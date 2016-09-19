import ceylon.math.float {
	sqrt
}
import ceylon.test {

	assertThatException,
	fail
}

"Run the module `sudokuSolver`."
shared void run() {
	value sudoku = Sudoku(4, 2);
	print("Cells: (``sudoku.cells.size``)  ``sudoku``");
	assert(sudoku.cells.size == 16);
	print("Slices: (``sudoku.slices.size``)   ``sudoku.slices``");
	assert(sudoku.slices.size == 4);
	print("Vectors: (``sudoku.vectors.size``)  ``sudoku.vectors``");
	assert(sudoku.vectors.size == 8);
	
	"Empty sudoku does not satisfy default rules." 
	assert (checkRules(sudoku)==false);
	
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
	sudoku.setSymbolAt([2,2], '3');
	sudoku.setSymbolAt([2,3], '2');
	sudoku.setSymbolAt([3,0], '3');
	sudoku.setSymbolAt([3,1], '2');
	sudoku.setSymbolAt([3,2], '1');
	sudoku.setSymbolAt([3,3], '0');
	assert (checkRules(sudoku)==true);
	
	try {
		sudoku.setSymbolAt([3,3], 'A');
		fail("Symbols 'A' should not be allowed.");
	} catch (AssertionError e) {
		
	}
}

"Size is the number of characters (or the vertes
 Size should be an exponent for the dimension.
 Tipical Sudoku is size 9, dimension 2, slides 3 (9=3^2).
 3D Sudoku is size 27, dimension 3, slides 3 (27=3^3).
 
 Tipical sudoku is bidimensional. Rules apply for 2 axis (1D) and 1 square (2D) 
 3D sudoku rules are for 3 axis (x,y and z), 3 planes (2D) and 1 box (3D)"
shared class Sudoku(Integer size, Integer dimension = 2) {
	assert (size > 1);
	
	"Size for a Sudoku should be (at least) a quadratic number. 9 is a valid size (3^2=9), but 5 is not."
	assert (sqrt(size.float).fractionalPart == 0);
	
	shared class Cell(shared [Coord+] coords, shared {Symbol*} allowedSymbols = "0123456789") {
		assert(allowedSymbols.size>0);
		shared alias Coord => Integer;
		shared alias Symbol => Character;

		variable Symbol? _symbol = null;
		shared Symbol? symbol =>_symbol;
		assign symbol {
			if (exists symbol) {
				"Symbol not alloeed."
				assert(allowedSymbols.contains(symbol));
			} 
			_symbol=symbol;
		}
		
		string => (symbol?.string else "_") + coords.string;
	}
	
	{[Integer+]*} constructAllCoordsRec(Integer size, Integer dimension, {[Integer+]*} current) {
		if (dimension == 1) {
			return { for (dim in 0 .. size-1) [dim] };
		} else {
			value short = constructAllCoordsRec(size, dimension - 1, current);
			return { for (Integer coord in 0 .. size-1) for ([Integer+] other in short) other.withLeading(coord) };
		}
	}
	"All cells in the Sudoku"
	shared [Cell*] cells = [ for ([Integer+] coords in constructAllCoordsRec(size, dimension, {})) Cell(coords) ];
	
	shared Cell? cellAt([Integer+] coords) => cells.find((Cell cell) => cell.coords.equals(coords));
	shared Cell? setSymbolAt([Integer+] coords, Cell.Symbol symbol) {
		if (exists value cell = cellAt(coords)) {
			cell.symbol = symbol;
			return cell;
		}
		return null;
	}
	
	"Size for each slice is the square root for the size of the Sudoku."
	Integer sliceSize = sqrt(size.float).integer;
	
	"Slices are hypercubes (squares for 2D, cubes for 3D, hypercubes for 4D...)
	                         Slices are also identified by their coordinates inside the whole Sudoku, following the same order than cells.
	                         In other words, Slice with coordinates [x0..xn] contain all cells with coordinates [a0..an] that: (x)*sqrt(size)<=a<(x+1)*sqrt(size)"
	shared {Cell*} slice([Integer+] coords) => cells.filter(
		(Cell cell) => cell.coords.indexed.every((Integer coordIdx -> Sudoku.Cell.Coord cellCord) {
			assert (exists sliceCoord = coords[coordIdx]);
			return (sliceCoord * sliceSize <= cellCord < (sliceCoord + 1) * sliceSize);
		})

	);
	
	shared {{Cell*}*} slices = { for ([Integer+] coords in constructAllCoordsRec(sliceSize, dimension, {})) slice(coords) };
	
	string => cells.string;
	
	{[Cell+]*} allVectorsForCoordIdx(Integer cordIdx) => cells.group((Cell cell) => cell.coords.slice(cordIdx)[0].append([null]).append(cell.coords.slice(cordIdx)[1].rest)).items;
	
	"Vectors are 1D arrays inside a Sudoku. Vector size is the same as the Sudoku.
	   All cells in a vector have the same coordinates BUT ONE (say XX).
	   Changing coordinate (XX) are different for each vector cells. In other words, coord[x] contains all possible values between 0 and size-1;
	   So we can identify every vector in a Sudoku by [X0..XX..Xn], being XX null, and X0...Xn being all possible values between 0 and size-1; "
	shared {[Cell+]*} vectors => expand((0 .. dimension-1).map(allVectorsForCoordIdx));

}

"Check if the all cell satisfy Sudoku rules. Default rules are:
 - All cells have a value.
 - No slice have repeated symbols
 - Every 1D (vector) division have no repeated symbols."
shared Boolean checkRules(Sudoku sudoku, {SudokuRule*} rules = { everyCellHaveValueRule , noRepeatOnVectorsRule, noRepeatOnSlicesRule} ) => rules.every((SudokuRule rule) => rule(sudoku));

shared alias SudokuRule => Boolean(Sudoku);
Boolean haveUniqueSymbols({Sudoku.Cell*} cells) => (cells.map(Sudoku.Cell.symbol).distinct.size == cells.size);
shared SudokuRule noRepeatOnVectorsRule => (Sudoku sudoku) => sudoku.vectors.every(haveUniqueSymbols);
shared SudokuRule noRepeatOnSlicesRule => (Sudoku sudoku) => sudoku.slices.every(haveUniqueSymbols);
shared SudokuRule everyCellHaveValueRule => (Sudoku sudoku) => sudoku.cells.every((Sudoku.Cell cell) => (cell.symbol exists) );
