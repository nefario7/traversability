function [grid_point_cloud, grid_labels_mtx] = grid_cloud(pc_data, pc_path, resolution)
%% Dividing Point Cloud in Grid
base_name = split(pc_path, '.');
base_name = base_name(1);
gc_data_path = strcat(base_name, '_grid_cloud.mat');
if isfile(gc_data_path)
    %% Load Data
    disp("Loading Grid Cloud")
    load(gc_data_path, 'grid_point_cloud', 'grid_labels_mtx');
else
    %% Process Data
    disp("Generating Grid Cloud")
    grid_point_cloud = [];
    grid_labels_mtx = [];
    grid_labels = [];
    nLabels = 1;

    x_min = min(pc_data(:,1));
    x_max = max(pc_data(:,1));

    y_min = min(pc_data(:,2));
    y_max = max(pc_data(:,2));

    xLimits = linspace(x_min, x_max, fix(x_max - x_min)); %fix((x_max - x_min)/nGrid));
    yLimits = linspace(y_min, y_max, fix(y_max - y_min)); %fix((y_max - y_min)/nGrid));
    % xLimits = linspace(x_min, x_max, fix((x_max - x_min)/resolution));
    % yLimits = linspace(y_min, y_max, fix((y_max - y_min)/resolution));
    % xLimits = linspace(x_min, x_max, 200);
    % yLimits = linspace(y_min, y_max, 200);
    disp('Grid Cloud Resolution X: ')
    disp((x_max - x_min)/fix(x_max - x_min));

    disp('Grid Cloud Resolution Y: ')
    disp((y_max - y_min)/fix(y_max - y_min));

    if ~isempty(xLimits) && ~isempty(yLimits)
        for k = progress(1:length(xLimits)-1)
            if k < length(xLimits)-1
                idx_x = (xLimits(k) <= pc_data(:,1)) & (pc_data(:,1) < xLimits(k+1));
            elseif k == length(xLimits)-1
                idx_x = (xLimits(k) <= pc_data(:,1)) & (pc_data(:,1) <= xLimits(k+1));
            end

            for j = 1:length(yLimits)-1
                if j <length(yLimits)-1
                    idx_y = (yLimits(j) <= pc_data(:,2)) & (pc_data(:,2) < yLimits(j+1));
                elseif j == length(yLimits)-1
                    idx_y = (yLimits(j) <= pc_data(:,2)) & (pc_data(:,2) <= yLimits(j+1));
                end

                idx = idx_x & idx_y;
                grid_cloud = pc_data(idx,:);

                % if ~isempty(gridCloud) && (size(gridCloud,1)>1)
                grid_point_cloud = [grid_point_cloud; grid_cloud];

                labels = ones(size(grid_cloud,1),1)*nLabels;
                grid_labels = [grid_labels; labels];

                grid_labels_mtx(j,k) = nLabels;

                nLabels = nLabels + 1;
                %end

            end
        end
    end

    grid_point_cloud = [grid_point_cloud grid_labels];
    save(gc_data_path, 'grid_point_cloud', 'grid_labels_mtx');
end

% figure
% pcshow(grid_point_cloud(:,1:3), gridLabels)
% colormap("lines")

end