clc ;
clear;

%% Add Libraries
addpath(genpath('usrFunctions'))

%% Path and Data
data_name = "fullCloud_labeled";
data_dir = "point data";
data_path = fullfile(data_dir, strcat(data_name, '.txt'));

%% Filter Ground and Non-ground points
[ground_points, nonground_points] = filter_pointcloud(data_path);
point_cloud_points = [
    [ground_points(:,1:3), zeros(length(ground_points),1)]; 
    [nonground_points(:,1:3), ones(length(nonground_points),1)]
    ];

%% Grid Cloud
[grid_point_cloud, grid_labels_mtx] = grid_cloud(point_cloud_points, data_path, 1.0);

%% Trim Cloud
trimmed_grid_cloud = trim_cloud(grid_point_cloud, data_path);

% %% Digital Elevation Map Fuzzy Index
plot_data=true;
fuzzy=true;
fuzzy_map = digital_em(trimmed_grid_cloud, plot_data, fuzzy);
