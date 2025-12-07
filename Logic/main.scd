(
~mh = (
	// INIT //
	init: { |self|
		// Reference main folder
		self[\folder] = thisProcess.nowExecutingPath.dirname.dirname;
		// Load prototypes
		this.executeFile(
			self[\folder]
			+/+ "Logic"
			+/+ "loadConstructors.scd"
		);
	},

	// STATE //
	players: (),
	registerPlayer: { |self, player|
		self[\players][player[\id]] = player;
	},

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