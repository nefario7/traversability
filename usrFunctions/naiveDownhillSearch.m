function idx_nn = naiveDownhillSearch(P, E, Q, v)
   
    if isempty(E)
        idx_nn = v;
    else
        E_Pv = E(E(:,1)== v,:);
        for k = 1:size(E_Pv,1)
            u = E_Pv(k,2);
            if norm(Q - P(u,:), 2) < norm(Q - P(v,:), 2)
               v = u; 
            end
        end
        idx_nn = v;
    end
end
