function ifErrorStop(w_edb_errorid)
%IFERRORSTOP 此处显示有关此函数的摘要
%   此处显示详细说明

if w_edb_errorid ~= 0
    error('Get Wind Data Error')
end

