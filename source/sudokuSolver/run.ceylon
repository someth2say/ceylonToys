import ceylon.math.float {
	sqrt
}

"Run the module `sudokuSolver`."
shared void run() {
	value sudoku = Sudoku(4, 2);
	print(sudoku);

	print(sudoku.slice([0, 0]));
	print(sudoku.slice([0, 1]));
	print(sudoku.slice([1, 0]));	
	print(sudoku.slice([1, 1]));
}

"Size is the number of characters.
 Sice should be an exponent for the dimension.
 Tipical Sudoku is size 9, dimension 2, slides 3 (9=3^2).
 3D Sudoku is size 27, dimension 3, slides 3 (27=3^3).
 
 Tipical sudoku is bidimensional. Rules are for 2 axis (1D) and 1 square (2D) 
 3D sudoku rules are for 3 axis (x,y and z), 3 planes (2D) and 1 box (3D)"
shared class Sudoku(Integer size, Integer dimension = 2) {
	assert (size > 1);
	
	"Size for a Sudoku should be (at least) a quadratic number.
	                   Say, 9 is a valid size (3^2=9), but 5 is not."
	assert (sqrt(size.float).fractionalPart == 0);
	Integer slideSize = sqrt(size.float).integer;
	
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
	
	{Cell*} allCells = { for ([Integer+] coords in constructAllCoordsRec(size, dimension, {})) Cell(coords) };
	
	"Slides are hypercubes (squares for 2D, cubes for 3D, hypercubes for 4D...)
	                   Slides are also defined by their coordinates inside the whole Sudoku, following the same order than cells.
	                   That is: For size=4,dimension=2 Sudoku.
	                   Cells are: { [0, 0], [0, 1], [0, 2], [0, 3], [1, 0], [1, 1], [1, 2], [1, 3], [2, 0], [2, 1], [2, 2], [2, 3], [3, 0], [3, 1], [3, 2], [3, 3] } 
	                   Slides are: { [0, 0] -> { [0, 0], [0, 1], [1, 0], [1, 1] },
	                   			   [0, 1] -> { [0, 2], [0, 3], [1, 2], [1, 3] },
	                   			   [1, 0] -> { [2, 0], [2, 1], [3, 0], [3, 1] },
	                   			   [1, 1] -> { [2, 2], [2, 3], [3, 2], [3, 3] } }
	                   In other words, Slide with coordinates [x,y] contain all cells with coordinates [a,b] that: 
	                   	(x)*sqrt(size)<=a<(x+1)*sqrt(size), (y)*sqrt(size)<b<=(y+1)y*sqrt(size) =
	                   	
	                   	
	                   "
	shared {Cell*} slice([Integer+] coords) {
		print("Slice(``slideSize``) for ``coords``:");
		return allCells.filter(
			(Sudoku.Cell cell) => cell.coords.mapElements((Integer coordIdx, Sudoku.Cell.Coord cellCord) {
						assert (exists sliceCoord = coords[coordIdx]);
						value result = sliceCoord * slideSize <= cellCord < (sliceCoord + 1) * slideSize;
						//print("sliceCoord: ``sliceCoord`` cellCord[``coordIdx``]: ``cellCord`` -> ``result``");
						return (result);
					})
					.every((Boolean element) => element)
		);
	}
	string => allCells.string;
}
