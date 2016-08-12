import ceylon.math.float {
	sqrt
}

"Run the module `sudokuSolver`."
shared void run() {
	value sudoku = Sudoku(4, 2);
	print(sudoku);
	
	print(sudoku.allSlices);
}

"Size is the number of characters (or the vertes
 Size should be an exponent for the dimension.
 Tipical Sudoku is size 9, dimension 2, slides 3 (9=3^2).
 3D Sudoku is size 27, dimension 3, slides 3 (27=3^3).
 
 Tipical sudoku is bidimensional. Rules apply for 2 axis (1D) and 1 square (2D) 
 3D sudoku rules are for 3 axis (x,y and z), 3 planes (2D) and 1 box (3D)"
shared class Sudoku(Integer size, Integer dimension = 2) {
	assert (size > 1);
	
	shared class Cell(shared [Coord+] coords, shared variable Symbol? symbol = null) {
		shared alias Coord => Integer;
		shared alias Symbol => Character;
		
		string => coords.string;
	}
	
	{[Integer+]*} constructAllCoordsRec(Integer size, Integer dimension, {[Integer+]*} current) {
		if (dimension == 1) {
			return { for (dim in 0 .. size-1) [dim] };
		} else {
			value short = constructAllCoordsRec(size, dimension - 1, current);
			return { for (Integer coord in 0 .. size-1) for ([Integer+] other in short) other.withLeading(coord) };
		}
	}
	
	shared {Cell*} allCells = { for ([Integer+] coords in constructAllCoordsRec(size, dimension, {})) Cell(coords) };
	
	"Size for a Sudoku should be (at least) a quadratic number. 9 is a valid size (3^2=9), but 5 is not."
	assert (sqrt(size.float).fractionalPart == 0);
	
	"Size for each slice is the square root for the size of the Sudoku."
	Integer sliceSize = sqrt(size.float).integer;
	
	"Slices are hypercubes (squares for 2D, cubes for 3D, hypercubes for 4D...)
	    Slices are also identified by their coordinates inside the whole Sudoku, following the same order than cells.
	    In other words, Slice with coordinates [x0..xn] contain all cells with coordinates [a0..an] that: (x)*sqrt(size)<=a<(x+1)*sqrt(size)"
	shared {Cell*} slice([Integer+] coords) {
		return allCells.filter(
			(Cell cell) => cell.coords.mapElements((Integer coordIdx, Sudoku.Cell.Coord cellCord) {
						assert (exists sliceCoord = coords[coordIdx]);
						value result = sliceCoord * sliceSize <= cellCord < (sliceCoord + 1) * sliceSize;
						//print("sliceCoord: ``sliceCoord`` cellCord[``coordIdx``]: ``cellCord`` -> ``result``");
						return (result);
					})
					.every((Boolean element) => element)
		);
	}
	
	shared {{Cell*}*} allSlices = { for ([Integer+] coords in constructAllCoordsRec(sliceSize, dimension, {})) slice(coords) };
	
	string => allCells.string;
	
	Collection<[Sudoku.Cell+]> allVectorsForCoordIdx(Integer cordIdx)=> allCells.group((Sudoku.Cell cell) => let (value slices = cell.coords.slice(cordIdx)) slices[0].append([null]).append(slices[1])).items;
	
	"Vectors are 1D arrays inside a Sudoku. Vector size is the same as the Sudoku.
	    All cells in a vector have the same coordinates BUT ONE (say XX).
	    Changing coordinate (XX) are different for each vector cells. In other words, coord[x] contains all possible values between 0 and size-1;
	    So we can identify every vector in a Sudoku by [X0..XX..Xn], being XX null, and X0...Xn being all possible values between 0 and size-1; "
	shared {{Cell*}*} vectors() {
		{ Map<Integer?[],[Cell+]>+} iterable = { for (Integer cordIdx in 0 .. size-1)
			allVectorsForCoordIdx(cordIdx);
		};
		
		
	}
	
	
	"Check if the all cell satisfy Sudoku rules. Rules are:
	    	- No slice have repeated symbols
	    	- Every 1D (vector) division have no repeated symbols.	 	
	    "
	shared Boolean satisfyRules() {
		
		return true;
	}
}
