function cloudProcessed = fd_processing(validCloud, currInfo, currLabels, fdGround_threshold, fdNonGround_threshold, graphStructure, action)

currInfo = sortrows(currInfo, 1); %%sort by fractal dimension

cloudGround_ = [];
labelGround_ = [];

cloudNonGround_ = [];
labelNonGround_ = [];

cloudHeight_mean = mean(validCloud(:,3));
groundLabel = 1;
nonGroundLabel = 1;
for j = 1: size(currInfo,1)
    idx_labels = currLabels(:,1)==currInfo(j,2);
    cloud_tmp = validCloud(idx_labels,:);
    segmentHeigt_mean = mean(cloud_tmp(:,3));
    
    if   (segmentHeigt_mean <= cloudHeight_mean) %% (currInfo(j,1) <= fdGround_threshold)  %% && &&
        cloudGround_ = [cloudGround_; cloud_tmp];
        labelGround_ = [labelGround_; ones(length(cloud_tmp),1)*groundLabel];
        groundLabel = groundLabel + 1;
        
    else
        cloudNonGround_ = [cloudNonGround_; cloud_tmp];
        labelNonGround_ = [labelNonGround_; ones(length(cloud_tmp),1)*nonGroundLabel];
        nonGroundLabel = nonGroundLabel + 1;
    end
    
% %     if (currInfo(j,1) >= fdNonGround_threshold) && (segmentHeigt_mean >= cloudHeight_mean) %%&&
% %         finalCloudNonGround = [finalCloudNonGround; cloud_tmp];
% %         finalLabelNonGround = [finalLabelNonGround; ones(length(cloud_tmp),1)*nonGroundLabel];
% %         nonGroundLabel = nonGroundLabel + 1;
% %     end
end

%% Compute new segments based on height difference
% % ptLabels_height = graphHeightSegmentation(cloudGround_, graphStructure, 'compute', 100);


%%
if contains(action, 'plot')
    %         figure
    subplot(1,2,1)
    RGB = label2rgb(labelNonGround_, 'prism', 'c');
    pcshow(cloudNonGround_,[RGB(:,1,1), RGB(:,1,2), RGB(:,1,3)], 'MarkerSize', 50);
    colormap([RGB(:,1,1), RGB(:,1,2), RGB(:,1,3)]);
%     colorbar
    title('Final segments nonground')
    subplot(1,2,2)
    RGB = label2rgb(labelGround_, 'prism', 'c');
    pcshow(cloudGround_,[RGB(:,1,1), RGB(:,1,2), RGB(:,1,3)], 'MarkerSize', 50);
    colormap([RGB(:,1,1), RGB(:,1,2), RGB(:,1,3)]);
%     colorbar
    title('Final segments ground')
    
    pause
end

cloudProcessed = cloudGround_;

end
