(
//------//
// INIT //
init: { |self|
	self[\view] = UserView()
	.onClose_({
		self[\view] = nil;
		self.doRemove;
	});
	self[\label] = GMTextView()
	.displayFrame_(true)
	.string_("freq")
	.fontRatio_(0.8)
	.maxFontSize_(24)
	.maxWidth_(128)
	.orientation_(\top);
	self[\freqSlider] = ~mhi.addFreqSlider;
	self[\scaleSelector] = ~mhi.addScaleSelector;
	self[\widgets] = [
		self[\freqSlider],
		self[\scaleSelector]
	];
	self[\view].layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\label], 1)
		.add(
			VLayout()
			.margins_(0)
			.spacing_(0)
			.add(self[\freqSlider][\view])
			.add(self[\scaleSelector][\view]),
			1
		)
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
	self[\label].style_(textStyle);
},
)