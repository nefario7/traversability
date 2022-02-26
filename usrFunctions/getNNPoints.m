function pts_out = getNNPoints(ptCloud, pt, action)

if contains(action, 'right')
    tmpCloud = ptCloud(ptCloud(:,1)> pt(1,1),:);
    pts_out = getPoint(tmpCloud, pt);
  
elseif contains(action, 'left')
    tmpCloud = ptCloud(ptCloud(:,1)< pt(1,1),:);
    pts_out = getPoint(tmpCloud, pt);
elseif contains(action, 'front')
    tmpCloud = ptCloud(ptCloud(:,2)> pt(1,2),:);
    pts_out = getPoint(tmpCloud, pt);
elseif contains(action, 'back')
    tmpCloud = ptCloud(ptCloud(:,2)< pt(1,2),:);
    pts_out = getPoint(tmpCloud, pt);
elseif contains(action, 'all')
    tmpPt_1 = getNNPoints(ptCloud, pt, 'right');
    tmpPt_2 = getNNPoints(ptCloud, pt, 'left');
    tmpPt_3 = getNNPoints(ptCloud, pt, 'front');
    tmpPt_4 = getNNPoints(ptCloud, pt, 'back');
    pts_out = [tmpPt_1; tmpPt_2; tmpPt_3; tmpPt_4];
end
end

function pts_out = getPoint(ptCloud, pt)
if ~isempty(ptCloud)
    idx = knnsearch(ptCloud, pt);
    pts_out = ptCloud(idx, :);
else
    pts_out = pt;
end
end