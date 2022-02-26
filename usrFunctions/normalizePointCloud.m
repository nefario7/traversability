function data = normalizePointCloud(data)
    if ~iscell(data)
        data = {data};
    end
    
    numObservations = size(data,1);
    for i = 1:numObservations
        % Scale points between 0 and 1.
        xlim = [min(data{i,1}(:,1)), max(data{i,1}(:,1))]; %%data{i,1}.XLimits;
        ylim = [min(data{i,1}(:,2)), max(data{i,1}(:,2))]; %%data{i,1}.YLimits;
        zlim = [min(data{i,1}(:,3)), max(data{i,1}(:,3))]; %%data{i,1}.ZLimits;
        
        xyzMin = [xlim(1) ylim(1) zlim(1)];
        xyzDiff = [diff(xlim) diff(ylim) diff(zlim)];
        
        tmp = (data{i,1}(:,:) - xyzMin) ./ xyzDiff; %%(data{i,1}.Location - xyzMin) ./ xyzDiff;
        % Convert the data to SCSB format.
        data{i,1} = permute(tmp,[1,3,2]);
    end
end
