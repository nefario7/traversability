%% print odometry path

filepath = '../../Data/vlpMapping/toFrancisco/Odometry/odom-cut_good_one-';

filename = {'ALOAM.txt', 'LIOSAM.txt', 'LIOSAM_imu.txt', 'GPS.txt'};
figure
for n = 1:3%length(filename)
    odom_tmp = readmatrix([filepath, filename{n}]);
    x = odom_tmp(:,1);
    y = odom_tmp(:,2);
%     z = odom_tmp(:,3);
%     plot3(x,y,z, '.')
plot(x,y, '.')
    grid on
    hold on
end

filepath = '../../Data/vlpMapping/toFrancisco/Odometry/gps.bag';

bag = rosbag(filepath);
bSel = select(bag, 'Topic', 'odometry/gps');
msgStructs = readMessages(bSel,'DataFormat','struct');

xPoints = cellfun(@(m) double(m.Pose.Pose.Position.X),msgStructs);
yPoints = cellfun(@(m) double(m.Pose.Pose.Position.Y),msgStructs);
zPoints = cellfun(@(m) double(m.Pose.Pose.Position.Z),msgStructs);
% plot3(xPoints,yPoints, zPoints, '.')
plot(xPoints,yPoints, '.')
legend('ALOAM', 'LIOSAM+GPS', 'LIOSAM_imu', 'GPS')

%% Read data
filename = '../../Data/Portugal/MappingResults/imu_raw.txt';
imu_raw = readmatrix(filename);

filename = '../../Data/Portugal/MappingResults/imu_raw_cut.txt';
imu_raw_cut = readmatrix(filename);


filename = '../../Data/Portugal/MappingResults/gps_fix.txt';
gps_raw = readmatrix(filename);

filename = '../../Data/Portugal/MappingResults/odom_ekf.txt';
odom_vilsam0 = readmatrix(filename);

filename = '../../Data/Portugal/MappingResults/odom_navsat.txt';
gps_navsat = readmatrix(filename);

filename = '../../Data/Portugal/MappingResults/LIOSAM/odom.txt';
odom_liosam = readmatrix(filename);

filename = '../../Data/Portugal/MappingResults/LIOSAM/odom_noGPS.txt';
odom_noGPS_liosam = readmatrix(filename);

filename = '../../Data/Portugal/MappingResults/ALOAM/odom.txt';
odom_aloam = readmatrix(filename);



%%
close all
figure
plot(odom_vilsam0(:,1)-6, odom_vilsam0(:,2)-11, 'k', 'LineWidth', 2.0)
hold on;

plot(odom_noGPS_liosam(350:end,1), odom_noGPS_liosam(350:end,2), '-.', 'Color',[0 0 0]+0.5, 'LineWidth', 1.5)
plot(odom_aloam(:,1), odom_aloam(:,2), '--c', 'LineWidth', 1.5)
plot(odom_liosam(130:end,1)-6, odom_liosam(130:end,2)-11, '--m', 'LineWidth', 1.5)
plot(odom_noGPS_liosam(350:430,1), odom_noGPS_liosam(350:430,2), '--m', 'LineWidth', 1.5)
xlabel('X (m)');
ylabel('Y (m)');

hold off;


%%
close all;

figure
plot(imu_raw_cut(:,8));
figure
plot(imu_raw_cut(:,9));
figure
plot(imu_raw_cut(:,10));


%%
%% Read data Indoor
clc
clear all;

filename = '../../Data/MappingResults/Odom_gps_superOdom/2022-01-26-16-36/odom.txt';
gps_superOdom = readmatrix(filename);

% filename = '../../Data/frankensam_aloam_liosam/odom_gps_liosam1.txt';
% gps_liosam = readmatrix(filename);

filename = '../../Data/MappingResults/Odom_camera_superOdom/2022-01-26-16-36/odom.txt';
cam_superOdom = readmatrix(filename);

filename = '../../Data/MappingResults/Odom_lidar_superOdom/2022-01-26-16-36/odom.txt';
lidar_superOdom = readmatrix(filename);

filename = '../../Data/MappingResults/Odom_gps_thightly/2022-01-27-13-28/odom.txt';
cam_thightly= readmatrix(filename);

filename = '../../Data/MappingResults/Odom_gps_thightly/2022-01-27-13-28/odom.txt';
lidar_thightly = readmatrix(filename);

%%
close all
figure
plot(gps_superOdom(:,1), gps_superOdom(:,2), 'k', 'LineWidth', 3.0) %% 'Color',[0 0 0]+0.75
% plot(gps_liosam(:,1), gps_liosam(:,2), 'k', 'LineWidth', 2.0)
hold on;


plot(cam_superOdom(:,1), cam_superOdom(:,2), '-', 'Color',[1 0 0]*1.0, 'LineWidth', 1.5) %% 'Color',[0 0 0]+0.5,
plot(lidar_superOdom(:,1), lidar_superOdom(:,2), '-', 'Color',[0 0 1]*1.0, 'LineWidth', 1.5) %% 'Color', [1 1 1]*0.5,

plot(cam_thightly(:,1), cam_thightly(:,2), '-.', 'Color',[1 0 1]*1.0, 'LineWidth', 1.5) %% 'Color',[0 0 0]+0.5,
plot(lidar_thightly(:,1), lidar_thightly(:,2), '--', 'Color',[0 1 1]*1.0, 'LineWidth', 1.5) %% 'Color', [1 1 1]*0.5,
% plot(lidar(:,1), lidar(:,2), '--m', 'LineWidth', 1.5)

xlabel('X (m)');
ylabel('Y (m)');
grid on
hold off;





