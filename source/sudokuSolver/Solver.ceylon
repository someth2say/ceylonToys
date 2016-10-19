import java.util {
    Random
}

abstract shared class Solver<GameT>()
    given GameT satisfies Game<GameType, BoardType, CellType>
{
    alias GameType => GameT;
    shared alias RuleType => GameType.GameRule;
    shared alias CellType => GameType.CellType;
    shared alias BoardType => GameType.BoardType;

    formal shared {CellType*}? step(BoardType sudoku, Set<RuleType> gamePlayRules);
    formal shared Boolean rollback(BoardType sudoku);

    shared default Boolean solve(BoardType sudoku, Set<RuleType> gamePlayRules, Set<RuleType> gameOverRules) {
        if (!sudoku.checkRules(gamePlayRules)) {
            return false;
        }
        while (!sudoku.checkRules(gameOverRules)) {
            if (!step(sudoku, gamePlayRules) exists) {
                if (!rollback(sudoku)) {
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
shared class RandomSolver() extends Solver<Sudoku>() {

    function addSymbolToCell(BoardType sudoku, CellType cell, Set<RuleType> gamePlayRules) {
        for (CellType.Symbol symbol in sudoku.allowedSymbols) {
            cell.symbol = symbol;
            if (sudoku.checkRulesOnCells(cell, gamePlayRules)) {
                return symbol;
            }
        }
        // No symbol can be used
        cell.clear();
        return null;
    }

    shared actual default {CellType*}? step(BoardType sudoku, Set<RuleType> gamePlayRules) {
        // First, pick a ramdom empty cell.
        CellType? randomCell = getRandomEmptyCell(sudoku);
        if (exists randomCell) {
            // Try available symbols, in order.
            CellType.Symbol usedSymbol = addSymbolToCell(sudoku, randomCell, gamePlayRules);
            if (exists usedSymbol) {
                return [randomCell];
            }
        }
        // If no symbol can be used, or unable to find an empty cell, sudoku can not be resolved
        return null;
    }

    CellType? getRandomEmptyCell(BoardType sudoku) {
        {CellType*} emptyCells = sudoku.cells.filter((CellType cell) => (!cell.symbol exists));
        if (emptyCells.empty) {
            return null;
        } else {
            value index = (Random().nextLong()).magnitude % (emptyCells.size);
            CellType? cell = emptyCells.getFromFirst(index);
            return cell;
        }
    }

    shared actual Boolean rollback(BoardType sudoku) {
        sudoku.reset();
        return true;
    }

    shared Boolean defaultSolve(BoardType sudoku) => super.solve(sudoku, sudoku.defaultGamePlayRules, sudoku.defaultGameOverRules);
}

/*
"A bit more advanced solver, that keeps track what has been already tried, so not repeating steps"
shared class OtherSolver() extends RandomSolver(){
	
	{SudokuCell*} emptyCells(SudokuBoard sudoku) => sudoku.cells.filter((SudokuCell element) => !element.symbol exists);
	
	shared {SudokuCell.Symbol*} availableSymbols(SudokuCell cell, SudokuBoard sudoku, Set<SudokuRule> gamePlayRules) => {
		//TODO
		
		
		
	};
	
	shared actual {SudokuCell*}? step(SudokuBoard sudoku, Set<SudokuRule> gamePlayRules) {
		
		alias SymbolsAndCell => [{Character*},SudokuCell];
		// If there is a cell (or many) with a single valid symbol, then use it.
		{SymbolsAndCell*} potentialSymbolAndCells = emptyCells(sudoku)
				.map((SudokuCell cell) => [availableSymbols(cell, sudoku, gamePlayRules),cell])
				.sort(byIncreasing((SymbolsAndCell e) => e.first.size));
		value directValueCells = potentialSymbolAndCells.filter((SymbolsAndCell sac) => sac.first.size==1);
		if (directValueCells.size>0){
			// Found some cells with a single valid symbol
			directValueCells.each(([syms, cell])=>cell.symbol=syms.first);
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
}*/

