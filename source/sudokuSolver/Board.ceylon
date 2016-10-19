import ceylon.collection {
    HashMap
}

shared interface Game {}

shared abstract class Cell<GameType>() given GameType satisfies Game {}

"Size is the lenght of an edge for the Sudoku.
 Dimension means the number of coordinates (dimensions) the Sudoku is composed of.
 Size should be an exponent for the dimension.
 Tipical Sudoku is size 9, dimension 2.
 3D Sudoku is size 27, dimension 3.

 Tipical sudoku is bidimensional. Rules apply for 2 axis (1D) and 1 square (2D)
 3D sudoku rules are for 3 axis (x,y and z), 3 planes (2D) and 1 box (3D)"
shared abstract class Board<GameType,CellType>()
given GameType satisfies Game
given CellType satisfies Cell<GameType> {
    shared late default [CellType*] cells;

    shared actual default String string => cells.string;

    /** Predicates **/

    "CellPredicates are used to filter the cells where rules should be applied.
      Is responsibility for the rule to decide between applying the rune to a single cell or to a spedcific type of CellSet.
      Default predicate is `acceptAllPredicate`, meaning rule will be applied to all cells."
    shared alias Predicate => Boolean({CellType*});

    //Boolean({Cell<GameType>*}) _acceptAllPredicate given GameType satisfies Game => ({Cell<GameType>*} cellSet) => true;
    Boolean acceptAllPredicate({CellType*} cellSet) => true;

    "containsCellPredicate denotates that rule should be applied only to the provided cell, or to CellSets containing the provided cell."
    //Predicate<Game> containsCellPredicate(Cell<Game> cell) => ({Cell<Game>*} cellSet) => cellSet.contains(cell);
    Boolean containsCellPredicate(CellType cell)({CellType*} cellSet) => cellSet.contains(cell);

    /** Rules **/

    "Rules are boolean functions that can be applied to a set of cells. In other words, rules apply to a Cell Predicate
        There are two kind of rules:
        - Gameplay rules: Validate the current board is valid during gameplay.
        - Gameover rules: Validate the current board is complete (game over).
       "
    shared alias Rule => Boolean(Predicate);

    "Check that sudoku satisfies provided rules (every cell is checked)"
    shared Boolean checkRules({Rule*} rules)
            => rules.every((rule) => rule(acceptAllPredicate));

    "Check that sudoku satisfies provided rules at the provided cell.
     Assumes cell belong to provided Sudoku. Else, 'true' is returned."
    shared Boolean checkRulesOnCells(CellType cell, {Rule*} rules)
            => rules.every((rule) => rule(containsCellPredicate(cell)));

    /** Splitter **/

    "Splitter are methods that, given a Board, generate a set of cells in it that satisfy a condition."
    shared alias Splitter => {{CellType*}*}();
}

shared abstract class CartesianBoard<GameType,CellType>(shared Integer size, shared Integer dimension) extends Board<GameType,CellType>()
given GameType satisfies Game
given CellType satisfies Cell<GameType> {

    "Sudoku size shoud be at least 2"
    assert (size>1);

    Map<[Integer+],CellType> mapCellsToCoords({CellType*} cells, [[Integer+]*] allCoords) {
        {<[Integer+]->CellType>*} entries = cells.indexed.map((Integer idx->CellType cell) {
            assert (exists [Integer+] coord = allCoords.getFromFirst(idx));
            return (coord->cell);
        });
        return HashMap {
            entries = entries;
        };
    }

    shared [[Integer+]*] constructAllCoordsRec(Integer size, Integer dimension) {
        if (dimension == 1) {
            return [for (dim in 0 .. size - 1) [dim]];
        } else {
            value short = constructAllCoordsRec(size, dimension - 1);
            return [for (Integer coord in 0 .. size - 1) for ([Integer+] other in short) other.withLeading(coord)];
        }
    }

    value allCoordsRec = constructAllCoordsRec(size, dimension);

    shared Map<[Integer+],CellType> cellMap => mapCellsToCoords(cells, allCoordsRec);

    "Return a *mutable* cell, given coordinates inside the sudoku."
    shared default CellType? cellAt([Integer+] coords) => cellMap.get(coords);

    shared actual default String string => cellMap.string;
}

