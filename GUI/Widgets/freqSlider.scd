(
//------//
// INIT //
init: { |self|
	self[\view] = GMSymbolSlider()
	.scale_(\exp)
	.orientation_(\horizontal)
	.fontRatio_(0.7)
	.onClose_({
		if(self[\removed].not) {
			self[\view] = nil;
			self.doRemove;
		};
	});
	self[\player] = nil;
	self
},

//---------//
// METHODS //
setPlayer: { |self, player|
	self.disconnect;
	self[\player] = player;
	// Widget action
	self[\view].action_({ |value|
		~mh.cmd(
			\setFreq,
			[
				self[\player][\id],
				value
			]
		);
	});
	// Signal(s) function(s)
	self[\tuningFunction] = { |args|
		// [freq]
		self[\view]
		.min_(args[0])
		.max_(args[0] * 2);
	};
	self[\freqFunction] = { |args|
		// [freq]
		self[\view].value_(args[0]);
	};
	self[\playerRMFunction] = { self.doRemove; };
	// Signal(s) connection(s)
	self[\player].addSignal(\tuning, self[\tuningFunction]);
	self[\player].addSignal(\freq, self[\freqFunction]);
	self[\player].addSignal(\remove, self[\playerRMFunction]);
	// State update
	self[\view].min_(player[\tuning]);
	self[\view].max_(player[\tuning] * 2);
	self[\view].value_(player[\freq]);
},

disconnect: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\diapason, self[\tuningFunction]);
		self[\player].rmSignal(\freq, self[\freqFunction]);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\tuningFunction] = nil;
		self[\freqFunction] = nil;
		self[\playerRMFunction] = nil;
		self[\view].action_({});
		self[\player] = nil;
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
)