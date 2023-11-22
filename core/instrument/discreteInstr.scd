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
		self[\defaultOsc].put(\out, 0);
		if(self.isTunable) { self[\defaultOsc].put(\freq,440); };
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

	// getScoreAt returns the osc message
	// no matter what
	getScoreAt: { |self, time|
		var msgList = nil;
		if(time < self.getOscScore.size) {
			msgList = self.expandScore(self.getOscScore[time]);
			msgList.do({ |paramDict, index|
				msgList[index] = self.constructOscMsg(paramDict);
			});
		} {
			"Instrument: getScoreAt: specified time is outside of score bounds".warn;
		};
		msgList
	},

	getAudibleScoreAt: { |self, time|
		var msgList = nil;
		if(time < self.getOscScore.size) {
			msgList = self.expandScore(self.getOscScore[time]);
			// Removing inaudible instructions
			msgList = msgList.select({ |msg| self.isMsgAudible(msg) });
			msgList.do({ |paramDict, index|
				msgList[index] = self.constructOscMsg(paramDict);
			});
		} {
			"Instrument: getAudibleScoreAt: specified time is outside of score bounds".warn;
		};
		msgList
	},

	expandScore: { |self, paramDict|
		var list = List(0);
		var maxArraySize = 1;
		paramDict.keysValuesDo({ |key, value|
			if(value.isKindOf(SequenceableCollection)) {
				if(value.size > maxArraySize) {
					maxArraySize = value.size;
				};
			};
		});
		maxArraySize.do({ |index|
			var param = ();
			paramDict.keysValuesDo({ |key, value|
				if(value.isKindOf(SequenceableCollection)) {
					value = value[index%value.size];
				};
				param.put(key, value);
			});
			list.add(param);
		});
		list
	},

	// playScoreAt checks rand. trigger
	// and audibility before returning the osc msg
	// This is not producing sound by itself !
	playScoreAt: { |self, time|
		var oscMsgList = nil;
		// Warp time around score size
		time = time % self.getOscScore.size;
		// Toss a random trigger coin
		if(self.getTriggers[time].coin) {
			oscMsgList = self.getAudibleScoreAt(time);
		};
		oscMsgList
	},

	checkUpdateScore: { |self, time|
		if(~mh[\conductor].isCurrentSub(time))
		{ self.updateScore(time); };
	},

	updateScore: { |self, time|
		~mh[\conductor].updateScore(
			self.getCurrentMsgs,
			self.playScoreAt(time)
		);
	},

	getCurrentMsgs: { |self| self[\currentMsgs] },

	// Private
	constructOscMsg: { |self, paramDict|
		var oscMsg = self.getHeader.deepCopy;
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

	setParamList: { |self, param, list|
		if(self.getDefaultOsc.includesKey(param)) {
			case
			{ self.getOscScore.size == list.size } {
				list.do({ |value, index|
					self.setParamAt(index, param, value);
				});
			}
			{ self.getOscScore.size > list.size } {
				list.do({ |value, index|
					self.setParamAt(index, param, value);
				});
				"Instrument: setParamList: specified list is shorter than score".warn;
			}
			{ self.getOscScore.size == list.size } {
				self.getOscScore.size.do({ |index|
					self.setParamAt(index, param, list[index]);
				});
				"Instrument: setParamList: specified list is longer than score".warn;
			};
		} {
			var warning = "Instrument: setParamList: ";
			warning = warning ++ param.asString;
			warning = warning ++ " is not a valid parameter";
			warning.warn;
		};
	},

	// Most likely to be available, should make user happy (I hope)
	setAmpAt: { |self, time, value| self.setParamAt(time, \amp, value); },
	setAmps: { |self, list| self.setParamList(\amp, list); },
	setFreqAt: { |self, time, value| self.setParamAt(time, \freq, value); },
	setFreqs: { |self, list| self.setParamList(\freq, list); },

	// Triggers
	getTriggers: { |self| self[\triggers] },

	setTriggerAt: { |self, time, value|
		if(time < self.getOscScore.size)
		{ self[\triggers][time] = value; }
		{ "Instrument: setTriggerAt: specified list is longer than score".warn; };
	},

	setTriggers: { |self, list|
		case
		{ self.getOscScore.size == list.size } {
			list.do({ |value, index|
				self.setTriggerAt(index, value);
			});
		}
		{ self.getOscScore.size > list.size } {
			list.do({ |value, index|
				self.setTriggerAt(index, value);
			});
			"Instrument: setTriggers: specified trigger list is shorter than score".warn;
		}
		{ self.getOscScore.size == list.size } {
			self.getOscScore.size.do({ |index|
				self.setTriggerAt(index, list[index]);
			});
			"Instrument: setTriggers: specified trigger list is longer than score".warn;
		};
	},

	// Trigger shortcuts
	muteTriggers: { |self|
		self[\triggers].size.do({ |index|
			self[\triggers][index] = 0; });
	},
	checkTriggers: { |self|
		self[\triggers].size.do({ |index|
			self[\triggers][index] = 1; });
	},
	invertTriggers: { |self|
		self[\triggers].do({ |trigger, index|
			self[\triggers][index] = 0.5 + (0.5 - trigger);
		});
	},

	isMsgAudible: { |self, msg|
		var audible = true;
		// Amp check
		if(msg.includesKey(\amp)) {
			if(msg[\amp] <= 0) {
				audible = false;
			};
		};
		// Freq check
		if(audible) {
			if(msg.includesKey(\freq)) {
				if(msg[\freq] == 0) {
					audible = false;
				};
			};
		};
		audible
	},

	freqNotNil: { |self, freq|
		var boolean = true;
		switch(freq)
		{ 0 } { boolean = false; }
		{ nil } { boolean = false; }
		{ \r } { boolean = false; };
		boolean;
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
		triggers: List(0),
		currentMsgs: List(0),
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
	16.do({ self[\triggers].add(0); });
};

// Return the getDiscreteInstr function
getDiscreteInstr
)