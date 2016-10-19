import ceylon.collection {
    HashMap
}
import ceylon.language.meta.model {
    Function
}

shared abstract class Game<GameT>() of GameT
given GameT satisfies Game<GameT> {

    "Rules are boolean functions that can be applied to a set of cells. In other words, rules apply to a Cell Predicate
        There are two kind of rules:
        - Gameplay rules: Validate the current board is valid during gameplay.
        - Gameover rules: Validate the current board is complete (game over).
       "
    shared abstract class GameRule() {
        shared default Boolean check() => true;
    }

    " Check that game satisfies provided rules (every cell is checked) "

    shared formal {GameRule*} gamePlayRules;
    shared formal {GameRule*} gameOverRules;
    shared default Boolean checkGamePlayRules() => checkGameRules(gamePlayRules);
    shared default Boolean checkGameOverRules() => checkGameRules(gameOverRules);
    shared default Boolean checkGameRules({GameRule*} rules) => rules.every((rule) => rule.check());
}

"Cells are basic element of a game, where game status is held.
 Can be anything, an empty token, a Symbol holder or a Card Placeholder"
shared abstract class Cell() {}

shared abstract class BoardGame<BoardType,CellType>() extends Game<BoardGame<BoardType,CellType>>()
given CellType satisfies Cell
given BoardType satisfies Board<CellType>
{
    /** Predicates **/
    "CellPredicates are used to filter the cells where rules should be applied.
      Is responsibility for the rule to decide between applying the rune to a single cell or to a spedcific type of CellSet.
      Default predicate is `acceptAllPredicate`, meaning rule will be applied to all cells."
    shared alias Predicate => Boolean({CellType*});

    //shared Boolean acceptAllPredicate({CellType*} cellSet) => true;
    shared Predicate acceptAllPredicate => ({CellType*} cellSet) => true;
    "containsCellPredicate denotates that rule should be applied only to the provided cell, or to CellSets containing the provided cell."
    shared Boolean containsCellPredicate(CellType cell)({CellType*} cellSet) => cellSet.contains(cell);

    shared abstract class BoardGameRule() extends GameRule() {
        shared formal Boolean checkPredicate(Predicate predicate);
    }

    "Check that game satisfies provided rules at the provided cell.Assumes cell belong to provided Sudoku.Else, 'true' is returned."
    shared Boolean checkBoardGameRules(Predicate predicate, {GameRule*} rules) => rules.every((rule) => if (is BoardGameRule rule) then rule.checkPredicate(predicate) else rule.check());

    shared actual default Boolean checkGamePlayRules() => checkBoardGameRules(acceptAllPredicate, gamePlayRules);
    shared actual default Boolean checkGameOverRules() => checkBoardGameRules(acceptAllPredicate, gameOverRules);

}

"Tipical sudoku is bidimensional.Rules apply for 2 axis (1 D) and 1 square (2D) 3D sudoku rules are for 3 axis (x, y and z), 3 planes (2 D) and 1 box (3 D)"
shared abstract class Board<CellType>() given CellType satisfies Cell {

    shared late default [CellType*] cells;

    shared actual default String string => cells.string;

    "Splits are just a subset of cells satisfying a predicate."
    shared alias Split => {{CellType*}*};
}

"Size is the lenght of an edge for the Sudoku.
    Dimension means the number of coordinates (dimensions) the Sudoku is composed of.
    Size should be an exponent for the dimension.
    Tipical Sudoku is size 9, dimension 2.
    3D Sudoku is size 27, dimension 3."
shared abstract class CartesianBoard<CellType>(shared Integer size, shared Integer dimension) extends Board<CellType>()
given CellType satisfies Cell {
    " Sudoku size
        shoud be at least 2 "
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

    shared default Map<[Integer+],CellType> cellMap => mapCellsToCoords(cells, allCoordsRec);

    " Return a * mutable * cell, given coordinates inside the sudoku."
    shared default CellType? cellAt([Integer+] coords) => cellMap.get(coords);

    shared actual default String string => cellMap.string;
}