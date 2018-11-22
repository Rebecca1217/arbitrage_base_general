function res = formatAdj(inputTable)
%FORMATADJ ר������Python�洢��CSV�ļ����ݸ�ʽ����������yyyy-mm-dd��ʽ���ڣ� �����ַ���Ϊ��ֵ

inputTable.Properties.VariableNames = {'Date', 'Value'};
% �� yyyy-mm-dd datetime��ʽ���ڸ�ΪMATLAB yyyymmdd��ֵ��ʽ����
colDate = table(inputTable.Date);

% ���ַ�����ʽ��yyyy-mm-dd���룺
% idx = strfind(vDate, '-');
% y = zeros(length(vDate), 1);
% m = zeros(length(vDate), 1);
% d = zeros(length(vDate), 1);
% for i = 1 : length(vDate)
% y(i) = str2double(vDate{i}(1 : (idx{i}(1) - 1)));
% m(i) = str2double(vDate{i}((idx{i}(1) + 1) : (idx{i}(2) - 1)));
% d(i) = str2double(vDate{i}((idx{i}(2) + 1) : end));
% end
% vDate = y .* 10000 + m .* 100 + d;
colDate = rowfun(@(x, y) datestr(x, 'yyyymmdd'), colDate);
colDate = rowfun(@(x) str2double(x), colDate);

% convert value from char to double
colValue = inputTable.Value;
colValue = cellfun(@(x, y, z) ifelse(strcmp(x, '-'), y, z), ...
    colValue, repmat({NaN}, size(inputTable, 1), 1), colValue, 'UniformOutput', false);
colValue = str2double(colValue);

res = table(colDate.Var1, colValue);
res.Properties.VariableNames = {'Date', 'Value'};

end

