cd E:\Repository\arbitrage_base_general
addpath public newSystem3.0\gen_for_BT2 newSystem3.0 usual_function

% 从J JM扩展到通用型两个品种
% 以MA-PP为例 PP - 3 * MA - 800

% @2018.12.12修改利润中枢为每天变动，目前这种思路不适合改成每天变动，否则出来会是总体平的，偶尔大起大落，不适合作为轨线
% @2018.12.17修改利润中枢为每天判断，但只有连续10日判断中枢都发生了变动时才确定中枢变动(因为基本面上的利润中枢上下移动不是一个超短期现象)
% @2018.12.17自变量要提前一天，用今天的自变量去预测明天的中枢

% @2018.12.17另外可以人工贴标签，自动训练模型参数，人工调超参数
% @2018.12.18人工贴利润中枢上移，下移，或者不动的标签可靠吗？其实是可以的，因为事后回过头来看，大家都知道变了
% 关键是事前准确判断接下来会变，那有了事后的标签和事前的自变量，我们可以训练模型去做这个判断
% 那现在还有个问题就是，自变量和因变量的时间错位窗口怎么定
% @2018.12.19放弃现货数据做自变量的模型，现货数据根本不影响利润中枢，那制作宏观条件的话，数据点就很少，根本用不上模型

% PP开工率同比； 甲醇港口库存每周四更新；甲醇中国主港现货价每天更新(甲醇价格在下午5点还没更新)；

%% 数据参数
if_reverse = true; % 默认输入的fut_variety = {'J','JM'}按照成品-原料的顺序，
% 如果\\Cj-lmxue-dt\期货数据2.0\pairData的数据也是按照成品-原料的顺序，则if_reverse = FALSE
% 否则，if_reverse = TRUE，输入fut_variety后，读取数据的地址要把品种名称倒一下
% J-JM是false， PP-MA是true

% 回测数据地址
% J-JM 地址
% btDataPath = 'E:\Repository\hedge\backtestData\strategyPCA\'; % backtestDataPath 每个品种对的回测数据地址不一样
% PP-MA 地址
btDataPath = 'E:\Repository\arbitrage_base_general\backtestData\';

% 品种
fut_variety = {'PP','MA'};
% 利润中枢
profitPivot = 500; % PP-MA暂取500， J-JM暂取-800

%% 交易参数
paraM.rate = 1 / 3; %%这个rate一定要注意。。不要随便改成1.35！改的话calOpenHands一定要跟着改！！每次结果要检查一下手数比对不对！！
paraM.fixedExpense = 800;
% paraM.continuousDay = 10;
% PP/MA 手数 = 1 / 1.5

% testRes = nan(13, 9);
% % testRegressR2 = nan(3, 50);
% % seq = [20130201 20170929;...
% %     20140101 20141231;...
% %     20150101 20151231;...
% %     20160101 20161230;...
% %     20170101 20170929];
% seq = 500 : 20 : 660;
% for iTest = 1 : 9

% dateBegin 到 dateEnd是训练集和验证集
dateBegin = 20130201;
dateEnd = 20170630;
% dateBegin = seq(iTest, 1); % 训练
% dateEnd = seq(iTest, 2); % 训练 % c_edD必须是交易日，不然totaldate里面定位不到
% dateBegin = 20170701; % 验证
% dateEnd = 20180330; % 验证
% dateBegin = 20180101; % 测试
% dateEnd = 20181029; % 测试


%%%%%%%%%%%%%%%%3个关键参数：%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% paraM.proportion = 0.98; % MA与预测利润加权平均，MA所占的比例
% paraM.xMA = 12; % MA天数
% paraM.hgChg = -300; % -340~-240结果都还可以, -260效果最好，但是不确定是否稳定
% 宏观条件变化应有上浮和下浮两种情况啊（上有顶，下有底）
paraM.interval = 550; % J-JM暂取100， PP-MA暂取500
% paraM.lagDays = 30; % 2018.12.18修改lagDays的含义，当前lagDays表示解释变量相对于被解释变量的提前天数
%%%%%%%%%%%%%%%%3个关键参数 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lossRatio = 0.5; % 止损上限


%% 取回测期全部交易日

load Z:\baseData\Tdays\future\Tdays_dly.mat
% totalDate = Tdays(Tdays(:, 1) >= dateBegin & Tdays(:, 1) <= dateEnd, 1);
totalDate = Tdays(Tdays(:, 1) <= dateEnd, 1); % 分段测试用，避免前面有空值

%% 模拟现货利润数据

% w = windmatlab;
% 现货利润数据搞一个函数，其中各序列价格设为子函数，最终输出现货利润Y序列 现货利润数据在模型没用，只是画出来看看
% profit = getSpotProfit(dateBegin, dateEnd, paraM);
% 后面没有再用到现货利润数据了，只是前期画图用
% 准确的说getSpotPrice应该取名叫getWindData

% % @12.4 这里获取现货数据，先都填充为日度fillToDaily，再计算周环比或者年同比等getWoW getYoY；
% productionPPYoY = getSpotPrice('S0027180', 20130201, dateEnd, 'ProductYoYPP', 'mean'); % PP开工率当月同比
% productionPPYoY = fillToDaily(productionPPYoY, totalDate, 1); % 填充为日度数据，滞后调整1个工作日
% % productionPPYoY 已经是同比数据，不需要再计算增长率
% % Wind这个产量数据是月度的，4月底公布4月份的产量数据，那其实productionPPYoY滞后很严重！
% % 但为什么日度的PP开工率与PP Fut Price相关性很低，反而不如这个严重滞后的产量数据？
%
%
% % @12.7 PP 开工率的日度数据（卓创资讯，东证期货），跟期货价格的相关性很低。。但感觉应该有用啊
%
% % @12.10 加入进口量构造总供应量
% % 产量和进口量都用当月数值，再计算当月同比或环比
% % 月度数据频率会不会太低了？
% % 国内产量：
% % productionDom = getSpotPrice('S0027179', 20130201, dateEnd, 'ProductionDom', 'mean');
% % % 产量要先做一个特殊处理，2014年之后2月份一般没有当月值，如果公布了当月值其实是1、2月份累计，需要额外处理一下
% % % 2016.02.29公布的数据是两个月合计，历史数据只有这一天是异常的，先手动处理一下...
% % productionDom(productionDom.Date == 20160229, 'ProductionDom') = table(NaN);
% % productionDom = fillToDaily(productionDom, totalDate, 1);
% %
% % % 进口量：
% % % 大商所PP对应的交割标的是窄带类均聚聚丙烯,203年以来均聚级和共聚级的进口数量趋势还挺不一样的，且数量级相差和很大，基本都是均聚级，其实用总数或者均聚趋势基本完全一样
% % importation = getSpotPrice('S5401023', 20130201, dateEnd, 'Importation', 'mean'); % 万吨
% % importation = fillToDaily(importation, totalDate, 1);
% % supplyPP = outerjoin(productionDom, importation, 'type', 'left', 'Mergekeys', true);
% % supplyPP.SupplyPP = supplyPP.ProductionDom + supplyPP.Importation;
% % supplyPP = supplyPP(:, [1, 4]);
% %
% % supplyPP = getYoY(supplyPP, 'daily'); % 月度数据应该有一个月度环比的函数
%
%
% harborStoreMA = getSpotPrice('S5436526,S5436527', 20130201, dateEnd, 'HarborStoreMA', 'sum'); % MA港口库存
% %2018.11.30 这里MA港口库存再加一个变量是进口数量，加起来作为甲醇供给量（变量到底怎么选，再研究一下）
% %@2018.12.3harborStoreMA 改为周度环比增长率
% harborStoreMA = fillToDaily(harborStoreMA, totalDate, 1);
%
% % 计算WoW或者YoY
% harborStoreMA = getWoW(harborStoreMA, 'daily');
% harborStoreMA = table(harborStoreMA.Date, harborStoreMA.WoW, 'VariableNames', {'Date', 'HarborStoreMA'});
%
% % 读取宏观PMI
% pmi = getSpotPrice('M0017126', 20130201, dateEnd, 'PMI', 'mean');
% pmi = fillToDaily(pmi, totalDate, 1);
% % pmi指数一般当月月底国家统计局就公布，不知道Wind收录会不会滞后，假定滞后1个交易日
%
%
% % get impMAPrice，美元计价，需乘以汇率
% % 先填充为日度数据，这个价格数据不需要滞后，一般当天收盘可拿到
% impMAPrice = getSpotPrice('S5416976', 20130201, dateEnd, 'ImpMAPrice', 'mean');  % MA进口价格:美元
% exUSDCNY = getSpotPrice('M0000185', 20130201, dateEnd, 'USDCNY', 'mean');
% impMAPrice = outerjoin(impMAPrice, exUSDCNY, 'type', 'left', 'MergeKeys', true);
% impMAPrice.USDCNY = fillmissing(impMAPrice.USDCNY, 'previous');
% impMAPrice.ImpMAPrice = impMAPrice.ImpMAPrice .* impMAPrice.USDCNY;
% impMAPrice.USDCNY = [];
%
% % 2018.12.6 注意，虽然impMAPrice这个数据本身就是daily的，也要做fillToDaily操作，因为它可能确实某些交易日数据
% % 相当于每个变量自己要先填补全，再汇总到一起，因为最后汇总完没有再fillmissing了，所以要保证每个变量自己是全的，不然有缺失数据会被踢掉
% impMAPrice = fillToDaily(impMAPrice, totalDate, 0);
%
% % @2018.12.3 impMAPrice先改为周度环比试一下
% impMAPrice = getWoW(impMAPrice, 'daily');
% impMAPrice = table(impMAPrice.Date, impMAPrice.WoW, 'VariableNames', {'Date', 'ImpMAPrice'});
%
% spotData = outerjoin(table(totalDate, 'VariableNames', {'Date'}), productionPPYoY, 'type', 'left', 'MergeKeys', true);
% spotData = outerjoin(spotData, harborStoreMA, 'type', 'left', 'MergeKeys', true);
% spotData = outerjoin(spotData, impMAPrice, 'type', 'left', 'MergeKeys', true);
% spotData = outerjoin(spotData, pmi, 'type', 'left', 'MergeKeys', true);

% 每个数据自己先fillmissing了，不要等到最后，因为前面需要计算WoW或YoY
% spotData.ProductYoYPP = fillmissing(spotData.ProductYoYPP, 'previous');
% spotData.HarborStoreMA = fillmissing(spotData.HarborStoreMA, 'previous');
% spotData.ImpMAPrice = fillmissing(spotData.ImpMAPrice, 'previous');
% spotData.PMI = fillmissing(spotData.PMI, 'previous');

% 剔除缺失值
% @12.6 好像没有必要剔除缺失值？最开始有的缺失有的不确实的其实可以不剔
% 只是恰好因为PP品种上市在2014年2月，前面2013年的都剔了没关系，本来也没用，如果不是这样的话不应该剔，不完整的现货数据也是可以用的
% spotData = spotData(all(~isnan(table2array(spotData)), 2), :);

% spotData = spotData(spotData.Date >= dateBegin & spotData.Date <= dateEnd, :);


%% 尝试以期货价差与现货价差均值作为真实价差，逻辑是，PP-MA这组，期货价差和现货价差大概率还是倾向于收敛的
%% 真实价差有时候偏向期货，现货跟着期货走，有时候偏向现货，期货调整到现货，那中间位置的均值就是一个比较中性的状态，先试试看

% 获取期货价格数据

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
    if if_reverse == false
        dataPath = [sigDPath,'\',pFut1,'_',pFut2];
    else
        dataPath = [sigDPath,'\',pFut2,'_',pFut1];
    end
    % 合约乘数
    contM1 = cont_multi{ismember(cont_multi(:,1),pFut1),2};
    contM2 = cont_multi{ismember(cont_multi(:,1),pFut2),2};
    
    % 导入换月日数据
    if if_reverse == false
        load(['\\Cj-lmxue-dt\期货数据2.0\code2.0\data20_pair_data\chgInfo\',pFut1,'_',pFut2,'.mat'])
    else
        load(['\\Cj-lmxue-dt\期货数据2.0\code2.0\data20_pair_data\chgInfo\',pFut2,'_',pFut1,'.mat'])
        
    end
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
        
        if if_reverse == false
            contNum1 = 2;
            contNum2 = 3;
        else
            contNum1 = 3;
            contNum2 = 2;
        end
        
        cont1 = regexp(chgInfo{c,contNum1}{1},'\w*(?=\.)','match'); % 成品
        cont2 = regexp(chgInfo{c,contNum2}{1},'\w*(?=\.)','match'); % 原料
        clear contNum1 contNum2
        
        % 导入数据
        data1 = getData([dataPath,'\',pFut1,'\',cont1{1},'.mat'],edDate);
        data2 = getData([dataPath,'\',pFut2,'\',cont2{1},'.mat'],edDate);
        
        spreadData1 = table(data1.date, data1.close, 'VariableNames', {'Date', 'Close1'});
        spreadData2 = table(data2.date, data2.close, 'VariableNames', {'Date', 'Close2'});
        spread = outerjoin(spreadData1, spreadData2, 'type', 'left', 'MergeKeys', true);
        spread.Spread = spread.Close1 - 1 / paraM.rate * spread.Close2 - paraM.fixedExpense;
        %         tstData = vertcat(tstData, resSignal(resSignal.Date >= c_stD & resSignal.Date <= c_edD, :));
        %         spread = outerjoin(spread, spotData, 'type', 'left', 'MergeKeys', true);
        %
        %         realSpread = table2array(rowfun(@(x, y, z, hg) getRealSpread(x, y, z, hg), spread(:, 5:8)));
        %         realSpread = table2array(rowfun(@(x, y, z, hg) getRealSpread(x, y, z, hg), spread(1 : paraM.lagDays, 5:8)));
        % realSpread做处理，处理逻辑：初始值用第一天中枢，往下直到遇到第一个连续10天的作为新中枢
        % originalKey 取上一个合约在今天时候的中枢（上市第一个合约就用第一个值）
        % 用c = 1作为是不是初始合约，分段交叉验证也都是从初始开始
        %         if c == 1
        %             originalKey = realSpread(1);
        %         else
        %             originalKey = lastRealSpread(lastRealSpread.Date == spread.Date(1), 2).RealSpread;
        %         end
        %         realSpread = realSTransform(realSpread, originalKey, paraM.continuousDay);
        
        realSpread = ones(size(spread, 1), 1) * profitPivot;
        
        % rowfun输入的function参数必须一一对应，不能括号里显示只有一个参数，实际输入有两列，不行
        %         keySpread = mode(realSpread); % 取前paraM.lagDays天给出利润中枢的众数作为接下来的base中枢
        %         realSpread = [nan(paraM.lagDays, 1); ones(size(spread, 1) - paraM.lagDays, 1) .* keySpread];
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
        
        lastRealSpread = realSpread;
        clear realSpread
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

% % subplot(2, 3, iTest)
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
