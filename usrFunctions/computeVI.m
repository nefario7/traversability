function VIs = computeVI(b, g, r, re, nir)

ndvi = (nir - r) ./ (nir  + r);
gndvi = (nir - g) ./ (nir + g);
msavi = (2*nir + 1 - sqrt(2*nir +1) - 8*(nir - r))/2;
osavi = (1.16*(nir - r))./(nir + r + 0.16);
evi = 2.5*(nir - r)./(nir + 6*r - 7.5*b +1);
cari = (re - r) - 0.2*(re - g);
mcari = (re.*((re-r) - 0.2*(re-g)))./r;
rendvi = (nir - re)./(nir + re);
remsr = ((nir./re) - 1)./sqrt((nir./re) + 1);

VIs = [ndvi, gndvi, msavi, osavi, evi, cari, mcari, rendvi, remsr];
end