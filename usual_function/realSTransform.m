function newRealS = realSTransform(realSpread, originalKey, continuousDay)
%REALSTRANSFORM ��realSpread���任��
% Ϊ�����һ����Ϊ��ʼ���࣬����ȡ��һ��������Ϊ��ʼ���࣬
% ֱ������10������������������ֵ���滻��ʼֵ
newRealS = nan(size(realSpread, 1), 1);
newRealS(1 : continuousDay, 1) = ones(continuousDay, 1) .* originalKey;

for iRow = continuousDay + 1 : size(realSpread)
    % �жϵ�iRow����ǰ10�У�����iRow�У��ǲ���ͬһ����������ǣ���ônewRealS(iRow)�͵���realSpread(iRow)
    % ������ǣ���ônewRealS(iRow) = newRealS(iRow - 1)
    if length(unique(realSpread(iRow - 9 : iRow, 1))) == 1
        newRealS(iRow) = realSpread(iRow);    
    else
        newRealS(iRow) = newRealS(iRow - 1);
    end    
end

end

