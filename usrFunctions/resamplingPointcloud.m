function [pcX, pcY, pcZ, pcBlue, pcGreen, pcRed, pcRedEd, pcNir, nNodes] = resamplingPointcloud(pcX, pcY, pcZ, pcBlue, pcGreen, pcRed, pcRedEd, pcNir, idx)

pcX = pcX(idx);
pcY = pcY(idx);
pcZ = pcZ(idx);
pcBlue = pcBlue(idx);
pcRed = pcRed(idx); 
pcGreen = pcGreen(idx);
pcRedEd = pcRedEd(idx);
pcNir = pcNir(idx);

nNodes = length(pcX); %number of 

end