% regData.Profit��Ԥ�⽹�������նȣ�
% ��ȡ�������������ܶ�����
% ���ܶ����ݲ鿴���ϵ��
JProfit = readtable('C:\Users\fengruiling\Desktop\JJMdata\JProfit_bck.xlsx');
JProfit.Properties.VariableNames = {'Date', 'JProfitData'};
JProfit.Date = datestr(JProfit.Date, 'yyyymmdd');
convertDate = table(JProfit.Date);
JProfit.Date = table2array(rowfun(@(x) str2double(x), convertDate));


projectedProfit = regData(:, 1:2);

res = outerjoin(JProfit, projectedProfit, 'type', 'left', 'MergeKeys', true);
res.Profit = fillmissing(res.Profit, 'previous');

% δ�õ��岹�������ܶ����ݵ������ ��Ȼ�Ƿǳ��ߵ�
corr(res.JProfitData, res.Profit, 'Type', 'Pearson')
corr(res.JProfitData(1:25), res.Profit(1:25), 'Type', 'Spearman')
corr(res.JProfitData, res.Profit, 'Type', 'Kendall')





