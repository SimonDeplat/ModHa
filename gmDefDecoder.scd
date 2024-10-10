(
~gmDef = (
	gmDefs: (),
	server: s,
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

	folder: nil,

	loader: nil,
	loaderTitle: nil,
	loaderCloseButton: nil,
	loaderSelector: nil,
	initLoader: { |self|
		self[\loader] = UserView()
		.background_(Color(0.5, 0.5, 0.5));

		self[\loaderTitle] = GMTextView()
		.maxHeight_(96)
		.fontRatio_(0.4);
		self[\loaderCloseButton] = GMCloseButton()
		.maxWidth_(96)
		.maxHeight_(96)
		.action_({ self[\loader].visible_(false); });
		self[\loaderSelector] = GMGridButton();

		self[\loader].layout_(
			VLayout()
			.add(
				HLayout()
				.add(self[\loaderTitle], 9)
				.add(self[\loaderCloseButton], 1),
				1
			)
			.add(self[\loaderSelector], 9)
		);
		self[\loader].visible_(false);
	},
	callLoader: { |self, rule, symbol, action, msg|
		var files, states;

		self[\loaderTitle].string_(msg);

		files = self.getFilesFor(rule, symbol);
		states = files.collect({ |i| i[0] });
		self[\loaderSelector]
		.states_(states)
		.action_({ |index|
			action.value(files[index][1], files[index][0]);
			self[\loader].visible_(false);
			files.clear;
		})
		.desindex;

		self[\loader].visible_(true);
	},

	textInput: nil,
	textTitle: nil,
	textCloseButton: nil,
	textField: nil,
	textInputButton: nil,
	initTextInput: { |self|
		self[\textInput] = UserView()
		.background_(Color(0.5, 0.5, 0.5));

		self[\textTitle] = GMTextView()
		.maxHeight_(96)
		.fontRatio_(0.4);
		self[\textCloseButton] = GMCloseButton()
		.maxWidth_(96)
		.maxHeight_(96)
		.action_({ self[\textInput].visible_(false); });
		self[\textField] = TextField()
		.align_(\center);
		self[\textInputButton] = GMButton()
		.string_("Save")
		.maxWidth_(192)
		.maxHeight_(96);

		self[\textInput].layout_(
			VLayout()
			.add(
				HLayout()
				.add(self[\textTitle], 9)
				.add(self[\textCloseButton], 1),
				1
			)
			.add(
				VLayout()
				.add(self[\textField])
				.add(
					HLayout()
					.add(self[\textInputButton])
				),
				9
			)
		);
		self[\textInput].visible_(false);
	},
	callTextInput: { |self, action, msg|
		var files, states;

		self[\textTitle].string_(msg);
		self[\textField]
		.string_("")
		.focus(true);

		self[\textInputButton]
		.action_({
			action.value(self[\textField].string);
			self[\textInput].visible_(false);
		});

		self[\textInput].visible_(true);
	},

	getFilesFor: { |self, rule, symbol|
		var folder, list;

		list = List(0);

		if(rule == \playerState) {
			PathName(
				self[\folder]
				++ "/presets/playerState/"
			).files.do({ |fileName|
				if(fileName.fileName
					.endsWith(".gmdef_playerState")) {
					list.add([
						this.executeFile(fileName.fullPath)[\name],
						fileName.fullPath
					]);
				};
			});
		};

		if(rule == \synth) {
			PathName(self[\folder] ++ "/presets/synth/").files.do({ |fileName|
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
	),

	getIcon: { |self, symbol|
		self[\folder] ++ "/assets/icons/" ++ self[\icons][symbol]
	},

	invokeGrid: { |self, grid|
		var window = self.getMainWindow;
		var player = self.getPlayer;
		window.setPlayer(player);
		window.setAsMonoGrid(grid);
		window.doFront;
		CmdPeriod.doOnce({ window.doClose; });
	},
	
	invokeGridBKP: { |self, grid|
		var win = Window("",
			Rect(
				Window.screenBounds.width * 0.1,
				Window.screenBounds.height * 0.1,
				Window.screenBounds.width * 0.8,
				Window.screenBounds.height * 0.8
			);
		)
		.acceptsMouseOver_(true);
		var overlayLayout = StackLayout()
		.mode_(\stackAll);
		var stackLayout = StackLayout();
		var mainView = UserView()
		.acceptsMouseOver_(true);
		var menuStates = List(0).add("Player");
		var synthLists = List(0);
		var synthNames = List(0);
		var synthIndices = List(0);
		var player = self.getPlayer;
		var view = self.getSynthView;
		var currentRack = 0;
		var leftMenu = GMMultiButton()
		.fontRatio_(0.1)
		.maxWidth_(64)
		.orientation_(\vertical)
		.direction_(\top)
		.action_({ |index|
			synthIndices[currentRack] = index;
			view.setSynth(
				synthLists[currentRack][index]
			);
		});
		var topMenu = GMMultiButton()
		.maxHeight_(96)
		.action_({ |index|
			if(index == 0) {
				stackLayout.index_(0);
			} {
				currentRack = index - 1;
				view.setSynth(
					synthLists[currentRack]
					[synthIndices[currentRack]]
				);
				leftMenu.states_(synthNames[currentRack]);
				leftMenu.state_(synthIndices[currentRack]);
				stackLayout.index_(1);
			};
		});

		view.setPlayer(player);

		grid.do({ |row, rowIndex|
			menuStates.add(row[0]);
			synthLists.add(List(0));
			synthNames.add(List(0));
			synthIndices.add(0);
			(row.size - 1).do({ |index|
				var synth = ~gmDef.getSynth(row[index + 1]);
				synth.setPlayer(player);
				view.connectSynth(synth);
				synthLists[rowIndex].add(synth);
				synthNames[rowIndex].add(synth[\name]);
			});
		});

		topMenu.states_(menuStates);
		stackLayout.add(player[\view]);
		stackLayout.add(
			UserView()
			.acceptsMouseOver_(true)
			.layout_(
				HLayout()
				.margins_(0)
				.spacing_(0)
				.add(leftMenu, 1)
				.add(view[\view], 9)
			);
		);

		mainView.layout_(
			VLayout()
			.margins_(0)
			.spacing_(0)
			.add(topMenu, 1)
			.add(stackLayout, 9)
		);

		overlayLayout
		.add(~gmDef[\loader])
		.add(~gmDef[\textInput])
		.add(mainView);

		win.layout_(overlayLayout);

		CmdPeriod.doOnce({
			self[\synthFreed] = true;
			win.close;
		});

		win.front;
	},

	init: { |self|
		self[\folder] = thisProcess.nowExecutingPath.dirname;

		// Load synth datas
		PathName(self[\folder] ++ "/GMDefs/").files.do({ |fileName|
			var synthData = this.executeFile(fileName.fullPath);
			self[\gmDefs][synthData[\name].asSymbol] = synthData;
		});
		self.initLoader;
		self.initTextInput;

		self[\defaultProperties][\style] = GMStyle();
		self[\defaultProperties][\textStyle] =
		self[\defaultProperties][\style]
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
			++ "/protos/synthParent.scd");
		self[\continuousSynthParent] =
		this.executeFile(self[\folder]
			++ "/protos/continuousSynthParent.scd");
		self[\discreteSynthParent] =
		this.executeFile(self[\folder]
			++ "/protos/discreteSynthParent.scd");
		self[\effectSynthParent] =
		this.executeFile(self[\folder]
			++ "/protos/effectSynthParent.scd");
		self[\inputSynthParent] =
		this.executeFile(self[\folder]
			++ "/protos/inputSynthParent.scd");
		self[\getSynth] =
		this.executeFile(self[\folder]
			++ "/protos/getSynth.scd");

		self[\masterParent] =
		this.executeFile(self[\folder]
			++ "/protos/masterParent.scd");
		self[\getMaster] =
		this.executeFile(self[\folder]
			++ "/protos/getMaster.scd");

		// Main Window
		self[\mainWindowParent] =
		this.executeFile(self[\folder]
			++ "/protos/mainWindowParent.scd");
		self[\getMainWindow] =
		this.executeFile(self[\folder]
			++ "/protos/getMainWindow.scd");
		
		// Player
		self[\getPlayer] =
		this.executeFile(self[\folder]
			++ "/protos/player.scd");

		// Synth interfaces
		// Main interface
		self[\synthViewParent] =
		this.executeFile(self[\folder]
			++ "/protos/synthViewParent.scd");
		self[\getSynthView] =
		this.executeFile(self[\folder]
			++ "/protos/getSynthView.scd");

		// Sequencer
		self[\sequencerViewParent] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/sequencerViewParent.scd");
		self[\getSequencerView] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/getSequencerView.scd");
		// Piano Roll
		self[\pianoRollViewParent] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/pianoRollViewParent.scd");
		self[\getPianoRollView] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/getPianoRollView.scd");
		// Param Manager
		self[\paramManagerParent] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/paramManagerParent.scd");
		self[\getParamManager] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/getParamManager.scd");
		// Out View
		self[\outViewParent] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/outViewParent.scd");
		self[\getOutView] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/getOutView.scd");

		// Param Parent
		self[\paramViewParent] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/paramViewParent.scd");
		// Continuous Param
		self[\continuousViewParent] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/continuousViewParent.scd");
		self[\getContinuousView] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/getContinuousView.scd");
		// Selector Param
		self[\selectorViewParent] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/selectorViewParent.scd");
		self[\getSelectorView] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/getSelectorView.scd");
		// Env Param
		self[\envViewParent] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/envViewParent.scd");
		self[\getEnvView] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/getEnvView.scd");
		// 2D Slider Param
		self[\slider2ViewParent] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/slider2ViewParent.scd");
		self[\getSlider2View] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/getSlider2View.scd");
		// Input Selector
		self[\inputViewParent] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/inputViewParent.scd");
		self[\getInputView] =
		this.executeFile(self[\folder]
			++ "/protos/synthComponents/getInputView.scd");

		// Prevents re-trying to free synths on CmdPeriod
		CmdPeriod.doOnce({ self[\synthFreed] = true; });
	},
);

~gmDef.init;
)