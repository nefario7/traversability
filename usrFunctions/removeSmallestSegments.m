function treeSegments = removeSmallestSegments(treeSegments)

for k = max(treeSegments)
   idx = treeSegments ==k;
   if sum(idx) < 60
       treeSegments(idx) = 0;
   end
end

idx_zero = treeSegments == 0;

tmpSegments = treeSegments(~idx_zero);
[~, ~, ic] = unique(tmpSegments, 'stable');

treeSegments(~idx_zero) = ic;