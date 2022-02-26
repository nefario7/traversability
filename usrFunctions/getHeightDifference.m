function edgeHeight = getHeightDifference(pcZ, pcEdges)
nNodes = length(pcZ);

nEdges = length(pcEdges);
% compute edge slopes
if mod(nEdges, nNodes) == 0
    cols = nEdges/nNodes;
    pcIdx1 = reshape(pcEdges(:,1), [nNodes, cols]);
    pcIdx2 = reshape(pcEdges(:,2), [nNodes, cols]);
    
    edgeHeight = computeHeightDifference(pcZ, pcIdx1, pcIdx2, cols);

 
else
    nIdx = rem(nEdges, nNodes);
    pcIdx1 = pcEdges(1:nIdx, 1);
    pcIdx2 = pcEdges(1:nIdx, 2);
    edgeHeight0 = computeHeightDifference(pcZ, pcIdx1, pcIdx2, 1);
    
    cols = (nEdges-nIdx)/nNodes;
    pcIdx1 = reshape(pcEdges(nIdx+1:end,1), [nNodes, cols]);
    pcIdx2 = reshape(pcEdges(nIdx+1:end,2), [nNodes, cols]);
    
    edgeHeight1 = computeHeightDifference(pcZ, pcIdx1, pcIdx2, cols);
    
    edgeHeight = [edgeHeight0; edgeHeight1];
        
end

    function edgeHeight = computeHeightDifference(pcZ, idx1, idx2, cols)
        edgeHeight = [];
        for k = 1:cols
            heightDiff = abs(pcZ(idx1(:,k)) - pcZ(idx2(:,k)));
            edgeHeight = [edgeHeight; heightDiff];
            heightDiff = 0;
        end
    end
end