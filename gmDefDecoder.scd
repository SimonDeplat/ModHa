(
~gmDef = (
	gmDefs: (),
	server: s,
	// Reference every synth, accessed by ID
	synths: (),
	players: (),
	synthFreed: false,

	loadGMDefs: { |self|
		// Load synth datas
		PathName(self[\folder] ++ "/GMDefs/").files.do({ |fileName|
			var synthData;
			//fileName.postln;
			synthData = this.executeFile(fileName.fullPath);
			// Fill \category if nil
			if(synthData.includesKey(\category).not)
			{ synthData[\category] = \uncategorized; };
			// Allow param access by symbol key
			synthData[\param] = ();
			synthData[\params].do({ |param|
				synthData[\param][param[\symbol]] = param;
			});
			// Reference datas
			self[\gmDefs][synthData[\name].asSymbol] = synthData;
		});
	},

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
	setSliderParams: { |self, slider, param|
		//    CONTROL    //
		if(param.includesKey(\min))
		{ slider.min_(param[\min]); }
		{ slider.min_(0); };
		if(param.includesKey(\max))
		{ slider.max_(param[\max]); }
		{ slider.max_(1); };
		if(param.includesKey(\scale))
		{ slider.scale_(param[\scale]); }
		{ slider.scale_(\lin); };
		if(param.includesKey(\polarity))
		{ slider.polarity_(param[\polarity]); }
		{ slider.polarity_(\uni); };
		if(param.includesKey(\expMin))
		{ slider.expMin_(param[\expMin]); }
		{ slider.expMin_(0.01); };
		if(param.includesKey(\modStep))
		{ slider.modStep_(param[\modStep]); }
		{ slider.modStep_(2); };
		if(param.includesKey(\modStepOperator))
		{ slider.modStepOperator_(param[\modStepOperator]); }
		{ slider.modStepOperator_(\mul); };
		if(param.includesKey(\modStepPixelRange))
		{ slider.modStepPixelRange_(param[\modStepPixelRange]); }
		{ slider.modStepPixelRange_(10); };
		if(param.includesKey(\modStep2))
		{ slider.modStep2_(param[\modStep2]); }
		{ slider.modStep2_(2); };
		if(param.includesKey(\modStep2Operator))
		{ slider.modStep2Operator_(param[\modStep2Operator]); }
		{ slider.modStep2Operator_(\mul); };
		if(param.includesKey(\modStep2PixelRange))
		{ slider.modStep2PixelRange_(param[\modStep2PixelRange]); }
		{ slider.modStep2PixelRange_(10); };
		//    UI    //
		if(param.includesKey(\orientation))
		{ slider.orientation_(param[\orientation]); }
		{ slider.orientation_(\vertical); };
		if(param.includesKey(\displayFunction))
		{ slider.displayFunction_(param[\displayFunction]); }
		{ slider.displayFunction_(nil); };
		if(param.includesKey(\helpersNumber))
		{ slider.helpersNumber_(param[\helpersNumber]); }
		{ slider.helpersNumber_(3); };
		if(param.includesKey(\helperSubdivisions))
		{ slider.helperSubdivisions_(param[\helperSubdivisions]); }
		{ slider.helperSubdivisions_(4); };
		if(param.includesKey(\helpersStyle))
		{ slider.helpersStyle_(param[\helpersStyle]); }
		{ slider.helpersStyle_(\line); };
		if(param.includesKey(\helpersRatio))
		{ slider.helpersRatio_(param[\helpersRatio]); }
		{ slider.helpersRatio_(1); };
		if(param.includesKey(\centerHelpers))
		{ slider.centerHelpers_(param[\centerHelpers]); }
		{ slider.centerHelpers_(true); };
		if(param.includesKey(\displayHelpers))
		{ slider.displayHelpers_(param[\displayHelpers]); }
		{ slider.displayHelpers_(false); };
		if(param.includesKey(\displayValue))
		{ slider.displayValue_(param[\displayValue]); }
		{ slider.displayValue_(true); };
		if(param.includesKey(\roundValue))
		{ slider.roundValue_(param[\roundValue]); }
		{ slider.roundValue_(0.01); };
		//    GENERAL SETTINGS    //
		// TO DO /!\
		//slider.slideRatio_();
		//slider.centerValue_();
		//slider.minAlpha_();
		//slider.fontRatio_();
	},

	setMultiSliderParams: { |self, slider, param|
		//    CONTROL    //
		if(param.includesKey(\min))
		{ slider.min_(param[\min]); }
		{ slider.min_(0); };
		if(param.includesKey(\max))
		{ slider.max_(param[\max]); }
		{ slider.max_(1); };
		if(param.includesKey(\scale))
		{ slider.scale_(param[\scale]); }
		{ slider.scale_(\lin); };
		if(param.includesKey(\polarity))
		{ slider.polarity_(param[\polarity]); }
		{ slider.polarity_(\uni); };
		if(param.includesKey(\expMin))
		{ slider.expMin_(param[\expMin]); }
		{ slider.expMin_(0.01); };
		if(param.includesKey(\modStep))
		{ slider.modStep_(param[\modStep]); }
		{ slider.modStep_(2); };
		if(param.includesKey(\modStepOperator))
		{ slider.modStepOperator_(param[\modStepOperator]); }
		{ slider.modStepOperator_(\mul); };
		if(param.includesKey(\modStepPixelRange))
		{ slider.modStepPixelRange_(param[\modStepPixelRange]); }
		{ slider.modStepPixelRange_(10); };
		if(param.includesKey(\modStep2))
		{ slider.modStep2_(param[\modStep2]); }
		{ slider.modStep2_(2); };
		if(param.includesKey(\modStep2Operator))
		{ slider.modStep2Operator_(param[\modStep2Operator]); }
		{ slider.modStep2Operator_(2); };
		if(param.includesKey(\modStep2PixelRange))
		{ slider.modStep2PixelRange_(param[\modStep2PixelRange]); }
		{ slider.modStep2PixelRange_(10); };
		//    UI    //
		if(param.includesKey(\orientation))
		{ slider.orientation_(param[\orientation]); }
		{ slider.orientation_(\horizontal); };
		if(param.includesKey(\displayFunction))
		{ slider.displayFunction_(param[\displayFunction]); }
		{ slider.displayFunction_(nil); };
		if(param.includesKey(\helpersNumber))
		{ slider.helpersNumber_(param[\helpersNumber]); }
		{ slider.helpersNumber_(3); };
		if(param.includesKey(\helperSubdivisions))
		{ slider.helperSubdivisions_(param[\helperSubdivisions]); }
		{ slider.helperSubdivisions_(4); };
		if(param.includesKey(\helpersStyle))
		{ slider.helpersStyle_(param[\helpersStyle]); }
		{ slider.helpersStyle_(\dot); };
		if(param.includesKey(\centerHelpers))
		{ slider.centerHelpers_(param[\centerHelpers]); }
		{ slider.centerHelpers_(true); };
		if(param.includesKey(\multiSliderdisplayHelpers))
		{ slider.displayHelpers_(param[\multiSliderDisplayHelpers]); }
		{ slider.displayHelpers_(false); };
		if(param.includesKey(\roundValue))
		{ slider.roundValue_(param[\roundValue]); }
		{ slider.roundValue_(0.01); };
		//    GENERAL SETTINGS    //
		// TO DO /!\
		//slider.slideRatio_();
		//slider.centerValue_();
		//slider.minAlpha_();
		//slider.fontRatio_();
	},

	setSlider2Params: { |self, slider, xParam, yParam|
		var array;
		//    CONTROL    //
		// Min
		array = [0, 0];
		if(xParam.includesKey(\min)) { array[0] = xParam[\min]; };
		if(yParam.includesKey(\min)) { array[1] = yParam[\min]; };
		slider.min_(array);
		// Max
		array = [1, 1];
		if(xParam.includesKey(\max)) { array[0] = xParam[\max]; };
		if(yParam.includesKey(\max)) { array[1] = yParam[\max]; };
		slider.max_(array);
		// Scale
		array = [\lin, \lin];
		if(xParam.includesKey(\scale)) { array[0] = xParam[\scale]; };
		if(yParam.includesKey(\scale)) { array[1] = yParam[\scale]; };
		slider.scales_(array);
		// Polarities
		array = [\uni, \uni];
		if(xParam.includesKey(\polarity)) { array[0] = xParam[\polarity]; };
		if(yParam.includesKey(\polarity)) { array[1] = yParam[\polarity]; };
		slider.polarities_(array);
		// Exp Mins
		array = [0.01, 0.01];
		if(xParam.includesKey(\expMin)) { array[0] = xParam[\expMin]; };
		if(yParam.includesKey(\expMin)) { array[1] = yParam[\expMin]; };
		slider.expMins_(array);
		// Mod Steps
		array = [2, 2];
		if(xParam.includesKey(\modStep)) { array[0] = xParam[\modStep]; };
		if(yParam.includesKey(\modStep)) { array[1] = yParam[\modStep]; };
		slider.modSteps_(array);
		// Mod Step Operators
		array = [\mul, \mul];
		if(xParam.includesKey(\modStepOperator)) { array[0] = xParam[\modStepOperator]; };
		if(yParam.includesKey(\modStepOperator)) { array[1] = yParam[\modStepOperator]; };
		slider.modStepsOperators_(array);
		// Mod Step Pixel Range
		array = [10, 10];
		if(xParam.includesKey(\modStepPixelRange)) { array[0] = xParam[\modStepPixelRange]; };
		if(yParam.includesKey(\modStepPixelRange)) { array[1] = yParam[\modStepPixelRange]; };
		slider.modStepsPixelRanges_(array);
		//    UI    //
		// Helpers Numbers
		array = [3, 3];
		if(xParam.includesKey(\helpersNumber)) { array[0] = xParam[\helpersNumber]; };
		if(yParam.includesKey(\helpersNumber)) { array[1] = yParam[\helpersNumber]; };
		slider.helpersNumbers_(array);
		// Helpers Subdivision
		array = [4, 4];
		if(xParam.includesKey(\helperSubdivisions)) { array[0] = xParam[\helperSubdivisions]; };
		if(yParam.includesKey(\helperSubdivisions)) { array[1] = yParam[\helperSubdivisions]; };
		slider.helperSubdivisions_(array);
		// Helpers Style
		if(xParam.includesKey(\helpersStyle))
		{ slider.helpersStyle_(xParam[\helpersStyle]); }
		{ slider.helpersStyle_(\dot); };
		// Center Helpers
		if(xParam.includesKey(\centerHelpers))
		{ slider.centerHelpers_(xParam[\centerHelpers]); }
		{ slider.centerHelpers_(true); };
		// Draw Helpers
		if(xParam.includesKey(\displayHelpers))
		{ slider.displayHelpers_(xParam[\displayHelpers]); }
		{ slider.displayHelpers_(false); };
		// Display line
		if(xParam.includesKey(\displayLine))
		{ slider.displayLine_(xParam[\displayLine]); }
		{ slider.displayLine_(false); };
		// Symbol
		if(xParam.includesKey(\sliderSymbol))
		{ slider.symbol_(xParam[\sliderSymbol]); }
		{ slider.symbol_(\circle); };
		// Display values
		if(xParam.includesKey(\displayValue))
		{ slider.displayValues_(xParam[\displayValue]); }
		{ slider.displayValues_(true); };
		// Round values
		array = [0.01, 0.01];
		if(xParam.includesKey(\roundValue)) { array[0] = xParam[\roundValue]; };
		if(yParam.includesKey(\roundValue)) { array[1] = yParam[\roundValue]; };
		slider.roundValues_(array);
		//    GENERAL SETTINGS    //
		// TO DO /!\
		// Helpers ratio
		//slider.helpersRatio_();
		// Symbol min size
		//slider.symbolMinSize_();
		// Symbol max size
		//slider.symbolMaxSize_();
		// Symbol ratio
		//slider.symbolRatio_();
		// Font ratio
		//slider.fontRatio_();
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

	doCopy: { |self, symbol, data|
		self[\copyPaste][symbol] = data;
	},

	doPaste: { |self, symbol|
		var data = nil;
		if(self[\copyPaste][symbol].notNil)
		{ data = self[\copyPaste][symbol].deepCopy; };
		data
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
		noteNoire: "noteNoire.svg",
		noteRonde: "noteRonde.svg",
		noteRonde2: "noteRonde2.svg",
		noteRonde3: "noteRonde3.svg",
		noteNoire2: "noteNoire2.svg",
		noteNoire3: "noteNoire3.svg",
		noteNoire4: "noteNoire4.svg",
		noteDouble: "noteDouble.svg",
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

	init: { |self|
		self[\folder] = thisProcess.nowExecutingPath.dirname;
		self[\userFolder] = self[\folder] +/+ "userFolder/";
		// Construct user folder if needed
		// /!\ WIP: userFolder disabled for now
		/*this.executeFile(self[\folder]
			++ "/functions/checkUserFolder.scd");*/
		self.loadGMDefs;
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
		// Copy-paste dictionary
		self[\copyPaste] = ();
		//////////////////////
		//    PROTOTYPES    //
		//////////////////////
		// Prototypes are loaded here:
		this.executeFile(self[\folder]
			++ "/protos/loadConstructors.scd");
		// Prevents (or at least tries...) re-trying to free synths on CmdPeriod
		CmdPeriod.doOnce({ self[\synthFreed] = true; });
	},
);

~gmDef.init;
)