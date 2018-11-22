function res = fillone(inputVector)
%fill the one data with previous ~one ones
% only used for vertical fillin now

idx = (inputVector ~= 1); % non one
inputVectorValue = inputVector(idx); %挑出非1数值
if idx(1) ~= 0
    res = inputVectorValue(cumsum(idx));
else
    id = cumsum(idx);
    validID = id(id ~= 0);
    nanNum = length(idx) - length(validID);
    res = [ones(nanNum, 1); inputVectorValue(validID)];
end

end

