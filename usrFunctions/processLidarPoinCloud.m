function pcRaw_final = processLidarPoinCloud(pcRaw)

% pcX = pcRaw(:,1);
% pcY = pcRaw(:,2);
% pcZ = pcRaw(:,3);
% pcLabels = pcRaw(:,4);

% delete repeated points
[~, pcIdx, ~] = unique(pcRaw(:,1:2),'stable', 'rows');

% pcX = pcX(pcIdx);
% pcY = pcY(pcIdx);
% pcZ = pcZ(pcIdx);
% pcLabels = pcLabels(pcIdx);

pcRaw_final = pcRaw(pcIdx, :);

% pcshow([pcX, pcY, pcZ], pcLabels)
% title('Repeated points')

%outlier removal
[~,inlierIdx,~] = pcdenoise(pointCloud(pcRaw_final(:,1:3)), 'NumNeighbors', 10, 'Threshold',0.6);

% pcX = pcX(inlierIdx);
% pcY = pcY(inlierIdx);
% pcZ = pcZ(inlierIdx);
% pcLabels = pcLabels(inlierIdx);

% pcRaw_final = [pcX, pcY, pcZ, pcLabels];
pcRaw_final = pcRaw_final(inlierIdx,:);

% pcshow([pcX, pcY, pcZ], pcLabels)
% title('Outlier removal')