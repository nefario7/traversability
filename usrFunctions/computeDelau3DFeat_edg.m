function [delauGeoFeatures_cell, delauEdges_cell] = computeDelau3DFeat_edg(pcRaw_cell, action)
%%
if strcmp(action,'load')
    disp('Loading optimal features ...')
    load('./Results/delauEdges_cell.mat')  
    load('./Results/optGeoFeatures_cell.mat')  
    load('./Results/optNeighEdges_cell.mat')
    
elseif strcmp(action,'compute_save')

    disp('Computing delaunay features ...')

    rasterSize = 1;             % Raster size in [m]
   
%%
    % Compute 2D delaunay triangulation
    delauEdges_cell = {};
    delauSize_cell = {};    
    nbIdx_cell = {};
    dist_cell = {};
    max_nnSize = 0;
    for k = 1: length(pcRaw_cell)
        tmpEdges = edges(delaunayTriangulation(pcRaw_cell{k}(:,1), pcRaw_cell{k}(:,2)));
        delauEdges_cell{k,1} = tmpEdges;
        
        tmpEdges1 = fliplr(tmpEdges);
        tmpEdges1 =  sortrows([tmpEdges; tmpEdges1]);
        
        nn_size = accumarray(tmpEdges1(:,1),1);
        %tmp = (1:length(nn_size))';
        delauSize_cell{k,1} = nn_size;%[tmp nn_size];
        
        [~, ~, U] = unique(tmpEdges1(:,1));
        nbIdx = cell2mat(accumarray(U, tmpEdges1(:,2),[], ...
            @(neigh){concatVect(neigh', max(nn_size) + 1)}));
        nbIdx_cell{k,1} = [(1:length(pcRaw_cell{k}))' nbIdx];
        
        tmpDist = getPointDist(pcRaw_cell{k}, tmpEdges1);
        dist_vct = cell2mat(accumarray(U, tmpDist(:,1),[], ...
            @(dist){concatVect(dist', max(nn_size) + 1)}));
        dist_cell{k,1} = [zeros(length(pcRaw_cell{k}),1) dist_vct];
    end
    
    save('./Results/delauEdges_cell.mat', 'delauEdges_cell')

    delauGeoFeatures_cell = {};      % Cell array of features of all points of point clouds
  
    % Compute delaunay Features
    delauGeoFeatures_cell = cellfun(@(pc_cell, nn_cell, nb_cell, dst_cell) ...
        geoFEX_usr(pc_cell, nn_cell, nb_cell, dst_cell, rasterSize), ...
        pcRaw_cell, delauSize_cell, nbIdx_cell, dist_cell,  'UniformOutput',false);
    save('./Results/delauGeoFeatures_cell.mat', 'delauGeoFeatures_cell')

else
    disp('No action specified')
end



end