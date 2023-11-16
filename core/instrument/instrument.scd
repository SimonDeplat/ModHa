(
// Instruments are composed of 4 structures
// protoInstrument : a general Instrument Class
// instrument : a protoInstrument prototype
// protoDiscreteInstr : a general DiscreteInstrument Class
// discreteInstr : a protoDiscreteInstr prototype
// (same goes for continuousInstr)

var getInstrument;
var protoInstrument;

protoInstrument = (

	init: { |self|
		var instrument;
		self[\name] = self[\data][\name];
		self[\symbol] = self[\data][\synthSymbol];
		if(self[\data][\continuous])
		{ self[\type] = \continuous; }
		{ self[\type] = \discrete; };
		// Not implemented yet
		//if(self[\type] == \continuous)
		//{ instrument = getContinuousInstrument.value(self); }
		//{ instrument = getDiscreteInstrument.value(self); };
	},

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