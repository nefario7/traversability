function  groundCloud_guess = estimateGroundElevation(ptCloud, treeSegments, regressorName, action)
%%
% % load('./Results/TreeSegmentation/bestTreeSegments.mat', 'bestTreeSegments')
% % load('./Results/TreeSegmentation/gridPtCloud.mat', 'gridPtCloud')
% % load('./Results/TreeSegmentation/treeSegments_fine.mat', 'treeSegments')
% % 
% % ptCloud = gridPtCloud(:,1:3);
% % 
% % treeSegments = joinNearSegments(ptCloud, treeSegments, 'xy_maxHeight');
% % treeSegments = addInsidePoints2segment(treeSegments, gridPtCloud(:,1:3), 'xy_maxHeight');
% % 
% % 
% % treeSegments = removeQSegments(treeSegments, 0.1, 0.9);
% % 
% % RGB = label2rgb(treeSegments, 'prism', 'c');
% % figure
% % pcshow(ptCloud, [RGB(:,1,1), RGB(:,1,2), RGB(:,1,3)], 'MarkerSize', 80);
% % 
% % regressorName = 'jucker';

% groundPoints_vct = [];
groundElevation_vct = [];
crownDiameter_vct = [];
for k = 1:max(treeSegments)
    idx = treeSegments == k;
    if sum(idx) >= 60
        tmpCloud = ptCloud(idx,:);
        [~, idx_max] = max(tmpCloud(:,3), [], 1);
        xy_max = tmpCloud(idx_max,1:2);
        
        [idx_convHull, crownArea] = convhull(tmpCloud(:,1:2));
        [~, crownVolume] = convhull(tmpCloud(:,1:3));
        
        r = vecnorm(tmpCloud(idx_convHull,1:2) - xy_max, 2, 2);
        crownDiameter = 2*(max(r(:)));
        
        treeHeight = [];
        switch regressorName
            case 'newfor_1'
                mdl_newFor_1 = loadLearnerForCoder('./Results/Regression/mdl_newFor_1');
                X = [crownArea, crownDiameter, crownVolume];
                treeHeight = exp(predict(mdl_newFor_1, log(X(:,:))));
                
            case 'newfor_2'
                load('./Results/Regression/coeff_newfor_2.mat', 'coeff_newfor_2');
                load('./Results/Regression/sigma_newfor_2.mat', 'sigma_newfor_2');
                treeHeight = exp(coeff_newfor_2(1)).*(crownDiameter.^coeff_newfor_2(2)).*exp((sigma_newfor_2^2)/2);
                
            case 'haeni'
                load('./Results/Regression/coeff_haeni.mat', 'coeff_haeni');
                load('./Results/Regression/sigma_haeni.mat', 'sigma_haeni');
                treeHeight = exp(coeff_haeni(1)).*(crownDiameter.^coeff_haeni(2)).*exp((sigma_haeni^2)/2);
            case 'jucker'
                load('./Results/Regression/coeff_jucker.mat', 'coeff_jucker');
                load('./Results/Regression/sigma_jucker.mat', 'sigma_jucker');
                treeHeight = exp(coeff_jucker(1)).*(crownDiameter.^coeff_jucker(2)).*exp((sigma_jucker^2)/2);
        end
        
        q01 = quantile(tmpCloud(:,3), 0.1);
        q09 = quantile(tmpCloud(:,3), 0.9);
        idx_q01 = tmpCloud(:,3) <= q01;
        idx_q09 = tmpCloud(:,3) >= q09;
        
        crownMaxHeight_mean = mean(tmpCloud(idx_q09,3));
        crownMinHeight_mean = mean(tmpCloud(idx_q01,3));
        
        crownHeight = crownMaxHeight_mean - crownMinHeight_mean;
        
        groundElevation = treeHeight - crownHeight;
        groundElevation_vct = [groundElevation_vct, groundElevation];
        crownDiameter_vct = [crownDiameter_vct, crownDiameter];
    end
end

idx_trees = treeSegments ~= 0;
treeCloud = ptCloud(idx_trees,1:3);
% treeLabels = treeSegments(idx_trees,:);

idx_ground = segmentGroundSMRF(pointCloud(treeCloud), mean(crownDiameter_vct),...
    'ElevationThreshold', 0.5, 'SlopeThreshold', 0.3);
groundCloud_guess = treeCloud(idx_ground,:);
switch action
    case 'mean'
        groundCloud_guess(:,3) = groundCloud_guess(:,3) - mean(groundElevation_vct);
	case 'median'
        groundCloud_guess(:,3) = groundCloud_guess(:,3) - median(groundElevation_vct);
    case 'max'
        q09 = quantile(groundElevation_vct, 0.9);
        maxHeightDiff = mean(groundElevation_vct(groundElevation_vct>=q09));
        groundCloud_guess(:,3) = groundCloud_guess(:,3) - maxHeightDiff;
    case 'min'
        q01 = quantile(groundElevation_vct, 0.1);
        minHeightDiff = mean(groundElevation_vct(groundElevation_vct<=q01));
        groundCloud_guess(:,3) = groundCloud_guess(:,3) - minHeightDiff;
end


end