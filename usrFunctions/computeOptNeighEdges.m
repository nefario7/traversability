function optNeighEdges = computeOptNeighEdges(ptCloud, nn_size)

k_plus_1 = max(nn_size)+1;
[idx1, ~] = knnsearch(ptCloud, ptCloud, 'Distance', 'euclidean', 'NSMethod', 'kdtree', 'K', k_plus_1);

tmpEdges = [];

tmpEdges = cell2mat((arrayfun(@(k) sort([k*ones(nn_size(k), 1) idx1(k,2:nn_size(k)+1)']), ...
    1:length(idx1), 'UniformOutput',false))');

[~, idx, ~] = unique(sort(tmpEdges,2), 'stable', 'rows');
optNeighEdges = tmpEdges(idx,:);

% tmpgraph = graph(tmpEdges(:,1), tmpEdges(:,2));
% spy(adjacency(tmpgraph))
% tmpgraph1= graph(tmpEdges1(:,1), tmpEdges1(:,2));
% figure
% spy(adjacency(tmpgraph1))
end

