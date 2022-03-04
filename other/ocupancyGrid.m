clc ;
clear all;

%% Load Data
filename = '../point data/ground_points.txt';
groundPoints = readmatrix(filename);
filename = '../point data/non-ground_points.txt';
nonGroundPoints = readmatrix(filename);

ptCloud = [[groundPoints(:,1:3), zeros(length(groundPoints),1)]; [nonGroundPoints(:,1:3), ones(length(nonGroundPoints),1)]];

plot_data = false;

%% Plot - Point Cloud 
if plot_data
    figure;
    subplot(1,2,1)
    pcshow(ptCloud(:,1:3))
    title('Point Cloud - Original')
    subplot(1,2,2)
    pcshow(ptCloud(:,1:3), ptCloud(:,4))
    title('Point Cloud - Labeled')
end

[gridPtCloud, gridLabels, gridLabels_mtx] = pointCloud2GridCloud_occupancyGrid(ptCloud);

%% Plot - Grid Cloud
if plot_data
    figure
    pcshow(gridPtCloud(:,1:3), gridLabels)
    colormap("lines")
end

%% Find Traversable and Non-traversable areas in grid
[rows, cols] = size(gridLabels_mtx);
% gridMap = occupancyMap(rows,cols,1,'grid');
gridObstacle = ones(length(gridPtCloud),1);
for k=progress(1:cols)
    for j=1:rows-1
        idxGrid = gridLabels_mtx(j,k);
        idxPts = gridLabels==idxGrid;
        
        gridCloud = gridPtCloud(idxPts,1:3);
        gridTrunkLabels = gridPtCloud(idxPts,4);

        if ~isempty(gridCloud)
            nPts = size(gridCloud,1);
            nTrunkPts = sum(gridTrunkLabels);
%             setOccupancy(gridMap,grid2local(gridMap,[rows - j,k]), nTrunkPts/nPts);
            if (nTrunkPts/nPts <= 0.3)
              gridObstacle(idxPts,1) = 0;  % zero means that the grid might be traversable
            end
        end 
    end
end


%% Plot - Segregated Point Cloud
if plot_data
    figure
    pcshow(gridPtCloud(:,1:3), gridPtCloud(:,4));
    view(2)
end

%% Segregating only the traversability related points 
traversableCloud = gridPtCloud(gridObstacle==0,:);
% idx_trav = traversableCloud(:,4) == 0;
% traversableCloud = traversableCloud(idx_trav,1:3);
traversableCloud = traversableCloud(:,1:3);

if plot_data
    disp("Showing Traversability Cloud")
    pcshow(traversableCloud)
end


%% Cleaning up Traversable Cloud
groundLabels = gridPtCloud(:,4) ==0;
traversableCloud = gridPtCloud(groundLabels,1:4);

if plot_data
    disp("Showing cleaned up Traversability Cloud")
    pcshow(traversableCloud(:,1:3))   
end


%%% TOPOTOOLBOX AND DEM
plot_dem_data = false;

%% Generate DEM from point cloud
% elevModel = pc2dem(pointCloud(traversableCloud), [0.3, 0.3]);
elevModel = pc2dem(pointCloud(gridPtCloud(:,1:3)), [0.3, 0.3]);
elevModel_labels = pc2dem(pointCloud([gridPtCloud(:,1:2), gridPtCloud(:,4)]), [0.3, 0.3]);

X = 0:size(elevModel,2)-1;
Y = 0:size(elevModel,1)-1;

if plot_dem_data
    figure
    subplot(1,2,1)
    imagesc(elevModel)
    % colormap(gray)
    title("Digital Terrain Model")
    subplot(1,2,2)
    imagesc(elevModel_labels)
    % colormap(gray)
    title("Labels")
end
% nonGroundLabels = elevModel_labels == 1;
% elevModel(nonGroundLabels) = nan;
DEM = GRIDobj(X,Y,elevModel);
if plot_dem_data
    figure
    imageschs(DEM)
end


%% Traversability Roughness 
R = roughness(DEM, 'srf', [23, 23]);
if plot_dem_data
    figure
    imageschs(DEM,R)
end
roughnessScore = R.Z;
idxRoughnessScore = roughnessScore < 0.7;
% roughnessScore(idxRoughnessScore) = 1;
% DEM.Z(idxRoughnessScore) = nan;
% figure
% imageschs(DEM)


%% Traversability Slope
G = gradient8(DEM);
if plot_dem_data
    imageschs(DEM,G,'ticklabel','nice','colorbarylabel','Slope [-]','caxis',[0 1])
end
slopeScore = G.Z;
% idxNonGround = elevModel_labels == 1;
% slopeScore(idxNonGround) = 1;
idxSlopeScore = slopeScore >= pi/4;
% DEM.Z(idxSlopeScore) = nan;
% slopeScore(idxSlopeScore) = 1;

%% Traversability
[rows, cols] = size(slopeScore);
gridMap = occupancyMap(rows,cols,0.3,'grid');
for k=progress(1:cols)
    for j=1:rows
        s1 = slopeScore(j, k);
        s2 = roughnessScore(j, k);
        s3 = elevModel_labels(j, k);
        if (s1 == 1) || (s2 == 1) || (s3 == 1)
            setOccupancy(gridMap,grid2local(gridMap,[j,k]), 1);
        else
            if isnan(s1)
                setOccupancy(gridMap,grid2local(gridMap,[j,k]), 0.5);
            else
                setOccupancy(gridMap,grid2local(gridMap,[j,k]), s1);
            end
        end
    end
end
% inflate(gridMap,0.5)
show(gridMap)


figure;
show(gridMap);

inflatedMap = copy(gridMap);
inflate(inflatedMap,0.5);
% figure;
% show(inflatedMap);