% % regData.Profit��Ԥ�⽹�������նȣ�
% % ��ȡ�������������ܶ�����
% % ���ܶ����ݲ鿴���ϵ��
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
% % δ�õ��岹�������ܶ����ݵ������ ��Ȼ�Ƿǳ��ߵ�
% corr(res.JProfitData, res.Profit, 'Type', 'Pearson')
% corr(res.JProfitData(1:25), res.Profit(1:25), 'Type', 'Spearman')
% corr(res.JProfitData, res.Profit, 'Type', 'Kendall')
%


% �鿴���ϵ��

% productYoYPP PP������ͬ��
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
corrcoef = NaN(height(chgInfo), 1); % ÿһ�κ�Լ��spread�����ϵ��
for c = 1:height(chgInfo)
    cont1 = regexp(chgInfo{c,3}{1},'\w*(?=\.)','match'); % ��Ʒ
    cont2 = regexp(chgInfo{c,2}{1},'\w*(?=\.)','match'); % ԭ��
    % ��������
    data1 = getData([dataPath,'\',pFut1,'\',cont1{1},'.mat'],edDate);
    data2 = getData([dataPath,'\',pFut2,'\',cont2{1},'.mat'],edDate);
    
    spreadData1 = table(data1.date, data1.close, 'VariableNames', {'Date', 'Close1'});
    spreadData2 = table(data2.date, data2.close, 'VariableNames', {'Date', 'Close2'});
    spread = outerjoin(spreadData1, spreadData2, 'type', 'left', 'MergeKeys', true);
    spread.Spread = spread.Close1 - 1 / paraM.rate * spread.Close2 - paraM.fixedExpense;
    spread = outerjoin(spread, compareData, 'type', 'left', 'Mergekeys', true);
    spread(:, 5) = fillmissing(spread(:, 5), 'previous');
    
    corrcoef(c) = corr(table2array(spread(:, 4)), table2array(spread(:, 5)), 'Type', 'Pearson');
    % Ϊʲô����ط����ϵ����pearson?��Ϊspearman���������ԣ�pearson�ܼ�ֵӰ���
    % spread�ܶ������ؽ���Ӱ�죬���ܳ��ڸ�����������߼���������Ƿ��ģ�����ֵ��ʱ��Σ�����������������ӽϴ�Ӱ�����Ľ׶Σ�
    % �ǵ�������ѹ��������Ӱ�죬͹���䱾����spread��ϵ�����ԵĽ׶Σ���������ѡpearson
    % ע�⣺����������Բ�������Ԥ�⣬��spread��impMAPrice��2016��11��֮����Ҳ����������Ϊ����
    % ��֤�˶��߸���ز��ܾ�ֱ����impMAPriceȥԤ��spread�仯����Ϊ��������impMAPrice��spread��Ӱ��Ƚ�������������Ӱ��ռ�Ϸ�
    % ����impMAPrice���������ھ���������Ϊһ��֦
    
end

corrcoefTotal(:, iVar) = corrcoef;
end

% check �״��������Բ�һ�����⣺

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

% �����Ʊ����ع鿴�״����Լ״��۸�Ӱ���Ƿ�����,R2��0������0.74��PvalueҲ�Ӳ���������ر�����
y = table2array(spread(:, 3));
dummy = [ones(127, 1); zeros(97, 1)];
x = [ones(size(spread, 1), 1) dummy table2array(spread(:, 5))];
% x = table2array(spread(:, 5));

[b, bint, r, rint, stats] = regress(y, x);
% b�ǻع�ϵ����stats�ֱ���R2�� Fֵ�� P-value������

% ������߼����ܽ��ͼ״������2014��12����Ѯ�Ժ�����ʲô���鵼�����Ʒ�ת��
% APEC����Ӱ�����䵼��ǰ�ڸۿڿ���ۻ��������ڼ�Σ��Ʒ�����������е��¶�ؼ״��������









