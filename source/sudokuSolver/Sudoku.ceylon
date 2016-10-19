import ceylon.collection {
    unmodifiableSet,
    HashSet
}
import ceylon.math.float {
    sqrt
}

shared interface Sudoku satisfies Game {}

shared class SudokuCell() extends Cell<Sudoku>() {
    shared alias Coord => Integer;
    shared alias Symbol => Character;

    "Currently, cells can be protected/unprotected at will.
                 This may change any time."
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

shared class SudokuBoard extends CartesianBoard<Sudoku,SudokuCell> {

    /** Initialization **/

    shared [SudokuCell.Symbol*] allowedSymbols;

    Integer cellAmmount;
    shared new (Integer size = 9, Integer dimension = 2, [SudokuCell.Symbol*] allowedSymbols = defaultSudokuSymbols) extends CartesianBoard<Sudoku,SudokuCell>(size, dimension) {

        "Size for a Sudoku should be (at least) a quadratic number. 9 is a valid size (3^2=9), but 5 is not."
        assert (sqrt(size.float).fractionalPart == 0);

        "Number of symbols should match the sqrt(size)^dimension"
        assert (allowedSymbols.size == ((sqrt(size.float).integer) ^ dimension));

        this.allowedSymbols = allowedSymbols;

        cellAmmount = size * dimension;
    }

    shared new fromSymbols(SudokuCell[] cells, Integer dimension = 2, [SudokuCell.Symbol*] allowedSymbols = defaultSudokuSymbols) extends SudokuBoard((allowedSymbols.size ^ (1 / dimension)) ^ 2, dimension, allowedSymbols) {}

    cells = [for (_ in 0 .. cellAmmount - 1) SudokuCell()];

    /** Definition **/

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
    shared Splitter hipercubes => () => { for ([Integer+] coords in constructAllCoordsRec(hipercubeSize, dimension)) hipercube(coords) };

    /**
       AllCells splitter
       */
    shared Splitter allCells => () => { cells };

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
    shared Splitter slices => () => expand((0 .. dimension - 1).map(slice));

    /** Rules **/

    " Check if the all cell satisfy Sudoku rules. Default rules are:
     - All cells have a value.
     - No slice have repeated symbols
     - Every 1D (vector) division have no repeated symbols."

    Boolean haveUniqueSymbols({SudokuCell*} cells) => cells.map((cell) => cell.symbol).frequencies().map((symbol->count) => count).every((count) => count<2);

    "Rule that validates all slices satisfying predicate have no diplicate symbols.
     THOSE ARE PART OF INITIALIZATION!"
    shared Rule noRepeatOnSlicesRule => (Predicate predicate) => slices().filter(predicate).every(haveUniqueSymbols);
    "Rule that validates all hipercubes satisfying predicate have no diplicate symbols."
    shared Rule noRepeatOnHipercubesRule => (Predicate predicate) => hipercubes().filter(predicate).every(haveUniqueSymbols);
    "Rule that validates all cells satisfying predicate have a symbols.
     Note that themselves assert only valid symbols are set, so no use on validating here."
    shared Rule everyCellHaveValueRule => (Predicate predicate) => expand(allCells().filter(predicate)).every((cell) => cell.symbol exists);

    "Default gameplay rules for Sudoku are
     1.- Do not repeat any symbol on a single slice.
     2.- Do not repeat any symbon on an hipercube."
    shared Set<Rule> defaultGamePlayRules => unmodifiableSet(HashSet {
        elements = { noRepeatOnSlicesRule, noRepeatOnHipercubesRule };
    });
    "Default gameover rules (definition of solved) for Sudoku are
     1.- Do not repeat any symbol on a single slice.
     2.- Do not repeat any symbon on an hipercube.
     3.- All cells have a valid symbol."
    shared Set<Rule> defaultGameOverRules => unmodifiableSet(HashSet {
        elements = { everyCellHaveValueRule, noRepeatOnSlicesRule, noRepeatOnHipercubesRule };
    });


}





