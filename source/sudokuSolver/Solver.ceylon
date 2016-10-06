import java.util {
	Random
}

abstract shared class Solver() {

	formal shared {Sudoku.Cell*}? step(Sudoku sudoku, Set<SudokuRule> gamePlayRules = defaultGamePlayRules);
	formal shared Boolean rollback(Sudoku sudoku);
	
	shared default Boolean solve(Sudoku sudoku, Set<SudokuRule> gamePlayRules = defaultGamePlayRules, Set<SudokuRule> gameOverRules = defaultGameOverRules) {
		if (!checkRules(sudoku, gamePlayRules)){
			return false;
		}
		while (!checkRules(sudoku, gameOverRules)) {
			if (!step(sudoku, gamePlayRules) exists) {
				if (!rollback(sudoku)){
					return false;
				}
			} 
		}
		return true;
	}
}

"Basic sudoku solver.
 Just drops numbers at places in order, and checks if rules are satisfied. 
 If no available places, just clear the sudoku and starts again."
shared class RandomSolver() extends Solver() {
	function addSymbolToCell(Sudoku sudoku, Sudoku.Cell cell, Set<SudokuRule> gamePlayRules) {
		for (Sudoku.Cell.Symbol symbol in sudoku.allowedSymbols) {
			cell.symbol = symbol;
			if (checkRulesOnCells(sudoku, cell, gamePlayRules)) {
				return symbol;
			}
		}
		// No symbol can be used
		cell.clear();
		return null;
	}
	
	shared actual default {Sudoku.Cell*}? step(Sudoku sudoku, Set<SudokuRule> gamePlayRules) {
		// First, pick a ramdom empty cell.
		Sudoku.Cell? randomCell = getRandomEmptyCell(sudoku);
		if (exists randomCell) {
			// Try available symbols, in order.
			value usedSymbol = addSymbolToCell(sudoku, randomCell, gamePlayRules);
			if (exists usedSymbol) {
				return [randomCell];
			} 
		} 
			// If no symbol can be used, or unable to find an empty cell, sudoku can not be resolved
			return null;
	}
	
	Sudoku.Cell? getRandomEmptyCell(Sudoku sudoku) {
		{Sudoku.Cell*} emptyCells = sudoku.cells.filter((Sudoku.Cell cell) => (!cell.symbol exists));
		if (emptyCells.empty) {
			return null;
		} else {
			value index = (Random().nextLong()).magnitude % (emptyCells.size);
			Sudoku.Cell? cell = emptyCells.getFromFirst(index);
			return cell;
		}
	}
	
	shared actual Boolean rollback(Sudoku sudoku) {
		sudoku.reset();
		return true;
	}
}

"A bit more advanced solver, that keeps track what has been already tried, so not repeating steps"
shared class OtherSolver() extends RandomSolver(){
	
	{Sudoku.Cell*} emptyCells(Sudoku sudoku) => sudoku.cells.filter((Sudoku.Cell element) => !element.symbol exists);
	
	shared {Sudoku.Cell.Symbol*} availableSymbols(Sudoku.Cell cell, Sudoku sudoku, Set<SudokuRule> gamePlayRules) => {
		//TODO
		
		
		
	};
	
	shared actual {Sudoku.Cell*}? step(Sudoku sudoku, Set<SudokuRule> gamePlayRules) {
		
		alias SymbolsAndCell => [{Character*},Sudoku.Cell];
		// If there is a cell (or many) with a single valid symbol, then use it.
		{SymbolsAndCell*} potentialSymbolAndCells = emptyCells(sudoku)
				.map((Sudoku.Cell cell) => [availableSymbols(cell, sudoku, gamePlayRules),cell])
				.sort(byIncreasing((SymbolsAndCell e) => e.first.size));
		value directValueCells = potentialSymbolAndCells.filter((SymbolsAndCell sac) => sac.first.size==1);
		if (directValueCells.size>0){
			// Found some cells with a single valid symbol
			directValueCells.each(([syms, cell]) => cell.symbol=syms.first);
			return directValueCells.map(([syms, cell]) => cell);
		} else {
			// At least 2 symbols to try on every empty cell... let's pick first
			SymbolsAndCell? sac = potentialSymbolAndCells.first;
			if (exists sac){
				value [syms, cell] = sac;
				cell.symbol = syms.first;
				return [cell];
			} else {
				// no cells with potential symbols, then fail.
				return null;
			}
		}
	}
}

