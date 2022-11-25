function risk = Risk_function(tbl, factors, measures, condition)

if ~exist('condition', 'var')
    condition = 'n';
end

% Setting the time parameter values based on the condition
if condition == 'c'
    disp('Cat Condition');
    time_start = factors.timec;
    time_end = factors.timec_end;
    time_fab = factors.timec_fab;
    time_fab_true = factors.timec_fab;
    index = factors.cat_index;
    name = [factors.name ' Cat'];
elseif condition == 'b'
    disp('Baseline Condition');
    time_start = factors.timeb;
    time_end = factors.timeb_end;
    time_fab = factors.timeb_fab;
    time_fab_true = factors.timeb_fab_true;
    index = factors.basal_index;
    name = [factors.name ' Baseline'];
elseif condition == '1'
    disp('Hab1');
    time_start = factors.time1;
    time_end = factors.time1_end;
    time_fab = factors.time1_fab;
    time_fab_true = factors.time1_fab;
    index = factors.hab1_index;
    name = [factors.name ' Hab1'];
elseif condition == '2'
    disp('Hab2');
    time_start = factors.time2;
    time_end = factors.time2_end;
    time_fab = factors.time2_fab;
    time_fab_true = factors.time2_fab;
    index = factors.hab2_index;
    name = [factors.name ' Hab2'];   
elseif condition == '3'
    disp('Hab3');
    time_start = factors.time3;
    time_end = factors.time3_end;
    time_fab = factors.time3_fab;
    time_fab_true = factors.time3_fab;
    index = factors.hab3_index;
    name = [factors.name ' Hab3']; 
elseif condition == '4'
    disp('Hab4');
    time_start = factors.time4;
    time_end = factors.time4_end;
    time_fab = factors.time4_fab;
    time_fab_true = factors.time4_fab;
    index = factors.hab4_index;
    name = [factors.name ' Hab4'];  
else
    time_start = factors.time_start;
    time_end = factors.time_end;
    time_fab = factors.time_fab;
    time_fab_true = factors.time_fab;
    index = factors.index;
    name = [factors.name ' ' factors.cond];
end


nose_x = tbl.nose;
len = factors.length;

%% Time Spent in Danger Zone and Safe Zone
% Calculating the amount of time the animal spent in the safe and danger
% zone

dzone = (tbl.nose(time_start:time_fab_true, 1) < measures.bound_x);
szone = (tbl.nose(time_start:time_fab_true, 1) > measures.bound_x_opp);
risk.dzone_time = sum(dzone(dzone==1))/25;
risk.szone_time = sum(szone(szone==1))/25;



%% Average Length after Length Thresholding using baseline and x-coordinate threshold
% Variables used: factors.avg_length_baseline, factors.std_length_baseline
% These variables are set in the Basic Parameters section while calculating

% Setting basic parameters
if condition == 'c' || condition == 'b'
    x_mean = factors.avg_length_baseline;
    x_std = factors.std_length_baseline;
elseif condition == '1'
    x_mean = factors.avg_length_hab1;
    x_std = factors.std_length_hab1;
elseif condition == '2'
    x_mean = factors.avg_length_hab2;
    x_std = factors.std_length_hab2;
elseif condition == '3'
    x_mean = factors.avg_length_hab3;
    x_std = factors.std_length_hab3;
elseif condition == '4'
    x_mean = factors.avg_length_hab4;
    x_std = factors.std_length_hab4;
else
    x_mean = factors.avg_length;
    x_std = factors.std_length;
end
fig_path = [factors.datasheet_path filesep factors.name];

% Basic Length graph
plot(len);
xline(time_start, '-', 'Start');
xline(time_fab_true, '-', 'End');
yline(x_mean + x_std, '-', 'UpperThreshold');
yline(x_mean - x_std, '-', 'LowerThreshold');
xlabel('Frames');
ylabel('Length in cm');
title(name);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);
set(gcf,'PaperPositionMode','auto'); 
set(gcf,'PaperOrientation','landscape');
saveas(gcf, [fig_path filesep 'Length1_' name '.png']);
print('-painters','-dpdf', '-bestfit',[fig_path filesep 'Length1_' name '.pdf']);
close;

% Calculation of len_avg_x
count_avg_x = 1;
len_avg_x = 0;
for i = time_start:time_fab_true
    con1 = nose_x(i,1) < measures.bound_x;
    con2 = len(i,1) > (x_mean + x_std);
    if con1 && con2
        len_avg_x = len_avg_x+len(i,1);
        time_stamps(count_avg_x, 1) = i;
        count_avg_x = count_avg_x + 1;
    end
end

risk.len_avg_x = len_avg_x/(count_avg_x-1);
risk.risk_assess_time = length(time_stamps)/factors.frame_rate;
dispVar = ['Risk Assessment Avg. Length (from time_start to time_fab_true): ', num2str(risk.len_avg_x)];
disp(dispVar);
dispVar = ['Risk Assessment Duration (from time_start to time_fab_true): ', num2str(risk.risk_assess_time)];
disp(dispVar);


%% Calculating Various Length parameters

len_left = nose_x < measures.bound_x;
len_right = nose_x > measures.bound_x_opp;
len_middle = nose_x >= measures.bound_x & nose_x <= measures.bound_x_opp;
len_above_thresh_x  = nose_x < measures.bound_x & len > (x_mean+x_std);
len_above_thresh = len > (x_mean+x_std);

len_left = len_left.*len;
len_right = len_right.*len;
len_middle = len_middle.*len;
len_above_thresh_x = len_above_thresh_x.*len;
len_above_thresh = len_above_thresh.*len;

len_left(len_left==0) = nan;
len_right(len_right==0) = nan;
len_middle(len_middle==0) = nan;
len_above_thresh_x(len_above_thresh_x==0) = nan;
len_above_thresh(len_above_thresh==0) = nan;

risk.avg_len_left = mean(len_left(time_start:time_fab_true,1), 'omitnan');
risk.avg_len_right = mean(len_right(time_start:time_fab_true,1), 'omitnan');
risk.avg_len_middle = mean(len_middle(time_start:time_fab_true,1), 'omitnan');
risk.avg_len_above_thresh = mean(len_above_thresh(time_start:time_fab_true,1), 'omitnan');
risk.avg_len_above_thresh_x = mean(len_above_thresh_x(time_start:time_fab_true,1), 'omitnan');
risk.avg_len = mean(len(time_start:time_fab_true,1), 'omitnan');

%% Plot Length graph based on position and thresholds

plot(len(1:time_fab_true), 'Color', 'b');
hold all;
plot(len_left(1:time_fab_true), 'Color', 'r');
hold all;
plot(len_right(1:time_fab_true), 'Color', 'g');
xline(time_start, '-', 'Start');
xline(time_fab_true, '-', 'End');
yline(x_mean + x_std, '-', 'UpperThreshold');
yline(x_mean - x_std, '-', 'LowerThreshold');
xlabel('Frames');
ylabel('Length(cm)');
legend('Middle', 'Danger', 'Safe');
box off;
title(name);

set(gcf, 'Position', get(0, 'Screensize'));
set(gcf,'PaperPositionMode','auto'); 
set(gcf,'PaperOrientation','landscape');
saveas(gcf, [fig_path filesep 'Length2_' name '.png']);
print('-painters','-dpdf', '-bestfit',[fig_path filesep 'Length2_' name '.pdf']);
close;

%% Plot all the stretching events

count_beforeStart = 0;
count_afterStart = 0;
count_beforeStart_DangerZone = 0;
count_afterStart_DangerZone = 0;

for i = time_start:time_fab_true
    con1 = nose_x(i,1) < measures.bound_x;
    con2 = len(i,1) > (x_mean + x_std);
    if con2
        count_afterStart = count_afterStart + 1;
        plot([tbl.nose(i,1), tbl.bodycentre(i,1), tbl.tailbase(i,1)], [tbl.nose_1(i,1), tbl.bodycentre_1(i,1), tbl.tailbase_1(i,1)], 'Color',[0.7 0.7 0.7]);
        hold all;
        plot(tbl.nose(i,1), tbl.nose_1(i,1), 'ro', 'MarkerSize', 5,'Color', 'r');
        hold all;
        plot(tbl.tailbase(i,1), tbl.tailbase_1(i,1), 'ro', 'MarkerSize', 5,'Color', 'b');
        hold all;
    end
    if con1 && con2
        count_afterStart_DangerZone = count_afterStart_DangerZone + 1;
    end
end

plot([measures.bl_x, measures.br_x, measures.tr_x, measures.tl_x, measures.bl_x],....
        [measures.bl_y, measures.br_y, measures.tr_y, measures.tl_y, measures.bl_y], 'Color', 'k');
xlim([measures.left_x-5 measures.right_x+5]);
ylim([measures.br_y-5 measures.tr_y+5]);
xlabel('X coordinates (cm)');
ylabel('Y coordinates (cm)');
title('Stretched Length');
saveas(gcf, [fig_path filesep ['RiskAssessments_Lengths_' factors.cond '.png']]);
print('-painters','-dpdf', '-bestfit',[fig_path filesep ['RiskAssessments_Lengths_' factors.cond '.pdf']]);
close;


for i=1:time_start-1
    con1 = nose_x(i,1) < measures.bound_x;
    con2 = len(i,1) > (x_mean + x_std);
    if con2
        count_beforeStart = count_beforeStart + 1;
    end
    if con1 && con2
        count_beforeStart_DangerZone = count_beforeStart_DangerZone + 1;
    end
end

risk.count_afterStart = count_afterStart;
risk.count_afterStart_DangerZone = count_afterStart_DangerZone;
risk.count_beforeStart = count_beforeStart;
risk.count_beforeStart_DangerZone = count_beforeStart_DangerZone;

%% Is mouse in the danger zone or the safe zone?

body_centre = tbl.bodycentre;
count_left = 1;
for i=1:length(nose_x)
    if body_centre(i,1) < measures.bound_x
        pos_left(i, 1) = 1;
        count_left = count_left + 1;
    else
        pos_left(i, 1) = 0;
    end
end

count_left = count_left - 1;

count_right = 1;
for i=1:length(nose_x)
    if body_centre(i,1) > measures.bound_x_opp
        pos_right(i, 1) = 1;
        count_right = count_right + 1;
    else
        pos_right(i, 1) = 0;
    end
end

count_right = count_right - 1;
risk.pos_left = pos_left;
risk.pos_right = pos_right;

%% To and fro motion
% The main variable on which the algorithm depends: bound_x_opp and bound_x

% Calculating the time points when the animal leaves and then re-enters the
% Danger Zone. count_exit and count_enter are the counter variables for
% the number of times the animal leaves the DZone and re-enter the DZone
% respectively. pos_left_exit and pos_left enter store the timestamps of
% the exit and entry points.
count_exit = 1;
count_enter = 1;
for i=time_start:time_fab_true
    if pos_left(i,1) == 1 && pos_left(i+1, 1) == 0
        pos_left_exit(count_exit,1) = i;  %(i+1) because the frame at which the animal is not in the DZone
        count_exit = count_exit + 1;
        
        for j=i:length(pos_left)
            if pos_left(j,1) == 1 && pos_left(j-1,1) == 0
                pos_left_enter(count_enter, 1) = j;  %j because the frame at which the animal is in the DZone
                count_enter = count_enter+1;
                break;
            end
        end
        
    end
end


% Calculating the time points when the animal leaves the Danger Zone and
% then enters the Safe Zone in order to get the escape periods. count_run
% stores the number of times the animal runs from the DZone to the SZone.
% The first column in index stores the timepoints at which the animal
% leaves the DZone, the second column stores the timepoints at which the
% animal enter the SZone.
count_run = 1;
for i=1:length(pos_left_exit)
    for j=pos_left_exit(i,1):pos_left_enter(i,1)
        if j > time_fab_true
            break;
        elseif body_centre(j,1) > measures.bound_x_opp
            index(count_run, 1) = pos_left_exit(i,1);
            index_1(count_run, 1) = pos_left_exit(i,1)/25;
            index(count_run, 2) = j;
            index_1(count_run, 2) = j/25;
            count_run = count_run + 1;
            break;
        end
    end
end

% Calculates the time points at which the animal leaves the Safe Zone 
% In order to move the fabric, the animal will have to come out of the
% SZone.So there will be a timestamp corresponding to the moment when the
% animal leaves the SZone. The third column of index stores the timepoints
% at which the animal comes out of the SZone.
for i = 1:size(index,1)
    for j = index(i,2):time_fab_true
        if pos_right(j,1) == 0 && pos_right(j-1,1) == 1
            index(i,3) = j;
            break;
        elseif j==time_fab_true
            index(i,3) = j;
        end
    end
end

% Calculates the time points at which the animal re-enters the Danger Zone
% It is possible that the animal does not reenter the DZone near
% time_fab_true. It can stay in the middle region and pull the fabric out.
% So in such cases we use, the re-entry time as time_fab_true itself.
% The fourth column of index stores the timepoints of re-entry to DZone.
for i = 1:size(index,1)
    for j = index(i,2):time_fab_true
        if pos_left(j,1) == 1 && pos_left(j-1,1) == 0
            index(i,4) = j;
            break;
        elseif j == time_fab_true
            index(i,4) =j;
        end
    end
end


count_run = count_run - 1;
risk.count_run = count_run;
risk.index = index;
dispVar = ['The number of to-fro (from time_start to time_fab_true): ', num2str(risk.count_run)];
disp(dispVar);

% Plots the x-coordinate graph with xlines where the animal leaves the
% DZone and when the animal re-enters the DZone.
plot(nose_x(1:time_fab_true), 'g');
for i = 1:size(index,1)
    xline(index(i,1), '--r');
    xline(index(i,4), '--b');
end
xline(time_start, '-', 'Start');
xline(time_fab_true, '-', 'End');
title(name);
xlabel('Frames');
ylabel(' X coordinate(cm)');
box off;

set(gcf, 'Position', get(0, 'Screensize'));
set(gcf,'PaperPositionMode','auto'); 
set(gcf,'PaperOrientation','landscape');
saveas(gcf, [fig_path filesep 'ToFro_' name '.png']);
print('-painters','-dpdf', '-bestfit',[fig_path filesep 'ToFro_' name '.pdf']);
close;


    

%% Speed Calculations

% Basic Speed calculation
speed = Speed(tbl.tailbase, tbl.tailbase_1);

% Calculating the average velocity in the period from time_start to
% time_fab_true.
risk.avg_speed = factors.frame_rate * mean(speed(time_start:time_fab_true,1));

% Calculating the escape velocity - the velocity with which the animal runs
% away from the DZone to the SZone.
count_escape_vel = 1;
escape_vel = 0;
for i=1:size(index, 1)
    for j=index(i,1):index(i,2)
        escape_vel = escape_vel + speed(j,1);
        count_escape_vel = count_escape_vel +1;
    end
end

escape_vel = escape_vel*factors.frame_rate/(count_escape_vel-1);
risk.escape_vel = escape_vel;
dispVar = ['The escape velocity: ', num2str(risk.escape_vel)];
disp(dispVar);

% Calculating the approach velocity - the velocity with which the animal
% approaches the DZone from the SZone.
% if index(i,3) == index(i,4) => animal remains in the safe zone; happens 
% for baseline videos when fabric is not moved
count_approach_vel = 1;
approach_vel = 0;
for i=1:size(index, 1)
    if index(i,3) ~= index(i,4)   
        for j=index(i,3):index(i,4)
            approach_vel = approach_vel + speed(j,1);
            count_approach_vel = count_approach_vel +1;
        end
    end
end

approach_vel = approach_vel*factors.frame_rate/(count_approach_vel-1);
risk.approach_vel = approach_vel;
dispVar = ['The approach velocity: ', num2str(risk.approach_vel)];
disp(dispVar);

% Calculating the amount of time the animal stays in the SZone after
% escaping from the DZone
risk.avg_SZone_time = mean(index(:, 3) - index(:, 2))/factors.frame_rate;
risk.avg_away_time = mean(index(:, 4) - index(:, 1))/factors.frame_rate;
risk.avg_DZone_time = mean(index(2:size(index,1), 1) - index(1:size(index,1)-1,4))/factors.frame_rate;



