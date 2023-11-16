(
~mh[\orchestra] = (
	// SynthDef manipulation
	instrDatas: List(0),

	// Methods

	loadInstrDatas: { |self|
		// Iterate through the synth data folder,
		// which will add SynthDefs,
		// and return the datas,
		// stored in self[\instrDatas]
		PathName(
			~mh[\folderPath]
			++ "core/synthData/synth/"
		).files.do({ |fileName|
			self[\instrDatas].add(
				~mh.exe(fileName.fullPath);
			);
		});
	},

	dumpInstrDatas: { |self|
		self[\instrList].do({ |instrData|
			instrData.postln;
		});
	},
	
	// Private
	// ModHa init function
	mhInit: { |self|
		// Load instr datas
		self.loadInstrDatas;
		// Return self to prevent
		// variable reassignment
		self
	},
	
).mhInit();
)