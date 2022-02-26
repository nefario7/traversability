function [ptModes_vct, ptDensity_vct, ptCloud_out] = gridPtCloud2Modes_density(gridPtCloud, gridLabels, gridLabels_mtx, action)

%% compute meanshift

ptModes_vct = [];
ptDensity_vct = [];
ptCloud_out = [];

[rows, cols] = size(gridLabels_mtx);

treeSegments = [];
prevLabel = 0;

% ptCloud_cell = gridHeight_cell;
cellCount = 1;
disp('Computing modes')
for k = 1:cols
    for j = 1:rows
        Xa = [];
        ptCloud = [];
        
        idxGrid = gridLabels_mtx(j,k);
        idxPts = gridLabels==idxGrid;
        
        Xa = gridPtCloud(idxPts,:);
        ptCloud = gridPtCloud(idxPts,:);
        
        if contains(action, 'all')
            ptCloud = addNeighborGrids(ptCloud, gridPtCloud, gridLabels_mtx,...
                gridLabels, j, k, rows, cols);
        end
        
        if isempty(Xa) || (size(Xa,1) <= 3)
            continue
        end
        
        ptModes = pointModesMeanShift(Xa, ptCloud, 'mtx');
        
        ptDensity = computePtDensity(ptModes, 'approximate');
        ptDensity_vct = [ptDensity_vct; ptDensity];
        ptModes_vct = [ptModes_vct; ptModes];
        ptCloud_out = [ptCloud_out; gridPtCloud(idxPts,:)];
        
%         if contains(action, 'by_grids')
%             disp('Segmenting using single grids...')
%             [tmpSegments, ~, ~, ~] = recursiveGraphSegmentation(Xa, ...
%                 ptModes, ptDensity, [], 'delaunay');
%             
%             treeSegmentFeatures = computeTreeSegmentFeatures(Xa, tmpSegments, ptModes, ptDensity);
%             treeSegmentLabels = unique(tmpSegments);
%             
%             siteSet_name = 'mediumDensity';
%             load(['./Models/annModel_' siteSet_name '.mat'], 'net')
%             
%             idx_bestSegments = classify(net, treeSegmentFeatures);
%             idx_bestSegments = logical(double(string(idx_bestSegments)));
%             
%             bestTreeSegments = treeSegmentLabels(idx_bestSegments,:);
%             treeLabels = fineTreeSegmentation(Xa, tmpSegments, bestTreeSegments);
%             
%             treeLabels(treeLabels ~= 0,:) = treeLabels(treeLabels ~= 0,:) + prevLabel;
%             
%             treeSegments = [treeSegments; treeLabels];
%             prevLabel = max(treeSegments);
%             
%         end
        
        disp((cellCount/(rows*cols))*100)
        cellCount = cellCount +1;
    end
    
end

% %% segment by modes and point density
% if contains(action, 'all')
%     disp('Segmenting using all point Cloud...')
%     %     [treeSegments, ~, ~, ~] = recursiveGraphSegmentation(gridPtCloud, ...
%     %         ptModes_vct, ptDensity_vct, [], 'delaunay');
%     minpts = 60;
%     
%     X = [gridPtCloud, ptModes_vct, ptDensity_vct];
% %     kD = pdist2(X,X,'euc','Smallest',minpts); % The minpts smallest pairwise distances
% %     epsilon = (length(kD)/100000) + 0.5;
%     epsilon = 3;
%     treeSegments = dbscan(X,epsilon,minpts);
%     treeSegments(treeSegments == -1) = 0;
%     
%     treeSegments = joinNearSegments(gridPtCloud(:,1:3), treeSegments, 'xy_mean');
%     treeSegments = addInsidePoints2segment(treeSegments, gridPtCloud(:,1:3), 'xy_mean');
%     treeSegments = removeIntersectingPoints(gridPtCloud(:,1:3), treeSegments);
%     treeSegments = removeSmallestSegments(treeSegments);
%     treeSegments = addInsidePoints2segment(treeSegments, gridPtCloud(:,1:3), 'xy_mean');
%     treeSegments = removeSmallestSegments(treeSegments);
%     
% end
% if contains(action, 'plot')
%     
%     RGB = label2rgb(treeSegments, 'prism', 'c');
%     pcshow(gridPtCloud, [RGB(:,1,1), RGB(:,1,2), RGB(:,1,3)], 'MarkerSize', 30);
%     pause(1)
% end

end

function ptCloud = addNeighborGrids(ptCloud, gridPtCloud, gridLabels_mtx, gridLabels, j, k, rows, cols)

if k > 1
    idxGrid = gridLabels_mtx(j,k-1);
    idxPts = gridLabels==idxGrid;
    ptCloud = [ptCloud; gridPtCloud(idxPts,:)];
    %             ptCloud = [ptCloud; ptCloud_cell{k-1,j}];
    if j > 1
        idxGrid = gridLabels_mtx(j-1,k-1);
        idxPts = gridLabels==idxGrid;
        ptCloud = [ptCloud; gridPtCloud(idxPts,:)];
        %                 ptCloud = [ptCloud; ptCloud_cell{k-1,j-1}];
    end
    if j <= rows-1
        idxGrid = gridLabels_mtx(j+1,k-1);
        idxPts = gridLabels==idxGrid;
        ptCloud = [ptCloud; gridPtCloud(idxPts,:)];
        %                 ptCloud = [ptCloud; ptCloud_cell{k-1,j+1}];
    end
elseif k<= cols -1
    idxGrid = gridLabels_mtx(j,k+1);
    idxPts = gridLabels==idxGrid;
    ptCloud = [ptCloud; gridPtCloud(idxPts,:)];
    
    %             ptCloud = [ptCloud; ptCloud_cell{k+1,j}];
    if j > 1
        idxGrid = gridLabels_mtx(j-1,k+1);
        idxPts = gridLabels==idxGrid;
        ptCloud = [ptCloud; gridPtCloud(idxPts,:)];
        
        %                 ptCloud = [ptCloud; ptCloud_cell{k+1,j-1}];
    end
    if j <= rows-1
        idxGrid = gridLabels_mtx(j+1,k+1);
        idxPts = gridLabels==idxGrid;
        ptCloud = [ptCloud; gridPtCloud(idxPts,:)];
        
        %                 ptCloud = [ptCloud; ptCloud_cell{k+1,j+1}];
    end
end
if j>1
    idxGrid = gridLabels_mtx(j-1,k);
    idxPts = gridLabels==idxGrid;
    ptCloud = [ptCloud; gridPtCloud(idxPts,:)];
    
    %             ptCloud = [ptCloud; ptCloud_cell{k,j-1}];
end
if j <= rows-1
    idxGrid = gridLabels_mtx(j+1,k);
    idxPts = gridLabels==idxGrid;
    ptCloud = [ptCloud; gridPtCloud(idxPts,:)];
    
    %             ptCloud = [ptCloud; ptCloud_cell{k,j+1}];
end

end




