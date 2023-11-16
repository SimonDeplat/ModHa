(
~mh[\orchestra] = (
	// SynthDef manipulation
	instrDatas: (),

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
			var data = ~mh.exe(fileName.fullPath);
			var nameAsSymbol = ~mh[\function].stringToSymbol(
				data[\name]);
			self[\instrDatas].put(
				nameAsSymbol,
				data
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