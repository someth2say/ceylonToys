import ceylon.collection {
    unmodifiableSet,
    HashSet
}
import ceylon.math.float {
    sqrt
}

shared class Sudoku(Integer size = 9, Integer dimension = 2, shared [SudokuCell.Symbol*] allowedSymbols = defaultSudokuSymbols) extends BoardGame<SudokuBoard,SudokuCell>() {

    board = SudokuBoard(size, dimension, allowedSymbols);

    /** Rules **/

    " Check if the all cell satisfy Sudoku rules. Default rules are:
     - All cells have a value.
     - No slice have repeated symbols
     - Every 1D (vector) division have no repeated symbols."

    Boolean haveUniqueSymbols({SudokuCell*} cells) => cells.map((cell) => cell.symbol).frequencies().map((symbol->count) => count).every((count) => count<2);

    "Default gameplay rules for Sudoku are
     1.- Do not repeat any symbol on a single slice.
     2.- Do not repeat any symbon on an hipercube."
    shared actual {BoardGameRule*} gamePlayRules =>  { NoRepeatOnSlicesRule(), NoRepeatOnHipercubesRule() };
/*    shared Set<BoardGameRule> defaultGamePlayRules => unmodifiableSet(HashSet {
        elements = { NoRepeatOnSlicesRule(), NoRepeatOnHipercubesRule() };
    });*/

    "Default gameover rules (definition of solved) for Sudoku are
     1.- Do not repeat any symbol on a single slice.
     2.- Do not repeat any symbon on an hipercube.
     3.- All cells have a valid symbol."
    shared actual {BoardGameRule*} gameOverRules =>  { EveryCellHaveValueRule(), NoRepeatOnSlicesRule(), NoRepeatOnHipercubesRule() };
    /*shared Set<BoardGameRule> defaultGameOverRules => unmodifiableSet(HashSet {
        elements = { EveryCellHaveValueRule(), NoRepeatOnSlicesRule(), NoRepeatOnHipercubesRule() };
    });*/

    //shared object noRepeatOnSlicesRule extends NoRepeatOnSlicesRule() {};

    "Rule that validates all slices satisfying predicate have no diplicate symbols."
    shared class NoRepeatOnSlicesRule() extends super.BoardGameRule() {
        shared actual Boolean checkPredicate(Predicate predicate) => board.slices.filter(predicate).every(haveUniqueSymbols);
    }

    "Rule that validates all hipercubes satisfying predicate have no diplicate symbols."
    class NoRepeatOnHipercubesRule() extends super.BoardGameRule() {
        shared actual Boolean checkPredicate(Predicate predicate) => board.hipercubes.filter(predicate).every(haveUniqueSymbols);
    }

    "Rule that validates all cells satisfying predicate have a symbols.
     Note that themselves assert only valid symbols are set, so no use on validating here."
    class EveryCellHaveValueRule() extends super.BoardGameRule() {
        shared actual Boolean checkPredicate(Predicate predicate) => expand(board.allCells.filter(predicate)).every((cell) => cell.symbol exists);
    }


}

shared class SudokuCell() extends Cell() {
    shared alias Coord => Integer;
    shared alias Symbol => Character;

    "Currently, cells can be protected/unprotected at will. This may vary anytime"
    shared variable Boolean protected = false;

    variable Symbol? _symbol = null;
    shared Symbol? symbol => _symbol;
    assign symbol {
        "Can not update the value for a protected cell."
        assert (!protected);
        _symbol = symbol;
    }

    "Can not make an empty protected cell"
    assert (!protected|| symbol exists);

    shared void clear() {
        assert (!protected);
        _symbol = null;
    }

    shared Boolean empty() => !_symbol exists;

    string => (symbol ?. string else "_");
}

shared [SudokuCell.Symbol*] defaultSudokuSymbols => ['1', '2', '3', '4', '5', '6', '7', '8', '9'];

shared class SudokuBoard(Integer size = 9, Integer dimension = 2, shared [SudokuCell.Symbol*] allowedSymbols = defaultSudokuSymbols) extends CartesianBoard<SudokuCell>(size, dimension) {

    /** Initialization **/

    Integer cellAmmount;

    "Size for a Sudoku should be (at least) a quadratic number. 9 is a valid size (3^2=9), but 5 is not."
    assert (sqrt(size.float).fractionalPart == 0);

    "Number of symbols should match the sqrt(size)^dimension"
    assert (allowedSymbols.size == ((sqrt(size.float).integer) ^ dimension));

    cellAmmount = size * dimension;

    //shared new fromSymbols(Cell[] cells, Integer dimension = 2, [Cell.Symbol*] allowedSymbols = defaultSudokuSymbols) extends Board((allowedSymbols.size ^ (1 / dimension)) ^ 2, dimension, allowedSymbols) {}
    shared actual [SudokuCell*] cells = [for (_ in 0 .. cellAmmount - 1) SudokuCell()];

    /** Declaration **/

    "Set the symbol for the cell at the provided coords.
             Will fail of symbol is not allowed, or cell is protected."
    shared SudokuCell? setSymbolAt([Integer+] coords, SudokuCell.Symbol symbol) {
        if (exists SudokuCell cell = cellAt(coords)) {
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

    "Clears all non-protected cells"
    shared void reset() => cells.filter((element) => !element.protected).each(SudokuCell.clear);

    "Splits are just a subset of cells satisfying a predicate."
    shared alias SudokuSplit => {{SudokuCell*}*};

    /**
    Hipercube splitter
    */

    "Size for each hipercube is the square root for the size of the Sudoku."
    Integer hipercubeSize => sqrt(size.float).integer;

    shared alias Hipercube => {SudokuCell*};

    Hipercube hipercube([Integer+] coords) {
        {SudokuCell*} result = cellMap.filter((coords->cell) => coords.indexed.every((coordIdx->cellCord) {
            assert (exists currentCoord = coords[coordIdx]);
            return (currentCoord * hipercubeSize<=cellCord<(currentCoord + 1) * hipercubeSize);
        })).map((coords->cell) => cell).sequence();
        return result;
    }

    "Hypercubes (squares for 2D, cubes for 3D, hypercubes for 4D...) are identified by their coordinates inside the whole Sudoku, following the same order than cells.
      In other words, Hipercube with coordinates [x0..xn] contain all cells with coordinates [a0..an] that: (x)*sqrt(size)<=a<(x+1)*sqrt(size)"
    shared SudokuSplit hipercubes => { for ([Integer+] coords in constructAllCoordsRec(hipercubeSize, dimension)) hipercube(coords) };

    /**
       AllCells splitter
       */
    shared SudokuSplit allCells => { cells };

    /**
    Slice splitter
    */

    shared alias Slice => {SudokuCell*};

    "Obtain all cells, grouped by the value on the provided dimension (aka coordIdx)"
    {Slice*} slice(Integer dimension) => cellMap.group((coord->cell) => coord.get(dimension) else - 1).items.map((entries) => entries.map(Entry.item));

    "Slices are 1D arrays inside a Sudoku. Vector size is the same as the Sudoku.
        All cells in a vector have the same coordinates BUT ONE (say XX).
        Changing coordinate (XX) are different for each vector cells. In other words, coord[x] contains all possible values between 0 and size-1;
        So we can identify every vector in a Sudoku by [X0..XX..Xn], being XX null, and X0...Xn being all possible values between 0 and size-1; "
    shared SudokuSplit slices => expand((0 .. dimension - 1).map(slice));
}
