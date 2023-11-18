(
var getDiscreteInstr;
var protoDiscreteInstr;

protoDiscreteInstr = (

	// Score manipulation
	// General score manipulation
	fillDefaultOsc: { |self|
		self[\data][\params].do({ |param|
			self[\defaultOsc].put(
				param[\symbol],
				param[\default]
			);
		});
	},

	getDefaultOsc: { |self|
		self[\defaultOsc]
	},

	newEmptyScore: { |self, scoreLength|
		self[\oscScore].clear;
		self[\oscScore] = List(0);
		scoreLength.do({
			self[\oscScore].add(
				self[\defaultOsc].deepCopy;
			);
		});
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

	// Param manipulation
	setParamAt: { |self, time, param,  value|
		if(self.getDefaultOsc.includesKey(param)) {
			if(time < self.getOscScore.size) {
				// -1 sets param for every time
				if(time == -1) {
					self.getOscScore.size.do({ |time|
						self.setParamAt(time, param, value);
					});
				} {
					// FIX ME : should detect incorrect values
					// but this would need an algo for both
					// continuous and discrete values
					// FIX ME : Shoud also update conductor's score
					// if the modification is concerning current
					// osc message
					self[\oscScore][time][param] = value;
				};
			} {
				"Instrument : specified time is outside of score bounds".warn;
			};
		} {
			var warning = "Instrument : ";
			warning = warning ++ param.asString;
			warning = warning ++ " is not a valid parameter";
			warning.warn;
		};
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