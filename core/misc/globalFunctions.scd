(
// File execution shortcut
~mh.exe = { |self, path|
	this.executeFile(path.standardizePath);
};

~mh.preproc = { |self|
	if(this.preProcessor == nil) {
		this.preProcessor = { |code|
			code = code.replace("i<", "~mh[\\orchestra].instr");
			code = code.replace("o<", "~mh[\\orchestra].");
			code = code.replace("c<", "~mh[\\conductor].");
			code
		};
	};
};

~mh[\function] = (

	stringToSymbol: { |self, string|
		string = string.replace(" ", "_");
		string = string.asSymbol;
		string
	},
	
);
)