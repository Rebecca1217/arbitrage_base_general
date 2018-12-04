function resSpread = getRealSpread(x, y, z, hg)
%GETREALSPREAD x y z分别表示从上到下用于判断的节点变量

% 正常的利润中枢resSpread应该是1000，如果什么指标发生了什么，resSpread就做怎样的调整
% 用决策树把众多自变量用起来，1、找自变量，2、看自变量和spread的相关系数，3、相关性最高的作为决策树最高层，往下判断利润中枢是高于还是低于现有中枢
% 然后想办法定义这个高(低)于的程度

% 判断过程是非线性的，也没法衡量你判断的对不对（分类的正确率无法衡量）还是面临拿不合理的spread本身作因变量的这道坎
% 但是思想是可以借鉴的，衡量标准就是模型的效果和是否逻辑可解释，而不是模拟spread本身的好坏对错

if x >= 15 % PP 开工率越高，认为PP价格越低，spread应该越低
    if y < 0 % 甲醇库存越少，认为甲醇价格越高，spread应该越低
        if z >= 0 % 甲醇进口价格越高，spread应该越低
            profitChg = -800;
        else
            profitChg = 200;
        end
            
    else % y >=0 
        if z >= 0 % 加入这层判断是因为不能保证最上层x是最重要的，事实上这里可以修改为平级投票模式
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
% 最后用宏观条件盖一个大帽子
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

