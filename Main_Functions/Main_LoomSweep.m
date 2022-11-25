function EscapeRes = Main_LoomSweep(animal, condition, folder, newfactors)

%% Reading csv file and setting the variables

name = [animal '_' condition];
filename = [name '.csv'];
filepath = [folder filesep animal];
addpath(filepath);
datasheet_fullpath = [folder filesep 'Data.xlsx'];    % Sheet to store all results
stimulus_sheet_path = [folder filesep animal filesep 'Stimulus.xlsx'];

% Read the animal file
opts = detectImportOptions(filename, 'NumHeaderLines', 1);
opts.VariableNamesLine = 2;
opts.DataLine = 4;
tbl = readtable(filename,opts);

% Read the datasheet
datasheet = readtable(datasheet_fullpath, 'Sheet', 'Basics');
animal_column = table2cell(datasheet(:,1));
idx = find(strcmp(animal_column, name));

% Setting up the factors structure variable
factors.folder = folder;
factors.animal = animal;
factors.condition = condition;
factors.name = name;
factors.filename = filename;
factors.filepath = filepath;
factors.frame_rate = 29.41;
factors.test = 1;
factors.basal2 = 0;
factors.speed_changes_times = [1, 15, 20, 26];
factors.speed_changes = [600, 650, 700, 750];
factors.draw_fig = 0; % If 1, then figures are drawn.
frames = size(tbl,1);
factors.frames = frames;

if nargin > 3
    factors = FactorsUpdate(factors,newfactors);
end

% Read the stimulus datasheet
if factors.test == 1
    stimulus = readtable(stimulus_sheet_path, 'Sheet', condition);
    loom = table2array(stimulus(:,3));
    mov = table2array(stimulus(:,1));
    mov_duration = table2array(stimulus(:,2));
end

if sum(~isnan(loom)) ~= 0
    factors.loom = loom;
end
if sum(~isnan(mov)) ~= 0
    factors.mov = mov;
    factors.mov_duration = mov_duration;
end

%% Transform the Coordinates
% This secontion of the code first converts the raw coordinates obtained
% after Deeplabcut estimation into true x-y coordinates. After that, a
% small plot is created to depict the square field of the arena.
 
tbl_new = TransformCoordinates(tbl);

tl_x = mean(tbl_new.tl);
tl_y = mean(tbl_new.tl_1);
tr_x = mean(tbl_new.tr);
tr_y = mean(tbl_new.tr_1);
bl_x = mean(tbl_new.bl);
bl_y = mean(tbl_new.bl_1);
br_x = mean(tbl_new.br);
br_y = mean(tbl_new.br_1);

plot([tr_x tl_x bl_x br_x tr_x], [tr_y tl_y bl_y br_y tr_y], 'Color', 'k');
ylim([-10 60]);
xlim([-10 60]);
close;


%% Basic Plots
% This section is used to plot the likelihood plots for the nose and the
% bodycentre of the animal. These plots are constructed and saved only if
% the parameter factors.draw_fig is set equal to 1. 

fig_path = factors.filepath;

if factors.draw_fig == 1
    
    tl_x_o = mean(tbl.tl);
    tl_y_o = -mean(tbl.tl_1);
    tr_x_o = mean(tbl.tr);
    tr_y_o = -mean(tbl.tr_1);
    bl_x_o = mean(tbl.bl);
    bl_y_o = -mean(tbl.bl_1);
    br_x_o = mean(tbl.br);
    br_y_o = -mean(tbl.br_1);
    
    
    % Plot the true nose coordinates
    Lineplot(tbl.nose, -tbl.nose_1, tbl.nose_2, [animal ' Nose']);
    hold all;
    plot([tr_x_o tl_x_o bl_x_o br_x_o tr_x_o], [tr_y_o tl_y_o bl_y_o br_y_o tr_y_o], 'Color', 'k');
    h = get(gca);
    h.XAxis.Visible = 'off';
    h.YAxis.Visible = 'off';
    
    %     set(gcf, 'Position', get(0, 'Screensize'));
    set(gcf, 'Position', [0,0,600,500]);
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperOrientation','landscape');
    saveas(gcf, [fig_path filesep [name '_NoseCoordinate.png']]);
    print('-painters','-dpdf', '-bestfit',[fig_path filesep [name '_NoseCoordinate.pdf']]);
    close;
    
    % Plot the true bodycentre coordinates
    Lineplot(tbl.bodycentre, -tbl.bodycentre_1, tbl.bodycentre_2, [animal ' BodyCentre']);
    hold all;
    plot([tr_x_o tl_x_o bl_x_o br_x_o tr_x_o], [tr_y_o tl_y_o bl_y_o br_y_o tr_y_o], 'Color', 'k');
    h = get(gca);
    h.XAxis.Visible = 'off';
    h.YAxis.Visible = 'off';
    
    set(gcf, 'Position', [0,0,600,500]);
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperOrientation','landscape');
    saveas(gcf, [fig_path filesep [name '_BodyCentreCoordinate.png']]);
    print('-painters','-dpdf', '-bestfit',[fig_path filesep [name '_BodyCentreCoordinate.pdf']]);
    close;
end

%% Comparing the quality of bodycentre and nose detection
% This section can be used to see if the bodycentre is a more reliable
% variable or the nose, based on the p-values of detection. A threshold
% value of 0.9 is used to classify a frame as either good or bad. These
% values are then stored in the 'Data' excelsheet.


% --- Count the number of frames with poor tracking ---

count_bc = 0;
count_nose = 0;

for i=1:factors.frames
    if tbl_new.bodycentre_2(i,1) < 0.9
        count_bc = count_bc + 1;
    end
    
    if tbl_new.nose_2(i,1) < 0.9
        count_nose = count_nose + 1;
    end
end

writematrix(factors.frames,datasheet_fullpath,'Sheet','Basics','Range',['B' num2str(idx+1)]);
writematrix(count_bc,datasheet_fullpath,'Sheet','Basics','Range',['C' num2str(idx+1)]);
writematrix(count_nose,datasheet_fullpath,'Sheet','Basics','Range',['D' num2str(idx+1)]);

disp(count_bc);
disp(count_nose);

close all;

%% -----------------------Correcting the transformed coordinates----------------------------%%
%% Location Variable
% This section is used to construct the location variable. This variable
% will store the true location of the animal, and NaN for all those frames
% in which tracking is not accurate. The variable is constructed using the
% bodycentre, nose and tailbase coordinates (in that order of preference).

tbl_new.locx = nan(frames,1);
tbl_new.locy = nan(frames,1);
tbl_new.locp = nan(frames,1);
tbl_new.locfillx = nan(frames,1);
tbl_new.locfilly = nan(frames,1);
tbl_new.locfillp = 0.5*ones(frames,1); % Gives a temporary p value to decice the color of the likelihood plot

count = 1;
for i=1:factors.frames
    if tbl_new.bodycentre_2(i,1) > 0.9
        tbl_new.locx(i,1) = tbl_new.bodycentre(i,1);
        tbl_new.locy(i,1) = tbl_new.bodycentre_1(i,1);
        tbl_new.locp(i,1) = tbl_new.bodycentre_2(i,1);
    elseif tbl_new.nose_2(i,1) > 0.9
        tbl_new.locx(i,1) = tbl_new.nose(i,1);
        tbl_new.locy(i,1) = tbl_new.nose_1(i,1);
        tbl_new.locp(i,1) = tbl_new.nose_2(i,1);
    elseif tbl_new.tailbase_2(i,1) > 0.9
        tbl_new.locx(i,1) = tbl_new.tailbase(i,1);
        tbl_new.locy(i,1) = tbl_new.tailbase_1(i,1);
        tbl_new.locp(i,1) = tbl_new.tailbase_2(i,1);
    else
        bad_frames(count) = i;
        count = count + 1;
    end
    
end

% Filling the NaN values of loc variables in the locfill variables
for i=1:factors.frames-1
    
    if ~isnan(tbl_new.locx(i,1)) && isnan(tbl_new.locx(i+1,1))
        start = i+1;
        start_x = tbl_new.locx(i,1);
        start_y = tbl_new.locy(i,1);
        
        for j=start:factors.frames-1
            if isnan(tbl_new.locx(j,1)) && ~isnan(tbl_new.locx(j+1,1))
                end_x = tbl_new.locx(j+1,1);
                end_y = tbl_new.locy(j+1,1);
                count_frames = j-start+1;
                finish = j;
                break;
            end
        end
        
        if end_x && end_y
            step_x = (end_x - start_x)/(count_frames+1);
            step_y = (end_y - start_y)/(count_frames+1);
            
            for frame = start-1:finish+1
                tbl_new.locfillx(frame,1) = start_x + (frame-start+1)*step_x;
                tbl_new.locfilly(frame,1) = start_y + (frame-start+1)*step_y;
            end
        end
        
    end
end


% Number of Frames with NaN location
disp("Number of Frames with NaN:");
disp(sum(isnan(tbl_new.locx)));
writematrix(sum(isnan(tbl_new.locx)),datasheet_fullpath,'Sheet','Basics','Range',['E' num2str(idx+1)]);

% Lineplot for this new location variable
if factors.draw_fig == 1
    Lineplot(tbl_new.locx, tbl_new.locy, tbl_new.locp, animal);
    hold all;
    Lineplot(tbl_new.locfillx, tbl_new.locfilly, tbl_new.locfillp, animal);
    hold all;
    plot([tr_x tl_x bl_x br_x tr_x], [tr_y tl_y bl_y br_y tr_y], 'Color', 'k');
    xlim([-10 60]);
    ylim([-10 60]);
    h = get(gca);
    h.XAxis.Visible = 'off';
    h.YAxis.Visible = 'off';
    
    set(gcf, 'Position', [0, 0, 500, 500]);
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperOrientation','landscape');
    saveas(gcf, [fig_path filesep [name '_NewLocVariable.png']]);
    print('-painters','-dpdf', '-bestfit',[fig_path filesep [name '_NewLocVariable.pdf']]);
    close;
end

%% Draw Coordinate comparison graphs
% This section plots x and y coordinate graphs versus frames to represent
% how the coordinates appeared before and after the correction using the
% location variable strategy.


if factors.draw_fig == 1
    
    % --- New X and Y coordinates ---
    x = 1:factors.frames;
    subplot(2,1,1);
    plot(x, tbl_new.locx);
    hold;
    plot(x, tbl_new.locfillx, 'r');
    title('X-coordinate');
    box off;
    xlabel('Frames');
    ylabel('Coordinates in cm');
    subplot(2,1,2);
    plot(x, tbl_new.locy);
    hold;
    plot(x, tbl_new.locfilly, 'r');
    title('Y-coordinate');
    box off;
    xlabel('Frames');
    ylabel('Coordinates in cm');
    
    set(gcf, 'Position', get(0, 'Screensize'));
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperOrientation','landscape');
    saveas(gcf, [fig_path filesep [name '_XYCoordinates.png']]);
    print('-painters','-dpdf', '-bestfit',[fig_path filesep [name '_XYCoordinates.pdf']]);
    close all;
    
    % --- Comparing the X-coordinate ---
    subplot(2,1,1);
    plot(x, tbl_new.bodycentre);
    title('Old X-coordinate');
    box off;
    xlabel('Frames');
    ylabel('Coordinates in cm');
    subplot(2,1,2);
    plot(x,tbl_new.locx);
    hold all;
    plot(x, tbl_new.locfillx, 'r');
    title('Updated X-coordinate');
    box off;
    xlabel('Frames');
    ylabel('Coordinates in cm');
    
    set(gcf, 'Position', get(0, 'Screensize'));
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperOrientation','landscape');
    saveas(gcf, [fig_path filesep [name '_XCoordinates.png']]);
    print('-painters','-dpdf', '-bestfit',[fig_path filesep [name '_XCoordinates.pdf']]);
    close all;
    
    % --- Comparing the Y-coordinate ---
    subplot(2,1,1);
    plot(x, tbl_new.bodycentre_1);
    title('Old y-coordinate');
    box off;
    xlabel('Frames');
    ylabel('Coordinates in cm');
    subplot(2,1,2);
    plot(x,tbl_new.locy);
    hold all;
    plot(x, tbl_new.locfilly, 'r');
    title('New y-coordinate');
    box off;
    xlabel('Frames');
    ylabel('Coordinates in cm');
    
    set(gcf, 'Position', get(0, 'Screensize'));
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperOrientation','landscape');
    saveas(gcf, [fig_path filesep [name '_YCoordinates.png']]);
    print('-painters','-dpdf', '-bestfit',[fig_path filesep [name '_YCoordinates.pdf']]);
    close all;
end

%% Filling the NaN values in the location variable
% This section fills the NaN values in the location variable using the
% 'locfillx' and 'locfilly' variables. The number of remaining NaN values
% for the location variable are then entered into the 'Data' excelsheet.

for i=1:factors.frames
    if isnan(tbl_new.locx(i,1))
        tbl_new.locx(i,1) = tbl_new.locfillx(i,1);
        tbl_new.locy(i,1) = tbl_new.locfilly(i,1);
        tbl_new.locp(i,1) = tbl_new.locfillp(i,1);
    end
end

% NaNs in final Location variable
writematrix(sum(isnan(tbl_new.locx)),datasheet_fullpath,'Sheet','Basics','Range',['F' num2str(idx+1)]);



%% -----------------------------Understanding Escape and Freezing Responses------------------------------%%
%% Understanding Escape Responses using function

if isfield(factors, 'mov')
    
    stimulus_details.num_stim = sum(~isnan(factors.mov));
    stimulus_details.stim = factors.mov;
    for i=1:stimulus_details.num_stim
        stimulus_details.curr_duration(i) = factors.mov_duration(i,1);
        stimulus_details.show_duration(i) = max(stimulus_details.curr_duration) + 2;
    end
    factors.method = 'sweep';
    EscapeRes = Escape_Responses(factors, tbl_new, stimulus_details);
end
    
if isfield(factors, 'loom')
    
    stimulus_details.num_stim = sum(~isnan(factors.loom));
    stimulus_details.stim = factors.loom;
    for i=1:stimulus_details.num_stim
        stimulus_details.curr_duration(i) = 2.5;
        stimulus_details.show_duration(i) = 8;
    end
    factors.method = 'loom';
    EscapeRes = Escape_Responses(factors, tbl_new, stimulus_details);
    
end

