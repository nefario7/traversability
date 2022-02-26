function [pcRawISPRS_cell, geoFeaturesISPRS_cell, adjMatrix_cell, edges_cell] = computeAdjMatrix(pc_cell, geoFeatures_cell, action)

pcRawISPRS_cell = {};
geoFeaturesISPRS_cell = {};
adjMatrix_cell = {};
edges_cell = {};

minimumLength = inf;
if strcmp(action,'resize')
    for k = 1: length(pc_cell)
        tmpLenght = length(pc_cell{k});
        if tmpLenght <= minimumLength
            minimumLength = tmpLenght;
        end
    end
else 
    disp('No rezising action')
end

for k = 1: length(pc_cell)
    nPoints = length(pc_cell{k});
    tmpEdges = [];
    tmpGraph = [];
    
    if nPoints > minimumLength
        randomIdx = randsample(nPoints,minimumLength);
        pcRawISPRS_cell{k,1} = pc_cell{k}(randomIdx,:);
        geoFeaturesISPRS_cell{k,1} = geoFeatures_cell{k}(randomIdx,:);
        
        [tmpEdges, tmpGraph] = getEdgesGraph(pc_cell{k}(randomIdx,1), pc_cell{k}(randomIdx,2));
    else
        pcRawISPRS_cell{k,1} = pc_cell{k};
        geoFeaturesISPRS_cell{k,1} = geoFeatures_cell{k};
        
        [tmpEdges, tmpGraph] = getEdgesGraph(pc_cell{k}(:,1), pc_cell{k}(:,2));
    end
    
    edges_cell{k,1} = tmpEdges;
    adjMatrix_cell{k,1} = adjacency(tmpGraph);
    
end

    function [tmpEdges, tmpGraph] = getEdgesGraph(pcX, pcY)
         pcDelaunay = delaunayTriangulation(pcX, pcY);
         tmpEdges = edges(pcDelaunay);
         tmpGraph = graph(tmpEdges(:,1), tmpEdges(:,2));
    end


end