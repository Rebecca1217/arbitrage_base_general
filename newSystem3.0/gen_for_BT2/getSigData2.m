function sigData = getSigData2(signal,tdDate)
% ÿһ���źŶ�Ӧ�Ŀ�ƽ��������
% signal:����Ʒ�ֶ�Ӧ���źź�����
% ע��������һ�������źŶ�Ӧ��ƽ���ź�û�з����������һ���źŵ�ƽ��ʱ���Ϊnan
% 20180710����Ķ���ƽ���źŵ��б���ǰһ���б�+1

signal = signal(signal(:,1)>=tdDate(1) & signal(:,1)<=tdDate(end),:);
signal = signal(:,2);
% �ֶ��ͷ�ֱ���
sigLong = signal;
sigLong(signal==-1) = 0;
sigShort = signal;
sigShort(signal==1) = 0;
sigShort(signal==-1) = 1;
if sum(sigLong)~=0
    sigLiLong = getSigLines(sigLong);
else
    sigLiLong = [];
end
if sum(sigShort)~=0
    sigLiShort = getSigLines(sigShort);
    sigLiShort(:,1) = -1;
else
    sigLiShort = [];
end
sigData = sortrows([sigLiLong;sigLiShort],2);

end



