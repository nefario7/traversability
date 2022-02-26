function treeSegments = removeQSegments(treeSegments, q1, q2)

[labels, ~, ic] = unique(treeSegments, 'sort');
idx_zero = labels == 0;
tmpLabels = labels(~idx_zero);

segmentSize = [];
for k = 1:max(labels)
   idx_1 = treeSegments == k;
   segmentSize = [segmentSize; sum(idx_1)];
end

Q1 = quantile(segmentSize, q1);
Q2 = quantile(segmentSize, q2);

idx_1 = segmentSize >= Q1;
idx_2 = segmentSize <= Q2;
idx = idx_1 & idx_2;
tmpLabels(~idx) = 0;
% tmpLabels(idx_1) = 1;
labels(~idx_zero) = tmpLabels;
labels = labels(ic);
idx_zero = labels == 0;
tmpLabels = labels(~idx_zero);
[~, ~, ic] = unique(tmpLabels, 'sort');

labels(~idx_zero) =ic;


treeSegments = labels;
