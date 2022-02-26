function [w, Xnode, Xedge, y, nodeMap, edgeMap, edgeStruct] = CRF_ptCloudSetup(inputVector, targetVector, nNodes, pcEdges)

%% Initial set up
y = int32(1+targetVector);
y = reshape(y,1,1,length(y));
v = ones(length(pcEdges),1);
nStates = 2;

% Vector formats: features = [nInstances nFeatures nNodes]
nFeatures = size(inputVector,2);
X = [];
for k = 1: nFeatures
    x_temp = inputVector(:,k);
    x_temp = reshape(x_temp, 1, 1, nNodes);
    X = [X x_temp];
end

%% Make edge structure

adj = sparse( pcEdges(:,1), pcEdges(:,2),v , nNodes, nNodes);
adj = adj+adj';

useMex = 1;
maxIter = 60;
edgeStruct = UGM_makeEdgeStruct(adj,nStates, useMex, maxIter);
nEdges = edgeStruct.nEdges;
%% Make Xnode, Xedge, nodeMap, edgeMap, initialize weights

% Standardize Columns
tied = 1;
Xnode = [ones(1,1,nNodes) UGM_standardizeCols(X,tied)];
Xnode(isnan(Xnode)) = 0;
nNodeFeatures = size(Xnode,2);

% Make nodeMap
nodeMap = zeros(nNodes,nStates,nNodeFeatures,'int32');
for f = 1:nNodeFeatures
    nodeMap(:,1,f) = f;
end

sharedFeatures = zeros(1, nNodeFeatures);
sharedFeatures(1,1) = 1;

% Make Xedge
Xedge = UGM_makeEdgeFeaturesInvAbsDif(Xnode,edgeStruct.edgeEnds,sharedFeatures);
nEdgeFeatures = size(Xedge,2);

% Make edgeMap
f = max(nodeMap(:));
edgeMap = zeros(nStates,nStates,nEdges,nEdgeFeatures,'int32');
for edgeFeat = 1:nEdgeFeatures
   edgeMap(1,1,:,edgeFeat) = f+edgeFeat;
   edgeMap(2,2,:,edgeFeat) = f+edgeFeat;
end

nParams = max([nodeMap(:);edgeMap(:)]);
w = zeros(nParams,1);

