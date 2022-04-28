disp("Loading Original Point Cloud")
point_cloud = readmatrix('point data/fullCloud_labeled.txt');
full_cloud = pointCloud(point_cloud(:, 1:3));
[ground_points_index, nonground_cloud, ground_cloud] = segmentGroundSMRF(full_cloud);
pcshowpair(ground_cloud, nonground_cloud)

disp("Denoising")
nonground_cloud = pcdenoise(nonground_cloud);
figure
pcshow(nonground_cloud);

distance_thres = 0.5;

[labels, nclusters] = pcsegdist(nonground_cloud, distance_thres); 
figure
pcshow(nonground_cloud.Location, labels)
colormap(hsv(nclusters))
title('Nonground Clusters')