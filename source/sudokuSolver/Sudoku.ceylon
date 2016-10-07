import ceylon.collection {
	HashMap,
	MutableMap
}
import ceylon.math.float {
	sqrt
}

shared class SudokuCell satisfies Cell<Sudoku> {
	"Currently, cells can be protected/unprotected at will.
	             This may change any time."
	shared variable Boolean protected;
	variable Symbol? _symbol = null;
	
	shared new (Symbol? symbol = null, Boolean protected = false) {
		"Can not make an empty protected cell"
		assert (!protected || symbol exists);
		
		this._symbol = symbol;
		this.protected = protected;
	}
	
	shared alias Coord => Integer;
	shared alias Symbol => Character;
	
	shared Symbol? symbol => _symbol;
	assign symbol {
		"Can not update the value for a protected cell."
		assert (!protected);
		_symbol = symbol;
	}
	
	shared void clear() => _symbol = null;
	shared Boolean empty() => !_symbol exists;
	
	string => (symbol?.string else "_");
}

shared [SudokuCell.Symbol*] defaultSudokuSymbols = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];

abstract shared class Sudoku() satisfies Game {}

shared class SudokuBoard extends Board<Sudoku, SudokuCell> {
	
	shared [SudokuCell.Symbol*] allowedSymbols;
	
	shared actual MutableMap<[Integer+],SudokuCell> cellMap;

	shared new(Integer size = 9, Integer dimension = 2, [SudokuCell.Symbol*] allowedSymbols = defaultSudokuSymbols) extends Board<Sudoku, SudokuCell>(size, dimension, SudokuCell) {
		
		"Size for a Sudoku should be (at least) a quadratic number. 9 is a valid size (3^2=9), but 5 is not."
		assert (sqrt(size.float).fractionalPart == 0);
		
		"Number of symbols should match the sqrt(size)^dimension"
		assert (allowedSymbols.size == ((sqrt(size.float).integer) ^ dimension));
		
		this.allowedSymbols = allowedSymbols;
		
		cellMap = HashMap { entries = { for ([Integer+] coords in constructAllCoordsRec(size, dimension)) Entry(coords, SudokuCell()) }; };
	}
	shared new fromSymbols(Integer dimension = 2, [SudokuCell.Symbol*] allowedSymbols = defaultSudokuSymbols) extends SudokuBoard((allowedSymbols.size ^ (1 / dimension)) ^ 2, dimension, allowedSymbols) {}


	
	"Set the symbol for the cell at the provided coords.
	             Will fail of symbol is not allowed, or cell is protected."
	shared SudokuCell? setSymbolAt([Integer+] coords, SudokuCell.Symbol symbol) {
		if (exists value cell = cellAt(coords)) {
			"Symbol not allowed"
			assert (allowedSymbols.contains(symbol));
			cell.symbol = symbol;
			return cell;
		}
		return null;
	}
	
	"Set the symbol for the cell at the provided coords, and then protect the cell for further changes.
	             Will fail of symbol is not allowed, or cell is already protected."
	shared SudokuCell? setProtectedSymbolAt([Integer+] coords, SudokuCell.Symbol symbol) {
		if (exists value cell = setSymbolAt(coords, symbol)) {
			cell.protected = true;
			return cell;
		}
		return null;
	}
	
	shared void replaceCell([Integer+] coords, SudokuCell newCell) {
		"Provided coordinates should already be present."
		assert (cellMap.keys.contains(coords));
		cellMap.put(coords, newCell);
	}
	
	"Clears all non-protected cells"
	shared void reset() {
		cells.each((SudokuCell cell) {
			if (!cell.protected) { cell.clear(); }
		});
	}


	
}