function hands = calOpenHands(closedata,ratio,asset,contM1,contM2)
% ��������Ʒ�ֵĿ�������

close1 = closedata(:,1)*contM1;
close2 = closedata(:,2);

% ratio = 1;
h1 = round(asset / (close1 + close2 * contM1 / ratio));
h2 = round(h1 / ratio * (contM1 / contM2));

% �����Ƿ񳬳�������ֵ
% totalAsset = h2 .* close2 .* contM2 + h1 .* close1;
% if totalAsset>asset %����������ֵ
%     h1 = h2-1;
% end
hands = [h1,h2];
