function [res] = getprice(date, contName, varietyName, priceType)
%GETPRICE ����varietyName��date��contName, ��load�����������ʹ����������۸����������ҵ���Ӧ�ļ۸�
% ���ڹ���һ�л�ϼ۸���ʱ����������ʱ������������㲻ͬ����
% priceType in ('Open', 'Close', 'Settle')
TradePara = evalin('base', 'TradePara');
narginchk(4, 4)
futDataPath = '\\Cj-lmxue-dt\�ڻ�����2.0\dlyData\';
dataPath = [futDataPath, '������Լ\', varietyName, '.mat'];
load(dataPath)
str = ['dataMain = table(futureData.Date, futureData.mainCont, futureData.', priceType, ');'];
eval(str)


dataPath = [futDataPath, '��������Լ\', varietyName, '.mat'];
load(dataPath)
str = ['dataSecond = table(futureData.Date, futureData.secondCont, futureData.', priceType, ');'];
eval(str)



dataMain.Properties.VariableNames = {'Date', 'MainCont', 'Price'};
dataSecond.Properties.VariableNames = {'Date', 'SecondCont', 'Price'};
dataMain = dataMain(dataMain.Date >= date(1) & dataMain.Date <= date(end), :);
dataSecond = dataSecond(dataSecond.Date >= date(1) & dataSecond.Date <= date(end), :);

dataMain.MainCont = cellfun(@(x) str2double(x), dataMain.MainCont);
dataSecond.SecondCont = cellfun(@(x) str2double(x), dataSecond.SecondCont);

match1 = dataMain(dataMain.Date == date & dataMain.MainCont == contName, 'Price');
match2 = dataSecond(dataSecond.Date == date & dataSecond.SecondCont == contName, 'Price');

if size(match1, 1) == 1
    res = match1.Price;
elseif size(match2) == 1
    res = match2.Price;
else
    % ���������Լ�ʹ�������Լ�ﶼû�м۸���ҪȥWindȡ������Ҫ���Wind Code
    w = windmatlab;
    if strcmp(priceType, 'Open')
        windPriceType = 'open';
    elseif strcmp(priceType, 'Close')
        windPriceType = 'close';
    elseif strcmp(priceType, 'Settle')
        windPriceType = 'settle';
    end
    
    load([TradePara.usualPath, '\contInfo.mat'])
    futName = regexp(fut_total, '^\w+(?=\.)', 'match');
    futExchange = regexp(fut_total, '\.\w+', 'match');
    futUniverse = cell2table([futName futExchange], 'VariableNames', {'Name', 'Exchange'});
    % ת��Ϊchar�Ժ��һ���ַ�һ���ַ��ıȽ�
    exchange = futUniverse(strcmp(futUniverse.Name, varietyName), :);
    windCode = [varietyName, num2str(contName), char(exchange.Exchange)];
    [w_wss_data,~,~,~,w_wss_errorid,~]=w.wss(windCode,windPriceType,['tradeDate=', num2str(date)],'priceAdj=U','cycle=D');
    if w_wss_errorid ~= 0
        error('Error happened when fetching data from Wind!')
    end
    
    res = w_wss_data;
end

end

