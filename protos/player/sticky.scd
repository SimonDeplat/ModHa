(
setPlayer: { |self, player|
	self[\playButton].setPlayer(player);
	self[\cycleView].setPlayer(player);
},

disconnect: { |self|
	self[\playButton].disconnect;
	self[\cycleView].disconnect;
},

setStyles: { |self, style, smallStyle, widgetStyle|
	self[\cycleView].setStyles_(style, smallStyle, widgetStyle);
	self[\playButton].setStyles_(style, smallStyle, widgetStyle);
},

doRemove: { |self|
	self[\cycleView].doRemove;
	self[\playButton].doRemove;
	self[\view].remove;
	self.clear;
},

init: { |self|
	self[\view] = UserView();
	self[\cycleView] = ~gmDef.getCycleView;
	self[\playButton] = ~gmDef.getPlayButton;
	self[\view].layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\cycleView][\view])
		.add(self[\playButton][\view])
	);
	self
},
)