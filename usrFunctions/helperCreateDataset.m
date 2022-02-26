function [pClouds, orgMap, gTruth] = helperCreateDataset(datafile, wayPointsfile)
% The function loads aerial data and ground truth waypoints from data file
% and create lidar scans at each waypoint.
    dataFolder = fullfile(tempdir, 'aerialMapData', filesep);
    aerialFile = dataFolder + "aerialMap.laz";
    
    % Check whether the folder and data file already exist or not
    folderExists = exist(dataFolder, 'dir');
    fileExists = exist(aerialFile, 'file');
    % Create a new folder if it is not exist
    if ~folderExists
        mkdir(dataFolder);
    end
    
    % Extract aerial data file if it is not exist
    if ~fileExists
        untar(datafile, dataFolder);
    end
  
    % The data is collected at an altitude of 700m
    altitude = 700;
    
    % Load laz file
    lazReader = lasFileReader(aerialFile);
    lazPtCloud = readPointCloud(lazReader);
    
    % Transform the point cloud such that it will be centered around
    % origin. This helps to create fasteroccupancy map and easycomputation
    xshift = sum(lazPtCloud.XLimits)/2;
    yshift = sum(lazPtCloud.YLimits)/2;
    tform = rigid3d(eye(3),[-xshift -yshift 0]);
    tformPt = pctransform(lazPtCloud, tform);

    % Create occupancy map for the data
    pose = [ 0 0 0 1 0 0 0];
    map3D = occupancyMap3D(1);
    insertPointCloud(map3D,pose,tformPt.Location,300);

    % Load Ground truth trajectory and adjust it w.r.t transformed data
    traj = load(wayPointsfile);
    gTruth = [traj.gTruthTraj(:,1)-xshift traj.gTruthTraj(:,2)-yshift repmat(altitude,height(traj.gTruthTraj),1)];
    
    % Create directional angles with horizontal FOV of -13 to 13 and
    % vertical FOV of -2.5 to 2.5
    [xx,yy]=meshgrid(-13:0.08:13, -2.5:0.2:2.5);
    dirAngles = [xx(:) yy(:) repmat(90,numel(xx),1)];

    % Extract lidar scans at each waypoint using rayIntesection
    mapPoints = [];
    pClouds = pointCloud.empty();
    for i = 1:height(gTruth)
        % calculate pose at each waypoint.
        if i == 1
            posex = -(0.5*pi);
        else
            posex = atan((gTruth(i,2)-gTruth(i-1,2))/(gTruth(i,1)-gTruth(i-1,1)));
        end
        rot = eul2quat([posex+0.5*pi 0 pi]);
        
        % Apply rayIntesection at each waypoint to extract lidar scans
        [pts, isOccupied] = rayIntersection(map3D, [gTruth(i,:) rot], dirAngles, 800);
        pts = cast(pts, 'like', tformPt.Location);
        ptsvalid = pts(isOccupied==1,:);
        orgPts = ptsvalid(ptsvalid(:,1)~=0 | ptsvalid(:,2)~=0 | ptsvalid(:,3)~=0,:);
        
        % Store original map for comparision
        mapPoints = [mapPoints;orgPts];
        
        % Transform lidar scan such that the waypoint will be the origin
        % for it
        tempPt = pointCloud(orgPts);
        tform = rigid3d(eye(3),[-gTruth(i,1) -gTruth(i,2) -altitude]);
        pClouds(i) = pctransform(tempPt, tform);
    end
    
    orgMap = pointCloud(mapPoints);
end