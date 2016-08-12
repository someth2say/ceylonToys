import ceylon.math.float {
	sqrt
}

"Run the module `sudokuSolver`."
shared void run() {
	value sudoku = Sudoku(4, 2);
	print(sudoku);
	
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
	
	shared class Cell(shared [Coord+] coords) {
		shared alias Coord => Integer;
		
		string => coords.string;
		shared variable Character? symbol = null;
	}
	
	{[Integer+]*} constructAllCoordsRec(Integer size, Integer dimension, {[Integer+]*} current) {
		if (dimension == 1) {
			return { for (dim in 1..size) [dim] };
		} else {
			value short = constructAllCoordsRec(size, dimension - 1, current);
			return { for (Integer coord in 1..size) for ([Integer+] other in short) other.withLeading(coord) };
		}
	}
	
	{Cell*} allCells = { for ([Integer+] coords in constructAllCoordsRec(size, dimension, {})) Cell(coords) };
	
	"Slides are hypercubes (squares for 2D, cubes for 3D, hypercubes for 4D...)
	                Slides are also defined by their coordinates inside the whole Sudoku, following the same order than cells.
	                That is: For size=4,dimension=2 Sudoku.
	                Cells are: { [1, 1], [1, 2], [1, 3], [1, 4], [2, 1], [2, 2], [2, 3], [2, 4], [3, 1], [3, 2], [3, 3], [3, 4], [4, 1], [4, 2], [4, 3], [4, 4] } 
	                Slides are: { [1, 1] -> { [1, 1], [1, 2], [2, 1], [2, 2] },
	                			   [1, 2] -> { [1, 3], [1, 4], [2, 3], [2, 4] },
	                			   [2, 1] -> { [3, 1], [3, 2], [4, 1], [4, 2] },
	                			   [2, 2] -> { [3, 3], [3, 4], [4, 3], [4, 4] } }
	                In other words, Slide with coordinates [x,y] contain all cells with coordinates [a,b] that: 
	                	(x-1)*sqrt(size)<a<=x*sqrt(size), (y-1)*sqrt(size)<b<=y*sqrt(size)
	                "
	shared {Cell*} slice([Integer+] coords) =>
		allCells.filter(
			(Sudoku.Cell cell) => cell.coords.mapElements((Integer coordIdx, Sudoku.Cell.Coord cellCord) {
						assert (exists lo = coords[coordIdx], exists hi = coords[coordIdx + 1]);
						print("lo: ``lo``  hi: ``hi`` cellCord: ``cellCord``");
						return (lo * slideSize <= cellCord < hi * slideSize);
					})
					.every((Boolean element) => element)
		);
	
	string => allCells.string;
}
