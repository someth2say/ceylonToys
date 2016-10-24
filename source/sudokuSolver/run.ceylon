shared void run() {
	Sudoku default2d = Sudoku();
	default2d.board.setProtectedSymbolAt([0,0],'6');
	print(default2d);

	SudokuRandomSolver().solve(default2d);
	print(default2d);
}