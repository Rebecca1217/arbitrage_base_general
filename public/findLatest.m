function res = findLatest(findTarget, universe)
%FINDLATEST findTarget��ʾ��Ҫƥ���Ԫ�أ�����20130303, universe��ʾ����ƥ��ı�
% ��һ����findTarget��ȥ��ѯ�ı�����20130303���� �ڶ�����Ҫ���ص�Ŀ����
% ÿ�β�ѯ�������ϲ�ѯ��������Ծ�������Ľ����
% universe �ĵ�һ�б����Ǵ�С�������е�

universe = sortrows(universe, 1);

qualifiedUniv = universe(table2array(universe(:, 1)) <= findTarget, :);

if ~isempty(qualifiedUniv)
    res = table2array(qualifiedUniv(end, 2));
else
    res = NaN;
end

end

