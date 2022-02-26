function m = meanShiftVector(Xa, ptCloud, action)
%     ptCloud_Xa = ptCloud(:,:);
%     gs = densityKernel(Xa, ptCloud);
% gr = heightKernel(Xa, ptCloud);
%     m = sum((ptCloud.*gs.*gr)./sum((gs.*gr))) - Xa;

ptNN = knnsearch(ptCloud, Xa, 'K', 100);
ptCloud_nn = [];

for k =1 : size(ptNN,1)
    ptCloud_nn(:,:,k) = ptCloud(ptNN(k,:),:);
end

if contains(action, 'mtx')
    Xa_mtx = reshape(Xa', [1,3,size(Xa,1)]);
    
    [gs_mtx, idx_mtx] = densityKernel_opt(Xa_mtx, ptCloud_nn);
    [gr_mtx, mask_mtx] = heightKernel_opt(Xa_mtx, ptCloud_nn);
    m = sum((ptCloud_nn.*gs_mtx.*gr_mtx)./sum((gs_mtx.*gr_mtx))) - Xa_mtx;
%  
%     [gs_mtx, idx_mtx] = densityKernel_opt3D(Xa_mtx, ptCloud_nn);
%     m = sum((ptCloud_nn.*gs_mtx)./sum((gs_mtx))) - Xa_mtx;
    
    m = (reshape(m,[3, length(m)]))';
    
elseif contains(action, 'vct')
    gs = densityKernel_3D(Xa, ptCloud);
    m = sum((ptCloud.*gs)./sum((gs))) - Xa;
end


end


%% Kernels

function [gs_mtx, idx_mtx] = densityKernel_opt3D(Xa_mtx, ptCloud)
H = 5;
xa = Xa_mtx(:,:,:);
xi = ptCloud(:,:,:);

aux1 = (xa - xi)/H;
aux_norm = vecnorm(aux1,2,2);

idx_mtx = aux_norm<=1;
gs_mtx = zeros(size(aux_norm));
gs_mtx(idx_mtx) = exp(-0.5*(aux_norm(idx_mtx)).^2);
end

function [gs_mtx, idx_mtx] = densityKernel_opt(Xa_mtx, ptCloud)
H = 3;%1.5;
xa = Xa_mtx(:,1:2,:);
xi = ptCloud(:,1:2,:);

aux1 = (xa - xi)/H;
aux_norm = vecnorm(aux1,2,2);

idx_mtx = aux_norm<=1;
gs_mtx = zeros(size(aux_norm));
gs_mtx(idx_mtx) = exp(-0.5*(aux_norm(idx_mtx)).^2);
end

function [gr_mtx, mask_mtx] = heightKernel_opt(Xa_mtx, ptCloud)
HR = 5;
xa = Xa_mtx(:,3,:);
xi = ptCloud(:,3,:);

mask_mtx = (xi >= xa - HR/4) & ( xi <= xa + HR/2);
dist_mtx = zeros(length(xi), 1, length(xa));

comp_mtx = [abs(((xa - HR/4)-xi)/(3*HR/8)),abs(((xa + HR/2) - xi)/(3*HR/8))];
% comp_mtx = comp_mtx(mask_mtx);

min_mtx = min(comp_mtx, [],2);

% min_mtx = [];
% for k = 1:length(xa)
%    min_tmp = min(comp_mtx(:,:,k), [],2);
%    min_mtx(:,:,k) = min_tmp;
% end

dist_mtx(mask_mtx) = min_mtx(mask_mtx);
gr_mtx = 1 - vecnorm(1 - dist_mtx).^2;
end







function gs = densityKernel_3D(Xa, ptCloud)
HS = 1.5;
aux1 = (Xa - ptCloud(:,1:3))/HS;

gs = arrayfun(@(aux1_1, aux1_2, aux1_3) densityComparison(norm([aux1_1, aux1_2, aux1_3])), ...
    aux1(:,1), aux1(:,2), aux1(:,3));
end


function gs = densityKernel(Xa, ptCloud)
HS = 1.5;
Xa_tmp = ones(length(ptCloud),2).*Xa(:,1:2);
aux1 = (Xa_tmp - ptCloud(:,1:2))/HS;

gs = arrayfun(@(aux1_1, aux1_2) densityComparison(norm([aux1_1, aux1_2])), ...
    aux1(:,1), aux1(:,2));
end

function gs_tmp = densityComparison(aux1_norm)
if aux1_norm <= 1
    gs_tmp = exp(-0.5*(aux1_norm^2));
else
    gs_tmp = 0;
end
end

function gr = heightKernel(Xa, ptCloud)
HR = 5;
Xa_tmp = ones(length(ptCloud),1).*Xa(:,3);
Xi = ptCloud(:,3);

gr = arrayfun(@(xa, xi) heightComparison(xa, xi, HR), Xa_tmp, Xi);
end

function gr_tmp = heightComparison(xa, xi, HR)
if (xi >= xa - HR/4) && ( xi <= xa + HR/2) %% check mask 1 ? 0
    aux1 = min([norm(((xa - HR/4)-xi)/(3*HR/8)), norm(((xa + HR/2) - xi)/(3*HR/8)) ]);
    gr_tmp = 1 - norm(1 - aux1)^2;
else
    gr_tmp = 0;
end

end
