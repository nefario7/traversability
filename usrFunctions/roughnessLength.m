function [FD FD_residuals]= roughnessLength(rangeScan)
scanLength = length(rangeScan);

% wSizes_vct = floor(2.^linspace(1, log2(scanLength/2), 30))';
wSizes_vct = (4:length(rangeScan))';

roughness_vct = [];
for i = 1:length(wSizes_vct)
    wSize =  wSizes_vct(i);  
    nw = 1;
    roughness_ = 0;
    for k = 1:wSize:scanLength
        if (scanLength - k) >= wSize
            wRange = rangeScan(k:k+wSize-1,1);
        else
            wRange = rangeScan(k:end,1);
        end
        mi = length(wRange);
        if mi > 3
            % compute the residuals for the ith window
            angleAxis = (0.2:0.2:0.2*mi)';
            P = polyfit(angleAxis, wRange, 1);
            linearEstimates = P(1)*angleAxis + P(2);
            r = wRange - linearEstimates;
            %         mdl = fitlm(angleAxis, wRange);
            %         r = mdl.Residuals.Raw;
            r_mean = mean(r);
            r_squaredSum = sum((r - r_mean).^2);
            
            roughness_  = roughness_ + sqrt((1/(mi -2))*(r_squaredSum));
            
            nw = nw +1;
        end
    end
    
    roughness = roughness_/nw;
    roughness_vct = [roughness_vct; roughness];
end

%% Check Fractal dimension
x = log(wSizes_vct);
y = log(roughness_vct);
% 
% fractal_mdl = fitlm(x, y);
% plot(fractal_mdl)
% 
% hold on

fractal_coef = polyfit(x, y,1);
H = fractal_coef(1);
% plot(x, y, 'mo')
% plot(x, fractal_coef(1)*x + fractal_coef(2), 'c');

%Fractal Dimension
FD = 2 - H;
FD_residuals = y - (fractal_coef(1)*x + fractal_coef(2));
% disp(['Fractal Dimension: ' num2str(FD)]);
end