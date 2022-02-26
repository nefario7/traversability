function z_error = errorFit(x, y, z, x_u, y_u, xxCov, xyCov, yyCov)

model2Fit = @(x, a, b) ...
     0.5*(2*pi*sqrt(det([x(3), x(4); x(4), x(5)])))^-1*...
     exp(-0.5*(([a; b]  - [x(1); x(2)])'/[x(3), x(4); x(4), x(5)]*...
     ([a; b]  - [x(1); x(2)])));

 z_fit = arrayfun(@(X, Y) model2Fit([x_u, y_u, xxCov, xyCov, yyCov], X, Y), x, y);
 
 z_error = max((z - z_fit)./z);
end