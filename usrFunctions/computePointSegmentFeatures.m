function geoFeatData_cell = computePointSegmentFeatures(pcRaw_cell, edges_cell, action, structure_flag)
%%
geoFeatData_cell = {};
if contains(action, 'compute')
    
    geoFeatData_cell = cellfun(@(ptCloud, E) getGeometricFeatures(ptCloud(:,1:3), ...
        E, 'pt_segSH'), pcRaw_cell, edges_cell, 'UniformOutput',false);
    
    if contains(action, '_save')
        save(['./Results/', structure_flag, 'GeoFeatData_cell','.mat'], 'geoFeatData_cell');
        disp(['Save: ', './Results/', structure_flag, 'GeoFeatData_cell','.mat'])
    end
    
elseif strcmp(action, 'load')
    load(['./Results/', structure_flag, 'GeoFeatData_cell','.mat'], 'geoFeatData_cell');
    disp(['Load: ', './Results/', structure_flag, 'GeoFeatData_cell','.mat'])
end



end