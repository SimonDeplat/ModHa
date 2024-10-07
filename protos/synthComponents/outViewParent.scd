(
availableEffects: List(0),
updateOuts: { |self|
	if(self[\synthView][\player].notNil) {
		var nameDetect;
		var effectStates = List(0);
		var masterNames = List(0);

		self[\availableEffects].clear;
		self[\availableEffects] = List(0);

		// /!\ For now, auto connection,
		// circular references, etc, are only
		// handled by the UI, not the synth itself...

		// /!\ FIX ME: REMOVE CIRCULAR REFERENCES
		// AND REORDER EFFECTS NODES IF NEEDED
		// REORDER -> IN EFFECT SYNTH
		self[\synthView][\player][\effects].do({ |effect|
			// Prevent the synth from self connecting :
			if(effect[\parent] !== self[\synthView][\synth]) {
				effectStates.add(effect[\name]);
				self[\availableEffects].add(effect);
			};
		});

		if(effectStates.size > 0) {
			self[\effectSelector]
			.states_(effectStates)
			.desindex
			.action_({ |index|
				self[\synthView][\synth].setOut(
					self[\availableEffects][index];
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

		self[\synthView][\player]
		[\masters].do({ |master|
			masterNames.add(master[\name]);
		});

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
	};
},
)