function resWoW = getWoW(datatable, type)
%GETWOW datatable����������ݣ���һ��Ϊ���ڣ�ȫ�������գ����ڶ���Ϊԭʼ���ݣ�type��ʾԭʼ���ݵ�Ƶ�ʣ�
% type = 'weekly'���������������ܶȣ��м��ֵ������Ϊ������һ���ǿ���ֵ - 1���ٲ����ֵ��
% type = 'daily'���������������նȣ��ȼ������ڱ�ǣ��ٹ���������һ��ͬ���ڵ���ֵ - 1.

if strcmp(type, 'weekly')
    % ԭʼ����Ƶ�����ܶ�
    nNaN = ~isnan(table2array(datatable(:, 2)));
    idx = find(nNaN, size(datatable, 1)); % �ǿ���ֵ��index
    originalData = table2array(datatable(:, 2));
    res = NaN(size(originalData, 1), 1);
    resPure = originalData(idx(2:end)) ./ originalData(idx(1:end-1)) - 1;
    res(idx(2:end)) = resPure;
elseif strcmp(type, 'daily')
    % ԭʼ����Ƶ�����ն�
    datatable(:, 3) = table(weekday(datenum(num2str(table2array(datatable(:, 1))), 'yyyymmdd'), 'yyyymmdd'));  % �������ڱ�ǩ
    % ��3�б�ʾһ�ܵĵڼ��죬��һ��������
    % �и�������Ҫ���ǣ�����������ܶ������ܶ����ǽ����գ���ô�������һ��weekday =
    % 3�ľ��������ܶ��ˣ��о�Ӧ�ó������ܶ�֮ǰ��������ո�����
    res = NaN(size(datatable, 1), 1);
    for iWeekday = 2 : 6 % ��Ϊ���ǽ����գ����Բ����ܳ���1 �� 7
        targetDay = table2array(datatable(:, 3));
        targetDay = targetDay == iWeekday;
        idx = find(targetDay, size(targetDay, 1)); % ÿ�����ڵ�iWeekday���index
        originalData = table2array(datatable(:, 2));
        resPure = originalData(idx(2:end)) ./ originalData(idx(1:end-1)) - 1;
        % resPure ��Ҫ�پ���һ����������һ������������ã������ԣ�
        idxDiff = [NaN; diff(idx)];
        adjIdx = idxDiff > 5;
        adjIdxExtract = find(adjIdx, size(adjIdx, 1));
        adjIdxValue = idx(adjIdx); % ԭ��������idxΪ��Щ�����ݣ�������һ�ܶ�Ӧ����ȱʧ��������Ҫ���Ե������ܶ�Ӧ����ǰһ������
        adjIdxValue = adjIdxValue(adjIdxValue > 5); % Ӧ��Ҳ������֣�5�����
        % ����
        resPureAdj = originalData(adjIdxValue) ./ originalData(adjIdxValue - 5) - 1;
        resPure(adjIdxExtract - 1) = resPureAdj;
        res(idx(2:end)) = resPure;
    end   
end
res = fillmissing(res, 'previous');
datatable(:, 3) = table(res);
datatable.Properties.VariableNames(3) = {'WoW'};
resWoW = datatable;
clear datatable
end

