function resSpread = getRealSpread(x, y, z, hg)
%GETREALSPREAD x y z�ֱ��ʾ���ϵ��������жϵĽڵ����

% ��������������resSpreadӦ����1000�����ʲôָ�귢����ʲô��resSpread���������ĵ���
% �þ��������ڶ��Ա�����������1�����Ա�����2�����Ա�����spread�����ϵ����3���������ߵ���Ϊ��������߲㣬�����ж����������Ǹ��ڻ��ǵ�����������
% Ȼ����취���������(��)�ڵĳ̶�

% �жϹ����Ƿ����Եģ�Ҳû���������жϵĶԲ��ԣ��������ȷ���޷����������������ò������spread������������������
% ����˼���ǿ��Խ���ģ�������׼����ģ�͵�Ч�����Ƿ��߼��ɽ��ͣ�������ģ��spread����ĺû��Դ�

if x >= 15 % PP ������Խ�ߣ���ΪPP�۸�Խ�ͣ�spreadӦ��Խ��
    if y < 0 % �״����Խ�٣���Ϊ�״��۸�Խ�ߣ�spreadӦ��Խ��
        if z >= 0 % �״����ڼ۸�Խ�ߣ�spreadӦ��Խ��
            profitChg = -800;
        else
            profitChg = 200;
        end
            
    else % y >=0 
        if z >= 0 % ��������ж�����Ϊ���ܱ�֤���ϲ�x������Ҫ�ģ���ʵ����������޸�Ϊƽ��ͶƱģʽ
        profitChg = 0;
        else % z <0
            profitChg = 300;
        end
    end  
else  % x < 15
    if y < 0
        if z >= 0
        profitChg = -300;
        else % z < 0
            profitChg = 0;
        end
    else % y >= 0
        if z >= 0
            profitChg = 200;
        else % z < 0
            profitChg = 500;
        end
    end
    
   
end

hgChg = evalin('base', 'paraM.hgChg');
% ����ú��������һ����ñ��
if hg <= 50.5
    profitChg = profitChg + hgChg;
end

resSpread = 800 + profitChg;

% if ratio < 0
%     resSpread = -500;
% elseif ratio < 0.7
%     resSpread = 800;
% else 
%     resSpread = 1200;
% end

end

