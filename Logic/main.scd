(
~mh = (
	//------//
	// INIT //
	init: { |self, host = true|
		// Reference main folder
		self[\folder] =
		thisProcess.nowExecutingPath.dirname.dirname;
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
		} {
			// Remote client
			self.setAsRemote;
		};
	},

	//-------//
	// STATE //
	players: (),
	registerPlayer: { |self, player|
		self[\players][player[\id]] = player;
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

~mh.init;
)