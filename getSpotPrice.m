function resPrice = getSpotPrice(windID,dateBegin, dateEnd, priceVarName, type)
%GETSPOTPRICE 从Wind获取现货价格数据，输入参数：Wind代码，起止时间, 输出现货价格的表头名称
% Wind代码可以输入一个也可以输入多个，如果是一个，resPrice就是它自己，如果是多个，resPrice输出平均值
% windID 的输入格式： 'S5120126'，或者'S5120126,S5120127,S5120128'
% type 选择输入'mean'或者'sum'
w = evalin('base', 'w');
% [w_edb_data,~,~,w_edb_times,w_edb_errorid,~] = ...
%     w.edb(windID,dateBegin,dateEnd,'Fill=Previous');
str = ['[w_edb_data,~,~,w_edb_times,w_edb_errorid,~] = w.edb(windID,''',num2str(dateBegin),''',dateEnd, ''Fill=Previous'');'];
eval(str);
% 这个地方dateBegin必须直接写入，如果用参数，就只能读出最新的一天，不知道为什么。。
w_edb_times = rowfun(@(x, f) datestr(x, 'yyyymmdd'), table(w_edb_times));
w_edb_times = table2array(rowfun(@str2double, w_edb_times));

ifErrorStop(w_edb_errorid) 

if strcmp(type, 'mean')
    price = mean(w_edb_data, 2);
else
    price = sum(w_edb_data, 2);
end
resPrice = table(w_edb_times, price, 'VariableNames', {'Date', priceVarName});

resPrice = resPrice(resPrice.Date >= dateBegin & resPrice.Date <= dateEnd, :); % 因为Wind取数有时候会多取一两天。。
end

