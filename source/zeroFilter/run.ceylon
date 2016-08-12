"Run the module `zeroFilter`."
shared void run() {
	{Integer*} input = { 2, 0, 4, -3, 0, 0, 0, 3, 0, 0, 2, 0, 0, 0, 0 };
	//{Integer*} input = { 0, 1, 0, 2, 0 };
	variable Integer? prev0 = null;
	variable Integer? prev1 = null;
	value output = input.map<Integer?>((Integer current) {
			Integer? result;
			if (exists Integer prv0 = prev0, exists Integer prv1 = prev1) {
				if ((current != 0) || ((prv0 != 0) || (prv1 != 0))) {
					result = prev1;
				} else {
					//skip
					result = null;
				}
			} else {
				//first ones are to be kept..unless double zero
				result = if (exists prv1=prev1 , prv1!=0) then prv1 else null;
			}
			
			// move one step fwd.
			prev0 = prev1;
			prev1 = current;
			
			return result;
		}
	);
	//last ones are to be kept..unless double zero

	if (exists Integer prv0 = prev0, prv0 == 0, exists Integer prv1 = prev1, prv1 == 0) {
		//remove tail
		print(output.exceptLast.coalesced);
	} else {
		print(output.coalesced);
	}
}
