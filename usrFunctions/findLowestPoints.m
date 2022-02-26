function idxFinal = findLowestPoints(ptCloud)
% %%    
%     ptCloud = gridCloud;
    x_min = min(ptCloud(:,1));
    x_max = max(ptCloud(:,1));
    
    y_min = min(ptCloud(:,2));
    y_max = max(ptCloud(:,2));
    
    xGrid = linspace(x_min, x_max, 10);
    yGrid = linspace(y_min, y_max, 10);
    
    [X, Y] = meshgrid(xGrid, yGrid);
    
%     ptIdx = knnsearch([X(:), Y(:)], ptCloud(:,1:2));
    ptIdx = knnsearch(ptCloud(:,1:2), [X(:), Y(:)], 'K', 10);
    
    minIdx = [];
    for k =1 : size(ptIdx, 1)
       [~, idx] = min(ptCloud(ptIdx(k,:),3));
       minIdx = [minIdx; ptIdx(k,idx)];
    end
    minIdx = unique(minIdx);
    ptCloud_tmp = ptCloud(minIdx, :);
    
    E = edges(delaunayTriangulation(ptCloud_tmp(:,1), ptCloud_tmp(:,2)));
    
    nNodes = size(ptCloud_tmp,1);
    slope_vct = getPointsSlopes(ptCloud_tmp(:,1), ptCloud_tmp(:,2), ptCloud_tmp(:,3)...
        , nNodes, E);
%     E_relHeight = getHeightDifference(ptCloud_tmp(:,3), E);
	
    labels = graphSegmentation(nNodes, E, abs(slope_vct), 10);
    
    medianHeight = median(ptCloud_tmp(:,3));
    
    idxFinal = [];
    for k = 1:max(labels)
        tmp = mean(ptCloud_tmp(labels==k,3));
        if tmp < medianHeight
            idxFinal = [idxFinal; minIdx(labels==k)];
        end
    end
    
    
%     pcshow(ptCloud_tmp, labels, 'MarkerSize', 30);
%     colormap(prism)
%     
%     
%     
%     [~, idx] = sort(ptCloud_tmp(:,3));
%     minIdx = minIdx(idx,:);
%     ptCloud_tmp = ptCloud_tmp(idx, :);
%    
%     ptCloud_tmp2 = reshape(ptCloud_tmp', [1,3, size(ptCloud_tmp,1)]);
%     
%     tmp = ptCloud_tmp2 - ptCloud_tmp;
%     
%     
%     ptIdx = knnsearch(ptCloud_tmp, ptCloud_tmp, 'K', 2);
%     
%     tmp = abs(ptCloud_tmp(ptIdx(:,1),3) - ptCloud_tmp(ptIdx(:,2),3));
%     minIdx(tmp>1) = [];
    
    %%
% pcshow(ptCloud(:,:), 'g', 'MarkerSize', 30)
% hold on
%     pcshow(ptCloud(idxFinal,:), 'or', 'MarkerSize', 30)

end
