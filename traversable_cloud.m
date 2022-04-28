function [traversableCloud, gridObstacle, gridMap] = traversable_cloud(threshold, gridPtCloud, gridLabels_mtx, plot_data)
disp("Finding Traversable Grid Blocks")
% !Try Occupancy Map
%% Find Traversable and Non-traversable areas in Grid Cloud
[rows, cols] = size(gridLabels_mtx);
gridObstacle = ones(length(gridPtCloud),1);
gridLabels = gridPtCloud(:, 5);
gridMap = occupancyMap(rows, cols, 0.3, 'grid');

% gridMap = occupancyMap(rows,cols,1,'grid');

for i=progress(1:cols)
    for j=1:rows-1
        idxGrid = gridLabels_mtx(j,i);
        idxPts = gridLabels == idxGrid;

        gridCloud = gridPtCloud(idxPts,1:3);
        gridTrunkLabels = gridPtCloud(idxPts,4);

        if ~isempty(gridCloud)
            nPts = size(gridCloud,1);
            nTrunkPts = sum(gridTrunkLabels);
            % setOccupancy(gridMap,grid2local(gridMap,[rows - j,k]), nTrunkPts/nPts);
            if (nTrunkPts/nPts <= threshold)
                gridObstacle(idxPts,1) = 0;  % 1 means that the grid might be traversable
                setOccupancy(gridMap, grid2local(gridMap,[j, i]), 0)
            else
                gridObstacle(idxPts,1) = nTrunkPts/nPts;
                setOccupancy(gridMap, grid2local(gridMap,[j, i]), 1)
            end
        else
            setOccupancy(gridMap, grid2local(gridMap,[j, i]), 1)
        end
    end
end

% if plot_data
%     figure;
%     show(gridMap);
%     title("Heuristic Grid Map")
% end


% %% Plot - Segregated Point Cloud
% if plot_data
%     figure
%     pcshow(gridPtCloud(:,1:3), gridPtCloud(:,4));
%     view(2)
% end

%% Segregating only the traversability related points
traversableCloud = gridPtCloud(gridObstacle == 1,:);
% idx_trav = traversableCloud(:,4) == 0;
% traversableCloud = traversableCloud(idx_trav,1:3);
traversableCloud = traversableCloud(:,1:3);


%% Cleaning up Traversable Cloud
groundLabels = gridPtCloud(:,4) == 0;
traversableCloud = gridPtCloud(groundLabels,1:4);

% if plot_data
%     figure
%     disp("Showing Traversability Cloud")
%     pcshow(traversableCloud)
% end

end