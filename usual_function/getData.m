function data = getData(dataPath,edDate)
% �����Լ���ݣ���ʽ����

load(dataPath)
data = TableData(TableData.date<=edDate,:);
data{:,{'open';'close';'high';'low'}} = fillmissing(data{:,{'open';'close';'high';'low'}},'previous');

