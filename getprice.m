function [res] = getprice(date, contName, varietyName, priceType)
%GETPRICE 输入varietyName，date，contName, 从load进来的主力和次主力两个价格序列里面找到对应的价格
% 用于构造一列混合价格（有时候主力，有时候次主力，满足不同需求）
% priceType in ('Open', 'Close', 'Settle')
TradePara = evalin('base', 'TradePara');
narginchk(4, 4)
futDataPath = '\\Cj-lmxue-dt\期货数据2.0\dlyData\';
dataPath = [futDataPath, '主力合约\', varietyName, '.mat'];
load(dataPath)
str = ['dataMain = table(futureData.Date, futureData.mainCont, futureData.', priceType, ');'];
eval(str)


dataPath = [futDataPath, '次主力合约\', varietyName, '.mat'];
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
    % 如果主力合约和次主力合约里都没有价格，需要去Wind取数，先要获得Wind Code
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
    % 转换为char以后会一个字符一个字符的比较
    exchange = futUniverse(strcmp(futUniverse.Name, varietyName), :);
    windCode = [varietyName, num2str(contName), char(exchange.Exchange)];
    [w_wss_data,~,~,~,w_wss_errorid,~]=w.wss(windCode,windPriceType,['tradeDate=', num2str(date)],'priceAdj=U','cycle=D');
    if w_wss_errorid ~= 0
        error('Error happened when fetching data from Wind!')
    end
    
    res = w_wss_data;
end

end

