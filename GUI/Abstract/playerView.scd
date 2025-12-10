(
//------//
// INIT //
init: { |self|
	self[\view] = UserView()
	.onClose_({
		self[\view] = nil;
		self.doRemove;
	});
	self[\playStopButton] = ~mhi.addPlayStopButton;
	self[\freqView] = ~mhi.addFreqView;
	self[\widgets] = [
		self[\playStopButton],
		self[\freqView]
	];
	self[\view].layout_(
		VLayout()
		.add(self[\playStopButton][\view], 1)
		.add(self[\freqView][\view], 1)
	);
	self[\player] = nil;
	self
},

//---------//
// METHODS //
setPlayer: { |self, player|
	self.disconnect;
	self[\widgets].do({ |widget|
		widget.setPlayer(player);
	});
	self[\player] = player;
	self[\playerRMFunction] = { self.doRemove; };
	self[\player].addSignal(\remove, self[\playerRMFunction]);
},

disconnect: { |self|
	if(self[\player].notNil) {
		self[\widgets].do({ |widget|
			widget.disconnect;
		});
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\playerRMFunction] = nil;
		self[\player] = nil;
	};
},

removed: false,
doRemove: { |self|
	self[\widgets].do({ |widget|
		widget.doRemove;
	});
	if(self[\view].notNil) {
		self[\removed] = true;
		self[\view].remove;
	};
	self.clear;
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\widgets].do({ |widget|
		widget.setStyles(
			style,
			textStyle,
			widgetStyle
		);
	});
},
)