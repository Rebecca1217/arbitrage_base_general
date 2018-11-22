function res = zStandard(inputSeries)
%ZSTANDARD zֵ��׼��������ֵ���Ա�׼��

mu = mean(inputSeries, 'omitnan');
sigma = std(inputSeries, 'omitnan');

res = (inputSeries - mu) ./ sigma;

end

