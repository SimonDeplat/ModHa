(
setSaveFunction: { |self, func|
	self[\saveFunction] = func;
},

setSaveAsFunction: { |self, func|
	self[\saveAsFunction] = func;
},

setLoadFunction: { |self, func|
	self[\loadFunction] = func;
},

setStyles: { |self, style, textStyle|
	self[\saveButton].style_(style);
	self[\saveAsButton].style_(style);
	self[\loadButton].style_(style);
},

doRemove: { |self|
	self[\view].removeAll;
	self[\view].remove;
	self.clear;
},

init: { |self|
	self[\view] = UserView()
	.maxWidth_(96 * 3);
	self[\saveButton] = GMFeedbackButton()
	.svg_(~gmDef.getIcon(\save))
	.maxWidth_(96)
	.action_({
		if(self[\saveFunction].notNil)
		{ self[\saveFunction].value; };
	});
	self[\saveAsButton] = GMButton()
	.svg_(~gmDef.getIcon(\saveAs))
	.maxWidth_(96)
	.action_({
		if(self[\saveAsFunction].notNil)
		{ self[\saveAsFunction].value; };
	});
	self[\loadButton] = GMButton()
	.svg_(~gmDef.getIcon(\load))
	.maxWidth_(96)
	.action_({
		if(self[\loadFunction].notNil)
		{ self[\loadFunction].value; };
	});
	self[\view].layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\saveButton], 1)
		.add(self[\saveAsButton], 1)
		.add(self[\loadButton], 1)
	);
	self
},
)