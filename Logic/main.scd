(
~mh = (
	init: { |self|
		// Reference main folder
		self[\folder] = thisProcess.nowExecutingPath.dirname.dirname;
	},
);

~mh.init;
)