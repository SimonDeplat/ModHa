(
updateOuts: { |self|
	if(self[\synthView][\player].notNil) {
		var nameDetect;
		var effectStates = List(0);
		var masterNames = List(0);
		var availableEffects = List(0);
		var forbiddenEffects = List(0);
		// This will prevent synth self-connection
		forbiddenEffects.add(self[\synthView][\synth]);
		// Iterate through effects,
		// and check if they could
		// provoke a circular connection
		self[\synthView][\player][\effects].do({ |effect|
			if(availableEffects.includes(effect).not) {
				if(forbiddenEffects.includes(effect[\parent]).not) {
					var circular = false;
					var currentEffect = effect;
					var effectChain = List(0);
					effectChain.add(currentEffect);
					while { currentEffect[\parent][\outNode][\type] != \master } {
						currentEffect = currentEffect[\parent][\outNode];
						effectChain.add(currentEffect);
					};
					effectChain.do({ |effect|
						if(effect[\parent] == self[\synthView][\synth])
						{ circular = true; };
					});
					if(circular) {
						// Could be optimized
						forbiddenEffects.add(effectChain[0][\parent]);
					} {
						effectChain.do({ |effect|
							if(availableEffects.includes(effect).not)
							{ availableEffects.add(effect); };
						});
					};
				};
			};
		});
		// Reference effect names
		availableEffects.do({ |effect| effectStates.add(effect[\name]); });
		// Update effect UI
		if(effectStates.size > 0) {
			self[\effectSelector]
			.states_(effectStates)
			.desindex
			.action_({ |index|
				self[\synthView][\synth].setOut(
					availableEffects[index];
				);
				self[\synthView][\view].layout.index_(0);
			});
			// Try to detect current out
			nameDetect = effectStates.indexOfEqual(
				self[\synthView][\outLabel].string);
			if(nameDetect.isNil)
			{ self[\effectSelector].desindex; }
			{ self[\effectSelector].state_(nameDetect); };
			self[\effectSelector].visible_(true);
		} {
			self[\effectSelector].visible_(false);
		};
		// Reference master names
		self[\synthView][\player]
		[\masters].do({ |master| masterNames.add(master[\name]); });
		// Update master UI
		self[\masterSelector]
		.states_(masterNames)
		.desindex
		.action_({ |index|
			self[\synthView][\synth].setOut(
				self[\synthView][\player][\masters][index]);
			self[\synthView][\view].layout.index_(0);
		});
		// Try to detect current out
		nameDetect = masterNames.indexOfEqual(
			self[\synthView][\outLabel].string);
		if(nameDetect.isNil)
		{ self[\masterSelector].desindex; }
		{ self[\masterSelector].state_(nameDetect); };
		// Clear stuff
		forbiddenEffects.clear;
	};
},

doRemove: { |self|
	self[\view].removeAll;
	self[\view].remove;
	self.clear;
},

init: { |self|
	var topLayout, bottomLayout;
	
	self[\view] = UserView();
	self[\string] = GMTextView()
	.string_("Plug this synth into :");
	self[\closeButton] = GMCloseButton()
	.action_({
		self[\synthView][\view]
		.layout.index_(0);
	});
	self[\effectSelector] = GMMultiButton()
	.orientation_(\vertical);
	self[\masterSelector] = GMMultiButton()
	.orientation_(\vertical);
	
	topLayout = HLayout()
	.margins_(0)
	.spacing_(0)
	.add(self[\string], 9)
	.add(self[\closeButton], 1);

	bottomLayout = HLayout()
	.margins_(0)
	.spacing_(0)
	.add(self[\effectSelector], 1)
	.add(self[\masterSelector], 1);

	self[\view].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(topLayout, 1)
		.add(bottomLayout, 9)
	);
},
)