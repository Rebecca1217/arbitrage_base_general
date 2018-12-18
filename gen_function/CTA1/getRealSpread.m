function resSpread = getRealSpread(x, y, z, hg)
%GETREALSPREAD x y z�ֱ��ʾ���ϵ��������жϵĽڵ����

% ��������������resSpreadӦ����1000�����ʲôָ�귢����ʲô��resSpread���������ĵ���
% �þ��������ڶ��Ա�����������1�����Ա�����2�����Ա�����spread�����ϵ����3���������ߵ���Ϊ��������߲㣬�����ж����������Ǹ��ڻ��ǵ�����������
% Ȼ����취���������(��)�ڵĳ̶�

% �жϹ����Ƿ����Եģ�Ҳû���������жϵĶԲ��ԣ��������ȷ���޷����������������ò������spread������������������
% ����˼���ǿ��Խ���ģ�������׼����ģ�͵�Ч�����Ƿ��߼��ɽ��ͣ�������ģ��spread����ĺû��Դ�

% @2018.12.05 ʵ��������Ը߲�̫���ף�PP��������ͬ�ȷŵ������棬����һ��ʼƫ����ߵľ���Ҳ�޷�ƫ���ұ�
% @�������Ľṹ���¶����������Ҫ��̫�ߣ�����������
% @���Ըĳ�ÿ������ͶƱ����ʽ ���������ʱ���ܷ�����ֻ��Ϊ�˷���ۿ�д�ɺ�����ʽ

% @2018.12.7 ����ͶƱ�ṹ���ӱ�����ʱ��ҪС�ģ�ͬ���������̫�࣬�����൱����Ϊ��������������Ȩ��

res = NaN(3, 1);
if x >= 15 % PP ������Խ�ߣ���ΪPP�۸�Խ�ͣ�spreadӦ��Խ��
    res(1) = -1;
else 
    res(1) = 1;
end

if y < 0 % �״����Խ�٣���Ϊ�״��۸�Խ�ߣ�spreadӦ��Խ��
    res(2) = -1;
else
    res(2) = 1;
end
  
if z >= 0 % �״����ڼ۸�Խ�ߣ�spreadӦ��Խ��
    res(3) = -1;
else 
    res(3) = 1;
end

resPlus = size(res(res == 1), 1);
resMinus = size(res(res == -1), 1);

% There may be NaN at the beginning of SpotData, no need to add this restrict
% if resPlus + resMinus ~= size(res, 1)
%     error('Please check the condition which is not complete!')
% end

decideRatio = resPlus / (resPlus + resMinus);
% decideRatio = resPlus / size(res, 1); % �۸��������Ƶ�Ƶ�ʣ�
% 0.8��������500�� 0.6��������200�� 0.4��������300��0.2��������800


profitChg = 0;

if decideRatio >= 0.8
    profitChg = 500;
elseif decideRatio >= 0.6
    profitChg = 200;
elseif decideRatio < 0.2
    profitChg = -800;
elseif decideRatio < 0.4
    profitChg = -800;
end

   
hgChg = evalin('base', 'paraM.hgChg');
% ����ú��������һ����ñ��
if hg <= 50.5
    profitChg = profitChg + hgChg;
end

resSpread = 800 + profitChg;

end

