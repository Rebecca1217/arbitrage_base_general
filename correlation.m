% % regData.Profit是预测焦厂利润（日度）
% % 读取钢联焦厂利润周度数据
% % 用周度数据查看相关系数
% JProfit = readtable('C:\Users\fengruiling\Desktop\JJMdata\JProfit_bck.xlsx');
% JProfit.Properties.VariableNames = {'Date', 'JProfitData'};
% JProfit.Date = datestr(JProfit.Date, 'yyyymmdd');
% convertDate = table(JProfit.Date);
% JProfit.Date = table2array(rowfun(@(x) str2double(x), convertDate));
%
%
% projectedProfit = regData(:, 1:2);
%
% res = outerjoin(JProfit, projectedProfit, 'type', 'left', 'MergeKeys', true);
% res.Profit = fillmissing(res.Profit, 'previous');
%
% % 未用到插补，仅看周度数据的相关性 仍然是非常高的
% corr(res.JProfitData, res.Profit, 'Type', 'Pearson')
% corr(res.JProfitData(1:25), res.Profit(1:25), 'Type', 'Spearman')
% corr(res.JProfitData, res.Profit, 'Type', 'Kendall')
%


% 查看相关系数

% productYoYPP PP开工率同比
productYoYPP = spotData(:, [1 3]);
harborStoreMA = spotData(:, [1 4]);
MAPR = MAData(:, 1:2);
MAPR(:, 2) = fillmissing(MAPR(:, 2), 'previous');
MADSPR = MAData(:, [1 3]);
MADSPR(:, 2) = fillmissing(MADSPR(:, 2), 'previous');
impMAPrice = MAData(:, [1 4]);
impMAPrice(:, 2) = fillmissing(impMAPrice(:, 2), 'previous');


varSeq = {'productYoYPP', 'harborStoreMA', 'MAPR', 'MADSPR', 'impMAPrice'};

corrcoefTotal = NaN(height(chgInfo), length(varSeq));
for iVar = 1 : 5
str = ['compareData = ', varSeq{iVar}, ';'];
eval(str)
corrcoef = NaN(height(chgInfo), 1); % 每一段合约与spread的相关系数
for c = 1:height(chgInfo)
    cont1 = regexp(chgInfo{c,3}{1},'\w*(?=\.)','match'); % 成品
    cont2 = regexp(chgInfo{c,2}{1},'\w*(?=\.)','match'); % 原料
    % 导入数据
    data1 = getData([dataPath,'\',pFut1,'\',cont1{1},'.mat'],edDate);
    data2 = getData([dataPath,'\',pFut2,'\',cont2{1},'.mat'],edDate);
    
    spreadData1 = table(data1.date, data1.close, 'VariableNames', {'Date', 'Close1'});
    spreadData2 = table(data2.date, data2.close, 'VariableNames', {'Date', 'Close2'});
    spread = outerjoin(spreadData1, spreadData2, 'type', 'left', 'MergeKeys', true);
    spread.Spread = spread.Close1 - 1 / paraM.rate * spread.Close2 - paraM.fixedExpense;
    spread = outerjoin(spread, compareData, 'type', 'left', 'Mergekeys', true);
    spread(:, 5) = fillmissing(spread(:, 5), 'previous');
    
    corrcoef(c) = corr(table2array(spread(:, 4)), table2array(spread(:, 5)), 'Type', 'Pearson');
    % 为什么这个地方相关系数用pearson?因为spearman衡量单调性，pearson受极值影响大，
    % spread受多种因素交错影响，可能长期跟你这个变量逻辑上相关性是反的；但极值的时间段，正是你这个变量发挥较大影响力的阶段，
    % 是单变量力压其他变量影响，凸显其本身与spread关系方向性的阶段，所以这里选pearson
    % 注意：这样的相关性不能用来预测，以spread和impMAPrice在2016年11月之后剧烈波动反向相关为例，
    % 验证了二者负相关不能就直接用impMAPrice去预测spread变化，因为长期来看impMAPrice对spread的影响比较弱，其他因素影响占上风
    % 但是impMAPrice可以用来在决策树中作为一个枝
    
end

corrcoefTotal(:, iVar) = corrcoef;
end

% check 甲醇库存相关性不一致问题：

corrTest = NaN(size(aa, 1), 6) - 1;
for iN = 1 : size(aa, 1) - 1
corrFront = corr(aa(1 : iN), bb(1 : iN), 'type', 'spearman');
corrBack = corr(aa(iN + 1 : 224), bb(iN + 1 : 224), 'type', 'spearman');
corrTotal = corr(aa, bb, 'type', 'spearman');
spearman = [corrFront corrBack corrTotal];
corrTest(iN, 1:3) = spearman;
corrFront = corr(aa(1 : iN), bb(1 : iN), 'type', 'pearson');
corrBack = corr(aa(iN + 1 : 224), bb(iN + 1 : 224), 'type', 'pearson');
corrTotal = corr(aa, bb, 'type', 'pearson');
pearson = [corrFront corrBack corrTotal];
corrTest(iN, 4:6) = pearson;
end

% 加入哑变量回归看甲醇库存对甲醇价格影响是否显著,R2从0提升到0.74，Pvalue也从不显著变得特别显著
y = table2array(spread(:, 3));
dummy = [ones(127, 1); zeros(97, 1)];
x = [ones(size(spread, 1), 1) dummy table2array(spread(:, 5))];
% x = table2array(spread(:, 5));

[b, bint, r, rint, stats] = regress(y, x);
% b是回归系数，stats分别是R2， F值， P-value，误差方差

% 那你从逻辑上能解释甲醇库存在2014年12月中旬以后发生的什么事情导致趋势反转？
% APEC会议影响运输导致前期港口库存累积，国庆期间危化品车辆高速现行导致多地甲醇库存上升









