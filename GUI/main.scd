(
~mhi = (
	//------//
	// INIT //
	init: { |self|
		// Load prototypes
		this.executeFile(
			~mh[\folder]
			+/+ "GUI"
			+/+ "loadConstructors.scd"
		);
	},
);

~mhi.init;
)