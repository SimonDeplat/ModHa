(
// File execution shortcut
~mh.exe = { |self, path|
	this.executeFile(path.standardizePath);
};

~mh[\function] = (

	stringToSymbol: { |self, string|
		string = string.replace(" ", "_");
		string = string.asSymbol;
		string
	},
	
);
)