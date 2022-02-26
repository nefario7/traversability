function ptFPFHFeat_cell = computeFPFHfeatures(pcRaw_cell, action)

ptFPFHFeat_cell = {};
if contains(action, 'compute')
    
    ptFPFHFeat_cell = cellfun(@(ptCloud) extractFPFHFeatures(pointCloud(ptCloud(:,1:3))), ...
        pcRaw_cell, 'UniformOutput',false);
    
    if contains(action, '_save')
        save(['./Results/ptFPFHFeat_cell','.mat'], 'ptFPFHFeat_cell');
        disp(['Save: ', './Results/ptFPFHFeat_cell','.mat'])
    end
    
elseif strcmp(action, 'load')
    load(['./Results/ptFPFHFeat_cell','.mat'], 'ptFPFHFeat_cell');
    disp(['Load: ', './Results/ptFPFHFeat_cell','.mat'])
end
end