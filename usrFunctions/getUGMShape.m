function X_temp = getUGMShape(inputVector)
nFeatures = size(inputVector,2);
nNodesEdges = size(inputVector,1);  %Number of nodes or edges
X_temp = [];
for j = 1: nFeatures
    x_temp = inputVector(:,j);
    x_temp = reshape(x_temp, 1, 1, nNodesEdges);
    X_temp = [X_temp x_temp];
end   
end