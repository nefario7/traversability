function treeLabels = findSingleTreePoints(ptCloud, maxHeightDiff, action)


treeLabels = zeros(size(ptCloud,1),1);

% k = boundary(ptCloud);
% k = unique(k(:));
% tmpCloud = ptCloud(k,:);

tmpCloud = ptCloud;
[~, idx_high] = max(tmpCloud(:,3),[],1);

prevPt = tmpCloud(idx_high,:);

currCloud = tmpCloud;
currCloud(idx_high,:) = [];

[~, r] = knnsearch(currCloud, prevPt);

L = linspace(0,2*pi,360);
xy_center = prevPt(1,1:2);

nPts = size(tmpCloud,1);
nLabel = 1;
while nPts > 10
    
    xq = tmpCloud(:,1);
    yq = tmpCloud(:,2);
    
    xv = xy_center(1) + r*cos(L);
    yv = xy_center(2) + r*sin(L);
    
    idx_in = inpolygon(xq, yq, xv, yv);
    tmp = tmpCloud(idx_in,:);
%     prevPt = mean(tmp, 1);

    idx_boundary = boundary(tmp(:,1:2));
    if isempty(idx_boundary)
        [~, idx_pt] = min(tmp(:,3));
        prevPt = tmp(idx_pt,:);
    else 
        tmpBoundary = tmp(idx_boundary,1:3);
        q03 = quantile(tmpBoundary(:,3), 0.3);
%         mean_boundary = mean(tmpBoundary(:,3),1);
        prevPt = mean(tmpBoundary(tmpBoundary(:,3) <= q03,:), 1);
    end
    
    
    
    if contains(action, 'plot')
        pcshow(tmpCloud(:,:), 'MarkerSize', 50)
        hold on
        pcshow(tmpCloud(idx_in,:), 'c+', 'MarkerSize', 50)
        hold on
%         pcshow(tmp(idx_boundary,:), 'bo', 'MarkerSize', 50)
        pcshow(prevPt, 'bo', 'MarkerSize', 50)
        hold on
        pcshow(median(tmpCloud(~idx_in,:), 1), 'rx', 'MarkerSize', 80)
        hold off
        pause(0.1)
    end
    
    currCloud = tmpCloud(~idx_in,:);
    [~, r_] = knnsearch(currCloud(:,1:3), prevPt(1:3));
     r = r + r_;
%     r = norm(xy_center - prevPt(1,1:2)) + r_tmp;
    
    treeLabels(idx_in) = nLabel;
    if (median(currCloud(:,3)) - prevPt(3)) > maxHeightDiff %% new tree might be found
        subTreeLabels = findSingleTreePoints(currCloud, maxHeightDiff, action);
        subTreeLabels((subTreeLabels ~=0),:) = subTreeLabels((subTreeLabels ~=0),:) +1;
        treeLabels(~idx_in) = subTreeLabels;
        currCloud = currCloud((subTreeLabels ==0),:);
    end
    
    nPts = sum(treeLabels == 0);
end


end