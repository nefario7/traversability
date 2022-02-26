function ptDensity_vct = computePtDensity(ptCloud, action)
R = 1.5;

if contains(action, 'approximate')
    [~, d] = knnsearch(ptCloud, ptCloud, 'K', 301);
    
    nInside = sum(d(:,2:end)<=R,2);
    ptDensity_vct = nInside/(4*pi*R.^3/3);
   
elseif contains(action, 'precise')
setSize = 1000;
ptDensity_vct = [];


ptRemainder = rem(length(ptCloud),setSize);

if ptRemainder == 0
    for k = 1:setSize:length(ptCloud)-setSize
        tmpCloud = ptCloud(k:k+setSize,:);
        tmpCloud = reshape(tmpCloud', [1,3, length(tmpCloud)]);
        
        d = vecnorm(tmpCloud - ptCloud, 2, 2);
        nInside = sum(d<=R);
        ptDensity = nInside/(4*pi*R.^3/3);
        ptDensity = reshape(ptDensity, [length(ptDensity), 1]);
        
        ptDensity_vct = [ptDensity_vct; ptDensity];
    end
else
    tmpCloud = ptCloud(1:ptRemainder,:);
    tmpCloud = reshape(tmpCloud', [1,3, length(tmpCloud)]);
    
    d = vecnorm(tmpCloud - ptCloud, 2, 2);
    nInside = sum(d<=R);
    ptDensity = nInside/(4*pi*R.^3/3);
    ptDensity = reshape(ptDensity, [length(ptDensity), 1]);
    
    ptDensity_vct = [ptDensity_vct; ptDensity];
        
    for k = ptRemainder + 1:setSize:length(ptCloud)-setSize
        tmpCloud = ptCloud(k:k+setSize-1,:);
        tmpCloud = reshape(tmpCloud', [1,3, length(tmpCloud)]);
        
        d = vecnorm(tmpCloud - ptCloud, 2, 2);
        nInside = sum(d<=R);
        ptDensity = nInside/(4*pi*R.^3/3);
        ptDensity = reshape(ptDensity, [length(ptDensity), 1]);
        
        ptDensity_vct = [ptDensity_vct; ptDensity];
    end
    
end
end

end