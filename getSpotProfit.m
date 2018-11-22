function resProfit = getSpotProfit(dateBegin, dateEnd, paraM)
%GETSPOTPROFIT ���������
% ����������ڲ�ͬƷ����˵��Ҫ�������£���Ϊÿ����ҵ������ʽ��һ��
totalDate = evalin('base', 'totalDate');
totalDate = array2table(totalDate, 'VariableNames', {'Date'});
% ��������Ҫ��PP - 3MA - 800���ֻ�����Y����
% �ֻ���Ʒ�۸� PP ���ֻ��۸���Ҫ��ɸѡ�����㽻���׼����ͬ��������ϴ��ݶ���Wind��ҳ��ʾ����³ʯ���۸�T36F
priceProduct = getSpotPrice('S5431209', dateBegin, dateEnd, 'PricePP', 'mean');
% �ֻ�������������зǽ������ݣ�������Ҫ��һ��ɸѡ���ڴ���
priceProduct = outerjoin(totalDate, priceProduct, 'type', 'left', 'MergeKeys', true);

% �ֻ�ԭ�ϼ۸�
% �״��������������ػ���һ���������Եͣ���������һ��
priceMaterial = getSpotPrice('S5422062,S5422065,S5422037', dateBegin, dateEnd, 'PriceMA', 'mean');
priceMaterial = outerjoin(totalDate, priceMaterial, 'type', 'left', 'MergeKeys', true);

resProfit = outerjoin(priceProduct, priceMaterial, 'type', 'left', 'MergeKeys', true);

resProfit.Profit = resProfit.PricePP - 1 / paraM.rate * resProfit.PriceMA - paraM.fixedExpense;

resProfit.PricePP = [];
resProfit.PriceMA = [];
end

