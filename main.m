cd E:\Repository\arbitrage_base_general
addpath public newSystem3.0\gen_for_BT2 newSystem3.0 usual_function

% ��J JM��չ��ͨ��������Ʒ��
% ��MA-PPΪ�� PP - 3 * MA - 800

% @2018.12.12�޸���������Ϊÿ��䶯��Ŀǰ����˼·���ʺϸĳ�ÿ��䶯�����������������ƽ�ģ�ż��������䣬���ʺ���Ϊ����
% @2018.12.17�޸���������Ϊÿ���жϣ���ֻ������10���ж����඼�����˱䶯ʱ��ȷ������䶯(��Ϊ�������ϵ��������������ƶ�����һ������������)
% @2018.12.17�Ա���Ҫ��ǰһ�죬�ý�����Ա���ȥԤ�����������

% @2018.12.17��������˹�����ǩ���Զ�ѵ��ģ�Ͳ������˹���������
% @2018.12.18�˹��������������ƣ����ƣ����߲����ı�ǩ�ɿ�����ʵ�ǿ��Եģ���Ϊ�º�ع�ͷ��������Ҷ�֪������
% �ؼ�����ǰ׼ȷ�жϽ�������䣬�������º�ı�ǩ����ǰ���Ա��������ǿ���ѵ��ģ��ȥ������ж�
% �����ڻ��и�������ǣ��Ա������������ʱ���λ������ô��
% @2018.12.19�����ֻ��������Ա�����ģ�ͣ��ֻ����ݸ�����Ӱ���������࣬��������������Ļ������ݵ�ͺ��٣������ò���ģ��

% PP������ͬ�ȣ� �״��ۿڿ��ÿ���ĸ��£��״��й������ֻ���ÿ�����(�״��۸�������5�㻹û����)��

%% ���ݲ���
if_reverse = true; % Ĭ�������fut_variety = {'J','JM'}���ճ�Ʒ-ԭ�ϵ�˳��
% ���\\Cj-lmxue-dt\�ڻ�����2.0\pairData������Ҳ�ǰ��ճ�Ʒ-ԭ�ϵ�˳����if_reverse = FALSE
% ����if_reverse = TRUE������fut_variety�󣬶�ȡ���ݵĵ�ַҪ��Ʒ�����Ƶ�һ��
% J-JM��false�� PP-MA��true

% �ز����ݵ�ַ
% J-JM ��ַ
% btDataPath = 'E:\Repository\hedge\backtestData\strategyPCA\'; % backtestDataPath ÿ��Ʒ�ֶԵĻز����ݵ�ַ��һ��
% PP-MA ��ַ
btDataPath = 'E:\Repository\arbitrage_base_general\backtestData\';

% Ʒ��
fut_variety = {'PP','MA'};
% ��������
profitPivot = 500; % PP-MA��ȡ500�� J-JM��ȡ-800

%% ���ײ���
paraM.rate = 1 / 3; %%���rateһ��Ҫע�⡣����Ҫ���ĳ�1.35���ĵĻ�calOpenHandsһ��Ҫ���Ÿģ���ÿ�ν��Ҫ���һ�������ȶԲ��ԣ���
paraM.fixedExpense = 800;
% paraM.continuousDay = 10;
% PP/MA ���� = 1 / 1.5

% testRes = nan(13, 9);
% % testRegressR2 = nan(3, 50);
% % seq = [20130201 20170929;...
% %     20140101 20141231;...
% %     20150101 20151231;...
% %     20160101 20161230;...
% %     20170101 20170929];
% seq = 500 : 20 : 660;
% for iTest = 1 : 9

% dateBegin �� dateEnd��ѵ��������֤��
dateBegin = 20130201;
dateEnd = 20170630;
% dateBegin = seq(iTest, 1); % ѵ��
% dateEnd = seq(iTest, 2); % ѵ�� % c_edD�����ǽ����գ���Ȼtotaldate���涨λ����
% dateBegin = 20170701; % ��֤
% dateEnd = 20180330; % ��֤
% dateBegin = 20180101; % ����
% dateEnd = 20181029; % ����


%%%%%%%%%%%%%%%%3���ؼ�������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% paraM.proportion = 0.98; % MA��Ԥ�������Ȩƽ����MA��ռ�ı���
% paraM.xMA = 12; % MA����
% paraM.hgChg = -300; % -340~-240�����������, -260Ч����ã����ǲ�ȷ���Ƿ��ȶ�
% ��������仯Ӧ���ϸ����¸���������������ж������еף�
paraM.interval = 550; % J-JM��ȡ100�� PP-MA��ȡ500
% paraM.lagDays = 30; % 2018.12.18�޸�lagDays�ĺ��壬��ǰlagDays��ʾ���ͱ�������ڱ����ͱ�������ǰ����
%%%%%%%%%%%%%%%%3���ؼ����� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lossRatio = 0.5; % ֹ������


%% ȡ�ز���ȫ��������

load Z:\baseData\Tdays\future\Tdays_dly.mat
% totalDate = Tdays(Tdays(:, 1) >= dateBegin & Tdays(:, 1) <= dateEnd, 1);
totalDate = Tdays(Tdays(:, 1) <= dateEnd, 1); % �ֶβ����ã�����ǰ���п�ֵ

%% ģ���ֻ���������

% w = windmatlab;
% �ֻ��������ݸ�һ�����������и����м۸���Ϊ�Ӻ�������������ֻ�����Y���� �ֻ�����������ģ��û�ã�ֻ�ǻ���������
% profit = getSpotProfit(dateBegin, dateEnd, paraM);
% ����û�����õ��ֻ����������ˣ�ֻ��ǰ�ڻ�ͼ��
% ׼ȷ��˵getSpotPriceӦ��ȡ����getWindData

% % @12.4 �����ȡ�ֻ����ݣ��ȶ����Ϊ�ն�fillToDaily���ټ����ܻ��Ȼ�����ͬ�ȵ�getWoW getYoY��
% productionPPYoY = getSpotPrice('S0027180', 20130201, dateEnd, 'ProductYoYPP', 'mean'); % PP�����ʵ���ͬ��
% productionPPYoY = fillToDaily(productionPPYoY, totalDate, 1); % ���Ϊ�ն����ݣ��ͺ����1��������
% % productionPPYoY �Ѿ���ͬ�����ݣ�����Ҫ�ټ���������
% % Wind��������������¶ȵģ�4�µ׹���4�·ݵĲ������ݣ�����ʵproductionPPYoY�ͺ�����أ�
% % ��Ϊʲô�նȵ�PP��������PP Fut Price����Ժܵͣ�����������������ͺ�Ĳ������ݣ�
%
%
% % @12.7 PP �����ʵ��ն����ݣ�׿����Ѷ����֤�ڻ��������ڻ��۸������Ժܵ͡������о�Ӧ�����ð�
%
% % @12.10 ��������������ܹ�Ӧ��
% % �����ͽ��������õ�����ֵ���ټ��㵱��ͬ�Ȼ򻷱�
% % �¶�����Ƶ�ʻ᲻��̫���ˣ�
% % ���ڲ�����
% % productionDom = getSpotPrice('S0027179', 20130201, dateEnd, 'ProductionDom', 'mean');
% % % ����Ҫ����һ�����⴦��2014��֮��2�·�һ��û�е���ֵ����������˵���ֵ��ʵ��1��2�·��ۼƣ���Ҫ���⴦��һ��
% % % 2016.02.29�����������������ºϼƣ���ʷ����ֻ����һ�����쳣�ģ����ֶ�����һ��...
% % productionDom(productionDom.Date == 20160229, 'ProductionDom') = table(NaN);
% % productionDom = fillToDaily(productionDom, totalDate, 1);
% %
% % % ��������
% % % ������PP��Ӧ�Ľ�������խ������۾۱�ϩ,203���������ۼ��͹��ۼ��Ľ����������ƻ�ͦ��һ���ģ������������ͺܴ󣬻������Ǿ��ۼ�����ʵ���������߾������ƻ�����ȫһ��
% % importation = getSpotPrice('S5401023', 20130201, dateEnd, 'Importation', 'mean'); % ���
% % importation = fillToDaily(importation, totalDate, 1);
% % supplyPP = outerjoin(productionDom, importation, 'type', 'left', 'Mergekeys', true);
% % supplyPP.SupplyPP = supplyPP.ProductionDom + supplyPP.Importation;
% % supplyPP = supplyPP(:, [1, 4]);
% %
% % supplyPP = getYoY(supplyPP, 'daily'); % �¶�����Ӧ����һ���¶Ȼ��ȵĺ���
%
%
% harborStoreMA = getSpotPrice('S5436526,S5436527', 20130201, dateEnd, 'HarborStoreMA', 'sum'); % MA�ۿڿ��
% %2018.11.30 ����MA�ۿڿ���ټ�һ�������ǽ�����������������Ϊ�״�������������������ôѡ�����о�һ�£�
% %@2018.12.3harborStoreMA ��Ϊ�ܶȻ���������
% harborStoreMA = fillToDaily(harborStoreMA, totalDate, 1);
%
% % ����WoW����YoY
% harborStoreMA = getWoW(harborStoreMA, 'daily');
% harborStoreMA = table(harborStoreMA.Date, harborStoreMA.WoW, 'VariableNames', {'Date', 'HarborStoreMA'});
%
% % ��ȡ���PMI
% pmi = getSpotPrice('M0017126', 20130201, dateEnd, 'PMI', 'mean');
% pmi = fillToDaily(pmi, totalDate, 1);
% % pmiָ��һ�㵱���µ׹���ͳ�ƾ־͹�������֪��Wind��¼�᲻���ͺ󣬼ٶ��ͺ�1��������
%
%
% % get impMAPrice����Ԫ�Ƽۣ�����Ի���
% % �����Ϊ�ն����ݣ�����۸����ݲ���Ҫ�ͺ�һ�㵱�����̿��õ�
% impMAPrice = getSpotPrice('S5416976', 20130201, dateEnd, 'ImpMAPrice', 'mean');  % MA���ڼ۸�:��Ԫ
% exUSDCNY = getSpotPrice('M0000185', 20130201, dateEnd, 'USDCNY', 'mean');
% impMAPrice = outerjoin(impMAPrice, exUSDCNY, 'type', 'left', 'MergeKeys', true);
% impMAPrice.USDCNY = fillmissing(impMAPrice.USDCNY, 'previous');
% impMAPrice.ImpMAPrice = impMAPrice.ImpMAPrice .* impMAPrice.USDCNY;
% impMAPrice.USDCNY = [];
%
% % 2018.12.6 ע�⣬��ȻimpMAPrice������ݱ������daily�ģ�ҲҪ��fillToDaily��������Ϊ������ȷʵĳЩ����������
% % �൱��ÿ�������Լ�Ҫ���ȫ���ٻ��ܵ�һ����Ϊ��������û����fillmissing�ˣ�����Ҫ��֤ÿ�������Լ���ȫ�ģ���Ȼ��ȱʧ���ݻᱻ�ߵ�
% impMAPrice = fillToDaily(impMAPrice, totalDate, 0);
%
% % @2018.12.3 impMAPrice�ȸ�Ϊ�ܶȻ�����һ��
% impMAPrice = getWoW(impMAPrice, 'daily');
% impMAPrice = table(impMAPrice.Date, impMAPrice.WoW, 'VariableNames', {'Date', 'ImpMAPrice'});
%
% spotData = outerjoin(table(totalDate, 'VariableNames', {'Date'}), productionPPYoY, 'type', 'left', 'MergeKeys', true);
% spotData = outerjoin(spotData, harborStoreMA, 'type', 'left', 'MergeKeys', true);
% spotData = outerjoin(spotData, impMAPrice, 'type', 'left', 'MergeKeys', true);
% spotData = outerjoin(spotData, pmi, 'type', 'left', 'MergeKeys', true);

% ÿ�������Լ���fillmissing�ˣ���Ҫ�ȵ������Ϊǰ����Ҫ����WoW��YoY
% spotData.ProductYoYPP = fillmissing(spotData.ProductYoYPP, 'previous');
% spotData.HarborStoreMA = fillmissing(spotData.HarborStoreMA, 'previous');
% spotData.ImpMAPrice = fillmissing(spotData.ImpMAPrice, 'previous');
% spotData.PMI = fillmissing(spotData.PMI, 'previous');

% �޳�ȱʧֵ
% @12.6 ����û�б�Ҫ�޳�ȱʧֵ���ʼ�е�ȱʧ�еĲ�ȷʵ����ʵ���Բ���
% ֻ��ǡ����ΪPPƷ��������2014��2�£�ǰ��2013��Ķ�����û��ϵ������Ҳû�ã�������������Ļ���Ӧ���ޣ����������ֻ�����Ҳ�ǿ����õ�
% spotData = spotData(all(~isnan(table2array(spotData)), 2), :);

% spotData = spotData(spotData.Date >= dateBegin & spotData.Date <= dateEnd, :);


%% �������ڻ��۲����ֻ��۲��ֵ��Ϊ��ʵ�۲�߼��ǣ�PP-MA���飬�ڻ��۲���ֻ��۲����ʻ���������������
%% ��ʵ�۲���ʱ��ƫ���ڻ����ֻ������ڻ��ߣ���ʱ��ƫ���ֻ����ڻ��������ֻ������м�λ�õľ�ֵ����һ���Ƚ����Ե�״̬�������Կ�

% ��ȡ�ڻ��۸�����

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
    if if_reverse == false
        dataPath = [sigDPath,'\',pFut1,'_',pFut2];
    else
        dataPath = [sigDPath,'\',pFut2,'_',pFut1];
    end
    % ��Լ����
    contM1 = cont_multi{ismember(cont_multi(:,1),pFut1),2};
    contM2 = cont_multi{ismember(cont_multi(:,1),pFut2),2};
    
    % ���뻻��������
    if if_reverse == false
        load(['\\Cj-lmxue-dt\�ڻ�����2.0\code2.0\data20_pair_data\chgInfo\',pFut1,'_',pFut2,'.mat'])
    else
        load(['\\Cj-lmxue-dt\�ڻ�����2.0\code2.0\data20_pair_data\chgInfo\',pFut2,'_',pFut1,'.mat'])
        
    end
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
        
        if if_reverse == false
            contNum1 = 2;
            contNum2 = 3;
        else
            contNum1 = 3;
            contNum2 = 2;
        end
        
        cont1 = regexp(chgInfo{c,contNum1}{1},'\w*(?=\.)','match'); % ��Ʒ
        cont2 = regexp(chgInfo{c,contNum2}{1},'\w*(?=\.)','match'); % ԭ��
        clear contNum1 contNum2
        
        % ��������
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
        % realSpread�����������߼�����ʼֵ�õ�һ�����࣬����ֱ��������һ������10�����Ϊ������
        % originalKey ȡ��һ����Լ�ڽ���ʱ������ࣨ���е�һ����Լ���õ�һ��ֵ��
        % ��c = 1��Ϊ�ǲ��ǳ�ʼ��Լ���ֶν�����֤Ҳ���Ǵӳ�ʼ��ʼ
        %         if c == 1
        %             originalKey = realSpread(1);
        %         else
        %             originalKey = lastRealSpread(lastRealSpread.Date == spread.Date(1), 2).RealSpread;
        %         end
        %         realSpread = realSTransform(realSpread, originalKey, paraM.continuousDay);
        
        realSpread = ones(size(spread, 1), 1) * profitPivot;
        
        % rowfun�����function��������һһ��Ӧ��������������ʾֻ��һ��������ʵ�����������У�����
        %         keySpread = mode(realSpread); % ȡǰparaM.lagDays��������������������Ϊ��������base����
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
        
        lastRealSpread = realSpread;
        clear realSpread
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

% % subplot(2, 3, iTest)
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
