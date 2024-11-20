(
assignFunction: { |self, func|
	self[\func] = func;
},

arrangeByCategory: { |self|
	// To be reimplemented
},

arrangeByType: { |self|
	// To be reimplemented
},

arrangeByTypeAndCat: { |self|
	var buttonsPerRow = 3;
	var labelLayout = VLayout()
	.margins_(0)
	.spacing_(5);
	var typeLayout = VLayout()
	.margins_(0)
	.spacing_(5);
	var typeLayouts = Array.fill(
		4, {
			HLayout()
			.margins_(0)
			.spacing_(5)
		});
	var defs = (
		continuous: (),
		discrete: (),
		effect: (),
		input: (),
	);
	self[\labels].do({ |label| label.remove; });
	self[\labels].clear;
	// Create type labels
	["continuous", "discrete", "effect", "input"].do({ |string|
		var label = GMTextView()
		.displayFrame_(true)
		.maxWidth_(48)
		.orientation_(\top)
		.fontRatio_(0.6)
		.string_(string);
		if(self[\textStyle].notNil)
		{ label.style_(self[\textStyle]); };
		self[\labels].add(label);
		labelLayout.add(label, 1);
	});
	// Sort defs
	self[\defs].do({ |def|
		if(defs[def[\type]].includesKey(def[\category]).not)
		{ defs[def[\type]][def[\category]] = List(0); };
		defs[def[\type]][def[\category]].add(def);
	});
	// Agence views
	[\continuous, \discrete, \effect, \input].do({ |type, index|
		self[\typeCategories][type].do({ |cat|
			var topLayout = VLayout()
			.spacing_(0)
			.margins_(0);
			var catLabel = GMTextView()
			.displayFrame_(true)
			.fontRatio_(0.6)
			.string_(cat.asString);
			var catLayout = VLayout()
			.margins_(0)
			.spacing_(0);
			var listSize = defs[type][cat].size;
			var lowerSquare = listSize.sqrt.trunc(1);
			var gridOrga;
			// Find best grid distribution
			if(listSize <= (lowerSquare * (lowerSquare + 1)))
			{ gridOrga = Array.fill(lowerSquare, { 0 }); }
			{ gridOrga = Array.fill(lowerSquare + 1, { 0 }); };
			listSize.do({ |index|
				gridOrga[index % gridOrga.size]
				= gridOrga[index % gridOrga.size] + 1;
			});
			// Create adequate layouts and insert buttons
			gridOrga.do({ |column, row|
				var absIndex;
				var layout = HLayout()
				.margins_(0)
				.spacing_(0);
				catLayout.add(layout, 1);
				column.do({ |c|
					absIndex = 0;
					row.do({ |n| absIndex = absIndex + gridOrga[n]; });
					absIndex = absIndex + c;
					layout.add(defs[type][cat][absIndex][\container], 1);
				});
			});
			// Label setup
			if(self[\textStyle].notNil)
			{ catLabel.style_(self[\textStyle]); };
			self[\labels].add(catLabel);
			// Layout referencement
			// View distribution
			topLayout.add(catLabel, 1);
			topLayout.add(catLayout, 4);
			typeLayouts[index].add(topLayout, gridOrga.size);
		});
	});
	// Misc View
	typeLayouts.do({ |layout| typeLayout.add(layout, 1) });
	// Update main layout
	self[\container].layout_(
		HLayout()
		.margins_(5)
		.spacing_(5)
		.add(labelLayout, 1)
		.add(typeLayout, 1)
	);
},

loadDefs: { |self|
	var list;
	// Iterate over gmDefs
	~gmDef[\gmDefs].do({ |def|
		// Def Object creation
		var defObj = ();
		defObj[\def] = def;
		defObj[\type] = def[\type];
		defObj[\category] = def[\category];
		defObj[\name] = def[\name];
		defObj[\container] = UserView()
		.layout_(
			VLayout()
			.margins_(0)
			.spacing_(0)
		);
		defObj[\button] = GMButton()
		.string_(def[\name])
		.fontRatio_(0.5)
		.maxFontSize_(24)
		.action_({ self[\func].value(def); });
		defObj[\container].layout.add(defObj[\button]);
		self[\defs].add(defObj);
		// Category referencement
		if(self[\categories].includes(def[\category]).not)
		{ self[\categories].add(def[\category]); };
		if(self[\typeCategories][def[\type]].includes(def[\category]).not)
		{ self[\typeCategories][def[\type]].add(def[\category]); };
	});
	// Sort datas alphabetically
	// Defs
	list = List(0);
	self[\defs].do({ |def|
		var index = 0;
		while { (index < list.size) and:
			{ def[\name] > list[index][\name]; } }
		{ index = index + 1; };
		list.insert(index, def);
	});
	self[\defs] = list;
	// Categories
	list = List(0);
	self[\categories].do({ |cat|
		var index = 0;
		while { (index < list.size) and:
			{ cat > list[index]; } }
		{ index = index + 1; };
		list.insert(index, cat);
	});
	self[\categories] = list;
	// Type categories
	[\continuous, \discrete, \effect, \type].do({ |type|
		list = List(0);
		self[\typeCategories][type].do({ |cat|
			var index = 0;
			while { (index < list.size) and:
				{ cat > list[index]; } }
			{ index = index + 1; };
			list.insert(index, cat);
		});
		self[\typeCategories][type] = list;
	});
	// Misc
	list.clear;
},

updateSearch: { |self|
	var quickLoadNil = false;
	self[\quickLoad] = nil;
	self[\defs].do({ |def|
		if(
			(def[\name].toLower.contains(self[\searchBar].string.toLower))
			or: { self[\searchBar].string == "" }) {
				def[\button].visible_(true);
				if(quickLoadNil.not) {
					self[\quickLoad] = def;
					quickLoadNil = true;
				} {
					if(self[\quickLoad].notNil)
					{ self[\quickLoad] = nil; };
				};
			} {
				def[\button].visible_(false);
			};
	});
},

doFocus: { |self|
	self[\searchBar].focus(true);
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
	self[\defs].do({ |def| def[\button].style_(widgetStyle); });
	self[\searchBar].font_(style.font.deepCopy);
},

doRemove: { |self|
	self[\labels].clear;
	self[\defs].clear;
	self[\categories].clear;
	self[\typeCategories].do({ |list| list.clear; });
	self[\typeCategories].clear;
	self[\view].removeAll;
	self[\view].remove;
	self.clear;
},

init: { |self|
	self[\textStyle] = nil;
	self[\widgetStyle] = nil;
	self[\defs] = List(0);
	self[\labels] = List(0);
	self[\categories] = List(0);
	self[\typeCategories] = (
		continuous: List(0),
		discrete: List(0),
		effect: List(0),
		input: List(0),
	);
	self[\quickLoad] = nil;
	self[\view] = UserView()
	.layout_(VLayout());
	self[\searchBar] = TextField()
	.align_(\center)
	.maxHeight_(64)
	.keyDownAction_({ |view, char, mod, unicode, keycode, key|
		if(unicode == 13) { // RET
			if(self[\quickLoad].notNil) {
				self[\func].value(self[\quickLoad]);
				self[\searchBar].string_("");
				self.updateSearch;
			};
		} {
			// Basically, keyDownAction happens before TextField's string is updated,
			// and action only triggers when RET key is pressed
			// Hack: To make TextField respond to key strokes, need to defer
			{ self.updateSearch; }.defer(0.05);
		};
	});
	self[\container] = UserView();
	self[\func] = { |def| def.postln; };
	self[\view].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\searchBar], 1)
		.add(self[\container], 9)
	);
	self.loadDefs;
	self.arrangeByTypeAndCat;
	self
},
)