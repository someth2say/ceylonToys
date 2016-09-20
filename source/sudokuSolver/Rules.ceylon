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
shared Boolean checkRules(Sudoku sudoku, {SudokuRule*} rules) => rules.every((SudokuRule rule) => rule(sudoku));

shared alias SudokuRule => Boolean(Sudoku);
Boolean haveUniqueSymbols({Sudoku.Cell*} cells) => cells.map((Sudoku.Cell cell) => cell.symbol).frequencies().map((Sudoku.Cell.Symbol symbol -> Integer count) => count).every((Integer count) => count<2);
shared SudokuRule noRepeatOnVectorsRule => (Sudoku sudoku) => sudoku.slices.every(haveUniqueSymbols);
shared SudokuRule noRepeatOnSlicesRule => (Sudoku sudoku) => sudoku.hipercubes.every(haveUniqueSymbols);
shared SudokuRule everyCellHaveValueRule => (Sudoku sudoku) => sudoku.cells.every((Sudoku.Cell cell) => (cell.symbol exists));

shared Set<SudokuRule> defaultGamePlayRules =  unmodifiableSet(HashSet { elements = { noRepeatOnVectorsRule, noRepeatOnSlicesRule }; });
shared Set<SudokuRule> defaultGameOverRules = unmodifiableSet(HashSet { elements = { everyCellHaveValueRule, noRepeatOnVectorsRule, noRepeatOnSlicesRule }; });
