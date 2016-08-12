"Run the module `stringPermutatons`."
shared void run() {
	[String+] input = ["hat", "abc", "Zu6"];	
	assert(exists String([Character+]) con = `String`.defaultConstructor);
	print ([for (str in input) str.permutations.map(con)]);
	
}
