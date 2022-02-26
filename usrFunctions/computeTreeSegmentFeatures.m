function treeSegmentFeatures = computeTreeSegmentFeatures(gridPtCloud, treeSegments, ptModes_vct, ptDensity_vct)

treeSegmentFeatures = [];

for j = 0:max(treeSegments)
    idx = treeSegments(:,1) == j;
    tmpCloud = gridPtCloud(idx,:);
    ptModes = ptModes_vct(idx,:);
    ptDensity = ptDensity_vct(idx,:);
    
    segmentFeatures = computeSegmentFeatures_meanShift(tmpCloud, ptModes, ptDensity);
    
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
%     
%     %         FD = differentialBoxCounting_ptCloud(ptModes(idx,:));
%     
%     treeSegmentFeatures = [treeSegmentFeatures; ...
%         [d1, d2, r, area_xy, area_xz, area_yz, area_r]];%features(idx,:);
    treeSegmentFeatures = [treeSegmentFeatures; ...
        segmentFeatures];%features(idx,:);

end