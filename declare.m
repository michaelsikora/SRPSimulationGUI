% Script to generate and store declarations
addpath('M:/toolboxes/AudioArrayToolbox/'); % location of Audio Array Toolbox

% default values
show_plots = 0;
saveplot = 1;

%  Target signal parameters for chirp signal
vars.f12p = 3000;  %  Corresponding upper frequency limit
vars.f11p = 100;  %  Lower frequency limit

vars.fs= 16000;  %  Sample frequency in Hz
vars.sigtot = 1;   %  Number of targets in FOV
vars.numnos = 2;   %  Number of coherent targets on wall perimeter
              %  generate target bandwidths
vars.cnsnr = -300;  %  coherent noise sources SNR to be added relative to strongest target peaks
vars.batar = .6; %  Beta values for PHAT processing

%  White noise snr
wgnsnr = -50;
vars.sclnos = 10^(wgnsnr/20);

%  Frequency dependent Attenuation
temp = 28; % Temperature centigrade
press = 29.92; % pressure inHg
hum = 80;  % humidity in percent
dis = 1;  %  Distance in meters (normalized to 1 meter)
vars.prop.freq = vars.fs/2*[0:200]/200;  %  Create 100 point frequency axis
vars.prop.atten =  atmAtten(temp, press, hum, dis, vars.prop.freq);  %  Attenuation vector
vars.prop.c = SpeedOfSound(temp,hum,press);

%  Generate room geometry
%  Opposite corner points for room, also walls are locations for noise source placement
froom = [-3.5 -4 0; 3.5 4 3.5]';  % [x1, y1, z1; x2 y2 z2]'
% Opposite Corner Points of Perimeter for mic placement
fmics = [-3.25 -3.75 0; 3.25 3.75 2]';
%  Room reflection coefficients (walls, floor, ceiling)
vars.bs = [.5 .5 .5 .5 .5 .5];
%  Field of view for reconstructing SRP image (opposite corner points)
fov = [-2.5 -2.5 1.5; 2.5 2.5 1.5]';
vars.fov = fov;
vars.froom = froom;
vars.fmics = fmics;

%  Time window for frequency domain block processing
vars.trez = 20e-3;  %  In seconds
%  Room Resolution: Step through cartesion grid for mic and sound source
%  plane
vars.rez = .04;  %  In meters

%  All vertcies in image plane
v = [fmics(1:2,1), [fmics(1,1); fmics(2,2)], fmics(1:2,2), [fmics(1,2); fmics(2,1)]];  
vars.v = [v; ones(1,4)*1.5];
vn = [froom(1:2,1), [froom(1,1); froom(2,2)], froom(1:2,2), [froom(1,2); froom(2,1)]];  
vars.vn = [vn; ones(1,4)*1.5];
%  Compute window length in samples for segmenting time signal 
vars.winlen = ceil(vars.fs*vars.trez);
vars.wininc = round(vars.fs*vars.trez/2);  %  Compute increment in sample for sliding time window along
%  Compute grid axis for pixel of the SRP image
vars.gridax = {[fov(1,1):vars.rez:fov(1,2)], [fov(2,1):vars.rez:fov(2,2)], [fov(3,1):vars.rez:fov(3,2)]}; 
%%%%%%%%%%%%%%

N_win = 1;

toolspath = './tools';
includes = {'/class_Platform',
            '/quaternions'};
        
save('include.mat','toolspath','includes');
