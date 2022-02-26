function newTreeSegments = fineTreeSegmentation_recursive(gridPtCloud, treeSegments, maxIter)

initialSegments = unique(treeSegments(treeSegments~=0));
newTreeSegments = zeros(size(treeSegments));
for nIter = 1:maxIter
    counter = 1;
    for k = 1:length(initialSegments)
        idx =  treeSegments == initialSegments(k);
        if sum(idx) > 20
            ptCloud = gridPtCloud(idx,1:3);
            
            treeLabels = zeros(size(ptCloud, 1),1);
            idx_boundary = boundary(ptCloud);
            idx_boundary = unique(idx_boundary(:));
            tmpCloud = ptCloud(idx_boundary,:);
            treeLabels(idx_boundary) = findSingleTreePoints(tmpCloud, 0.3, 'none');
            treeLabels(idx_boundary) = joinNearSegments(tmpCloud, treeLabels(idx_boundary), 'xy_maxHeight');

            treeLabels = addPointsInsideBoundary(treeLabels, ptCloud);

            
%             figure
%             subplot(1,2,1)
%             RGB = label2rgb(treeLabels, 'prism', 'c');
%             pcshow(tmpCloud0, [RGB(:,1,1), RGB(:,1,2), RGB(:,1,3)], 'MarkerSize', 50)
            
            maxTree = -inf;
            for j = 1:max(treeLabels)
                idx_0 = treeLabels == j;
                treePts = sum(idx_0);
                if maxTree < treePts
                    maxTree = treePts;
                    idx_max = j;
                end
            end
            treeLabels(treeLabels ~= idx_max)  = 0;
            treeLabels(treeLabels == idx_max)  = counter;
%             treeLabels = addInsidePoints2segment(treeLabels, tmpCloud0, 'xy_maxHeight');

            newTreeSegments(idx) = treeLabels;
            
%             subplot(1,2,2)
%             RGB = label2rgb(treeLabels, 'prism', 'c');
%             pcshow(tmpCloud0, [RGB(:,1,1), RGB(:,1,2), RGB(:,1,3)], 'MarkerSize', 50);
%             pause
            counter = counter + 1;
        end
        disp(k)

    end
    
    initialSegments = unique(treeSegments(treeSegments~=0));
end