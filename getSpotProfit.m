function resProfit = getSpotProfit(dateBegin, dateEnd, paraM)
%GETSPOTPROFIT 输入参数：
% 这个函数对于不同品种来说需要单独更新，因为每个产业链利润公式不一样
totalDate = evalin('base', 'totalDate');
totalDate = array2table(totalDate, 'VariableNames', {'Date'});
% 比如现在要做PP - 3MA - 800的现货利润Y序列
% 现货成品价格 PP 的现货价格需要再筛选，满足交割标准，不同地区差异较大，暂定用Wind主页显示的齐鲁石化价格T36F
priceProduct = getSpotPrice('S5431209', dateBegin, dateEnd, 'PricePP', 'mean');
% 现货数据里面可能有非交易数据，这里需要做一个筛选日期处理
priceProduct = outerjoin(totalDate, priceProduct, 'type', 'left', 'MergeKeys', true);

% 现货原料价格
% 甲醇华东、华南两地基本一样，华北略低，三者趋势一致
priceMaterial = getSpotPrice('S5422062,S5422065,S5422037', dateBegin, dateEnd, 'PriceMA', 'mean');
priceMaterial = outerjoin(totalDate, priceMaterial, 'type', 'left', 'MergeKeys', true);

resProfit = outerjoin(priceProduct, priceMaterial, 'type', 'left', 'MergeKeys', true);

resProfit.Profit = resProfit.PricePP - 1 / paraM.rate * resProfit.PriceMA - paraM.fixedExpense;

resProfit.PricePP = [];
resProfit.PriceMA = [];
end

