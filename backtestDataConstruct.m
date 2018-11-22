% ��Ҫ���У�Date, Close, Open, Settle, High, Low, adjFactor, mainCont��ʵ�ʲ�һ����ʲôCont��
% ���futureData
% ����PP��futureData�ز�����
fut = 'PP';
futureData = struct;

contName1 = res.Cont1;
contName1 = regexp(contName1, '\d*', 'match');
contName1 = cellfun(@(x) str2double(x), contName1);

futureData.Date = res.Date;
futureData.mainCont = contName1; % ��ʵ�ʽ��׵ĺ�Լ����������Լ���غϣ�ֻ��Ϊ������ز�ƽ̨������������Ϊ������Լ
% futureData.Close = res.Close1;

futureData.Close = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Close'), res.Date, contName1);
futureData.Open = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Open'), res.Date, contName1);
futureData.Settle = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Settle'), res.Date, contName1);
futureData.High = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'High'), res.Date, contName1);
futureData.Low = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Low'), res.Date, contName1);


% res�������chgLabel
[~, la, ~] = intersect(res.Date, chgInfo.date);
res.ChgLabel = zeros(size(res, 1), 1);
res.ChgLabel(la) = 1;


% @2018.11.21�޸�adjFactor�ļ��㷽ʽ��֮ǰ�Ǵ�ģ����»���ʱ��۸񲻶�
% ��ѩ����adjFactor���߼����ǰ�1ȫ�滻Ϊ��һ����1ֵ�����Ǵ�ͷ����ǰ����cumprod
adjFactor = [res.Date contName1 res.ChgLabel futureData.Open];
adjFactor(:, 5) = [adjFactor(1, 2); adjFactor(1:(end-1), 2)]; % ��Ϊ���Բ����һ��ͻ��£����԰ѵ�һ����ϣ����߻�ͷ��getprice��һ�£�����NaN�Ļ����NaN
adjFactor(:, 6) = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Open'), adjFactor(:, 1), adjFactor(:, 5));%ǰһ���Լ�ڽ���Ŀ��̼�
adjFactor(:, 7) = adjFactor(:, 6) ./ adjFactor(:, 4);
adjFactor(:, 7) = cumprod(adjFactor(:, 7));
futureData.adjFactor = [adjFactor(:, 1) adjFactor(:, 7) adjFactor(:, 3)];

save('E:\Repository\arbitrage_base_general\backtestData\PP.mat', 'futureData')


% ����MA��futureData�ز�����
fut = 'MA';
futureData = struct;

contName2 = res.Cont2;
contName2 = regexp(contName2, '\d*', 'match');
contName2 = cellfun(@(x) str2double(x), contName2);

futureData.Date = res.Date;
futureData.mainCont = contName2; % ��ʵ�ʽ��׵ĺ�Լ����������Լ���غϣ�ֻ��Ϊ������ز�ƽ̨������������Ϊ������Լ
futureData.Close = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Close'), res.Date, contName2);
futureData.Open = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Open'), res.Date, contName2);
futureData.Settle = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Settle'), res.Date, contName2);
futureData.High = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'High'), res.Date, contName2);
futureData.Low = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Low'), res.Date, contName2);


adjFactor = [res.Date contName2 res.ChgLabel futureData.Open];
adjFactor(:, 5) = [adjFactor(1, 2); adjFactor(1:(end-1), 2)]; % ��Ϊ���Բ����һ��ͻ��£����԰ѵ�һ����ϣ����߻�ͷ��getprice��һ�£�����NaN�Ļ����NaN
adjFactor(:, 6) = arrayfun(@(x1, y, z, o) getprice(x1, y, fut, 'Open'), adjFactor(:, 1), adjFactor(:, 5));%ǰһ���Լ�ڽ���Ŀ��̼�
adjFactor(:, 7) = adjFactor(:, 6) ./ adjFactor(:, 4);
adjFactor(:, 7) = cumprod(adjFactor(:, 7));
futureData.adjFactor = [adjFactor(:, 1) adjFactor(:, 7) adjFactor(:, 3)];

save('E:\Repository\arbitrage_base_general\backtestData\MA.mat', 'futureData')
