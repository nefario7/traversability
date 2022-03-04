function [gridMap] = traversability_index_fuzzy(slopeScore, roughnessScore, elevModel_labels)

% minr = min(roughnessScore, [], 'all', 'omitnan');
% maxr = max(roughnessScore, [], 'all', 'omitnan');
%
% mins = min(slopeScore, [], 'all', 'omitnan');
% maxs = max(slopeScore, [], 'all', 'omitnan');

%% Normalization and dealing with NaN
roughnessScore = normalize(roughnessScore, 'range');
slopeScore = normalize(slopeScore, 'range');
roughnessScore(isnan(roughnessScore)) = -1;
slopeScore(isnan(slopeScore)) = -1;

%% Membership Functions
rmf = [
    fismf("trapmf", [0 0 0.15 0.3], "Name", "smooth");
    fismf("trapmf", [0.2 0.4 0.6 0.8],"Name", "rough");
    fismf("trapmf", [0.75 0.85 1 1], "Name", "rocky")];

smf = [
    fismf("trapmf", [0 0 0.15 0.25], "Name", "flat"),
    fismf("trapmf", [0.2 0.4 0.6 0.8],"Name", "sloped"),
    fismf("trapmf", [0.75 0.85 1 1], "Name", "steep")];

%% Evaluating MFs
[rows, cols] = size(roughnessScore);
roughIndex = zeros(3, rows, cols);
slopeIndex = zeros(3, rows, cols);

for i=progress(1:rows)
    for j=1:cols
        roughIndex(:, i, j) = evalmf(rmf, roughnessScore(i, j));
        slopeIndex(:, i, j) = evalmf(smf, slopeScore(i, j));
    end
end

[rows, cols] = size(roughnessScore);
gridMap = occupancyMap(rows, cols, 0.3,'grid');
for i=progress(1:rows)
    for j=1:cols
        param_1 = slopeIndex(:, i, j);
        %         display(param_1);
        param_2 = roughIndex(:, i, j);
        %         display(param_2);
        param_3 = elevModel_labels(i, j);
        if param_3 == 1
            setOccupancy(gridMap, grid2local(gridMap,[i, j]), 1);
        else
            if param_1(1) && param_2(1)
                setOccupancy(gridMap, grid2local(gridMap,[i, j]), 0.9);
            elseif param_1(1) && param_2(2)
                setOccupancy(gridMap, grid2local(gridMap,[i, j]), 0.5);
            elseif param_1(2) && param_2(1)
                setOccupancy(gridMap, grid2local(gridMap,[i, j]), 0.5);
            else
                setOccupancy(gridMap, grid2local(gridMap,[i, j]), 0.1);
            end
        end
    end
end
end



