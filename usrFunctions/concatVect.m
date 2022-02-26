function neighbor_vct = concatVect(neighbors, max_nNeighbor)
neighbor_vct = zeros(1,max_nNeighbor);
neighbor_vct(1, 1:size(neighbors,2)) = neighbors;
end