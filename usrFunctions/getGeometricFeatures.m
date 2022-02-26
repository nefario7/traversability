function geoFeatures = getGeometricFeatures(ptCloud, E, feat_flag, ...
    structure_flag, isprs_sample, action, set)

rasterSize = 1;

switch nargin
    case 2
        feat_flag = 'pt_segSH';
        structure_flag = 'delaunay2D';
        isprs_sample = nan;
        action = 'compute';
        set = '_';
    case 3
        structure_flag = 'delaunay2D';
        isprs_sample = nan;
        action = 'compute';
        set = '_';
    case 4
        isprs_sample = nan;
        action = 'compute';
        set = '_';
    case 5
        action = 'compute';
        set = '_';
end

if strcmp(action,'load')
    load(['./Results/CRF_Forest/ieeeCorrecions/', structure_flag, 'Feat_', feat_flag, '_',...
        mat2str(isprs_sample), '_', mat2str(set) ,'.mat'])
    
    disp('Geometric features loaded ...')
    
elseif contains(action,'compute')
    
    pcX = ptCloud(:,1);
    pcY = ptCloud(:,2);
    pcZ = ptCloud(:,3);
    
        nNodes = length(ptCloud);
    geoFeatures = [];
    slopeLabels = [];
    heightLabels = [];
    
    normHeight = normalize(pcZ, 'center', 'median');
    
    if strcmp(feat_flag, 'weinFeat')
        if strcmp(structure_flag, 'optGeo')
            load('./optSize', 'optSize');
            weinFeat =  geoFEX(ptCloud, optSize, rasterSize);
            
        else
            load('./nn_size', 'nn_size');
            load('./nbIdx_vct', 'nbIdx_vct');
            load('./dist_vct', 'dist_vct');
            weinFeat = geoFEX_usr(ptCloud, nn_size, nbIdx_vct, dist_vct, rasterSize);
        end
        
        save('./weinFeat', 'weinFeat');
        geoFeatures = weinFeat;
        
    elseif contains(feat_flag, 'pt')
        [pointFeatures, ~] = getSlopeFeatures(pcX, pcY, pcZ, ...
    E, nNodes);        
        
        save('./pointFeatures', 'pointFeatures')
        geoFeatures = [pointFeatures, normHeight];
        
    elseif strcmp(feat_flag, 'wavelet')
       
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
        
        waveletFeat = dd(:,2:end);
        
        save('./waveletFeat', 'waveletFeat');
        
        geoFeatures = [waveletFeat, normHeight];
        
    elseif strcmp(feat_flag, 'fpfh')
        
        fpfhFeat = extractFPFHFeatures(pointCloud(ptCloud(:,1:3)));
        
        save('./fpfhFeat', 'fpfhFeat');
        
        geoFeatures = [fpfhFeat, normHeight];
        
    elseif strcmp(feat_flag, 'segSlop')
        [~, E_slope] = getSlopeFeatures(pcX, pcY, pcZ, E, nNodes);        
        
        slopeLabels = graphSegmentation(nNodes, E, abs(E_slope), 100);
        segSlopFeat = getSegmentFeatures(ptCloud, normHeight, ...
    slopeLabels);

        save('./segSlopFeat', 'segSlopFeat');
        
        geoFeatures = segSlopFeat; 
    
    elseif strcmp(feat_flag, 'segHeight')

        E_relHeight = getHeightDifference(pcZ, E);
        heightLabels = graphSegmentation(nNodes, E, E_relHeight, 100);
        segHeightFeat = getSegmentFeatures(ptCloud, normHeight, ...
    heightLabels);

        save('./segHeightFeat', 'segHeightFeat');

        geoFeatures = segHeightFeat;  

    elseif strcmp(feat_flag, 'weinSegSlop')
        load('./weinFeat', 'weinFeat');
        load('./segSlopFeat', 'segSlopFeat');
        
        geoFeatures = [weinFeat, segSlopFeat];
        
    elseif strcmp(feat_flag, 'weinSegHeight')
        load('./weinFeat', 'weinFeat');
        load('./segHeightFeat', 'segHeightFeat');
        
        geoFeatures = [weinFeat, segHeightFeat];

    elseif strcmp(feat_flag, 'ptSegSlope')
        load('./pointFeatures', 'pointFeatures');
        load('./segSlopFeat', 'segSlopFeat');
        
        geoFeatures = [pointFeatures, normHeight, segSlopFeat];
     
    elseif strcmp(feat_flag, 'ptSegHeight')
        load('./pointFeatures', 'pointFeatures');
        load('./segHeightFeat', 'segHeightFeat');
        
        geoFeatures = [pointFeatures, normHeight, segHeightFeat];
     
    elseif strcmp(feat_flag, 'waveletSegSlope')
        load('./waveletFeat', 'waveletFeat');
        load('./segSlopFeat', 'segSlopFeat');
        
        geoFeatures = [waveletFeat, normHeight, segSlopFeat];
     
    elseif strcmp(feat_flag, 'waveletSegHeight')
        load('./waveletFeat', 'waveletFeat');
        load('./segHeightFeat', 'segHeightFeat');
        
        geoFeatures = [waveletFeat, normHeight, segHeightFeat];
        
    elseif strcmp(feat_flag, 'fpfhSegSlope')
        load('./fpfhFeat', 'fpfhFeat');
        load('./segSlopFeat', 'segSlopFeat');
        
        geoFeatures = [fpfhFeat, normHeight, segSlopFeat];
     
    elseif strcmp(feat_flag, 'fpfhSegHeight')
        load('./fpfhFeat', 'fpfhFeat');
        load('./segHeightFeat', 'segHeightFeat');
        
        geoFeatures = [fpfhFeat, normHeight, segHeightFeat];
        
    elseif strcmp(feat_flag, 'ptWaveletSegSlope')
        load('./pointFeatures', 'pointFeatures');
        load('./waveletFeat', 'waveletFeat');
        load('./segSlopFeat', 'segSlopFeat');
        
        geoFeatures = [pointFeatures, waveletFeat, normHeight, segSlopFeat];
     
    elseif strcmp(feat_flag, 'ptWaveletSegHeigh')
        load('./pointFeatures', 'pointFeatures');
        load('./waveletFeat', 'waveletFeat');
        load('./segHeightFeat', 'segHeightFeat');
        
        geoFeatures = [pointFeatures, waveletFeat, normHeight, segHeightFeat];
        
    elseif strcmp(feat_flag, 'ptFpfhSegSlope')
        load('./pointFeatures', 'pointFeatures');
        load('./fpfhFeat', 'fpfhFeat');
        load('./segSlopFeat', 'segSlopFeat');
        
        geoFeatures = [pointFeatures, fpfhFeat, normHeight, segSlopFeat];
     
    elseif strcmp(feat_flag, 'ptFpfhSegHeight')
        load('./pointFeatures', 'pointFeatures');
        load('./fpfhFeat', 'fpfhFeat');
        load('./segHeightFeat', 'segHeightFeat');
        
        geoFeatures = [pointFeatures, fpfhFeat, normHeight, segHeightFeat];
        
     elseif strcmp(feat_flag, 'ptWaveletFpfhSegSlope')
        load('./pointFeatures', 'pointFeatures');
        load('./waveletFeat', 'waveletFeat');
        load('./fpfhFeat', 'fpfhFeat');
        load('./segSlopFeat', 'segSlopFeat');
        
        geoFeatures = [pointFeatures, waveletFeat, fpfhFeat, normHeight, segSlopFeat];
     
    elseif strcmp(feat_flag, 'ptWaveletFpfhSegHeight')
        load('./pointFeatures', 'pointFeatures');
        load('./waveletFeat', 'waveletFeat');
        load('./fpfhFeat', 'fpfhFeat');
        load('./segHeightFeat', 'segHeightFeat');
        
        geoFeatures = [pointFeatures, waveletFeat, fpfhFeat, normHeight, segHeightFeat];       
        
    elseif strcmp(feat_flag, 'pt_segS')
        [pointFeatures, E_slope] = getSlopeFeatures(pcX, pcY, pcZ, ...
    E, nNodes);        
        
        slopeLabels = graphSegmentation(nNodes, E, abs(E_slope), 100);
        segmentSlopeFeat = getSegmentFeatures(ptCloud, normHeight, ...
    slopeLabels);
        
        geoFeatures = [segmentSlopeFeat, pointFeatures, normHeight];  
        
    elseif strcmp(feat_flag, 'pt_segH')
        [pointFeatures, ~] = getSlopeFeatures(pcX, pcY, pcZ, E, nNodes);        
        
        E_relHeight = getHeightDifference(pcZ, E);
        heightLabels = graphSegmentation(nNodes, E, E_relHeight, 100);
        segmentHeightFeat = getSegmentFeatures(ptCloud, normHeight, ...
    heightLabels);

        geoFeatures = [segmentHeightFeat, pointFeatures, normHeight];  
        
    elseif strcmp(feat_flag, 'pt_segSH')
        [pointFeatures, E_slope] = getSlopeFeatures(pcX, pcY, pcZ, ...
    E, nNodes);        
        
        slopeLabels = graphSegmentation(nNodes, E, abs(E_slope), 100);
        segmentSlopeFeat = getSegmentFeatures(ptCloud, normHeight, ...
    slopeLabels);
        
        E_relHeight = getHeightDifference(pcZ, E);
        heightLabels = graphSegmentation(nNodes, E, E_relHeight, 100);
        segmentHeightFeat = getSegmentFeatures(ptCloud, normHeight, ...
    heightLabels);
        
        geoFeatures = [segmentSlopeFeat, segmentHeightFeat, pointFeatures,...
            normHeight];  
        
    end
    
    disp(['Geometric features computed: ', feat_flag])
    
    if contains(action,'save')
        save(['./Results/CRF_Forest/ieeeCorrecions/', structure_flag, 'Feat_', feat_flag, '_',...
            mat2str(isprs_sample), '_', mat2str(set) ,'.mat'], 'geoFeatures');
        disp(['Features saved: ', ...
            './Results/CRF_Forest/ieeeCorrecions/', structure_flag, 'Feat_', feat_flag, '_',...
            mat2str(isprs_sample), '_', mat2str(set) ,'.mat'])
    end

else
    disp('No action specified')
end

% % % geoFeat_data = [geoFeatures, slopeLabels, heightLabels]; Parte que me
% ayuda en caso general de celldas 
end