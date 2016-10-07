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
shared alias SudokuRule => Boolean(SudokuBoard, SudokuPredicate);


"CellPredicates are used to filter the cells where rules should be applied.
 Is responsibility for the rule to decide between applying the rune to a single cell or to a spedcific type of CellSet. 
 Default predicate is `acceptAllPredicate`, meaning rule will be applied to all cells."
shared alias Predicate<GameType>
		given GameType satisfies Game
		 => Boolean({Cell<GameType>*});
shared alias SudokuPredicate => Predicate<Sudoku>;

/** Predicates **/
//Boolean({Cell<GameType>*}) _acceptAllPredicate given GameType satisfies Game => ({Cell<GameType>*} cellSet) => true;
Boolean acceptAllPredicate<GameType>({Cell<GameType>*} cellSet) given GameType satisfies Game => true;

"containsCellPredicate denotates that rule should be applied only to the provided cell, or to CellSets containing the provided cell."
//Predicate<Game> containsCellPredicate(Cell<Game> cell) => ({Cell<Game>*} cellSet) => cellSet.contains(cell); 
Boolean containsCellPredicate<GameType>(Cell<GameType> cell)({Cell<GameType>*} cellSet) given GameType satisfies Game => cellSet.contains(cell);

/** Rules **/
"Check that sudoku satisfies provided rules (every cell is checked)"
shared Boolean checkRules<GameType, BoardType, CellType>(BoardType sudoku, {Boolean(BoardType, Predicate<GameType>)*} rules)
		given GameType satisfies Game
		given CellType satisfies Cell<GameType>
		given BoardType satisfies Board<GameType, CellType>
		 => rules.every((rule) => rule(sudoku, acceptAllPredicate));

"Check that sudoku satisfies provided rules at the provided cell.
 Assumes cell belong to provided Sudoku. Else, 'true' is returned."
shared Boolean checkRulesOnCells<GameType, BoardType, CellType>(BoardType sudoku, Cell<GameType> cell, {Boolean(BoardType, Predicate<GameType>)*} rules) 
		given GameType satisfies Game
		given CellType satisfies Cell<GameType>
		given BoardType satisfies Board<GameType, CellType>
		=> rules.every((rule) => rule(sudoku, containsCellPredicate(cell)));
		
		
Boolean haveUniqueSymbols({SudokuCell*} cells) => cells.map((cell) => cell.symbol).frequencies().map((symbol -> count) => count).every((count) => count<2);

"Rule that validates all slices satisfying predicate have no diplicate symbols."
shared Boolean(SudokuBoard, SudokuPredicate) noRepeatOnSlicesRule => (SudokuBoard sudoku, SudokuPredicate predicate) => slices(sudoku).filter(predicate).every(haveUniqueSymbols);
"Rule that validates all hipercubes satisfying predicate have no diplicate symbols."
shared SudokuRule noRepeatOnHipercubesRule => (SudokuBoard sudoku, SudokuPredicate predicate) => hipercubes(sudoku).filter(predicate).every(haveUniqueSymbols);
"Rule that validates all cells satisfying predicate have a symbols.
 Note that themselves assert only valid symbols are set, so no use on validating here."
shared SudokuRule everyCellHaveValueRule => (SudokuBoard sudoku, SudokuPredicate predicate) => sudoku.cells.filter((SudokuCell element) => predicate([element])).every((SudokuCell cell) => (cell.symbol exists));

"Default gameplay rules for Sudoku are
 1.- Do not repeat any symbol on a single slice.
 2.- Do not repeat any symbon on an hipercube."
shared Set<SudokuRule> defaultGamePlayRules =  unmodifiableSet(HashSet { elements = { noRepeatOnSlicesRule, noRepeatOnHipercubesRule }; });
"Default gameover rules (definition of solved) for Sudoku are
 1.- Do not repeat any symbol on a single slice.
 2.- Do not repeat any symbon on an hipercube.
 3.- All cells have a valid symbol."
shared Set<SudokuRule> defaultGameOverRules = unmodifiableSet(HashSet { elements = { everyCellHaveValueRule, noRepeatOnSlicesRule, noRepeatOnHipercubesRule }; });




