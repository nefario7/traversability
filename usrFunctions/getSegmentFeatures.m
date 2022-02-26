function nodeSegmentFeatures = getSegmentFeatures(ptCloud, normHeight, nodeLabels)
%% Features
% average normalized segment height
% variance of normalized segment height 
% average angle of segment normal vector to xy plane
% variance angle of segment normal vector to xy plane 
% Height difference between segments
% Variance of height difference
% Angle difference between segment normal vectors
% variance of angle difference 
% relative height to minimun average segment height 

% % % ptCloud = [pcX, pcY, pcZ];
% % % nodeLabels = nodeLabelSlope_opGeo;

%% compute normal vectors
pcNormals = pcnormals(pointCloud(ptCloud));

%% group points with the same label

[~, ~, U] = unique(nodeLabels(:,1));

segmentHeight_cell = accumarray(U, 1:size(nodeLabels,1),[],@(r){ptCloud(r,3)});
segmentNormHeight_cell = accumarray(U, 1:size(nodeLabels,1),[],@(r){normHeight(r,1)});
segmentNormals_cell = accumarray(U, 1:size(nodeLabels,1),[],@(r){pcNormals(r,:)});

avrSegmentHeight = cellfun(@mean, segmentHeight_cell);
varSegmentNormHeight = cellfun(@var, segmentNormHeight_cell);
avrSegmentNormHeight = cellfun(@mean, segmentNormHeight_cell);


neighSeg_cell = findNeighborSegments(nodeLabels);

[avrSegRH, varSegRH] = getRelativeHeight(avrSegmentNormHeight, neighSeg_cell);

minAvrSegHeight = min(avrSegmentHeight);
relHeight =  ptCloud(:,3) - minAvrSegHeight; 

normalAngles = cellfun(@(nCell) computeNormalsAngle(nCell), segmentNormals_cell, ...
    'UniformOutput', false);
avrAngSegNormals = cellfun(@mean, normalAngles);
varAngSegNormals = cellfun(@mean, normalAngles);

nodeSegmentFeatures = [avrSegmentNormHeight(U), varSegmentNormHeight(U), ...
    avrAngSegNormals(U), varAngSegNormals(U), relHeight];


% Additional functions

%  Compute angle of segment normals
    function ang_vct = computeNormalsAngle(normals)
        nNormals = size(normals,1);
        xyNormal = [zeros(nNormals,1), zeros(nNormals,1), ones(nNormals,1) ];

        ang_vct = (acos(dot(normals, xyNormal, 2)));
    end
% Compute relative height
    function [avrSegRH, varSegRH] = getRelativeHeight(avrSegmentHeight, neighSeg_cell)
        idx_cell = num2cell((1:length(avrSegmentHeight))');
        
        avrSegRH = cellfun(@(nCell, idx) mean(arrayfun(@(idxNeig) abs(avrSegmentHeight(idx) - ...
            avrSegmentHeight(idxNeig)), nCell)), neighSeg_cell, idx_cell);
        varSegRH = cellfun(@(nCell, idx) var(arrayfun(@(idxNeig) abs(avrSegmentHeight(idx) - ...
            avrSegmentHeight(idxNeig)), nCell)), neighSeg_cell, idx_cell);
    end

%  Fing segmnet neighbors
    function neighSeg_cell = findNeighborSegments(nodeLabels)
        neighSeg_cell = {};
        labels = unique(nodeLabels);
        
        neighSeg_cell = arrayfun(@(label) getNeighbors(nodeLabels, label) , labels, 'UniformOutput',false);
    end

% get Neighbors
    function neighborsLabel =  getNeighbors(nodeLabels, label)
        segment = nodeLabels == label;
        se = true(3,1);
        neighbors = imdilate(segment, se) & ~ segment;
        neighborsLabel = unique(nodeLabels(neighbors))';
    end



end