function groupIdx = queryBallPoint(XYZ,newXYZ,nClusters,nSamples,radius)
% Given the cluster center, the queryBallPoint finds all points that are
% within a radius to the query point.

    N = size(XYZ,1);
    groupIdx = reshape(1:N,[1,N]);
    groupIdx = repmat(groupIdx,[nClusters,1]);
    
    % Find the distance between the centroids and given points.
    sqDist = squareDistance(newXYZ,XYZ);    
    
    % Find the points that are inside the given radius.
    groupIdx(sqDist > (radius)^2) = N;
    groupIdx = sort(groupIdx,2,"ascend");
    
    % Find the closest nSamples points within the given radius.
    groupIdx = groupIdx(:,1:nSamples);
    groupFirst = repmat(groupIdx(:,1),1,nSamples);
    mask = (groupIdx == N);
    groupIdx(mask) = groupFirst(mask);
end

% Find the squared distance.
function dist = squareDistance(src,dst)
    dist = -2 * (src*permute(dst,[2,1,3]));
    tmp1 = sum(src.^2,2);
    tmp1 = reshape(tmp1,[size(src,1),1]);
    tmp2 = sum(dst.^2,2);
    tmp2 = reshape(tmp2,[1,size(dst,1)]);
    dist = dist + tmp1 + tmp2;
end