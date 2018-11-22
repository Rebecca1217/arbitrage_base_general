# arbitrage_base_general
arbitrage_base strategy using fundamental methods, written in a general variableName.(PP-MA varieties as example)
- use pure fundamental logic, not including statistical methods(like Bollinger bands or MA etc.)
- write in general variable names(like close1, close2, instead of closePP, closeMA), which can be applied on every pair containing 2 varieties in an industrial chain(Later on it should be expanded to 3 varieties(A-BO-M).
- @2018.11.21 fixed the adjFactor problem in backtestDataConstruct and make sure the backtest result is right.
- when using the strategy, remember to check the lots(手数) of 2 varieties frequently to make sure your tading curve the same as your signal curve.
