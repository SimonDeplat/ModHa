(
/*
This prototype shares keys (i.e. methods/variables) with other protos,
making use of polymorphism, to centralize synth connection utilities:

- effect
- effectChain
- scope
- dispatcher

Shared keys:
- type
- setOut (except for effect)
- bus
- name
*/

type: \master,

setOut: { |self, out|
	// Need to sync server
	// or self[\synth] might be nil
	// because it is still initializing
	if(~gmDef[\server].serverRunning) {
		fork {
			s.sync;
			if(self[\synth].notNil) {
				self[\synth].set(\out, out);
			};
		};
	};
},

setGroup: { |self, group|
	// Need to sync server
	// or self[\synth] might be nil
	// because it is still initializing
	if(~gmDef[\server].serverRunning) {
		fork {
			s.sync;
			if(self[\synth].notNil) {
				self[\synth].moveToTail(group);
			};
		};
	};
},

doRemove: { |self|
	if(~gmDef[\synthFreed].not
		and: { self[\synth].notNil })
	{ self[\synth].free; };
	self[\bus].free;
	self.clear;
},

init: { |self|
	self[\bus] = Bus.audio(
		~gmDef[\server],
		2
	);

	if(~gmDef[\server].serverRunning) {
		fork {
			s.sync;
			self[\synth] = Synth(
				\mhMaster,
				[\inBus, self[\bus]],
				~gmDef[\server].defaultGroupID,
				\addToTail
			);
		};
	};
},
)