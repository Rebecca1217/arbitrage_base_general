function newRealS = realSTransform(realSpread, originalKey, continuousDay)
%REALSTRANSFORM 对realSpread做变换，
% 为避免第一天作为初始中枢，不能取第一个中枢作为初始中枢，
% 直到遇到10个工作日连续的中枢值后替换初始值
newRealS = nan(size(realSpread, 1), 1);
newRealS(1 : continuousDay, 1) = ones(continuousDay, 1) .* originalKey;

for iRow = continuousDay + 1 : size(realSpread)
    % 判断第iRow行往前10行（包括iRow行）是不是同一个数，如果是，那么newRealS(iRow)就等于realSpread(iRow)
    % 如果不是，那么newRealS(iRow) = newRealS(iRow - 1)
    if length(unique(realSpread(iRow - 9 : iRow, 1))) == 1
        newRealS(iRow) = realSpread(iRow);    
    else
        newRealS(iRow) = newRealS(iRow - 1);
    end    
end

end

