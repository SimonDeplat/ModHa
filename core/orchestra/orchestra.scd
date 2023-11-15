(
~mh[\orchestra] = (
	// SynthDef manipulation
	instrList: List(0),

	// Methods

	loadInstrList: { |self|
		// Iterate through the synth data folder,
		// which will add SynthDefs,
		// and return the datas,
		// stored in self[\instrList]
		PathName(
			~mh[\folderPath]
			++ "core/synthData/synth/"
		).files.do({ |fileName|
			self[\instrList].add(
				~mh.exe(fileName.fullPath);
			);
		});
	},

	dumpInstrList: { |self|
		self[\instrList].do({ |instrData|
			instrData.postln;
		});
	},
	
	// Private
	// ModHa init function
	mhInit: { |self|
		// Load instr datas
		self.loadInstrList;
		// Return self to prevent
		// variable reassignment
		self
	},
	
).mhInit();
)