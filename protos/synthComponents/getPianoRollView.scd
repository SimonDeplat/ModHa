({ |decoder|
	var self = (
		view: UserView(),
		pianoRoll: GMListPianoRoll()
		.actionMode_(\index),
	);

	self.parent_(decoder[\pianoRollViewParent]);

	self[\view].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\pianoRoll])
	);

	self
})