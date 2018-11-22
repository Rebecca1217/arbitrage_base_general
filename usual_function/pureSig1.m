function [sigLi] = pureSig1(sig)
%PURESIG1 �źŴ����һ��������ԭʼ�Ĵ����źŵ���һ���ź�ƥ����
% tdList:�ֲַ��򣬿���ʱ�㣬���ּ۲ƽ�ּ۲�, Ʒ��1������Ʒ��2����������ӯ�����,�ۼ��ʲ�
% �ÿ���ǰһ������̼ۼ��㿪������
% c_edD�Ǿɺ�Լ�����һ�죬�ɺ�Լ��ƽ��ʱ��Ӧ������һ��ƽ��

% ����ֹ���Ժ���Ҫ������ٵ���һ�£�������ƽ���ź�֮ǰ�Ŀ����źŶ���ҪԽ��ȥ����������38 42  40 42������Ƕ�����

% ��ƽ���ź�
sigOp = sig(:,1);
sigCl = sig(:,2);
% ��ƽ���ź�������
sigLi = zeros(length(sigOp),3); % ���򣬿�ƽ�ź�������
c = 1;
for t = 1:size(sigLi,1)
    opL = find(sigOp(c:end)~=0,1,'first')+c-1;
    if isempty(opL) || opL==length(sigOp)
        break;
    else
        sigLi(t,1) = sigOp(opL);
        sigLi(t,2) = opL;
    end
    clL = find(sigCl(opL+1:end)==-sigOp(opL),1,'first')+opL;
    if isempty(clL)
        sigLi(t,3) = size(sigLi,1);
        break;
    else
        sigLi(t,3) = clL;
        %         c = clL;
        c = c + 1; % 2018.10.12�޸ģ�38 42 40 42���
    end
end
sigLi(sigLi(:,1)==0,:) = [];


end

