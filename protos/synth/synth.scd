(
setName: { |self, aString| self[\name] = aString; },

// SIGNALS
emitSignal: { |self, symbol|
	if(self[\signals].includesKey(symbol))
	{ self[\signals][symbol].value; };
},

addSignal: { |self, symbol, function|
	if(self[\signals][symbol].isNil)
	{ self[\signals][symbol] = FunctionList(); };
	self[\signals][symbol].addFunc(function);
},

rmSignal: { |self, symbol, function|
	if(self[\signals].includesKey(symbol))
	{ self[\signals][symbol].removeFunc(function); };
},

dumpPairs: { |self|
	"".postln;
	"[".postln;
	(
		"\t"
		++ "\\instrument, \\"
		++ self[\data][\symbol]
		++ ","
	).postln;

	self[\params].keysValuesDo({ |key, value|
		(
			"\t\\"
			++ key
			++ ", "
			++ value
			++ ","
		).postln;
	});

	"]".postln;
	"".postln;
},
)