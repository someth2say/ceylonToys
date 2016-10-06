import ceylon.collection {
	HashSet,
	unmodifiableSet
}

"There are two kind of rules:
 - Gameplay rules: Validate the current board is valid during gameplay.
 - Gameover rules: Validate the current board is complete (game over). 
 
 Check if the all cell satisfy Sudoku rules. Default rules are:
 - All cells have a value.
 - No slice have repeated symbols
 - Every 1D (vector) division have no repeated symbols."

shared alias SudokuRule => Boolean(Sudoku, CellPredicate);

"CellPredicates are used to filter the cells where rules should be applied.
 Is responsibility for the rule to decide between applying the rune to a single cell or to a spedcific type of CellSet. 
 Default predicate is `acceptAllPredicate`, meaning rule will be applied to all cells."
shared alias CellPredicate => Boolean(Sudoku.CellSet);
CellPredicate acceptAllPredicate => (Sudoku.CellSet cellSet) => true;

"containsCellPredicate denotates that rule should be applied only to the provided cell, or to CellSets containing the provided cell."
CellPredicate containsCellPredicate(Sudoku.Cell cell) => (Sudoku.CellSet cellSet) => cellSet.contains(cell); 

"Check that sudoku satisfies provided rules (every cell is checked)"
shared Boolean checkRules(Sudoku sudoku, {SudokuRule*} rules) => rules.every((SudokuRule rule) => rule(sudoku, acceptAllPredicate));
"Check that sudoku satisfies provided rules at the provided cell.
 Assumes cell belong to provided Sudoku. Else, 'true' is returned."
shared Boolean checkRulesOnCells(Sudoku sudoku, Sudoku.Cell cell, {SudokuRule*} rules) => rules.every((SudokuRule rule) => rule(sudoku, containsCellPredicate(cell) ));
		
Boolean haveUniqueSymbols(Sudoku.CellSet cells) => cells.map((Sudoku.Cell cell) => cell.symbol).frequencies().map((Sudoku.Cell.Symbol symbol -> Integer count) => count).every((Integer count) => count<2);

"Rule that validates all slices satisfying predicate have no diplicate symbols."
shared SudokuRule noRepeatOnSlicesRule => (Sudoku sudoku, CellPredicate predicate) => sudoku.slices.filter(predicate).every(haveUniqueSymbols);
"Rule that validates all hipercubes satisfying predicate have no diplicate symbols."
shared SudokuRule noRepeatOnHipercubesRule => (Sudoku sudoku, CellPredicate predicate) => sudoku.hipercubes.filter(predicate).every(haveUniqueSymbols);
"Rule that validates all cells satisfying predicate have a symbols.
 Note that themselves assert only valid symbols are set, so no use on validating here."
shared SudokuRule everyCellHaveValueRule => (Sudoku sudoku, CellPredicate predicate) => sudoku.cells.filter((Sudoku.Cell element) => predicate([element])).every((Sudoku.Cell cell) => (cell.symbol exists));

"Default gameplay rules for Sudoku are
 1.- Do not repeat any symbol on a single slice.
 2.- Do not repeat any symbon on an hipercube."
shared Set<SudokuRule> defaultGamePlayRules =  unmodifiableSet(HashSet { elements = { noRepeatOnSlicesRule, noRepeatOnHipercubesRule }; });
"Default gameover rules (definition of solved) for Sudoku are
 1.- Do not repeat any symbol on a single slice.
 2.- Do not repeat any symbon on an hipercube.
 3.- All cells have a valid symbol."
shared Set<SudokuRule> defaultGameOverRules = unmodifiableSet(HashSet { elements = { everyCellHaveValueRule, noRepeatOnSlicesRule, noRepeatOnHipercubesRule }; });

