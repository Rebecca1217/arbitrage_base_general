function sigLi = lossStop(sigLi, tddata, beta, lossRatio, Cost, oriAsset)
%LOSSSTOP �������źŽ���ֹ�����

% ����daily PL

% ���׳ɱ�
fixC = Cost.fix;
slip = Cost.float;
unit1 = Cost.unit1; %��С�䶯��λ
unit2 = Cost.unit2;
contM1 = Cost.contM1; %��Լ����
contM2 = Cost.contM2;

% �۸�����
closedata = tddata(:,3:4); %���̼�
tddata = tddata(:,1:2); %�ɽ���
tddata1 = tddata(:,1); %��һ��Ʒ��
tddata2 = tddata(:,2); %�ڶ���Ʒ��

Ratio = beta;

% �ز�
tdList = zeros(size(tddata, 1),9); % ��ӵھ��У���ʾһ�ν��ף��ź����䣩���ۼ�ӯ��
num = size(sigLi,1);
asset = oriAsset;
tdList(1:sigLi(1,2),8) = asset;
for i = 1:num %����źż���
%     disp(i)
    opL = sigLi(i,2); %�����ź�������
    clL = sigLi(i,3); %ƽ���ź�������
    sgn1 = sigLi(i,1); %���ַ���-��һ��Ʒ�ֵķ���
    sgn2 = -sigLi(i,1); %���ַ���-�ڶ���Ʒ�ֵķ���
    sgn = sigLi(i,1);
    if clL-opL>1 %���ǵ������¸�ƽ�����
        tdList(opL+1:clL-1,1) = sgn;
        tdList(opL+1,2) = 2-sgn; %��տ�
        tdList(clL,2) = 3-sgn; %���ƽ
        % ��������ÿ����ƽ��
        chgH1 = 0;
        chgH2 = 0;
        for d = opL:clL-1
            % ���㿪������
            hands = calOpenHands(closedata(d,:),Ratio(d),asset,contM1,contM2); %��ǰһ������̼�ȥ���㵱�������
            if d==opL %����ʱ������
                h1 = hands(1);
                h2 = hands(2);
            end
            if d>opL %����ڿ���ʱ�����ı仯
                chgH1 = hands(1)-h1;
                chgH2 = hands(2)-h2;
            end
            if abs(chgH1)>2 || abs(chgH2)>2 %����Ʒ��������һ���ĳֲ������仯����2�֣�������Ʒ��һ�����
                tdList(d+1,5) = hands(1);
                tdList(d+1,6) = hands(2);
                h1 = hands(1);
                h2 = hands(2);
            else
                tdList(d+1,5) = h1;
                tdList(d+1,6) = h2;
            end
        end
        % ���˵õ���һ���źŶ��ڵ�ȫ������
        % ����ÿ������
        d = opL + 1;
        while d <= clL
            % Ʒ�ֱַ���к��㣬Ȼ�����
            h1 = tdList(d,5);
            h2 = tdList(d,6);
            if d==opL+1 %����
                % Ʒ��1
                op1 = (tddata1(d)+sgn1*slip*unit1)*(1+sgn1*fixC)*contM1*h1; %���ּ�
                cl1 = closedata(d,1)*contM1*h1; %����ƽ�ּ�
                % Ʒ��2
                op2 = (tddata2(d)+sgn2*slip*unit2)*(1+sgn2*fixC)*contM2*h2; %���ּ�
                cl2 = closedata(d,2)*contM2*h2; %����ƽ�ּ�
                % ����ӯ��
                tdList(d,7) = (-sgn1*op1+sgn1*cl1)+(-sgn2*op2+sgn2*cl2);
                % ���ν��ף�һ���ºŶΣ��ۼ�ӯ��
                tdList(d, 9) = tdList(d - 1, 9) + tdList(d, 7);
                tdList(d,8) = asset+tdList(d,7); %�ۼ���ֵ
                % ���ּ۲�
                tdList(d,3) = op1-op2;
                if (tdList(d, 9) / oriAsset) < (-lossRatio)
                sigLi(i, 3) = d;
                clL = d;
                end
            elseif d>opL+1 && d<=clL %�ǿ�ƽ����
                % Ʒ��1
                hChg1 = h1-tdList(d-1,5); %�����仯
                op1 = closedata(d-1,1)*contM1*h1; %��ǰһ������̼ۿ���
                cl1 = closedata(d,1)*contM1*h1; %����ƽ�ּ�
                %                 opChg1 = (tddata1(d)+sgn1*slip*unit1)*(1+sgn1*fixC)*contM1*hChg1; %���ּ�
                % �о�����ط������㣬��Ҫ���ǽ�ȥhChg1�ķ���
                opChg1 = (tddata1(d)+sgn1*slip*unit1 * sign(hChg1))*(1+sgn1*fixC)*contM1*hChg1; %���ּ�
                clChg1 = closedata(d,1)*contM1*hChg1; %ƽ�ּ�
                % Ʒ��2
                hChg2 = h2-tdList(d-1,6); %�����仯
                op2 = closedata(d-1,2)*contM2*h2; %��ǰһ������̼ۿ���
                cl2 = closedata(d,2)*contM2*h2; %����ƽ�ּ�
                %                 opChg2 = (tddata2(d)+sgn2*slip*unit2)*(1+sgn2*fixC)*contM2*hChg2; %���ּ�
                opChg2 = (tddata2(d)+sgn2*slip*unit2 * sign(hChg2))*(1+sgn2*fixC)*contM2*hChg2; %���ּ�
                clChg2 = closedata(d,2)*contM2*hChg2; %ƽ�ּ�
                % ����ӯ��
                tdList(d,7) = (-sgn1*op1+sgn1*cl1)+(-sgn1*opChg1+sgn1*clChg1)+...
                    (-sgn2*op2+sgn2*cl2)+(-sgn2*opChg2+sgn2*clChg2);
                tdList(d,8) = tdList(d-1,8)+tdList(d,7); %�ۼ���ֵ
                % ���ν��ף�һ���ºŶΣ��ۼ�ӯ��
                tdList(d, 9) = tdList(d - 1, 9) + tdList(d, 7);
                
                if tdList(d, 9) / oriAsset < (-lossRatio)
                sigLi(i, 3) = d;
                clL = d;
                end
            end
            if d==clL %ƽ��
                % ƽ�ֵ�ʱ��Ҫ�ѵڶ���ƽ�ִ�����������㵽�����һ������
                % �и����⣬������ñ���������һ�췢����ƽ���źţ��ǵڶ������ϵĿ��̼�û�����ݰ�
                % ��Ϊ����ط��Ѿ���һ����Լ��ȫ�����������ˣ��ڶ����û�н����ˣ�����Ҳû����windȡ����
                % ��������������һ�췢��ƽ���źŵĻ�����ֱ����ǰ��ǰһ��Ϳ����ˣ���Ϊ��һ�����ź������ʱ���ѷ������������Щ�����������Ӱ�����ս����
                % Ʒ��1
                op1 = closedata(d,1)*contM1*h1; %��ǰһ������̼ۿ���
                % Ʒ��2
                op2 = closedata(d,2)*contM2*h2;
                % ƽ�ּ۲�
                tdList(d,4) = op1-op2;
                
                if d < size(tddata1, 1)
                    cl1 = (tddata1(d+1)-sgn1*slip*unit1)*(1-sgn1*fixC)*contM1*h1; %ƽ�ּ�
                    cl2 = (tddata2(d+1)-sgn2*slip*unit2)*(1-sgn2*fixC)*contM2*h2;
                else
                    % ������������һ���ˣ�ֱ�Ӹĺ���������
                    sigLi(i, 3) = sigLi(i, 3) - 1; % ƽ������Ųһ��
                    clL = sigLi(i, 3);
                    d = d + 1;
                    break % �������ʱ������һ��ƽ�֣��Ͱ�ƽ��������Ųһ�У�Ҳ���ü���ֹ���ˣ�����ȥ
%                     cl1 = (tddata1(d)-sgn1*slip*unit1)*(1-sgn1*fixC)*contM1*h1; %ƽ�ּ�;
%                     cl2 = (tddata2(d)-sgn2*slip*unit2)*(1-sgn2*fixC)*contM2*h2;
                end
                % ����ӯ��(ƽ��û����Ų�����������Ųһ���Ȳ����ˣ���Ϊ�����һ���ֹ��ƽ�ֵĻ�����һ���ʱ���ֹ���ˣ��ⲿ�ֵ����治���棬�ز�ƽ̨������������)
                tdList(d,7) = tdList(d,7)+(-sgn1*op1+sgn1*cl1)+(-sgn2*op2+sgn2*cl2);
                tdList(d,8) = tdList(d,8)+(-sgn1*op1+sgn1*cl1)+(-sgn2*op2+sgn2*cl2);
                tdList(d,9) = tdList(d,9) + (-sgn1*op1+sgn1*cl1) + (-sgn2*op2+sgn2*cl2);
                
                if (tdList(d, 9) / oriAsset) < (-lossRatio)
                sigLi(i, 3) = d;
                clL = d;
                end
            end
            d = d + 1;
        end
    end
     % �������¸�ƽ����Ҫֹ����tdList��Ϊ�˼���ӯ��ֹ���õģ��������ﲻ��Ҫ����tdList
     % ��Ϊֹ��ֻ�����ν��ף������Ҫ���ۼƾ�ֵֹ��Ļ�����ÿһ�ʶ���Ҫ����
     % �����Ҫ�����ʱ��clL�Ƿ������һ����Ҫ����Դ������һ���ƽ�ּ�����һ�쿪�̼ۣ��ò���������
     
    % ��ֵ����
    asset = tdList(clL,8);
    % ��ֵ���
    if i<num
        tdList(clL+1:sigLi(i+1,2),8) = asset;
    else
        tdList(clL:end,8) = asset;
    end
    
    
    % �ж��Ƿ�ֹ������ﵽ����������ƣ�������ź��˳�����
%     if tdList(d, 9) / oriAsset < (-lossRatio)
%         sigLi(i, 3) = d;
%     end
    
end

end

