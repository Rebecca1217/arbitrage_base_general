function resSpread = getRealSpread(ratio)
%GETREALSPREAD 此处显示有关此函数的摘要
%   此处显示详细说明
if ratio < 0
    resSpread = -500;
elseif ratio < 0.7
    resSpread = 800;
else 
    resSpread = 1200;
end

end

