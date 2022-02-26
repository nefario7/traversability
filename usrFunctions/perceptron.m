function dlY = perceptron(dlX,parameters)
% The perceptron function processes the input dlX using a convolution, a
% instance normalization, and a ReLU operation and returns the output of the
% ReLU operation.

    % Convolution.
    W = parameters.Conv.Weights;
    B = parameters.Conv.Bias;
    dlY = dlconv(dlX,W,B);
    
    % Instance normalization.
    offset = parameters.InstanceNorm.Offset;
    scale = parameters.InstanceNorm.Scale;
    dlY = instancenorm(dlY,offset,scale);
    
    % ReLU.
    dlY = relu(dlY);
end