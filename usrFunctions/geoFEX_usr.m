function [attributes] = geoFEX_usr(XYZI,nn_size, idx_usr, dist_usr, raster_size) %*** Modified by TAR
% This is our tool geoFEX for calculating low-level geometric 3D and
% 2D features.
%
% DESCRIPTION
%   For each point in the point cloud, this function derives basic
%   geometric properties of the respective local neighborhood by using
%   the respective number of nearest neighbors. More
%   details can be found in the following paper:
%
%     M. Weinmann, S. Urban, S. Hinz, B. Jutzi, and C. Mallet (2015):
%     Distinctive 2D and 3D features for automated large-scale scene
%     analysis in urban areas. Computers & Graphics, Vol. 49, pp. 47-57.
%
%
% INPUT VARIABLES
%
%   XYZI          -   matrix containing XYZI [n x 4]
%   nn_size       -   vector containing the number of neighbors for each 3D point 
%   raster_size   -   raster size in [m], e.g. 0.25m
%
%
% OUTPUT VARIABLES
%
%   attributes    -   matrix containing attributes for each point in a point cloud 
%
%                        column 01: linearity
%                        column 02: planarity
%                        column 03: scattering
%                        column 04: omnivariance
%                        column 05: anisotropy
%                        column 06: eigenentropy
%                        column 07: sum_EVs
%                        column 08: change_of_curvature
%                        column 09: normalize(Z_vals, 'center', 'median')  *****modified by TAR*****
%                        column 10: radius_kNN
%                        column 11: density
%                        column 12: verticality
%                        column 13: delta_Z_kNN
%                        column 14: std_Z_kNN
%                        column 15: radius_kNN_2D
%                        column 16: density_2D
%                        column 17: sum_EVs_2D
%                        column 18: EV_ratio
%                        column 19: frequency_acc_map
%                        column 20: delta_z
%                        column 21: std_z
%                        columns 22-24: Evs in 3D
%                        columns 25-26: EVs in 2D
%
%
% USAGE
%   [attributes] = geoFEX(XYZI,nn_size,raster_size)
%
%
% LICENSE
%
%   Copyright (C) 2015  Martin Weinmann
%
%   This program is free software; you can redistribute it and/or
%   modify it under the terms of the GNU General Public License
%   as published by the Free Software Foundation; either version 2
%   of the License, or (at your option) any later version.
% 
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%   GNU General Public License for more details.
% 
%   You should have received a copy of the GNU General Public License
%   along with this program; if not, write to the Free Software
%   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
%
%
% CONTACT
%
%   Martin Weinmann
%   Institute of Photogrammetry and Remote Sensing, Karlsruhe Institute of Technology (KIT)
%   email:   martin.weinmann@kit.edu
%

% get point IDs
point_ID_max = size(XYZI,1);

% first feature is Z value
Z_vals = XYZI(:,3);
X_vals = XYZI(:,1);
Y_vals = XYZI(:,2);

% get local neighborhoods consisting of k neighbors (the maximum k value is chosen here in order to conduct knnsearch only once)
data_pts = XYZI(:,1:3);

% k_plus_1 = max(nn_size)+1;          
idx1 = idx_usr;         % Modified by TAR
dist = dist_usr;        % Modified by TAR
%[idx1, dist] = knnsearch(data_pts,data_pts,'Distance','euclidean','NSMethod','kdtree','K',k_plus_1);

% do some initialization stuff for incredible speed improvement
normal_vector = zeros(point_ID_max,3);
EVs = zeros(point_ID_max,3);
sum_EVs = zeros(point_ID_max,1);
radius_kNN = zeros(point_ID_max,1);
density = zeros(point_ID_max,1);
delta_Z_kNN = zeros(point_ID_max,1);
std_Z_kNN = zeros(point_ID_max,1);

radius_kNN_2D = zeros(point_ID_max,1);
density_2D = zeros(point_ID_max,1);
sum_EVs_2D = zeros(point_ID_max,1);
EVs_2D = zeros(point_ID_max,2);

% loop over all 3D points
for j=1:point_ID_max
        
    % select neighboring points
    P = data_pts(idx1(j,1:nn_size(j)+1),:);
    [m,~] = size(P);

    % calculate covariance matrix C
    P = P-ones(m,1)*(sum(P,1)/m);
    C = P.'*P./(m-1);
    
    % get the eigenvalues of C (sorting is already done by Matlab routine eig)
    % ... and remove negative eigenvalues (NOTE: THESE APPEAR ONLY BECAUSE OF NUMERICAL REASONS AND ARE VERY VERY CLOSE TO 0!)
    % ... and later avoid NaNs resulting for eigenentropy if one EV is 0
    [V, D] = eig(C);
    s1 = D(1,1);
    s2 = D(2,2);
    s3 = D(3,3);
    epsilon_to_add = 1e-8;
    EVs(j,:) = [D(3,3) D(2,2) D(1,1)];
    if EVs(j,3) <= 0; EVs(j,3) = epsilon_to_add;
        if EVs(j,2) <= 0; EVs(j,2) = epsilon_to_add;
            if EVs(j,1) <= 0; EVs(j,1) = epsilon_to_add; end;
        end;
    end;
    sum_EVs(j,1) = EVs(j,1) + EVs(j,2) + EVs(j,3);
    
    % ... as well as normal vectors derived from eigenvectors (columns in V)
    if (s1 <= s2 && s1<= s3)
        normal_vector(j,:) = V(:,1)/norm(V(:,1));
    elseif (s2 <= s1 && s2 <= s3)
        normal_vector(j,:) = V(:,2)/norm(V(:,2));
    elseif (s3 <= s1 && s3 <= s2)
        normal_vector(j,:) = V(:,3)/norm(V(:,3));
    end  % if
    
    % get attributes for local neighborhoods (eigenvalues, radius, density, curvature, ...)
    radius_kNN(j,1) = dist(j,nn_size(j)+1);                    % radius of local neighborhood
    density(j,1) = (nn_size(j)+1) ./ (4/3*pi*radius_kNN(j,1).^3);   % local point density
    delta_Z_kNN(j,1) = max(Z_vals(idx1(j,1:nn_size(j)+1))) - min(Z_vals(idx1(j,1:nn_size(j)+1)));
    std_Z_kNN(j,1) = std(Z_vals(idx1(j,1:nn_size(j)+1)));
    
    % get some 2D features
    dist_X = X_vals(idx1(j,1:nn_size(j)+1),1) - repmat(X_vals(idx1(j,1)),nn_size(j)+1,1);
    dist_Y = Y_vals(idx1(j,1:nn_size(j)+1),1) - repmat(Y_vals(idx1(j,1)),nn_size(j)+1,1);
    dist_2D = sqrt(dist_X.^2 + dist_Y.^2);
    radius_kNN_2D(j,1) = max(dist_2D);
    density_2D(j,1) = (nn_size(j)+1) ./ (pi .* radius_kNN_2D(j,1).^2);
    
    % select neighboring points
    P_2D = data_pts(idx1(j,1:nn_size(j)+1),1:2);
    [m,~] = size(P_2D);
    
    % calculate covariance matrix C
    P_2D = P_2D-ones(m,1)*(sum(P_2D,1)/m);
    C = P_2D.'*P_2D./(m-1);
    
    % get the eigenvalues of C
    % ... and remove negative eigenvalues (NOTE: THESE APPEAR ONLY BECAUSE OF NUMERICAL REASONS AND ARE VERY VERY CLOSE TO 0!)
    % ... and later avoid NaNs resulting for eigenentropy if one EV is 0
    [~, D] = eig(C);
    epsilon_to_add = 1e-8;
    EVs_2D(j,:) = [D(2,2) D(1,1)];
    if EVs_2D(j,2) <= 0; EVs_2D(j,2) = epsilon_to_add;
        if EVs_2D(j,1) <= 0; EVs_2D(j,1) = epsilon_to_add; end;
    end;
    sum_EVs_2D(j,1) = EVs_2D(j,1) + EVs_2D(j,2);
    
end  % j

% normalization of eigenvalues
EVs(:,1) = EVs(:,1) ./ sum_EVs;
EVs(:,2) = EVs(:,2) ./ sum_EVs;
EVs(:,3) = EVs(:,3) ./ sum_EVs;
EVs_2D(:,1) = EVs_2D(:,1) ./ sum_EVs_2D;
EVs_2D(:,2) = EVs_2D(:,2) ./ sum_EVs_2D;

% Now, get eigenvalue-based features by vectorized calculations:
% 1.) properties of the structure tensor according to [West et al., 2004:
%     Context-driven automated target detection in 3-D data; Toshev et al.,
%     2010: Detecting and Parsing Architecture at City Scale from Range Data;
%     Mallet et al., 2011: Relevance assessment of full-waveform lidar data
%     for urban area classification] (-> redundancy!)
linearity = ( EVs(:,1) - EVs(:,2) ) ./ EVs(:,1);
planarity = ( EVs(:,2) - EVs(:,3) ) ./ EVs(:,1);
scattering = EVs(:,3) ./ EVs(:,1);
omnivariance = ( EVs(:,1) .* EVs(:,2) .* EVs(:,3) ).^(1/3);
anisotropy = ( EVs(:,1) - EVs(:,3) ) ./ EVs(:,1);
eigenentropy = -( EVs(:,1).*log(EVs(:,1)) + EVs(:,2).*log(EVs(:,2)) + EVs(:,3).*log(EVs(:,3)) );

% 2.) get surface variation, i.e. the change of curvature [Pauly et al.,
%     2003: Multi-scale feature extraction on point-sampled surfaces;
%     Rusu, 2009: Semantic 3D Object Maps for Everyday Manipulation in
%     Human Living Environments (PhD Thesis)], namely the variation of a
%     point along the surface normal (i.e. the ratio between the minimum
%     eigenvalue and the sum of all eigenvalues approximates the change
%     of curvature in a neighborhood centered around this point; note this
%     ratio is invariant under rescaling)
change_of_curvature = EVs(:,3) ./ ( EVs(:,1) + EVs(:,2) + EVs(:,3) );

% ... and derive the measure of verticality [Demantke et al, 2012: Streamed 
% Vertical Rectangle Detection in Terrestrial Laser Scans for Facade Database
% Production]
verticality = ones(point_ID_max,1) - normal_vector(:,3);

% Finally, get ratio of eigenvalues in 2D ...
EV_ratio = EVs_2D(:,2) ./ EVs_2D(:,1);

% ... and derive features from projection to discrete image raster for ground plane
X = X_vals - min(X_vals) * ones(point_ID_max,1);
Y = Y_vals - min(Y_vals) * ones(point_ID_max,1);
X_new = floor(X/raster_size) + 1;
Y_new = floor(Y/raster_size) + 1;

% get size of observed area
min_X = min(X_new);
max_X = max(X_new);
min_Y = min(Y_new);
max_Y = max(Y_new);
r_acc = max_Y - min_Y + 1;
c_acc = max_X - min_X + 1;

% accumulate
Acc = zeros(r_acc,c_acc);
for i=1:point_ID_max
    Acc(Y_new(i),X_new(i)) = Acc(Y_new(i),X_new(i)) + 1;
end  % i

% return a suitable vector representation
frequency_acc_map = zeros(point_ID_max,1);
h_max = zeros(point_ID_max,1);
h_min = zeros(point_ID_max,1);
std_z = zeros(point_ID_max,1);

% use another loop  :-(  for getting accumulation map based 2D features
for i=1:point_ID_max
    
    [r,~] = find( (X_new == X_new(i)) & (Y_new == Y_new(i)) );
    h_max(i,1) = max(Z_vals(r,1));
    h_min(i,1) = min(Z_vals(r,1));
    frequency_acc_map(i,1) = Acc(Y_new(i),X_new(i));
    std_z(i,1) = std(Z_vals(r,1));
    
end  % i

% height difference in the respective 2D bins (compare to cylindrical 3D neighborhood -> e.g. [Mallet et al., 2011])
delta_z = h_max - h_min;

% Finally, combine all 3D features to a big matrix:
attributes = [...
    linearity planarity scattering omnivariance anisotropy eigenentropy sum_EVs change_of_curvature ...   % 8 eigenvalue-based 3D features 
    normalize(Z_vals, 'center', 'median') radius_kNN density verticality delta_Z_kNN std_Z_kNN ...                                       % 6 further 3D features 
    radius_kNN_2D density_2D sum_EVs_2D EV_ratio frequency_acc_map delta_z std_z ...                      % 7 derived 2D features 
    EVs EVs_2D];                                                                                          % (3 EVs in 3D + 2EVs in 2D)
    
end  % function

