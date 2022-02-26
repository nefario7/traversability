function [treeLabels, ptDensity] = segmentByPtDensity(ptModes, action)

ptDensity = computePtDensity(ptModes, 'approximate');

% nn = 4;
% [ptNN, ptD] = knnsearch(ptModes(:,:), ptModes(:,:), 'K', nn);
% E = [repelem(ptNN(:,1), nn-1), reshape(ptNN(:,2:end)', [], 1)];
% [~, idx] = unique(sort(E')', 'rows', 'stable');
% E = E(idx,:);
% 
% % E_dist = ptDensity(E(:,1),:) - ptDensity(E(:,2),:);
% 
% 
% E_dist = reshape(ptD(:,2:end)',[],1);
% E_dist = E_dist(idx,:);
% 
% nNodes = length(ptModes);
% graphLabels = graphSegmentation(nNodes, E, E_dist, 50);
% 
% for k = 1:max(graphLabels)
%     idx_tmp = graphLabels==k;
%     ptDensity(idx_tmp) =  max(ptDensity(idx_tmp));
% end




idxAbove_50 = ptDensity >= median(ptDensity);
idxTmp = ptDensity(~idxAbove_50) >= median(ptDensity(~idxAbove_50));
idxAbove_25 = idxAbove_50;
idxAbove_25(idxTmp)  = 1;

treeLabels = zeros(length(ptDensity),1);
labels_tmp = pcsegdist(pointCloud([ptModes(idxAbove_25,1:2), ptDensity(idxAbove_25)]), 3);
tmpCloud = ptModes(idxAbove_25,1:3);

% % segmentMeanPt = [];
% % for k = 1:max(labels_tmp)
% %     idx = labels_tmp == k;
% %     segmentMeanPt = [segmentMeanPt; mean(ptCloud(idx,:),1)];
% % end
% % 
% % [idx_NN, d_NN] = knnsearch(segmentMeanPt(:,1:2), segmentMeanPt(:,1:2), 'K', 2);
% % 
% % idx_tmp = d_NN(:,2) < 150;
% % 
% % idx_NN = idx_NN(idx_tmp,:);
% % [idx_NN, ~] = unique(sort(idx_NN')', 'rows', 'stable');
% % 
% % for k = 1:length(idx_NN)
% %     labels_tmp(labels_tmp == idx_NN(k,1)) = idx_NN(k,2);
% % end


treeLabels(idxAbove_25,1) = labels_tmp;

% [treeLabels, segmentMeanPt] = joinNearSegments(ptCloud, treeLabels);


labelsSetSize = [];
for k = 1:max(treeLabels)
    labelsSetSize(k,1) = sum(treeLabels == k);
end
q04 = quantile(labelsSetSize, 0.4);
q09 = quantile(labelsSetSize, 0.90);

for k = 1:max(treeLabels)
    if (sum(treeLabels == k) >= q04) && (sum(treeLabels == k) <= q09)
        continue
    else
        treeLabels(treeLabels == k) = 0;
    end
end
idx_tmp = treeLabels ~=0;
labels_tmp = treeLabels(idx_tmp);
[~, ~, idxC] = unique(labels_tmp, 'stable');
treeLabels(idx_tmp) = idxC;

% [treeLabels, segmentMeanPt] = joinNearSegments(ptCloud, treeLabels);
% treeLabels(idx_tmp) = labels_tmp;


if contains(action, 'plot')
% treeLabels = pcsegdist(pointCloud(ptModes_vct(idxAbove_50,1:3)), 1.5);

    RGB = label2rgb(treeLabels, 'prism', 'c');
    subplot(1,2,1)
    pcshow(ptModes,  ptDensity, 'MarkerSize', 30)
    title('Modes Cloud')
    hold on
    pcshow(segmentMeanPt, 'g*', 'MarkerSize', 60)
    subplot(1,2,2)
    pcshow(ptModes, [RGB(:,1,1), RGB(:,1,2), RGB(:,1,3)], 'MarkerSize', 30)
    title('Segmented Cloud')
    pause
end

end