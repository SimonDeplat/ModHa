(
~gmDef = (
	gmDefs: (),
	server: s,
	// Reference every synth, accessed by ID
	synths: (),
	players: (),
	synthFreed: false,

	//////////////////////////
	//    DUMP UTILITIES    //
	//////////////////////////
	dumpSynths: { |self|
		"ModHa: available synths:".postln;
		self[\gmDefs].keysValuesDo({ |key, value|
			"\\".post;
			value[\name].postln;
		});
	},

	dumpContinuousSynths: { |self|
		"ModHa: continuous synths:".postln;
		self[\gmDefs].keysValuesDo({ |key, value|
			if(value[\type] == \continuous) {
				"\\".post;
				value[\name].postln;
			};
		});
	},

	dumpDiscreteSynths: { |self|
		"ModHa: discrete synths:".postln;
		self[\gmDefs].keysValuesDo({ |key, value|
			if(value[\type] == \discrete) {
				"\\".post;
				value[\name].postln;
			};
		});
	},

	dumpEffectSynths: { |self|
		"ModHa: effect synths:".postln;
		self[\gmDefs].keysValuesDo({ |key, value|
			if(value[\type] == \effect) {
				"\\".post;
				value[\name].postln;
			};
		});
	},

	dumpInputSynths: { |self|
		"ModHa: input synths:".postln;
		self[\gmDefs].keysValuesDo({ |key, value|
			if(value[\type] == \input) {
				"\\".post;
				value[\name].postln;
			};
		});
	},

	dumpSynthsByType: { |self|
		self.dumpContinuousSynths;
		self.dumpDiscreteSynths;
		self.dumpEffectSynths;
		self.dumpInputSynths;
	},

	dumpSynthsByCategory: { |self|
		var categories = ();
		var noCategory = List(0);
		self[\gmDefs].keysValuesDo({ |key, value|
			if(value.includesKey(\category)) {
				if(categories.includesKey(value[\category]).not)
				{ categories[value[\category]] = List(0); };
				categories[value[\category]].add(value[\name]);
			} {
				noCategory.add(value[\name]);
			};
		});
		categories.keysValuesDo({ |key, value|
			"ModHa: ".post;
			key.post;
			" category synths:".postln;
			value.do({ |name|
				"\\".post;
				name.postln;
			});
		});
		"ModHa: uncategorized synths:".postln;
		noCategory.do({ |name|
			"\\".postln;
			name.postln;
		});
	},
	
	///////////////////////
	//    PARAM VIEWS    //
	///////////////////////
	setSliderParams: { |self, slider, paramDict|
		// FIX ME : impl. properties
		if(paramDict.includesKey(\scale)) {
			slider.scale_(paramDict[\scale]); };
		if(paramDict.includesKey(\polarity)) {
			slider.polarity_(paramDict[\polarity]); };
		if(paramDict.includesKey(\orientation)) {
			slider.orientation_(paramDict[\orientation]); };
		if(paramDict.includesKey(\modStep)) {
			slider.modStep_(paramDict[\modStep]); };
		if(paramDict.includesKey(\modStepOperator)) {
			slider.modStepOperator_(paramDict[\modStepOperator]); };
		if(paramDict.includesKey(\modStepPixelRange)) {
			slider.modStepPixelRange_(paramDict[\modStepPixelRange]); };
		if(paramDict.includesKey(\modStep2)) {
			slider.modStep2_(paramDict[\modStep2]); };
		if(paramDict.includesKey(\modStep2Operator)) {
			slider.modStep2Operator_(paramDict[\modStep2Operator]); };
		if(paramDict.includesKey(\modStep2PixelRange)) {
			slider.modStep2PixelRange_(paramDict[\modStep2PixelRange]); };
		if(paramDict.includesKey(\displayFunction)) {
			slider.displayFunction_(paramDict[\displayFunction]); };
		if(paramDict.includesKey(\helpersNumber)) {
			slider.helpersNumber_(paramDict[\helpersNumber]); };
		if(paramDict.includesKey(\helperSubdivisions)) {
			slider.helperSubdivisions_(paramDict[\helperSubdivisions]); };
	},

	setMultiSliderParams: { |self, slider, paramDict|
		// FIX ME : impl. properties
		if(paramDict.includesKey(\scale)) {
			slider.scale_(paramDict[\scale]); };
		if(paramDict.includesKey(\polarity)) {
			slider.polarity_(paramDict[\polarity]); };
		if(paramDict.includesKey(\orientation)) {
			slider.orientation_(paramDict[\orientation]); };
		if(paramDict.includesKey(\modStep)) {
			slider.modStep_(paramDict[\modStep]); };
		if(paramDict.includesKey(\modStepOperator)) {
			slider.modStepOperator_(paramDict[\modStepOperator]); };
		if(paramDict.includesKey(\modStepPixelRange)) {
			slider.modStepPixelRange_(paramDict[\modStepPixelRange]); };
		if(paramDict.includesKey(\modStep2)) {
			slider.modStep2_(paramDict[\modStep2]); };
		if(paramDict.includesKey(\modStep2Operator)) {
			slider.modStep2Operator_(paramDict[\modStep2Operator]); };
		if(paramDict.includesKey(\modStep2PixelRange)) {
			slider.modStep2PixelRange_(paramDict[\modStep2PixelRange]); };
		if(paramDict.includesKey(\displayFunction)) {
			slider.displayFunction_(paramDict[\displayFunction]); };
		if(paramDict.includesKey(\helpersNumber)) {
			slider.helpersNumber_(paramDict[\helpersNumber]); };
		if(paramDict.includesKey(\helperSubdivisions)) {
			slider.helperSubdivisions_(paramDict[\helperSubdivisions]); };
	},

	/////////////////////
	//    MISC VIEW    //
	/////////////////////
	uidCounter: 0,
	getUID: { |self|
		var uid = Date.getDate.dayStamp;
		uid = uid ++ Date.getDate.hourStamp;
		uid = uid.replace( ":", "" );
		uid = uid.replace( ".", "" );
		uid = uid ++ self[\uidCounter].asString;
		self[\uidCounter] = self[\uidCounter] + 1;
		uid
	},
	getSymbolUID: { |self|
		var symbol = self.getUID;
		symbol = $$ ++ symbol;
		symbol = symbol.asSymbol;
		symbol
	},

	folder: nil,
	getFilesFor: { |self, rule, symbol|
		var folder, list;

		list = List(0);

		if(rule == \playerState) {
			PathName(
				self[\userFolder]
				++ "/presets/players/"
			).files.do({ |fileName|
				if(fileName.fileName.endsWith(".gmdef_player")) {
					list.add([
						this.executeFile(fileName.fullPath)[\name],
						fileName.fullPath
					]);
				};
			});
		};

		if(rule == \synth) {
			PathName(self[\userFolder]
				++ "/presets/synths/"
			).files.do({ |fileName|
				if(fileName.fileName.beginsWith(symbol)) {
					list.add([
						this.executeFile(fileName.fullPath)[\name],
						fileName.fullPath
					]);
				};
			});
		};

		list
	},

	copiedEnv: nil,
	copyEnv: { |self, env|
		self[\copiedEnv] = env.deepCopy;
	},
	pasteEnv: { |self|
		var env = nil;
		if(self[\copiedEnv].notNil)
		{ env = self[\copiedEnv].deepCopy; };
		env;
	},

	defaultProperties: (
		style: GMStyle(),
		textStyle: GMStyle(),
		slidersDisplayValues: true,
		slidersDisplayHelpers: true,
		pairsDisplayHelpers: true,
		helpersOnlyWhenSet: true,
		margins: 5,
		itemMaxWidth: 128
	),

	icons: (
		add: "add.svg",
		slider: "iconSlider.svg",
		multiSlider: "iconMultiSlider.svg",
		zoomIn: "iconZoomIn.svg",
		zoomOut: "iconZoomOut.svg",
		audible: "audible.svg",
		muted: "muted.svg",
		copy: "copy.svg",
		paste: "paste.svg",
		arrowBot: "arrowBot.svg",
		arrowTop: "arrowTop.svg",
		save: "save.svg",
		saveAs: "saveAs.svg",
		load: "load.svg",
		note: "note.svg",
		glass: "glass.svg",
		out: "out.svg",
		remove: "remove.svg",
		check: "check.svg",
	),

	getIcon: { |self, symbol|
		self[\folder] ++ "/assets/icons/" ++ self[\icons][symbol]
	},

	// Contexts
	invokeSingleView: { |self, synthSymbol|
		if(self[\gmDefs].includesKey(synthSymbol)) {
			var context = self.getSingleView;
			var synth = self.getSynth(synthSymbol);
			var player = self.getPlayer;
			synth.setPlayer(player);
			context.setSynth(synth);
			context.setPlayer(player);
			context.setStyles(
				self[\style],
				self[\textStyle],
				self[\widgetStyle]
			);
			context.doFront;
		} {
			"ModHa: invokeSingleView: synthSymbol not found".warn;
		};
	},

	invokeInvoker: { |self|
		var context = self.getInvoker;
		var player = self.getPlayer;
		context.setPlayer(player);
		context.setStyles(
			self[\style],
			self[\textStyle],
			self[\widgetStyle]
		);
		context.doFront;
	},

	invokeOrchestra: { |self|
		var context = self.getOrchestra;
		var player = self.getPlayer;
		context.setPlayer(player);
		context.setStyles(
			self[\style],
			self[\textStyle],
			self[\widgetStyle]
		);
		context.doFront;
	},
	
	invokeGrid: { |self, grid|
		var player = self.getPlayer;
		var window = self.getMainWindow;
		window.setPlayer(player);
		window.setAsMonoGrid(grid);
		window.doFront;
		//CmdPeriod.doOnce({ window.doClose; });
	},

	init: { |self|
		self[\folder] = thisProcess.nowExecutingPath.dirname;
		self[\userFolder] = self[\folder] +/+ "userFolder/";
		// Construct user folder if needed
		this.executeFile(self[\folder]
			++ "/functions/checkUserFolder.scd");

		// Load synth datas
		PathName(self[\folder] ++ "/GMDefs/").files.do({ |fileName|
			var synthData = this.executeFile(fileName.fullPath);
			self[\gmDefs][synthData[\name].asSymbol] = synthData;
		});
		self.initLoader;
		self.initTextInput;

		// Style setup
		self[\style] = GMStyle();
		self[\textStyle] =
		self[\style]
		.deepCopy
		.backColor_(self[\style].borderColor.deepCopy)
		.borderSize_(0)
		.secondBorderSize_(0)
		.thirdBorderSize_(0);
		self[\widgetStyle] =
		self[\style]
		.deepCopy
		.borderSize_(2)
		.secondBorderSize_(2)
		.thirdBorderSize_(0);

		// Load master synth definition
		this.executeFile(self[\folder]
			++ "/protos/masterSynth.scd");

		//////////////////////
		//    PROTOTYPES    //
		//////////////////////
	
		// Synths
		self[\synthParent] =
		this.executeFile(self[\folder]
			++ "/protos/synth/synth.scd");
		self[\continuousSynthParent] =
		this.executeFile(self[\folder]
			++ "/protos/synth/continuousSynth.scd");
		self[\discreteSynthParent] =
		this.executeFile(self[\folder]
			++ "/protos/synth/discreteSynth.scd");
		self[\effectSynthParent] =
		this.executeFile(self[\folder]
			++ "/protos/synth/effectSynth.scd");
		self[\inputSynthParent] =
		this.executeFile(self[\folder]
			++ "/protos/inputSynth.scd");
		self[\getSynth] =
		this.executeFile(self[\folder]
			++ "/protos/getSynth.scd");

		// Param View
		self[\paramViewParent] =
		this.executeFile(self[\folder]
			++ "/protos/synth/paramViewParent.scd");

		// Most prototypes are defined here:
		this.executeFile(self[\folder]
			++ "/protos/loadConstructors.scd");

		// Prevents re-trying to free synths on CmdPeriod
		CmdPeriod.doOnce({ self[\synthFreed] = true; });
	},
);

~gmDef.init;
)