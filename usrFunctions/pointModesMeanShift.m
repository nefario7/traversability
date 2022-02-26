function Xa = pointModesMeanShift(Xa, ptCloud, action)
m_old = zeros(1,3);
m_diff = inf;

% Xa_0 = Xa;
while m_diff > 0.1
    
    if contains(action, 'mtx')
        m_vct = meanShiftVector(Xa, ptCloud, 'mtx');
        
    elseif contains(action, 'vct')
        m_vct = arrayfun(@(xa_1, xa_2, xa_3) meanShiftVector([xa_1, xa_2, xa_3], ptCloud, 'vct'), ...
            Xa(:,1), Xa(:,2), Xa(:,3), 'UniformOutput', false);
        m_vct = cell2mat(m_vct);
    end
    Xa = Xa + m_vct;
    
    m_curr = max(m_vct);
    m_diff = norm(m_curr - m_old);
    m_old = m_curr;
   
%     disp(m_diff)
end

% if contains(action, 'segment')
%     treeLabels = segmentByPtDensity(Xa, action);
% end

% if contains(action, 'plot')
%     segmentMeanPt = [];
%     for k = 1:max(treeLabels)
%         idx = treeLabels == k;
%         segmentMeanPt = [segmentMeanPt; mean(Xa(idx,:),1)];
%     end
%     
%     RGB = label2rgb(treeLabels, 'prism', 'c');
%     subplot(1,2,1)
%     pcshow(Xa, 'MarkerSize', 30)
%     title('Modes Cloud')
%     hold on
%     pcshow(segmentMeanPt, 'g*', 'MarkerSize', 60)
%     subplot(1,2,2)
%     pcshow(Xa_0, [RGB(:,1,1), RGB(:,1,2), RGB(:,1,3)], 'MarkerSize', 30)
%     title('Segmented Cloud')
%     pause
% end


% treeLabels = findNearestNeighbors(pointCloud(Xa), Xa);
% treeLabels = pcsegdist(pointCloud(Xa),3);

%
% subplot(1,2,1)
% pcshow(canopyCloud, 'MarkerSize', 5)
% colormap(hot)
% subplot(1,2,2)
% if contains(action, 'plot')
%     pcshow(Xa, treeLabels, 'MarkerSize', 10)
%     colormap(prism)
% end


end