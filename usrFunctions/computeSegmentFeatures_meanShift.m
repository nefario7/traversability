function segmentFeatures = computeSegmentFeatures_meanShift(tmpCloud, ptModes, ptDensity)

xy_mean = mean(tmpCloud(:,1:2), 1);

xy_norm = tmpCloud(:,1:2) - xy_mean;

coeff = pca(xy_norm);
xy_pca = xy_norm*coeff;

l_max = max(xy_pca, [], 1);
l_min = min(xy_pca, [], 1);

d1 = l_max(1,1) - l_min(1,1);
d2 = l_max(1,2) - l_min(1,2);

r = d1/d2;

[~, area_xy] = boundary(xy_pca(:,1), xy_pca(:,2));
[~, area_xz] = boundary(xy_pca(:,1), tmpCloud(:,3));
[~, area_yz] = boundary(xy_pca(:,2), tmpCloud(:,3));

area_r = area_xz/area_yz;

meanDensity = mean(ptDensity);
stdDensity = std(ptDensity);
[~, modeArea_xy] = boundary(ptModes(:,1), ptModes(:,2));
[~, modeArea_xz] = boundary(ptModes(:,1), ptModes(:,3));
[~, modeArea_yz] = boundary(ptModes(:,2), ptModes(:,3));
[~, modeVolume] = boundary(ptModes(:,1:3));
[~, ptVolume] = boundary(tmpCloud(:,1:3));

segmentFeatures = [d1, d2, r, area_xy, area_xz, area_yz, area_r, meanDensity, stdDensity, ...
    modeArea_xy, modeArea_xz, modeArea_yz, modeVolume, ptVolume];
end