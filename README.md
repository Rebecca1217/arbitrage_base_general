# arbitrage_base_general
arbitrage_base strategy using fundamental methods, written in a general variableName.(PP-MA varieties as example)
- use pure fundamental logic, not including statistical methods(like Bollinger bands or MA etc.)
- write in general variable names(like close1, close2, instead of closePP, closeMA), which can be applied on every pair containing 2 varieties in an industrial chain(Later on it should be expanded to 3 varieties(A-BO-M).
- @2018.11.21 fixed the adjFactor problem in backtestDataConstruct and make sure the backtest result is right.
- when using the strategy, remember to check the lots(手数) of 2 varieties frequently to make sure your tading curve the same as your signal curve.
- @2018.12.4 improve the variable-to-ratio method with decision-tree method(not precisely the decision tree but just using its ideology). Why improve? Because combing variables to a composite ratio is difficult to explain the logic. While the decision-tree thought is most logical and the test result seems to be acceptable.
- @2018.12.4 add macro variable to the top of decision tree.
- @2018.12.4 should rewrite the decision tree to a parallel variables, decide, and vote form. Because you can't decide which variable most important and should be in the first place of the tree(correlation is not good enough to be precise and stable).
