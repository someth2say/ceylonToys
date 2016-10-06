import ceylon.math.float {
	sqrt
}
import ceylon.collection {

	MutableMap,
	HashMap
}

shared [Sudoku.Cell.Symbol*] defaultSymbols = ['1','2','3','4','5','6','7','8','9'];

"Size is the lenght of an edge for the Sudoku.
 Dimension means the number of coordinates (dimensions) the Sudoku is composed of.
 Size should be an exponent for the dimension.
 Tipical Sudoku is size 9, dimension 2.
 3D Sudoku is size 27, dimension 3.
 
 Tipical sudoku is bidimensional. Rules apply for 2 axis (1D) and 1 square (2D) 
 3D sudoku rules are for 3 axis (x,y and z), 3 planes (2D) and 1 box (3D)"
shared class Sudoku(Integer size=9, Integer dimension = 2, shared [Sudoku.Cell.Symbol*] allowedSymbols = defaultSymbols) {
	
	"Sudoku size shoud be at least 2"
	assert (size > 1);
	
	"Size for a Sudoku should be (at least) a quadratic number. 9 is a valid size (3^2=9), but 5 is not."
	assert (sqrt(size.float).fractionalPart == 0);
	
	"Size for each hipercube is the square root for the size of the Sudoku."
	Integer hipercubeSize = sqrt(size.float).integer;

	"Number of symbols should be size^(dimension-1)"
	//assert (allowedSymbols.size == (size^(dimension-1)));
	assert (allowedSymbols.size == (hipercubeSize^dimension));
	
	shared class Cell {
		"Currently, cells can be protected/unprotected at will.
		 This may change any time."
		shared variable Boolean protected;
		variable Symbol? _symbol = null;
		
		shared new (Symbol? symbol = null, Boolean protected = false) {
			
			"Can not make an empty protected cell"			
			assert(!protected || symbol exists);
			
			this._symbol=symbol;
			this.protected = protected;			
		}

		shared alias Coord => Integer;
		shared alias Symbol => Character;

		shared Symbol? symbol =>_symbol;
		assign symbol {
			"Can not update the value for a protected cell."
			assert(!protected);
			_symbol=symbol;
		}
		
		shared void clear() => _symbol=null;
		shared Boolean empty() => ! _symbol exists;
		
		string => (symbol?.string else "_");
	}
	

	
	"CellSets are just set of cells belonging to a the same Sudoku.
	 There are three kind of CellSets:
	 1) All cells in the sudoku.
	 2) Slices
	 3) Hipercubes"
	shared alias CellSet => {Cell+};
	shared alias Hipercube => CellSet;
	shared alias Slice => CellSet;

	{[Integer+]*} constructAllCoordsRec(Integer size, Integer dimension) {
		if (dimension == 1) {
			return { for (dim in 0 .. size-1) [dim] };
		} else {
			value short = constructAllCoordsRec(size, dimension - 1);
			return { for (Integer coord in 0 .. size-1) for ([Integer+] other in short) other.withLeading(coord) };
		}
	}
	
	MutableMap<[Integer+],Cell> cellMap = HashMap{ entries = { for ([Integer+] coords in constructAllCoordsRec(size, dimension)) Entry(coords,Cell()) }; } ;
	
	"All cells in the Sudoku"
	shared {Cell*} cells => cellMap.items;
	
	"Return a *mutable* cell, given coordinates inside the sudoku."
	shared Cell? cellAt([Integer+] coords) => cellMap.get(coords);
	
	shared void replaceCell([Integer+] coords, Cell newCell) {
		"Provided coordinates should already be present."
		assert(cellMap.keys.contains(coords));		
		cellMap.put(coords, newCell);
	}
	
	"Set the symbol for the cell at the provided coords.
	 Will fail of symbol is not allowed, or cell is protected."
	shared Cell? setSymbolAt([Integer+] coords, Cell.Symbol symbol) {
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
	shared Cell? setProtectedSymbol([Integer+] coords, Cell.Symbol symbol) {
		if (exists value cell = setSymbolAt(coords, symbol)) {
			cell.protected=true;
			return cell;
		}
		return null;
	}
		
	Hipercube hipercube([Integer+] coords) {
		value result = cellMap.filter(
			(
				coords -> cell) => coords.indexed.every(
					(coordIdx -> cellCord) { 
						assert (exists currentCoord = coords[coordIdx]);
						return (currentCoord * hipercubeSize <= cellCord < (currentCoord + 1) * hipercubeSize); }
				)
			).map((coords -> cell) => cell).sequence();
			
		assert (nonempty result);
		return result;	
	}
	"Hypercubes (squares for 2D, cubes for 3D, hypercubes for 4D...) are identified by their coordinates inside the whole Sudoku, following the same order than cells.
	     In other words, Hipercube with coordinates [x0..xn] contain all cells with coordinates [a0..an] that: (x)*sqrt(size)<=a<(x+1)*sqrt(size)"
	shared {Hipercube*} hipercubes = { for ([Integer+] coords in constructAllCoordsRec(hipercubeSize, dimension)) hipercube(coords) };

		
	"Obtain all cells, grouped by the value on the provided dimension (aka coordIdx)"
	{{Sudoku.Cell+}*} slice(Integer dimension) {
		Map<Integer,[<[Integer+]->Sudoku.Cell>+]> entriesMap = cellMap.group((coord->cell) => coord.get(dimension) else -1);
		return entriesMap.items.map((entries) => entries.map(Entry.item));
	}
		
	"Slices are 1D arrays inside a Sudoku. Vector size is the same as the Sudoku.
	   All cells in a vector have the same coordinates BUT ONE (say XX).
	   Changing coordinate (XX) are different for each vector cells. In other words, coord[x] contains all possible values between 0 and size-1;
	   So we can identify every vector in a Sudoku by [X0..XX..Xn], being XX null, and X0...Xn being all possible values between 0 and size-1; "	
	shared {{Cell+}*} slices => expand((0 .. dimension-1).map(slice));

	string => cellMap.string;
	
	"Clears all non-protected cells"
	shared void reset(){
		cells.filter((cell) => !cell.protected).each((cell) => cell.clear());
	}
}