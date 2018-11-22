function sigLi = getSigLines(sigDirect) 
% �����˵�һ�оͷ����źŵ����
% �����źŷ��������С��źŽ���������


difSig = [sigDirect(1);diff(sigDirect)];
locs = find(difSig==1); %�źŷ���������

sigLi = zeros(length(locs),3);
sigLi(:,1) = 1;
sigLi(:,2) = locs; %�����ź�������
for l = 1:length(locs)
    edL = find(difSig(locs(l):end)==-1,1,'first')+locs(l)-1;
    if isempty(edL)
        sigLi(l,3) = nan;
    else
        sigLi(l,3) = edL;
    end
end

end