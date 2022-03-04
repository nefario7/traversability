clc ;
clear;

%% Add Libraries
addpath(genpath('usrFunctions'))

%% Load Data
disp("Loading Data")
groundPoints = readmatrix('point data/ground_points.txt');
nonGroundPoints = readmatrix('point data/non-ground_points.txt');

ptCloud = [[groundPoints(:,1:3), zeros(length(groundPoints),1)]; [nonGroundPoints(:,1:3), ones(length(nonGroundPoints),1)]];

figure;
subplot(1,2,1)
pcshow(ptCloud(:,1:3))
title('Point Cloud - Original')
subplot(1,2,2)
pcshow(ptCloud(:,1:3), ptCloud(:,4))
title('Point Cloud - Labeled')

%% Data Paths
gc_data_path = 'variables/grid_cloud_data.mat';
tc_data_path = 'variables/traversable_cloud_data.mat';


%% Grid Cloud
if ~isfile(gc_data_path)
    disp("Generating Grid Cloud")
    [gridPtCloud, gridLabels, gridLabels_mtx] = grid_cloud(ptCloud, plot_data=false);
    save(gc_data_path,'gridPtCloud', 'gridLabels', 'gridLabels_mtx');
else
    disp("Loading Grid Cloud Data")
    load(gc_data_path,'gridPtCloud', 'gridLabels', 'gridLabels_mtx');
end


%% Traversable Cloud
if ~isfile(tc_data_path)
    disp("Finding Traversable Grid Blocks")
    threshold = 0.3;    % No. of trunk points / Total points
    [obstacleGrid, traversableCloud] = traversable_cloud(threshold, gridPtCloud, gridLabels, gridLabels_mtx, plot_data=false);
    save(tc_data_path, 'obstacleGrid', 'traversableCloud');
else
    load(tc_data_path, 'obstacleGrid', 'traversableCloud');
end

% %% Digital Elevation Map Index
gridMap = digital_em(ptCloud, gridPtCloud, plot_data=false, fuzzy=false);
%
% %% Digital Elevation Map Fuzzy Index
% gridMapFuzzy = digital_em(ptCloud, plot_data=false, fuzzy=true);
