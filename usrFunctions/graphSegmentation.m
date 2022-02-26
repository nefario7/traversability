function nodeLabels = graphSegmentation(nNodes, edges, edgeWeight, k_graph)
% % %%
% % nRows = 3;
% % nCols = 4;
% % nNodes = nRows*nCols;
% % 
% % % Create graph structure
% % adj = zeros(nNodes,nNodes);
% % 
% % % Add Down Edges
% % ind = 1:nNodes;
% % exclude = sub2ind([nRows nCols],repmat(nRows,[1 nCols]),1:nCols); % No Down edge for last row
% % ind = setdiff(ind,exclude);
% % adj(sub2ind([nNodes nNodes],ind,ind+1)) = 1;
% % 
% % % Add Right Edges
% % ind = 1:nNodes;
% % exclude = sub2ind([nRows nCols],1:nRows,repmat(nCols,[1 nRows])); % No right edge for last column
% % ind = setdiff(ind,exclude);
% % adj(sub2ind([nNodes nNodes],ind,ind+nRows)) = 1;
% % 
% % % Add Up/Left Edges
% % adj = adj+adj';
% % G = graph(adj);
% % 
% % edges = table2array(G.Edges);
% % edges = edges(:,1:2);
% % nodeWeight = [12; 13; 12; 14; 16; 40; 12; 110; 14; 12; 90; 100];
% % edgeWeight = [abs(nodeWeight(edges(1:12,1)) - nodeWeight(edges(1:12,2))); ...
% %     abs(nodeWeight(edges(13:17,1)) - nodeWeight(edges(13:17,2)))];

%%

% sort  edges in non-decreasing order by edge weights
% edges and edgeWeight must be column vectors
tmp_mtx = sortrows([edgeWeight, edges], 1);
edges = tmp_mtx(:,2:3);
edgeWeight = tmp_mtx(:,1);

%initialize internal component difference (all nodes are consider as components)
Int = zeros(nNodes, 1);
nodeLabels = (1:nNodes)';
nComponents = ones(nNodes,1);
% k_graph = 100;

for k = 1 : length(edgeWeight)
    w_ij = edgeWeight(k);
    e_i = edges(k,1);
    e_j = edges(k,2);
    
    % compare for two disjoint components
    if nodeLabels(e_i) < nodeLabels(e_j)
        tau_i = nComponents(nodeLabels(e_i));
        tau_j = nComponents(nodeLabels(e_j));
        mInt_i = Int(nodeLabels(e_i)) + k_graph/tau_i;
        mInt_j = Int(nodeLabels(e_j)) + k_graph/tau_j;
        minInt = min([mInt_i, mInt_j]);
        
        if w_ij <= minInt
           % update nComponents
           nComponents(nodeLabels(e_i)) = nComponents(nodeLabels(e_i)) + nComponents(nodeLabels(e_j));
           % merge components
           nodeLabels(nodeLabels==nodeLabels(e_j)) = nodeLabels(e_i);
           % update internal component difference
           if Int(nodeLabels(e_i)) < w_ij
               Int(nodeLabels(e_i)) = w_ij;
           end
        end
    end
    
    if nodeLabels(e_j) < nodeLabels(e_i)
        tau_i = nComponents(nodeLabels(e_i));
        tau_j = nComponents(nodeLabels(e_j));
        mInt_i = Int(nodeLabels(e_i)) + k_graph/tau_i;
        mInt_j = Int(nodeLabels(e_j)) + k_graph/tau_j;
        minInt = min([mInt_i, mInt_j]);
        
        if w_ij <= minInt
           % update nComponents
           nComponents(nodeLabels(e_j)) = nComponents(nodeLabels(e_j)) + nComponents(nodeLabels(e_i));
           % merge components
           nodeLabels(nodeLabels==nodeLabels(e_i)) = nodeLabels(e_j);
           % update internal component difference
           if Int(nodeLabels(e_j)) < w_ij
               Int(nodeLabels(e_j)) = w_ij;
           end
        end
    end
end

[labels, ~, U] = unique(nodeLabels);
nLabels = length(labels);
labels_tmp = (1:nLabels)';
nodeLabels = labels_tmp(U);


end