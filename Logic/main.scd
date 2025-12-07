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
				self.openNetwork;
			};
		};
	},

	//-------//
	// STATE //
	players: (),
	registerPlayer: { |self, player|
		self[\players][player[\id]] = player;
	},

	networkIsOpen: true,
	openNetwork: { |self|
		var oscReceiver = OSCFunc.newMatching(
			{ |msg, time, addr, port|
				// Check if not connected yet
				var match = false;
				self[\remoteClients].do({ |netAddr|
					if(netAddr.localIP == addr.localIP) {
						match = true;
					};
				});
				if(match.not) {
					self[\remoteClients].add(addr);
				};
			},
			"/mhConnect"
		);
		self[\networkIsOpen] = true;
	},
	remoteClients: List(0),

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