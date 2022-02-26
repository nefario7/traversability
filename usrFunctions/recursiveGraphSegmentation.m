function [labels, ptCloud, ptModes, ptDensity] = recursiveGraphSegmentation(ptCloud, ptModes, ptDensity, labels, action)

%% check segments size
if ~isempty(labels)
    nLabel = 1;
    labels_tmp = labels;
    for k = 1: max(labels_tmp)
        idx = labels_tmp == k;
        nPts = sum(idx);
        if nPts < 15
            labels_tmp(idx) = 0;
%             ptCloud(idx,:) = [];
%             ptDensity(idx,:) = [];
%             ptModes(idx,:) = [];
        else
            labels_tmp(idx) = nLabel;
            nLabel = nLabel +1;
        end
    end
    labels = labels_tmp;
    
    if contains(action, 'plot') && ~isempty(labels)
        RGB = label2rgb(labels, 'prism', 'c');
        figure
        subplot(1,3,1)
        pcshow(ptCloud, ptDensity, 'MarkerSize', 80);
        subplot(1,3,2)
        pcshow(ptModes, [RGB(:,1,1), RGB(:,1,2), RGB(:,1,3)], 'MarkerSize', 80);
        subplot(1,3,3)
        pcshow(ptCloud, [RGB(:,1,1), RGB(:,1,2), RGB(:,1,3)], 'MarkerSize', 80);
    end
end

%% graph segmentation
if contains(action, 'delaunay')  
    E = edges(delaunayTriangulation(ptCloud(:,1), ptCloud(:,2)));
    nNodes = length(ptCloud);
    E_dist = vecnorm(ptCloud(E(:,1),1:3) - ptCloud(E(:,2),1:3),2,2);
    graphLabels = graphSegmentation(nNodes, E, E_dist, 50);
    
    [graphLabels, ptCloud, ptModes, ptDensity] = recursiveGraphSegmentation(ptCloud, ptModes, ...
        ptDensity, graphLabels, 'none');
    
%     ptCloud_final = [];
%     ptModes_final = [];
%     ptDensity_final = [];
    finalLabels = zeros(length(ptCloud),1);
    for k = 1:max(graphLabels)
        idx_label = graphLabels == k;
        ptCloud_tmp = ptCloud(idx_label,:);
        ptDensity_tmp = ptDensity(idx_label,:);
        ptModes_tmp = ptModes(idx_label,:);
        
        [labels_tmp, ~, ~, ~] = recursiveGraphSegmentation(ptCloud_tmp, ptModes_tmp, ...
            ptDensity_tmp, graphLabels(idx_label,:), 'nn_10');
       
        if ~isempty(finalLabels)
            idx = labels_tmp ~= 0;
            labels_tmp(idx) = labels_tmp(idx) + max(finalLabels);
            finalLabels(idx_label) = labels_tmp;
        else
            finalLabels(idx_label) = labels_tmp;
        end
        
%         ptCloud_final = [ptCloud_final; ptCloud_tmp];
%         ptModes_final = [ptModes_final; ptModes_tmp];
%         ptDensity_final = [ptDensity_final; ptDensity_tmp];
    end
%     ptCloud = ptCloud_final;
%     ptModes = ptModes_final;
%     ptDensity = ptDensity_final;
    if sum(finalLabels) ~= 0
        labels = joinNearSegments(ptCloud, finalLabels);
    else
        labels = finalLabels;
    end
%     labels = finalLabels;
    
elseif contains(action, 'nn_10')
    nn = 10;
    nNodes = length(ptCloud);
    
    [ptNN, ptD] = knnsearch([ptModes(:,1:2), ptDensity], [ptModes(:,1:2), ptDensity], 'K', nn);
    E = [repelem(ptNN(:,1), nn-1), reshape(ptNN(:,2:end)', [], 1)];
    [~, idx] = unique(sort(E')', 'rows', 'stable');
    E = E(idx,:);
    E_dist = reshape(ptD(:,2:end)',[],1);
    E_dist = E_dist(idx,:);
    
    graphLabels = graphSegmentation(nNodes, E, E_dist, 50);
%     ptCloud_final = [];
%     ptModes_final = [];
%     ptDensity_final = [];
    finalLabels = zeros(size(labels));
    for k = 1:max(graphLabels)
        idx_label = graphLabels == k;
        ptCloud_tmp = ptCloud(idx_label,:);
        ptDensity_tmp = ptDensity(idx_label,:);
        ptModes_tmp = ptModes(idx_label,:);
        
        [labels_tmp, ~, ~, ~]  = recursiveGraphSegmentation(ptCloud_tmp, ptModes_tmp, ...
            ptDensity_tmp, graphLabels(idx_label), 'nn_5');
        
        if ~isempty(finalLabels)
            idx = labels_tmp ~= 0;
            labels_tmp(idx) = labels_tmp(idx) + max(finalLabels);
            finalLabels(idx_label) = labels_tmp;
        else
            finalLabels(idx_label) = labels_tmp;
        end
%         ptCloud_final = [ptCloud_final; ptCloud_tmp];
%         ptModes_final = [ptModes_final; ptModes_tmp];
%         ptDensity_final = [ptDensity_final; ptDensity_tmp];
    end
%     ptCloud = ptCloud_final;
%     ptModes = ptModes_final;
%     ptDensity = ptDensity_final;
    if sum(finalLabels) ~= 0
        labels = joinNearSegments(ptCloud, finalLabels);
    else
        labels = finalLabels;
    end


    
elseif contains(action, 'nn_5') 
    nn = 5;
    if sum(labels) ~= 0
        nNodes = length(ptCloud);
        
        [ptNN, ptD] = knnsearch(ptModes(:,1:3), ptModes(:,1:3), 'K', nn);
        
        E = [repelem(ptNN(:,1), nn-1), reshape(ptNN(:,2:end)', [], 1)];
        [~, idx] = unique(sort(E')', 'rows', 'stable');
        E = E(idx,:);
        
        %     E_dist = reshape(ptD(:,2:end)',[],1);
        %     E_dist = E_dist(idx,:);
        E_dist = abs(ptModes(E(:,1),3) - ptModes(E(:,2),3));
        
        
%         idx_dist = E_dist < 1;
%         E_dist = E_dist(idx_dist,:);
%         
%         E = E(idx_dist,:);
        
        graphLabels = graphSegmentation(nNodes, E, E_dist, 50);
        graphLabels = joinNearSegments(ptCloud, graphLabels, 'xy_mean');
        
        [labels, ptCloud, ptModes, ptDensity]  = recursiveGraphSegmentation(ptCloud, ptModes, ...
            ptDensity, graphLabels, 'none');
        
%         if sum(labels) ~= 0
%             maxHeight = -inf;
%             maxLabel = 0;
%             for k = 1:max(labels)
%                 idx = labels == k;
%                 tmp = median(ptCloud(idx,3));
%                 
%                 if tmp >= maxHeight
%                     maxHeight = tmp;
%                     maxLabel = k;
%                 end
%             end
%             
%             idx = labels == maxLabel;
%             labels(~idx,:) = 0;
%             %                 ptCloud(~idx,:) =[];
%             %                 ptModes(~idx,:) =[];
%             %                 ptDensity(~idx,:) =[];
%             
%             labels(idx,:) = 1;
%             
%         end
    end

end

