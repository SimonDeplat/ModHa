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
		// Load prototypes
		this.executeFile(
			self[\folder]
			+/+ "Logic"
			+/+ "loadConstructors.scd"
		);
		// Host or remote
		if(host) {
			// Load action manager
			self[\am] = this.executeFile(
				self[\folder]
				+/+ "Logic"
				+/+ "actionManager.scd"
			);
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
		// GUI
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

	players: (),
	sortedPlayers: List(0),
	registerPlayer: { |self, player|
		self[\players][player[\id]] = player;
		self[\sortedPlayers].add(player);
	},

	networkIsOpen: true,

	setAsRemote: { |self|
		// Load remote action manager
		self[\am] = this.executeFile(
			self[\folder]
			+/+ "Logic"
			+/+ "remoteActionManager.scd"
		);
		self[\am].init;
	},

	//---------//
	// METHODS //
	cmd: { |self, cmd, args = nil, playerID = nil, time = nil|
		if(self[\am].notNil) {
			self[\am].cmd(
				cmd,
				args,
				playerID,
				time
			);
		};
	},

	quit: { |self|
		~mh = nil;
		self.clear;
	},

	//------------------//
	// GLOBAL FUNCTIONS //
	uidCounter: 0,
	getUID: { |self|
		var uid = Date.getDate.dayStamp;
		uid = uid ++ Date.getDate.hourStamp;
		uid = uid.replace( ":", "" );
		uid = uid.replace( ".", "" );
		uid = uid ++ self[\uidCounter].asString;
		self[\uidCounter] = self[\uidCounter] + 1;
		uid = $$ ++ uid;
		uid = uid.asSymbol;
		uid
	},
);

~mh.preInit;
)