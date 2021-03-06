function resWoW = getWoW(datatable, dataFreq)
%GETWOW datatable是输入的数据，第一列为日期（全部交易日），第二列为原始数据，type表示原始数据的频率，
% type = 'weekly'，则数据类型是周度，计算为除以上一个非空数值 - 1;不要这么做！看着简单其实都是坑
% 处理起来很麻烦因为数据质量很差 有的周四，有的周五，有的周日？，还有的同一周既有周四又有周五。。。
% 修改为周度数据先outerjoin到totalDate上补成日度数据，然后按照日度数据的方式处理
% type = 'daily'，则数据类型是日度，先加上星期标记，再滚动除以上一个同星期的数值 - 1。在此基础上修正间隔超过5个交易日情况

totalDate = evalin('base', 'totalDate');
totalDate = table(totalDate, 'VariableNames', {'Date'});
if  strcmp(dataFreq, 'daily')
    % 原始数据频率是日度
    datatable(:, 3) = table(weekday(datenum(num2str(table2array(datatable(:, 1))), 'yyyymmdd'), 'yyyymmdd'));  % 加上星期标签
    % 第3列表示一周的第几天，第一天是周日
    % 有个问题需要考虑，如果今天是周二，上周二不是交易日，那么你除以上一个weekday =
    % 3的就是上上周二了，感觉应该除以上周二之前最近交易日更合理
    res = NaN(size(datatable, 1), 1);
    for iWeekday = 2 : 6 % 因为都是交易日，所以不可能出现1 和 7
        targetDay = table2array(datatable(:, 3));
        targetDay = targetDay == iWeekday;
        idx = find(targetDay, size(targetDay, 1)); % 每个星期第iWeekday天的index
        originalData = table2array(datatable(:, 2));
        resPure = originalData(idx(2:end)) ./ originalData(idx(1:end-1)) - 1;
        % resPure 需要再经过一次修正（不一定修正结果更好，先试试）
        idxDiff = [NaN; diff(idx)];
        adjIdx = idxDiff > 5;
        adjIdxExtract = find(adjIdx, size(adjIdx, 1));
        adjIdxValue = idx(adjIdx); % 原先数据中idx为这些的数据，它的上一周对应日期缺失，他们需要除以的是上周对应日期前一天数据
        adjIdxValue = adjIdxValue(adjIdxValue > 5); % 应该也不会出现＜5的情况
        % 调整
        resPureAdj = originalData(adjIdxValue) ./ originalData(adjIdxValue - 5) - 1;
        resPure(adjIdxExtract - 1) = resPureAdj;
        res(idx(2:end)) = resPure;
    end
else
    error('Only support daily data! Suggest using fillToDaily First!')
end
res = fillmissing(res, 'previous');
datatable(:, 3) = table(res);
datatable.Properties.VariableNames(3) = {'WoW'};
resWoW = datatable;
clear datatable
end

