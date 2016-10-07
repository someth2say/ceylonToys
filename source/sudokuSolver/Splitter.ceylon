import ceylon.math.float {
	sqrt
}

"Splitter are methods that, given a Board, generate a set of cells in it that satisfy a condition."
shared alias Splitter<GameType, CellSetType, CellType, BoardType>
		given GameType satisfies Game 
		given CellType satisfies Cell<GameType>
		given CellSetType satisfies {CellType*}
		given BoardType satisfies Board<GameType, CellType>
		=> {CellSetType*}(BoardType);

/**
 Hipercube splitter
 */
shared alias Hipercube => {SudokuCell*};

"Size for each hipercube is the square root for the size of the Sudoku."
Integer hipercubeSize(SudokuBoard board) => sqrt(board.size.float).integer;

Hipercube hipercube(SudokuBoard sudoku, [Integer+] coords) {
	value result = sudoku.cellMap.filter(
		(
			coords -> cell) => coords.indexed.every(
				(coordIdx -> cellCord) { 
					assert (exists currentCoord = coords[coordIdx]);
					return (currentCoord * hipercubeSize(sudoku) <= cellCord < (currentCoord + 1) * hipercubeSize(sudoku)); }
				)
			).map((coords -> cell) => cell).sequence();
			
			assert (nonempty result);
			return result;	
		}
		
"Hypercubes (squares for 2D, cubes for 3D, hypercubes for 4D...) are identified by their coordinates inside the whole Sudoku, following the same order than cells.
  In other words, Hipercube with coordinates [x0..xn] contain all cells with coordinates [a0..an] that: (x)*sqrt(size)<=a<(x+1)*sqrt(size)"
shared Splitter<Sudoku, Hipercube, SudokuCell, SudokuBoard> hipercubes => (SudokuBoard sudoku) => { for ([Integer+] coords in constructAllCoordsRec(hipercubeSize(sudoku), sudoku.dimension)) hipercube(sudoku, coords) };
		
/**
  Slice splitter
 */
		
shared alias Slice => {SudokuCell*};

"Obtain all cells, grouped by the value on the provided dimension (aka coordIdx)"
{Slice*} slice(SudokuBoard sudoku)(Integer dimension) {
	Map<Integer,[<[Integer+]->SudokuCell>*]> entriesMap = sudoku.cellMap.group((coord->cell) => coord.get(dimension) else -1);
	return entriesMap.items.map((entries) => entries.map(Entry.item));
}

"Slices are 1D arrays inside a Sudoku. Vector size is the same as the Sudoku.
  All cells in a vector have the same coordinates BUT ONE (say XX).
  Changing coordinate (XX) are different for each vector cells. In other words, coord[x] contains all possible values between 0 and size-1;
  So we can identify every vector in a Sudoku by [X0..XX..Xn], being XX null, and X0...Xn being all possible values between 0 and size-1; "	
shared Splitter<Sudoku, Slice, SudokuCell, SudokuBoard> slices => (SudokuBoard sudoku) => expand((0 .. sudoku.dimension-1).map(slice(sudoku)));

	
/**
 AllCells splitter
 */	
shared alias SudokuCells => {SudokuCell*};
shared Splitter<Sudoku, SudokuCells, SudokuCell, SudokuBoard> allCells => (SudokuBoard sudoku) => { sudoku.cells };
	
	
	
	
	
	
	
	
	
	
	
	