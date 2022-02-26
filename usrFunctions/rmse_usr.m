function rmse = rmse_usr(y, yhat)

rmse = sqrt(mean((y - yhat).^2));

end