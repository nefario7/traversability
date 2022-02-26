function E = traverseAdd(P, E, v1, v2)
    u = naiveDownhillSearch(P, E, P(v2,:), v1);
    
    if u ~= v2
        E = addEdge(E, u, v2, P);  %% keep edges sorted
        E_pu = E(E(:,1) == u, :);
        for k = 1:size(E_pu,1)
            if isOccluding(P(E_pu(k,1),:), P(v2,:), P(E_pu(k,2),:))
                idx = arrayfun(@(e1, e2) isequal([e1, e2], E_pu(k,:)), E(:,1), E(:,2));
                E(idx,:) = [];
                %%E(E==E_pu(k,:)) = []; %remove edge E_k from E
                v = E_pu(k,2);
                E = traverseAdd(P, E, u, v);
            end
        end
        
         E = traverseAdd(P, E, v2, u);
    end
    
end

function E = addEdge(e, u, v2, P)
    if isempty(e)
        E = [u, v2];
    else
        e_tmp = [e; [u, v2]];
        L = arrayfun(@(e1, e2)(norm(P(e1,:) - P(e2,:), 2)), e_tmp(:,1), e_tmp(:,2));
        [~, idx] = sort(L);
        E = [e_tmp(idx,1), e_tmp(idx,2)];
    end

end

function occluded = isOccluding(P1, P2, P3)
    tau = 0.0001;

    occluded = false;
    if (norm(P1 - P2, 2) < norm(P1 - P3, 2)) && (norm(P2 - P3, 2)^2 < norm(P1 - P3, 2)^2 - 2*tau*norm(P1 - P2, 2))
        occluded = true;
    end

end


    