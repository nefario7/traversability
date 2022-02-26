function [groundLabels, processedCloud]= processSegments(ptCloud, graphStructure, actionTrainTest, action)
load(['./Results/fractalProcessing/CRF_lidar/' graphStructure '_' actionTrainTest 'w_lbfgs.mat'], 'w');


E = edges(delaunayTriangulation(ptCloud));
nNodes = length(ptCloud);

groundLabels = ones(nNodes,1);

heightDifference = getHeightDifference(ptCloud(:,3), E);
heightLabels = graphSegmentation(nNodes, E, heightDifference, 100);

processedCloud = [];
finalLabels = [];
for j = 1: max(heightLabels(:))
    idx_labels = heightLabels(:,1)==j;
    cloud_tmp = ptCloud(idx_labels,:);
   
    if sum(idx_labels) > 3 %%select segments bigger than
        [~, idx_inliers, ~] = pcdenoise(pointCloud(cloud_tmp), 'Threshold', 0.3);
        processedCloud = [processedCloud; cloud_tmp(idx_inliers,:)];
    end
end

E = edges(delaunayTriangulation(processedCloud));
nNodes = length(processedCloud);

heightDifference = getHeightDifference(processedCloud(:,3), E);
heightLabels = graphSegmentation(nNodes, E, heightDifference, 100);

normHeight = normalize(processedCloud(:,3), 'center', 'median');

segHeightFeat = getLidarSegmentFeatures(processedCloud, normHeight, ...
    heightLabels);

[pointFeatures, ~] = getLidarSlopeFeatures(processedCloud, E, nNodes);


if contains(actionTrainTest, 'by_scans') %% train by each vlp scan
    
    inputVector = [pointFeatures, segHeightFeat, normHeight];
    
elseif contains(actionTrainTest, 'by_segments')
    
    pointSegmentFeatures = [];
    for j = 1: max(heightLabels(:))
        idx_labels = heightLabels(:,1)==j;
        cloud_tmp = processedCloud(idx_labels,:);
        nNodes = length(cloud_tmp);
        
        if sum(idx_labels) > 3 %%select segments bigger than
            
            E_ = edges(delaunayTriangulation(cloud_tmp(:,1:2)));
            normHeight_segment = normalize(cloud_tmp(:,3), 'center', 'median');
            
            [pointFeatures_segment, ~] = getLidarSlopeFeatures(cloud_tmp, E_, nNodes);
            
            pointSegmentFeatures = [pointSegmentFeatures; ...
                [pointFeatures_segment, normHeight_segment]];
        else
            pointSegmentFeatures = [pointSegmentFeatures; zeros(sum(idx_labels), 5)];
        end
    end
    inputVector = [segHeightFeat, pointFeatures, normHeight...
        pointSegmentFeatures];
end

[crf_labels, ~] = crf_Lidar_cell({inputVector}, {ones(length(processedCloud), 1)}, ...
    {E}, 'l_bfgs', 'infer', w);

groundLabels = cell2mat(crf_labels); %%cell2mat(crf_labels); %
idx_ground = cell2mat(crf_labels) == 0;

[gnd_cloud, ~, groundOutliers] = pcdenoise(pointCloud(processedCloud(idx_ground,:)), 'Threshold', 0.3);

idx_tmp = groundLabels(idx_ground);
idx_tmp(groundOutliers) = 1;
groundLabels(idx_ground) = idx_tmp;





% % groundLabels = ones(length(ptCloud),1);
% % finalCloud = [];
% % 
% %     segmentHeigt_mean = mean(ptCloud(:,3));
% % 
% %     E = edges(delaunayTriangulation(ptCloud(:,1:2)));
% %         nNodes = length(ptCloud);
% % 
% %     [pointFeatures, ~] = getLidarSlopeFeatures(ptCloud, E, nNodes);
% %     heightDifference = getHeightDifference(ptCloud(:,3), E);
% %     heightLabels = graphSegmentation(nNodes, E, heightDifference, 100);
% %     
% %     normHeight = normalize(ptCloud(:,3), 'center', 'median');
% %     segHeightFeat = getLidarSegmentFeatures(ptCloud, normHeight, ...
% %             heightLabels);
% % 
% % for j = 1: max(segmentLabels(:))
% %     idx_labels = segmentLabels(:,1)==j;
% %     cloud_tmp = ptCloud(idx_labels,:);
% %     if sum(idx_labels) >= 128 %%select bigger segments
% %        
% %             E_ = edges(delaunayTriangulation(cloud_tmp(:,1:2)));
% % 
% %         %     curvatureFeat = getLidarCurvatureFeatures(ptCloud, E);
% %         
% %         inputVector = [pointFeatures(idx_labels), segHeightFeat(idx_labels), normHeight(idx_labels)];
% %         
% %         [crf_labels, ~] = crf_Lidar_cell({inputVector}, {ones(length(cloud_tmp), 1)}, ...
% %             {E_}, 'l_bfgs', 'infer', w);
% %         
% %         groundLabels(idx_labels) = cell2mat(crf_labels);
% %     end
% %     
% % end

%% Compute new segments based on height difference
% % ptLabels_height = graphHeightSegmentation(cloudGround_, graphStructure, 'compute', 100);


%%
if contains(action, 'plot')
    %         figure
    subplot(2,2,[1 2])
%     RGB = label2rgb(segmentLabels, 'prism', 'c');
    pcshow(ptCloud, 'MarkerSize', 50);
%     colormap([RGB(:,1,1), RGB(:,1,2), RGB(:,1,3)]);
%     colorbar
    title('Original Point CLoud')
    subplot(2,2,3)
    RGB = label2rgb(groundLabels, 'prism', 'c');
    pcshow(processedCloud,[RGB(:,1,1), RGB(:,1,2), RGB(:,1,3)], 'MarkerSize', 50);
%     colormap([RGB(:,1,1), RGB(:,1,2), RGB(:,1,3)]);
%     colorbar
    title('Point Cloud labels')
    subplot(2,2,4)
    pcshow(gnd_cloud, 'MarkerSize', 50);
    title('Ground Cloud')

    
    pause(0.01);
end

end
