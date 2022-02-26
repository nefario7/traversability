function [pc_train, pc_test, y_train, y_test] = ...
    getTrainTestData(ptCloud, targetVector, kfold, testSet) %, inputVector, targetVector)

switch nargin
    case 2
        kfold = 5;
        testSet = 5;
    case 3
        testSet = 5;
end

pcX = ptCloud(:,1);
pcY = ptCloud(:,2);
pcZ = ptCloud(:,3);

[~, xLimits] = hist(pcX,kfold);
%% generate random sets
% % set_1 = 9;%%randi([1,10]);
% % set_2 = 10;%%randi([1,10]);
% % while set_1 == set_2
% %     set_2 = randi([1,10]);
% % end

%% generate train and test data
pc_train = [];
pc_test = [];

% % X_train = [];
% % X_test = [];

y_train = [];
y_test = [];

% % figure
for k = 1:length(xLimits)
    idx = [];
    if k == 1
        idx = pcX <= xLimits(k);
    elseif k > 1 && k <= length(xLimits)
        idx = pcX <= xLimits(k) & pcX > xLimits(k - 1);
    else 
        idx = pcX > xLimits(k);
    end
  
    tmpPC = [pcX(idx), pcY(idx), pcZ(idx)];
% %     subplot(1,10,k)
% %     pcs = pcshow(tmpPC, targetVector(idx));
% %     colormap('summer')
% %     view(2)
    if k ~= testSet
        pc_train = [pc_train; tmpPC];
        y_train = [y_train; targetVector(idx)];
% %         X_train = [X_train; inputVector(idx,:)];
    elseif k== testSet
        pc_test = [pc_test; tmpPC];
        y_test = [y_test; targetVector(idx)];
% %         X_test = [X_test; inputVector(idx,:)];
    end
end
% % figure
% % pcshow(pcTrain, X_train)

end