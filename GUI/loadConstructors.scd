(
// Exploiting polymorphism
// Parent 'class' must have an 'init' function
var getInstance = { |parent|
	var instance = ();
	instance.parent_(~mhi[parent]);
	instance.init;
	instance
};

// Load factorized constructors:
[
	// Widgets
	[\addPlayStopButton, \playStopButton, "Widgets/playStopButton.scd"],
	[\addFreqSlider, \freqSlider, "Widgets/freqSlider.scd"],
	// Abstractions
	[\addFreqView, \freqView, "Abstract/freqView.scd"],
].do({ |array|
	~mhi[array[0]] = {
		~mhi[array[1]] = this.executeFile(
			~mh[\folder]
			+/+ "GUI"
			+/+ array[2]
		);
		~mhi[array[0]] = { getInstance.value(array[1]); };
		getInstance.value(array[1])
	};
});
)