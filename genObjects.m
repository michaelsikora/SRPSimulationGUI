function objs = genObjects(css,mainWin)
% GENOBJECTS Define graphic objects in objs struct
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

end

