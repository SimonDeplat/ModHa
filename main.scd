(
// Our main dictionary,
// everything is accessed using ~mh[\something]
~mh = ();

// File path referencements
// ModHa root folder
~mh[\folderPath] = thisProcess.nowExecutingPath.dirname ++ "/";

// A shortcut to execute this file globally
~mh.exe = {
	this.executeFile((
		~mh[\folderPath]
		++ "main.scd").standardizePath);
};

"Hello World".postln;
)