function curvatureFeat = getLidarCurvatureFeatures(ptCloud, E)

pcX = ptCloud(:,1);
pcY = ptCloud(:,2);
pcZ = ptCloud(:,3);
nNodes = length(pcX);

[~, E_slope] = getSlopeFeatures(pcX, pcY, pcZ, ...
    E, nNodes);

W = sparse(E(:,1), E(:,2), abs(E_slope), nNodes, nNodes);
G = gsp_graph(W);
G.coords = [pcX, pcY, pcZ];
% Define wavelet parameters
Nf = 6;
G = gsp_estimate_lmax(G);
Wk = gsp_design_mexican_hat(G, Nf);
% %         figure;
% %         gsp_plot_filter(G,Wk);

% Create filter based on the map coordinates
s_map = G.coords;
s_map_out = gsp_filter_analysis(G, Wk, s_map);
s_map_out = gsp_vec2mat(s_map_out, Nf);

% Curvature
% Obtain L1 or L2 norm of the filtered signal
dd = s_map_out(:,:,1).^2 + s_map_out(:,:,2).^2 + s_map_out(:,:,3).^2;
dd = sqrt(dd);

curvatureFeat = dd(:,2:end);

end