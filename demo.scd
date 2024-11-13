// Welcome to the ModHa demo file !
// To evaluate some code (in SCIDE), place your cursor
// on the line, or within the ( block ),
// and hit ctrl + enter.

// You can find more documentation on GitHub:
// https://github.com/SimonDeplat/ModHa/wiki

////////////////////////
//    Installation    //
////////////////////////
// If you've just downloaded the project, here's
// how to install dependencies:

// First, if your SuperCollider installation is a bit old,
// you might want to update your Quarks repository.
// Open the Quarks GUI and hit the "Check for updates" button:
Quarks.gui;

// Install the GUI library (and recompile class library afterwards):
(
Quarks.install("GraphicalModule");
thisProcess.recompile;
)

// Here's how to update the GUI library:
(
Quarks.update("GraphicalModule");
thisProcess.recompile;
)

/////////////////
//    Usage    //
/////////////////
// See https://github.com/SimonDeplat/ModHa/wiki/Usage
// for an illustrated documentation of those commands

// First of all, SuperCollider's server needs to be running:
s.boot;

// When starting SC, you need to evaluate the 'gmDefDecoder.scd'
// once to load the software:
(
this.executeFile(
	thisProcess.nowExecutingPath.dirname
	+/+ "gmDefDecoder.scd");
)

// This will make ModHa's functionalities available
// through a global variable, ~gmDef,
// which responds to certain commands:

// Evaluate this to get a list of available synths,
// sorted by type:
~gmDef.dumpSynthsByType;

// Create a window with a single instrument
// (and its player):
~gmDef.invokeSingleView(\Luce);

// Create a window with a player,
// which allows to create/remove instrument pop-up windows:
~gmDef.invokeInvoker;

// Create a window with a player,
// which allows to construct your own orchestra
~gmDef.invokeOrchestra;