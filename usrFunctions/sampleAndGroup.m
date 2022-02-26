function [newClusters,newpointFeatures] = sampleAndGroup(points,pointFeatures,nClusters,nSamples,radius)
% The sampleAndGroup layer first samples the point cloud to a given number of
% clusters and then constructs local region sets by finding neighboring
% points around the centroids using the queryBallPoint function.

    points = extractdata(squeeze(points));
    if ~isempty(pointFeatures)
        pointFeatures = extractdata(squeeze(pointFeatures));
    end
        
    % Find the centroids for nClusters - nClusters*3.
    centroids = farthestPointSampling(points,nClusters);
    newClusters = points(centroids,:);
    
    % Find the neareset nSamples for nClusters - nClusters*nSamples*3.
    idx = queryBallPoint(points,newClusters,nClusters,nSamples,radius);
    newPoints = reshape(points(idx,:),[nClusters,nSamples,3]);
    
    % Normalize the points in relation to the cluster center.
    newpointFeatures = newPoints - reshape(newClusters,nClusters,1,3);
    
    if ~isempty(pointFeatures)
        groupFeatures = reshape(pointFeatures(idx,:),...
                       [nClusters,nSamples,size(pointFeatures,2)]);
        newpointFeatures = cat(3,newPoints,groupFeatures);
    end
    
    newpointFeatures = dlarray(newpointFeatures,'SSC');
    newClusters = dlarray(newClusters,'SSC');
end