function [processedCloud, idxCanopy, canopyMetrics, canopyLabels, canopySegmentMetrics] = getForestFeatures(ptCloud, ptIntensity, action)
% set CRF options
graphStructure = 'delaunay2D';
actionTrainTest = 'by_segments'; %% by_scans, by_segments

% disp('1) Processing point cloud')
[groundLabels, processedCloud] = processSegments(ptCloud, graphStructure, actionTrainTest, 'none');
groundLabels = groundLabels +1;

% disp('2) Computing a raster Canopy Height Model (CHM)')
cellSize = 0.15;
[models, refmat] = elevationModels(processedCloud, ...
    groundLabels, ...
    'classTerrain', [1], ...
    'classSurface', [2], ...
    'cellSize', cellSize, ...
    'interpolation', 'idw', ...
    'searchRadius', inf, ...
    'weightFunction', @(d) d^-3, ...
    'smoothingFilter', fspecial('gaussian', [3, 3], 0.5), ...
    'outputModels', {'terrain', 'surface', 'height'}, ...
    'fig', false, ...
    'verbose', false);

% disp('3) Tree top detection')
[peaks_crh, ~] = canopyPeaks(models.height.values, ...
    refmat, ...
    'minTreeHeight', 5, ...
    'searchRadius', @(h) 0.28 * h^0.59, ...
    'fig', false, ...
    'verbose', false);

% disp('4) Marker controlled watershed segmentation')
[label_2d] = treeWatershed(models.height.values, ...
    'markers', peaks_crh(:,1:2), ...
    'minHeight', 5, ...
    'removeBorder', true, ...
    'fig', false, ...
    'verbose', false);

% disp('5) Transferring 2D labels to the 3D point cloud')
idxl_veg = ismember(groundLabels, [2]);
% convert map coordinates (x,y) to image coordinates (column, row)
RC = [processedCloud(:,1) - refmat(3,1), processedCloud(:,2) - refmat(3,2)] / refmat(1:2,:);
RC(:,1) = round(RC(:,1)); % row
RC(:,2) = round(RC(:,2)); % column
ind = sub2ind(size(label_2d), RC(:,1), RC(:,2));

% transfer the label
label_3d = label_2d(ind);
label_3d(~idxl_veg) = 0;
[label_3d(label_3d ~= 0), ~] = grp2idx(label_3d(label_3d ~= 0));

% select segments with more than 16 points
label_usr = zeros(length(label_3d),1);
nLabel = 1;
for j = 1:max(label_3d)
    label_tmp = label_3d==j;
    if sum(double(label_tmp(:))) >= 64
        label_usr(label_tmp,1) = nLabel;
        nLabel = nLabel + 1;
    end
end

% disp('6) Computing segment metrics from the labelled point cloud')
[metrics_3d, ~, ~] = treeMetrics(label_usr, ...
    processedCloud, ...
    ptIntensity, ...
    ones(length(processedCloud),1), ...
    ones(length(processedCloud),1), ...
    nan(length(processedCloud), 3), ...
    models.terrain.values, ...
    refmat, ...
    'metrics', {'XPos', 'YPos', 'ZPos', 'H', 'HMean', 'HStdDev', 'HKurt', 'CVH2DArea', 'CVH3DArea', 'IMean', 'IStdDev', 'IKurt', 'IQ50', }, ...
    'intensityScaling', true, ...
    'alphaMin', 1.5, ...
    'verbose', false);

metrics_3d = struct2table(metrics_3d);
metrics_3d = table2array(metrics_3d);

canopySegmentMetrics = metrics_3d;

nCols = size(metrics_3d,2);
canopyMetrics = zeros(length(idxl_veg), nCols);
for j =1:size(metrics_3d, 1)
    idx_tmp = label_usr == j;
    canopyMetrics(idx_tmp,:) = ones(sum(idx_tmp), nCols).*metrics_3d(j,:);
end

canopyMetrics = canopyMetrics(:,:);
idxCanopy = idxl_veg;
canopyLabels = label_usr;

if contains(action, 'plot')
    figure('Color', [1,1,1])
    subplot(1,2,1)
    RGB = label2rgb(label_usr(idxl_veg), 'prism', 'c');
    pcshow(processedCloud(idxl_veg,:), [RGB(:,1,1), RGB(:,1,2), RGB(:,1,3)], 'MarkerSize', 5);
    title('Segmented trees')
    subplot(1,2,2)
    pcshow(processedCloud,'MarkerSize', 5);
    title('Processed cloud')
end


end