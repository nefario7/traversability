function [delauGeoFeatures_cell, delauEdges_cell] = computeDelauFeat_edg(pcRaw_cell, action, dimension)
%%
if strcmp(action,'load')
    
    if strcmp(dimension,'2D')
        disp('Loading Weinmann features, 2D delaunay edges...')
        load('./Results/delauEdges_cell.mat')  
        load('./Results/delauGeoFeatures_cell.mat')  
    elseif strcmp(dimension,'3D')
        disp('Loading Weinmann features, 3D delaunay edges...')
        load('./Results/delau3DEdges_cell.mat')  
        load('./Results/delau3DGeoFeatures_cell.mat')  
    end
       
    
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
        if strcmp(dimension,'2D')
            tmpEdges = edges(delaunayTriangulation(pcRaw_cell{k}(:,1), pcRaw_cell{k}(:,2)));
        elseif strcmp(dimension,'3D')
            tmpEdges = edges(delaunayTriangulation(pcRaw_cell{k}(:,1), pcRaw_cell{k}(:,2), pcRaw_cell{k}(:,3)));
        end
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
    
    if strcmp(dimension, '2D')
        save('./Results/delauEdges_cell.mat', 'delauEdges_cell')
    elseif strcmp(dimension, '3D')
        save('./Results/delau3DEdges_cell.mat', 'delauEdges_cell')
    end

    delauGeoFeatures_cell = {};      % Cell array of features of all points of point clouds
  
    % Compute delaunay Features
    delauGeoFeatures_cell = cellfun(@(pc_cell, nn_cell, nb_cell, dst_cell) ...
        geoFEX_usr(pc_cell, nn_cell, nb_cell, dst_cell, rasterSize), ...
        pcRaw_cell, delauSize_cell, nbIdx_cell, dist_cell,  'UniformOutput',false);
    if strcmp(dimension, '2D')
        save('./Results/delauGeoFeatures_cell.mat', 'delauGeoFeatures_cell')
    elseif strcmp(dimension, '3D')
        save('./Results/delau3DGeoFeatures_cell.mat', 'delauGeoFeatures_cell')
    end

else
    disp('No action specified')
end



end