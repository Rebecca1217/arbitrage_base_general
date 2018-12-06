cd E:\Repository\arbitrage_base_general
addpath public newSystem3.0\gen_for_BT2 newSystem3.0 usual_function

% ��J JM��չ��ͨ��������Ʒ��
% ��MA-PPΪ�� PP - 3 * MA - 800


% ���ײ���
paraM.rate = 1 / 3; %%���rateһ��Ҫע�⡣����Ҫ���ĳ�1.35���ĵĻ�calOpenHandsһ��Ҫ���Ÿģ���ÿ�ν��Ҫ���һ�������ȶԲ��ԣ���
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
% dateBegin = seq(iTest, 1); % ѵ��
% dateEnd = seq(iTest, 2); % ѵ�� % c_edD�����ǽ����գ���Ȼtotaldate���涨λ����
% dateBegin = 20170701; % ��֤
% dateEnd = 20180330; % ��֤
% dateBegin = 20180101; % ����
% dateEnd = 20181029; % ����
   
    
paraM.hgChg = -300; % Ч���õĺܺã����Ǻܲ��ȶ�, 600~ -100�������ԣ�����-200����, -100 �� -300 ���
%%%%%%%%%%%%%%%%3���ؼ�������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% paraM.proportion = 0.98; % MA��Ԥ�������Ȩƽ����MA��ռ�ı���
% paraM.xMA = 12; % MA����
paraM.interval = 1020; % ����700~1400OK��1020~1160Ч����ã�
paraM.lagDays = 30; % 24-32Ч����ã��ݶ�ȡ30
%%%%%%%%%%%%%%%%3���ؼ����� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lossRatio = 0.5; % ֹ������
% alpha = 0.35; % �ع�ϵ������������ 1 - ��

% nLag= 10; % nLagȡ10���ϵĻ��ᵼ��realY������ǰ��Spread��9-10���Ҷ��߱Ƚ�ͬ��


%% ȡ�ز���ȫ��������

load Z:\baseData\Tdays\future\Tdays_dly.mat
% totalDate = Tdays(Tdays(:, 1) >= dateBegin & Tdays(:, 1) <= dateEnd, 1);
totalDate = Tdays(Tdays(:, 1) <= dateEnd, 1); % �ֶβ����ã�����ǰ���п�ֵ

% �ֻ��������ݸ�һ�����������и����м۸���Ϊ�Ӻ�������������ֻ�����Y���� �ֻ�����������ģ��û�ã�ֻ�ǻ���������
%% ģ���ֻ���������

w = windmatlab;
% profit = getSpotProfit(dateBegin, dateEnd, paraM); %
% ����û�����õ��ֻ����������ˣ�ֻ��ǰ�ڻ�ͼ��
% @12.4 �����ȡ�ֻ����ݣ��ȶ����Ϊ�ն�fillToDaily���ټ����ܻ��Ȼ�����ͬ�ȵ�getWoW getYoY��
productionPPYoY = getSpotPrice('S0027180', 20130302, dateEnd, 'ProductYoYPP', 'mean'); % PP�����ʵ���ͬ��
productionPPYoY = fillToDaily(productionPPYoY, totalDate, 1); % ���Ϊ�ն����ݣ��ͺ����1��������
% productionPPYoY �Ѿ���ͬ�����ݣ�����Ҫ�ټ���������

harborStoreMA = getSpotPrice('S5436526,S5436527', 20130302, dateEnd, 'HarborStoreMA', 'sum'); % MA�ۿڿ��
%2018.11.30 ����MA�ۿڿ���ټ�һ�������ǽ�����������������Ϊ�״�������������������ôѡ�����о�һ�£�
%@2018.12.3harborStoreMA ��Ϊ�ܶȻ���������
harborStoreMA = fillToDaily(harborStoreMA, totalDate, 1);

% ����WoW����YoY
harborStoreMA = getWoW(harborStoreMA, 'daily');
harborStoreMA = table(harborStoreMA.Date, harborStoreMA.WoW, 'VariableNames', {'Date', 'HarborStoreMA'});

% ��ȡ���PMI
pmi = getSpotPrice('M0017126', 20130302, dateEnd, 'PMI', 'mean');
pmi = fillToDaily(pmi, totalDate, 1);
% pmiָ��һ�㵱���µ׹���ͳ�ƾ־͹�������֪��Wind��¼�᲻���ͺ󣬼ٶ��ͺ�1��������
% 

% get impMAPrice����Ԫ�Ƽۣ�����Ի���
% �����Ϊ�ն����ݣ�����۸����ݲ���Ҫ�ͺ�һ�㵱�����̿��õ�
impMAPrice = getSpotPrice('S5416976', 20130302, dateEnd, 'ImpMAPrice', 'mean');  % MA���ڼ۸�:��Ԫ
exUSDCNY = getSpotPrice('M0000185', 20130302, dateEnd, 'USDCNY', 'mean');
impMAPrice = outerjoin(impMAPrice, exUSDCNY, 'type', 'left', 'MergeKeys', true);
impMAPrice.USDCNY = fillmissing(impMAPrice.USDCNY, 'previous');
impMAPrice.ImpMAPrice = impMAPrice.ImpMAPrice .* impMAPrice.USDCNY;
impMAPrice.USDCNY = [];

% 2018.12.6 ע�⣬��ȻimpMAPrice������ݱ������daily�ģ�ҲҪ��fillToDaily��������Ϊ������ȷʵĳЩ����������
% �൱��ÿ�������Լ�Ҫ���ȫ���ٻ��ܵ�һ����Ϊ��������û����fillmissing�ˣ�����Ҫ��֤ÿ�������Լ���ȫ�ģ���Ȼ��ȱʧ���ݻᱻ�ߵ�
impMAPrice = fillToDaily(impMAPrice, totalDate, 0);

% @2018.12.3 impMAPrice�ȸ�Ϊ�ܶȻ�����һ��
impMAPrice = getWoW(impMAPrice, 'daily');
impMAPrice = table(impMAPrice.Date, impMAPrice.WoW, 'VariableNames', {'Date', 'ImpMAPrice'});

spotData = outerjoin(table(totalDate, 'VariableNames', {'Date'}), productionPPYoY, 'type', 'left', 'MergeKeys', true);
spotData = outerjoin(spotData, harborStoreMA, 'type', 'left', 'MergeKeys', true);
spotData = outerjoin(spotData, impMAPrice, 'type', 'left', 'MergeKeys', true);
spotData = outerjoin(spotData, pmi, 'type', 'left', 'MergeKeys', true);

% ÿ�������Լ���fillmissing�ˣ���Ҫ�ȵ������Ϊǰ����Ҫ����WoW��YoY
% spotData.ProductYoYPP = fillmissing(spotData.ProductYoYPP, 'previous');
% spotData.HarborStoreMA = fillmissing(spotData.HarborStoreMA, 'previous');
% spotData.ImpMAPrice = fillmissing(spotData.ImpMAPrice, 'previous');
% spotData.PMI = fillmissing(spotData.PMI, 'previous');

% �޳�ȱʧֵ
spotData = spotData(all(~isnan(table2array(spotData)), 2), :);

% spotData = spotData(spotData.Date >= dateBegin & spotData.Date <= dateEnd, :);


%% �������ڻ��۲����ֻ��۲��ֵ��Ϊ��ʵ�۲�߼��ǣ�PP-MA���飬�ڻ��۲���ֻ��۲����ʻ���������������
%% ��ʵ�۲���ʱ��ƫ���ڻ����ֻ������ڻ��ߣ���ʱ��ƫ���ֻ����ڻ��������ֻ������м�λ�õľ�ֵ����һ���Ƚ����Ե�״̬�������Կ�

% ��ȡ�ڻ��۸�����
% Ʒ��
fut_variety = {'PP','MA'};
% �ź����
signalName = 'CTA1';
signalID = 101;

% paraM.jy
Cost.fix = 0; %�̶��ɱ�
Cost.float = 2; %����
tradeP = 'open'; %���׼۸�
oriAsset = 10000000; %��ʼ���


% �������
stDate = 0;
edDate = dateEnd; % �����ǽ�����
load Z:\baseData\Tdays\future\Tdays_dly.mat
totaldate = Tdays(Tdays(:,1)>=stDate & Tdays(:,1)<=edDate,1);
sigDPath = '\\Cj-lmxue-dt\�ڻ�����2.0\pairData';
% ���·��
addpath(['gen_function\',signalName]);
% ��������
load \\Cj-lmxue-dt\�ڻ�����2.0\usualData\minTickInfo.mat %Ʒ����С�䶯��λ
trade_unit = minTickInfo;
load(['\\Cj-lmxue-dt\�ڻ�����2.0\usualData\PunitInfo\',num2str(totaldate(end)),'.mat']) %��Լ����
cont_multi = infoData;

proAsset = oriAsset;


for i_pair = 1:size(fut_variety,1)
    pFut1 = fut_variety{i_pair,1};
    pFut2 = fut_variety{i_pair,2};
    dataPath = [sigDPath,'\',pFut2,'_',pFut1];
    % ��Լ����
    contM1 = cont_multi{ismember(cont_multi(:,1),pFut1),2};
    contM2 = cont_multi{ismember(cont_multi(:,1),pFut2),2};
    
    % ���뻻��������
    load(['\\Cj-lmxue-dt\�ڻ�����2.0\code2.0\data20_pair_data\chgInfo\',pFut2,'_',pFut1,'.mat'])
    chgInfo = chgInfo(chgInfo.date>stDate & chgInfo.date<=edDate,:);
    
    % �����ź�-����Լѭ��
    res = totaldate(totaldate >= chgInfo.date(1));
    res = res(1 : (end - 1)); %��Ȼ���һ���ǿ�ֵ
    res = array2table([res, NaN(size(res, 1), 5)], 'VariableNames', {'Date', 'PosLabel', 'Hands1', 'Hands2', 'Cont1', 'Cont2'});
    res.Cont1 = num2cell(res.Cont1);
    res.Cont2 = num2cell(res.Cont2);
    tstData = table();
    
    for c = 1:height(chgInfo)
        c_stD = chgInfo.date(c); %�ú�Լ��ʼ��Ϊ����������
        if c~=height(chgInfo)
            c_edD = totaldate(find(totaldate==chgInfo.date(c+1),1)-1); %�ú�Լ��Ϊ�����Ľ�������
        else %���һ��
            c_edD = totaldate(find(totaldate==edDate)-1);
        end
        cont1 = regexp(chgInfo{c,3}{1},'\w*(?=\.)','match'); % ��Ʒ
        cont2 = regexp(chgInfo{c,2}{1},'\w*(?=\.)','match'); % ԭ��
        % ��������
        data1 = getData([dataPath,'\',pFut1,'\',cont1{1},'.mat'],edDate);
        data2 = getData([dataPath,'\',pFut2,'\',cont2{1},'.mat'],edDate);
        
        spreadData1 = table(data1.date, data1.close, 'VariableNames', {'Date', 'Close1'});
        spreadData2 = table(data2.date, data2.close, 'VariableNames', {'Date', 'Close2'});
        spread = outerjoin(spreadData1, spreadData2, 'type', 'left', 'MergeKeys', true);
        spread.Spread = spread.Close1 - 1 / paraM.rate * spread.Close2 - paraM.fixedExpense;
        %         tstData = vertcat(tstData, resSignal(resSignal.Date >= c_stD & resSignal.Date <= c_edD, :));
        spread = outerjoin(spread, spotData, 'type', 'left', 'MergeKeys', true);
        
        realSpread = table2array(rowfun(@(x, y, z, hg) getRealSpread(x, y, z, hg), spread(1 : paraM.lagDays, 5:8)));
        % rowfun�����function��������һһ��Ӧ��������������ʾֻ��һ��������ʵ�����������У�����
        keySpread = mode(realSpread); % ȡǰparaM.lagDays��������������������Ϊ��������base����
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
        plot(datenum(num2str(spread.Date), 'yyyymmdd'), spread.Spread, 'DisplayName', '�ڻ�') % ʵ���ڻ��۲�:����
        %         yyaxis left
        plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.Spread)
        title(data1.fut(1))
        hold on
        % %        plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.Close1) % PP
        % %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.Close2) % MA
        plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.RealSpread) % ����
        plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.SpreadUp) % �Ϲ�
        plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.SpreadDown) % �¹�
        
        if c == 1
            legend('�ڻ�', '����', '�Ϲ�', '�¹�', 'Location', 'best')
        end
        datetick('x', 'yyyymmdd', 'keepticks', 'keeplimits')
        
        %             %         yyaxis right
        %             %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), spread.Ratio) % Ratio
        %             %         ylim([-0.2, 0.8])
        %
        %
        %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.SpreadUp)
        %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.SpreadDown)
        % %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.YHat) % ���Y
        %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.YReal) % ��ʵY�������ֻ�-�ֻ��� ����
        %
        % %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.YReal + interval)
        % %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.YReal - interval)
        % %         plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.JichaDiff) % ����
        % %          plot(datenum(num2str(resSignal.Date), 'yyyymmdd'), resSignal.SpreadTheory) % nLag������ʵ���� + ����Ĳ�����е�����:���ߣ�
        
        
        
        
        % ����Ϊֹ�𲿷�
        % �������Ϊ��pureSig��һ����������Ҫֹ��Ĳ��־�ֱ�Ӱѳֲ��źź�������Ϊ0�����ѳ������첻���ֶ���Ϊ0���ɣ���û����
        if strcmpi(tradeP,'open')
            tddata = [data1.open,data2.open];
        end
        tddata = [tddata,data1.close,data2.close];
        Cost.unit1 = trade_unit{ismember(trade_unit(:,1),pFut1),2};
        Cost.unit2 = trade_unit{ismember(trade_unit(:,1),pFut2),2};
        Cost.contM1 = contM1;
        Cost.contM2 = contM2;
        % pure_signal��Ϊ3���׶Σ��ڶ��׶�Ϊֹ���޸�ƽ���źţ���������pureSig�Ѿ���ֹ�����ź�
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
    %         legend('�ڻ�', '�ֻ�', 'Location', 'best')
    %         datetick('x', 'yyyymmdd', 'keepticks', 'keeplimits')
    
end



res = res(res.Date >= dateBegin, :);
targetPortfolio = num2cell(NaN(size(res, 1), 2));   %�����ڴ�
for iDate = 1:size(res, 1)
    hands = {char(res(iDate, :).Cont1), res(iDate, :).Hands1;...
        char(res(iDate, :).Cont2), res(iDate, :).Hands2};
    targetPortfolio{iDate, 1} = hands;
    targetPortfolio{iDate, 2} = res.Date(iDate);
end

% % getholdinghands���ֲ��漰�����գ���Ϊ��ÿ��ѭ���ģ���������û�к�Լ����
% % ���Ǻ�Լ������Ҫ��������ز�ƽ̨���ݲ���adjFactor
%
%
%
% TradePara��������ز�ƽ̨
TradePara.futDataPath = '\\Cj-lmxue-dt\�ڻ�����2.0\dlyData\������Լ'; %�ڻ�������Լ����·��
TradePara.futUnitPath = '\\Cj-lmxue-dt\�ڻ�����2.0\usualData\minTickInfo.mat'; %�ڻ���С�䶯��λ
TradePara.futMultiPath = '\\Cj-lmxue-dt\�ڻ�����2.0\usualData\PunitInfo'; %�ڻ���Լ����
TradePara.futLiquidPath = '\\Cj-lmxue-dt\�ڻ�����2.0\usualData\liquidityInfo'; %�ڻ�Ʒ�����������ݣ�����ɸѡ����ԾƷ�֣��޳�����ԾƷ��
TradePara.futSectorPath = '\\Cj-lmxue-dt\�ڻ�����2.0\usualData\SectorInfo.mat'; %�ڻ����������ݣ�����ȷ����������Ӧ��Ʒ��
TradePara.futMainContPath = '\\Cj-lmxue-dt\�ڻ�����2.0\��Ʒ�ڻ�������Լ����'; %������Լ����
% TradePara.usualPath = '..\data\usualData';%����ͨ������ �����ַ�����
TradePara.usualPath = '\\Cj-lmxue-dt\�ڻ�����2.0\usualData';
TradePara.fixC = 0.0000; %�̶��ɱ�
TradePara.slip = 2; %����
TradePara.PType = 'open'; %���׼۸�һ����open�����̼ۣ�����avg(�վ��ۣ�


[BacktestResult,err] = CTABacktest_GeneralPlatform_3(targetPortfolio,TradePara);

% subplot(2, 3, iTest)
figure
% ��ֵ����
dn = datenum(num2str(BacktestResult.nv(:, 1)), 'yyyymmdd');
plot(dn, (oriAsset + BacktestResult.nv(:, 2)) ./ oriAsset)
datetick('x', 'yyyymmdd', 'keepticks', 'keeplimits')

BacktestAnalysis = CTAAnalysis_GeneralPlatform_2(BacktestResult);
% testRes(:, iTest) = cellfun(@(x) double(x), BacktestAnalysis(:, 2));
% % testRegressR2(:, iTest) = mean(regressR2, 'omitnan')';
% end
% % plot(datenum(num2str(tstData.Date), 'yyyymmdd'), tstData.Spread - 150) % ��ʵY�������ֻ�-�ֻ��� ����
% hold on
% plot(datenum(num2str(tstData.Date), 'yyyymmdd'), tstData.YReal) % ��ʵY�������ֻ�-�ֻ��� ����
% datetick('x', 'yyyymmdd', 'keepticks', 'keeplimits')
%
%
% tst = table(spread.Date, spread.Close1, spread.Close2, spread.Spread, realSpread.RealSpread, realSpread.RealSpread - paraM.interval, realSpread.RealSpread + paraM.interval, ...
%     spread.ProductYoYPP, spread.HarborStoreMA, spread.ImpMAPrice, ...
%     'VariableNames', {'Date', 'PP', 'MA', 'Spread', 'RealSpread', 'RealDown', 'RealUp', 'ProductYoYPP', 'HarborStoreMA', 'ImpMAPrice'});
