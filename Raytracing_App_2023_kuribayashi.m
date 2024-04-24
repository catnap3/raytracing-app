classdef Raytracing_App_2023_kuribayashi_20240313 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Raytracing                matlab.ui.Figure
        GridLayout                matlab.ui.container.GridLayout
        LeftPanel                 matlab.ui.container.Panel
        DuctConditionPanel        matlab.ui.container.Panel
        DuctDistance              matlab.ui.control.NumericEditField
        DuctDistanceUnit          matlab.ui.control.Label
        DuctDistanceLabel         matlab.ui.control.Label
        DuctAmplitude             matlab.ui.control.NumericEditField
        DuctAmplitudeLabel        matlab.ui.control.Label
        Distsigma                 matlab.ui.control.NumericEditField
        DistsigmaUnit             matlab.ui.control.Label
        DistsigmaLabel            matlab.ui.control.Label
        LoopConditionPanel        matlab.ui.container.Panel
        Loop                      matlab.ui.control.NumericEditField
        MaximumofloopsLabel       matlab.ui.control.Label
        PlasmapausePanel          matlab.ui.container.Panel
        Plasmapause               matlab.ui.control.NumericEditField
        PlasmapauseUnit           matlab.ui.control.Label
        PlasmapauseLabel          matlab.ui.control.Label
        ExitButton                matlab.ui.control.Button
        StartButton               matlab.ui.control.Button
        SaveButton                matlab.ui.control.Button
        LoadButton                matlab.ui.control.Button
        WaveParameterPanel        matlab.ui.container.Panel
        ChangewavemodeCheckBox    matlab.ui.control.CheckBox
        WaveModeSwitch            matlab.ui.control.Switch
        WaveModeSwitchLabel       matlab.ui.control.Label
        FrequencyDropDown         matlab.ui.control.DropDown
        Frequency                 matlab.ui.control.NumericEditField
        FrequencyLabel            matlab.ui.control.Label
        InitialRayPositionPanel   matlab.ui.container.Panel
        Starting                  matlab.ui.control.NumericEditField
        StartingUnit              matlab.ui.control.Label
        StartingLabel             matlab.ui.control.Label
        Colatitude                matlab.ui.control.NumericEditField
        ColatitudeUnit            matlab.ui.control.Label
        ColatitudeLabel           matlab.ui.control.Label
        Longitude                 matlab.ui.control.NumericEditField
        LogitudeLabel             matlab.ui.control.Label
        LongitudeLabel            matlab.ui.control.Label
        InitialRayDirectionPanel  matlab.ui.container.Panel
        Delta                     matlab.ui.control.NumericEditField
        DeltaUnit                 matlab.ui.control.Label
        DeltaLabel                matlab.ui.control.Label
        Epsilon                   matlab.ui.control.NumericEditField
        EpsilonUnit               matlab.ui.control.Label
        EpsilonLabel              matlab.ui.control.Label
        RightPanel                matlab.ui.container.Panel
        Autosave                  matlab.ui.control.CheckBox
        StatusLabel               matlab.ui.control.Label
        UIAxes                    matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

% 20240219 Kuribayashi added Lines 247-267 to extract x,y,xd,yd,u,v from plot_prm and plot x vs xd.

    methods (Access = private)

        % get values from a input file
        function set_input(app,prm)
            app.Starting.Value = prm.N;
            app.Colatitude.Value = prm.th00;
            app.Longitude.Value = prm.ph00;
            app.Delta.Value = prm.dl00;
            app.Epsilon.Value = prm.es00;
            app.Frequency.Value = prm.M;
            app.Plasmapause.Value = prm.XLPP;
            app.Loop.Value = prm.NLPMAX;
            app.DuctAmplitude.Value = prm.MGDU;
            app.Distsigma.Value = prm.DIST;
            app.DuctDistance.Value = prm.XLDU;
            
            % get unit of frequency
            if prm.unit_fq00 == 1
                app.FrequencyDropDown.Value = app.FrequencyDropDown.Items{1};
            elseif prm.unit_fq00 == 2
                app.FrequencyDropDown.Value = app.FrequencyDropDown.Items{2};
            else
                app.FrequencyDropDown.Value = app.FrequencyDropDown.Items{3};
            end
            
            % get wave mode
            if prm.WMODE ==1
                app.WaveModeSwitch.Value = app.WaveModeSwitch.Items{1};
            else
                app.WaveModeSwitch.Value = app.WaveModeSwitch.Items{2};
            end
            
            if prm.CMODE ==1
                app.ChangewavemodeCheckBox.Value = true;
            end
        end
        
        %get values from the interface
        function prm = set_prm(app)
            prm.N = app.Starting.Value; 
            prm.th00 = app.Colatitude.Value; 
            prm.ph00 = app.Longitude.Value;
            prm.dl00 = app.Delta.Value;
            prm.es00 = app.Epsilon.Value;
            prm.M = app.Frequency.Value;
            prm.XLPP = app.Plasmapause.Value;
            prm.NLPMAX = app.Loop.Value;
            prm.MGDU = app.DuctAmplitude.Value;
            prm.DIST = app.Distsigma.Value;
            prm.XLDU = app.DuctDistance.Value;     
            if isequal(app.FrequencyDropDown.Value,app.FrequencyDropDown.Items{1})
                prm.unit_fq00 = 1;
            elseif isequal(app.FrequencyDropDown.Value,app.FrequencyDropDown.Items{2})
                prm.unit_fq00 = 2;
            else
                prm.unit_fq00 = 3;
            end
            
            if isequal(app.WaveModeSwitch.Value,app.WaveModeSwitch.Items{1})
                prm.WMODE = 1;
            else
                prm.WMODE = 2;
            end
            
            if app.ChangewavemodeCheckBox.Value
                prm.CMODE = 1;
            else
                prm.CMODE = 2;
            end

            
        end
              
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % initial status
            app.StatusLabel.Text='Status: Input';
            
            %%%%% load gui inital parameter data  %%%%%
            % using the last session parameter
            filename = 'prm_list/input_tmp.dat';
            prm = input_param(filename);
            if isempty(prm)
            return;
            end   
            set_input(app,prm)
            axis(app.UIAxes,'equal')
            set(app.UIAxes,'xlim',[0 6])
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.Raytracing.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {535, 535};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {582, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end

        % Button pushed function: ExitButton
        function ExitButtonPushed(app, event)
            YN = uiconfirm(app.Raytracing,'Do you want to close the app?', 'Close request');
            if strcmpi(YN,'OK')
                close all
                delete(app)
            end
            %app.delete;
        end

        % Button pushed function: LoadButton
        function LoadButtonPushed(app, event)
            % open dummy figure
            f=figure('Units','normalized','position',[0.1,0.5,0.001,0.001]);
            %bring figure to front focus
            drawnow;    
           [filename, pathname] = uigetfile('prm_list/*.dat');
            % delete dummy
            delete(f);      
           figure(app.Raytracing);
            if filename
                input_filename = [pathname,filename];
                prm = input_param(input_filename);
                set_input(app,prm)
            end
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            % open dummy figure
            f=figure('Units','normalized','position',[0.1,0.5,0.001,0.001]);
            %bring figure to front focus
            drawnow; 
            [filename, pathname] = uiputfile('prm_list/*.dat');
            % delete dummy
            delete(f);
            if filename
                prm = set_prm(app);
                save_filename = [pathname,filename];
                save_param(save_filename,prm);
            end
        end

        % Callback function: Distsigma, DuctAmplitude, DuctDistance, 
        % ...and 4 other components
        function StartButtonPushed(app, event)
            app.StatusLabel.Text='Status: Under calculation...';
            pause(1)
            filename = 'prm_list/input_tmp.dat';
            prm = set_prm(app);
            save_param(filename,prm);
            disp('Under calculation...');
            cla(app.UIAxes)
            if prm.unit_fq00 == 1
                title1 = '\Omega_e';
            elseif prm.unit_fq00 == 2
                title1 = '\Omega_p';
            else
                title1 = 'kHz';
            end
            plot_title = ['Raytracing: ',num2str(prm.N),' R_{E}  ',num2str(prm.M),title1];
            title(app.UIAxes, plot_title)
            
            % Set 2D plot
            plot_prm = raytracing_app_main(filename);


            
            % ファイルに保存
            save_filename = 'plot_data.dat'; % 保存するファイル名
            fileID = fopen(save_filename, 'w'); % ファイルを書き込み用に開く
            % ヘッダーを書き込む
            fprintf(fileID, '%s\t%s\t%s\t%s\t%s\t%s\n', 'x', 'y', 'xd', 'yd', 'u', 'v');
            
            
            % プロットの準備
            figure; % 新しい図を開く
            hold on; % 複数のプロットを同一の図に描画
            xlabel('x'); % x軸のラベル
            ylabel('xd'); % y軸のラベル（ここではxdをy軸として使用）
            title('Plot of x vs xd'); % グラフのタイトル
            
            % データを書き込む
            for i = 1:length(plot_prm.x)
                fprintf(fileID, '%f\t%f\t%f\t%f\t%f\t%f\n', plot_prm.x(i), plot_prm.y(i), plot_prm.xd(i), plot_prm.yd(i), plot_prm.u(i), plot_prm.v(i));
                plot(plot_prm.x(i), plot_prm.xd(i), 'o'); % (x, xd)の点をプロット
            end
            fclose(fileID); % ファイルを閉じる
            hold off; % 他のプロットがこの図に追加されないようにする



            
            if plot_prm.exist ==0 % wave does not exist
                
                app.StatusLabel.Text='Status: Wave does not exist under this condition.';
                
            else
                
                
                %%% Duct %%%
                if app.DuctAmplitude.Value ~= 0
                    lat=-90:0.1:90;
                    L=prm.XLDU;
                    brr=L*cosd(lat).*cosd(lat);
                    plt=find(abs(brr)>1);
                    plot(app.UIAxes,brr(plt).*cosd(lat(plt)),brr(plt).*sind(lat(plt)),'LineStyle','-','Color','#7DB9DE','LineWidth',3)
                end
                    % axes setting ==========
                    hold(app.UIAxes, 'on')
                    axis(app.UIAxes,'equal')
                
                % =======================
                
                %%% path %%%
                plot(app.UIAxes,plot_prm.x(1),plot_prm.y(1),'*r');
                plot(app.UIAxes,plot_prm.x,plot_prm.y,'LineWidth',1.5,'Color',[1 0 0]) % display propagation path
                
                [nm, ~]=size(plot_prm.xd);
                mode_color = [0 0.5 0; 0 0 1];
%                 quiver(app.UIAxes,plot_prm.xd,plot_prm.yd,plot_prm.u,plot_prm.v,'Color',[0
%                 0 1],'AutoScaleFactor',0.58) % display k vectors. used in
%                 old version with single mode wave

                for q_i=1:nm
                    quiver(app.UIAxes,plot_prm.xd(q_i),plot_prm.yd(q_i),plot_prm.u(q_i),plot_prm.v(q_i),'Color',mode_color(plot_prm.wmode(q_i),:),'AutoScaleFactor',0.4,'MaxHeadSize',1.2) % display k vectors
                end
                %%% Earth %%%
                lat=-90:0.1:90;
                plot(app.UIAxes,cosd(lat),sind(lat),'LineStyle','-','LineWidth',1.5,'Color','Black')
                %%% field line %%%
                for L=2:6   
                    brr=L*cosd(lat).*cosd(lat);
                    plt=find(abs(brr)>1);
                    plot(app.UIAxes,brr(plt).*cosd(lat(plt)),brr(plt).*sind(lat(plt)),'LineStyle',':','Color',[0 0 0])
                end
                %%% plasmapause %%%
                L=prm.XLPP;
                brr=L*cosd(lat).*cosd(lat);
                plt=find(abs(brr)>1);
                plot(app.UIAxes,brr(plt).*cosd(lat(plt)),brr(plt).*sind(lat(plt)),'LineStyle','--','Color','Black')
    
                
                %%% save plot or not %%%
                if app.Autosave.Value
                    set(app.UIAxes,'defaultAxesFontSize',14)
                    set(app.UIAxes,'defaultTextFontSize',14)
                    set(app.UIAxes,'defaultAxesFontName','Helvetica')
                    set(app.UIAxes,'defaultTextFontName','Helvetica')
    
                    output_file1 = ['result/trajectory_',num2str(prm.N),'RE_',num2str(round(plot_prm.fq00,1)),'kHz.png'];
                    exportgraphics(app.UIAxes,output_file1);
                end
                hold(app.UIAxes, 'off')
                app.StatusLabel.Text='Status: Calculation finished';
            
            end
        end

        % Key press function: Raytracing
        function RaytracingKeyPress(app, event)
            key = event.Key;
            switch key
                case 'return' % press Enter as click start button
                     StartButtonPushed(app, event)
            end

%             if isequal(event.Modifier,{'control'}) % hotkry: Ctrl+q
%                 switch key
%                     case 'q'
%                         StartButtonPushed(app, event)
%                         app.StatusLabel.Text='ctrl';
%                 end
%             end
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Raytracing and hide until all components are created
            app.Raytracing = uifigure('Visible', 'off');
            app.Raytracing.AutoResizeChildren = 'off';
            app.Raytracing.Position = [100 100 1089 535];
            app.Raytracing.Name = 'Raytracing: IWANE (Investigation of WAves Near the Earth)';
            app.Raytracing.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);
            app.Raytracing.KeyPressFcn = createCallbackFcn(app, @RaytracingKeyPress, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.Raytracing);
            app.GridLayout.ColumnWidth = {582, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.TitlePosition = 'centertop';
            app.LeftPanel.Title = 'Input Parameters';
            app.LeftPanel.BackgroundColor = [0.7098 0.851 0.949];
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;
            app.LeftPanel.FontWeight = 'bold';
            app.LeftPanel.Scrollable = 'on';
            app.LeftPanel.FontSize = 15;

            % Create InitialRayDirectionPanel
            app.InitialRayDirectionPanel = uipanel(app.LeftPanel);
            app.InitialRayDirectionPanel.Title = 'Initial Ray Direction';
            app.InitialRayDirectionPanel.FontWeight = 'bold';
            app.InitialRayDirectionPanel.FontSize = 14;
            app.InitialRayDirectionPanel.Position = [7 177 279 127];

            % Create EpsilonLabel
            app.EpsilonLabel = uilabel(app.InitialRayDirectionPanel);
            app.EpsilonLabel.HorizontalAlignment = 'right';
            app.EpsilonLabel.FontSize = 13;
            app.EpsilonLabel.Position = [87 15 48 22];
            app.EpsilonLabel.Text = 'Epsilon';

            % Create EpsilonUnit
            app.EpsilonUnit = uilabel(app.InitialRayDirectionPanel);
            app.EpsilonUnit.FontSize = 13;
            app.EpsilonUnit.Position = [220 15 43 22];
            app.EpsilonUnit.Text = '[deg]';

            % Create Epsilon
            app.Epsilon = uieditfield(app.InitialRayDirectionPanel, 'numeric');
            app.Epsilon.Position = [147 13 62 27];

            % Create DeltaLabel
            app.DeltaLabel = uilabel(app.InitialRayDirectionPanel);
            app.DeltaLabel.HorizontalAlignment = 'right';
            app.DeltaLabel.FontSize = 13;
            app.DeltaLabel.Position = [98 66 36 22];
            app.DeltaLabel.Text = 'Delta';

            % Create DeltaUnit
            app.DeltaUnit = uilabel(app.InitialRayDirectionPanel);
            app.DeltaUnit.FontSize = 13;
            app.DeltaUnit.Position = [220 66 43 22];
            app.DeltaUnit.Text = '[deg]';

            % Create Delta
            app.Delta = uieditfield(app.InitialRayDirectionPanel, 'numeric');
            app.Delta.Position = [147 64 62 27];

            % Create InitialRayPositionPanel
            app.InitialRayPositionPanel = uipanel(app.LeftPanel);
            app.InitialRayPositionPanel.Title = 'Initial Ray Position';
            app.InitialRayPositionPanel.FontWeight = 'bold';
            app.InitialRayPositionPanel.FontSize = 14;
            app.InitialRayPositionPanel.Position = [7 332 279 174];

            % Create LongitudeLabel
            app.LongitudeLabel = uilabel(app.InitialRayPositionPanel);
            app.LongitudeLabel.HorizontalAlignment = 'right';
            app.LongitudeLabel.FontSize = 13;
            app.LongitudeLabel.Position = [45 13 91 22];
            app.LongitudeLabel.Text = 'Longitude';

            % Create LogitudeLabel
            app.LogitudeLabel = uilabel(app.InitialRayPositionPanel);
            app.LogitudeLabel.FontSize = 13;
            app.LogitudeLabel.Position = [219 13 52 22];
            app.LogitudeLabel.Text = '[deg]';

            % Create Longitude
            app.Longitude = uieditfield(app.InitialRayPositionPanel, 'numeric');
            app.Longitude.Position = [148 11 62 27];

            % Create ColatitudeLabel
            app.ColatitudeLabel = uilabel(app.InitialRayPositionPanel);
            app.ColatitudeLabel.HorizontalAlignment = 'right';
            app.ColatitudeLabel.FontSize = 13;
            app.ColatitudeLabel.Position = [23 62 112 22];
            app.ColatitudeLabel.Text = 'Colatitude';

            % Create ColatitudeUnit
            app.ColatitudeUnit = uilabel(app.InitialRayPositionPanel);
            app.ColatitudeUnit.FontSize = 13;
            app.ColatitudeUnit.Position = [218 62 53 22];
            app.ColatitudeUnit.Text = '[deg]';

            % Create Colatitude
            app.Colatitude = uieditfield(app.InitialRayPositionPanel, 'numeric');
            app.Colatitude.Position = [147 60 62 27];

            % Create StartingLabel
            app.StartingLabel = uilabel(app.InitialRayPositionPanel);
            app.StartingLabel.HorizontalAlignment = 'right';
            app.StartingLabel.FontSize = 13;
            app.StartingLabel.Position = [-1 109 160 30];
            app.StartingLabel.Text = {'Starting distance'; '(from the Earth center)'};

            % Create StartingUnit
            app.StartingUnit = uilabel(app.InitialRayPositionPanel);
            app.StartingUnit.Position = [211 113 62 22];
            app.StartingUnit.Text = '[Re] (1–7)';

            % Create Starting
            app.Starting = uieditfield(app.InitialRayPositionPanel, 'numeric');
            app.Starting.Position = [169 111 41 27];

            % Create WaveParameterPanel
            app.WaveParameterPanel = uipanel(app.LeftPanel);
            app.WaveParameterPanel.Title = 'Wave Parameter';
            app.WaveParameterPanel.FontWeight = 'bold';
            app.WaveParameterPanel.FontSize = 14;
            app.WaveParameterPanel.Position = [296 343 279 162];

            % Create FrequencyLabel
            app.FrequencyLabel = uilabel(app.WaveParameterPanel);
            app.FrequencyLabel.HorizontalAlignment = 'right';
            app.FrequencyLabel.FontSize = 13;
            app.FrequencyLabel.Position = [12 101 96 22];
            app.FrequencyLabel.Text = 'Frequency';

            % Create Frequency
            app.Frequency = uieditfield(app.WaveParameterPanel, 'numeric');
            app.Frequency.ValueChangedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.Frequency.Position = [123 99 62 27];

            % Create FrequencyDropDown
            app.FrequencyDropDown = uidropdown(app.WaveParameterPanel);
            app.FrequencyDropDown.Items = {'E_gyro', 'P_gyro', 'kHz'};
            app.FrequencyDropDown.Position = [193 101 74 22];
            app.FrequencyDropDown.Value = 'E_gyro';

            % Create WaveModeSwitchLabel
            app.WaveModeSwitchLabel = uilabel(app.WaveParameterPanel);
            app.WaveModeSwitchLabel.HorizontalAlignment = 'right';
            app.WaveModeSwitchLabel.FontSize = 13;
            app.WaveModeSwitchLabel.Position = [38 61 97 22];
            app.WaveModeSwitchLabel.Text = 'Wave Mode';

            % Create WaveModeSwitch
            app.WaveModeSwitch = uiswitch(app.WaveParameterPanel, 'slider');
            app.WaveModeSwitch.Items = {'L', 'R'};
            app.WaveModeSwitch.Position = [165 59 58 26];
            app.WaveModeSwitch.Value = 'L';

            % Create ChangewavemodeCheckBox
            app.ChangewavemodeCheckBox = uicheckbox(app.WaveParameterPanel);
            app.ChangewavemodeCheckBox.Text = 'Change wave mode at crossover point';
            app.ChangewavemodeCheckBox.Position = [19 15 260 22];

            % Create LoadButton
            app.LoadButton = uibutton(app.LeftPanel, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);
            app.LoadButton.FontSize = 14;
            app.LoadButton.Position = [85 10 81 30];
            app.LoadButton.Text = 'Load';

            % Create SaveButton
            app.SaveButton = uibutton(app.LeftPanel, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.FontSize = 14;
            app.SaveButton.Position = [197 10 81 30];
            app.SaveButton.Text = 'Save';

            % Create StartButton
            app.StartButton = uibutton(app.LeftPanel, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.BackgroundColor = [0.5216 0.749 0.4];
            app.StartButton.FontSize = 14;
            app.StartButton.Position = [308 10 81 30];
            app.StartButton.Text = 'Start';

            % Create ExitButton
            app.ExitButton = uibutton(app.LeftPanel, 'push');
            app.ExitButton.ButtonPushedFcn = createCallbackFcn(app, @ExitButtonPushed, true);
            app.ExitButton.BackgroundColor = [0.9686 0.6392 0.7765];
            app.ExitButton.FontSize = 14;
            app.ExitButton.Position = [419 10 81 30];
            app.ExitButton.Text = 'Exit';

            % Create PlasmapausePanel
            app.PlasmapausePanel = uipanel(app.LeftPanel);
            app.PlasmapausePanel.Title = 'Plasmapause ';
            app.PlasmapausePanel.FontWeight = 'bold';
            app.PlasmapausePanel.FontSize = 14;
            app.PlasmapausePanel.Position = [296 250 279 75];

            % Create PlasmapauseLabel
            app.PlasmapauseLabel = uilabel(app.PlasmapausePanel);
            app.PlasmapauseLabel.HorizontalAlignment = 'right';
            app.PlasmapauseLabel.FontSize = 13;
            app.PlasmapauseLabel.Position = [12 14 96 22];
            app.PlasmapauseLabel.Text = 'Plasmapause';

            % Create PlasmapauseUnit
            app.PlasmapauseUnit = uilabel(app.PlasmapausePanel);
            app.PlasmapauseUnit.FontSize = 13;
            app.PlasmapauseUnit.Position = [194 14 29 22];
            app.PlasmapauseUnit.Text = '[Re]';

            % Create Plasmapause
            app.Plasmapause = uieditfield(app.PlasmapausePanel, 'numeric');
            app.Plasmapause.ValueChangedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.Plasmapause.Position = [121 12 62 27];

            % Create LoopConditionPanel
            app.LoopConditionPanel = uipanel(app.LeftPanel);
            app.LoopConditionPanel.Title = 'Loop Condition';
            app.LoopConditionPanel.FontWeight = 'bold';
            app.LoopConditionPanel.FontSize = 14;
            app.LoopConditionPanel.Position = [7 75 279 75];

            % Create MaximumofloopsLabel
            app.MaximumofloopsLabel = uilabel(app.LoopConditionPanel);
            app.MaximumofloopsLabel.HorizontalAlignment = 'right';
            app.MaximumofloopsLabel.FontSize = 13;
            app.MaximumofloopsLabel.Position = [23 14 125 22];
            app.MaximumofloopsLabel.Text = 'Maximum of loops';

            % Create Loop
            app.Loop = uieditfield(app.LoopConditionPanel, 'numeric');
            app.Loop.ValueChangedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.Loop.Position = [158 12 51 27];

            % Create DuctConditionPanel
            app.DuctConditionPanel = uipanel(app.LeftPanel);
            app.DuctConditionPanel.Title = 'Duct Condition';
            app.DuctConditionPanel.FontWeight = 'bold';
            app.DuctConditionPanel.FontSize = 14;
            app.DuctConditionPanel.Position = [296 75 279 167];

            % Create DistsigmaLabel
            app.DistsigmaLabel = uilabel(app.DuctConditionPanel);
            app.DistsigmaLabel.HorizontalAlignment = 'right';
            app.DistsigmaLabel.FontSize = 13;
            app.DistsigmaLabel.Position = [19 55 93 22];
            app.DistsigmaLabel.Text = 'Dist. sigma';

            % Create DistsigmaUnit
            app.DistsigmaUnit = uilabel(app.DuctConditionPanel);
            app.DistsigmaUnit.FontSize = 13;
            app.DistsigmaUnit.Position = [196 55 29 22];
            app.DistsigmaUnit.Text = '[Re]';

            % Create Distsigma
            app.Distsigma = uieditfield(app.DuctConditionPanel, 'numeric');
            app.Distsigma.ValueChangedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.Distsigma.Position = [123 55 62 27];

            % Create DuctAmplitudeLabel
            app.DuctAmplitudeLabel = uilabel(app.DuctConditionPanel);
            app.DuctAmplitudeLabel.HorizontalAlignment = 'right';
            app.DuctAmplitudeLabel.FontSize = 13;
            app.DuctAmplitudeLabel.Position = [19 106 105 22];
            app.DuctAmplitudeLabel.Text = 'Duct Amplitude';

            % Create DuctAmplitude
            app.DuctAmplitude = uieditfield(app.DuctConditionPanel, 'numeric');
            app.DuctAmplitude.ValueChangedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.DuctAmplitude.Position = [134 104 70 27];

            % Create DuctDistanceLabel
            app.DuctDistanceLabel = uilabel(app.DuctConditionPanel);
            app.DuctDistanceLabel.HorizontalAlignment = 'right';
            app.DuctDistanceLabel.FontSize = 13;
            app.DuctDistanceLabel.Position = [19 9 93 22];
            app.DuctDistanceLabel.Text = 'Duct Distance';

            % Create DuctDistanceUnit
            app.DuctDistanceUnit = uilabel(app.DuctConditionPanel);
            app.DuctDistanceUnit.FontSize = 13;
            app.DuctDistanceUnit.Position = [197 9 29 22];
            app.DuctDistanceUnit.Text = '[Re]';

            % Create DuctDistance
            app.DuctDistance = uieditfield(app.DuctConditionPanel, 'numeric');
            app.DuctDistance.ValueChangedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.DuctDistance.Position = [123 7 62 27];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.BackgroundColor = [0.7098 0.851 0.949];
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;
            app.RightPanel.Scrollable = 'on';

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            title(app.UIAxes, 'Raytracing')
            xlabel(app.UIAxes, '[Re]')
            ylabel(app.UIAxes, '[Re]')
            zlabel(app.UIAxes, '[Re]')
            app.UIAxes.DataAspectRatio = [6 6 1];
            app.UIAxes.XLim = [0 6];
            app.UIAxes.YLim = [-3 3];
            app.UIAxes.XTick = [0 1 2 3 4 5 6];
            app.UIAxes.YTick = [-3 -2 -1 0 1 2 3];
            app.UIAxes.YTickLabel = {'-3'; '-2'; '-1'; '0'; '1'; '2'; '3'};
            app.UIAxes.Box = 'on';
            app.UIAxes.XGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.Position = [28 18 450 450];

            % Create StatusLabel
            app.StatusLabel = uilabel(app.RightPanel);
            app.StatusLabel.Position = [18 472 304 22];
            app.StatusLabel.Text = 'Status: ';

            % Create Autosave
            app.Autosave = uicheckbox(app.RightPanel);
            app.Autosave.Text = 'Auto save plot';
            app.Autosave.Position = [381 502 113 22];

            % Show the figure after all components are created
            app.Raytracing.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Raytracing_App_2023_kuribayashi_20240313

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Raytracing)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Raytracing)
        end
    end
end