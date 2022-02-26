function normalFeatures = getNormalFeatures(normals, pcEdges, nNodes)

% set all edges of nodes
pcEdges_tmp = fliplr(pcEdges);
pcEdges_vct =  sortrows([pcEdges; pcEdges_tmp]);

%%
nEdges = length(pcEdges_vct);
if mod(nEdges, nNodes) == 0
    cols = nEdges/nNodes;
    pcIdx1 = reshape(pcEdges_vct(:,1), [nNodes, cols]);
    pcIdx2 = reshape(pcEdges_vct(:,2), [nNodes, cols]);
    
    ang_vct = computeNormalsAngle(pcX, pcY, pcZ, pcIdx1, pcIdx2, cols);
 
else
    nIdx = rem(nEdges, nNodes);
    pcIdx1 = pcEdges_vct(1:nIdx, 1);
    pcIdx2 = pcEdges_vct(1:nIdx, 2);
    ang_vct = computeNormalsAngle(normals, pcIdx1, pcIdx2, 1);
    
    cols = (nEdges-nIdx)/nNodes;
    pcIdx1 = reshape(pcEdges_vct(nIdx+1:end,1), [nNodes, cols]);
    pcIdx2 = reshape(pcEdges_vct(nIdx+1:end,2), [nNodes, cols]);
    
    ang_vct = computeNormalsAngle(normals, pcIdx1, pcIdx2, cols);
    
    ang_vct = [ang_vct; ang_vct];
        
end

% Node neighbors
[~, ~, U] = unique(pcEdges_vct(:,1));
ang_cell = accumarray(U, 1:size(pcEdges_vct,1),[],@(r){ang_vct(r,:)});

% compute point--based features
ang_avr = cellfun(@mean, ang_cell);
ang_max = cellfun(@max, ang_cell);
ang_min = cellfun(@min, ang_cell);
ang_std = cellfun(@std, ang_cell);

normalFeatures = [ang_avr, ang_max, ang_min, ang_std];


    function ang_vct = computeNormalsAngle(normals, pcIdx1, pcIdx2, cols)
        ang_vct = [];
        for k = 1: cols
            normals_1 = normals(pcIdx1(:,k),:);
            normals_2 = normals(pcIdx2(:,k),:);

            dotProd_vct = dot(normals_1, normals_2, 2);  % each row is consider as vector;
%             mag1_vct = sqrt(sum(normals_1.^2,2));
%             mag2_vct = sqrt(sum(normals_2.^2,2));

            angle = real(acos(dotProd_vct)); %./(mag1_vct.*mag2_vct)));
            ang_vct = [ang_vct; angle];
        end 
    end
end