(
~mh = (
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
);

~mh.init;
)