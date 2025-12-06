(
// Exploiting polymorphism
// Parent 'class' must have an 'init' function
var getInstance = { |parent|
	var instance = ();
	instance.parent_(~mh[parent]);
	instance.init;
	instance
};

// Load factorized constructors:
[

].do({ |array|
	~mh[array[0]] = {
		~mh[array[1]] = this.executeFile(
			~mh[\folder]
			+/+ "Logic"
			+/+ array[2]
		);
		~mh[array[0]] = { getInstance.value(array[1]); };
		getInstance.value(array[1])
	};
});
)