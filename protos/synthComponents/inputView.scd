(
setSynth: { |self, synth|
	self[\synth] = synth;
	self.setChannelNumber(synth[\numInputChannels]);
},

setChannelNumber: { |self, channelN|
	if(channelN == 1) {
		self[\selector].states_(
			Array.fill(
				~gmDef[\server].options.numInputBusChannels,
				{ |i| (i + 1).asString }
			);
		);
		self[\text].string_("Channel:");
	} {
		self[\selector].states_(
			Array.fill(
				~gmDef[\server].options.numInputBusChannels - (channelN - 1),
				{ |i| (i + 1).asString ++ " - " ++ (i + channelN) }
			);
		);
		self[\text].string_("Channels:");
	};
},

init: { |self|
	self[\type] = \inputSelector;
	self[\text] = GMTextView()
	.string_("Channel:")
	.maxHeight_(96)
	.fontRatio_(0.4);
	self[\selector] = GMMultiButton()
	.fontRatio_(0.95)
	.orientation_(\vertical)
	.action_({ |index| self[\synth].setInput(index); });
	self[\view] = UserView()
	.maxWidth_(128)
	.layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\text], 1)
		.add(self[\selector], 9)
	);

	self[\updateChannelIndex] = {
		self[\selector].state_(self[\synth][\input]);
	};
},
)