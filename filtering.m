clc;
clear;

%% Add Libraries
addpath(genpath('usrFunctions'))

%% Filter Point Cloud
disp("Loading Original Point Cloud")
point_cloud = readmatrix('point data/fullCloud_labeled.txt');

% CSF
tic
[ground_index, nonground_index] = csf_filtering(point_cloud,3,true,1,0.5,500,0.65);
toc

groundPoints = point_cloud(ground_index, :);
nonGroundPoints = point_cloud(nonground_index, :);

ground_cloud = pointCloud(groundPoints);
nonground_cloud = pointCloud(nonGroundPoints);

save('ground_points.txt', "ground_cloud")
save('non_ground_cloud.txt', "nonground_cloud")

% ptCloud = [[groundPoints(:,1:3), zeros(length(groundPoints),1)]; [nonGroundPoints(:,1:3), ones(length(nonGroundPoints),1)]];