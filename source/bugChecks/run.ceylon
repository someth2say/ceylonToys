"Run the module `bugChecks`."
shared void run() {
}

shared class Super() {
	shared alias SupAlias => Integer?;
	shared class Sub(shared SupAlias supAlias, shared SubAlias symbol) {
		shared alias SubAlias => Character?;
	}
}

