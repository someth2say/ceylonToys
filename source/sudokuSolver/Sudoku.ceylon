import ceylon.math.float {
	sqrt
}

shared [Sudoku.Cell.Symbol*] defaultSymbols = ['1','2','3','4','5','6','7','8','9'];

"Size is the number of characters (or the vertes
 Size should be an exponent for the dimension.
 Tipical Sudoku is size 9, dimension 2, slides 3 (9=3^2).
 3D Sudoku is size 27, dimension 3, slides 3 (27=3^3).
 
 Tipical sudoku is bidimensional. Rules apply for 2 axis (1D) and 1 square (2D) 
 3D sudoku rules are for 3 axis (x,y and z), 3 planes (2D) and 1 box (3D)"
shared class Sudoku(Integer size=9, Integer dimension = 2, shared [Sudoku.Cell.Symbol*] symbols = defaultSymbols) {
	"Sudoku size shoud be at least 2"
	assert (size > 1);
	
	"Size for a Sudoku should be (at least) a quadratic number. 9 is a valid size (3^2=9), but 5 is not."
	assert (sqrt(size.float).fractionalPart == 0);
	
	"Number of symbols should be size^(dimension-1)"
	assert (symbols.size == (size^(dimension-1)));
	
	shared class Cell(shared [Coord+] coords, shared [Symbol*] allowedSymbols = defaultSymbols) {
		assert(allowedSymbols.size>0);
		shared alias Coord => Integer;
		shared alias Symbol => Character;

		variable Symbol? _symbol = null;
		shared Symbol? symbol =>_symbol;
		assign symbol {
			if (exists symbol) {
				"Symbol not alloed."
				assert(allowedSymbols.contains(symbol));
			} 
			_symbol=symbol;
		}
		
		shared void clear() => _symbol=null;
		shared Boolean empty() => ! _symbol exists;
		
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
	shared [Cell*] cells = [ for ([Integer+] coords in constructAllCoordsRec(size, dimension, {})) Cell(coords, symbols) ];
	
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
	shared {Cell*} hipercube([Integer+] coords) => cells.filter(
		(Cell cell) => cell.coords.indexed.every((Integer coordIdx -> Sudoku.Cell.Coord cellCord) {
			assert (exists sliceCoord = coords[coordIdx]);
			return (sliceCoord * sliceSize <= cellCord < (sliceCoord + 1) * sliceSize);
		})
	);
	shared {{Cell*}*} hipercubes = { for ([Integer+] coords in constructAllCoordsRec(sliceSize, dimension, {})) hipercube(coords) };
		
	{[Cell+]*} slice(Integer dimension) => //cells.group((Cell cell) => cell.coords.slice(dimension)[0].append([null]).append(cell.coords.slice(dimension)[1].rest)).items;
				cells.group((Sudoku.Cell cell) => cell.coords.get(dimension) else -1).items;
	
	"Vectors are 1D arrays inside a Sudoku. Vector size is the same as the Sudoku.
	   All cells in a vector have the same coordinates BUT ONE (say XX).
	   Changing coordinate (XX) are different for each vector cells. In other words, coord[x] contains all possible values between 0 and size-1;
	   So we can identify every vector in a Sudoku by [X0..XX..Xn], being XX null, and X0...Xn being all possible values between 0 and size-1; "
	shared {[Cell+]*} slices => expand((0 .. dimension-1).map(slice));

	string => cells.string;
}