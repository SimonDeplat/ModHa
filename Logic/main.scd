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
		// Load action manager
		if(host) {
			self[\am] = this.executeFile(
				self[\folder]
				+/+ "Logic"
				+/+ "actionManager.scd"
			);
		};
	},

	//-------//
	// STATE //
	players: (),
	defaultPlayer: nil,
	registerPlayer: { |self, player|
		self[\players][player[\id]] = player;
		// First player is designated as default player
		if(self[\players].size == 1) {
			self[\defaultPlayer] = player;
		};
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