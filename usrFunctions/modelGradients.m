function [gradients, loss] = modelGradients(X,yTarget,params)

    % Execute the model function.
    yPred = pointNetplusModel(X,params.trainable,params.nontrainable);
    
    % Compute the loss.
    loss = focalCrossEntropy(yPred,yTarget,'TargetCategories','independent');
    
    % Compute the parameter gradients with respect to the loss. 
    gradients = dlgradient(loss, params.trainable);  
end