function FD = differentialBoxCounting_ptCloud(ptCloud) %% x, y, z Matrix
%%
% % ptCloud = vlpFrame_tmp(:,2:4);
% % % ptIdx = (ptCloud(:,2) > 0);
% % % ptCloud = ptCloud(ptIdx,:);
% % pcshow(pointCloud(ptCloud));

minX = min(ptCloud(:,1));
maxX = max(ptCloud(:,1));
minY = min(ptCloud(:,2));
maxY = max(ptCloud(:,2));
minZ = min(ptCloud(:,3));
maxZ = max(ptCloud(:,3));

xRange = maxX - minX;
yRange = maxY - minY;
zRange = maxZ - minZ;

blockSteps = 30;

Sx_vct = 2.^linspace(1, log2(xRange/2), blockSteps)';
Sy_vct = 2.^linspace(1, log2(yRange/2), blockSteps)';

stdHeight = std(ptCloud(:,3));
a = 3;

Nr_vct = [];
r_vct = [];


for i = 1:blockSteps
    S = 0;
    r_ = 0;
    if xRange < yRange
        S = Sy_vct(i);
        r_ = S/(1 + 2*a*stdHeight);
    else
        S = Sx_vct(i);
        r_ = S/(1 + 2*a*stdHeight);
    end
    N = [];
    for xCoor = minX : S : maxX-S
        for yCoor = minY : S : maxY-S
            
            idxBlock_x = (ptCloud(:,1) >= xCoor)&(ptCloud(:,1) < xCoor+S);
            idxBlock_y = (ptCloud(:,2) >= yCoor)&(ptCloud(:,2) < yCoor+S);
            
            idxBlock = idxBlock_x & idxBlock_y;
            
            if sum(idxBlock) ~= 0
                meanHeight = mean(ptCloud(idxBlock,3));
                minHeight = min(ptCloud(idxBlock,3));
                
                n_r = 0;
                if(meanHeight == minHeight)
                    n_r = 1;
                else
                    n_r = ceil(abs(meanHeight - minHeight)/r_);
                end
                
                N = [N; n_r];
            end
            
            
% %             xBlock = [xCoor, xCoor+Sx];
% %             yBlock = [yCoor, yCoor+Sy];
% %             disp(['block X: ' num2str(xBlock)]);
% %             disp(['block Y: ' num2str(yBlock)]);
        end
    end
    if N ~= 0
        Nr_vct = [Nr_vct; sum(N)];
    else
        Nr_vct = [Nr_vct; 1];
    end

end

Nr_log = log(Nr_vct);
% r_log = 0;
fractal_coef = [];

if xRange > yRange
    r_logx = log(Sx_vct);
   
    fractal_coef = polyfit(r_logx, Nr_log,1);
    FD = -fractal_coef(1);
end
if yRange >= xRange
    r_logy = log(Sy_vct);
   
    fractal_coef = polyfit(r_logy, Nr_log,1);
    FD = -fractal_coef(1);
end

% FD_residuals = Nr_log - (fractal_coef(1)*r_log + fractal_coef(2));

% disp(['Fractal Dimension (larger axis): ' num2str(FD)]);
end