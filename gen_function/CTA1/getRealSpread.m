function resSpread = getRealSpread(ratio)
%GETREALSPREAD �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
if ratio < 0
    resSpread = -500;
elseif ratio < 0.7
    resSpread = 800;
else 
    resSpread = 1200;
end

end

