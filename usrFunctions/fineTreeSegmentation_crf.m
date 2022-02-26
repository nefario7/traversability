function treeLabels = fineTreeSegmentation_crf(gridPtCloud, treeSegments, bestTreeSegments)
siteSet_name = 'mediumDensity';
load(['./Models/wCRF_' siteSet_name '.mat'], 'w_train')

treeLabels = zeros(length(treeSegments), 1);
nLabel = 1;
for k = 1:length(bestTreeSegments)
    idx = treeSegments == bestTreeSegments(k);
    ptCloud = gridPtCloud(idx,:);
    
    if size(ptCloud,1) > 60
        E = edges(delaunayTriangulation(ptCloud(:,1), ptCloud(:,2)));
        nNodes = size(ptCloud, 1);
        
        [ptSegments, ptModes, ptDensity] = segmentPtCloud_meanshift(ptCloud, ones(length(ptCloud),1), [1], 'none');
        
        [ptFeatures, ~] = getSlopeFeatures(ptCloud(:,1), ptCloud(:,2), ptCloud(:,3),...
            E, nNodes);
        
        fpfhFeatures = extractFPFHFeatures(pointCloud(ptCloud));
        
        segmentFeatures = zeros(length(ptSegments),14);
        for j = 1:max(ptSegments)
            idx = ptSegments(:,1) == j;
            tmpCloud = ptCloud(idx,:);
            tmpModes = ptModes(idx,:);
            tmpDensity = ptDensity(idx,:);
            
            features = computeSegmentFeatures_meanShift(tmpCloud, ptModes, ptDensity);
            
            segmentFeatures(idx,:) = ones(sum(idx),14).*features;
        end
        
        inputVector = [ptModes, ptDensity, ptFeatures, ...
                    fpfhFeatures, segmentFeatures, ptCloud(:,3)];
        targetVector = zeros(length(inputVector),1); %% set as zero vector because it is not used
        
        [~, Xnode, Xedge, ~, ...
            nodeMap, edgeMap, edgeStruct] = CRF_ptCloudSetup(inputVector, targetVector, nNodes, E);
        
        [nodePot,edgePot] = UGM_CRF_makePotentials(w_train, Xnode, Xedge,...
            nodeMap, edgeMap, edgeStruct);
        treePoints = UGM_Decode_ICM(nodePot,edgePot, edgeStruct);
        treePoints = logical(double(treePoints - 1));
        
        %update the labels
        if sum(treePoints) ~= 0
            tmpLabels = treeLabels(idx,:);
            tmpLabels(treePoints,:) = 1*nLabel;
            nLabel = nLabel +1;
            treeLabels(idx,:) = tmpLabels;
        end
    end
end
end

% function ptSegmentFeatures = computePointSegmentFeatures(ptCloud, ptSegments)
% ptSegmentFeatures = zeros(length(ptSegments),7);
% for j = 1:max(ptSegments)
%     idx = ptSegments(:,1) == j;
%     tmpCloud = ptCloud(idx,:);
%     
%     xy_mean = mean(tmpCloud(:,1:2), 1);
%     
%     xy_norm = tmpCloud(:,1:2) - xy_mean;
%     
%     coeff = pca(xy_norm);
%     xy_pca = xy_norm*coeff;
%     
%     l_max = max(xy_pca, [], 1);
%     l_min = min(xy_pca, [], 1);
%     
%     d1 = l_max(1,1) - l_min(1,1);
%     d2 = l_max(1,2) - l_min(1,2);
%     
%     r = d1/d2;
%     
%     [~, area_xy] = boundary(xy_pca(:,1), xy_pca(:,2));
%     [~, area_xz] = boundary(xy_pca(:,1), tmpCloud(:,3));
%     [~, area_yz] = boundary(xy_pca(:,2), tmpCloud(:,3));
%     
%     area_r = area_xz/area_yz;
%     ptSegmentFeatures(idx,:) = ones(sum(idx),7).*[d1, d2, r, area_xy, area_xz, area_yz, area_r];
% end
% end
