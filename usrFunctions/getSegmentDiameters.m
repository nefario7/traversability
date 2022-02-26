function [D, d, xy_center, xy_maxHeight] = getSegmentDiameters(ptCloud, segmentLabels)

D = [];
d= [];
xy_center = [];
xy_maxHeight = [];

for j = 1:max(segmentLabels)
    idx = segmentLabels(:,1) == j;
    tmpCloud = ptCloud(idx,:);
    
    if size(tmpCloud,1) >= 4
        
        xy_mean = mean(tmpCloud(:,1:2), 1);
        
        xy_norm = tmpCloud(:,1:2) - xy_mean;
        
        coeff = pca(xy_norm);
        xy_pca = xy_norm*coeff;
        
        l_max = max(xy_pca, [], 1);
        l_min = min(xy_pca, [], 1);
        
        d1 = l_max(1,1) - l_min(1,1);
        d2 = l_max(1,2) - l_min(1,2);
        
        d_tmp = max([d1, d2]);
        D = [D; d_tmp];
        
        d_tmp = min([d1, d2]);
        d = [d; d_tmp];
        
%         xy_median = median(tmpCloud(:,1:2), 1);
        xy_center = [xy_center; xy_mean];
        [~, idx_maxHeight] = max(tmpCloud(:,3), [], 1);
        xy_maxHeight = [xy_maxHeight; tmpCloud(idx_maxHeight,1:2)];
    else 
        segmentLabels(idx,1) = 0;
    end
end

end
