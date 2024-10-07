({ |decoder|
	var self = (
		view: UserView()
		.acceptsMouseOver_(true),
		stackLayout: UserView(),
		paramView: UserView()
		.acceptsMouseOver_(true)
		.layout_(HLayout()),
		zoomView: UserView()
		.layout_(HLayout()),
		continuousViews: List(0),
		selectorViews: List(0),
		envViews: List(0),
		slider2Views: List(0),
	);

	self.parent_(decoder[\paramManagerParent]);

	self[\stackLayout] = StackLayout();
	self[\stackLayout].add(self[\paramView]);
	self[\stackLayout].add(self[\zoomView]);

	self[\view].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\stackLayout], 1)
	);

	self
})