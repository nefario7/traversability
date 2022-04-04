function [gridPtCloud, gridLabels, gridLabels_mtx] = grid_cloud(ptCloud, resolution)

%% Divide point cloud in grids
gridPtCloud = [];
gridLabels_mtx = [];
gridLabels = [];
nLabels = 1;

x_min = min(ptCloud(:,1));
x_max = max(ptCloud(:,1));

y_min = min(ptCloud(:,2));
y_max = max(ptCloud(:,2));

xLimits = linspace(x_min, x_max, fix(x_max - x_min)); %fix((x_max - x_min)/nGrid));
yLimits = linspace(y_min, y_max, fix(y_max - y_min)); %fix((y_max - y_min)/nGrid));
% xLimits = linspace(x_min, x_max, fix((x_max - x_min)/resolution));
% yLimits = linspace(y_min, y_max, fix((y_max - y_min)/resolution)); 
% xLimits = linspace(x_min, x_max, 200);
% yLimits = linspace(y_min, y_max, 200); 

% disp('Grid Cloud Resolution X: ')
% disp((x_max - x_min)/fix(x_max - x_min));
% 
% disp('Grid Cloud Resolution Y: ')
% disp((y_max - y_min)/fix(y_max - y_min));

if ~isempty(xLimits) && ~isempty(yLimits)
    for k = progress(1:length(xLimits)-1)
        if k < length(xLimits)-1
            idx_x = (xLimits(k) <= ptCloud(:,1)) & (ptCloud(:,1) < xLimits(k+1));
        elseif k == length(xLimits)-1
            idx_x = (xLimits(k) <= ptCloud(:,1)) & (ptCloud(:,1) <= xLimits(k+1));
        end

        for j = 1:length(yLimits)-1
            if j <length(yLimits)-1
                idx_y = (yLimits(j) <= ptCloud(:,2)) & (ptCloud(:,2) < yLimits(j+1));
            elseif j == length(yLimits)-1
                idx_y = (yLimits(j) <= ptCloud(:,2)) & (ptCloud(:,2) <= yLimits(j+1));
            end

            idx = idx_x & idx_y;
            gridCloud = ptCloud(idx,:);

            %if ~isempty(gridCloud) && (size(gridCloud,1)>1)
            gridPtCloud = [gridPtCloud; gridCloud];

            labels = ones(size(gridCloud,1),1)*nLabels;
            gridLabels = [gridLabels; labels];

            gridLabels_mtx(j,k) = nLabels;

            nLabels = nLabels + 1;
            %             end

        end
    end
end

end