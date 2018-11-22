cd E:\Repository\arbitrage_base_general
addpath public newSystem3.0\gen_for_BT2 newSystem3.0 usual_function 

% 从J JM扩展到通用型两个品种
% 以MA-PP为例 PP - 3 * MA - 800


dateBegin = 20130302; % 训练
dateEnd = 20170929; % 训练 % c_edD必须是交易日，不然totaldate里面定位不到
% dateBegin = 20170701; % 验证
% dateEnd = 20180330; % 验证
% dateBegin = 20180101; % 测试
% dateEnd = 20181029; % 测试

% 交易参数
paraM.rate = 1 / 3; %%这个rate一定要注意。。不要随便改成1.35！改的话calOpenHands一定要跟着改！！每次结果要检查一下手数比对不对！！
paraM.fixedExpense = 800;
% seq =  100 : 100 : 1500;

% testRes = nan(13, 21);
% testRegressR2 = nan(3, 50);
% seq = 910 : 1 : 930; % interval取500以下收益回撤比都是负的, 1000效果最好但不稳健
% for iTest = 1 : 21

%%%%%%%%%%%%%%%%3个关键参数：%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% paraM.proportion = 0.98; % MA与预测利润加权平均，MA所占的比例
% paraM.xMA = 12; % MA天数
paraM.interval = 920;
%%%%%%%%%%%%%%%%3个关键参数 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lossRatio = 0.5; % 止损上限
% alpha = 0.35; % 回归系数的置信区间 1 - α

% nLag= 10; % nLag取10以上的话会导致realY明显提前于Spread，9-10左右二者比较同步


%% 取回测期全部交易日

load Z:\baseData\Tdays\future\Tdays_dly.mat
totalDate = Tdays(Tdays(:, 1) >= dateBegin & Tdays(:, 1) <= dateEnd, 1);

% 现货利润数据搞一个函数，其中各序列价格设为子函数，最终输出现货利润Y序列
%% 模拟现货利润数据

% 焦炭现货价格：车板价
w = windmatlab;
profit = getSpotProfit(dateBegin, dateEnd, paraM);
productionPPYoY = getSpotPrice('S0027180', dateBegin, dateEnd, 'ProductYoYPP', 'mean');
harborStoreMA = getSpotPrice('S5436526,S5436527', dateBegin, dateEnd, 'HarborStoreMA', 'sum');

spotData = outerjoin(profit, productionPPYoY, 'type', 'left', 'MergeKeys', true);
spotData = outerjoin(spotData, harborStoreMA, 'type', 'left', 'MergeKeys', true);

spotData.ProductYoYPP = fillmissing(spotData.ProductYoYPP, 'previous');
spotData.HarborStoreMA = fillmissing(spotData.HarborStoreMA, 'previous');

% 剔除缺失值
spotData = spotData(all(~isnan(table2array(spotData)), 2), :);
spotData.Ratio = spotData.ProductYoYPP ./ spotData.HarborStoreMA; % 这个Ratio直接除有量纲问题。。需要调整




%% 当天收盘价与当天真实价格比较

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
%         realSpread = table(spread.Date, (spread.Spread  +  spread.Profit) / 2, 'VariableNames', {'Date', 'RealSpread'});
        realSpread = arrayfun(@(x) getRealSpread(x), spread.Ratio(1:30));
        keySpread = mode(realSpread);
        realSpread = [nan(30, 1); ones(size(spread, 1) - 30, 1) .* keySpread];
        realSpread = table(spread.Date, realSpread, 'VariableNames', {'Date', 'RealSpread'});
        [sigOpen, sigClose, resSignal] = getSignal(data1, data2, realSpread, paraM);
        sig = [sigOpen,sigClose];

        if c < height(chgInfo)
        catSpread = spread(spread.Date >= chgInfo.date(c) & spread.Date < chgInfo.date(c + 1), :);
        else
            catSpread = spread(spread.Date >= chgInfo.date(c), :);
        end
        tstData = vertcat(tstData, catSpread);
        
        subplot(3, 4, c)
%         plot(datenum(num2str(spread.Date), 'yyyymmdd'), spread.Spread, 'DisplayName', '期货') % 实际期货价差:蓝线 
        plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.Spread)        
        title(data1.fut(1))
        hold on
        plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.RealSpread) % 中枢
        plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.SpreadUp) % 上轨
        plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.SpreadDown) % 下轨
        if c == 1
        legend('期货', '中枢', '上轨', '下轨', 'Location', 'best')
        end
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
        datetick('x', 'yyyymmdd', 'keepticks', 'keeplimits')
        
      
        
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


figure
% 净值曲线
dn = datenum(num2str(BacktestResult.nv(:, 1)), 'yyyymmdd');
plot(dn, (oriAsset + BacktestResult.nv(:, 2)) ./ oriAsset)
datetick('x', 'yyyymmdd', 'keeplimits')

BacktestAnalysis = CTAAnalysis_GeneralPlatform_2(BacktestResult);
% testRes(:, iTest) = cellfun(@(x) double(x), BacktestAnalysis(:, 2));
% testRegressR2(:, iTest) = mean(regressR2, 'omitnan')';
% end
% plot(datenum(num2str(tstData.Date), 'yyyymmdd'), tstData.Spread - 150) % 真实Y，利润，现货-现货， 红线
% hold on
% plot(datenum(num2str(tstData.Date), 'yyyymmdd'), tstData.YReal) % 真实Y，利润，现货-现货， 红线
% datetick('x', 'yyyymmdd', 'keepticks', 'keeplimits')
