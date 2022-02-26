function planeLabels = getPlaneLabels(ptCloud, maxDistance, maxAngularDistance)
%% find the points that fif a plane
% % compute edge height  difference
% weight = abs(pcZ(pcEdges(:,1)) - pcZ(pcEdges(:,2)));
% C = 1000;
% nodeLabels = (1:nNodes)';
% threshold = THRESHOLD(1, C)*ones(nNodes,1);
% 
% %nodeLabels1 = arrayfun(@(w, idx1, idx2) labeling(w, idx1, idx2, nodeLabels, threshold,C) , weight, pcIdx1, pcIdx2);
% 
% %     function out = labeling(w, idx1, idx2, nodeLabels, threshold, C)
% %         if w <= threshold(idx1)
% %             if w <= threshold(idx2)
% %                  nodeLabels(nodeLabels == idx2) = idx1;
% %                  threshold([idx1, idx2]) = w + THRESHOLD(length(find(nodeLabels == idx1)),C);
% %             end
% %         end
% %         out = idx1;
% %     end
% 
% for k = 1: length(pcEdges)
%     idx1 = pcIdx1(k);
%     idx2 = pcIdx2(k);
%     w = weight(k);
%     if w <= threshold(idx1)
%         if w <= threshold(idx2)
%              nodeLabels(nodeLabels == idx2) = idx1;
%              threshold([idx1, idx2]) = w + THRESHOLD(length(find(nodeLabels == idx1)),C);
%         end
%     end
% end
[~,inlierIndices,~] = pcfitplane(ptCloud,...
            maxDistance, [0,0,1], maxAngularDistance);
planeLabels = ones(ptCloud.Count,1);
planeLabels(inlierIndices) = 0;  % points that fit a plane
end
