import ceylon.test {
	test,
	assertThatException,
	beforeTestRun,
	beforeTest
}
import sudokuSolver {

	defaultGamePlayRules,
	Sudoku,
	RandomSolver,
	checkRules,
	defaultGameOverRules,
	OtherSolver
}

Sudoku unsolvable = Sudoku(4, 2, ['A','B','C','D']);	
Sudoku easy2d = Sudoku(4, 2, ['0','1','2','3']);	
Sudoku easy3d = Sudoku(4, 3, ['A','B','C','D','E','F','G','H']);	
Sudoku default2d = Sudoku();

shared beforeTestRun void init(){

	default2d.setProtectedSymbol([0,0],'6');

	unsolvable.setProtectedSymbol([0,0], 'A');
	unsolvable.setProtectedSymbol([0,1], 'A');

}

shared beforeTest void resetSudokus(){
	unsolvable.reset();
	easy2d.reset();
	easy3d.reset();
	default2d.reset();
}
shared test void allCellsAreGenerated(){
	assert(easy2d.cells.size == 16);
	//TODO: Cell contents
}

shared test void testHipercubes(){
	assert(easy2d.hipercubes.size == 4);
	//TODO: hipercube contents
}

shared test void testSlices(){
	assert(easy2d.slices.size == 8);
	//TODO: slice contents
}

shared test void testDefaultGameOverRules(){
	"Empty sudoku does not satisfy default gameover rules." 
	assert (false==checkRules(easy2d, defaultGameOverRules));
	/*
	 This 2D sudoku do satisfies basic rules:
	 0 1 2 3
	 2 3 0 1
	 1 0 3 2
	 3 2 1 0
	 */
	easy2d.setSymbolAt([0,0], '0');
	easy2d.setSymbolAt([0,1], '1');
	easy2d.setSymbolAt([0,2], '2');
	easy2d.setSymbolAt([0,3], '3');
	easy2d.setSymbolAt([1,0], '2');
	easy2d.setSymbolAt([1,1], '3');
	easy2d.setSymbolAt([1,2], '0');
	easy2d.setSymbolAt([1,3], '1');
	easy2d.setSymbolAt([2,0], '1');
	easy2d.setSymbolAt([2,1], '0');
	assert (false==checkRules(easy2d, defaultGameOverRules));
	easy2d.setSymbolAt([2,2], '3');
	easy2d.setSymbolAt([2,3], '2');
	easy2d.setSymbolAt([3,0], '3');
	easy2d.setSymbolAt([3,1], '2');
	easy2d.setSymbolAt([3,2], '1');
	easy2d.setSymbolAt([3,3], '0');
	assert (checkRules(easy2d, defaultGameOverRules));
}

shared test void testDefaultGamePlayRules(){
	"Empty sudoku does satify default gameplay rules"
	assert (checkRules(easy2d,defaultGamePlayRules));
	
	/*
	 This 2D sudoku do satisfies basic rules:
	 0 1 2 3
	 2 3 0 1
	 1 0 3 2
	 3 2 1 0
	 */
	easy2d.setSymbolAt([0,0], '0');
	easy2d.setSymbolAt([0,1], '1');
	easy2d.setSymbolAt([0,2], '2');
	easy2d.setSymbolAt([0,3], '3');
	easy2d.setSymbolAt([1,0], '2');
	easy2d.setSymbolAt([1,1], '3');
	easy2d.setSymbolAt([1,2], '0');
	easy2d.setSymbolAt([1,3], '1');
	easy2d.setSymbolAt([2,0], '1');
	easy2d.setSymbolAt([2,1], '0');
	assert (checkRules(easy2d,defaultGamePlayRules));
	easy2d.setSymbolAt([2,2], '3');
	easy2d.setSymbolAt([2,3], '2');
	easy2d.setSymbolAt([3,0], '3');
	easy2d.setSymbolAt([3,1], '2');
	easy2d.setSymbolAt([3,2], '1');
	easy2d.setSymbolAt([3,3], '0');
	assert (checkRules(easy2d, defaultGamePlayRules));
	
}

shared test void testSymbols(){
	//"Invalid symbol should not be used."
	assertThatException(()=>default2d.setSymbolAt([3,3], 'A'))
			.hasType(`AssertionError`);
	
	value sudokuWeird = Sudoku(4,2,['W','X','Y','Z']);
	assertThatException(()=>sudokuWeird.setSymbolAt([3,3], '1'))
			.hasType(`AssertionError`);
	
	
}

shared test void testOtherSolver(){
	print("Solving easy sudoku...");
	assert(OtherSolver().solve(easy2d));
	print("Solved easy sudoku...");
	
	print("Solving default sudoku...");
	assert(OtherSolver().solve(default2d));
	print("Solved default sudoku...");
	
}

shared test void testRandomSolver(){
	print("Unsolvable easy sudoku...");
	assert(!RandomSolver().solve(unsolvable ));
	
	print("Solving easy sudoku...");
	assert(RandomSolver().solve(easy2d));
	print("Solved easy sudoku: ``easy2d``");		
	
	print("Solving default sudoku...");
	assert(RandomSolver().solve(default2d));
	print("Solved default sudoku: ``default2d``");
	"Protected cells should not be changed during solution."
	assert(exists cell=default2d.cellAt([0,0]), exists sym=cell.symbol, '6'==sym);

	// RandomSolver is almost unable to solve Sudokus greater than the default one.
	//print("Solving 3D sudoku...");
	//assert(RandomSolver().solve(easy3d));
	//print("Solved easy sudoku: ``easy3d``");		
		
}
