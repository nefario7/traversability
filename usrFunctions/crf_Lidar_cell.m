function [yDecode_cell, w] = crf_Lidar_cell(inputVector_cell, targetVector_cell, ...
    pcEdges_cell, method, action, w_infer, testSet)

switch nargin
    case 3
        method = 'l_bfgs';
        action = 'train';
        w_infer = [];
        testSet = 1;
    case 4
        action = 'train';
        w_infer = [];
        testSet = 1;
    case 5
        w_infer = [];
        testSet = 1;
    case 6
        testSet = 1;
end

%%

nData = length(inputVector_cell);
data_cell = cell(nData,1);
disp('Setting up data')
for idx_cell=1:nData
    
    inputVector = inputVector_cell{idx_cell};
    targetVector = targetVector_cell{idx_cell};
    nNodes = length(inputVector);
    pcEdges = pcEdges_cell{idx_cell};
    
    
    %% Initial set up
    y = int32(1+targetVector);
    y = reshape(y,1,1,length(y));
    data_cell{idx_cell}.Y = y;
    
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
    
    
    data_cell{idx_cell}.edgeStruct = edgeStruct;
    %% Make Xnode, Xedge, nodeMap, edgeMap, initialize weights
    
    % Standardize Columns
    tied = 1;
    Xnode = [ones(1,1,nNodes) UGM_standardizeCols(X,tied)];
        
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
    
    
    data_cell{idx_cell}.Xnode = Xnode;
    data_cell{idx_cell}.Xedge = Xedge;
    data_cell{idx_cell}.nodeMap = nodeMap;
    data_cell{idx_cell}.edgeMap = edgeMap;
    
    nParams = max([nodeMap(:);edgeMap(:)]);
    disp(idx_cell)
end

%% Train with Pseudo-likelihood
% % if strcmp(method,'pseudo')
% %     if contains(action, '_crossVal')
% %         if testSet == 1
% %             w = zeros(nParams,1);
% %         else
% %             w = w_infer;
% %         end
% %     else
% %         w = zeros(nParams,1);
% %     end
% %         
% %     if contains(action, 'train')
% %         funObj = @(w)UGM_CRF_PseudoNLL(w,Xnode,Xedge,y,nodeMap,edgeMap,edgeStruct);
% %         w = minFunc(funObj,w);        
% %     elseif strcmp(action, 'infer') 
% %         w = w_infer;
% %     end
% %     
% %     % Inference
% %     [nodePot,edgePot] = UGM_CRF_makePotentials(w,Xnode,Xedge,nodeMap,edgeMap,edgeStruct);
% %     yDecode = UGM_Decode_ICM(nodePot,edgePot,edgeStruct);
% % %     save('weights_pseudo.mat', 'w');
% % end

%% Train with loopy belief propagation for approximate inference
if strcmp(method,'l_bfgs')
    
    if contains(action, '_crossVal')
        if testSet == 1
            w = zeros(nParams,1);
        else
            w = w_infer;
        end
    else
        w = zeros(nParams,1);
    end
    
    if contains(action, 'train')
        disp('Training with l_bfgs')
        UGM_CRFcell_NLL(w,data_cell,@UGM_Infer_LBP);
        funObj = @(w)UGM_CRFcell_NLL(w,data_cell,@UGM_Infer_LBP);
        
        lambda = ones(size(w));
        penalizedFunObj = @(w)penalizedL2(w,funObj,lambda);
        options.Display = 'full';
        w = minFunc(penalizedFunObj,w,options);

%         funObj = @(w)UGM_CRF_NLL(w,Xnode,Xedge,y,nodeMap,edgeMap,edgeStruct,@UGM_Infer_LBP);
%         UB = inf*ones(nParams,1); % No upper bound on parameters
%         LB = [-inf*ones(nParams/2,1); zeros(nParams/2, 1)]; %[-inf;-inf;-inf;0;0;0];
%         w = minConf_TMP(penalizedFunObj,w,LB,UB);
%         w = minFunc(funObj,w);   
    elseif strcmp(action, 'infer')
        w = w_infer;
    end
    
    disp('Computing potentials')
    yDecode_cell = {};
    for idx_cell = 1: nData
        [nodePot,edgePot] = UGM_CRF_makePotentials(w,data_cell{idx_cell}.Xnode,...
            data_cell{idx_cell}.Xedge, data_cell{idx_cell}.nodeMap,data_cell{idx_cell}.edgeMap,...
            data_cell{idx_cell}.edgeStruct);
        
        yDecode = UGM_Decode_ICM(nodePot,edgePot, data_cell{idx_cell}.edgeStruct);
        yDecode_cell{idx_cell} = yDecode -1;
    end
    
% 	save('./Results/fractalProcessing/CRF_lidar/w_lbfgs.mat', 'w');

    
    % Inference
end

% yDecode = yDecode -1;
%%
% figure
% pcshow([pcX, pcY, pcZ], yDecode);
% title('Infered')
% figure
% pcshow([pcX, pcY, pcZ], targetVector);
% title('Ground truth')

end



















