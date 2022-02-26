function [pointFeatures, slopes] = getLidarSlopeFeatures(ptCloud, pcEdges, nNodes)

pcX = ptCloud(:,1);
pcY = ptCloud(:,2);
pcZ = ptCloud(:,3);

% set all edges of nodes
pcEdges_tmp = fliplr(pcEdges);
[pcEdges_vct, idxSort] =  sortrows([pcEdges; pcEdges_tmp]);

%%
% compute slope of all edges
slopes = getPointsSlopes(pcX, pcY, pcZ, nNodes, pcEdges);
slopes_tmp = [slopes; -slopes];
slope_vct = slopes_tmp(idxSort);

% % slope_vct_1 = getPointsSlopes(pcX, pcY, pcZ, nNodes, pcEdges_vct);
atan_vct = atan(slope_vct);

% compute the arcTan for each node neighbors
[~, ~, U] = unique(pcEdges_vct(:,1));

atan_cell = accumarray(U, 1:size(pcEdges_vct,1),[],@(r){atan_vct(r,:)});

% atan_cell = accumarray(U, 1:size(pcEdges_vct,1),[],@(r){...
%     atan((pcZ(pcEdges_vct(r,1)) - pcZ(pcEdges_vct(r,2)))./ ...
%     sqrt((pcX(pcEdges_vct(r,1)) - pcX(pcEdges_vct(r,2))).^2 + ...
%     (pcY(pcEdges_vct(r,1)) - pcY(pcEdges_vct(r,2))).^2))});

% compute point--based features
atan_avr = cellfun(@mean, atan_cell);
atan_max = cellfun(@max, atan_cell);
atan_min = cellfun(@min, atan_cell);
atan_std = cellfun(@std, atan_cell);

pointFeatures = [atan_avr, atan_max, atan_min, atan_std];

end
