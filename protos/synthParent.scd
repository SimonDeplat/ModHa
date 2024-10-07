(
setName: { |self, aString| self[\name] = aString; },

notifyUI: { |self, symbol|
	if(self[\ui].includesKey(symbol))
	{ self[\ui][symbol].value; };
},

addUINotification: { |self, symbol, function|
	if(self[\ui][symbol].isNil)
	{ self[\ui][symbol] = FunctionList(); };
	self[\ui][symbol].addFunc(function);
},

rmUINotification: { |self, symbol, function|
	if(self[\ui].includesKey(symbol)) {
		self[\ui][symbol].removeFunc(function);
	};
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