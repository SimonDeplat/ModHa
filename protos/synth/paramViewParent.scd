(
setInactive: { |self, aBoolean|
	if(self[\active]) {
		self[\view].visible_(false);
		self.disconnect;
		self[\active] = false;
		self[\index] = nil;
	};
},

hide: { |self, updateLayout = true|
	self[\view].visible_(false);
	self[\synthView].hideView(
		self,
		self[\title].string
	);
	self[\hidden] = true;
	self[\manager][\hiddenWidgets].add(self);
	self[\manager][\hiddenViews].add(self[\param][\symbol]);
	if(updateLayout)
	{ self[\manager].updateLayout; };
},
unhide: { |self, updateLayout = true|
	self[\view].visible_(true);
	self[\hidden] = false;
	self[\manager][\hiddenWidgets].remove(self);
	self[\manager][\hiddenViews].remove(self[\symbol]);
	if(updateLayout)
	{ self[\manager].updateLayout; };
},

setTitle: { |self, title| self[\title].string_(title); },
hideTitle: { |self| self[\title].visible_(false); },

addMenuItem: { |self, item, stretch = 1|
	self[\menu].layout.insert(item, 0, stretch);
},

addZoomButton: { |self|
	if(self[\zoomButton].isNil) {
		self[\zoomButton] = GMButton()
		.svg_(~gmDef.getIcon(\zoomOut))
		.action_({ self.zoom; });
		self.addMenuItem(self[\zoomButton]);
	};
},

setSynthAndParam: { |self, synth, param, index = nil|
	self.setTitle(param[\text]);
	self[\preferredIndex] = index;
	self[\index] = index;

	self[\active] = true;
	self[\view].visible_(true);

	// Pass to child protoytpe
	self.synthAndParam(synth, param);
},

initParent: { |self|
	// Variables
	self[\active] = false;
	self[\stretch] = 1;
	self[\hidden] = false;
	// Views
	self[\view] = UserView();
	self[\title] = GMTextView()
	.displayFrame_(true)
	.minHeight_(24);
	self[\menu] = UserView()
	.layout_(
		HLayout()
		.spacing_(8)
		.margins_(0)
	)
	.minHeight_(32)
	.maxHeight_(48);
	self[\paramContainer] = UserView();
	// Layout
	self[\view].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\title], 1)
		.add(self[\menu], 2)
		.add(self[\paramContainer], 9)
	);
	// Top Menu
	self[\hideButton] = GMButton()
	.svg_(~gmDef.getIcon(\arrowBot))
	.action_({ self.hide; });
	self.addMenuItem(self[\hideButton]);
	// Return self
	self
},
)