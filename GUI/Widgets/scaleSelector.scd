(
//------//
// INIT //
init: { |self|
	self[\scaleNames] = [
		"Minor", "Locrian", "Major", "Dorian",
		"Phrygian", "Lydian", "Mixolydian"
	];
	self[\scaleSymbols] = [
		\minor, \ionian, \major, \dorian,
		\phrygian, \lydian, \mixolydian
	];
	self[\view] = GMMultiButton()
	.fontRatio_(0.5)
	.states_(self[\scaleNames]);
	self[\player] = nil;
	self
},

//---------//
// METHODS //
setPlayer: { |self, player|
	var detectIndex;
	self.disconnect;
	self[\player] = player;
	// Widget action
	self[\view].action_({ |index|
		~mh.cmd(
			\setScale,
			[
				self[\player][\id],
				self[\scaleSymbols][index]
			]
		);
	});
	// Signal(s) function(s)
	self[\scaleFunction] = { |args|
		// [freq]
		var detectIndex;
		self[\scale] = args[0];
		detectIndex =
		self[\scaleSymbols].indexOfEqual(self[\scale]);
		if(detectIndex.isNil) {
			{ self[\view].desindex; }.defer;
		} {
			{ self[\view].state_(detectIndex); }.defer;
		};
	};
	self[\playerRMFunction] = { self.doRemove; };
	// Signal(s) connection(s)
	self[\player].addSignal(\scale, self[\scaleFunction]);
	self[\player].addSignal(\remove, self[\playerRMFunction]);
	// State update
	self[\scale] = self[\player][\scale];
	detectIndex = self[\scaleSymbols].indexOfEqual(self[\scale]);
	if(detectIndex.isNil) {
		{ self[\view].desindex; }.defer;
	} {
		{ self[\view].state_(detectIndex); }.defer;
	};
},

disconnect: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\scale, self[\scaleFunction]);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\scaleFunction] = nil;
		self[\playerRMFunction] = nil;
		self[\view].action_({});
		self[\player] = nil;
		self[\scale] = nil;
	};
},

removed: false,
doRemove: { |self|
	self.disconnect;
	if(self[\view].notNil) {
		self[\removed] = true;
		self[\view].remove;
	};
	self.clear;
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\view].style_(widgetStyle);
},

scale: nil,
setAvailableScales: { |self, scaleSymbols, scaleNames|
	self[\scaleSymbols] = scaleSymbols;
	self[\scaleNames] = scaleNames;
	self[\scaleSelector].states_(self[\scaleNames]);
	if(self[\player.notNil]) {
		self[\scaleFunction].value([self[\scale]]);
	};
},
)