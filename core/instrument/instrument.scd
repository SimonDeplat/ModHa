(
// Instruments are composed in
// 4 distinct steps and result in 3 structures :
// ----------
// 1) instrument is created
// 2) it inherits from protoInstrument
// - depending on it's type (discrete here) : 
// 3) it will inherit from protoDiscreteInstr
// (using instrument.insertParent(protoDiscreteInstr)
// 4) instrument is then extended
// discreteInstr.keysValuesDo({ |k, v| instr.put(k, v); });

var getInstrument;
var protoInstrument;

protoInstrument = (

	init: { |self|
		self[\name] = self[\data][\name];
		self[\symbol] = self[\data][\synthSymbol];
		if(self[\data][\continuous])
		{ self[\type] = \continuous; }
		{ self[\type] = \discrete; };
		// Not implemented yet
		//if(self[\type] == \continuous)
		//{ instrument = getContinuousInstrument.value(self); }
		self.getDiscreteInstr;
	},

	// Getters
	getName: { |self| self[\name] },
	getUniqueName: { |self| self[\uniqueName] },
	getSymbol: { |self| self[\symbol] },
	getType: { |self| self[\type] },
	getData: { |self| self[\data] },

	getDiscreteInstr: ~mh.exe(~mh[\folderPath]
		++ "core/instrument/discreteInstr.scd"),

);

// getInstrument takes self as arg
// because it is connected directly
// to ~mh[\orchestra].getInstr(instrData)
getInstrument = { |self, instrData|
	var instrument = (
		name: nil,
		uniqueName: nil,
		symbol: nil,
		type: nil,
		data: instrData,
	).proto_(protoInstrument);
	// Init
	instrument.init;
	// Return the instrument
	instrument
};

// Return the getInstrument function
getInstrument
)