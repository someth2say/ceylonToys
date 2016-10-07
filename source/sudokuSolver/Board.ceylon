"Game is a type container for the kind of game"
shared interface Game {}


"Size is the lenght of an edge for the Sudoku.
 Dimension means the number of coordinates (dimensions) the Sudoku is composed of.
 Size should be an exponent for the dimension.
 Tipical Sudoku is size 9, dimension 2.
 3D Sudoku is size 27, dimension 3.
 
 Tipical sudoku is bidimensional. Rules apply for 2 axis (1D) and 1 square (2D) 
 3D sudoku rules are for 3 axis (x,y and z), 3 planes (2D) and 1 box (3D)"
shared abstract class Board<GameType, CellType>(shared Integer size, shared Integer dimension, Cell<GameType>() cellBuilder)
		given GameType satisfies Game 
		given CellType satisfies Cell<GameType>{
	
	"Sudoku size shoud be at least 2"
	assert (size > 1);
	
	shared formal Map<[Integer+],CellType> cellMap;
	
	"All cells in the Sudoku"
	shared default {CellType*} cells => cellMap.items;
	
	"Return a *mutable* cell, given coordinates inside the sudoku."
	shared CellType? cellAt([Integer+] coords) => cellMap.get(coords);
	
	string => cellMap.string;
}
suppressWarnings("unusedDeclaration")
shared interface Cell<GameType> given GameType satisfies Game {}

{[Integer+]*} constructAllCoordsRec(Integer size, Integer dimension) {
	if (dimension == 1) {
		return { for (dim in 0 .. size-1) [dim] };
	} else {
		value short = constructAllCoordsRec(size, dimension - 1);
		return { for (Integer coord in 0 .. size-1) for ([Integer+] other in short) other.withLeading(coord) };
	}
}
