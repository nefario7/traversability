clc ;
clear;

%% Add Libraries
addpath(genpath('usrFunctions'))

%% Load Data
disp("Loading Data")
groundPoints = readmatrix('point data/ground_points.txt');
nonGroundPoints = readmatrix('point data/non-ground_points.txt');

ptCloud = [[groundPoints(:,1:3), zeros(length(groundPoints),1)]; [nonGroundPoints(:,1:3), ones(length(nonGroundPoints),1)]];

% figure;
% subplot(1,2,1)
% pcshow(ptCloud(:,1:3))
% title('Point Cloud - Original')
% subplot(1,2,2)
% pcshow(ptCloud(:,1:3), ptCloud(:,4))
% title('Point Cloud - Filtered')

%% Data Paths
gc_data_path = 'variable data/grid_cloud_data_new.mat';
tc_data_path = 'variable data/traversable_cloud_data_new.mat';

plot_data = true;

%% Grid Cloud
if ~isfile(gc_data_path)
    disp("Generating Grid Cloud")
    [gridPtCloud, gridLabels, gridLabels_mtx] = grid_cloud(ptCloud, 1.0);
    save(gc_data_path,'gridPtCloud', 'gridLabels', 'gridLabels_mtx');
else
    disp("Loading Grid Cloud Data")
    load(gc_data_path,'gridPtCloud', 'gridLabels', 'gridLabels_mtx');
end

% if plot_data
%     figure
%     pcshow(gridPtCloud(:,1:3), gridLabels)
%     colormap("lines")
% end


%% Traversable Cloud
if ~isfile(tc_data_path)
    disp("Finding Traversable Grid Blocks")
    threshold = 0.3;    % No. of trunk points / Total points
    [obstacleGrid, traversableCloud, gridMap] = traversable_cloud(threshold, gridPtCloud, gridLabels, gridLabels_mtx, plot_data);
    save(tc_data_path, 'obstacleGrid', 'traversableCloud', 'gridMap');
else
    disp("Loading Traversable Cloud Data")
    load(tc_data_path, 'obstacleGrid', 'traversableCloud', 'gridMap');
end

% if plot_data
%     figure;
%     show(gridMap);
%     title("Heuristic Traversability Map")
% end


%% Digital Elevation Map Index
% disp("Traversability DEM")
% fuzzy=false;
% gridMap = digital_em(gridPtCloud, plot_data, fuzzy);

%% Digital Elevation Map Fuzzy Index
disp("Fuzzy Traversability DEM")
fuzzy=true;
gridMapFuzzy = digital_em(gridPtCloud, plot_data, fuzzy);
