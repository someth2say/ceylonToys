"Run the module `convinationSum`."
shared void run() {
	value num = [1, 2, 3, 4];
	value target = 4;
	
	print(convinations(num, target));
}

shared {[Integer+]*} convinations([Integer+] num, Integer target) {
	[Integer*] rest = num.rest;
	Integer first = num.first;
	{[Integer+]*} convinationsUsingFirst;
	{[Integer+]*} convinationsNotUsingFirst;
	//if can use first
	if (first == target) {
		convinationsUsingFirst = { [first] }.chain(convinations(num, target - first));
	} else if (first < target) {
		//found all convinations using first (if any)
		convinationsUsingFirst = convinations(num, target - first).map(([Integer+] element) => element.withLeading(first));
	} else {
		//can not use first.
		convinationsUsingFirst = {};
	}
	
	//found all convinations NOT using first (if any)
	if (is [Integer+] rest) {
		convinationsNotUsingFirst = convinations(rest, target);
	} else {
		convinationsNotUsingFirst = {};
	}
	
	//return both
	return convinationsUsingFirst.chain(convinationsNotUsingFirst);
}
