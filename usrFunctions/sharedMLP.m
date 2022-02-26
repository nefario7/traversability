function dlY= sharedMLP(dlX,parameters)
% The shared multilayer perceptron function processes the input dlX using a
% series of perceptron operations and returns the result of the last
% perceptron.
    dlY = dlX;
    for k = 1:numel(parameters) 
        dlY = perceptron(dlY,parameters(k));
    end
end