function mat3 =sub_mat_prod(mat1, mat2)
siz_mat =size(mat1);
if length(siz_mat)==2 % incase mat1 is only 2-D
    siz_mat =[siz_mat, 1];
end

mat3 =zeros(siz_mat(1), size(mat2, 2) ,siz_mat(end));
for sub_n =1:siz_mat(end)
    mat3(:,:, sub_n) =double(mat1(:,:, sub_n))*mat2;
end