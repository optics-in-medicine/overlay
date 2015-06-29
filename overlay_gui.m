function varargout = overlay_gui(varargin)
% OVERLAY_GUI M-file for overlay_gui.fig
%       
%          #######  ##     ## ######## ########  ##          ###    ##    ##     ######   ##     ## #### 
%         ##     ## ##     ## ##       ##     ## ##         ## ##    ##  ##     ##    ##  ##     ##  ##  
%         ##     ## ##     ## ##       ##     ## ##        ##   ##    ####      ##        ##     ##  ##  
%         ##     ## ##     ## ######   ########  ##       ##     ##    ##       ##   #### ##     ##  ##  
%         ##     ##  ##   ##  ##       ##   ##   ##       #########    ##       ##    ##  ##     ##  ##  
%         ##     ##   ## ##   ##       ##    ##  ##       ##     ##    ##       ##    ##  ##     ##  ##  
%          #######     ###    ######## ##     ## ######## ##     ##    ##        ######    #######  ####
%
%       OVERLAY_GUI - The MATLAB GUI enabling overlaying of fluorescence
%        or molecular imaging maps on white-light imaging for
%        intraoperative knowledge transfer, with a focus on understanding
%        and minimizing interpretive errors.
%              
%        Author: Jonathan T. Elliott, Ph.D.  <jte@dartmouth.edu>
%
%      OVERLAY_GUI, by itself, creates a new OVERLAY_GUI or raises the existing
%      singleton*.
%
%      H = OVERLAY_GUI returns the handle to a new OVERLAY_GUI or the handle to
%      the existing singleton*.
%
%      OVERLAY_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OVERLAY_GUI.M with the given input arguments.
%
%      OVERLAY_GUI('Property','Value',...) creates a new OVERLAY_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before overlay_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to overlay_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% List of known bugs:
% - after switching bottom image to grayscale, you cannot modify window
% andlevel.

% Edit the above text to modify the response to help overlay_gui

% Last Modified by GUIDE v2.5 19-Jun-2015 09:33:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @overlay_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @overlay_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before overlay_gui is made visible.
function overlay_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to overlay_gui (see VARARGIN)

% Display Logo
I = imread('OverlayLogo.png');
imshow(I,'parent',handles.axes5);

% Choose default command line output for overlay_gui
handles.output = hObject;

% turn off the axis labels on all axes objects.
axes(handles.axes1); axis off;                              
axes(handles.axes2); axis off;
axes(handles.axes3); axis off;
axes(handles.axes4); axis off;
update_labels(hObject, handles);
% initialize flags.
handles.top_flag = 0;
handles.bot_flag = 0;
handles.gray_flag = 0;

% set default data filepath.
mfile_path = mfilename('fullpath');
cd( mfile_path(1:end-11) )
% load default colormap and also store as secondary for uniform colormaps.

cmap_data = load([mfile_path(1:end-11)  filesep 'colormap_data.mat']);

% handles.cmap = dlmread([mfile_path(1:end-11) '\colormaps\parula_cmap.txt']);
handles.cmap_matrix = cmap_data.cmap_matrix;
handles.cmap = handles.cmap_matrix{3};
handles.alt_cmap = handles.cmap;
handles.div_cmap = handles.cmap_matrix{17};

% load lists and paths of all the colormaps allowed
handles.colormaps = cmap_data.colormaps;
% handles.colormaps = {'SEQUENTIAL', 'Parula (matlab)', 'Parula (bio-friendly)', 'cube1 (myCarta)', 'hot (JTE)', 'cubeYF (myCarta)', 'Linear_L (myCarta)', 'Seashore (colormap.org)', ...
%                                    'Greens',  'Purples', 'Dawn', 'Kryptonite', ...
%                      'MONOCHROME',  'Green (uniform)', 'Teal (uniform)', 'Red (uniform)', ...
%                      'DIVERGING', 'Fire and Ice', 'Paraview', 'Blue Green Plateau (JTE)', 'Parrot (static)', 'Parrot (dynamic)' };

handles.map_paths = cmap_data.map_paths;
% handles.map_paths = {'', 'parula_cmap.txt', 'bio_parula.txt', 'cube1.txt', 'hot.txt', 'cubeYF.txt', 'Linear_L.txt', 'seashore.txt', ...
%                      'greens.txt', 'purples.txt', 'dawn.txt', 'kryptonite.txt', ...
%                      '', 'uni_green.txt' 'uni_teal.txt', 'uni_red.txt', ...
%                      '', 'coldhot.txt', 'paraview.txt', 'bluegreenplat.txt', 'parrot.txt', 'dynamic'};
%                  

handles.PathName =  [mfile_path(1:end-11)  filesep 'test_files'  filesep ];
% handles.PathName =  'X:\#5 - Data\# Pearl dual tracer AIF mice\IRDye680nc and IRDye800_antiEGF\Mouse 4  with U251 Tumor\Mouse 4  with U251 Tumor\';
% consider preloading these into a matrix and also loading the matlab
% built-in colormaps.

guidata(hObject, handles);                                                  % update the handles structure.

set(handles.popupmenu1, 'String', handles.colormaps);                       % populate the popup menu with colormap titles.
set(handles.popupmenu1, 'Value', 3);
guidata(hObject, handles);                                                  % Update handles structure

% UIWAIT makes overlay_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = overlay_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- WINDOW BOTTOM IMAGE
% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);                                                  % Update handles structure
update_images(hObject, handles);                                            % Update the four axes.
update_labels(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- LEVEL BOTTOM IMAGE
% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);                                                  % Update handles structure
update_images(hObject, handles);                                            % Update the four axes.
update_labels(hObject, handles);
% disp(num2str( get( handles.slider2, 'Value' ), '%3.2f' ));

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- WINDOW TOP IMAGE
% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);                                                  % Update handles structure
update_images(hObject, handles);                                            % Update the four axes.
update_labels(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- LEVEL TOP IMAGE.
% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);                                                  % Update handles structure
update_images(hObject, handles);                                            % Update the four axes.
update_labels(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- SET TRANSPARENCY UPPER LIMIT.
% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);                                                  % Update handles structure
update_images(hObject, handles);                                            % Update the four axes.
update_labels(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- SET TRANSPARENCY SLOPE
% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);                                                  % Update handles structure
update_images(hObject, handles);                                            % Update the four axes.
update_labels(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- SET TRANSPARENCY CENTER OF CURVE
% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if the dynamic diverging colormap is selected, then update when x0
% changes.
if strcmp( handles.map_paths{ get(handles.popupmenu1, 'Value') }, 'dynamic')
    handles.cmap = dynamic_cmap( get( hObject, 'Value' ) );
end

guidata(hObject, handles);                                                  % Update handles structure
update_images(hObject, handles);                                            % Update the four axes.
update_labels(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- COLORMAP SELECTION UI.
% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if user selects a category header, it defaults to the first colormap in
% that category.
if strcmp( handles.map_paths{ get(hObject, 'Value') }, '')
    set(hObject, 'Value', get(hObject, 'Value') + 1);                       % set the popup menu selection + 1;
end



guidata(hObject, handles);                                                  % Update handles structure
update_images(hObject, handles);                                            % Update the four axes.

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- PLOT THE INFORMATION ABOUT COLORMAP IN SEPARATE WINDOW.
function plot_Lstar_Callback(hObject, eventdata, handles)
% hObject    handle to plot_Lstar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

x_255 = linspace(0,1,256);
M = [ 0.5767309  0.1855540  0.1881852;                                      % operator between xyz and rgb.
      0.2973769  0.6273491  0.0752741;
      0.0270343  0.0706872  0.9911085];

xyz = handles.cmap * M;                                                     % calculate xyz .
Lstar = real ( ( (25.29 .* xyz(:,2) .^ 0.3333 - 18.38) )./100 );            % caluculate L_star from xyz space.

Lstar_n = ( Lstar - min(Lstar) ) ./ (max(Lstar) - min(Lstar));

h = figure('color','white');                                                % launch new figure window.

% plot colorbar with name of colormap.
subplot(5,2,[1 2])                                                          
I = repmat(x_255./256,[20 1]);
pcolor(I); shading flat; 
colormap(handles.cmap ./ 255);
axis image; set(gca,'YTickLabel',[]);
set(gca,'XTickLabel',[]); 
title( handles.colormaps(get(handles.popupmenu1,'Value')) )

% plot the RGB and L* data as larger subplot.
subplot(5,2,[3 5 7 9])                                                      
plot(x_255, handles.cmap(:,1)./255,   'Color', [1 0 0], 'LineWidth', 1.5);
hold on
plot(x_255, handles.cmap(:,2)./255,   'Color', [0.1 1 0.1], 'LineWidth', 1.5);
plot(x_255, handles.cmap(:,3)./255,   'Color', [0 0 1], 'LineWidth', 1.5);
plot(x_255, Lstar_n,  'Color', [0.1 0.1 0.1], 'LineWidth', 2);
hold off;

title('R, G, B and L*');
ylim([0 1]); xlim([0 1]); grid on
xlabel('Parameter value');
ylabel('Intensity');

% plot the pyramid test for continuity.
subplot(5, 2, [4 6 8 10])
[X,Y,GIZA] = gen_pyramid;
surf(X,Y,GIZA,GIZA,'FaceColor','interp','EdgeColor','none');
view(-35,70);
colormap(handles.cmap ./ 255);
axis off;
grid off;

set(h, 'menubar', 'none');                                                  % hide menubar for cleaner look.

    

% --- UIGETFILE TO LOAD TOP IMAGE
% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%loads images into data structure.
handles.data.I1 = get_image(hObject, handles);
handles.data.I_top = handles.data.I1;

% Update handles structure
guidata(hObject, handles);

update_images(hObject, handles);

% --- UIGETFILE TO LOAD BOTTOM IMAGE.
% --------------------------------------------------------------------
function bottom_im_Callback(hObject, eventdata, handles)
% hObject    handle to bottom_im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%loads images into data structure.
[handles.data.I1, handles.PathName, imstat] = get_image(hObject, handles);

if imstat
    [rows cols channels] = size(handles.data.I1);
    set(handles.checkbox4, 'Enable', 'on');

    if channels ~= 3                                                        % If it isn't RGB, then convert to RGB.
        % show sliders
        set(handles.slider1, 'Enable', 'on');
        set(handles.slider2, 'Enable', 'on');
        
        handles.gray_flag = 0;
        set(handles.checkbox4, 'Enable', 'off');
        handles.data.I_bot = zeros(size(handles.data.I1));
        handles.gray_flag = 1;handles.just_flagged = 1;
        
%         handles.data.I_bot = repmat(uint8(fix(255 .* handles.data.I1)), [1 1 3]);
        
        for i = 1:3
            handles.data.I_bot(:,:,i) = histeq( handles.data.I1 ./ (4 * median(handles.data.I1(:))) );
        end

        handles.data.I1 = handles.data.I_bot;
    else
        % hide sliders
        set(handles.slider1, 'Enable', 'off');
        set(handles.slider2, 'Enable', 'off');
    end

    handles.bot_flag = 1;
    % Update handles structure
    guidata(hObject, handles);

    handles = update_images(hObject, handles);
    handles.PathName
end

% --------------------------------------------------------------------
function top_im_Callback(hObject, eventdata, handles)
% hObject    handle to top_im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.data.I2, handles.PathName, imstat] = get_image(hObject, handles);
if imstat
    handles.data.I_top = handles.data.I2;
    handles.top_flag = 1;

    % auto-set the level to the median value of the image. 
    slide_set = ( median(handles.data.I2(:)) - min(handles.data.I2(:)) ) ./ (max(handles.data.I2(:)) - min(handles.data.I2(:)));
    set(handles.slider4, 'Value', slide_set);

    % Update handles structure
    guidata(hObject, handles);

    handles =update_images(hObject, handles);
end
% --------------------------------------------------------------------
function view_menu_Callback(hObject, eventdata, handles)
% hObject    handle to view_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% loads multiple imaging data types into the container.
function [I, PathName, imstat] = get_image(hObject, handles)
image_types = {'Matlab Datafile (.mat)', 'Pearl 22-bit (.tiff)', 'Typhoon (.gel)', 'Zeiss HIS (.tiff)', 'Zeiss JPEG (.jpg)', 'MRI DICOM', 'Other Image Format', 'DHMC FGR structure'};
image_ext = {'.mat','.TIF','.gel','.tiff','*.jpg', '*.*', '*.*', '*.mat'};
[s,v] = listdlg('PromptString','Choose Image Type:', 'SelectionMode','single','ListString', image_types);

if v
    [FileName,PathName, filterIndex] = uigetfile(image_ext{s}, 'Open ...', handles.PathName);
    if filterIndex ~= 0
        handles.PathName = PathName;
        guidata(hObject, handles);
        handles.PathName
        switch s
            case {4, 5, 7}
                I = imread([PathName FileName]);    
            case {2, 3}
                I_bf = bfopen([PathName FileName]);
                I = double( I_bf{1}{1} );
            case 6
                %dicom reader
            case 1
                data_in = load([PathName FileName]);
                var_names = fieldnames( data_in );
                [s1, v1] = listdlg('PromptString','Select variable:', 'SelectionMode','single','ListString', var_names);
                I = data_in.( var_names{s1} );
    %             var_choice = strcat('data_in.', var_names(s1));
    %             eval( strcat('I = data_in.', var_names(s1), ';') );
            case 8
                data_in = load([PathName FileName]);
                var_names = fieldnames( data_in );
                [s1, v1] = listdlg('PromptString','Select variable:', 'SelectionMode','single','ListString', var_names);
                I = data_in.( var_names{s1} );
                [X, Y, Z] = size(I);

                if Z ~= 3
                    I_t = I;
                    clear I;
                    imn = 1;
                    if Z ~= 1
                        imn = inputdlg(['Which image in this series of ' int2str(Z) ' would you like?']);
                    end
                    I = squeeze( I_t(:,:,imn) );
                end
        end
        imstat = 1;
    else
        imstat = 0; I = []; PathName = [];
    end
else
    imstat = 0; I = []; PathName = [];
end
guidata(hObject, handles);


function handles = update_images(hObject, handles)
%% UPDATE IMAGE FUNCTION
% update colorbar

if get( handles.radiobutton4, 'Value')
    % load either dynamic (changes point of max L* with where the x0
    % transparency parameter is placed.
    if strcmp( handles.map_paths{ get(handles.popupmenu1, 'Value') }, 'dynamic')
        handles.cmap = dynamic_cmap( get( handles.slider7, 'Value' ) );         % call dynamic_cmap function.
    else
    %     handles.cmap = dlmread( ['colormaps\' handles.map_paths{ get(hObject,'Value')} ] );
        handles.cmap = handles.cmap_matrix{ get(handles.popupmenu1,'Value') };             % load the 256 x 3 cmap from handles.cmap_matrix.
    end
    
elseif get( handles.radiobutton5, 'Value')
    %
        r = str2double( get( handles.edit1, 'String') );
        g = str2double( get( handles.edit2, 'String') );
        b = str2double( get( handles.edit3, 'String') );
        handles.cmap = repmat([r g b], 256, 1);
end
   

% gather all the parameters.
handles.p.win_1 = get( handles.slider1, 'Value');
handles.p.lvl_1 = get( handles.slider2, 'Value');

handles.p.win_2 = get( handles.slider3, 'Value');
handles.p.lvl_2 = get( handles.slider4, 'Value');

handles.p.L = get( handles.slider5, 'Value' );
handles.p.k = get( handles.slider6, 'Value' );
handles.p.x0 = get( handles.slider7, 'Value' );

if get(handles.radiobutton11, 'Value'); handles.p.f = 'uni';
elseif get(handles.radiobutton10, 'Value'); handles.p.f = 'lin';
elseif get(handles.radiobutton9,'Value'); handles.p.f = 'power';
else handles.p.f = 'logistic';
end

handles.p.sm = fix( get( handles.slider8, 'Value' ) );

% update image containers
disp(num2str( get( handles.checkbox2,'Value' ), '%3.2f' ));
if handles.bot_flag
    
    % activate menu items.
    set(handles.cie_space, 'Enable', 'on');
    
    [rows, cols, chans] = size( handles.data.I1 )
    if chans == 1
        if get(handles.checkbox2,'Value') == 1
            % does it make more sene to log compress before or after windowing
            % and leveling?
            I1_cmp = log_compress(handles.data.I1 , 255);

            handles.data.I_bot = mywinlvl( I1_cmp, handles.p.win_1, handles.p.lvl_1, 16 );
            handles.p.win_1;
        else
            handles.data.I_bot = mywinlvl( handles.data.I1, handles.p.win_1, handles.p.lvl_1, 16 );
        end
        
    elseif chans == 3                                                       % if rgb image
        if handles.gray_flag
            I_gray = ( rgb2gray( handles.data.I1 )  );
           
            if handles.just_flagged
                slide_set = ( median(I_gray(:)) - min(I_gray(:)) ) ./ ...             % auto-set the level to the median value of the image.
                    (max(I_gray(:)) - min(I_gray(:)));
                set(handles.slider2, 'Value', slide_set)

                handles.p.lvl_1 = get( handles.slider2, 'Value');
                handles.just_flagged = 0;
            end
            
            % convert the grayscale image to rgb.
            handles.data.I_bot = repmat(uint8(fix( 255 .* mywinlvl( I_gray, handles.p.win_1, handles.p.lvl_1, 'double' ))),[1 1 3]);
                 
        else
           handles.data.I_bot = handles.data.I1;
        end
        
    end
    
    axes(handles.axes1);                                                    % plot bottom image.
    image(handles.data.I_bot); axis image; axis off; freezeColors;
    
end

if handles.top_flag
    if get(handles.checkbox3,'Value') == 1                                  % toggle between log compression and linear.
        I2_cmp = log_compress(handles.data.I2 , 255);                       % apply window and leveling specified by user.
        handles.data.I_top = mywinlvl( I2_cmp, handles.p.win_2, ...
            handles.p.lvl_2, 16 );
    else
        handles.data.I_top = mywinlvl( handles.data.I2, ...                 % apply window and leveling specified by user.
            handles.p.win_2, handles.p.lvl_2, 16 );
    end
    
    axes(handles.axes2)
    SM = floor( get( handles.slider8, 'Value' ) );                          % plot top image.
    if SM ~=0
        pcolor(flipud( medfilt2( handles.data.I_top, [SM SM] ) ) ); shading flat;
    else
        % plot top image.
        pcolor(flipud( handles.data.I_top )); shading flat; 
    end
    
    axis image; axis off;
    
    if ~get( handles.radiobutton4, 'Value')                                % if monochrome colormap, use alternate colormap for inset image.
        colormap( handles.alt_cmap ./ 255 );
    else
        colormap( handles.cmap ./ 255 );
    end
    freezeColors;
    
    if ~handles.bot_flag                                                    % if no bottom image, then overlay on array of ones.
        handles.data.I_bot = ones( [size(handles.data.I_top) 3] );
        handles.bot_flag = 1;
    end
end

if (handles.bot_flag && handles.top_flag)                                   % do if both images have been loaded.
%     set(handles.colorblind, 'Enable','on');                               % will have to wait until future releases
    SM = floor( get( handles.slider8, 'Value' ) );                          % plot top image.
    if SM ~=0
        new_rgb = get_cust_pcolor(  medfilt2( handles.data.I_top, [SM SM] ), handles.cmap );
    else
        new_rgb = get_cust_pcolor( handles.data.I_top, handles.cmap );      % get the RGB representation of the colormap.
    end
    
    
    % first, plot bottom image.
    axes(handles.axes3); 
    imagesc(handles.data.I_bot); 
    axis image; axis off;
    
    if ( get( handles.radiobutton4, 'Value') || ...
            get( handles.radiobutton5, 'Value' ) )                          % execute if Multivariate or Monochrome are selected.
        
        % then, plot top image.
        hold on; 
        imh = image( new_rgb ); 
        hold off;

        x_plot = linspace(0,1,100);

        % determine the transparency function.
        if get(handles.radiobutton11, 'Value')                              % uniform transparency
            alpha = ones( size( handles.data.I_top ) ) .* handles.p.L;
            a_plot = ones(1,100) .* handles.p.L;
            
        elseif get(handles.radiobutton10, 'Value')                          % linear transparency
            I_pn = ( handles.data.I_top - min( handles.data.I_top(:) ) ) ./ ...
                (max( handles.data.I_top(:) ) - min( handles.data.I_top(:) ));
            alpha = getAlphaLUT(I_pn, handles.p.k, 1, handles.p.x0, 'lin');
            a_plot = getAlphaLUT(x_plot, handles.p.k, 1, handles.p.x0, 'lin');
            
        elseif get(handles.radiobutton9,'Value')                            % power transparency
            I_pn = ( handles.data.I_top - min( handles.data.I_top(:) ) ) ./ ...
                (max( handles.data.I_top(:) ) - min( handles.data.I_top(:) ));
            alpha = getAlphaLUT(I_pn, handles.p.L, handles.p.k * 0.5, handles.p.x0, handles.p.f);
            a_plot = getAlphaLUT(x_plot, handles.p.L, handles.p.k * 0.5, handles.p.x0, handles.p.f);
                
        else                                                                % logistic 
            I_pn = ( handles.data.I_top - min( handles.data.I_top(:) ) ) ./ ...
                (max( handles.data.I_top(:) ) - min( handles.data.I_top(:) ));
            alpha = getAlphaLUT(I_pn, handles.p.L, handles.p.k * 5, handles.p.x0, handles.p.f);
            a_plot = getAlphaLUT(x_plot, handles.p.L, handles.p.k * 5, handles.p.x0, handles.p.f);
            
        end

        set(imh, 'AlphaData', alpha);                                           % set transparency to the top image.

        % create a blended picture which is suitable for output.
        [x1,y1,z1] = size(handles.data.I_bot);
        if z1 == 1
            temp_bot(:,:,1) = handles.data.I_bot;
            temp_bot(:,:,2) = handles.data.I_bot;
            temp_bot(:,:,3) = handles.data.I_bot;
        else
            temp_bot = handles.data.I_bot;
        end

        for i = 1:3
%             if strcmpi(class( handles.data.I_bot ), 'uint8')
%                 I_bot = double( temp_bot(:,:,i) ./ 255 );
%             else
                I_bot = double( temp_bot(:,:,i) ./ max(max(squeeze( temp_bot(:,:,i))) ));
%             end
            handles.I_rgb = double( new_rgb(:,:,i) );
            I_blend =  ( handles.I_rgb .* alpha )  + ( I_bot .* (1 - double( alpha )));

            handles.data.blend(:,:,i) = I_blend;
            clear I_blend
        end

        if get( handles.radiobutton5, 'Value')   
        else
            cb = colorbar;
            c_l(1) = ( ( handles.p.lvl_2 - handles.p.win_2 / 2 ) * (max(handles.data.I2(:)) - min( handles.data.I2(:) )) ) + min( handles.data.I2(:) );
            c_l(2) = ( ( handles.p.lvl_2 + handles.p.win_2 / 2 ) * (max(handles.data.I2(:)) - min( handles.data.I2(:) )) ) + min( handles.data.I2(:) );

%             if get(handles.checkbox1, 'Value')
                set( cb, 'YTickLabel', gen_clabel(c_l, 11, get(handles.checkbox3,'Value')) );
%             else
%                 set( cb, 'YTickLabel', gen_clabel(c_l, 11, get(handles.checkbox3,'Value')) );
%             end       
        end

        % plot transparency function
        axes(handles.axes4);
        plot(x_plot, a_plot);
        xlim([0 1]); xlabel('Norm. Param.');
        ylim([0 1]); ylabel('Opacity');grid on;

    elseif get( handles.radiobutton6, 'Value')                              % point cloud instead of colormap overlay
        r = str2double( get( handles.edit1, 'String') ) / 255;
        g = str2double( get( handles.edit2, 'String') ) / 255;
        b = str2double( get( handles.edit3, 'String') ) / 255;
        
        options.levels = 5;
        options.high = 4;
        DPC = mapwithdots( handles.data.I_top, options);
        
        axes(handles.axes3);
        hold on; 
        plot(DPC(:,1), DPC(:,2), 'o', 'MarkerSize', 2, ...
        'MarkerEdgeColor', [ r g b ], 'MarkerFaceColor',[ r g b ]' );
        hold off;
    elseif get( handles.radiobutton7, 'Value')                              % contour overlay.
        
        r = str2double( get( handles.edit1, 'String') ) / 255;
        g = str2double( get( handles.edit2, 'String') ) / 255;
        b = str2double( get( handles.edit3, 'String') ) / 255;
        
        I_pn = ( handles.data.I_top - min( handles.data.I_top(:) ) ) ./ ...
            (max( handles.data.I_top(:) ) - min( handles.data.I_top(:) ));
        V = handles.p.x0;
        
        axes(handles.axes3);
        
        hold on; 
        [c h] = contour(I_pn, V);
        set (h, 'LineColor', [r g b]);
%         colormap(repmat( [ r g b], 256, 1)); 
        set (h, 'LineWidth', 1);
        hold off;
                                                                            % Planned feature: checkbox to show/hid +- 10% of threshold lines.
    end
    
    guidata(hObject, handles);
    
    %%%% <--
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

update_images(hObject, handles);
update_labels(hObject, handles);
guidata(hObject, handles);

function y_cmp = log_compress(y, mu)
% y_cmp = sign(y).* (log (1 + mu .* abs(y)) ./ log(1 + mu));

%%%% added by alisha
    y(y<0)=0;
    base=1.06;
    temp=1000*y;
    temp=log10(temp) / log10(base);
    temp(isinf(temp))=0;
    temp(isinf(-temp))=0;
    temp(isnan(temp))=0;
    y_cmp=temp;
    clear temp;
%%%%


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

update_images(hObject, handles);
guidata(hObject, handles);
update_labels(hObject, handles);

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

update_images(hObject, handles);
guidata(hObject, handles);
update_labels(hObject, handles);

% --- PLOT THE RETINEX MODEL ANALYSIS...
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Retinex theory calculates how an image is perceived by visual system.
for i = 1:3
    Retinex(:,:,i) = retinex_frankle_mccann(squeeze( handles.data.blend(:,:,i) ), 8);
end

% caluculate L_star - luminance property.
I_Ls = get_Lstar( handles.data.blend );
R_Ls = get_Lstar( Retinex );

figure('color','white')
subplot(2,4,1)
image(handles.data.blend); axis image; axis off; 
title('True Composite')

subplot(2,4,2)
image( Retinex ); axis image; axis off; 
title('Retinex-modeled Composite')

subplot(2,4,5)
pcolor( flipud ( I_Ls ) ); shading flat; axis image; axis off;
title('True L*');
colormap gray; freezeColors

subplot(2,4,6)
pcolor( flipud ( R_Ls ) ); shading flat; axis image; axis off; title('Retinex-modeled L*');
colormap gray; freezeColors

subplot(2,4,[3 4 7 8])
pcolor(flipud( 100 .* double( (R_Ls - I_Ls) ./ I_Ls))); 
shading flat; caxis([-50 50]); 
colorbar('east'); axis image; axis off; title('Percent Difference');
colormap(handles.div_cmap / 256); freezeColors
update_labels(hObject, handles);

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
handles.gray_flag = abs(handles.gray_flag - 1);
if get( hObject, 'Value' )
    handles.just_flagged = 1;
    
    % show sliders
    set(handles.slider1, 'Enable', 'on');
    set(handles.slider2, 'Enable', 'on');
else
    handles.just_flagged = 0;
    % hide sliders
    set(handles.slider1, 'Enable', 'off');
    set(handles.slider2, 'Enable', 'off');
end

guidata(hObject, handles);
update_images(hObject, handles);
update_labels(hObject, handles);

% --- Returns the YTickLabels for the quantitative colorbar on the overlay
% image. This is so log compression can plot values that make sense.
function clb = gen_clabel(c_l, n, log_flag)

clb = {};
if nargin == 2
    log_flag = 0
end
if ~log_flag
    c_vec = linspace(c_l(1), c_l(2), n);
else
    c_lin = linspace(c_l(1), c_l(2), n);
    c_vec = sign(c_lin).* (log (1 + 255 .* abs(c_lin)) ./ log(1 + 255));
end
for i = 1:n
    clb{i} = num2str(c_vec(i), '%5.4f');
end

% --- Returns the CIELAB luminescence measurement.
function L_star = get_Lstar( I )
[rows cols chans] = size( I );

I_vec = reshape(I, [rows * cols, chans]);

M = [ 0.5767309  0.1855540  0.1881852;
      0.2973769  0.6273491  0.0752741;
      0.0270343  0.0706872  0.9911085];

xyz = I_vec * M;

Lstar_v = real ( ( (25.29 .* xyz(:,2) .^ 0.3333 - 18.38) )./100 );

L_star = reshape(Lstar_v, [rows, cols]);

% --- Returns the divergent colormap which is centered at the x0
% transparency value (median of I_top histogram).
function cmap_adj = dynamic_cmap( x0 )

x1 = linspace(0,128, ceil( 256 * x0 ));
x2 = linspace(0,128, floor( 256 * (1 - x0) ));
x = ( 0:255 )';

R1 = ones(size(x1)) .* 145;                 % RGB channels for bottom two quartiles.
G1 = floor( 1.6912 .* x1 + 0.1810 );
B1 = floor( 1.0671 .* x1 + 118.99 ); 

R2 = floor(-1.1395 .* x2 + 145.87 );        % RGB channels for top two quartiles.
G2 = floor(-0.3751 .* x2 + 215.00 );
B2 = floor(-1.6122 .* x2 + 256.90 );

cmap_adj = [R1 R2; G1 G2; B1 B2]'; 
cmap_adj(cmap_adj > 255) = 255;
cmap_adj(cmap_adj < 0) = 0;


% --------------------------------------------------------------------
function save_im_Callback(hObject, eventdata, handles)
% hObject    handle to save_im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uiputfile('*.png', 'Save images as...');
[rows cols] = size(handles.data.I_top);

drawnow
pause(1)
F2 = getframe(handles.axes2); 
Im2 = frame2im(F2);

file_patt = [pathname filename(1:findstr('.png', filename)-1)];

imwrite(Im2, [file_patt '_TOP.png'], 'XResolution', 400, 'YResolution', 400);
imwrite(handles.data.I_bot, [file_patt '_BOT.png']);
imwrite(handles.data.blend, [file_patt '_COMP.png']);


% --------------------------------------------------------------------
function colorblind_Callback(hObject, eventdata, handles)
% hObject    handle to colorblind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure('color','white')
subplot(2,3,1)
image( handles.data.blend );                                                % plot the overlay 
% image( I_comp );
axis image; axis off; 
title('Normal Color Vision')

subplot(2,3,2)
image( protanopia(handles.data.blend) );                                    % plot the protanopic interpretation.
axis image; axis off; 
title('Protanopia');

subplot(2,3,3)
image( deuteranopia(handles.data.blend) );                                  % plot the deuteranopic interpretation.
axis image; axis off; 
title('Deuteranopia');

subplot(2,3,4)
imagesc( get_Lstar( handles.data.blend ) );                                 % plot the brightness of normal vision.
axis image; axis off; title('Normal Lightness');
colormap gray

subplot(2,3,5)
imagesc( get_Lstar( protanopia(handles.data.blend) ) );                     % plot the brightness of protanopia.
axis image; axis off; 
title('Protanopic Lightness (L*)'); 
colormap gray

subplot(2,3,6)
imagesc( get_Lstar( deuteranopia(handles.data.blend) ) );                   % plot the brightness of deuteranopia.
axis image; axis off; 
title('Deuteranopic Lightness (L*)'); 
colormap gray



function deutRGB = deuteranopia(normalRGB)
%DEUTERANOPIA   Simulate an image with M-cone deficiency (deuteranopia).
%   DEUT = DEUTERANOPIA(RGB)
%   Reference: http://www.tsi.enst.fr/~brettel/CRA24/table2.html

cmaps = load('color_anomalies.mat');
normalInd = rgb2ind(normalRGB, cmaps.normal ./ 255);                         % Convert the RGB image to an indexed image using the normal colormap.
deutRGB = ind2rgb(normalInd, cmaps.deut ./ 255);                             % Convert back to an RGB image using the anomalous colormap.



function protRGB = protanopia(normalRGB)
%PROTANOPIA   Simulate an image with L-cone deficiency (protanopia).
%   PROT = PROTANOPIA(RGB)
%   Reference: http://www.tsi.enst.fr/~brettel/CRA24/table2.html

cmaps = load('color_anomalies.mat');
normalInd = rgb2ind(normalRGB, cmaps.normal ./ 255);                        % Convert the RGB image to an indexed image using the normal colormap.
protRGB = ind2rgb(normalInd, cmaps.prot ./ 255);                            % Convert back to an RGB image using the anomalous colormap.







function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
r = str2double( get( handles.edit1, 'String') ) ./ 255;
g = str2double( get( handles.edit2, 'String') ) ./ 255;
b = str2double( get( handles.edit3, 'String') ) ./ 255;

c = uisetcolor([r g b]);

set( handles.edit1, 'String', int2str( c(1) * 255 ) );
set( handles.edit2, 'String', int2str( c(2) * 255 ) );
set( handles.edit3, 'String', int2str( c(3) * 255 ) );

guidata(hObject, handles);                                                  % Update handles structure
update_images(hObject, handles);                                            % Update the four axes.
update_labels(hObject, handles);

% --- Executes on button press in uni_rb.
function uni_rb_Callback(hObject, eventdata, handles)
% hObject    handle to uni_rb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

                                      % Update the four axes.


% --- Executes on button press in cloud_rb.
function cloud_rb_Callback(hObject, eventdata, handles)
% hObject    handle to cloud_rb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

                                    % Update the four axes.


% --- Executes on button press in colormap_rb.
function colormap_rb_Callback(hObject, eventdata, handles)
% hObject    handle to colormap_rb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of colormap_rb



% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4

set( handles.popupmenu1, 'Enable', 'on');

set( handles.pushbutton2, 'Enable', 'off');
set( handles.edit1, 'Enable', 'off');
set( handles.edit2, 'Enable', 'off');
set( handles.edit3, 'Enable', 'off');

guidata(hObject, handles);                                                  % Update handles structure
update_images(hObject, handles);                                            % Update the four axes.
update_labels(hObject, handles);



% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5

set( handles.popupmenu1, 'Enable', 'off');

set( handles.pushbutton2, 'Enable', 'on');
set( handles.edit1, 'Enable', 'on');
set( handles.edit2, 'Enable', 'on');
set( handles.edit3, 'Enable', 'on');


guidata(hObject, handles);                                                  % Update handles structure
update_images(hObject, handles); 
update_labels(hObject, handles);

% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton6

set( handles.popupmenu1, 'Enable', 'off');

set( handles.pushbutton2, 'Enable', 'on');
set( handles.edit1, 'Enable', 'on');
set( handles.edit2, 'Enable', 'on');
set( handles.edit3, 'Enable', 'on');

guidata(hObject, handles);                                                  % Update handles structure
update_images(hObject, handles);                                            % Update the four axes.
update_labels(hObject, handles);

% --- Executes on slider movement.
function slider8_Callback(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

guidata(hObject, handles);                                                  % Update handles structure
update_images(hObject, handles);                                            % Update the four axes.
update_labels(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in radiobutton7.
function radiobutton7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton7


set( handles.popupmenu1, 'Enable', 'off');

set( handles.pushbutton2, 'Enable', 'on');
set( handles.edit1, 'Enable', 'on');
set( handles.edit2, 'Enable', 'on');
set( handles.edit3, 'Enable', 'on');

guidata(hObject, handles);                                                  % Update handles structure
update_images(hObject, handles);                                            % Update the four axes.
update_labels(hObject, handles);

function update_labels(hObject, handles)

set( handles.text12, 'String', num2str( get( handles.slider5, 'Value'), '%3.2f'));

if get(handles.radiobutton11, 'Value'); 
    set( handles.text13, 'String', num2str( get( handles.slider6, 'Value'), '%3.2f'));

elseif get(handles.radiobutton10, 'Value'); handles.p.f = 'lin';
    set( handles.text13, 'String', num2str( get( handles.slider6, 'Value'), '%3.2f'));

elseif get(handles.radiobutton9,'Value'); handles.p.f = 'power';
    set( handles.text13, 'String', num2str( get( handles.slider6, 'Value') * 0.5, '%3.2f'));

else handles.p.f = 'logistic';
    set( handles.text13, 'String', num2str( get( handles.slider6, 'Value') * 5, '%3.2f'));

end

set( handles.text14, 'String', num2str( get( handles.slider7, 'Value'), '%3.2f'));
set( handles.text15, 'String', num2str( get( handles.slider8, 'Value'), '%3.2f'));


% --------------------------------------------------------------------
function cie_space_Callback(hObject, eventdata, handles)
% hObject    handle to cie_space (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~handles.top_flag
    handles.data.I_bot = handles.data.I1;
end

% GENERATE CIE 1931 xy MAP
[WL, xFcn, yFcn, zFcn] = colorMatchFcn('CIE_1931');

v=[0:.001:1]; [x,y]=meshgrid(v,v); y=flipud(y); z=(1-x-y);
rgb=applycform(cat(3,x,y,z),makecform('xyz2srgb'));
ciex=xFcn./sum([xFcn; yFcn; zFcn],1); ciey=yFcn./sum([xFcn; yFcn; zFcn]);
nciex=ciex*size(rgb,2); nciey=size(rgb,1)-ciey*size(rgb,1);

%mask=~any(rgb==0,3); mask=cat(3,mask,mask,mask);
mask=roipoly(rgb,nciex,nciey); mask=cat(3,mask,mask,mask);

% OUTLINE THE CONTOURS OF WHITE-LIGHT DISTRO.
rgb2 = handles.data.I_bot;
rgb3 = rgb2;

% mask rgb2 based on 2sd less than median of the fluorescence data.
xyz = applycform(rgb3, makecform('srgb2xyz'));
xyl = applycform(xyz2double(xyz), makecform('xyz2xyl'));

X =  xyl(:,:,1); 
Y =  abs( xyl(:,:,2) - 1 );

    
[N,C] = hist3([X(:) Y(:)], {0:0.01:1 0:0.01:1});
[xg,yg] = meshgrid( 1000.*C{1}, 1000.*C{2}); %yg = flipud(yg);
    

% OUTLINE THE CONTOURS OF COLORMAP.
cmap = uint8( handles.cmap );                                               % load a colorbar
c_xyz = applycform(cmap, makecform('srgb2xyz'));
c_xyl = applycform(xyz2double(c_xyz), makecform('xyz2xyl'));

cX =  c_xyl(:,1); cY =  abs( c_xyl(:,2) - 1 );

figure('color','white'); 
imshow(rgb.*mask+~mask); hold on;
% plot(1000.*X(:),1000.*Y(:),'.'); 
plot( [640 300 150 640],abs( [1000 1000 1000 1000] -[330 600 060 330]),'k--', 'LineWidth',1.5);
[C,H] = contour(yg,xg,N,5);
set(H,'LineWidth',1.5);
colormap([0.1:0.1:0.5; 0.1:0.1:0.5; 0.1:0.1:0.5]')
plot(1000.*cX(2:10:end),1000.*cY(2:10:end),'ko-', 'LineWidth',1.5, 'MarkerSize',5);
legend('sRGB space', 'bottom image', 'colormap')

[C,IA,IB]=intersect(WL,[400 460 470 480 490 520 540 560 580 600 620 700]);
text(nciex(IA),nciey(IA),num2str(WL(IA).'));

axis on;
set(gca,'XTickLabel',get(gca,'XTick')/(size(rgb,2)-1));
set(gca,'YTickLabel',1-get(gca,'YTick')/(size(rgb,1)-1));

title('CIE Chromaticity'); xlabel('x'); ylabel('y');

hold off
set(gcf, 'menubar', 'none');


% --- Executes on button press in radiobutton8.
function radiobutton8_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton8
set(handles.radiobutton9, 'Value', 0);
set(handles.radiobutton10, 'Value', 0);
set(handles.radiobutton11, 'Value', 0);

update_images(hObject, handles);
update_labels(hObject, handles);
guidata(hObject, handles);


% --- Executes on button press in radiobutton9.
function radiobutton9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton9
set(handles.radiobutton10, 'Value', 0);
set(handles.radiobutton11, 'Value', 0);
set(handles.radiobutton8, 'Value', 0);

update_images(hObject, handles);
update_labels(hObject, handles);
guidata(hObject, handles);


% --- Executes on button press in radiobutton10.
function radiobutton10_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton10
set(handles.radiobutton11, 'Value', 0);
set(handles.radiobutton8, 'Value', 0);
set(handles.radiobutton9, 'Value', 0);

update_images(hObject, handles);
update_labels(hObject, handles);
guidata(hObject, handles);


% --- Executes on button press in radiobutton11.
function radiobutton11_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton11
set(handles.radiobutton8, 'Value', 0);
set(handles.radiobutton9, 'Value', 0);
set(handles.radiobutton10, 'Value', 0);

update_images(hObject, handles);
update_labels(hObject, handles);
guidata(hObject, handles);


% --- Pyramid Test

function [X,Y,GIZA] = gen_pyramid()
%% This cell creates the Great Pyramid of Khufu in Giza
% using the original(pre-erosion) dimensions of 755x755x482 feet 
% (I am using imperial measurements as they are round numbers 
% - metrics measurements are not)
PY=zeros(241,241);
for i = 1:241
    temp=(0:1:i-1);
      PY(i,1:i)=temp(:);
end   
test=PY.';
test=test-1;
test(test==-1)=0;
test1=test([2:1:end,1],:);
PY1=PY+test1;
PY2=fliplr(PY1);
PY3= flipud(PY1);
PY4=fliplr(PY3);
GIZA=[PY1,PY2;PY3,PY4].*2;
x=linspace(1,756,size(GIZA,1));
y=x;
[X,Y]=meshgrid(x,y);
clear i test test1 PY PY1 PY2 PY3 PY4 temp;

%%  This cell plots the pyramid with SURF (interpolated color) 
% 
% 
% %%  This cell creates L* plot for natural spectrum
% LS=colorspace('RGB->Lab',spectrum);
% figure;
% h=colormapline(1:1:256,LS(:,1),[],spectrum);
% set(h,'linewidth',2);
% title ('L* plot for natural spectrum colormap','Color','k','FontSize',12);
