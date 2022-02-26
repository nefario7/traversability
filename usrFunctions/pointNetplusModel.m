function dlY = pointNetplusModel(dlX,trainable,nontrainable)

    % Set abstraction module 1
   [points1, pointFeatures1] = sampleAndGroup(dlX,[],nontrainable.nClusters1,...
                                nontrainable.nSamples1,nontrainable.radius1);
    dlY = sharedMLP(pointFeatures1,trainable.SharedMLP1.Perceptron);
    pointNetFeatures1 = max(dlY,[],2);
    
    % Set abstraction module 2
    [points2, pointFeatures2] = sampleAndGroup(points1,pointNetFeatures1,nontrainable.nClusters2,...
                                nontrainable.nSamples2,nontrainable.radius2);
    dlY = sharedMLP(pointFeatures2,trainable.SharedMLP2.Perceptron);
    pointNetFeatures2 = max(dlY,[],2);
    
    % Set abstraction module 3
    [points3, pointFeatures3] = sampleAndGroup(points2,pointNetFeatures2,nontrainable.nClusters3,...
                                nontrainable.nSamples3,nontrainable.radius3);  
    dlY = sharedMLP(pointFeatures3,trainable.SharedMLP3.Perceptron);
    pointNetFeatures3 = max(dlY,[],2);
    
    % Set abstraction module 4
   [points4, pointFeatures4] = sampleAndGroup(points3,pointNetFeatures3,nontrainable.nClusters4,...
                                nontrainable.nSamples4,nontrainable.radius4); 
    dlY = sharedMLP(pointFeatures4,trainable.SharedMLP4.Perceptron);
    pointNetFeatures4 = max(dlY,[],2);
    
    % Feature propagation module 1
    pointsFP1 = featurePropagation(points3,points4,pointNetFeatures3,pointNetFeatures4);
    pointNetFP1 = sharedMLP(pointsFP1,trainable.SharedMLP5.Perceptron);
    
    % Feature propagation module 2
    pointsFP2 = featurePropagation(points2,points3,pointNetFeatures2,pointNetFP1);
    pointNetFP2 = sharedMLP(pointsFP2,trainable.SharedMLP6.Perceptron);
   
    % Feature propagation module 3
    pointsFP3 = featurePropagation(points1,points2,pointNetFeatures1,pointNetFP2);
    pointNetFP3 = sharedMLP(pointsFP3,trainable.SharedMLP7.Perceptron);
    
    % Feature propagation module 4
    pointsFP4 = featurePropagation(dlX,points1,[],pointNetFP3);
    dlY = sharedMLP(pointsFP4,trainable.SharedMLP8.Perceptron);
   
    % Shared MLP
    dlY = sharedMLP(dlY,trainable.SharedMLP9.Perceptron);
    dlY = softmax(dlY);
    dlY = dlarray(dlY,'SSCB');
end
