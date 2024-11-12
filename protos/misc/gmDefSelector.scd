(
assignFunction: { |self, func|
	self[\func] = func;
},

arrangeByCategory: { |self|
	var categories = List(0);
	var defs = List(0);
	var categoryLayout = VLayout()
	.margins_(0)
	.spacing_(5);
	var buttonsLayout = VLayout()
	.margins_(0)
	.spacing_(5);
	self[\labels].clear;
	self[\buttons].clear;
	~gmDef[\gmDefs].do({ |def|
		var index = categories.indexOfEqual(def[\category]);
		if(index.isNil) {
			index = categories.size;
			categories.add(def[\category]);
			defs.add(List(0));
		};
		defs[index].add(def);
	});
	self[\container].removeAll;
	self[\container].remove;
	self[\container] = UserView()
	.layout_(
		HLayout()
		.margins_(0)
		.spacing_(5)
		.add(categoryLayout, 1)
		.add(buttonsLayout, 5)
	);
	self[\view].layout.add(self[\container]);
	categories.do({ |symbol, index|
		var layout, label;
		// Layout
		layout = HLayout()
		.margins_(0)
		.spacing_(0);
		buttonsLayout.add(layout);
		// Label
		label = GMTextView()
		.displayFrame_(true)
		.fontRatio_(0.5)
		.string_(symbol);
		if(self[\textStyle].notNil)
		{ label.style_(self[\textStyle]); };
		categoryLayout.add(label);
		self[\labels].add(label);
		// Iteration
		defs[index].do({ |def|
			var button = GMButton()
			.string_(def[\name])
			.fontRatio_(0.333)
			.action_({ self[\func].value(def); });
			if(self[\widgetStyle].notNil)
			{ button.style_(self[\widgetStyle]); };
			self[\buttons].add(button);
			layout.add(button);
		});
	});
	categories.clear;
	defs.clear;
},

arrangeByType: { |self|
	var buttonsPerLayout = 5;
	var mainLayout = VLayout()
	.margins_(0)
	.spacing_(20);
	var names = ["Continuous", "Discrete", "Effect", "Input"];
	var defs = [List(0), List(0), List(0), List(0)];
	self[\labels].clear;
	self[\buttons].clear;
	~gmDef[\gmDefs].do({ |def|
		switch(def[\type])
		{ \continuous } { defs[0].add(def); }
		{ \discrete } { defs[1].add(def); }
		{ \effect } { defs[2].add(def); }
		{ \input } { defs[3].add(def); };
	});
	defs.do({ |defList, index|
		var typeLayout = HLayout()
		.margins_(0)
		.spacing_(5);
		var label = GMTextView()
		.fontRatio_(0.333)
		.orientation_(\top)
		.maxWidth_(64)
		.displayFrame_(true)
		.string_(names[index]);
		var topLayout = VLayout()
		.margins_(0)
		.spacing_(5);
		var layout = HLayout();
		var currentIndex = 0;
		var nLayouts = 1;
		if(self[\textStyle].notNil)
		{ label.style_(self[\textStyle]); };
		self[\labels].add(label);
		typeLayout.add(label, 1);
		typeLayout.add(topLayout, 9);
		topLayout.add(layout, 1);
		defList.do({ |def|
			var button = GMButton()
			.string_(def[\name])
			.fontRatio_(0.333)
			.action_({ self[\func].value(def); });
			if(currentIndex == buttonsPerLayout) {
				layout = HLayout()
				.margins_(0)
				.spacing_(5);
				topLayout.add(layout, 1);
				nLayouts = nLayouts + 1;
				currentIndex = 0;
			};
			if(self[\widgetStyle].notNil)
			{ button.style_(self[\widgetStyle]); };
			self[\buttons].add(button);
			layout.add(button);
			currentIndex = currentIndex + 1;
		});
		mainLayout.add(typeLayout, nLayouts);
	});
	self[\container].removeAll;
	self[\container].remove;
	self[\container] = UserView()
	.layout_(mainLayout);
	self[\view].layout.add(self[\container]);
	names.clear;
	defs.clear;
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\view].background_(
		Color(
			style.backColor.red * 0.5,
			style.backColor.green * 0.5,
			style.backColor.blue * 0.5
		);
	);
	self[\textStyle] = textStyle;
	self[\labels].do({ |widget| widget.style_(textStyle); });
	self[\widgetStyle] = widgetStyle;
	self[\buttons].do({ |widget| widget.style_(widgetStyle); });
},

doRemove: { |self|
	self[\labels].clear;
	self[\buttons].clear;
	self[\view].removeAll;
	self[\view].remove;
	self.clear;
},

init: { |self|
	self[\textStyle] = nil;
	self[\labels] = List(0);
	self[\widgetStyle] = nil;
	self[\buttons] = List(0);
	self[\view] = UserView()
	.layout_(VLayout());
	self[\container] = UserView();
	self[\func] = { |def| def.postln; };
	self.arrangeByType;
	self
},
)