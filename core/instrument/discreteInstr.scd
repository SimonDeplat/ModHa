(
var getDiscreteInstr;
var protoDiscreteInstr;

protoDiscreteInstr = (
	
	fillDefaultOsc: { |self|
		self[\data][\params].do({ |param|
			self[\defaultOsc].put(
				param[\symbol],
				param[\default]
			);
		});
	},

	newEmptyScore: { |self, scoreLength|
		self[\oscScore].clear;
		self[\oscScore] = List(0);
		scoreLength.do({ self[\oscScore].add(self[\defaultOsc]); });
	},

	getOscScore: { |self| self[\oscScore] },
	getHeader: { |self| self[\oscHeader] },

	getScoreAt: { |self, time|
		var oscMsg = nil;
		if(time < self.getOscScore.size) {
			oscMsg = self.constructOscMsg(
				self.getOscScore[time]);
		} {
			"Instrument : specified time is outside of score bounds".warn;
		};
		oscMsg
	},

	// Private
	constructOscMsg: { |self, paramDict|
		var oscMsg = self.getHeader.deepCopy;
		paramDict.postln;
		oscMsg = oscMsg.asList;
		paramDict.keysValuesDo({ |key, value|
			oscMsg.add(key);
			oscMsg.add(value);
		});
		oscMsg	
	},
	
);

// This function will expand the instrument
getDiscreteInstr = { |self|

	// This IDict is an extension
	var instr = (

		oscHeader: [
			\s_new, self.getSymbol, -1,
			0, ~mh[\orchestra].getDiscreteGroup
		],
		defaultOsc: (),
		oscScore: List(0),
	);

	// Inheritance setup
	self.insertParent(protoDiscreteInstr);
	// Extend self
	instr.keysValuesDo({ |key, value|
		self.put(key, value);
	});
	instr.clear;

	// Init
	// Store default osc arguments
	self.fillDefaultOsc;
	// Init score, default ModHa is 4/4
	self.newEmptyScore(16);
};

// Return the getDiscreteInstr function
getDiscreteInstr
)