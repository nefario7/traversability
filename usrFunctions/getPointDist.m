function dist_vct = getPointDist(pcRaw, pcEdges)

nNodes = length(pcRaw);
nEdges = length(pcEdges);

pcX = pcRaw(:,1);
pcY = pcRaw(:,2);
pcZ = pcRaw(:,3);

% compute point distances
if mod(nEdges, nNodes) == 0
    cols = nEdges/nNodes;
    pcIdx1 = reshape(pcEdges(:,1), [nNodes, cols]);
    pcIdx2 = reshape(pcEdges(:,2), [nNodes, cols]);
    
    dist_vct = computeDist(pcRaw, pcIdx1, pcIdx2, cols);

 
else
    nIdx = rem(nEdges, nNodes);
    pcIdx1 = pcEdges(1:nIdx, 1);
    pcIdx2 = pcEdges(1:nIdx, 2);
    slope_vct0 = computeDist(pcRaw, pcIdx1, pcIdx2, 1);
    
    cols = (nEdges-nIdx)/nNodes;
    pcIdx1 = reshape(pcEdges(nIdx+1:end,1), [nNodes, cols]);
    pcIdx2 = reshape(pcEdges(nIdx+1:end,2), [nNodes, cols]);
    
    slope_vct1 = computeDist(pcRaw, pcIdx1, pcIdx2, cols);
    
    dist_vct = [slope_vct0; slope_vct1];
        
end

    function dist_vct = computeDist(pcRaw, idx1, idx2, cols)
        dist_vct = [];
        for k = 1:cols
            dist = sqrt((pcRaw(idx1(:,k),1) - pcRaw(idx2(:,k),1)).^2 + ...
                (pcRaw(idx1(:,k),2) - pcRaw(idx2(:,k),2)).^2 + ... 
                (pcRaw(idx1(:,k),3) - pcRaw(idx2(:,k),3)).^2);
            dist_vct = [dist_vct; dist];
            dist = 0;
        end
    end
end