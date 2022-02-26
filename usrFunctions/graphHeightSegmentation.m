function ptLabels_height = graphHeightSegmentation(ptCloud, graphStructure, action, k)
nNodes = length(ptCloud);
disp('    1) Computing Edges');
disp(graphStructure);
graphEdges = [];
if contains(graphStructure, 'delaunay3D')
    if contains(action,'compute')
        graphEdges = edges(delaunayTriangulation(ptCloud(:,1:3)));
    elseif contains(action, 'load')
        %% TODO
    end
elseif contains(graphStructure, 'delaunay2D')
    if contains(action,'compute')
        graphEdges = edges(delaunayTriangulation(ptCloud(:,1:2)));
    elseif contains(action, 'load')
        %% TODO
    end
elseif contains(graphStructure, 'optimalNeighbors')
    if contains(action,'compute')
        % set up optimal neighbors
        k_min = 10;                 % Minimum neighbors
        k_max = 100;                % Maximum neighbors of a point
        delta_k = 1;
        
        rasterSize = 1;             % Raster size in [m]
        optSize = optNESS(ptCloud, k_min, k_max, delta_k);
        graphEdges = computeOptNeighEdges(ptCloud, optSize);
    elseif contains(action, 'load')
        %% TODO
    end
elseif contains(graphStructure, 'fixed')
    if contains(action, 'load')
        %% TODO
    elseif contains(action, 'compute')
        disp('Compute manually');
    end
end

heightDifference = getHeightDifference(ptCloud(:,3), graphEdges);
ptLabels_height = graphSegmentation(nNodes, graphEdges, heightDifference, k);
end