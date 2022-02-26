function [weinFeatGspbox_cell, gspBoxEdges_cell] = computeGspBoxFeat_edg(pcRaw_cell, action)

%%
if strcmp(action,'load')
    disp('Loading Weinmann features, gspBox edges...')
    load('./Results/weinFeatGspbox_cell.mat', 'weinFeatGspbox_cell');
    load('./Results/gspBoxEdges_cell.mat', 'gspBoxEdges_cell')
    
    
elseif contains(action,'compute')
    
    disp('Computing gspBox features ...')
    
    rasterSize = 1;             % Raster size in [m]
    
    % Compute 2D delaunay triangulation
    gspBoxEdges_cell = {};
    gspBoxSize_cell = {};
    nbIdx_cell = {};
    dist_cell = {};
    max_nnSize = 0;
    for k = 1: length(pcRaw_cell)
        param.type = 'knn';
        param.rescale = 0;
        param.center = 0;
        pcX = pcRaw_cell{k}(:,1);
        pcY = pcRaw_cell{k}(:,2);
        pcZ = pcRaw_cell{k}(:,3);
        
        %Compute graph from points (ineficient)
        G = gsp_nn_graph([pcX, pcY, pcZ], param);
        G = graph(G.A);
        
        tmpEdges = table2array(G.Edges);

        gspBoxEdges_cell{k,1} = tmpEdges;
        
        tmpEdges1 = fliplr(tmpEdges);
        tmpEdges1 =  sortrows([tmpEdges; tmpEdges1]);
        
        nn_size = accumarray(tmpEdges1(:,1),1);
        %tmp = (1:length(nn_size))';
        gspBoxSize_cell{k,1} = nn_size;%[tmp nn_size];
        
        [~, ~, U] = unique(tmpEdges1(:,1));
        nbIdx = cell2mat(accumarray(U, tmpEdges1(:,2),[], ...
            @(neigh){concatVect(neigh', max(nn_size) + 1)}));
        nbIdx_cell{k,1} = [(1:length(pcRaw_cell{k}))' nbIdx];
        
        tmpDist = getPointDist(pcRaw_cell{k}, tmpEdges1);
        dist_vct = cell2mat(accumarray(U, tmpDist(:,1),[], ...
            @(dist){concatVect(dist', max(nn_size) + 1)}));
        dist_cell{k,1} = [zeros(length(pcRaw_cell{k}),1) dist_vct];
    end
    
    if contains(action, '_save')
        save('./Results/gspBoxEdges_cell.mat', 'gspBoxEdges_cell')
    end
    
    weinFeatGspbox_cell = {};      % Cell array of features of all points of point clouds
    
    % Compute delaunay Features
    weinFeatGspbox_cell = cellfun(@(pc_cell, nn_cell, nb_cell, dst_cell) ...
        geoFEX_usr(pc_cell, nn_cell, nb_cell, dst_cell, rasterSize), ...
        pcRaw_cell, gspBoxSize_cell, nbIdx_cell, dist_cell,  'UniformOutput',false);
    
    if contains(action, '_save')
        save('./Results/weinFeatGspbox_cell.mat', 'weinFeatGspbox_cell')
    end
    
else
    disp('No action specified')
end





end
