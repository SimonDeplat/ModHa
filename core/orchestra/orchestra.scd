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

	dumpInstrData: { |self, instrName|
		instrName = ~mh[\function].stringToSymbol(instrName);
		if(self[\instrDatas].includesKey(instrName)) {
			var data = self[\instrDatas][instrName];
			// Not iterating because keys
			// are unordered
			"Name: ".post;
			data[\name].postln;
			"Category: ".post;
			data[\category].postln;
			"Symbol: ".post;
			data[\synthSymbol].postln;
			"Continuous: ".post;
			data[\continuous].postln;
			"Tunable: ".post;
			data[\tunable].postln;
			"Has env: ".post;
			data[\hasEnv].postln;
			"Env size: ".post;
			data[\envSize].postln;
			// FIX ME : nice post formatting
			"".postln;
			"Params: ".postln;
			data[\params].do({ |dict|
				dict.keysValuesDo({ |key, value|
					key.post;
					": ".post;
					value.postln;
				});
				"".postln;
			});
		} {
			"Orchestra : instrument data not found".warn;
		};
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