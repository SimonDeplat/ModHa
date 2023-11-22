(
// File execution shortcut
~mh.exe = { |self, path|
	this.executeFile(path.standardizePath);
};

~mh.preproc = { |self|
	this.preProcessor = { |code|
		code.replace("i<", "~mh[\orchestra].instr");
		code.replace("o<", "~mh[\orchestra].");
		code.replace("c<", "~mh[\conductor].");
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