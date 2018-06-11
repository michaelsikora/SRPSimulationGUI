% Michael Sikora <m.sikora@uky.edu>
% 2018.05.15
% Summer Research with Dr. Donohue at University of Kentucky
% dynamic GUI setup of SRP image simulator

%% GUI Fig Loader for dynamic microphone array simulations
function GUI_srp()
close all;
css = genStylesheet(0);

%%%% Generate GUI figure window
mainWin = figure('position',[0 0 css.width css.height], 'name', 'SRCP Simulator', 'NumberTitle', 'off');
set(mainWin,'Color',css.rgbcolora'./255);
set(mainWin,'KeyPressFcn', @key_pressed_fcn);
movegui(gcf,'center') % recenter GUI

%%%% Right Hand Side PLOT
objs.pnl = uipanel(mainWin,'FontSize',12,...
                'BackgroundColor',css.rgbcolorb'./255,...
                'Position',[280 20 css.width-280-20 css.height-30]./css.size);
objs.axes = axes('Parent',objs.pnl);

%%%% Left Hand Side SIDE MENU
%%%% BOX for independent variable setup
objs.indvarbox.N = 3; % number of objects in box
objs.indvarbox.label = {'Starting Value','Ending Value','Samples'} ;% text for label
objs.indvarbox.type  = {'popupmenu','popupmenu','popupmenu'};% types of the objects
objs.indvarbox.string = {}; % string values for object
objs.indvarbox.select = {{{'1','2','3','4'},...
                {'2','3','4','5'},...
                {}},... %% Mics per Platform
                {{'1','2','3','4'},...
                {'2','3','4','5'},...
                {}},... %% Number of Platforms
                {{'0.5m','1m','1.5m','2m','2.5m','3m'},...
                {'1m','1.5m','2m','2.5m','3m','3.5m'},...
                {'2','4','8'}},... %% Distance to Source
                {{'0deg','45deg'},...
                {'45deg','90deg'},...
                {'2','4','8'}},... %% Platform Angle
                {{'5cm','7cm','10cm','12cm','17cm'},...
                {'7cm','10cm','12cm','17cm','20cm'},...
                {'2','4','8'}}}; %% Distance between microphones
objs.indvarbox.callback = {@noOverlapCheckStart,@noOverlapCheckStop,''};

%%%% BOX Full variables list (Stored seperately for dynamically displaying a portion)
objs.varbox.N = 9; % number of objects in box
objs.varbox.label = {'Mics per Platform','Number of Platforms',...
                     'Distance to Source(m)','Platform Angle',...
                     'Distance Between Mics','Source Type',...
                     'Source Locations','Platform Locations',...
                     'Load Variables'} ;% text for label
objs.varbox.type  = {'popupmenu','popupmenu','popupmenu',...
                'popupmenu','popupmenu','popupmenu',...
                'popupmenu','popupmenu','pushbutton'};% types of the objects
objs.varbox.string = {{'1','2','3','4','5'},...
                {'1','2','3','4','5','6'},...
                {'0.5m','1m','1.5m','2m','2.5m','3m','3.5m'},...
                {'0deg','45deg','90deg','Random'},...
                {'5cm','10cm','17cm','20cm','25cm','30cm'},...
                {'IMPULSE','MOZART','SINE','WHITE NOISE'},...
                {'Center','Choose Location','Random XY'},...
                {'Equidistant','Choose Locations','Use Stored Values','Random XY','Linear'},...
                {}}; % string values for object
objs.varbox.callback = {'','','','','','',@setLocS,'',@loadArray};
objs.varbox.units = {'','','m','deg','cm','','','',''};
objs.box{2} = objs.varbox;

which = find(strcmp(objs.varbox.type, 'popupmenu'));
%%%% BOX 1 Select independent variable
objs.box{1}.N = 1; % number of objects in box
objs.box{1}.label = {'Independent Variable'} ;% text for label
objs.box{1}.type  = {'popupmenu'};% types of the objects
objs.box{1}.string = {{'None',objs.varbox.label{which(1:length(objs.indvarbox.select))}}}; % string values for object
objs.box{1}.callback = {@indVar};

%%%% BOX 3 data output
objs.box{3}.N = 8;
objs.box{3}.label = {'DATA','','','','','','',''};
objs.box{3}.type = {'text','text','text','text','text','text','text','text'};
objs.box{3}.string = {'','','','','','','',''};
objs.box{3}.callback = {'','','','','','','',''};

%%%% BOX 4 % plot options
objs.box{4}.N = 3; % number of objects in box
objs.box{4}.label = {'Plot Type','View','Update Figure'} ;% text for label
objs.box{4}.type  = {'popupmenu','popupmenu','pushbutton'};% types of the objects
objs.box{4}.string = {{'SRP image','Platform Orientations','SNR dB'},...
                {'XY','XYZ'},...
                {}}; % string values for object
objs.box{4}.callback = {'','',@loadFig};

%%%% BOX 5 gui options
objs.box{5}.N = 4; % number of objects in box
objs.box{5}.label = {'Restart GUI','Toggle Fullscreen','Export Variables','Import Variables'} ;% text for label
objs.box{5}.type  = {'pushbutton','pushbutton','pushbutton','pushbutton'};% types of the objects
objs.box{5}.string = {{},{},{},{}}; % string values for object
objs.box{5}.callback = {@restartGUI,@Fullscreen,@saveVars,@loadVars};

%%%% BOX 6 variables loaded
objs.box{6}.N = 2; % number of objects in box
objs.box{6}.label = {'Edit Variables','Run SRP'} ;% text for label
objs.box{6}.type  = {'pushbutton','pushbutton'};% types of the objects
objs.box{6}.string = {{},{},{}}; % string values for object
objs.box{6}.callback = {@editvars,@runSRP};

%%%% BOX 7 used to setup independent variable
objs.box{7}.N = 1;

%%%% BOX 8
objs.box{8}.N = 2; % number of objects in box
objs.box{8}.label = {'Run Error Analysis','Save Plot'} ;% text for label
objs.box{8}.type  = {'pushbutton','pushbutton'};% types of the objects
objs.box{8}.string = {{},{}}; % string values for object
objs.box{8}.callback = {@errorAnalysis,@saveFig};

%%%% BOX 9 scroll through images
objs.box{9}.N = 2;
objs.box{9}.label = {'Scroll','---'};
objs.box{9}.type = {'slider','text'};
objs.box{9}.string = {{'1','100'},{}};
objs.box{9}.callback = {@expSliderMove,''};

%%%% Define Side menu box labels and tentatively use for ordering in display
objs.boxTitles = {'indselect','varlist','output','plots',...
                'guiopts','srpsim','indvar','aftersrp','scroll'};
objs.active =  css.sidemenu1;

% Draw Starting side menu
css.adj = 0;
css.boxTop = css.sideMenuTop;
currSideMenuIDs = getBoxIndexes(objs.boxTitles,objs.active);
for ss = 1:length(currSideMenuIDs)
	[css, objs] = loadBox(css,objs,currSideMenuIDs(ss));
end
objs.box{2}.itemhandle{5}.Value = 3; % sets dist b/t mics to 17cm by default.

declare % generates predefined variables
css = genStylesheet(vars.computer);

%%%% Save GUI data for callback use
myhandles = guihandles(mainWin); 
myhandles.mainfig = mainWin; % Main figure handle
myhandles.css = css; % StyleSheet Struct
myhandles.objs = objs; % Graphics Objects Struct
myhandles.vars = vars; % Variables for the simulation
guidata(mainWin,myhandles);
end



function saveFig(hObject,eventdata)
myhandles = guidata(gcbo);

[file,path,indx] = uiputfile({'*.fig';...
    '*.png'});

map = colormap;
frame = getframe(gcf);
now = frame2im(frame);
imwrite(now,map,[path, file]);

% saveas(h,sprintf('images/roomsim1_%d_%d.png',bb,aa));
% saveas(objs.axes ,[path, file]);

guidata(gcf,myhandles);
end

function dispvars(hObject,eventdata)
myhandles = guidata(gcbo);
objs = myhandles.objs;
css = myhandles.css;
vars = myhandles.vars;

disp(vars.label);
disp(vars.value);
disp(vars);

myhandles.vars = vars;
myhandles.css = css;
myhandles.objs = objs;
guidata(gcf,myhandles);
end

function setLocS(hObject,eventdata)
myhandles = guidata(gcbo);
objs = myhandles.objs;
vars = myhandles.vars;

sigtot = 1;
if  eventdata.Source.Value == 1
    vars.sigpos = [0 0 1.5]';
elseif eventdata.Source.Value == 2
    [x,y] = getLocs(vars.fov,vars.sigtot,'Source(s) in FOV');
    vars.sigpos = [x,y,ones(vars.sigtot,1).*1.5]'; 
elseif eventdata.Source.Value == 3
	X = rand(sigtot,1)*abs(vars.fov(1,2)-vars.fov(1,1))+vars.fov(1,1);
    Y = rand(sigtot,1)*abs(vars.fov(2,2)-vars.fov(2,1))+vars.fov(2,1);
    vars.sigpos = [X,Y,ones(sigtot,1).*1.5]';
    vars.sigetup = 'RANDOM';
end

myhandles.vars = vars;
myhandles.objs = objs;
guidata(gcf,myhandles);
end

% Save gui data to .mat file
% intended to be used after srp has been run
function saveVars(hObject,eventdata)
myhandles = guidata(gcbo);
objs = myhandles.objs;
vars = myhandles.vars;
css = myhandles.css;
im = myhandles.im;

if find(strcmp(objs.active,'varlist'))
    storVars(hObject,eventdata)
end

[file,path,indx] = uiputfile({'matlab *.mat'});

removeSideMenu(1);
% save('variableSave.mat','vars','objs','im');
save([path, file],'vars','objs','im');
% Draw Starting side menu
css.adj = 0;
css.boxTop = css.sideMenuTop;
if strcmp(vars.independent,'None')
    objs.active = {'indselect','varlist','guiopts'};
else
    objs.active = {'indselect','indvar','varlist','guiopts'};
end
currSideMenuIDs = getBoxIndexes(objs.boxTitles,objs.active);
for ss = 1:length(currSideMenuIDs)
	[css, objs] = loadBox(css,objs,currSideMenuIDs(ss));
end

myhandles.css = css;
myhandles.vars = vars;
myhandles.objs = objs;
guidata(gcf,myhandles);

editvars(hObject,eventdata);
end

% Load gui data from .mat file
function loadVars(hObject,eventdata)
myhandles = guidata(gcbo);
objs = myhandles.objs;
vars = myhandles.vars;
css = myhandles.css;
[file,path,indx] = uigetfile('matlab *.mat');

removeSideMenu(1);
load([path, file],'vars','objs');
% Draw Starting side menu
css.adj = 0;
css.boxTop = css.sideMenuTop;
if strcmp(vars.independent,'None')
    objs.active = {'indselect','varlist','guiopts'};
else
    objs.active = {'indselect','indvar','varlist','guiopts'};
end
currSideMenuIDs = getBoxIndexes(objs.boxTitles,objs.active);
for ss = 1:length(currSideMenuIDs)
	[css, objs] = loadBox(css,objs,currSideMenuIDs(ss));
end

myhandles.vars = vars;
myhandles.objs = objs;
guidata(gcf,myhandles);

% editvars(hObject,eventdata);
end

function restartGUI(ObjH, EventData)
OrigDlgH = ancestor(ObjH, 'figure');
delete(OrigDlgH);
GUI_srp;
end

function expSliderMove(hObject, EventData)
myhandles = guidata(gcf);
objs = myhandles.objs;
vars = myhandles.vars;

for pp = 1:length(myhandles.im)
   peak(pp) = max(max(myhandles.im{pp})); 
   low(pp) = min(min(myhandles.im{pp}));
end
zmax = max(peak)*1.01;
zmin = min(low);

units = objs.varbox.units{vars.ii};
objs.box{9}.itemhandle{2}.String = [num2str(round(EventData.Source.Value*10)/10),units];
[lowest idx] = min(abs(vars.value{vars.ii}-EventData.Source.Value));
vars.currentImageIndex = idx;
limits = axis;
myhandles.implot.delete;
myhandles.micplot.delete;
myhandles.sourceplot.delete;
hold on;
myhandles.implot = surf(vars.gridax{1},vars.gridax{2}, myhandles.im{idx});

%  Mark coherenet noise positions
%       plot(sigposn(1,:),sigposn(2,:),'xb','MarkerSize', 18,'LineWidth', 2);  %  Coherent noise
%  Mark actual target positions  
myhandles.sourceplot = plot3(vars.sigpos(1,:),vars.sigpos(2,:),ones(vars.sigtot)*1.5,'ok', 'MarkerSize', 18,'LineWidth', 2);
%  Mark microphone positions
myhandles.micplot = plot3(vars.mposplat{idx}(1,:),vars.mposplat{idx}(2,:),vars.mposplat{idx}(3,:),'sr','MarkerSize', 12);

if ~strcmp(vars.setup,'LINEAR')
    for iii = 1:size(vars.platcenters{idx},1) % Label Platform numbers
        myhandles.platlabs{idx}(iii).delete;
        myhandles.platlabs{idx}(iii) = text(vars.platcenters{idx}(iii,1),vars.platcenters{idx}(iii,2)+0.5,vars.platcenters{idx}(iii,3), ['Pl', int2str(iii)], 'HorizontalAlignment', 'center');
    end
end
for kn=1:length(vars.mposplat{idx}(1,:)) % Label microphones
        myhandles.miclabs{kn}.delete; % delete existing
        myhandles.miclabs{kn} = text(vars.mposplat{idx}(1,kn),vars.mposplat{idx}(2,kn),vars.mposplat{idx}(3,kn), int2str(kn), 'HorizontalAlignment', 'center');
end

hold off;   
caxis([zmin zmax]);
axis([limits(1:4),zmin, zmax]);

myhandles.vars = vars;
myhandles.objs = objs;
guidata(gcf,myhandles);
end

function removeSideMenu(insertPos)
myhandles = guidata(gcf);
objs = myhandles.objs;
currSideMenuIDs = getBoxIndexes(objs.boxTitles,objs.active);
%%%% delete all side menu boxes after insertPos
for tt = insertPos:length(currSideMenuIDs)
    rr = currSideMenuIDs(tt);
    delete(objs.box{rr}.rect);
    for dd = 1:objs.box{rr}.N
        delete(objs.box{rr}.itemhandle{dd});
    end
    for ll = 1:length(objs.box{rr}.labels)
        delete(objs.box{rr}.labels{ll});
    end
end
%%%%
myhandles.objs = objs;
guidata(gcf,myhandles);
end

% Adds the Independent variable box to side menu
function indVar(hObject,eventdata)
myhandles = guidata(gcbo);
css = myhandles.css;
objs = myhandles.objs;
vars = myhandles.vars;

% insert after the independent variable selection box
insertPos = find(strcmp(css.sidemenu1,'indselect')) + 1;
removeSideMenu(insertPos); % remove all side boxes
N = length(css.sidemenu1); % Get number of sideboxes

if eventdata.Source.Value ~= 1 % Selection is not the NONE option
    %%%% Insert box at insertPos
    if isempty(find(strcmp(css.sidemenu1,'indvar'), 1)) 
        % if indvar box doesn't already exist
        for bb = fliplr(insertPos:N) % Move each box down one
            css.sidemenu1{bb+1} = css.sidemenu1{bb};
        end
    end
    css.sidemenu1{insertPos} = 'indvar';
    objs.active = css.sidemenu1;
    
    varboxPos = find(strcmp(objs.boxTitles,'varlist'), 1);
    % Redefine variables list BOX
    objs.box{varboxPos} = objs.varbox;

    which = eventdata.Source.Value-1;
    % Remove independent variable from variable list box
    objs.box{varboxPos}.N = objs.box{varboxPos}.N - 1;
    objs.box{varboxPos}.label(which) = [];
    objs.box{varboxPos}.type(which) = [];
    objs.box{varboxPos}.string(which) = [];
    objs.box{varboxPos}.callback(which) = [];
    
    % Load in Box values
    objs.indvarbox.string = objs.indvarbox.select{which};
    indvarboxPos = find(strcmp(objs.boxTitles,'indvar'), 1);
    objs.box{indvarboxPos} = objs.indvarbox;
    objs.box{indvarboxPos}.units = objs.varbox.units{which};
    if  isempty(objs.indvarbox.string{3}) % For variables of integer value, the third box is removed
        objs.box{indvarboxPos}.N = 2;
    end
    
    % Redraw all boxes
    css.adj = css.padding;
    css.boxTop = css.sideMenuTop-2*css.padding-css.itemOffset;
    currSideMenuIDs = getBoxIndexes(objs.boxTitles,objs.active);
    for ss = insertPos:length(currSideMenuIDs)
        [css, objs] = loadBox(css,objs,currSideMenuIDs(ss));
    end
    %%%%
    
        % var box list
    popupmenulist = find(strcmp(objs.box{varboxPos}.type,'popupmenu'));
    for ii = popupmenulist
        nn = find(strcmp(vars.label,objs.box{varboxPos}.label(ii)));
        units = objs.varbox.units{nn};
        stringvalue = [vars.value{nn}, units];
        if ~iscell(vars.value{nn}) && ~ischar(vars.value{nn})
            stringvalue = [num2str(vars.value{nn}(1)), units];
        end
        val = find(strcmp(objs.varbox.string{nn},stringvalue));
        objs.box{varboxPos}.itemhandle{ii}.Value = val;
    end
    
else % None is chosen as independent variable
    if ~isempty(find(strcmp(css.sidemenu1,'indvar'), 1)) % indvar box exists
        css.sidemenu1{insertPos} = [];
        for bb = insertPos:(N-1) % Move each box up one
            css.sidemenu1{bb} = css.sidemenu1{bb+1};
        end
        css.sidemenu1(N) = [];
        objs.active = css.sidemenu1;
    end
    
        varboxPos = find(strcmp(objs.boxTitles,'varlist'), 1);
        % Redefine variables list BOX
        objs.box{varboxPos} = objs.varbox;

        % Redraw all boxes
        css.adj = css.padding;
        css.boxTop = css.sideMenuTop-2*css.padding-css.itemOffset;
        currSideMenuIDs = getBoxIndexes(objs.boxTitles,objs.active);
        for ss = insertPos:length(currSideMenuIDs)
            [css, objs] = loadBox(css,objs,currSideMenuIDs(ss));
        end
end


indselectPos = find(strcmp(objs.boxTitles,'indselect'), 1);
% Flag to state which indpendent variable
myhandles.vars.independent = objs.box{indselectPos}.itemhandle{1}.String{objs.box{indselectPos}.itemhandle{1}.Value};
myhandles.css = css;
myhandles.objs = objs;
guidata(gcf,myhandles);
end

% Function to load a fig file and plot
function loadfig(hObject,eventdata)
myhandles = guidata(gcbo);

% Update view
figure(myhandles.mainfig);
view(2);
% set(gca,'ZLim',[0,0.3])

% Load from Fig file
[file,path] = uigetfile('*.fig');
f = hgload([path, file]);
f.Visible = 'off';
ax = get(f,'CurrentAxes');
% ax.set('Parent',tabs{2});
copyobj(allchild(ax),myhandles.objs.axes);
myhandles.objs.axes.Title = ax.Title;
myhandles.objs.axes.Title.FontSize = 10;
myhandles.objs.axes.XAxis.Label = ax.XAxis.Label;
myhandles.objs.axes.YAxis.Label = ax.YAxis.Label;
end

function storVars(hObject,eventdata)
myhandles = guidata(gcbo);
css = myhandles.css;
objs = myhandles.objs;
vars = myhandles.vars;

locindvar = find(strcmp(objs.active,'indvar'), 1);
locvar = find(strcmp(objs.boxTitles,'varlist'), 1);
locindselect = find(strcmp(objs.boxTitles,'indselect'), 1);
varlist = objs.box{locvar};
vars.ii = 0;
% Get list of variables from template varbox
popupmenulist = find(strcmp(objs.varbox.type,'popupmenu'));
if ~isempty(locindvar) % indvar box exists
    locindvar = find(strcmp(objs.boxTitles,'indvar'), 1);
    % Append value
    start = objs.box{locindvar}.itemhandle{1}.String{objs.box{locindvar}.itemhandle{1}.Value};
    start = str2double(replace(start,objs.box{locindvar}.units,''));
    stop = objs.box{locindvar}.itemhandle{2}.String{objs.box{locindvar}.itemhandle{2}.Value};
    stop = str2double(replace(stop,objs.box{locindvar}.units,''));
    if objs.box{locindvar}.N == 3
        points = str2double(objs.box{locindvar}.itemhandle{3}.String{objs.box{locindvar}.itemhandle{3}.Value});
        array = linspace(start,stop,points);
    else
       array = start:stop; 
    end
    vars.ii = objs.box{locindselect}.itemhandle{1}.Value-1;
    vars.label{vars.ii} = vars.independent;
    vars.value{vars.ii} = array;
    popupmenulist(vars.ii) = [];
end

for nn = 1:length(popupmenulist)
    vars.label{popupmenulist(nn)} = varlist.label{nn};
    vars.value{popupmenulist(nn)} = replace(varlist.itemhandle{nn}.String{varlist.itemhandle{nn}.Value},objs.varbox.units{popupmenulist(nn)},'');
end

myhandles.vars = vars; % Variables for the simulation
myhandles.css = css;
myhandles.objs = objs;
guidata(gcf,myhandles);
end

function loadArray(hObject,eventdata)
storVars(hObject,eventdata);

myhandles = guidata(gcbo);
css = myhandles.css;
objs = myhandles.objs;
vars = myhandles.vars;

platnumloc = find(strcmp(objs.box{2}.label,'Number of Platforms'));
instr = objs.box{2}.itemhandle{platnumloc}.String{objs.box{2}.itemhandle{platnumloc}.Value};
platnum = str2num(instr); % number of platforms chosen

platLocOpt = 8; % index of popup box for platform locations option
platAngleOpt = 4;
locindvar = find(strcmp(objs.active,'indvar'), 1);
if ~isempty(locindvar) % indvar box exists in active list
    platLocOpt = platLocOpt-1;
    platAngleOpt = platAngleOpt-1;
end

if objs.box{2}.itemhandle{platLocOpt}.Value == 1
        % Define group of microphone platforms
        vars.platformGroup = Platform(vars.sigpos',platnum,0.5);
        [mjs_X, mjs_Y, mjs_Z] = vars.platformGroup.getMics();
        vars.pcs = [mjs_X, mjs_Y, mjs_Z]; % Center points of arrays
        vars.setup = 'EQUIDISTANT';
elseif  objs.box{2}.itemhandle{platLocOpt}.Value == 2
    [X,Y] = getLocs(vars.froom,platnum,'Platform Center(s) in FROOM');
    vars.pcs = [X,Y,ones(platnum,1).*1.5];
    vars.setup = 'CHOSEN';
elseif  objs.box{2}.itemhandle{platLocOpt}.Value == 3
    vars.setup = 'CHOSEN';
elseif  objs.box{2}.itemhandle{platLocOpt}.Value == 4
    X = rand(platnum,1)*abs(vars.froom(1,2)-vars.froom(1,1))+vars.froom(1,1);
    Y = rand(platnum,1)*abs(vars.froom(2,2)-vars.froom(2,1))+vars.froom(2,1);
    vars.pcs = [X,Y,ones(platnum,1).*1.5];
    vars.setup = 'RANDOM';
elseif  objs.box{2}.itemhandle{platLocOpt}.Value == 5
    vars.setup = 'LINEAR';
end

if objs.box{2}.itemhandle{platAngleOpt}.Value == 4
   vars.angleSetup = 'RANDOM';
else
   vars.angleSetup = 'SET'; 
end

removeSideMenu(1);

% Redraw boxes for simulation
css.adj = 0;
css.boxTop = css.sideMenuTop;
objs.active = css.sidemenu2;
simBoxes = getBoxIndexes(objs.boxTitles,objs.active);

% Copy vars to output box
for nn = 1:min(objs.box{simBoxes(1)}.N,length(vars.label))
    if nn == vars.ii
        objs.box{simBoxes(1)}.label{nn} = [vars.label{nn},' : ', num2str(vars.value{nn}(1)),...
            ' to ', num2str(vars.value{nn}(end))];
    else
        objs.box{simBoxes(1)}.label{nn} = [vars.label{nn},' : ', vars.value{nn}];
    end
end

for ss = 1:length(simBoxes)
	[css, objs] = loadBox(css,objs,simBoxes(ss));
end

myhandles.vars = vars; % Variables for the simulation
myhandles.css = css;
myhandles.objs = objs;
guidata(gcf,myhandles);
end

% Return to editing vars menu
function editvars(hObject,eventdata)
myhandles = guidata(gcf);
objs = myhandles.objs;
css = myhandles.css;
vars = myhandles.vars;

removeSideMenu(1);
 
% Draw Starting side menu
css.adj = 0;
css.boxTop = css.sideMenuTop;
objs.active = css.sidemenu1;
currSideMenuIDs = getBoxIndexes(objs.boxTitles,objs.active);
for ss = 1:length(currSideMenuIDs)
	[css, objs] = loadBox(css,objs,currSideMenuIDs(ss));
end

% find boxes by titles and store locally
indselect = objs.box{strcmp(objs.boxTitles,'indselect')};
indsetup = objs.box{strcmp(objs.boxTitles,'indvar')};
varlist = objs.box{strcmp(objs.boxTitles,'varlist')};
% Reset Independent variable selection
val = find(strcmp(indselect.itemhandle{1}.String,vars.independent));
indselect.itemhandle{1}.Value = val;
if strcmp(vars.independent,'None')
    % var box list
    popupmenulist = find(strcmp(varlist.type,'popupmenu'));
    for ii = popupmenulist
        nn = find(strcmp(vars.label,varlist.label(ii)));
        units = objs.varbox.units{nn};
        val = find(strcmp(objs.varbox.string{nn},[vars.value{nn},units]));
        varlist.itemhandle{ii}.Value = val;
    end
else
    % var box list
    popupmenulist = find(strcmp(varlist.type,'popupmenu'));
    for ii = popupmenulist
        nn = find(strcmp(vars.label,varlist.label(ii)));
        units = objs.varbox.units{nn};
        val = find(strcmp(objs.varbox.string{nn},[vars.value{nn} units]));
        varlist.itemhandle{ii}.Value = val;
    end
end

myhandles.css = css;
myhandles.objs = objs;
guidata(gcf,myhandles);
end

% Toggle the Fullscreen mode
function Fullscreen(hObject,eventdata)
myhandles = guidata(gcbo);

    if min(get(gcf,'outerposition') == [0 0 0.8 1])
        set(gcf, 'units','Pixels',...
            'position',[0 0 myhandles.css.width myhandles.css.height]);
        movegui(gcf,'center') % recenter GUI
    else
        set(gcf, 'units','normalized','outerposition',[0 0 0.8 1]);
    end
end
% Keyboard shortcuts for toggling plotted features
function key_pressed_fcn(hObject, eventdata, handles)
myhandles = guidata(gcbo);
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%   Key: name of the key that was pressed, in lower case
%   Character: character interpretation of the key(s) that was pressed
%   Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% add this part as an experiment and see what happens!
% eventdata % Let's see the KeyPress event data
% disp(eventdata.Key) % Let's display the key, for fun!
if exist('myhandles')    
  if eventdata.Key == 'o'
    if ~isempty(myhandles.sourceplot)
        if strcmp(myhandles.sourceplot(1).Visible,'on')
            set(myhandles.sourceplot,'Visible','off')
        else
            set(myhandles.sourceplot,'Visible','on')
        end
    end
  elseif eventdata.Key == 'i'
    if ~isempty(myhandles.implot)
        if strcmp(myhandles.implot(1).Visible,'on')
            set(myhandles.implot,'Visible','off')
        else
            set(myhandles.implot,'Visible','on')
        end
    end
  elseif eventdata.Key == 'm'
    if ~isempty(myhandles.micplot)
        if strcmp(myhandles.micplot(1).Visible,'on')
            set(myhandles.micplot,'Visible','off')
            set(myhandles.platlabs{1:end},'Visible','off')
            set(myhandles.miclabs{1:end},'Visible','off')
        else
            set(myhandles.micplot,'Visible','on')
            set(myhandles.platlabs{1:end},'Visible','on')
            set(myhandles.miclabs{1:end},'Visible','on')
        end
    end
  end
end
 
end
% Loads a box in the sidemenu from objs.side.box
function [css, objs] = loadBox(css,objs,boxID)
css.boxTop = css.boxTop-2*css.padding-css.adj-css.itemOffset; % vertically offset from previous box 
currBox = objs.box{boxID};
if css.boxTop-css.itemOffset*(currBox.N-1)+css.padding < 0
    return
end
ll = 1;
currBox.labels = {};
for itemID = 1:currBox.N
    if strcmp(currBox.type{itemID},'popupmenu')
        currBox.labels{ll} = uicontrol('Style', 'text', 'String', currBox.label{itemID},...
            'BackgroundColor',css.rgbcolorb'./255,...
            'Position', [css.border+css.padding*2 ...
                     css.boxTop-css.textOffset-css.itemOffset*(itemID-1)...
                     130 20]);
        currBox.labels{ll}.HorizontalAlignment = css.HorizontalAlignment; 
        currBox.labels{ll}.FontWeight = css.FontWeight;
        currBox.labels{ll}.FontSize = css.FontSize; 
        currBox.labels{ll}.FontName = css.FontName;
        ll = ll + 1;
        
        if isempty(currBox.callback)
        currBox.itemhandle{itemID} = uicontrol('Style','popupmenu',...
            'String',currBox.string{itemID},'Value',1,...
            'Position',[160 css.boxTop-css.itemOffset*(itemID-1) 100 20]);
        else
        currBox.itemhandle{itemID} = uicontrol('Style','popupmenu',...
            'String',currBox.string{itemID},'Value',1,...
            'Position',[160 css.boxTop-css.itemOffset*(itemID-1) 100 20],...
            'Callback', currBox.callback{itemID});
        end
        css.adj = css.itemOffset*(currBox.N-1)+css.padding;
    elseif strcmp(currBox.type{itemID},'pushbutton')
        currBox.itemhandle{itemID} = uicontrol('Style', 'pushbutton', 'String', currBox.label{itemID} ,...
            'Position', [css.border+css.padding*2 ...
                 css.boxTop-css.itemOffset*(itemID-1)...
                 236 20],'Callback', currBox.callback{itemID}); 
        css.adj = css.itemOffset*(currBox.N-1)+css.padding;
    elseif strcmp(currBox.type{itemID},'text')
        currBox.itemhandle{itemID} = uicontrol('Style', 'text', 'String', currBox.label{itemID} ,...
            'Position', [css.border+css.padding*2 ...
                 css.boxTop-(css.itemOffset-10)*(itemID-1)...
                 236 20]); 
        css.adj = (css.itemOffset-10)*(currBox.N-1)+css.padding;
    elseif strcmp(currBox.type{itemID},'slider')
        currBox.labels{ll} = uicontrol('Style', 'text', 'String', currBox.label{itemID},...
            'BackgroundColor',css.rgbcolorb'./255,...
            'Position', [css.border+css.padding*2 ...
                     css.boxTop-css.textOffset-css.itemOffset*(itemID-1)...
                     130 20]);
        currBox.labels{ll}.HorizontalAlignment = css.HorizontalAlignment; 
        currBox.labels{ll}.FontWeight = css.FontWeight;
        currBox.labels{ll}.FontSize = css.FontSize; 
        currBox.labels{ll}.FontName = css.FontName;
        ll = ll + 1;
        
        units = objs.varbox.units{itemID};
        currBox.itemhandle{itemID} = uicontrol('Style','slider',...
            'min',str2double(replace(currBox.string{itemID}{1},units,'')),...
            'Value',str2double(replace(currBox.string{itemID}{1},units,'')),...
            'max',str2double(replace(currBox.string{itemID}{end},units,'')),...
            'Position',[160 css.boxTop-css.itemOffset*(itemID-1) 100 20],...
            'SliderStep', [str2double(replace(currBox.string{itemID}{1},units,'')),...
             str2double(replace(currBox.string{itemID}{end},units,''))],...
            'Callback', currBox.callback{itemID});
        css.adj = css.itemOffset*(currBox.N-1)+css.padding;
    end
end

% Create rectangle
currBox.rect = annotation(gcf,'rectangle',...
    [css.border css.boxTop-css.padding-css.adj 250 css.itemOffset+css.adj]./css.size,...
        'FaceColor',css.rgbcolorb'./255);
currBox.rect.Units = 'Pixels';
objs.box{boxID} = currBox;
end
% Removes overlapping Stop values given a Start value
function noOverlapCheckStart(hObject,eventdata)
myhandles = guidata(gcbo);
css = myhandles.css;
objs = myhandles.objs;
% eventdata.Source.Tag % Which popupbox
result = eventdata.Source.String{eventdata.Source.Value}; % option selected
indvarpos = find(strcmp(objs.boxTitles,'indvar'));
    which = find(strcmp(result,objs.box{indvarpos}.string{1})==1);
    if which > objs.box{indvarpos}.itemhandle{2}.Value
        objs.box{indvarpos}.itemhandle{2}.Value = which;
    end

myhandles.css = css;
myhandles.objs = objs;
guidata(gcf,myhandles);
end
% Removes overlapping Start values given a Stop value
function noOverlapCheckStop(hObject,eventdata)
myhandles = guidata(gcbo);
css = myhandles.css;
objs = myhandles.objs;
% eventdata.Source.Tag % Which popupbox
result = eventdata.Source.String{eventdata.Source.Value}; % option selected
indvarpos = find(strcmp(objs.boxTitles,'indvar'));
    which = find(strcmp(result,objs.box{indvarpos}.string{2})==1);
    if which < objs.box{indvarpos}.itemhandle{1}.Value
        objs.box{indvarpos}.itemhandle{1}.Value = which;
    end
myhandles.css = css;
myhandles.objs = objs;
guidata(gcf,myhandles);
end
% similar to setdiff but for two cells of strings. returns the indexes in 
% the first cell of the matching elements.
function indexes = getBoxIndexes(cellBoxNames,cellSelectBoxes)
indexes = [];
for ii = 1:length(cellSelectBoxes)
   val = find(strcmp(cellBoxNames,cellSelectBoxes{ii})); 
   indexes = [indexes, val];
end
end

%% Function to setup a SRP simulation from GUI
function runSRP(hObject,eventdata) 
myhandles = guidata(gcbo);
objs = myhandles.objs;
css = myhandles.css;
vars = myhandles.vars;

%%%% Get variable values for simulation
coeff = [1 1 1 (pi/180) 1]; % values to scale input variables
for vv = 1:5 % load numerical variables from user data
    if ischar(vars.value{vv})
        localvars.value{vv} = str2double(vars.value{vv}).*coeff(vv);
    else
        localvars.value{vv} = vars.value{vv}.*coeff(vv);
    end
end

% store independent variable array
if strcmp(vars.independent,'None') %
    vars.ii = 1;
end
localvars.indvalues = localvars.value{vars.ii};
localvars.value{vars.ii} = localvars.indvalues(1);

% String inputs and static variables
source = vars.value{6};
sourcesetup = vars.value{7};
platsetup = vars.value{8};
cameraAngle = 2;
N = 1;
if strcmp(vars.angleSetup,'RANDOM')
    N = 8; % number of angles        
end
aperature = localvars.value{3}; % meters
center = 0; % linear array center x-coordinate
myhandles.im{1} = 0;

waitDialog = waitbar(0,'Running Simulation');
%%%% independent variable loop
for aa = 1:length(localvars.indvalues)
localvars.value{vars.ii} = localvars.indvalues(aa);

    for bb = 1:N
        angle = localvars.value{4};
        if strcmp(vars.angleSetup,'RANDOM')
            angle = rand(1)*pi/2;
        end
    micnum = localvars.value{2}*localvars.value{1};  %  Number of mics in array to be tested
    mjs_radius = localvars.value{5}/(200*sin(pi/localvars.value{1}));

    if strcmp(vars.setup,'EQUIDISTANT')
        mjs_platformGroup = vars.platformGroup;
        mjs_platformGroup.setRadius(localvars.value{3});
        [mjs_X, mjs_Y, mjs_Z] = mjs_platformGroup.getMics();
        vars.pcs = [mjs_X, mjs_Y, mjs_Z]; % Center points of arrays
    elseif strcmp(vars.setup,'LINEAR')
        micnum = localvars.value{2};  %  Number of mics in array to be tested
        I = ones(localvars.value{2},1);
        vars.pcs = [...
            linspace(center-aperature/2,center+aperature/2,localvars.value{2})'...
            I*3 I*1.5];
        vars.mposplat{aa} = vars.pcs';
    elseif localvars.value{2} == 2
        distBetween = sqrt(sum((vars.pcs(2,:)-vars.pcs(1,:)).^2));
        scale = distBetween/localvars.value{3};
        vars.pcs(2,:) = vars.pcs(1,:) + (vars.pcs(2,:)-vars.pcs(1,:))/scale;
    end
    
    
    if ~strcmp(vars.setup,'LINEAR')
    % Precompute half angles for quaternion rotation
    mjs_cos2 = cos(angle/2); mjs_sin2 = sin(angle/2);
    % Define Platforms
        for pp = 1:localvars.value{2} % loop for identical platforms
            mjs_platform(pp) = Platform(vars.pcs(pp,:),localvars.value{1},localvars.value{5}/100);
            % vector from each mic center to source location
            mjs_pl2src(pp,:) = vars.sigpos-vars.pcs(pp,:)';
            mjs_pltheta(pp) = atan2(mjs_pl2src(pp,2),mjs_pl2src(pp,1));
            % tangential planar vector for rotation
            mjs_pltan2src(pp,:) = cross(mjs_pl2src(pp,:),[0 0 1]);
            % z axis rotations to orient endfire to source;
            mjs_platform(pp).eulOrient(mjs_pltheta(pp),0); 
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('Angle is %02.f degrees : ', angle/pi*180);
        for pp = 1:localvars.value{2}
        	mjs_platform(pp).eulOrient(mjs_pltheta(pp),angle); 
        end

% Add microphone coordinates to mic position matrix
        for pp = 1:localvars.value{2}
            [mjs_X, mjs_Y, mjs_Z] = mjs_platform(pp).getMics();
            vars.mposplat{aa}(:,(pp-1)*localvars.value{1}+(1:localvars.value{1})) = [mjs_X, mjs_Y, mjs_Z]'; % Set mic coordinates
        end
    end
%         vars.mposplat{aa} = zeros(3,micnum);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find max distance (delay) over all mic pairs; this represents an upper bound
% on all required relative delays when scanning over the FOV
        [rm, nm] = size(vars.mposplat{aa});
        prs = mposanaly(vars.mposplat{aa},2);

% Maximum delay in seconds needed to synchronize in Delay and Sum beamforming
        maxmicd = max(prs(:,3));
% Extra delay time for padding window of data
        textra = ceil(vars.fs*maxmicd(1)/vars.prop.c); 
% Windowing function to taper edge effects in the whitening process
        tapwin = flattap(vars.winlen+textra,20);
        winrec = tapwin*ones(1,micnum);

waitbar(0.25,waitDialog,'Simulating Source');
%%%% SOURCE
% Generate target waveforms
        switch source
            case 'IMPULSE'
                vars.f11s = vars.f11p-0.2*vars.f11p;  %  Compute Stop bands from passbands
                vars.f12s = vars.f12p+0.2*vars.f12p;  %  Compute Stop bands from passbands
% Ensure signal occurs at a late enough time to be included in
% first window for processing
                td = textra/(vars.fs)+15*vars.trez/2;
                simsiglen = td+2*(4/(vars.f12p-vars.f11p) + 4/vars.f11p);
                target = simimp(vars.f11p,vars.f12p,vars.f11s,vars.f12s,td,vars.fs,simsiglen);
% Expand to multiple targets if sigtot greater than 1
                target = target*ones(1,vars.sigtot);
    
            case 'MOZART'
                [target,fso] = audioread('./wav/mozart-1.wav');
                target = target(1:fso);
                target = resample(target,vars.fs,fso);  % Resample to fs
%                 target = filtfilt(target,a,y); % high pass filter the signal
                target = target*ones(1,vars.sigtot);

            case 'SINE'
                freq1 = 1000; time = (1:vars.fs)./vars.fs;
                target = sin(2*pi*freq1*time);
                target = target'*ones(1,vars.sigtot);
    
            case 'WHITE NOISE'
                [b,a] = butter(5,[200 vars.fs-200]./vars.fs);
                target = randn(vars.fs,1);
                target = 10^(-3/20)*(target./max(target));
                target = filtfilt(b,a,target);
        end

% Compute array signals from target
        [sigoutper, taxper] = simarraysigim(target, vars.fs, vars.sigpos, vars.mposplat{aa}, vars.froom, vars.bs, vars.prop);
% Random generation of coherent noise source positions on wall 
%         for knn=1:numnos
%             randv = ceil(rand(1,1)*4);
% Noise source positions
%             sigposn(:,knn) = vn(:,randv) + rand(1)*(vn(:,mod(randv,4)+1)-vn(:,randv));
%         end
        sigposn = [-2.6204 3.500; 4.000 -3.6285; 1.5000 1.5000];
% Create coherent white noise source with sample lengths as target signal
        [rt,ct] = size(target);
% generate white noise 
        onos = randn(rt,vars.numnos);
% place white noise target randomly on wall
%         [nosoutper, taxnosper] = simarraysigim(onos,vars.fs, sigposn, mposperim, froom, bs, vars.prop);
        [nosoutper, taxnosper] = simarraysigim(onos,vars.fs, sigposn, vars.mposplat{aa}, vars.froom, vars.bs, vars.prop);

        %%%% ENVELOPE SOURCE
        [mxp,cp] = max(max(abs(sigoutper)));  % Max point over all channels
        envper = abs(hilbert(sigoutper(:,cp(1))));  % Compute envelope of strongest channel
        % Compute maximum envelope point for reference in SNRs
        % Also location of max point will be used to ensure time window processed includes
        % the target
        [perpkpr, rpper] = max(envper);
        % Trim room signals to same length
        [siglenper, mc] = size(sigoutper);
        [noslenper, mc] = size(nosoutper);
        siglen = min([siglenper, noslenper]);
        sigoutper = sigoutper(1:siglen,:);
        nosoutper = nosoutper(1:siglen,:);

        N_win = vars.N_win;   
        %%%% SRP Window
        for ww = 1:N_win
            % Random window in 1 second
%             rpper = vars.winlen+round((length(target)-2*vars.winlen)*rand(1));
            rpper = vars.winlen+round((length(target)-2*vars.winlen)*0.4);
            % Normalize noise power
            nosoutper = nosoutper/sqrt(mean(mean(nosoutper.^2)));
            % Add coherent noise to target signals
            nos = randn(siglen,mc);
            asnr = 10^((vars.cnsnr/20));
            nosamp = asnr*perpkpr;
            sigoutpera = sigoutper + nosamp*nosoutper + nos*vars.sclnos*perpkpr;
            % Initialize signal window index to beginning index, offset to ensure it includes target
            % signal
            sst = 1+rpper(1)-fix(.9*vars.winlen); 
            sed = sst+min([vars.winlen+textra, siglen]);   %  and end window end
            % create tapering window
%             fprintf(' Window starts at %d seconds \n', sst/vars.fs);
            tapwin = flattap(sed-sst+1,20);  %  One dimensional
            wintap = tapwin*ones(1,micnum);  %  Extend to matrix covering all channels
            % Whiten signal (apply PHAT, with beta factor given at the begining)
            sigout = whiten(sigoutpera(sst:sed,:).*wintap, vars.batar);
            % Create SRP Image from processed perimeter array signals
            waitbar(.50,waitDialog,'Running SRP image');
            im = srpframenn(sigout, vars.gridax, vars.mposplat{aa}, vars.fs, vars.prop.c, vars.trez);
            if ww == 1
               myhandles.im{aa} = zeros(size(im)); 
            end
            myhandles.im{aa} = (myhandles.im{aa}.*(ww-1)+im)./ww;
            waitbar(.75,waitDialog,'Plotting SRP image');
            
            %%%% IMAGE ANALYSIS
%             [SNRdB,avgnoise,peakSourcePower,thresholdMeanPower] = imErrorAnalysis(myhandles.im{aa},vars.gridax,vars.sigpos,8);
%             win_errs(ww,:) = [SNRdB,avgnoise,peakSourcePower];
        end
        
        figure(myhandles.mainfig);
        myhandles.implot = surf(vars.gridax{1},vars.gridax{2}, myhandles.im{aa});
        peakVal = max(max(myhandles.im{aa})); % Used to test convergence
        colormap(jet); colorbar; axis('xy');
        axis([vars.froom(1,1)-.25, vars.froom(1,2)+.25, vars.froom(2,1)-.25, vars.froom(2,2)+.25]);
        hold on;
        %  Mark coherenet noise positions
%       plot(sigposn(1,:),sigposn(2,:),'xb','MarkerSize', 18,'LineWidth', 2);  %  Coherent noise
        %  Mark actual target positions  
        myhandles.sourceplot = plot3(vars.sigpos(1,:),vars.sigpos(2,:),ones(vars.sigtot)*1.5,'ok', 'MarkerSize', 18,'LineWidth', 2);
        %  Mark microphone positions
        myhandles.micplot = plot3(vars.mposplat{aa}(1,:),vars.mposplat{aa}(2,:),vars.mposplat{aa}(3,:),'sr','MarkerSize', 12);
        axis('tight');
            
        if ~strcmp(vars.setup,'LINEAR')
            for iii = 1:localvars.value{2} % Label Platform numbers
                vars.platcenters{aa}(iii,:) = mjs_platform(iii).getCenter();
                myhandles.platlabs{aa}(iii) = text(vars.platcenters{aa}(iii,1),vars.platcenters{aa}(iii,2)+0.5,vars.platcenters{aa}(iii,3), ['Pl', int2str(iii)], 'HorizontalAlignment', 'center');
            end
        end
        for kn=1:length(vars.mposplat{aa}(1,:)) % Label microphones
            myhandles.miclabs{kn} = text(vars.mposplat{aa}(1,kn),vars.mposplat{aa}(2,kn),vars.mposplat{aa}(3,kn), int2str(kn), 'HorizontalAlignment', 'center');
        end

            % Draw Room walls
        plot([vars.vn(1,:), vars.vn(1,1)],[vars.vn(2,:), vars.vn(2,1)],'k--')
        % Label Plot
        xlabel('Xaxis Meters')
        ylabel('Yaxis Meters')
        title({['SRP image (Mics at squares,'],[' Target in circle, Noise sources at Xs']} )
        hold off    

        vars.currentImageIndex = aa;
            if bb == 1
               myhandles.im{aa} = zeros(size(im)); 
            end
            myhandles.im{aa} = (myhandles.im{aa}.*(bb-1)+im)./bb;
                    
        %%%% IMAGE ANALYSIS
        [SNRdB,avgnoise,peakSourcePower,thresholdMeanPower] = imErrorAnalysis(myhandles.im{aa},vars.gridax,vars.sigpos,8);
        table(SNRdB,avgnoise,peakSourcePower,thresholdMeanPower)
    end
        
end % END of aa loop

waitbar(1,waitDialog,'Done');
close(waitDialog);
% pause

removeSideMenu(1);
% Add Boxes
css.adj = 0;
css.boxTop = css.sideMenuTop;
if strcmp(vars.independent,'None')
    objs.active = {css.sidemenu2{:}, css.sidemenu3{:}};
else
   objs.active = {css.sidemenu2{:}, css.sidemenu3{:},'scroll'}; 
   objs.box{9}.label{1} = vars.independent;
end
simBoxes = getBoxIndexes(objs.boxTitles,objs.active);

% Copy vars to output box
for nn = 1:min(objs.box{simBoxes(1)}.N,length(vars.label))
    if nn == vars.ii
        objs.box{simBoxes(1)}.label{nn} = [vars.label{nn},' : ', num2str(vars.value{nn}(1)),...
            ' to ', num2str(vars.value{nn}(end))];
    else
        objs.box{simBoxes(1)}.label{nn} = [vars.label{nn},' : ', vars.value{nn}];
    end
end

for ss = 1:length(simBoxes)
	[css, objs] = loadBox(css,objs,simBoxes(ss));
end

if ~strcmp(vars.independent,'None')
    boxID = 9; % scroll box number
	objs.box{boxID}.itemhandle{1}.Max = vars.value{vars.ii}(end);
    objs.box{boxID}.itemhandle{1}.Value = vars.value{vars.ii}(1);
	objs.box{boxID}.itemhandle{1}.Min = vars.value{vars.ii}(1);
    objs.box{boxID}.itemhandle{1}.SliderStep = ...
            [1,1]./(length(vars.value{vars.ii})-1);

end

myhandles.vars = vars;
myhandles.css = css;
myhandles.objs = objs;
guidata(gcf,myhandles);
end

% Run the error analysis on current plot and display table of values
function errorAnalysis(hObject,eventdata)
myhandles = guidata(gcf);
vars = myhandles.vars;

%%%% IMAGE ANALYSIS
[SNRdB,avgnoise,peakSourcePower,thresholdMeanPower] = imErrorAnalysis(myhandles.im{vars.currentImageIndex},vars.gridax,vars.sigpos,8);
% win_errs(ww,:) = [SNRdB,avgnoise,peakSourcePower];
            
% disp([' SNRdB :', num2str(SNRdB),...
%       '    Mean Noise :', num2str(avgnoise),...
%       '    Peak Source Power :', num2str(peakSourcePower)]);
table(SNRdB,avgnoise,peakSourcePower,thresholdMeanPower)

myhandles.vars = vars;
guidata(gcf,myhandles);
end