function resPrice = getSpotPrice(windID,dateBegin, dateEnd, priceVarName, type)
%GETSPOTPRICE ��Wind��ȡ�ֻ��۸����ݣ����������Wind���룬��ֹʱ��, ����ֻ��۸�ı�ͷ����
% Wind�����������һ��Ҳ�����������������һ����resPrice�������Լ�������Ƕ����resPrice���ƽ��ֵ
% windID �������ʽ�� 'S5120126'������'S5120126,S5120127,S5120128'
% type ѡ������'mean'����'sum'
w = evalin('base', 'w');
% [w_edb_data,~,~,w_edb_times,w_edb_errorid,~] = ...
%     w.edb(windID,dateBegin,dateEnd,'Fill=Previous');
str = ['[w_edb_data,~,~,w_edb_times,w_edb_errorid,~] = w.edb(windID,''',num2str(dateBegin),''',dateEnd, ''Fill=Previous'');'];
eval(str);
% ����ط�dateBegin����ֱ��д�룬����ò�������ֻ�ܶ������µ�һ�죬��֪��Ϊʲô����
w_edb_times = rowfun(@(x, f) datestr(x, 'yyyymmdd'), table(w_edb_times));
w_edb_times = table2array(rowfun(@str2double, w_edb_times));

ifErrorStop(w_edb_errorid) 

if strcmp(type, 'mean')
    price = mean(w_edb_data, 2);
else
    price = sum(w_edb_data, 2);
end
resPrice = table(w_edb_times, price, 'VariableNames', {'Date', priceVarName});

resPrice = resPrice(resPrice.Date >= dateBegin & resPrice.Date <= dateEnd, :); % ��ΪWindȡ����ʱ����ȡһ���졣��
end

