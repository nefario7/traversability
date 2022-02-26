function [loopSubmapIds,loopScores] = helperEstimateLoopCandidates(subMaps, currentScan, ...
    subMapPoses, recentPose, nsbmp, subMapThresh, loopClosureSearchRadius, loopClosureThreshold)
% The function matches current scan with submaps and tries to find the
% possible matches

    loopClosureMaxAttempts = 3;   % Maximum number of submaps checked
    maxLoopClosureCandidates = 3; % Maximum number of matches to send back

    %% Initialize variables
    loopSubmapIds = []; % Variable to hold the candidate submap IDs
    loopScores = [];    % Variable to hold the score of the matched submaps

    %% Find the submaps to be considered based on distance and Submap ID
    % Compute the centers of all Submaps
    centers = subMapPoses(1:nsbmp-subMapThresh,1:3);
    distanceToCenters = vecnorm(centers - recentPose(1:3),2,2);
    idx=find(distanceToCenters < loopClosureSearchRadius);
    centerCandidates = [distanceToCenters(idx) idx];

    % If there are submaps to be considered, sort them by distance from the
    % current scan
    if ~isempty(centerCandidates)
        % Sort them based on the distance from the current scan
        centerCandidates = sortrows(centerCandidates);

        % Return only the minimum number of loop candidates to be returned
        N = min(loopClosureMaxAttempts, size(centerCandidates,1));
        nearbySubmapIDs = centerCandidates(1:N, 2)';
    else
        nearbySubmapIDs = [];
    end
    %% Match the current scan with the candidate submaps
    newLoopCandidates = zeros(0,1); % Loop candidates
    newLoopCandidateScores = zeros(0,1); % Loop candidate scores
    count = 0; % Number of loop closure matches found

    % If there are submaps to consider
    if ~isempty(nearbySubmapIDs)
        % For every candidate submap
        for k = 1:length(nearbySubmapIDs)
            submapId = nearbySubmapIDs(k);
            [~,~,rmse] = pcregistericp(currentScan, subMaps{submapId}, 'MaxIterations',50);

            % Accept submap only if it meets the score threshold
            if rmse < loopClosureThreshold
                count = count + 1;
                % Keep track of matched Submaps and their scores
                newLoopCandidates(count) = submapId;
                newLoopCandidateScores(count) = rmse;
            end

        end

        % If there are candidates to consider
        if ~isempty(newLoopCandidates)
            % Sort them by their scores in descending order
            [~,ord] = sort(newLoopCandidateScores);
            % Return the required number of submaps matched, and their scores
            loopSubmapIds = newLoopCandidates(ord(1:min(count,maxLoopClosureCandidates)));
            loopScores = newLoopCandidateScores(ord(1:min(count,maxLoopClosureCandidates)));
        end
    end
end