(
~mh = (
	//------//
	// INIT //
	preInit: { |self|
		// Reference main folder
		self[\folder] =
		thisProcess.nowExecutingPath.dirname.dirname;
	},

	init: { |self, host = true, loadGUI = true|
		if(~mh[\verbose]) {
			"ModHa init starting".postln;
		};
		// 1) Load GMDefs
		self.loadGMDefs;
		// 2) Load prototypes
		this.executeFile(
			self[\folder]
			+/+ "Logic"
			+/+ "loadConstructors.scd"
		);
		// 3) Network - Host or Remote
		if(host) {
			// Load action manager
			self[\am] = this.executeFile(
				self[\folder]
				+/+ "Logic"
				+/+ "actionManager.scd"
			);
			self[\am].defineReferenceTime;
			// Auto-open network
			if(self[\networkIsOpen]) {
				self[\am].openNetwork;
			};
			if(~mh[\verbose]) {
				"Host setup".postln;
			};
		} {
			// Remote client
			self.setAsRemote;
			if(~mh[\verbose]) {
				"Remote setup".postln;
			};
		};
		// 4) GUI
		if(loadGUI) {
			this.executeFile(
				self[\folder]
				+/+ "GUI"
				+/+ "main.scd"
			);
			if(~mh[\verbose]) {
				"GUI loaded".postln;
			};
		};
		if(~mh[\verbose]) {
			"Init done".postln;
		};
	},

	//-------//
	// STATE //
	verbose: true,
	server: Server.default,

	// Player //
	players: (),
	sortedPlayers: List(0),
	registerPlayer: { |self, player|
		self[\players][player[\id]] = player;
		self[\sortedPlayers].add(player);
		// Update AM
		if(self[\host]) {
			self[\am].addPlayerTimeChecks(
				player[\id]
			);
		};
		player.addSignal(
			\remove, {
				self[\players].removeAt(player[\id]);
				self[\sortedPlayers].remove(player);
				// Update AM
				if(self[\host]) {
					self[\am].rmPlayerTimeChecks(
						player[\id]
					);
				};
			}
		);
	},
	getLastPlayer: { |self|
		self[\sortedPlayers].last
	},

	// Synths //
	synths: (),

	// Network //
	networkIsOpen: true,

	host: true,
	setAsRemote: { |self|
		// Load remote action manager
		self[\am] = this.executeFile(
			self[\folder]
			+/+ "Logic"
			+/+ "remoteActionManager.scd"
		);
		self[\am].init;
		self[\host] = false;
	},

	//---------//
	// METHODS //
	gmDefs: (),
	loadGMDefs: { |self|
		// Load synth datas
		PathName(self[\folder] ++ "/GMDefs/").files.do({ |fileName|
			var synthData;
			synthData = this.executeFile(fileName.fullPath);
			// Fill \category if nil
			if(synthData.includesKey(\category).not) {
				synthData[\category] = \uncategorized;
			};
			// Allow param access by symbol key
			synthData[\param] = ();
			synthData[\params].do({ |param|
				synthData[\param][param[\symbol]] = param;
			});
			// Reference datas
			self[\gmDefs][synthData[\name].asSymbol] = synthData;
		});
		if(~mh[\verbose]) {
			"GMDefs loaded".postln;
		};
	},

	cmd: { |self, cmd, args = nil|
		self[\am].cmd(
			cmd,
			args
		);
	},

	quit: { |self|
		~mh = nil;
		self.clear;
	},

	//------------------//
	// GLOBAL FUNCTIONS //
	uidCounter: 0,
	getUID: { |self|
		var uid = Date.getDate.format("%d%H%M%S");
		uid = uid ++ self[\uidCounter].asString;
		self[\uidCounter] = self[\uidCounter] + 1;
		uid = $$ ++ uid;
		uid = uid.asSymbol;
		uid
	},

	copyPaste: (),
	doCopy: { |self, symbol, data|
		self[\copyPaste][symbol] = data;
	},
	doPaste: { |self, symbol|
		var data = nil;
		if(self[\copyPaste][symbol].notNil) {
			data = self[\copyPaste][symbol].deepCopy;
		};
		data
	},
);

~mh.preInit;
)