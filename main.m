cd E:\Repository\arbitrage_base_general
addpath public newSystem3.0\gen_for_BT2 newSystem3.0 usual_function

% 从J JM扩展到通用型两个品种
% 以MA-PP为例 PP - 3 * MA - 800


% 交易参数
paraM.rate = 1 / 3; %%这个rate一定要注意。。不要随便改成1.35！改的话calOpenHands一定要跟着改！！每次结果要检查一下手数比对不对！！
paraM.fixedExpense = 800;

% testRes = nan(13, 5);
% % testRegressR2 = nan(3, 50);
% seq = [20130302 20170929;...
%     20140101 20141231;...
%     20150101 20151231;...
%     20160101 20161230;...
%     20170101 20170929];
% for iTest = 1 : 5

dateBegin = 20130302;
dateEnd = 20170929;
% dateBegin = seq(iTest, 1); % 训练
% dateEnd = seq(iTest, 2); % 训练 % c_edD必须是交易日，不然totaldate里面定位不到
% dateBegin = 20170701; % 验证
% dateEnd = 20180330; % 验证
% dateBegin = 20180101; % 测试
% dateEnd = 20181029; % 测试
   
    
paraM.hgChg = -300; % 效果好的很好，但是很不稳定, 600~ -100都还可以，其中-200不好, -100 和 -300 最好
%%%%%%%%%%%%%%%%3个关键参数：%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% paraM.proportion = 0.98; % MA与预测利润加权平均，MA所占的比例
% paraM.xMA = 12; % MA天数
paraM.interval = 1020; % 测试700~1400OK，1020~1160效果最好，
paraM.lagDays = 30; % 24-32效果最好，暂定取30
%%%%%%%%%%%%%%%%3个关键参数 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lossRatio = 0.5; % 止损上限
% alpha = 0.35; % 回归系数的置信区间 1 - α

% nLag= 10; % nLag取10以上的话会导致realY明显提前于Spread，9-10左右二者比较同步


%% 取回测期全部交易日

load Z:\baseData\Tdays\future\Tdays_dly.mat
% totalDate = Tdays(Tdays(:, 1) >= dateBegin & Tdays(:, 1) <= dateEnd, 1);
totalDate = Tdays(Tdays(:, 1) <= dateEnd, 1); % 分段测试用，避免前面有空值

% 现货利润数据搞一个函数，其中各序列价格设为子函数，最终输出现货利润Y序列 现货利润数据在模型没用，只是画出来看看
%% 模拟现货利润数据

w = windmatlab;
% profit = getSpotProfit(dateBegin, dateEnd, paraM); %
% 后面没有再用到现货利润数据了，只是前期画图用
% @12.4 这里获取现货数据，先都填充为日度fillToDaily，再计算周环比或者年同比等getWoW getYoY；
productionPPYoY = getSpotPrice('S0027180', 20130302, dateEnd, 'ProductYoYPP', 'mean'); % PP开工率当月同比
productionPPYoY = fillToDaily(productionPPYoY, totalDate, 1); % 填充为日度数据，滞后调整1个工作日
% productionPPYoY 已经是同比数据，不需要再计算增长率

harborStoreMA = getSpotPrice('S5436526,S5436527', 20130302, dateEnd, 'HarborStoreMA', 'sum'); % MA港口库存
%2018.11.30 这里MA港口库存再加一个变量是进口数量，加起来作为甲醇供给量（变量到底怎么选，再研究一下）
%@2018.12.3harborStoreMA 改为周度环比增长率
harborStoreMA = fillToDaily(harborStoreMA, totalDate, 1);

% 计算WoW或者YoY
harborStoreMA = getWoW(harborStoreMA, 'daily');
harborStoreMA = table(harborStoreMA.Date, harborStoreMA.WoW, 'VariableNames', {'Date', 'HarborStoreMA'});

% 读取宏观PMI
pmi = getSpotPrice('M0017126', 20130302, dateEnd, 'PMI', 'mean');
pmi = fillToDaily(pmi, totalDate, 1);
% pmi指数一般当月月底国家统计局就公布，不知道Wind收录会不会滞后，假定滞后1个交易日
% 

% get impMAPrice，美元计价，需乘以汇率
% 先填充为日度数据，这个价格数据不需要滞后，一般当天收盘可拿到
impMAPrice = getSpotPrice('S5416976', 20130302, dateEnd, 'ImpMAPrice', 'mean');  % MA进口价格:美元
exUSDCNY = getSpotPrice('M0000185', 20130302, dateEnd, 'USDCNY', 'mean');
impMAPrice = outerjoin(impMAPrice, exUSDCNY, 'type', 'left', 'MergeKeys', true);
impMAPrice.USDCNY = fillmissing(impMAPrice.USDCNY, 'previous');
impMAPrice.ImpMAPrice = impMAPrice.ImpMAPrice .* impMAPrice.USDCNY;
impMAPrice.USDCNY = [];

% 2018.12.6 注意，虽然impMAPrice这个数据本身就是daily的，也要做fillToDaily操作，因为它可能确实某些交易日数据
% 相当于每个变量自己要先填补全，再汇总到一起，因为最后汇总完没有再fillmissing了，所以要保证每个变量自己是全的，不然有缺失数据会被踢掉
impMAPrice = fillToDaily(impMAPrice, totalDate, 0);

% @2018.12.3 impMAPrice先改为周度环比试一下
impMAPrice = getWoW(impMAPrice, 'daily');
impMAPrice = table(impMAPrice.Date, impMAPrice.WoW, 'VariableNames', {'Date', 'ImpMAPrice'});

spotData = outerjoin(table(totalDate, 'VariableNames', {'Date'}), productionPPYoY, 'type', 'left', 'MergeKeys', true);
spotData = outerjoin(spotData, harborStoreMA, 'type', 'left', 'MergeKeys', true);
spotData = outerjoin(spotData, impMAPrice, 'type', 'left', 'MergeKeys', true);
spotData = outerjoin(spotData, pmi, 'type', 'left', 'MergeKeys', true);

% 每个数据自己先fillmissing了，不要等到最后，因为前面需要计算WoW或YoY
% spotData.ProductYoYPP = fillmissing(spotData.ProductYoYPP, 'previous');
% spotData.HarborStoreMA = fillmissing(spotData.HarborStoreMA, 'previous');
% spotData.ImpMAPrice = fillmissing(spotData.ImpMAPrice, 'previous');
% spotData.PMI = fillmissing(spotData.PMI, 'previous');

% 剔除缺失值
spotData = spotData(all(~isnan(table2array(spotData)), 2), :);

% spotData = spotData(spotData.Date >= dateBegin & spotData.Date <= dateEnd, :);


%% 尝试以期货价差与现货价差均值作为真实价差，逻辑是，PP-MA这组，期货价差和现货价差大概率还是倾向于收敛的
%% 真实价差有时候偏向期货，现货跟着期货走，有时候偏向现货，期货调整到现货，那中间位置的均值就是一个比较中性的状态，先试试看

% 获取期货价格数据
% 品种
fut_variety = {'PP','MA'};
% 信号相关
signalName = 'CTA1';
signalID = 101;

% paraM.jy
Cost.fix = 0; %固定成本
Cost.float = 2; %滑点
tradeP = 'open'; %交易价格
oriAsset = 10000000; %初始金额


% 数据相关
stDate = 0;
edDate = dateEnd; % 必须是交易日
load Z:\baseData\Tdays\future\Tdays_dly.mat
totaldate = Tdays(Tdays(:,1)>=stDate & Tdays(:,1)<=edDate,1);
sigDPath = '\\Cj-lmxue-dt\期货数据2.0\pairData';
% 添加路径
addpath(['gen_function\',signalName]);
% 导入数据
load \\Cj-lmxue-dt\期货数据2.0\usualData\minTickInfo.mat %品种最小变动价位
trade_unit = minTickInfo;
load(['\\Cj-lmxue-dt\期货数据2.0\usualData\PunitInfo\',num2str(totaldate(end)),'.mat']) %合约乘数
cont_multi = infoData;

proAsset = oriAsset;


for i_pair = 1:size(fut_variety,1)
    pFut1 = fut_variety{i_pair,1};
    pFut2 = fut_variety{i_pair,2};
    dataPath = [sigDPath,'\',pFut2,'_',pFut1];
    % 合约乘数
    contM1 = cont_multi{ismember(cont_multi(:,1),pFut1),2};
    contM2 = cont_multi{ismember(cont_multi(:,1),pFut2),2};
    
    % 导入换月日数据
    load(['\\Cj-lmxue-dt\期货数据2.0\code2.0\data20_pair_data\chgInfo\',pFut2,'_',pFut1,'.mat'])
    chgInfo = chgInfo(chgInfo.date>stDate & chgInfo.date<=edDate,:);
    
    % 生成信号-按合约循环
    res = totaldate(totaldate >= chgInfo.date(1));
    res = res(1 : (end - 1)); %不然最后一行是空值
    res = array2table([res, NaN(size(res, 1), 5)], 'VariableNames', {'Date', 'PosLabel', 'Hands1', 'Hands2', 'Cont1', 'Cont2'});
    res.Cont1 = num2cell(res.Cont1);
    res.Cont2 = num2cell(res.Cont2);
    tstData = table();
    
    for c = 1:height(chgInfo)
        c_stD = chgInfo.date(c); %该合约开始作为主力的日期
        if c~=height(chgInfo)
            c_edD = totaldate(find(totaldate==chgInfo.date(c+1),1)-1); %该合约作为主力的结束日期
        else %最后一段
            c_edD = totaldate(find(totaldate==edDate)-1);
        end
        cont1 = regexp(chgInfo{c,3}{1},'\w*(?=\.)','match'); % 成品
        cont2 = regexp(chgInfo{c,2}{1},'\w*(?=\.)','match'); % 原料
        % 导入数据
        data1 = getData([dataPath,'\',pFut1,'\',cont1{1},'.mat'],edDate);
        data2 = getData([dataPath,'\',pFut2,'\',cont2{1},'.mat'],edDate);
        
        spreadData1 = table(data1.date, data1.close, 'VariableNames', {'Date', 'Close1'});
        spreadData2 = table(data2.date, data2.close, 'VariableNames', {'Date', 'Close2'});
        spread = outerjoin(spreadData1, spreadData2, 'type', 'left', 'MergeKeys', true);
        spread.Spread = spread.Close1 - 1 / paraM.rate * spread.Close2 - paraM.fixedExpense;
        %         tstData = vertcat(tstData, resSignal(resSignal.Date >= c_stD & resSignal.Date <= c_edD, :));
        spread = outerjoin(spread, spotData, 'type', 'left', 'MergeKeys', true);
        
        realSpread = table2array(rowfun(@(x, y, z, hg) getRealSpread(x, y, z, hg), spread(1 : paraM.lagDays, 5:8)));
        % rowfun输入的function参数必须一一对应，不能括号里显示只有一个参数，实际输入有两列，不行
        keySpread = mode(realSpread); % 取前paraM.lagDays天给出利润中枢的众数作为接下来的base中枢
        realSpread = [nan(paraM.lagDays, 1); ones(size(spread, 1) - paraM.lagDays, 1) .* keySpread];
        realSpread = table(spread.Date, realSpread, 'VariableNames', {'Date', 'RealSpread'});
        [sigOpen, sigClose, resSignal] = getSignal(data1, data2, realSpread, paraM);
        sig = [sigOpen,sigClose];
        
        if c < height(chgInfo)
            catSpread = spread(spread.Date >= chgInfo.date(c) & spread.Date < chgInfo.date(c + 1), :);
        else
            catSpread = spread(spread.Date >= chgInfo.date(c), :);
        end
        tstData = vertcat(tstData, catSpread);
        
        subplot(3, 5, c)
        plot(datenum(num2str(spread.Date), 'yyyymmdd'), spread.Spread, 'DisplayName', '期货') % 实际期货价差:蓝线
        %         yyaxis left
        plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.Spread)
        title(data1.fut(1))
        hold on
        % %        plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.Close1) % PP
        % %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.Close2) % MA
        plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.RealSpread) % 中枢
        plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.SpreadUp) % 上轨
        plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.SpreadDown) % 下轨
        
        if c == 1
            legend('期货', '中枢', '上轨', '下轨', 'Location', 'best')
        end
        datetick('x', 'yyyymmdd', 'keepticks', 'keeplimits')
        
        %             %         yyaxis right
        %             %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), spread.Ratio) % Ratio
        %             %         ylim([-0.2, 0.8])
        %
        %
        %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.SpreadUp)
        %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.SpreadDown)
        % %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.YHat) % 拟合Y
        %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.YReal) % 真实Y，利润，现货-现货， 红线
        %
        % %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.YReal + interval)
        % %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.YReal - interval)
        % %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.JichaDiff) % 黄线
        % %          plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.SpreadTheory) % nLag天后的真实利润 + 基差的差（理想中的蓝线:紫线）
        
        
        
        
        % 以下为止损部分
        % 可以理解为对pureSig的一个修正，需要止损的部分就直接把持仓信号和手数改为0，并把持续几天不开仓都改为0即可（先没动）
        if strcmpi(tradeP,'open')
            tddata = [data1.open,data2.open];
        end
        tddata = [tddata,data1.close,data2.close];
        Cost.unit1 = trade_unit{ismember(trade_unit(:,1),pFut1),2};
        Cost.unit2 = trade_unit{ismember(trade_unit(:,1),pFut2),2};
        Cost.contM1 = contM1;
        Cost.contM2 = contM2;
        % pure_signal分为3个阶段，第二阶段为止损修改平仓信号，最后输出的pureSig已经是止损后的信号
        pureSig = pure_signal(sig, data1.date, tddata, c_stD, c_edD, oriAsset, data1, data2, paraM.rate*ones(size(sig,1),1), contM1, contM2, lossRatio, Cost);
        
        resI = array2table(pureSig, 'VariableNames', {'Date', 'PosLabel', 'Hands1', 'Hands2'});
        resI.Cont1 = repmat(cont1, size(pureSig, 1), 1);
        resI.Cont2 = repmat(cont2, size(pureSig, 1), 1);
        fromIdx = find(res.Date == c_stD);
        endIdx = find(res.Date == c_edD);
        res((fromIdx : endIdx), :) = resI(resI.Date >= c_stD & resI.Date <= c_edD, :);
    end
    
    
    %         plot(datenum(num2str(tstData.Date), 'yyyymmdd'), tstData.Spread)
    %         hold on
    %         plot(datenum(num2str(tstData.Date), 'yyyymmdd'), tstData.Profit)
    %         legend('期货', '现货', 'Location', 'best')
    %         datetick('x', 'yyyymmdd', 'keepticks', 'keeplimits')
    
end



res = res(res.Date >= dateBegin, :);
targetPortfolio = num2cell(NaN(size(res, 1), 2));   %分配内存
for iDate = 1:size(res, 1)
    hands = {char(res(iDate, :).Cont1), res(iDate, :).Hands1;...
        char(res(iDate, :).Cont2), res(iDate, :).Hands2};
    targetPortfolio{iDate, 1} = hands;
    targetPortfolio{iDate, 2} = res.Date(iDate);
end

% % getholdinghands部分不涉及换月日，因为是每段循环的，本部分内没有合约换月
% % 但是合约换月日要用于输入回测平台数据部分adjFactor
%
%
%
% TradePara用于输入回测平台
TradePara.futDataPath = '\\Cj-lmxue-dt\期货数据2.0\dlyData\主力合约'; %期货主力合约数据路径
TradePara.futUnitPath = '\\Cj-lmxue-dt\期货数据2.0\usualData\minTickInfo.mat'; %期货最小变动单位
TradePara.futMultiPath = '\\Cj-lmxue-dt\期货数据2.0\usualData\PunitInfo'; %期货合约乘数
TradePara.futLiquidPath = '\\Cj-lmxue-dt\期货数据2.0\usualData\liquidityInfo'; %期货品种流动性数据，用来筛选出活跃品种，剔除不活跃品种
TradePara.futSectorPath = '\\Cj-lmxue-dt\期货数据2.0\usualData\SectorInfo.mat'; %期货样本池数据，用来确定样本集对应的品种
TradePara.futMainContPath = '\\Cj-lmxue-dt\期货数据2.0\商品期货主力合约代码'; %主力合约代码
% TradePara.usualPath = '..\data\usualData';%基础通用数据 这个地址是哪里？
TradePara.usualPath = '\\Cj-lmxue-dt\期货数据2.0\usualData';
TradePara.fixC = 0.0000; %固定成本
TradePara.slip = 2; %滑点
TradePara.PType = 'open'; %交易价格，一般用open（开盘价）或者avg(日均价）


[BacktestResult,err] = CTABacktest_GeneralPlatform_3(targetPortfolio,TradePara);

% subplot(2, 3, iTest)
figure
% 净值曲线
dn = datenum(num2str(BacktestResult.nv(:, 1)), 'yyyymmdd');
plot(dn, (oriAsset + BacktestResult.nv(:, 2)) ./ oriAsset)
datetick('x', 'yyyymmdd', 'keepticks', 'keeplimits')

BacktestAnalysis = CTAAnalysis_GeneralPlatform_2(BacktestResult);
% testRes(:, iTest) = cellfun(@(x) double(x), BacktestAnalysis(:, 2));
% % testRegressR2(:, iTest) = mean(regressR2, 'omitnan')';
% end
% % plot(datenum(num2str(tstData.Date), 'yyyymmdd'), tstData.Spread - 150) % 真实Y，利润，现货-现货， 红线
% hold on
% plot(datenum(num2str(tstData.Date), 'yyyymmdd'), tstData.YReal) % 真实Y，利润，现货-现货， 红线
% datetick('x', 'yyyymmdd', 'keepticks', 'keeplimits')
%
%
% tst = table(spread.Date, spread.Close1, spread.Close2, spread.Spread, realSpread.RealSpread, realSpread.RealSpread - paraM.interval, realSpread.RealSpread + paraM.interval, ...
%     spread.ProductYoYPP, spread.HarborStoreMA, spread.ImpMAPrice, ...
%     'VariableNames', {'Date', 'PP', 'MA', 'Spread', 'RealSpread', 'RealDown', 'RealUp', 'ProductYoYPP', 'HarborStoreMA', 'ImpMAPrice'});
