({ |decoder|
	var self = (
		view: UserView(),
		string: GMTextView()
		.string_("Plug this synth into :"),
		closeButton: GMCloseButton()
		.action_({
			self[\synthView][\view]
			.layout.index_(0);
		}),
		effectSelector: GMMultiButton()
		.orientation_(\vertical),
		masterSelector: GMMultiButton()
		.orientation_(\vertical),
	);

	var topLayout = HLayout()
	.margins_(0)
	.spacing_(0)
	.add(self[\string], 9)
	.add(self[\closeButton], 1);

	var bottomLayout = HLayout()
	.margins_(0)
	.spacing_(0)
	.add(self[\effectSelector], 1)
	.add(self[\masterSelector], 1);

	self.parent_(decoder[\outViewParent]);

	self[\view].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(topLayout, 1)
		.add(bottomLayout, 9)
	);

	self
})