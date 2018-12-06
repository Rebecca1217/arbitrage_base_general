function resYoY = getYoY(datatable, dataFreq)
%GETYOY datatable����������ݣ���һ��Ϊ���ڣ�ȫ�������գ����ڶ���Ϊԭʼ���ݣ�dataFreq��ʾԭʼ���ݵ�Ƶ�ʣ�
% dataFreq ���붼��'daily'

if strcmp(dataFreq, 'daily')
    % ������������ڣ���ȥ��ͬ���ڿ�ʼ�����ң����һ������������������Ϊȥ��ͬ��
    lastyDate = str2num(datestr((datenum(num2str(datatable.Date), 'yyyymmdd') - 365), 'yyyymmdd'));
    res = arrayfun(@(x, y) findLatest(x, datatable), lastyDate);
    
    datatable(:, 3 : 4) = table(lastyDate, res);
    datatable(:, 5) = table(table2array(datatable(:, 2)) ./ table2array(datatable(:, 4)) - 1); % ��ͬ��������
    resYoY = datatable(:, [1 5]);
    resYoY.Properties.VariableNames = {'Date', 'YoY'};
    clear datatable
else
    error('dataFreq should be daily! Try fillToDaily first!')
end

end

