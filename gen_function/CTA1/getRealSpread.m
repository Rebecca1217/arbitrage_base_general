function resSpread = getRealSpread(x, y, z, hg)
%GETREALSPREAD x y z分别表示从上到下用于判断的节点变量

% 正常的利润中枢resSpread应该是1000，如果什么指标发生了什么，resSpread就做怎样的调整
% 用决策树把众多自变量用起来，1、找自变量，2、看自变量和spread的相关系数，3、相关性最高的作为决策树最高层，往下判断利润中枢是高于还是低于现有中枢
% 然后想办法定义这个高(低)于的程度

% 判断过程是非线性的，也没法衡量你判断的对不对（分类的正确率无法衡量）还是面临拿不合理的spread本身作因变量的这道坎
% 但是思想是可以借鉴的，衡量标准就是模型的效果和是否逻辑可解释，而不是模拟spread本身的好坏对错

% @2018.12.05 实际上相关性高不太靠谱，PP开工率年同比放到最上面，导致一开始偏向左边的就再也无法偏向右边
% @决策树的结构导致顶层变量的重要性太高，决定性作用
% @所以改成每个变量投票的形式 这个函数暂时不能泛化，只是为了方便观看写成函数形式

% @2018.12.7 这种投票结构，加变量的时候要小心，同类变量不能太多，否则相当于人为给这类变量提高了权重

res = NaN(3, 1);
if x >= 15 % PP 开工率越高，认为PP价格越低，spread应该越低
    res(1) = -1;
else 
    res(1) = 1;
end

if y < 0 % 甲醇库存越少，认为甲醇价格越高，spread应该越低
    res(2) = -1;
else
    res(2) = 1;
end
  
if z >= 0 % 甲醇进口价格越高，spread应该越低
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
% decideRatio = resPlus / size(res, 1); % 价格中枢上移的频率：
% 0.8以上上移500， 0.6以上上移200； 0.4以下下移300，0.2以下下移800


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
% 最后用宏观条件盖一个大帽子
if hg <= 50.5
    profitChg = profitChg + hgChg;
end

resSpread = 800 + profitChg;

end

