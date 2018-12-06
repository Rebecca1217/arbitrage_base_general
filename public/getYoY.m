function resYoY = getYoY(datatable, dataFreq)
%GETYOY datatable是输入的数据，第一列为日期（全部交易日），第二列为原始数据，dataFreq表示原始数据的频率，
% dataFreq 必须都是'daily'

if strcmp(dataFreq, 'daily')
    % 对于输入的日期，从去年同日期开始往上找，最后一个符合条件的日期作为去年同期
    lastyDate = str2num(datestr((datenum(num2str(datatable.Date), 'yyyymmdd') - 365), 'yyyymmdd'));
    res = arrayfun(@(x, y) findLatest(x, datatable), lastyDate);
    
    datatable(:, 3 : 4) = table(lastyDate, res);
    datatable(:, 5) = table(table2array(datatable(:, 2)) ./ table2array(datatable(:, 4)) - 1); % 年同比增长率
    resYoY = datatable(:, [1 5]);
    resYoY.Properties.VariableNames = {'Date', 'YoY'};
    clear datatable
else
    error('dataFreq should be daily! Try fillToDaily first!')
end

end

