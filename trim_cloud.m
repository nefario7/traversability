function [trimmed_cloud] = trim_cloud(grid_point_cloud, pc_path)
%% Trimming Grid Point Cloud
base_name = split(pc_path, '.');
base_name = base_name(1);
trim_path = strcat(base_name, '_trimmed_cloud.mat');
if isfile(trim_path)
    %% Load Data
    disp("Loading Trimmed Cloud")
    load(trim_path, 'trimmed_cloud');
else
    %% Cut Data
    disp("Trimming Point Cloud")
    trimmed_cloud = [];
    grid_indexes = unique(grid_point_cloud(:, 5));

    for i=progress(1:length(grid_indexes))
        blockcloud = grid_point_cloud(grid_point_cloud(:, 5) == grid_indexes(i), :);
        % Threshold
        %     avg_z = av(blockcloud(:, 3));
        %     max_z = max(blockcloud(:, 3));
        mean_z = mean(blockcloud(:, 3));

        % Clustering
        %     distance_thres = 0.5;
        %     [labels, nclusters] = pcsegdist(pointCloud(blockcloud(:, 1:3)), distance_thres);
        %     colormap(hsv(nclusters))
        %     title(i)
        indexes = blockcloud(:, 3) < mean_z;
        cloud_points = blockcloud(indexes, :);
        trimmed_cloud = [trimmed_cloud; cloud_points];
    end

    save(trim_path, "trimmed_cloud")

    %     trimmed_point_cloud = pointCloud(cut_cloud(:, 1:3));
    figure
    pcshow(trimmed_cloud(:,1:3), trimmed_cloud(:,4));
end
end