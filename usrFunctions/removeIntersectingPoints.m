function newSegmentLabels = removeIntersectingPoints(ptCloud, segmentLabels)

newSegmentLabels = segmentLabels;

[labels, ~, ic] = unique(segmentLabels, 'stable');

if max(labels) >= 2
    
    [D, d, xy_center, xy_maxHeight] = getSegmentDiameters(ptCloud, segmentLabels);
    
    [idx_nn, ~]  = knnsearch(xy_maxHeight, xy_maxHeight, 'K', 2);
    idx_nn = idx_nn(:,2);
    
    for k = 1:max(segmentLabels)
        idx_tmpSegment = segmentLabels == k;
        idx_nnSegment = segmentLabels == idx_nn(k);
        
        tmpCloud = ptCloud(idx_tmpSegment, :);
        nnCloud = ptCloud(idx_nnSegment, :);
        
        R_tmp = D(k)/2;
        R_nn = D(idx_nn(k))/2;
        
        r_tmp = d(k)/2;
        r_nn = d(idx_nn(k))/2;
        
        center_tmp = xy_maxHeight(k);
        center_nn = xy_maxHeight(idx_nn(k));
        
        
        if norm(center_tmp - center_nn) >= (R_tmp + R_nn) %% no intercting points
            continue
        else %% there are intersecting points
            %add the intersecting points to the region with lowest ratio
            if R_tmp > R_nn
                cloud = [tmpCloud; nnCloud];
                tmpLabels = [ones(size(tmpCloud,1), 1); zeros(size(nnCloud,1), 1)];
                
                newLabels = addInsidePoints2segment(tmpLabels, cloud, 'xy_mean');
                newLabels = newLabels(size(tmpCloud,1) +1:end,:);
                
                tmp = newSegmentLabels(idx_nnSegment);
                tmp(logical(newLabels)) = k;
                newSegmentLabels(idx_nnSegment) = tmp;
                
            elseif R_nn > R_tmp
                cloud = [nnCloud; tmpCloud];
                tmpLabels = [ones(size(nnCloud,1), 1); zeros(size(tmpCloud,1),1)];
                newLabels = addInsidePoints2segment(tmpLabels, cloud, 'xy_mean');
                newLabels = newLabels(size(nnCloud,1) +1:end,:);
                
                tmp = newSegmentLabels(idx_tmpSegment);
                tmp(logical(newLabels)) = idx_nn(k);
                newSegmentLabels(idx_tmpSegment) = tmp;
            elseif R_nn == R_tmp
                if r_tmp > r_nn
                    cloud = [tmpCloud; nnCloud];
                    tmpLabels = [ones(size(tmpCloud,1), 1); zeros(size(nnCloud,1), 1)];
                    newLabels = addInsidePoints2segment(tmpLabels, cloud, 'xy_mean');
                    newLabels = newLabels(size(tmpCloud,1) +1:end,:);
                    
                    tmp = newSegmentLabels(idx_nnSegment);
                    tmp(logical(newLabels)) = k;
                    newSegmentLabels(idx_nnSegment) = tmp;
                    
                elseif r_nn > r_tmp
                    cloud = [nnCloud; tmpCloud];
                    tmpLabels = [ones(size(nnCloud,1), 1); zeros(size(tmpCloud,1), 1)];
                    newLabels = addInsidePoints2segment(tmpLabels, cloud, 'xy_mean');
                    newLabels = newLabels(size(nnCloud,1) +1:end,:);
                    
                    tmp = newSegmentLabels(idx_tmpSegment);
                    tmp(logical(newLabels)) = idx_nn(k);
                    newSegmentLabels(idx_tmpSegment) = tmp;
                end
            end
        end
    end
    
    idx_zero = newSegmentLabels == 0;
    tmpSegments = newSegmentLabels(~idx_zero);
    [~, ~, ic] = unique(tmpSegments, 'stable');
    newSegmentLabels(~idx_zero) = ic;
    
end
end