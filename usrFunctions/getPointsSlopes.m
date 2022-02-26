function slope_vct = getPointsSlopes(pcX, pcY, pcZ, nNodes, pcEdges)

nEdges = length(pcEdges);
% compute edge slopes
if mod(nEdges, nNodes) == 0
    cols = nEdges/nNodes;
    pcIdx1 = reshape(pcEdges(:,1), [nNodes, cols]);
    pcIdx2 = reshape(pcEdges(:,2), [nNodes, cols]);
    
    slope_vct = computeSlope(pcX, pcY, pcZ, pcIdx1, pcIdx2, cols);
else
    nIdx = rem(nEdges, nNodes);
    pcIdx1 = pcEdges(1:nIdx, 1);
    pcIdx2 = pcEdges(1:nIdx, 2);
    slope_vct0 = computeSlope(pcX, pcY, pcZ, pcIdx1, pcIdx2, 1);
    
    cols = (nEdges-nIdx)/nNodes;
    pcIdx1 = reshape(pcEdges(nIdx+1:end,1), [nNodes, cols]);
    pcIdx2 = reshape(pcEdges(nIdx+1:end,2), [nNodes, cols]);
    
    slope_vct1 = computeSlope(pcX, pcY, pcZ, pcIdx1, pcIdx2, cols);
    
    slope_vct = [slope_vct0; slope_vct1];
        
end

    function slope_vct = computeSlope(pcX, pcY, pcZ, idx1, idx2, cols)
        slope_vct = [];
        for k = 1:cols
            slope = (pcZ(idx1(:,k)) - pcZ(idx2(:,k)))./...
                sqrt((pcX(idx1(:,k)) - pcX(idx2(:,k))).^2 + ...
                (pcY(idx1(:,k)) - pcY(idx2(:,k))).^2);
            slope_vct = [slope_vct; slope];
            slope = 0;
        end
    end
end