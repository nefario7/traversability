function r2 = rsquared_usr(y, yhat)

ybar = mean(y(:));
r2 =  1 - (sum((y - yhat).^2))/(sum((y - ybar).^2));

end