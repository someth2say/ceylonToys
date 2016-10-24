import java.util {
    Random
}

abstract shared class GameSolver()
{
    /*shared alias RuleType => Game.GameRule;
    shared alias CellType => GameType.CellType;
    shared alias BoardType => GameType.BoardType;
*/

}

shared abstract class BoardGameSolver<GameT, BoardT, CellT>() extends GameSolver()
    given CellT satisfies Cell
    given BoardT satisfies Board<CellT>
    given GameT satisfies BoardGame<BoardT, CellT> {


    formal shared {CellT*}? step(GameT game);
    formal shared Boolean rollback(GameT game);

    shared default Boolean solve(GameT game) {
        if (!game.checkGamePlayRules()) {
            return false;
        }
        while (!game.checkGameOverRules()) {
            if (!step(game) exists) {
                if (!rollback(game)) {
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
shared class SudokuRandomSolver() extends BoardGameSolver<Sudoku, SudokuBoard, SudokuCell>() {

    function addSymbolToCell(Sudoku sudoku, SudokuCell cell) {
        for (SudokuCell.Symbol symbol in sudoku.allowedSymbols) {
            cell.symbol = symbol;
            if (sudoku.checkGamePlayRulesOnCell(cell)) {
                return symbol;
            }
        }
        // No symbol can be used
        cell.clear();
        return null;
    }

    shared actual default {SudokuCell*}? step(Sudoku sudoku) {
        // First, pick a ramdom empty cell.
        SudokuCell? randomCell = getRandomEmptyCell(sudoku);
        if (exists randomCell) {
            // Try available symbols, in order.
            value usedSymbol = addSymbolToCell(sudoku, randomCell);
            if (exists usedSymbol) {
                return [randomCell];
            }
        }
        // If no symbol can be used, or unable to find an empty cell, sudoku can not be resolved
        return null;
    }

    SudokuCell? getRandomEmptyCell(Sudoku sudoku) {
        {SudokuCell*} emptyCells = sudoku.board.cells.filter((SudokuCell cell) => (!cell.symbol exists));
        if (emptyCells.empty) {
            return null;
        } else {
            value index = (Random().nextLong()).magnitude % (emptyCells.size);
            SudokuCell? cell = emptyCells.getFromFirst(index);
            return cell;
        }
    }

    shared actual Boolean rollback(Sudoku sudoku) {
        sudoku.board.reset();
        return true;
    }
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

