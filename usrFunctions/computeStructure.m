function E = computeStructure(ptCloud, structure_flag, isprs_sample, action, set, dataQuality)

switch nargin
    case 1
        structure_flag = 'delaunay2D';
        isprs_sample = nan;
        action = 'compute';
        set = '_';
    case 2
        isprs_sample = nan;
        action = 'compute';
        set = '_';
    case 3
        action = 'compute';
        set = '_';
end


if strcmp(action,'load')
    load(['./Results/CRF_Forest/ieeeCorrections/' dataQuality , structure_flag, ...
        'Edges', mat2str(isprs_sample), '_', set ,'.mat'], 'E');

    disp('graph structure loaded ...')
    
elseif contains(action,'compute')
    
    disp(['Computing ', structure_flag,' structure ', set])
    
    E = [];
    optSize = [];          % Cell array of point clouds in the ISPR data set
    rasterSize = 1;             % Raster size in [m]
    
    
    if strcmp(structure_flag, 'optGeo')
        k_min = 10;                 % Minimum neighbors
        k_max = 100;                % Maximum neighbors of a point
        delta_k = 1;
        
        
        % Compute optimal Neighbor
        optSize = optNESS(ptCloud, k_min, k_max, delta_k);
        
        % Compute optimal neighbor edges
        E = computeOptNeighEdges(ptCloud, optSize);
        
        disp('Saving optNeig data for feature computation');
        save('./optSize', 'optSize');
        
    else
        if contains(structure_flag, 'delaunay')
            
            if contains(structure_flag, '2D')
                E = edges(delaunayTriangulation(ptCloud(:,1), ptCloud(:,2)));
            elseif contains(structure_flag, '3D')
                E = edges(delaunayTriangulation(ptCloud(:,1), ptCloud(:,2), ptCloud(:,3)));
            end
            
        elseif contains(structure_flag, 'gspBox')
            param.type = 'knn';
            param.rescale = 0;
            param.center = 0;
            
            G = gsp_nn_graph([ptCloud(:,1), ptCloud(:,2), ptCloud(:,3)], param);
            G = graph(G.A);
            
            E = table2array(G.Edges);
        end
        tmpEdges1 = fliplr(E);
        tmpEdges1 =  sortrows([E; tmpEdges1]);
        
        nn_size = accumarray(tmpEdges1(:,1),1);
        
        [~, ~, U] = unique(tmpEdges1(:,1));
        nbIdx = cell2mat(accumarray(U, tmpEdges1(:,2),[], ...
            @(neigh){concatVect(neigh', max(nn_size) + 1)}));
        nbIdx_vct = [(1:length(ptCloud))' nbIdx];
        
        tmpDist = getPointDist(ptCloud, tmpEdges1);
        dist_vct = cell2mat(accumarray(U, tmpDist(:,1),[], ...
            @(dist){concatVect(dist', max(nn_size) + 1)}));
        dist_vct = [zeros(length(ptCloud),1) dist_vct];
        disp('Saving delaunay data for feature computation');
        
        save('./nn_size', 'nn_size');
        save('./nbIdx_vct', 'nbIdx_vct');
        save('./dist_vct', 'dist_vct');
    end
    
    disp([structure_flag,' structure computed ', set])
    
    if contains(action,'save')
        save(['./Results/CRF_Forest/ieeeCorrections/' dataQuality , structure_flag, 'Edges', mat2str(isprs_sample), '_', set ,'.mat'], 'E')
        disp(['Structure saved: ', ...
            './Results/CRF_Forest/ieeeCorrections/' dataQuality , structure_flag, 'Edges', mat2str(isprs_sample), '_', set ,'.mat'])
    end
    
else
    disp('No action specified')
end
end