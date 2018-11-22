function [sigLi] = pureSig1(sig)
%PURESIG1 �źŴ����һ��������ԭʼ�Ĵ����źŵ���һ���ź�ƥ����
% tdList:�ֲַ��򣬿���ʱ�㣬���ּ۲ƽ�ּ۲�, Ʒ��1������Ʒ��2����������ӯ�����,�ۼ��ʲ�
% �ÿ���ǰһ������̼ۼ��㿪������
% c_edD�Ǿɺ�Լ�����һ�죬�ɺ�Լ��ƽ��ʱ��Ӧ������һ��ƽ��

% ����ֹ���Ժ���Ҫ������ٵ���һ�£�������ƽ���ź�֮ǰ�Ŀ����źŶ���ҪԽ��ȥ����������38 42  40 42������Ƕ�����
% @2018.09.27 �����źţ���������������������ų������ź�
lines = evalin('base', 'lines');

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
        c = clL;
    end
end
sigLi(sigLi(:,1)==0,:) = [];

% % @2018.09.27 ��������¼ӣ������޳������������۵��źŶ�
% sigLi(:, size(sigLi, 2) + 1) = NaN; % ��һ���Ƿ��ų���if_valid,1��ʾ�����źţ�0��ʾ���ų����ź�
% 
% for iRow = 1 : size(sigLi, 1)
%     if lines.SpreadDiff(sigLi(iRow, 2)) >= lines.PriceDiffBoundaryDown(sigLi(iRow, 2)) && ...
%             lines.SpreadDiff(sigLi(iRow, 2)) <= lines.PriceDiffBoundaryUp(sigLi(iRow, 2))
%         sigLi(iRow, size(sigLi, 2)) = 1;
%     else
%         sigLi(iRow, size(sigLi, 2)) = 0;
%     end
% end
% 
% sigLi(sigLi(:, size(sigLi, 2)) == 0, :) = []; 
% sigLi(:, size(sigLi, 2)) = [];

end

