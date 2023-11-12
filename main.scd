(
// Our main dictionary,
// everything is accessed using ~mh[\something]
~mh = ();

// File path referencements
// ModHa root folder
~mh[\folderPath] = thisProcess.nowExecutingPath.dirname ++ "/";

// A shortcut to execute this file globally
~mh.launch = {
	this.executeFile((
		~mh[\folderPath]
		++ "main.scd").standardizePath);
};

// Load global functions
this.executeFile((
	~mh[\folderPath]
	++ "core/misc/globalFunctions.scd").standardizePath);

// Load the conductor
~mh.exe(~mh[\folderPath] ++ "core/conductor/conductor.scd");

"Hello World".postln;
)