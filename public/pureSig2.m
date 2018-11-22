function sigLi = pureSig2(sigLi, date, oriAsset, c_stD, c_edD, sig)
%PURESIG2 
% pure_signal�����׶Σ��޳���������ź�

% ��ƽ���źŸ��ݺ�Լ��������ʱ����е���

stL = find(date==c_stD,1);
edL = find(date==c_edD,1);
% ��ʼ
stS = find(and(sigLi(:,2)<=stL,sigLi(:,3)>=stL),1,'first'); %�����Լ��Ϊ������Լ֮ʱ�ĵ�һ�������źţ�����֮ǰ�Ϳ��֣��������ƽ�ֵ����
if isempty(stS) %��һ����Լ������������⣬��Ϊ�Ǵ�ĳ��Ʒ�ֵ������տ�ʼ��
    stS = find(and(sigLi(:,2)>=stL,sigLi(:,2)<=edL),1,'first'); % ���û��������������ҵ�һ��������ſ��ֵ��ź�
    if isempty(stS) %�������Լ��Ϊ������Լ�ڼ䣬û�з��������ź�
        tdList = [date,zeros(length(sig),8)];
        tdList(:,end) = oriAsset;
        sigAdj = zeros(size(sig));
        sigLi(:,:) = []; %�Ѹú�Լ��û��Ϊ������Լʱ��Ŀ����ź�ȥ��
        return;
    end
elseif stS>1
    sigLi(1:stS-1,:) = []; %�Ѹú�Լ��û��Ϊ������Լʱ��Ŀ����ź�ȥ��
    sigLi(1,2) = stL-1;  % �п���δƽ�Ļ���Ϊ���µ�һ�췢�������ź�
end

% ����
edS = find(and(sigLi(:,2)<=edL,sigLi(:,3)>=edL),1,'last'); %�����Լ��Ϊ������Լ֮������һ�������ź�
if isempty(edS) %����Ҳ��������źţ������ʱ��֮ǰƽ���ˣ�����û���µĿ����ź�
    edS = find(sigLi(:,3)<=edL,1,'last'); %�����ʱ��֮ǰ���һ��ƽ���ź�������
    sigLi(edS+1:end,:) = [];
else
    sigLi(edS+1:end,:) = [];
    sigLi(end,3) = edL; % ���￪��δƽ�Ļ���Ҫƽ��

end

end

