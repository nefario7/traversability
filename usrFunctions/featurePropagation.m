function newPoints = featurePropagation(points1,points2,pointNetFeatures1,pointNetFeatures2)
    % Use the inverse distance weighted average based on the k nearest neighbors to
    % interpolate features.
    
    points1 = extractdata(squeeze(points1));
    points2 = extractdata(squeeze(points2));
    if ~isempty(pointNetFeatures1)
    pointNetFeatures1 = extractdata(squeeze(pointNetFeatures1));
    end
    pointNetFeatures2 = extractdata(squeeze(pointNetFeatures2));
    
    % Find the K nearest neighbors for each point.
    dists = squareDistance(points1,points2);
    [dists,idx] = sort(dists,2,"ascend");
    dists = dists(:,1:3);
    idx = idx(:,1:3);
    
    % Calculate the weights for interpolation.
    dist_recip = 1./(dists+1e-8);
    normFactor = sum(dist_recip,2);
    weights = dist_recip./normFactor;
    
    % Perform weighted interpolation.
    interpolatedPoints = pointNetFeatures2(idx,:);
    interpolatedPoints = reshape(interpolatedPoints,[size(idx,1),size(idx,2),size(pointNetFeatures2,2)]);
    
    interpolatedPoints = interpolatedPoints .* weights;
    interpolatedPoints = squeeze(sum(interpolatedPoints,2));
    
    if ~isempty(pointNetFeatures1)
        % Calculate the new points.
        newPoints = cat(2,pointNetFeatures1,interpolatedPoints);
    else
        newPoints = interpolatedPoints;
    end
    
     newPoints = dlarray(newPoints,'SCS');
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