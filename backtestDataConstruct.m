% 需要的列：Date, Close, Open, Settle, High, Low, adjFactor, mainCont（实际不一定是什么Cont）
% 替代futureData
% 构造PP的futureData回测数据
fut = 'PP';
futureData = struct;

contName1 = res.Cont1;
contName1 = regexp(contName1, '\d*', 'match');
contName1 = cellfun(@(x) str2double(x), contName1);

futureData.Date = res.Date;
futureData.mainCont = contName1; % 是实际交易的合约，和主力合约不重合，只是为了输入回测平台方便所以命名为主力合约
% futureData.Close = res.Close1;

futureData.Close = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Close'), res.Date, contName1);
futureData.Open = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Open'), res.Date, contName1);
futureData.Settle = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Settle'), res.Date, contName1);
futureData.High = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'High'), res.Date, contName1);
futureData.Low = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Low'), res.Date, contName1);


% res上面加上chgLabel
[~, la, ~] = intersect(res.Date, chgInfo.date);
res.ChgLabel = zeros(size(res, 1), 1);
res.ChgLabel(la) = 1;


% @2018.11.21修改adjFactor的计算方式，之前是错的，导致换月时候价格不对
% 漫雪构造adjFactor的逻辑不是把1全替换为上一个非1值，而是从头到当前连乘cumprod
adjFactor = [res.Date contName1 res.ChgLabel futureData.Open];
adjFactor(:, 5) = [adjFactor(1, 2); adjFactor(1:(end-1), 2)]; % 因为策略不会第一天就换月，所以把第一天填补上，或者回头把getprice改一下，输入NaN的话输出NaN
adjFactor(:, 6) = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Open'), adjFactor(:, 1), adjFactor(:, 5));%前一天合约在今天的开盘价
adjFactor(:, 7) = adjFactor(:, 6) ./ adjFactor(:, 4);
adjFactor(:, 7) = cumprod(adjFactor(:, 7));
futureData.adjFactor = [adjFactor(:, 1) adjFactor(:, 7) adjFactor(:, 3)];

save('E:\Repository\arbitrage_base_general\backtestData\PP.mat', 'futureData')


% 构造MA的futureData回测数据
fut = 'MA';
futureData = struct;

contName2 = res.Cont2;
contName2 = regexp(contName2, '\d*', 'match');
contName2 = cellfun(@(x) str2double(x), contName2);

futureData.Date = res.Date;
futureData.mainCont = contName2; % 是实际交易的合约，和主力合约不重合，只是为了输入回测平台方便所以命名为主力合约
futureData.Close = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Close'), res.Date, contName2);
futureData.Open = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Open'), res.Date, contName2);
futureData.Settle = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Settle'), res.Date, contName2);
futureData.High = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'High'), res.Date, contName2);
futureData.Low = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Low'), res.Date, contName2);


adjFactor = [res.Date contName2 res.ChgLabel futureData.Open];
adjFactor(:, 5) = [adjFactor(1, 2); adjFactor(1:(end-1), 2)]; % 因为策略不会第一天就换月，所以把第一天填补上，或者回头把getprice改一下，输入NaN的话输出NaN
adjFactor(:, 6) = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Open'), adjFactor(:, 1), adjFactor(:, 5));%前一天合约在今天的开盘价
adjFactor(:, 7) = adjFactor(:, 6) ./ adjFactor(:, 4);
adjFactor(:, 7) = cumprod(adjFactor(:, 7));
futureData.adjFactor = [adjFactor(:, 1) adjFactor(:, 7) adjFactor(:, 3)];

save('E:\Repository\arbitrage_base_general\backtestData\MA.mat', 'futureData')
