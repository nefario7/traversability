function infer_results = inferOccludedPoints(pcZ, zLabels, pcEdges)
%% zero -> ground
%% one -> noground
%%
lambda_0 = 100;
lambda_1 = 1;

% set all edges of nodes
pcEdges_tmp = fliplr(pcEdges);
pcEdges_vct =  sortrows([pcEdges; pcEdges_tmp]);

% create a graph object
G = graph(pcEdges(:,1), pcEdges(:,2));
L = laplacian(G);
cols = 1:length(pcZ);
rows = 1:length(pcZ);
I = sparse(rows, cols, ones(1,length(pcZ)));
% compute the neighbor cell for each node
[~, ~, U] = unique(pcEdges_vct(:,1));
neigh_cell = accumarray(U, 1:size(pcEdges_vct,1),[],@(r){pcEdges_vct(r,2)});

p_1 = double(zLabels);
p_0 = 1 - p_1;

% initial ground guess
g_t = pcZ;
%%
for EM_steps = 1:10
    neighbors_mean = (arrayfun(@(k) mean(g_t(neigh_cell{k})), 1:size(neigh_cell,1)))';
    
    E_results = expectation(lambda_0, lambda_1, p_1, p_0, neighbors_mean, g_t, pcZ);
    W_1 = E_results{1};
    wi_1 = E_results{2};  %% probability of non--groun points given, point clssification and point elevation
    g_t = maximization(lambda_0, lambda_1, W_1, L, I, pcZ);    
    infer_results = [g_t, wi_1];
%     EM_steps
end

    function E_results  = expectation(lambda_0, lambda_1, p_1, p_0, neighbors_mean, g_t, pcZ)
        p_gi1 = p_1.*exp(-0.5*lambda_1*(g_t - neighbors_mean).^2);        
        p_gi0 = p_0.*exp(-0.5*lambda_0*(g_t - pcZ).^2);
                
        w_i = (p_gi1)./(p_gi1 + p_gi0);
        n = (1:length(w_i))';
        W = sparse(n,n,w_i);
        E_results = {W, w_i};
    end

    function g_t1 = maximization(lambda_0, lambda_1, W, L, I, pcZ)
        
        A = [sqrt(lambda_0*(I - W)); sqrt(lambda_1*W)*L];
        b = [sqrt(lambda_0*(I - W))*pcZ; zeros(size(A,1) - size(pcZ,1),1)];
        g_t1 = lsqminnorm(A,b);
    end
end