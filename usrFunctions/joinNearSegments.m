function finalLabels = joinNearSegments(ptCloud, labels, action)


[D, ~, xy_center, xy_maxHeight] = getSegmentDiameters(ptCloud, labels);

if contains(action, 'xy_mean')
    center = xy_center;
elseif contains(action, 'xy_maxHeight')
    center = xy_maxHeight;
end

nCenter = size(center,1);

if  nCenter >= 3
    E = edges(delaunayTriangulation(center(:,1), center(:,2)));
    d = vecnorm(center(E(:,1),:) - center(E(:,2),:), 2, 2);
    
    R = max([D(E(:,1),:), D(E(:,2),:)],[],2)/2;
    
    idx = d < R;
    
    E = E(idx,:);
    [E, ~] = unique(sort(E')', 'rows', 'stable');
    
    E = sortrows(E,[1, 2]);
    
    for k = 1:size(E,1)
        labels(labels == E(k,1)) = E(k,2);
    end
    
    idx_tmp = labels ~=0;
    labels_tmp = labels(idx_tmp);
    
    [~, ~, idxC] = unique(labels_tmp, 'stable');
    labels(idx_tmp) = idxC;
    
    finalLabels = labels;
elseif nCenter == 2
    E = [1,2];
    d = vecnorm(center(E(:,1),:) - center(E(:,2),:), 2, 2);
    
    R = max([D(E(:,1),:), D(E(:,2),:)],[],2)/2;
    
    idx = d < R;
    
    E = E(idx,:);
    [E, ~] = unique(sort(E')', 'rows', 'stable');
    
    E = sortrows(E,[1, 2]);
    
    for k = 1:size(E,1)
        labels(labels == E(k,1)) = E(k,2);
    end
    
    idx_tmp = labels ~=0;
    labels_tmp = labels(idx_tmp);
    
    [~, ~, idxC] = unique(labels_tmp, 'stable');
    labels(idx_tmp) = idxC;
    
    finalLabels = labels;
else 
    finalLabels = labels;
end


% % segmentMean = [];
% % furthestPoint = [];
% % for k = 1:max(labels)
% %     idx = labels == k;
% %     tmp_mean = mean(ptCloud(idx,1:2),1);
% %     segmentMean = [segmentMean; tmp_mean];
% % 	furthestPoint = [furthestPoint; max(vecnorm(ptCloud(idx,1:2) - tmp_mean,2 ,2))];
% % end
% % 
% % E = edges(delaunayTriangulation(segmentMean(:,1), segmentMean(:,2)));
% % d = vecnorm(segmentMean(E(:,1),:) - segmentMean(E(:,2),:), 2, 2);
% % d_max = max([furthestPoint(E(:,1),:), furthestPoint(E(:,2),:)],[],  2);
% %  
% % idx = d < d_max;
% % 
% % E = E(idx,:);
% % [E, ~] = unique(sort(E')', 'rows', 'stable');
% % 
% % E = sortrows(E,[1, 2]);
% % 
% % for k = 1:size(E,1)
% %     labels(labels == E(k,1)) = E(k,2);
% % end
% % 
% % idx_tmp = labels ~=0;
% % labels_tmp = labels(idx_tmp);
% % 
% % [~, ~, idxC] = unique(labels_tmp, 'stable');
% % labels(idx_tmp) = idxC;
% % 
% % finalLabels = labels;



% [idx_NN, d_NN] = knnsearch(segmentMean(:,1:2), segmentMean(:,1:2), 'K', 2);
% idx_tmp = d_NN(:,2) <= 3; %ceil(mean(d_NN(:,2)));
% 
% idx_NN = idx_NN(idx_tmp,:);
% [idx_NN, ~] = unique(sort(idx_NN')', 'rows', 'stable');
% 
% idx_NN = sortrows(idx_NN,[1, 2]);
% 
% for k = 1:length(idx_NN)
%     labels(labels == idx_NN(k,1)) = idx_NN(k,2);
% end
% 
% idx_tmp = labels ~=0;
% labels_tmp = labels(idx_tmp);
% 
% [~, ~, idxC] = unique(labels_tmp, 'stable');
% labels(idx_tmp) = idxC;
% 
% finalLabels = labels;
% 
% segmentMean = [];
% for k = 1:max(labels)
%     idx = labels == k;
%     segmentMean = [segmentMean; mean(ptCloud(idx,:),1)];
% end
end