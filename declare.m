% Michael Sikora
% 2018.05.21
% Script to generate and store default variables for srp gui simulator

% Which Computer is this program running on?
COMPUTER = 0; % default
desktopVers = '2015b';
laptopVers = '2017b';
v = [version('-release')];
if strcmp(v,desktopVers)
    COMPUTER = 0; % Desktop
elseif strcmp(v,laptopVers)
    COMPUTER = 1; % Laptop
end
clear('v','laptopVers','desktopVers');

%%%% INCLUDES
if COMPUTER == 0
    addpath('C:\Users\donohue\Desktop\Sikora\ArrayToolbox\ArrayToolbox/'); % location of Audio Array Toolbox
elseif COMPUTER == 1
    addpath('M:/toolboxes/AudioArrayToolbox/'); % location of Audio Array Toolbox
end
toolspath = './tools';
includes = {'/class_Platform',...
            '/quaternions'};
save('include.mat','toolspath','includes');

%%%% INCLUDES
% Prefix to include utility functions
includeDirectories = load('include.mat','toolspath','includes');
if isfield(includeDirectories, 'toolspath') == 0
    toolspath = ''; % same directory if undefined
else
    toolspath = includeDirectories.toolspath;
end
for ii = 1:length(includeDirectories.includes) % for all include files, add to path
    addpath([ toolspath, includeDirectories.includes{ii}]);
end
%%%%

%%%% DEFAULT VARIABLES
vars.independent = 'None';
vars.sigpos = [0 0 1.5]';
vars.setup = 'EQUIDISTANT';
popupmenulist = find(strcmp(objs.varbox.type,'popupmenu'));
for nn = popupmenulist
    vars.label{nn} = objs.varbox.label{nn};
    vars.value{nn} = replace(objs.varbox.string{nn}{1},...
        objs.varbox.units{nn},'');
end

%%%% CONSTANTS
%  Target signal parameters for chirp signal
vars.f12p = 7000;  %  Corresponding upper frequency limit
vars.f11p = 100;  %  Lower frequency limit

vars.fs= 16000;  %  Sample frequency in Hz
vars.sigtot = 1;   %  Number of targets in FOV
vars.numnos = 2;   %  Number of coherent targets on wall perimeter
              %  generate target bandwidths
vars.cnsnr = -2;  %  coherent noise sources SNR to be added relative to strongest target peaks
vars.batar = .6; %  Beta values for PHAT processing

%  White noise snr
vars.wgnsnr = -30;
vars.sclnos = 10^(vars.wgnsnr/20);

%  Frequency dependent Attenuation
vars.temp = 28; % Temperature centigrade
vars.press = 29.92; % pressure inHg
vars.hum = 80;  % humidity in percent
vars.dis = 1;  %  Distance in meters (normalized to 1 meter)
vars.prop.freq = vars.fs/2*[0:200]/200;  %  Create 100 point frequency axis
vars.prop.atten =  atmAtten(vars.temp, vars.press, vars.hum, vars.dis, vars.prop.freq);  %  Attenuation vector
vars.prop.c = SpeedOfSound(vars.temp,vars.hum,vars.press);

%  Generate room geometry
%  Opposite corner points for room, also walls are locations for noise source placement
vars.froom = [-3.5 -4 0; 3.5 4 3.5]';  % [x1, y1, z1; x2 y2 z2]'
% Opposite Corner Points of Perimeter for mic placement
vars.fmics = [-3.25 -3.75 0; 3.25 3.75 2]';
%  Room reflection coefficients (walls, floor, ceiling)
vars.bs = [.5 .5 .5 .5 .5 .5];
%  Field of view for reconstructing SRP image (opposite corner points)
vars.fov = [-2.5 -2.5 1.5; 2.5 2.5 1.5]';

%  Time window for frequency domain block processing
vars.trez = 20e-3;  %  In seconds
%  Room Resolution: Step through cartesion grid for mic and sound source
%  plane
vars.rez = .04;  %  In meters

%  All vertcies in image plane
vars.v = [vars.fmics(1:2,1),[vars.fmics(1,1); vars.fmics(2,2)],...
    vars.fmics(1:2,2),[vars.fmics(1,2); vars.fmics(2,1)]];  
vars.v = [vars.v; ones(1,4)*1.5];
vars.vn = [vars.froom(1:2,1), [vars.froom(1,1); vars.froom(2,2)],...
    vars.froom(1:2,2), [vars.froom(1,2); vars.froom(2,1)]];  
vars.vn = [vars.vn; ones(1,4)*1.5];
%  Compute window length in samples for segmenting time signal 
vars.winlen = ceil(vars.fs*vars.trez);
vars.wininc = round(vars.fs*vars.trez/2);  %  Compute increment in sample for sliding time window along
%  Compute grid axis for pixel of the SRP image
vars.gridax = {[vars.fov(1,1):vars.rez:vars.fov(1,2)],...
    [vars.fov(2,1):vars.rez:vars.fov(2,2)],...
    [vars.fov(3,1):vars.rez:vars.fov(3,2)]}; 
%%%%%%%%%%%%%%

% number of windows to take and average image results
vars.N_win = 2;
vars.computer = COMPUTER;
