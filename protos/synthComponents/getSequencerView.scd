({ |decoder|
	var self = (
		view: UserView(),
		sequencer: GMDuoSequencer()
		.actionMode_(\index),
	);

	self.parent_(decoder[\sequencerViewParent]);

	self[\view].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\sequencer])
	);

	self
})