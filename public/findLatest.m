function res = findLatest(findTarget, universe)
%FINDLATEST findTarget表示需要匹配的元素，比如20130303, universe表示用于匹配的表，
% 第一列是findTarget进去查询的变量（20130303）， 第二列是要返回的目标结果
% 每次查询都是向上查询，不是相对距离最近的结果。
% universe 的第一列必须是从小到大排列的

universe = sortrows(universe, 1);

qualifiedUniv = universe(table2array(universe(:, 1)) <= findTarget, :);

if ~isempty(qualifiedUniv)
    res = table2array(qualifiedUniv(end, 2));
else
    res = NaN;
end

end

