% Michael Sikora <m.sikora@uky.edu>
% 2018.05.15
% Summer Research with Dr. Donohue at University of Kentucky
% dynamic GUI setup of SRP image simulator

%% GUI Fig Loader for dynamic microphone array simulations
function GUI_srp()
close all;

%%%% Set Style Attributes
colors{1} = '71d1f1'; % blue
colors{2} = '71f1c1'; % mint
colors{3} = '315171'; % dark blue
colors{4} = '317151'; % forest green
colors{5} = 'ffa151'; % orange
colors{6} = '333333'; % grey
colors{7} = '0033a0'; % Wildcat Blue
colors{8} = '2c2a29'; % Wildcat Black
colors{9} = '1897d4'; % Light Blue
% colora = colors{1+round((length(colors)-1)*rand(1))}; 
colora = colors{9};
css.rgbcolora = hex2dec([colora(1:2); colora(3:4); colora(5:6)]);
colorb = 'fafafa';
css.rgbcolorb = hex2dec([colorb(1:2); colorb(3:4); colorb(5:6)]);

css.width = 900; css.height = 600;
css.size = [css.width css.height css.width css.height];

%%%% SideMenu Styling
css.sideMenuTop = css.height-10;
css.textOffset = 4;
css.itemOffset = 30;
css.border = 16;
css.padding = 4;
css.boxTop = css.sideMenuTop;

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
%%%% Boxes for independent variables
objs.indvarbox.N = 3; % number of objects in box
objs.indvarbox.label = {'Starting Value','Ending Value','Samples'} ;% text for label
objs.indvarbox.type  = {'popupmenu','popupmenu','popupmenu'};% types of the objects
objs.indvarbox.string = {}; % string values for object
objs.indvarbox.units = {'','','m','deg','cm','','',''};
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

%%%% BOX 2 Full variables list (Stored seperately)
objs.varbox.N = 9; % number of objects in box
objs.varbox.label = {'Mics per Platform','Number of Platforms',...
                     'Distance to Source(m)','Platform Angle',...
                     'Distance Between Mics','Source Type','Source Locations','Platform Locations','Load Variables'} ;% text for label
objs.varbox.type  = {'popupmenu','popupmenu','popupmenu',...
                'popupmenu','popupmenu','popupmenu','popupmenu','popupmenu','pushbutton'};% types of the objects
objs.varbox.string = {{'2','3','4','5'},...
                {'1','2','3','4','5'},...
                {'0.5m','1m','1.5m','2m','2.5m','3m','3.5m'},...
                {'0deg','45deg','90deg'},...
                {'5cm','10cm','17cm','20cm','25cm','30cm'},...
                {'IMPULSE','MOZART','SINE','WHITE NOISE'},...
                {'Center','Choose Location'},...
                {'Equidistant','Choose Locations','Monte Carlo'},...
                {}}; % string values for object
objs.varbox.callback = {'','','','','','',@setLocS,'',@loadArray};
objs.box{2} = objs.varbox;

which = find(strcmp(objs.varbox.type, 'popupmenu'));
%%%% BOX 1
objs.box{1}.N = 1; % number of objects in box
objs.box{1}.label = {'Independent Variable'} ;% text for label
objs.box{1}.type  = {'popupmenu'};% types of the objects
objs.box{1}.string = {{'None',objs.varbox.label{which(1:length(objs.indvarbox.select))}}}; % string values for object
objs.box{1}.callback = {@indVar};

%%%% BOX 3
objs.box{3}.N = 8;
objs.box{3}.label = {'DATA','','','','','','',''};
objs.box{3}.type = {'text','text','text','text','text','text','text','text'};
objs.box{3}.string = {'','','','','','','',''};
objs.box{3}.callback = {'','','','','','','',''};

%%%% BOX 4
objs.box{4}.N = 3; % number of objects in box
objs.box{4}.label = {'Plot Type','View','Update Figure'} ;% text for label
objs.box{4}.type  = {'popupmenu','popupmenu','pushbutton'};% types of the objects
objs.box{4}.string = {{'SRP image','Platform Orientations','SNR dB'},...
                {'XY','XYZ'},...
                {}}; % string values for object
objs.box{4}.callback = {'','',@loadFig};

%%%% BOX 5
objs.box{5}.N = 3; % number of objects in box
objs.box{5}.label = {'Restart GUI','Toggle Fullscreen','About'} ;% text for label
objs.box{5}.type  = {'pushbutton','pushbutton','pushbutton'};% types of the objects
objs.box{5}.string = {{},{},{}}; % string values for object
objs.box{5}.callback = {@restartGUI,@Fullscreen,@dispvars};

%%%% BOX 6
objs.box{6}.N = 2; % number of objects in box
objs.box{6}.label = {'Edit Variables','Run SRP'} ;% text for label
objs.box{6}.type  = {'pushbutton','pushbutton'};% types of the objects
objs.box{6}.string = {{},{},{}}; % string values for object
objs.box{6}.callback = {@editvars,@setupSim};

%%%% BOX 7
objs.box{7}.N = 1;

%%%% BOX 6
objs.box{8}.N = 2; % number of objects in box
objs.box{8}.label = {'Run Error Analysis','Save Plot'} ;% text for label
objs.box{8}.type  = {'pushbutton','pushbutton'};% types of the objects
objs.box{8}.string = {{},{}}; % string values for object
objs.box{8}.callback = {@errorAnalysis,@saveFig};

%%%% Define Side menu box labels and tentatively use for ordering in display
objs.boxTitles = {'indselect','varlist','output','plots','guiopts','srpsim','indvar','aftersrp'};
objs.active = {'indselect','varlist','guiopts'};
% Draw Starting side menu
css.adj = 0;
css.boxTop = css.sideMenuTop;
currSideMenuIDs = getBoxIndexes(objs.boxTitles,objs.active);
for ss = 1:length(currSideMenuIDs)
	[css, objs] = loadBox(css,objs,currSideMenuIDs(ss));
end

%%%% default variables
vars.independent = 'None';
vars.sigpos = [0 0 1.5]';
vars.setup = 'EQUIDISTANT';
popupmenulist = find(strcmp(objs.varbox.type,'popupmenu'));
for nn = popupmenulist
    vars.label{nn} = objs.varbox.label{nn};
    vars.value{nn} = replace(objs.varbox.string{nn}{1},objs.indvarbox.units{nn},'');
end

declare; % generates mat file of predefined variables

%%%% Save GUI data for callback use
myhandles = guihandles(mainWin); 
myhandles.mainfig = mainWin; % Main figure handle
myhandles.css = css; % StyleSheet Struct
myhandles.objs = objs; % Graphics Objects Struct
myhandles.vars = vars; % Variables for the simulation
guidata(mainWin,myhandles);
end



% Return to editing vars menu
function editvars(hObject,eventdata)
myhandles = guidata(gcbo);
objs = myhandles.objs;
css = myhandles.css;
vars = myhandles.vars;

removeSideMenu(1);
 
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

val = find(strcmp(objs.box{currSideMenuIDs(1)}.itemhandle{1}.String,vars.independent));
objs.box{currSideMenuIDs(1)}.itemhandle{1}.Value = val;
if strcmp(vars.independent,'None')
    % var box list
    popupmenulist = find(strcmp(objs.box{currSideMenuIDs(2)}.type,'popupmenu'));
    for ii = popupmenulist
        nn = find(strcmp(vars.label,objs.box{currSideMenuIDs(2)}.label(ii)));
        units = objs.indvarbox.units{nn};
        val = find(strcmp(objs.varbox.string{nn},[vars.value{nn},units]));
        objs.box{currSideMenuIDs(2)}.itemhandle{ii}.Value = val;
    end
else
    % var box list
    popupmenulist = find(strcmp(objs.box{currSideMenuIDs(3)}.type,'popupmenu'));
    for ii = popupmenulist
        nn = find(strcmp(vars.label,objs.box{currSideMenuIDs(3)}.label(ii)));
        units = objs.indvarbox.units{nn};
        val = find(strcmp(objs.varbox.string{nn},[vars.value{nn},units]));
        objs.box{currSideMenuIDs(3)}.itemhandle{ii}.Value = val;
    end
end


myhandles.css = css;
myhandles.objs = objs;
guidata(gcf,myhandles);
end

function saveFig(hObject,eventdata)
myhandles = guidata(gcbo);
objs = myhandles.objs;

[file,path,indx] = uiputfile({'*.fig';...
    'image *.png'});

% saveas(h,sprintf('images/roomsim1_%d_%d.png',bb,aa));
saveas(objs.axes ,[path, file]);

myhandles.objs = objs;
guidata(gcf,myhandles);
end

% Run the SRP image using the stored variables
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
css = myhandles.css;
vars = myhandles.vars;

if  eventdata.Source.Value == 1
    vars.sigpos = [0 0 1.5]';
elseif eventdata.Source.Value == 2
    [x,y] = getLocs(vars.fov,vars.sigtot,'Source(s) in FOV');
    vars.sigpos = [x,y,ones(vars.sigtot,1).*1.5]'; 
end

myhandles.vars = vars;
myhandles.css = css;
myhandles.objs = objs;
guidata(gcf,myhandles);
end

function setLocP(hObject,eventdata)
myhandles = guidata(gcbo);
objs = myhandles.objs;
css = myhandles.css;
vars = myhandles.vars;

platnum = str2num(objs.box{2}.itemhandle{2}.String{objs.box{2}.itemhandle{2}.Value});
if eventdata.Source.Value == 1
        % Define group of microphone platforms
        vars.platformGroup = Platform([0 0 1.5],platnum,0.5);
        [mjs_X, mjs_Y, mjs_Z] = vars.platformGroup.getMics();
        vars.pcs = [mjs_X, mjs_Y, mjs_Z]; % Center points of arrays
        vars.setup = 'EQUIDISTANT';
elseif  eventdata.Source.Value == 2
    [X,Y] = getLocs(vars.froom,platnum,'Platform Center(s) in FROOM');
    vars.pcs = [X,Y,ones(platnum,1).*1.5];
    vars.setup = 'CHOSEN';
end

myhandles.vars = vars;
myhandles.css = css;
myhandles.objs = objs;
guidata(gcf,myhandles);
end

% Finds the indexes of all elements in one cell array in another, assumes
% strings
function indexes = getBoxIndexes(cellBoxNames,cellSelectBoxes)
indexes = [];
for ii = 1:length(cellSelectBoxes)
   val = find(strcmp(cellBoxNames,cellSelectBoxes{ii})); 
   indexes = [indexes, val];
end
end

function restartGUI(ObjH, EventData)
OrigDlgH = ancestor(ObjH, 'figure');
delete(OrigDlgH);
GUI_srp;
end

function removeSideMenu(insertPos)
myhandles = guidata(gcbo);
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
guidata(gcf,myhandles);
end

% Adds the Independent variable box to side menu
function indVar(hObject,eventdata)
myhandles = guidata(gcbo);
css = myhandles.css;
objs = myhandles.objs;
vars = myhandles.vars;

% insert after the independent variable selection box
insertPos = find(strcmp(objs.active,'indselect')) + 1;
removeSideMenu(insertPos); % remove all side boxes
N = length(objs.active); % Get number of sideboxes

if eventdata.Source.Value ~= 1 % Selection is not the none option
    %%%% Insert box at insertPos
    if isempty(find(strcmp(objs.active,'indvar'), 1)) 
        % if indvar box doesn't already exist
        for bb = fliplr(insertPos:N) % Move each box down one
            objs.active{bb+1} = objs.active{bb};
        end
    end
    objs.active{insertPos} = 'indvar';
    
    varboxPos = find(strcmp(objs.boxTitles,'varlist'), 1);
    % Redefine variables list BOX
    objs.box{varboxPos} = objs.varbox;

    which = eventdata.Source.Value-1;
    % Remove indpendent variable from variable list box
    objs.box{varboxPos}.N = objs.box{varboxPos}.N - 1;
    objs.box{varboxPos}.label(which) = [];
    objs.box{varboxPos}.type(which) = [];
    objs.box{varboxPos}.string(which) = [];
    objs.box{varboxPos}.callback(which) = [];
    
    % Load in Box values
    objs.indvarbox.string = objs.indvarbox.select{which};
    indvarboxPos = find(strcmp(objs.boxTitles,'indvar'), 1);
    objs.box{indvarboxPos} = objs.indvarbox;
    objs.box{indvarboxPos}.units = objs.indvarbox.units{which};
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
        units = objs.indvarbox.units{nn};
        val = find(strcmp(objs.varbox.string{nn},[vars.value{nn},units]));
        objs.box{varboxPos}.itemhandle{ii}.Value = val;
    end
    
else % None is chosen as independent variable
    if ~isempty(find(strcmp(objs.active,'indvar'), 1)) % indvar box exists
        objs.active{insertPos} = [];
        for bb = insertPos:(N-1) % Move each box up one
            objs.active{bb} = objs.active{bb+1};
        end
        objs.active(N) = [];
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

% Function to load the fig file and plot
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
    vars.value{popupmenulist(nn)} = replace(varlist.itemhandle{nn}.String{varlist.itemhandle{nn}.Value},objs.indvarbox.units,'');
end

myhandles.vars = vars; % Variables for the simulation
myhandles.css = css;
myhandles.objs = objs;
guidata(gcf,myhandles);
end

function loadArray(hObject,eventdata)
storVars;

myhandles = guidata(gcbo);
css = myhandles.css;
objs = myhandles.objs;
vars = myhandles.vars;

platnum = str2num(objs.box{2}.itemhandle{2}.String{objs.box{2}.itemhandle{2}.Value});
if objs.box{2}.itemhandle{8}.Value == 1
        % Define group of microphone platforms
        vars.platformGroup = Platform([0 0 1.5],platnum,0.5);
        [mjs_X, mjs_Y, mjs_Z] = vars.platformGroup.getMics();
        vars.pcs = [mjs_X, mjs_Y, mjs_Z]; % Center points of arrays
        vars.setup = 'EQUIDISTANT';
elseif  objs.box{2}.itemhandle{8}.Value == 2
    [X,Y] = getLocs(vars.froom,platnum,'Platform Center(s) in FROOM');
    vars.pcs = [X,Y,ones(platnum,1).*1.5];
    vars.setup = 'CHOSEN';
elseif  objs.box{2}.itemhandle{8}.Value == 3
    X = rand(platnum,1)*abs(vars.froom(1,2)-vars.froom(1,1))+vars.froom(1,1);
    Y = rand(platnum,1)*abs(vars.froom(2,2)-vars.froom(2,1))+vars.froom(2,1);
    vars.pcs = [X,Y,ones(platnum,1).*1.5];
    vars.setup = 'MONTE';
end

removeSideMenu(1);

% Redraw boxes for simulation
css.adj = 0;
css.boxTop = css.sideMenuTop;
objs.active = {'output','srpsim','aftersrp','guiopts'};
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

% Fullscreen GUI
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
        currBox.labels{ll}.HorizontalAlignment = 'Left'; 
        currBox.labels{ll}.FontWeight = 'bold';
        currBox.labels{ll}.FontSize = 8; 
        currBox.labels{ll}.FontName = 'KaiTi';
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
        currBox.labels{ll}.HorizontalAlignment = 'Left'; 
        currBox.labels{ll}.FontWeight = 'bold';
        currBox.labels{ll}.FontSize = 8; 
        currBox.labels{ll}.FontName = 'KaiTi';
        ll = ll + 1;
        
        units = objs.indvarbox.units{itemID};
        currBox.itemhandle{itemID} = uicontrol('Style','slider',...
            'min',str2double(replace(currBox.string{itemID}{1},units,'')),...
            'Value',str2double(replace(currBox.string{itemID}{1},units,'')),...
            'max',str2double(replace(currBox.string{itemID}{end},units,'')),...
            'Position',[160 css.boxTop-css.itemOffset*(itemID-1) 100 20]);
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

function errorAnalysis(hObject,eventdata)
myhandles = guidata(gcbo);
objs = myhandles.objs;
vars = myhandles.vars;

%%%% IMAGE ANALYSIS
[SNRdB,avgnoise,peakSourcePower] = imErrorAnalysis(myhandles.im,vars.gridax,vars.sigpos,8);
% win_errs(ww,:) = [SNRdB,avgnoise,peakSourcePower];
            
disp(SNRdB);
disp(avgnoise);
disp(peakSourcePower);

myhandles.vars = vars;
myhandles.objs = objs;
guidata(gcf,myhandles);
end


% EXTRA EXAMPLE
% Permutates the Order of the side menu boxes
function randomSideMenu(hObject,eventdata)
myhandles = guidata(gcbo);
css = myhandles.css;
objs = myhandles.objs;
eventdata.Source.Tag; % Which sideMenu popupbox
eventdata.Source.String{eventdata.Source.Value}; % option selected

% delete all side menu boxes
for rr = 1:length(objs.box)
    delete(objs.box{rr}.rect);
    for dd = 1:objs.box{rr}.N
        delete(objs.box{rr}.itemhandle{dd});
    end
    for ll = 1:length(objs.box{rr}.labels)
        delete(objs.box{rr}.labels{ll});
    end
end

css.adj = 0;
css.boxTop = css.sideMenuTop;
for ss = randperm(length(objs.box))
    [css, objs] = loadBox(css,objs,ss);
end

myhandles.css = css;
myhandles.objs = objs;
guidata(gcf,myhandles);
end


%% Function to setup a SRP simulation from GUI
function setupSim(hObject,eventdata) 
myhandles = guidata(gcbo);
objs = myhandles.objs;
css = myhandles.css;
vars = myhandles.vars;

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

% Upgrade defaults with user inputs
mjs_N = str2num(vars.value{1});
mjs_platnum = str2num(vars.value{2});
dist2center = str2num(vars.value{3});
mjs_angle = str2num(vars.value{4});
mic2micLength = str2num(vars.value{5});
source = vars.value{6}; 
sourcesetup = vars.value{7};
platsetup = vars.value{8};
cameraAngle = 2;
N = 1;
if strcmp(vars.setup,'EQUIDISTANT')
    mjs_platformGroup = vars.platformGroup;
end
mjs_pcs = vars.pcs;

    
% Dependent Declarations
micnum = mjs_platnum*mjs_N;  %  Number of mics in array to be tested
% mic2micLength = sin(pi/mjs_N)*mjs_radius*2; % distance between two adjacent microphones
mjs_radius = mic2micLength/(200*sin(pi/mjs_N));

waitDialog = waitbar(0,'Running Simulation');
errs = zeros(N*N,5);
%%%% EXPERIMENT LOOP
% for bb = 1:N % iterate through distance to center
bb = 1;

    % Set Independent Variable for test
%     angles = linspace(0,pi/2,N); % variable angles
    angles = ones(1,N).*mjs_angle; % constant radii
    radii = ones(1,N)*mjs_radius; % constant radii

    % Precompute half angles
    mjs_cos2 = cos(mjs_angle/2); mjs_sin2 = sin(mjs_angle/2);

    % Define Platforms
    for pp = 1:mjs_platnum % loop for identical platforms
        mjs_platform(pp) = Platform(mjs_pcs(pp,:),mjs_N,radii(1));
        % vector from each mic center to source location
        mjs_pl2src(pp,:) = vars.sigpos-mjs_pcs(pp,:)';
        mjs_pltheta(pp) = atan2(mjs_pl2src(pp,2),mjs_pl2src(pp,1));
        % tangential planar vector for rotation
        mjs_pltan2src(pp,:) = cross(mjs_pl2src(pp,:),[0 0 1]);
        % z axis rotations to orient endfire to source;
        mjs_platform(pp).eulOrient(mjs_pltheta(pp),0); 
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     for aa = 1:N % iterate through angles
aa = 1;
        fprintf('Angle is %d degrees : ', angles(aa)/pi*180);
        for pp = 1:mjs_platnum
        	mjs_platform(pp).eulOrient(mjs_pltheta(pp),mjs_angle); 
        end
        if aa ~= 1
            for pp = 1:mjs_platnum
                mjs_platform(pp).eulOrient(mjs_pltheta(pp),angles(aa)); 
            end
        end
        mposplat = zeros(3,micnum);

% Add microphone coordinates to mic position matrix
        for pp = 1:mjs_platnum
            [mjs_X, mjs_Y, mjs_Z] = mjs_platform(pp).getMics();
            mposplat(:,(pp-1)*mjs_N+(1:mjs_N)) = [mjs_X, mjs_Y, mjs_Z]'; % Set mic coordinates
        end
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find max distance (delay) over all mic pairs; this represents an upper bound
% on all required relative delays when scanning over the FOV
        [rm, nm] = size(mposplat);
        prs = mposanaly(mposplat,2);

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
                target = randn(vars.fs,1);
                target = 10^(-3/20)*(target./max(target));
        end

% Random generation of signal position within FOV
%         vars.sigpos = ((fov(:,2)-fov(:,1))*ones(1,sigtot)).*rand(3,sigtot) + fov(:,1)*ones(1,sigtot);
% Compute array signals from target
        [sigoutper, taxper] = simarraysigim(target, vars.fs, vars.sigpos, mposplat, vars.froom, vars.bs, vars.prop);
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
        [nosoutper, taxnosper] = simarraysigim(onos,vars.fs, sigposn, mposplat, vars.froom, vars.bs, vars.prop);

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

% Matrix to store SNRdB, db(peakSourcePower) and db(avgnoise) for each
% window iteration
        win_errs = zeros(N,3);        
        
        %  Set up figure for plotting
%%%% SRP Window
        for ww = 1:N
% Random window in 1 second
            rpper = vars.winlen+round((length(target)-2*vars.winlen)*rand(1));
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
            fprintf(' Window starts at %d seconds \n', sst/vars.fs);
            tapwin = flattap(sed-sst+1,20);  %  One dimensional
            wintap = tapwin*ones(1,micnum);  %  Extend to matrix covering all channels
% Whiten signal (apply PHAT, with beta factor given at the begining)
            sigout = whiten(sigoutpera(sst:sed,:).*wintap, vars.batar);
% Create SRP Image from processed perimeter array signals
waitbar(.50,waitDialog,'Running SRP image');
            myhandles.im = srpframenn(sigout, vars.gridax, mposplat, vars.fs, vars.prop.c, vars.trez);
            
            waitbar(.75,waitDialog,'Plotting SRP image');
            
            figure(myhandles.mainfig);
            zoffset = 1.5;
            myhandles.implot = surf(vars.gridax{1},vars.gridax{2}, myhandles.im);
            peakVal = max(max(myhandles.im));
            colormap(jet); colorbar; axis('xy');
            axis([vars.froom(1,1)-.25, vars.froom(1,2)+.25, vars.froom(2,1)-.25, vars.froom(2,2)+.25]);
            hold on;
%  Mark coherenet noise positions
% plot(sigposn(1,:),sigposn(2,:),'xb','MarkerSize', 18,'LineWidth', 2);  %  Coherent noise
%  Mark actual target positions  
            myhandles.sourceplot = plot3(vars.sigpos(1,:),vars.sigpos(2,:),ones(vars.sigtot)*peakVal,'ok', 'MarkerSize', 18,'LineWidth', 2);
%  Mark microphone positions
%plot(mposperim(1,:),mposperim(2,:),'sr','MarkerSize', 12);
            myhandles.micplot = plot3(mposplat(1,:),mposplat(2,:),mposplat(3,:),'sr','MarkerSize', 12);
            axis('tight');
%  Number them
%for kn=1:length(mposperim(1,:))
%    text(mposperim(1,kn),mposperim(2,kn), int2str(kn), 'HorizontalAlignment', 'center')
%end
for iii = 1:mjs_platnum % Label Platform numbers
    mjs_loc = mjs_platform(iii).getCenter();
    myhandles.platlabs{iii} = text(mjs_loc(1),mjs_loc(2)+0.5,mjs_loc(3), ['Pl', int2str(iii)], 'HorizontalAlignment', 'center');
end

for kn=1:length(mposplat(1,:)) % Label microphones
    myhandles.miclabs{kn} = text(mposplat(1,kn),mposplat(2,kn),mposplat(3,kn), int2str(kn), 'HorizontalAlignment', 'center');
end

%  Draw Room walls
plot([vars.vn(1,:), vars.vn(1,1)],[vars.vn(2,:), vars.vn(2,1)],'k--')
% Label Plot
view(cameraAngle);
xlabel('Xaxis Meters')
ylabel('Yaxis Meters')
title({['SRP image (Mics at squares,'],[' Target in circle, Noise sources at Xs']} )
hold off

close(waitDialog);
%%%% IMAGE ANALYSIS
            [SNRdB,avgnoise,peakSourcePower] = imErrorAnalysis(myhandles.im,vars.gridax,vars.sigpos,8);
            win_errs(ww,:) = [SNRdB,avgnoise,peakSourcePower];
        end
        SNRdB = mean(win_errs(:,1));
        avgnoise = mean(win_errs(:,2));
        peakSourcePower = mean(win_errs(:,3));

% Error matrix
        errs(N*(bb-1)+aa,:) = [angles(aa), dist2center(bb),SNRdB,db(avgnoise),db(peakSourcePower)];

%     end % END of aa loop
    
    endfireError(bb) = errs(N*(bb-1)+1,3);
    broadsideError(bb) = errs(N*(bb-1)+N,3);
% end % END of bb loop

% clear('h','h2','h3');
% save('error2.mat','errs','endfireError','broadsideError','dist2center',...
%     'N','N','mjs_platnum','mjs_N','mjs_radius');

% % Plot the Errors
% %%%% Experimental Results
% bb = 1:(N);
% metricID = 2; % 1 is SNRdB, 2 is meanNoisedB and 3 is dBpeakPower
% errLabels = {'SNR dB of SRP image','Mean Noise in dB', 'Peak Power at Source in dB'};
% scatter(dist2center(bb),errs(N*(bb-1)+1,metricID+2),'ok'); hold on;
% scatter(dist2center(bb),errs(N*(bb-1)+N,metricID+2),'+r'); hold off;
% xlabel('distance to source [m]');
% % ylabel(errLabels{metricID}); xlim([dist2center(1) dist2center(end)]);
% title({[errLabels{metricID} ' vs. distance to source for rotating platforms'],...
%     ['number of Platforms: ', num2str(mjs_platnum), ', Microphones per Platform: ', num2str(mjs_N)],...
%     ['Radii of Platforms: ', num2str(mjs_radius*100),' [cm], Angle discretization: ', num2str(N) ]}, 'FontSize', 11);
% legend('endfire','broadside');

myhandles.vars = vars;
myhandles.css = css;
myhandles.objs = objs;
guidata(gcf,myhandles);
end

