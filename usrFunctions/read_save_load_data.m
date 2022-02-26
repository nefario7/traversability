function pcRaw_cell = read_save_load_data(pcFilenames, idxStart, idxEnd, action)
%%
% This function read save and load the ISPRS lidar pointclouds data set.
% Moreover for each point cloud a set of 26 geometric features (3D and 2D) are computed
if strcmp(action, 'load')
    disp('Loading data...')
    load('./Results/pcRaw_cell.mat')
    
elseif contains(action, 'read')
    % Set up initial variable
    pcRaw_cell = {};
    
    for k = 1:length(pcFilenames)
        dataFilepath = pcFilenames(k).folder;
        pcFilename = pcFilenames(k).name;
        
        disp(['Reading file: ', dataFilepath, '/', pcFilename])
        pcRaw = dlmread([dataFilepath '/' pcFilename]);
        if idxEnd > size(pcRaw,2)
            idxEnd = size(pcRaw,2);
        end
        pcRaw = pcRaw(:,idxStart:idxEnd);
        disp('Processing ...')
        pcRaw_final = processLidarPoinCloud(pcRaw);
        pcRaw_cell{k,1} = pcRaw_final;
    end
    
    if contains(action, '_save')
        disp('Saving point cloud')
        save('./Results/pcRaw_cell.mat', 'pcRaw_cell')
    end
else
    disp('the action has not been identified')
end


end