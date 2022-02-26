function [optSize_cell, optGeoFeatures_cell, optNeighEdges_cell] = computeOptFeat_Edg(pcRaw_cell, action)

%%
if contains(action,'load')
    disp('Loading optimal features ...')
    load('./Results/optSize_cell.mat')  
    load('./Results/optGeoFeatures_cell.mat')  
    load('./Results/optNeighEdges_cell.mat')
    
elseif contains(action,'compute')

    disp('Computing optimal features ...')

    % set up
    k_min = 10;                 % Minimum neighbors 
    k_max = 100;                % Maximum neighbors of a point
    delta_k = 1; 

    rasterSize = 1;             % Raster size in [m]

    optSize_cell = {};          % Cell array of point clouds in the ISPR data set
    optGeoFeatures_cell = {};      % Cell array of features of all points of point clouds

    % Compute optimal Neighbor
    optSize_cell = cellfun(@(pc_cell) optNESS(pc_cell, k_min, k_max, delta_k), ...
        pcRaw_cell, 'UniformOutput',false);
    if contains(action, '_save')
        save('./Results/optSize_cell.mat', 'optSize_cell')
    end

    % Compute optimal Features
    optGeoFeatures_cell = cellfun(@(pc_cell, nn_cell) geoFEX(pc_cell, nn_cell, rasterSize), ...
        pcRaw_cell, optSize_cell, 'UniformOutput',false);
    if contains(action, '_save')
        save('./Results/optGeoFeatures_cell.mat', 'optGeoFeatures_cell')
    end

    % Compute optimal neighbor edges

    optNeighEdges_cell = cellfun(@(pc_cell, nn_cell) computeOptNeighEdges(pc_cell, nn_cell), ...
        pcRaw_cell, optSize_cell, 'UniformOutput',false);
    if contains(action, '_save')
        save('./Results/optNeighEdges_cell.mat', 'optNeighEdges_cell')
    end

else
    disp('No action specified')
end

end