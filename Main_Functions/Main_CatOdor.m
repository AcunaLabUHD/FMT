function [measures, risk, factors, escape] = Main_CatOdor(name, cond, filename, datasheet_path, newfactors)

%% Reading a csv file

addpath(datasheet_path);
datasheet_fullpath = [datasheet_path filesep 'Data.xlsx'];    % Sheet to store all results


opts = detectImportOptions(filename, 'NumHeaderLines', 1);
opts.VariableNamesLine = 2;
opts.DataLine = 4;
tbl = readtable(filename,opts);

datasheet = readtable(datasheet_fullpath, 'Sheet', 'Basics');

animal_name = table2array(datasheet(:,1));
condition_name = table2array(datasheet(:,2));
start_time = table2array(datasheet(:,3));
stop_time = table2array(datasheet(:,4));
fab_time = table2array(datasheet(:,5));

idx = intersect(find(strcmp(animal_name, name)), find(strcmp(condition_name, cond)));
time_start = start_time(idx,1);
time_end = stop_time(idx,1);
time_fab = fab_time(idx,1);

factors.name = name;    % Name of the animal
factors.cond = cond;
factors.filename = filename;    % csv file 
factors.datasheet_path = datasheet_path;    % Path to the folder containing the Data sheet
factors.datasheet_fullpath = datasheet_fullpath;    % Full path of the Data sheet
factors.frame_rate = 25;    % 25 frames per seconds
factors.index = idx;    % Row index in the spreadsheet
factors.time_start = time_start * factors.frame_rate;    % Beginning of the trial
factors.time_fab = time_fab * factors.frame_rate;    % Time when the fabric is moved
factors.time_end = time_end * factors.frame_rate;
factors.xlen = 36.3;    % True length of the box in cm
factors.ylen = 15.4;    % True width of the box in cm
factors.std_length = 0; 
factors.avg_length = 0;


factors.plot = 1; % 1 if you want to make the plots

if nargin > 4
    factors = FactorsUpdate(factors,newfactors);
end

disp("Coordinate files are loaded");


%% BASIC SECTION
% CheckQuality; CorrectCoorinates; Diagonal; Ratio

% Declaring Variables of Interest
factors.quality_thresh = 0.95; % threshold for quality checking

%%%% QUALITY CHECKING %%%%
% This function checks the quality of the deeplabcut predictions based on
% the likelihood values and the factors.quality_thresh variable. It then
% fills these values in the sheet.
% function CheckQuality(table, factors, time_start, time_end, index)


time_end = size(tbl.nose,1)-10;
CheckQuality(tbl, factors, factors.time_start, time_end, factors.index);
disp("Quality checking done");

%%%%-----------------------------------------------------------------------------------------%%%%




%%%% COORDINATE CORRECTION %%%%
% Correct the coordinates from pixel to cm
% DO NOT RUN THIS CODE OVER AND OVER AGAIN as coordinates will keep getting
% updated
% function [tbl, x_pixel2cm, y_pixel2cm] = CorrectCoordinates(tbl,factors,start_time)

[tbl, measures] = CorrectCoordinates(tbl, factors, factors.time_start);

disp("Coordinates are corrected");
%%%%-----------------------------------------------------------------------------------------%%%%




%%%% DIAGONAL MEASUREMENT %%%%
% function dist = Diagonal(tbl, factors, time_start, time_end, index)

time_end = size(tbl.nose,1)-10;
diag = Diagonal(tbl, factors, factors.time_start, time_end, factors.index);
disp('The Diagonal measurement is:');
disp(diag);
%%%%-----------------------------------------------------------------------------------------%%%%



%%%% RATIO OF NOSE AND TAILBASE DISTANCE COVERED %%%%
% function ratio = Ratio(tbl, factors, index, startframe, endframe)

ratio = Ratio(tbl, factors, factors.index, factors.time_start, factors.time_fab);
disp('Ratio of Nose and Tailbase: ');
disp(ratio);
%%%%-----------------------------------------------------------------------------------------%%%%



%% Setting up the x-coordinate Threshold
% Boundaries are marked at 1/4th distance from left and 1/4th distance from
% right. This also sets the threshold for to-fro motion.

factors.ratio_r = 0.25;
factors.ratio_l = 0.75;

measures.left_x = min(measures.bl_x, measures.tl_x);
measures.right_x = max(measures.br_x, measures.tr_x);
measures.bound_x = measures.left_x + (measures.right_x-measures.left_x)*factors.ratio_r;
measures.bound_x_opp = measures.left_x + (measures.right_x - measures.left_x)*factors.ratio_l;


pos1 = [0, 0, measures.bound_x, factors.ylen];
pos2 = [measures.bound_x, 0, measures.bound_x_opp - measures.bound_x, factors.ylen];
pos3 = [measures.bound_x_opp, 0, factors.xlen-measures.bound_x_opp, factors.ylen];
rectangle('Position', pos1, 'FaceColor', 'r', 'EdgeColor', 'k');
rectangle('Position', pos2, 'FaceColor', 'b', 'EdgeColor', 'k');
rectangle('Position', pos3, 'FaceColor', 'g', 'EdgeColor', 'k');
xlim([-5 factors.xlen+5]);
ylim([-5 factors.ylen+5]);

fig_path = [factors.datasheet_path filesep factors.name];
if ~exist(fig_path)
    mkdir(fig_path);
end
saveas(gcf, [fig_path filesep ['DifferentZones_' cond '.png']]);
print('-painters','-dpdf', '-bestfit',[fig_path filesep ['DifferentZones_' cond '.pdf']]);
close;


%% The Position Density Plots
% Construct the position density plot to show the position of the animal in
% the rectangular field in the period start_time till the fabric is moved
fig_path = [factors.datasheet_path filesep factors.name];
if ~exist(fig_path)
    mkdir(fig_path);
end

% By default, the densityplot function divides the grid into a region of
% 10X10 small boxes and the number of coordinates in each box is counter.
% This number is represented on the colorbar. Instead of 10X10, we can
% change the value to anything MXN by passing an argument [M,N] in the
% function.
densityplot(tbl.nose(factors.time_start:factors.time_fab,1), tbl.nose_1(factors.time_start:factors.time_fab,1))
xlim([-5 factors.xlen+5]);
ylim([-5 factors.ylen+5]);
xlabel('X coordinates (cm)');
ylabel('Y coordinates (cm)');
set(gca, 'box', 'off');
title('Position Density Plot');
saveas(gcf, [fig_path filesep ['Position_Density_' cond '.png']]);
print('-painters','-dpdf', '-bestfit',[fig_path filesep ['Position_Density_' cond '.pdf']]);
close;


%% Basic Plots
% Nose-Based; Likelihood values based; X-coordinate based

%%%% NOSE BASED PLOTTING %%%%
% Plotting nose positions from timeb/timec to timeb_fab/timec_fab
% The box is also plotted based on the measures_b and measures_c parameters
% Dotplot(var_x, var_y, var_name, startframe, endframe)


if factors.plot == 1
    fig_path = [factors.datasheet_path filesep factors.name];
    if ~exist(fig_path)
        mkdir(fig_path);
    end
    
    Dotplot(tbl.nose, tbl.nose_1, factors.time_start,factors.time_fab);
    title('Nose');
    axis([-5 45 -5 20]);
    hold all;
    plot([measures.bl_x, measures.br_x, measures.tr_x, measures.tl_x, measures.bl_x],....
        [measures.bl_y, measures.br_y, measures.tr_y, measures.tl_y, measures.bl_y]);
    saveas(gcf, [fig_path filesep ['Nose_DotPlot_' cond '.png']]);
    print('-painters','-dpdf', '-bestfit',[fig_path filesep ['Nose_DotPlot_' cond '.pdf']]);
    close;
    %%%%-----------------------------------------------------------------------------------------%%%%
    
    
    
    
    %%%% LIKELIHOOD VALUES BASED PLOTTING %%%%
    % Plotting from timeb/timec to (end of video - 10 frames)
    % The box is also plotted based on the measures_b and measures_c parameter
    % Lineplot(var_x, var_y, var_p, var_name, startframe, endframe)
    
    Lineplot(tbl.nose, tbl.nose_1, tbl.nose_2, 'Nose Basal', factors.time_start);
    axis([-5 45 -5 20]);
    hold all;
    plot([measures.bl_x, measures.br_x, measures.tr_x, measures.tl_x, measures.bl_x],....
        [measures.bl_y, measures.br_y, measures.tr_y, measures.tl_y, measures.bl_y],'k');
    title(['Likelihood Line Plot ' cond]);
    saveas(gcf, [fig_path filesep ['Likelihood_Lineplot_' cond '.png']]);
    print('-painters','-dpdf', '-bestfit',[fig_path filesep ['Likelihood_Lineplot_' cond '.pdf']]);
    close;
    %%%%-----------------------------------------------------------------------------------------%%%%
    
    
    
    
    %%%% X-COORDINATE BASED PLOTTING %%%%
    % Plots the x-coordinates of the nose for the entire period
    
  
    plot(tbl.nose);
    xline(factors.time_start, '-', 'Start');
    xline(factors.time_fab, '-', 'Fabric Move');
    xline(factors.time_end, '-', 'End');
    title('Baseline');
    xlabel('Frames');
    ylabel(' X coordinate in cm');
    
    set(gcf, 'Position', get(0, 'Screensize'));
    set(gcf,'PaperPositionMode','auto'); 
    set(gcf,'PaperOrientation','landscape');
    saveas(gcf, [fig_path filesep ['X_coordinate_' cond '.png']]);
    print('-painters','-dpdf', '-bestfit',[fig_path filesep ['X_coordinate_' cond '.pdf']]);
    close;
    %%%%-----------------------------------------------------------------------------------------%%%%
end


%% BASIC Parameters
% Distance travelled; Length; Speed

%%%% DISTANCE TRAVELLED %%%%
distance = Distance(tbl.tailbase, tbl.tailbase_1, factors.time_start, factors.time_end);
writematrix(distance,factors.datasheet_fullpath,'Sheet','Basics','Range',['H' num2str(factors.index+1)]);
%%%%-----------------------------------------------------------------------------------------%%%%


%%%% AVERAGE LENGTH %%%%
% The avg_length_baseline and avg_length_cat parameters will be used in the

length = Length(tbl);
length = medfilt1(length, 5);
length(length>11) = nan;
length(length<4) = nan;

factors.length = length;
if factors.avg_length==0 && factors.std_length==0
    factors.avg_length = nanmean(length(factors.time_start:factors.time_end,1));
    factors.std_length = nanstd(length(factors.time_start:factors.time_end,1));
end

writematrix(factors.avg_length,factors.datasheet_fullpath,'Sheet','Basics','Range',['I' num2str(factors.index+1)]);
%%%%-----------------------------------------------------------------------------------------%%%%




%%%% AVERAGE SPEED %%%%
% Multiplied by frame_rate to get (cm/second) from (cm/frame)
speed = Speed(tbl.bodycentre, tbl.bodycentre_1) * factors.frame_rate;
avg_speed = mean(speed(factors.time_start:factors.time_end,1));

writematrix(avg_speed,factors.datasheet_fullpath,'Sheet','Basics','Range',['J' num2str(factors.index+1)]);
%%%%-----------------------------------------------------------------------------------------%%%%


%% Risk Assessment

risk = Risk_function(tbl, factors, measures);
% writematrix(risk.dzone_time,factors.datasheet_fullpath,'Sheet','Data','Range',['F' num2str(factors.index+1)]);
% writematrix(risk.szone_time,factors.datasheet_fullpath,'Sheet','Data','Range',['G' num2str(factors.index+1)]);
% writematrix(risk.avg_len,factors.datasheet_fullpath,'Sheet','Data','Range',['H' num2str(factors.index+1)]);
% writematrix(risk.len_avg_x,factors.datasheet_fullpath,'Sheet','Data','Range',['I' num2str(factors.index+1)]);
% writematrix(risk.risk_assess_time,factors.datasheet_fullpath,'Sheet','Data','Range',['J' num2str(factors.index+1)]);
% writematrix(risk.count_run,factors.datasheet_fullpath,'Sheet','Data','Range',['K' num2str(factors.index+1)]);
% writematrix(risk.avg_SZone_time,factors.datasheet_fullpath,'Sheet','Data','Range',['L' num2str(factors.index+1)]);
% writematrix(risk.avg_DZone_time,factors.datasheet_fullpath,'Sheet','Data','Range',['M' num2str(factors.index+1)]);
% writematrix(risk.avg_away_time,factors.datasheet_fullpath,'Sheet','Data','Range',['N' num2str(factors.index+1)]);
% writematrix(risk.escape_vel,factors.datasheet_fullpath,'Sheet','Data','Range',['O' num2str(factors.index+1)]);
% writematrix(risk.approach_vel,factors.datasheet_fullpath,'Sheet','Data','Range',['P' num2str(factors.index+1)]);
% writematrix(risk.avg_speed,factors.datasheet_fullpath,'Sheet','Data','Range',['Q' num2str(factors.index+1)]);
% writematrix(risk.mean_left,factors.datasheet_fullpath,'Sheet','Data','Range',['R' num2str(factors.index+1)]);
% writematrix(risk.mean_right,factors.datasheet_fullpath,'Sheet','Data','Range',['S' num2str(factors.index+1)]);


%% Escape Responses

pos_left = risk.pos_left;
pos_left(pos_left==0) = nan;
pos_right = risk.pos_right;
pos_right(pos_right==0) = nan;

pos_mid = risk.pos_left + risk.pos_right;
pos_mid(isnan(pos_mid)) = 0;
pos_mid(pos_mid==1) = nan;
pos_mid(pos_mid==0) = 1; 

vel_left = nan(size(speed));
vel_mid = nan(size(speed));
vel_right = nan(size(speed));

for i=1:size(speed,1)-10
    if pos_left(i,1) == 1
        vel_left(i,1) = speed(i,1);
    elseif pos_mid(i,1) == 1
        vel_mid(i,1) = speed(i,1);
    elseif pos_right(i,1) == 1
        vel_right(i,1) = speed(i,1);
    end
end

avg_speed_left = nanmean(vel_left);
avg_speed_mid = nanmean(vel_mid);
avg_speed_right = nanmean(vel_right);

index = risk.index;
for i=1:size(index,1)
    start_frame = index(i,1);
    end_frame = index(i,2);
    Lineplot(tbl.bodycentre, tbl.bodycentre_1, tbl.bodycentre_2, factors.name, start_frame, end_frame);
    hold all;
    plot(tbl.bodycentre(start_frame,1), tbl.bodycentre_1(start_frame,1), 'ro', 'MarkerSize', 5);
    escape.speed(i) = nanmean(speed(index(i,1):index(i,2)));
    escape.dist(i) = sum(speed(index(i,1):index(i,2))/25);
end
plot([measures.bl_x, measures.br_x, measures.tr_x, measures.tl_x, measures.bl_x],....
        [measures.bl_y, measures.br_y, measures.tr_y, measures.tl_y, measures.bl_y],'k');
ylim([-5 20]);      
xlim([-5 40]);
set(gcf,'PaperPositionMode','auto'); 
set(gcf,'PaperOrientation','landscape');
saveas(gcf, [fig_path filesep ['EscapeReponses_' cond '.png']]);
print('-painters','-dpdf', '-bestfit',[fig_path filesep ['EscapeResponses_' cond '.pdf']]);
close;

end