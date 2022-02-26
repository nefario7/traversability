function [fdGround_threshold, fdNonGround_threshold] = getFD_threshold(graphStructure, fdInfo_cell, a, action)

fdInfo_vct = cell2mat(fdInfo_cell');
fdInfo_vct(isnan(fdInfo_vct(:,1)),:) = [];
fdInfo_ground = sortrows(fdInfo_vct, 3); %% sort according ground points
fdInfo_nonGround = sortrows(fdInfo_vct, 4); %% sort according ground points


idx_ground = fdInfo_ground(:,3) >  10*fdInfo_ground(:,4);
idx_nonGround = fdInfo_nonGround(:,4) >  10*fdInfo_nonGround(:,3);

disp([graphStructure ' Ground segments: ' num2str(sum(idx_ground))])
disp([graphStructure ' Non-ground segments: ' num2str(sum(idx_nonGround))])

fd_ground = fdInfo_ground(idx_ground, 1);
fd_nonGround = fdInfo_nonGround(idx_nonGround, 1);


fdGround_mean = mean(fd_ground);
fdNonGround_mean = mean(fd_nonGround);
fdGround_std = std(fd_ground);
fdNonGround_std = std(fd_nonGround);
disp([graphStructure ' FD ground; mean: ' num2str(fdGround_mean) '; std: ' num2str(fdGround_std)])
disp([graphStructure ' FD non-ground; mean: ' num2str(fdNonGround_mean) '; std: ' num2str(fdNonGround_std)])

if contains(action, 'plot')
    figure
    subplot(1,2,1)
    plot(fdInfo_nonGround(idx_nonGround,4), fd_nonGround, 'mo');
    xlabel('Non-Ground points');
    ylabel('fractal dimension');
    hold on
    plot(fdInfo_ground(idx_ground,3), fd_ground, 'c*');
    xlabel('Ground points');
    ylabel('fractal dimension');
    
    
    subplot(1,2,2)
    c = categorical({'Ground Points','Non-Ground Points'});
    fd_means = [fdGround_mean, fdNonGround_mean];
    fd_stds = [fdGround_std, fdNonGround_std];
    bar(c, fd_means)
    hold on
    er = errorbar(c,fd_means,fd_stds,-fd_stds);
    er.Color = [0 0 0];
    er.LineStyle = 'none';
    
    pause
end

fdGround_threshold = fdGround_mean + a*fdGround_std;
fdNonGround_threshold = fdNonGround_mean + a*fdNonGround_std;
disp([graphStructure ' FD ground; threshold: ' num2str(fdGround_threshold)])
disp([graphStructure ' FD non-ground; threshold: ' num2str(fdNonGround_threshold)])
end