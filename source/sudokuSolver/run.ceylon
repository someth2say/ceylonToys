import ceylon.test {
	fail
}

"Run the module `sudokuSolver`."
shared void run() {
	value sudoku = Sudoku(4, 2, ['0','1','2','3']);
	print("Cells: (``sudoku.cells.size``)  ``sudoku``");
	assert(sudoku.cells.size == 16);
	print("Hipercubes: (``sudoku.hipercubes.size``)   ``sudoku.hipercubes``");
	assert(sudoku.hipercubes.size == 4);
	print("Slices: (``sudoku.slices.size``)  ``sudoku.slices``");
	assert(sudoku.slices.size == 8);
	
	"Empty sudoku does not satisfy default rules." 
	assert (checkRules(sudoku, defaultGameOverRules)==false);
	print("Empty sudoku does not satify default gameover rules");
	assert (checkRules(sudoku,defaultGamePlayRules));
	print("But it does satify default gameplay rules");
	/*
	 This 2D sudoku do satisfies basic rules:
	 0 1 2 3
	 2 3 0 1
	 1 0 3 2
	 3 2 1 0
	 */
	sudoku.setSymbolAt([0,0], '0');
	sudoku.setSymbolAt([0,1], '1');
	sudoku.setSymbolAt([0,2], '2');
	sudoku.setSymbolAt([0,3], '3');
	sudoku.setSymbolAt([1,0], '2');
	sudoku.setSymbolAt([1,1], '3');
	sudoku.setSymbolAt([1,2], '0');
	sudoku.setSymbolAt([1,3], '1');
	sudoku.setSymbolAt([2,0], '1');
	sudoku.setSymbolAt([2,1], '0');
	assert (checkRules(sudoku, defaultGameOverRules)==false);
	print("Partial sudoku does not satify default gameover rules");
	assert (checkRules(sudoku,defaultGamePlayRules));
	print("But it does satify default gameplay rules");

	sudoku.setSymbolAt([2,2], '3');
	sudoku.setSymbolAt([2,3], '2');
	sudoku.setSymbolAt([3,0], '3');
	sudoku.setSymbolAt([3,1], '2');
	sudoku.setSymbolAt([3,2], '1');
	sudoku.setSymbolAt([3,3], '0');
	assert (checkRules(sudoku, defaultGameOverRules)==true);
	print("Default gameover rules satisfied. Sudoku resolved");
	
	try {
		sudoku.setSymbolAt([3,3], 'A');
		fail("Symbols 'A' should not be allowed.");
	} catch (AssertionError e) {
		
	}
	
	
	value easy2d = Sudoku(4, 2, ['A','B','C','D']);
	RandomSolver().solve(easy2d);
	print("Solved easy 2D sudoku: ``easy2d``");

	value default2d = Sudoku();
	RandomSolver().solve(default2d);
	print("Solved default 2D sudoku: ``default2d``");

	value sudoku3d = Sudoku(4, 3, ['1','2','3','4','5','6','7','8','9','0','A','B','C','D','E','F']);
	RandomSolver().solve(sudoku3d);
	print("Solved 3D sudoku: ``sudoku3d``");

}




