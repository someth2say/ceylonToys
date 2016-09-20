import java.util {
	Random
}

import ceylon.math {
	...
}

abstract shared class Solver() {
	formal shared void solve(Sudoku sudoku, Set<SudokuRule> gamePlayRules = defaultGamePlayRules, Set<SudokuRule> gameOverRules = defaultGameOverRules);
}

"Basic sudoku solver.
 Just drops numbers at places in order, and checks if rules are satisfied. 
 If no available places, just clear the sudoku and starts again."
shared class RandomSolver() extends Solver() {
	function addSymbolToCell(Sudoku sudoku, Sudoku.Cell cell, Set<SudokuRule> gamePlayRules) {
		
		for (Sudoku.Cell.Symbol symbol in sudoku.symbols) {
			cell.symbol = symbol;
			if (checkRules(sudoku, gamePlayRules)) {
				return symbol;
			} 
		} 
		// No symbol can be used
		cell.clear();
		return null;
	}
	
	shared actual void solve(Sudoku sudoku, Set<SudokuRule> gamePlayRules, Set<SudokuRule> gameOverRules) {
		while (!checkRules(sudoku, gameOverRules)) {
			// First, pick a ramdom empty cell.
			Sudoku.Cell? randomCell = getRandomEmptyCell(sudoku);
			if (randomCell exists) {
				assert (exists randomCell);
				// Try available symbols, in order.
				addSymbolToCell(sudoku, randomCell, gamePlayRules);
				if (randomCell.empty()) {
					//print("Can't find a Symbol for ``randomCell``. Restarting.");
					clearAllCells(sudoku);
				}
			} else {
				// If unable to find an empty cell, but rules not satisfied, then restart.
				print("This should never happen! No empty cells, but rules not satisfied!");
				print(sudoku.string);
				clearAllCells(sudoku);
			}
		}
	}
	
	Sudoku.Cell? getRandomEmptyCell(Sudoku sudoku) {
		{Sudoku.Cell*} emptyCells = sudoku.cells.filter((Sudoku.Cell cell) => (!cell.symbol exists));
		if (emptyCells.empty) {
			return null;
		} else {
			value index = (Random().nextLong()).magnitude % (emptyCells.size );
			Sudoku.Cell? cell = emptyCells.getFromFirst(index);
			return cell;
		}
	}
	
	shared void clearAllCells(Sudoku sudoku) {
		sudoku.cells.each((Sudoku.Cell cell) => cell.symbol = null);
	}
}
