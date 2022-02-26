function treeSegments = addPointsInsideBoundary(treeSegments, ptCLoud)

for k = 1:max(treeSegments)
    idx = treeSegments == k;
    
%     tmpLabels = treeSegments(idx,:);
    tmpCloud = ptCLoud(idx,:);
    
    if size(tmpCloud,1) > 4
%         [D, ~, xy_center, ~] = getSegmentDiameters(tmpCloud, ones(size(tmpLabels,1),1));
%         
%         L = linspace(0,2*pi,360);
%         xv = xy_center(1) + (D/2)*cos(L);
%         yv = xy_center(2) + (D/2)*sin(L);
%         
        idxBoundary = boundary(tmpCloud(:,1:2));
        xv = tmpCloud(idxBoundary, 1);
        yv = tmpCloud(idxBoundary, 2);
        
        idx_noLabeled = treeSegments(:,:) == 0;
        idx_in = zeros(size(ptCLoud,1),1);
                
        xq =ptCLoud(idx_noLabeled,1);
        yq = ptCLoud(idx_noLabeled,2);
        idx_in(idx_noLabeled) = inpolygon(xq, yq, xv, yv);
        
        %     xMax = max(tmpCloud(:,1));
        %     xMin = min(tmpCloud(:,1));
        %
        %     yMax = max(tmpCloud(:,2));
        %     yMin = min(tmpCloud(:,2));
        %
        %
        %     idx_x = zeros(size(gridPtCloud,1),1);
        %     idx_y = zeros(size(gridPtCloud,1),1);
        %
        %     idx_x(idx_noLabeled,1) = (xMin <= gridPtCloud(idx_noLabeled,1)) & (gridPtCloud(idx_noLabeled,1) <= xMax);
        %     idx_y(idx_noLabeled, 1) = (yMin <= gridPtCloud(idx_noLabeled,2)) & (gridPtCloud(idx_noLabeled,2) <= yMax);
        %
        %     idx_in = idx_x & idx_y;
        
        treeSegments(logical(idx_in),:) = k;
    else
        treeSegments(idx,:) = 0;
    end
    
end



end