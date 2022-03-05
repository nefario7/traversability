function [gridMap] = digital_em(gridPtCloud, plot_dem_data, fuzzy)

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

%     nonGroundLabels = elevModel_labels == 1;
%     elevModel(nonGroundLabels) = nan;
DEM = GRIDobj(X, Y, elevModel);
if plot_dem_data
    figure
    imageschs(DEM)
end


%% Traversability Roughness
R = roughness(DEM, 'srf', [23, 23]);
roughnessScore = R.Z;
idxRoughnessScore = roughnessScore < 0.7;
roughnessScore(idxRoughnessScore) = 1;
%     DEM.Z(idxRoughnessScore) = nan;
if plot_dem_data
    figure
    imageschs(DEM,R)
end


%% Traversability Slope
G = gradient8(DEM);
slopeScore = G.Z;
%     idxNonGround = elevModel_labels == 1;
%     slopeScore(idxNonGround) = 1;
idxSlopeScore = slopeScore >= pi/4;
%     DEM.Z(idxSlopeScore) = nan;
slopeScore(idxSlopeScore) = 1;
if plot_dem_data
    figure
    imageschs(DEM,G,'ticklabel','nice','colorbarylabel','Slope [-]','caxis',[0 1])
end


%% Traversability Index
if ~fuzzy
    gridMap = traversability_index(slopeScore, roughnessScore, elevModel_labels);
    figure;
    inflate(gridMap, 0.2)
    show(gridMap);
    title("Heuristic Grid Map")
else
    gridMap = traversability_index_fuzzy(slopeScore, roughnessScore, elevModel_labels);
    figure;
%     inflate(gridMap, 0.2)
    show(gridMap);
    legend('High', 'Medium', 'Low')
    title("Fuzzy Grid Map")
end

%     inflatedMap = copy(gridMap);
%     inflate(inflatedMap,0.5);
%     figure;
%     show(inflatedMap);
end