function b = bias_usr(y, yhat)
   b =  mean((y - yhat)./y)*100;
end