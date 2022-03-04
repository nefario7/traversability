function [gridMap] = traversability_index(slopeScore, roughnessScore, elevModel_labels)
[rows, cols] = size(slopeScore);
gridMap = occupancyMap(rows,cols,0.3,'grid');
for k=progress(1:cols)
    for j=1:rows
        s1 = slopeScore(j, k);
        s2 = roughnessScore(j, k);
        s3 = elevModel_labels(j, k);
        if (s1 == 1) || (s2 == 1) || (s3 == 1)
            setOccupancy(gridMap,grid2local(gridMap,[j,k]), 1);
        else
            if isnan(s1)
                setOccupancy(gridMap,grid2local(gridMap,[j,k]), 0.5);
            else
                setOccupancy(gridMap,grid2local(gridMap,[j,k]), s1);
            end
        end
    end
end
end