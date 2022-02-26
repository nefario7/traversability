function data = onehotEncodeLabels(data,classNames)
    if ~iscell(data)
        data = {data};
    end

    numObservations = size(data,1);
    for i = 1:numObservations
       labels = data{i,1}; %%data{i,1}';
       encodedLabels = onehotencode(labels,2,'ClassNames', [1, 2]); %%onehotencode(labels,2,'ClassNames',classNames);
       data{i,1} = permute(encodedLabels,[1,3,2]);
    end
end