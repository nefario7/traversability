function [w_crossVal, cm_mtx]  = crossValidationTrainingTesting(pcX, pcY, ...
pcZ, targetVector, feat_flag, structure_flag, nFeat, isprs_sample)

action = 'compute_save';             %% 'load', 'compute', 'compute_save'
CRF_Method = 'l_bfgs';           %% 'l_bfgs', 'pseudo'

kfold = 5;
w_crossVal = [];
cm_mtx = [];

for testSet = 1:kfold
    
    [pc_train, pc_test, y_train, y_test] = getTrainTestData([pcX, pcY, pcZ], ...
        targetVector, kfold, testSet);
    
    %% Compute graph structure (edges) of all ISPRS samples
    % Just compute the graph structure once (in the first set of features)
    if nFeat == 1
        E_train = computeStructure(pc_train, structure_flag, isprs_sample, ...
            'compute_save', ['train_kfold' mat2str(testSet)]);
        E_test = computeStructure(pc_test, structure_flag, isprs_sample, ...
            'compute_save', ['test_kfold' mat2str(testSet)]);
    else
        E_train = computeStructure(pc_train, structure_flag, isprs_sample, 'load', ...
            ['train_kfold' mat2str(testSet)]);
        E_test = computeStructure(pc_test, structure_flag, isprs_sample, 'load', ...
            ['test_kfold' mat2str(testSet)]);
    end
    
    
    %% Compute geometric features
    
    [geoFeatures_train, ~, ~]  = ...
        getGeometricFeatures(pc_train, E_train, feat_flag, structure_flag, isprs_sample,...
        action, ['train_kfold' mat2str(testSet)]);
    [geoFeatures_test, ~, ~] = ...
        getGeometricFeatures(pc_test, E_test, feat_flag, structure_flag, isprs_sample,...
        action, ['test_kfold' mat2str(testSet)]);
    
    %% Train CRF
    nNodes = length(pc_train);
    
    [~, w_crossVal] = getPotentialParam(geoFeatures_train, y_train, nNodes, E_train,...
        CRF_Method, 'train_crossVal', w_crossVal, testSet);
    
    %% Infer CRF
    nNodes = length(pc_test);
    [zLabels_test, ~] = getPotentialParam(geoFeatures_test, y_test, nNodes, E_test,...
        CRF_Method, 'infer', w_crossVal);
    
    
    %% Confusion matrix
%     labelNames = {'Terrain', 'Non-Terrain'};
    %cm_train = confusionmat(y_train, double(zLabels_train));
    cm_test = confusionmat(y_test, double(zLabels_test));
    cm_mtx = [cm_mtx cm_test];
end

end