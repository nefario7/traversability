function tmp_cell = getCellData(x_cell, idx1, idx2)

tmp_cell = {};
for k = 1:length(x_cell)
    tmp_cell{k,1} = x_cell{k}(:,idx1:idx2);
end 