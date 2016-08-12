"Run the module `factorial`."
shared void run() {
    print (firstFactorial(4));
    print (firstFactorial(8));
}

Integer firstFactorial(Integer num) {
	return {for (Integer x in num..1) x}.fold(1)((Integer a, Integer b) => a*b);
}