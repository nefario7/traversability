function centroids = farthestPointSampling(pointLocations,numPoints)
% The farthestPointSampling function selects a set of points from input
% points, which defines the centroids of local regions.
% pointLocations - PointCloud locations N-by-3.
% numPoints - Number of clusters to find.
% centroids - centroids of each farthest cluster.
    
    % Initialize initial indices as zeros.
    centroids = zeros(numPoints,1);
    
    % Distance from centroid to each point.
    distance = ones(size(pointLocations,1),1) .* 1e10; 
    
    % Random Initialization of the first point.
    farthest = randi([1,size(pointLocations,1)],1);
    
    for i = 1:numPoints
        centroids(i) = farthest;
        centroid = pointLocations(farthest,:);
        dist = sum(((pointLocations - centroid).^2),2);
        mask = dist < distance;
        distance(mask) = dist(mask);
        [~,farthest] = max(distance,[],1);
    end
end