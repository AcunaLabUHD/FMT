function EscapeRes = Escape_Responses(factors, tbl_new, stimulus_details)

draw_fig_comp = 0;

% Main parameters
time_fastEscape = 2.5;
maxspeed_fastEscape = 40;
closeness_attemptedEscape = 5;  % Distance in cm, animal should be in this range for attempted Escape response
initial_attemptedEscape = 10;   % Distance in cm, animal should be at the start for attempted Escape response
time_shortFreeze = 0.3;
time_longFreeze = 1;
max_dist = 0.25; % For freezing Behaviour

% Details extracted from the stimulus_details variables
num_stim = stimulus_details.num_stim;
stim = stimulus_details.stim;
curr_duration = stimulus_details.curr_duration;
show_duration = stimulus_details.show_duration;

frate = factors.frame_rate;
home_x = nanmean(tbl_new.home);
home_y = nanmean(tbl_new.home_1);
var_x = tbl_new.locx;
var_y = tbl_new.locy;

label_escape = [];     % To be used for escape responses
label_freeze = [];     % To be used for escape responses
attemptedEscape = [];  % Attempted Escape behaviour
fastEscape = [];       % Fast Escape behavior
slowEscape = [];
enterEscape_frame = []; % Frame at which the animal enters the shelter
beginEscape_frame = [];
longFreeze = [];
shortFreeze = [];
NA = [];
random = [];
freezetimes = {};
fastfreeze_end = nan(1,num_stim);






%% Calculate the distance from the shelter and the speed of the animal
% Calculate the distance from the shelter (top-right corner)
for i=1:factors.frames
    dist_x = abs(var_x(i,1) - home_x);
    dist_y = abs(var_y(i,1) - home_y);
    dist_x = dist_x*dist_x;
    dist_y = dist_y*dist_y;
    dist(i,1) = sqrt(dist_x + dist_y);
    
    if var_x(i,1) <= home_x && var_y(i,1) <= home_y
        dist(i,1) = dist(i,1)*(-1);
    end
end

% Calculate the speed
% To get speed in cm/sec, we have multiplied by frate
vel = Speed(tbl_new.locx, tbl_new.locy)*frate;

%% Classification of responses

for i=1:num_stim
    start_frame = floor(stim(i,1)*frate);
    end_frame = floor((stim(i,1)+time_fastEscape)*frate);
    
    % To check if the animal ever entered the shelter in the period from
    % start_frame to end_frame. It is possible that the animal enters the
    % shelter and then comes out.
    con_escape = 0;
    for check_frame=start_frame:end_frame
        if dist(check_frame,1) < 0
            con_escape = 1;
        end
    end
    
    % Check if animal reaches shelter within 2.5 sec
    if con_escape == 1 && dist(start_frame, 1) > 0
        
        % Find the frame at which the animal entered the shelter
        for j=start_frame:end_frame
            if dist(j-1,1) > 0 && dist(j,1) <= 0
                enter_frame = j;
                break;
            end
        end
        
        % Calculating the freezing time and freezing part of the response
        image_name = [factors.filepath filesep [factors.name '_FreezingResponses_' num2str(i)]];
        duration = Freezing(var_x(start_frame:enter_frame,1), var_y(start_frame:enter_frame,1), image_name);
        freezetimes{i} = duration + start_frame-1;
        
        if ~isnan(duration)
            freeze_time = sum(duration(:,2) - duration(:,1) + 1);
            max_freeze_time = max(duration(:,2) - duration(:,1) + 1)/frate;
        else
            freeze_time = 0;
            max_freeze_time = 0;
        end
        
        if max_freeze_time >= time_longFreeze
            label_freeze{i} = 'Long Freeze';
            longFreeze = [longFreeze, i];
        elseif max_freeze_time >= time_shortFreeze
            label_freeze{i} = 'Short Freeze';
            shortFreeze = [shortFreeze, i];
        else
            label_freeze{i} = 'No Freeze';
        end
        
      
        if max(vel(enter_frame - floor(frate):enter_frame,1)) >= maxspeed_fastEscape
            label_escape{i} = 'Fast Escape';
            fastEscape = [fastEscape, i];
            enterEscape_frame(i) = enter_frame;
            beginEscape_frame(i) = DetectStartofEscape(vel,start_frame, enter_frame, maxspeed_fastEscape, frate);
        else
            label_escape{i} = 'Slow Escape';
            slowEscape = [slowEscape, i];
            enterEscape_frame(i) = enter_frame;
            beginEscape_frame(i) = DetectStartofEscape(vel, start_frame, enter_frame, maxspeed_fastEscape/2, frate);
        end
        
        
        % If the animal never enters the shelter until 2.5 seconds in case
        % of looming stimuli or curr_duration in case of sweeping stimuli.
    elseif dist(ceil((stim(i,1)+curr_duration(i))*frate),1) > 0 && dist(start_frame,1) > 0 && min(dist(start_frame:ceil((stim(i,1)+curr_duration(i))*frate),1))>=0
        
        end_frame = floor((stim(i,1)+curr_duration(i))*frate);
        
        % Calculating the freezing time
        image_name = [factors.filepath filesep [factors.name '_FreezingResponses_' num2str(i)]];
        duration = Freezing(var_x(start_frame:end_frame,1), var_y(start_frame:end_frame,1), image_name);
        freezetimes{i} = duration + start_frame-1;
        
        if ~isnan(duration)
            freeze_time = sum(duration(:,2) - duration(:,1) + 1);
            max_freeze_time = max(duration(:,2) - duration(:,1) + 1)/frate;
            
            if max_freeze_time >= time_shortFreeze
                
                final_val = start_frame + duration(end,2);
                
                % Calculate the freezing behaviour even after curr_duration seconds
                final_x = var_x(final_val,1);
                final_y = var_y(final_val,1);
                final_x_min = final_x - max_dist;
                final_x_max = final_x + max_dist;
                final_y_min = final_y - max_dist;
                final_y_max = final_y + max_dist;
                freeze_end_frame = final_val;
                
                for j = final_val:factors.frames
                    if var_x(j,1)>=final_x_min && var_x(j,1) <= final_x_max && var_y(j,1)>= final_y_min && var_y(j,1)<=final_y_max
                        freeze_end_frame = freeze_end_frame + 1;
                    else
                        break;
                    end
                end
                
                if freeze_end_frame > final_val
                    show_duration(i) = show_duration(i) + (freeze_end_frame-final_val)/frate;
                    freezetimes{i}(end) = freezetimes{i}(end) + (freeze_end_frame-final_val);
                    duration(end,2) = duration(end,2)+(freeze_end_frame-final_val);
                end
                
                max_freeze_time = max(duration(:,2) - duration(:,1) + 1)/frate;
                if max_freeze_time >= time_longFreeze
                    
                    label_freeze{i} = 'Long Freeze';
                    longFreeze = [longFreeze, i];
                    
                    fastfreeze_end(i) = freeze_end_frame - start_frame;
                    freeze_escape_startFrame = freeze_end_frame;
                    freeze_escape_endFrame = freeze_end_frame + ceil(2.5*frate);
                    if freeze_escape_endFrame > factors.frames
                        freeze_escape_endFrame = factors.frames;
                    end
                    
                    if dist(freeze_escape_startFrame,1) > 0 && min(dist(freeze_escape_startFrame:freeze_escape_endFrame,1)) < 0
                        for j=freeze_escape_startFrame:freeze_escape_endFrame
                            if dist(j-1,1) > 0 && dist(j,1) <= 0
                                enter_frame = j;
                                break;
                            end
                        end
                        
                        
                        if max(vel(enter_frame - floor(frate):enter_frame,1)) >= maxspeed_fastEscape
                            label_escape{i} = 'Fast Escape';
                            fastEscape = [fastEscape, i];
                            enterEscape_frame(i) = enter_frame;
                            beginEscape_frame(i) = DetectStartofEscape(vel, start_frame,enter_frame, maxspeed_fastEscape, frate);
                        else
                            label_escape{i} = 'Slow Escape';
                            slowEscape = [slowEscape, i];
                            enterEscape_frame(i) = enter_frame;
                            beginEscape_frame(i) = DetectStartofEscape(vel,start_frame, enter_frame, maxspeed_fastEscape/2, frate);
                        end
                        
                    elseif min(var_x(freeze_escape_startFrame:freeze_escape_endFrame,1) <= (home_x+closeness_attemptedEscape)) && min(var_y(freeze_escape_startFrame:freeze_escape_endFrame,1) <= (home_y+closeness_attemptedEscape))
                        if (var_x(start_frame,1) > (home_x+initial_attemptedEscape)) || (var_y(start_frame,1) > (home_y+initial_attemptedEscape))
                            label_escape{i} = 'Attempted Escape';
                            attemptedEscape = [attemptedEscape, i];
                        end
                    else
                        label_escape{i} = 'No Escape';
                    end
                    
                else
                    label_freeze{i} = 'Short Freeze';
                    shortFreeze = [shortFreeze, i];
                    fastfreeze_end(i) = freeze_end_frame - start_frame;
                    
                    if min(var_x(start_frame:end_frame,1) <= (home_x+closeness_attemptedEscape)) && min(var_y(start_frame:end_frame,1) <= (home_y+closeness_attemptedEscape))
                        if (var_x(start_frame,1) > (home_x+initial_attemptedEscape)) || (var_y(start_frame,1) > (home_y+initial_attemptedEscape))
                            label_escape{i} = 'Attempted Escape';
                            attemptedEscape = [attemptedEscape, i];
                        end
                    else
                        label_escape{i} = 'No Escape';
                    end
                    
                end
            else
                label_freeze{i} = 'No Freeze';
                label_escape{i} = 'No Escape';
            end
        else
            freeze_time = 0;
            label_freeze{i} = 'No Freeze';
            label_escape{i} = 'No Escape';
        end
        
        
    elseif min(dist(start_frame:ceil((stim(i,1)+curr_duration(i))*frate),1)) < 0 && dist(start_frame,1) > 0
        
        end_frame = ceil((stim(i,1)+curr_duration(i))*frate);
        for j=start_frame:end_frame
            if dist(j-1,1) > 0 && dist(j,1) <= 0
                enter_frame = j;
                break;
            end
        end
        
        image_name = [factors.filepath filesep [factors.name '_FreezingResponses_' num2str(i)]];
        duration = Freezing(var_x(start_frame:enter_frame,1), var_y(start_frame:enter_frame,1), image_name);
        freezetimes{i} = duration + start_frame - 1;
        
        if ~isnan(duration)
            freeze_time = sum(duration(:,2) - duration(:,1) + 1);
            max_freeze_time = max(duration(:,2) - duration(:,1) + 1)/frate;
            
            if max_freeze_time >= time_shortFreeze
                
                final_val = start_frame + duration(end,2);
               
                if max_freeze_time >= time_longFreeze
                    label_freeze{i} = 'Long Freeze';
                    longFreeze = [longFreeze, i];
                else
                    label_freeze{i} = 'Short Freeze';
                    shortFreeze = [shortFreeze, i];
                end
                escape_startFrame = final_val;
            else
                label_freeze{i} = 'No Freeze';
                escape_startFrame = start_frame;
            end
        else
            freeze_time = 0;
            label_freeze{i} = 'No Freeze';
            escape_startFrame = start_frame;
        end
        
        
        if strcmp(factors.method, 'loom')
            if max(vel(enter_frame - floor(frate):enter_frame,1)) >= maxspeed_fastEscape && freeze_time~=0
                label_escape{i} = 'Fast Escape';
                fastEscape = [fastEscape, i];
                enterEscape_frame(i) = enter_frame;
                beginEscape_frame(i) = DetectStartofEscape(vel,start_frame, enter_frame, maxspeed_fastEscape, frate);
            elseif freeze_time~=0
                label_escape{i} = 'Slow Escape';
                slowEscape = [slowEscape, i];
                enterEscape_frame(i) = enter_frame;
                beginEscape_frame(i) = DetectStartofEscape(vel,start_frame, enter_frame,max(vel(enter_frame - floor(frate):enter_frame,1))-2, frate);
            else
                label_escape{i} = 'No Escape';
            end
        elseif strcmp(factors.method, 'sweep')
            if max(vel(enter_frame - floor(frate):enter_frame,1)) >= maxspeed_fastEscape
                label_escape{i} = 'Fast Escape';
                fastEscape = [fastEscape, i];
                enterEscape_frame(i) = enter_frame;
                beginEscape_frame(i) = DetectStartofEscape(vel,start_frame, enter_frame, maxspeed_fastEscape, frate);
            else
                label_escape{i} = 'Slow Escape';
                slowEscape = [slowEscape, i];
                enterEscape_frame(i) = enter_frame;
                beginEscape_frame(i) = DetectStartofEscape(vel,start_frame, enter_frame,max(vel(enter_frame - floor(frate):enter_frame,1))-2, frate);
            end
        end
            
            
        elseif (dist(end_frame,1) < 0 && dist(start_frame,1) < 0) || (dist(end_frame,1) > 0 && dist(start_frame,1) < 0)
            label_escape{i} = 'NA';
            label_freeze{i} = 'NA';
            NA = [NA, i];
        else
            label_escape{i} = 'None';
            label_freeze{i} = 'None';
            random = [random, i];
        end
    end
    
    
    %% Plotting the Distance and velocity graphs
    
    % Distance
    for i=1:num_stim
        
        base_frame = floor((stim(i,1)-1)*frate);
        start_frame = floor(stim(i,1)*frate);
        if floor((stim(i,1)+show_duration(i))*frate) > factors.frames
            end_frame = factors.frames;
        else
            end_frame = floor((stim(i,1)+show_duration(i))*frate);
        end
        subplot(5, ceil(num_stim/5), i);
        plot(dist(base_frame:end_frame,1), '-', 'Color', 'b');
        hold;
        num_freezetimes = size(freezetimes{i},1);
        if ~isnan(freezetimes{i})
            for j = 1:num_freezetimes
                curr_freezetime_start = freezetimes{i}(j,1);
                curr_freezetime_end = freezetimes{i}(j,2);
                plot(curr_freezetime_start-base_frame+1:curr_freezetime_end-base_frame+1,dist(curr_freezetime_start:curr_freezetime_end,1), '-', 'Color', 'r');
                hold all;
            end
        end
        
        if ismember(i, fastEscape) || ismember(i,slowEscape)
            plot(beginEscape_frame(i)-base_frame+1:enterEscape_frame(i)-base_frame+1, dist(beginEscape_frame(i):enterEscape_frame(i),1), '-', 'Color', [0.4660 0.6740 0.1880]);
        end
        
        
        title([num2str(i) ')' label_escape{i} ' ' label_freeze{i}], 'FontSize', 8);
        xline(frate);
        xline(frate*(1+curr_duration(i)));
        ylim([-20 50]);
        xlim([0 frate*(show_duration(i)+1)]);
        h = get(gca);
        h.XAxis.Visible = 'off';
        set(gca, 'xtick', []);
        set(gca, 'ytick', []);
        yline(0, '--');
        box off;
        hold all;
        
    end
    sgtitle(factors.animal);
    
    set(gcf, 'Position', get(0, 'Screensize'));
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperOrientation','landscape');
    saveas(gcf, [factors.filepath filesep [factors.name '_Distance.png']]);
    print('-painters','-dpdf', '-bestfit',[factors.filepath filesep [factors.name '_Distance.pdf']]);
    close;
    
    % Speed
    for i=1:num_stim
        
        base_frame = floor((stim(i,1)-1)*frate);
        start_frame = floor(stim(i,1)*frate);
        if floor((stim(i,1)+show_duration(i))*frate) > factors.frames
            end_frame = factors.frames-1;
        else
            end_frame = floor((stim(i,1)+show_duration(i))*frate);
        end
        subplot(5, ceil(num_stim/5), i);
        
        plot(vel(base_frame:end_frame,1), '-', 'Color', 'b');
        hold;
        num_freezetimes = size(freezetimes{i},1);
        if ~isnan(freezetimes{i})
            for j = 1:num_freezetimes
                curr_freezetime_start = freezetimes{i}(j,1);
                curr_freezetime_end = freezetimes{i}(j,2)-1;
                plot(curr_freezetime_start-base_frame+1:curr_freezetime_end-base_frame+1,vel(curr_freezetime_start:curr_freezetime_end,1), '-', 'Color', 'r');
                hold all;
            end
        end
        
        if ismember(i, fastEscape) || ismember(i,slowEscape)
            plot(beginEscape_frame(i)-base_frame+1:enterEscape_frame(i)-base_frame+1, vel(beginEscape_frame(i):enterEscape_frame(i),1), '-', 'Color', [0.4660 0.6740 0.1880]);
        end
        
        
        title([num2str(i) ')' label_escape{i} ' ' label_freeze{i}], 'FontSize', 8);
        xline(frate);
        xline(frate*(1+curr_duration(i)));
        ylim([-5 150]);
        xlim([0 frate*(show_duration(i)+1)]);
        h = get(gca);
        h.XAxis.Visible = 'off';
        set(gca, 'xtick', []);
        set(gca, 'ytick', []);
        yline(maxspeed_fastEscape, '--');
        box off;
        hold all;
        
    end
    sgtitle(factors.animal);
    
    set(gcf, 'Position', get(0, 'Screensize'));
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperOrientation','landscape');
    saveas(gcf, [factors.filepath filesep [factors.name '_Speed.png']]);
    print('-painters','-dpdf', '-bestfit',[factors.filepath filesep [factors.name '_Speed.pdf']]);
    close;
    
    %% Understanding the start of escape responses
    
    
    for i=1:num_stim
        
        base_frame = floor((stim(i,1)-1)*frate);
        start_frame = floor(stim(i,1)*frate);
        if floor((stim(i,1)+show_duration(i))*frate) > factors.frames
            end_frame = factors.frames-1;
        else
            end_frame = floor((stim(i,1)+show_duration(i))*frate);
        end
        period = floor(frate);
        
        plot(vel(base_frame:end_frame,1), '-', 'Color', 'b');
        hold;
        num_freezetimes = size(freezetimes{i},1);
        if ~isnan(freezetimes{i})
            for j = 1:num_freezetimes
                curr_freezetime_start = freezetimes{i}(j,1);
                curr_freezetime_end = freezetimes{i}(j,2)-1;
                plot(curr_freezetime_start-base_frame+1:curr_freezetime_end-base_frame+1,vel(curr_freezetime_start:curr_freezetime_end,1), '-', 'Color', 'r');
                hold all;
            end
        end
        title([num2str(i) ')' label_escape{i} ' ' label_freeze{i}], 'FontSize', 8);
        
        if ismember(i,fastEscape) || ismember(i, slowEscape)
            xline(beginEscape_frame(i)-start_frame+period, '--r');
            xline(enterEscape_frame(i)-start_frame+period, '--b');
        end
        
        xline(frate);
        xline(frate*(1+curr_duration(i)));
        ylim([-5 150]);
        xlim([0 frate*(show_duration(i)+1)]);
        h = get(gca);
        h.XAxis.Visible = 'off';
        set(gca, 'xtick', []);
        set(gca, 'ytick', []);
        yline(maxspeed_fastEscape, '--');
        box off;
        hold all;
        
        sgtitle(factors.animal);
        
        set(gcf, 'Position', get(0, 'Screensize'));
        set(gcf,'PaperPositionMode','auto');
        set(gcf,'PaperOrientation','landscape');
        saveas(gcf, [factors.filepath filesep [factors.name '_' num2str(i) '_StartEscape.png']]);
        print('-painters','-dpdf', '-bestfit',[factors.filepath filesep [factors.name '_' num2str(i) '_StartEscape.pdf']]);
        close;
        
    end
    
    
    
    %% Total Response
    for i=1:num_stim
        start_frame = floor(stim(i,1)*frate);
        if floor((stim(i,1)+show_duration(i))*frate) > factors.frames
            end_frame = factors.frames;
        else
            end_frame = floor((stim(i,1)+show_duration(i))*frate);
        end
        plot(var_x(start_frame:end_frame,1), var_y(start_frame:end_frame,1), '--', 'Color','b');
        ylim([0 50]);
        xlim([0 50]);
        hold all;
        plot(var_x(start_frame,1), var_y(start_frame,1), 'ro', 'MarkerSize', 5, 'Color', 'b');
    end
    sgtitle(factors.animal);
    box off;
    plot([0 50 50 0 0], [0 0 50 50 0], 'Color', 'k')
    hold all;
    plot([0 home_x home_x 0 0], [0 0 home_y home_y 0], 'Color', 'k');
    h = get(gca);
    h.XAxis.Visible = 'off';
    h.YAxis.Visible = 'off';
    
    % set(gcf, 'Position', get(0, 'Screensize'));
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperOrientation','landscape');
    saveas(gcf, [factors.filepath filesep [factors.name '_TotalResponse.png']]);
    print('-painters','-dpdf', '-bestfit',[factors.filepath filesep [factors.name '_TotalResponse.pdf']]);
    close;
    
  
    
    %% Understanding the flow of responses for consecutive stimuli
    
    % Creating the shelter, border, freeze and escape variables
    shelter = zeros(factors.frames,1);
    shelter_edge = zeros(factors.frames, 1);
    border = zeros(factors.frames,1);
    freeze = zeros(factors.frames,1);
    escape = zeros(factors.frames,1);
    tl_x = mean(tbl_new.tl);
    tl_y = mean(tbl_new.tl_1);
    tr_x = mean(tbl_new.tr);
    tr_y = mean(tbl_new.tr_1);
    bl_x = mean(tbl_new.bl);
    bl_y = mean(tbl_new.bl_1);
    br_x = mean(tbl_new.br);
    br_y = mean(tbl_new.br_1);
    border_length = 3;
    
    % Filling the shelter and border variables
    for i = 1:factors.frames
        if dist(i,1) <= 0
            shelter(i,1) = 1;
        end
        
        con1 = var_y(i,1) < (border_length + (bl_y+br_y)/2);
        con2 = var_y(i,1) > ((tl_y+tr_y)/2 - border_length);
        con3 = var_x(i,1) < (border_length + (tl_x+bl_x)/2);
        con4 = var_x(i,1) > ((tr_x+br_x)/2 - border_length);
        
        if (con1==1 || con2==1 || con3==1 || con4==1) && (dist(i,1)>0)
            border(i, 1) = 1;
        end
    end
    
    % Filling the freeze variable
    if ~isempty(freezetimes)
        for i=1:num_stim
            if ~isnan(freezetimes{i})
                for j=1:size(freezetimes{i},1)
                    freeze_start = freezetimes{i}(j,1);
                    freeze_end = freezetimes{i}(j,2);
                    
                    if ismember(i, longFreeze)
                        freeze(freeze_start:freeze_end,1) = 1;
                    elseif ismember(i, shortFreeze)
                        freeze(freeze_start:freeze_end,1) = 2;
                    end
                    
                end
            end
        end
    end
    
    % Filling the escape variable
    for i=1:num_stim
        if ismember(i, fastEscape)
            escape_end = enterEscape_frame(i);
            escape_start = beginEscape_frame(i);
            escape(escape_start:escape_end,1) = 1;
        elseif ismember(i, slowEscape)
            escape_end = enterEscape_frame(i);
            escape_start = beginEscape_frame(i);
            escape(escape_start:escape_end,1) = 2;
        end
    end
    
    % Filling the shelter_edge variable
    for i=1:factors.frames
        if dist(i,1)>0
            if var_x(i,1) <= (home_x+closeness_attemptedEscape) && var_y(i,1) <= (home_y+closeness_attemptedEscape)
                shelter_edge(i,1) = 1;
            end
        end
    end
    
    xlen = (num_stim * max(show_duration(:,1)) * frate)+ (num_stim-1)*frate; % length of the xaxis to be depicted
    text_space = ceil(0.2*xlen);
    xlen = xlen + text_space;
    
    shelter_edge_height = 45;
    shelter_height = 40;
    border_height = 35;
    trueFreeze_height = 30;
    mildFreeze_height = 25;
    trueEscape_height = 20;
    mildEscape_height = 15;
    max_y = 50;
    min_y = 13;
    
    
    % Specify the colors for the plots
    trueFreeze_col = [1,0,0];
    mildFreeze_col = [0.6,0,0];
    trueEscape_col = [0,0,1];
    mildEscape_col = [0, 0.4, 0.6];
    else_col = [.9 .9 .9];
    shelter_col = 'c';
    border_col = 'g';
    shelter_edge_col = 'm';
    
    gap = ceil(frate);
    curr_x = ceil(frate);
    for i = 1:num_stim
        raster_start_frame = floor((stim(i,1)-1)*frate);
        raster_stim_frame = floor((stim(i,1))*frate);
        raster_stim_end_frame = floor((stim(i,1)+curr_duration(i))*frate);
        raster_end_frame = floor((stim(i,1)+ max(show_duration(:)))*frate);
        if raster_end_frame > factors.frames
            raster_end_frame = factors.frames;
        end
        
        for j = raster_stim_frame:raster_end_frame
            disp(j);
            curr_x = curr_x + 1;
            
            if shelter_edge(j,1) == 1
                line([curr_x, curr_x], [shelter_edge_height, shelter_edge_height + 5], 'Color', shelter_edge_col);
                %         else
                %             line([curr_x, curr_x], [shelter_edge_height, shelter_edge_height + 5], 'Color', else_col);
            end
            
            if shelter(j,1) == 1
                line([curr_x, curr_x], [shelter_height, shelter_height + 5], 'Color', shelter_col);
                %         else
                %             line([curr_x, curr_x], [shelter_height, shelter_height + 5], 'Color', else_col);
            end
            
            if border(j,1) == 1
                line([curr_x, curr_x], [border_height, border_height + 5], 'Color', border_col);
                %         else
                %             line([curr_x, curr_x], [border_height, border_height + 5], 'Color', else_col);
            end
            
            if freeze(j,1) == 1
                line([curr_x, curr_x], [trueFreeze_height, trueFreeze_height + 5], 'Color', trueFreeze_col);
                %             line([curr_x, curr_x], [mildFreeze_height, mildFreeze_height + 5], 'Color', else_col);
            elseif freeze(j,1) == 2
                line([curr_x, curr_x], [mildFreeze_height, mildFreeze_height + 5], 'Color', mildFreeze_col);
                %             line([curr_x, curr_x], [trueFreeze_height, trueFreeze_height + 5], 'Color', else_col);
            else
                %             line([curr_x, curr_x], [mildFreeze_height, mildFreeze_height + 5], 'Color', else_col);
                %             line([curr_x, curr_x], [trueFreeze_height, trueFreeze_height + 5], 'Color', else_col);
            end
            
            if escape(j,1) == 1
                line([curr_x, curr_x], [trueEscape_height, trueEscape_height + 5], 'Color', trueEscape_col);
                %             line([curr_x, curr_x], [mildEscape_height, mildEscape_height + 5], 'Color', else_col);
            elseif escape(j,1) == 2
                line([curr_x, curr_x], [mildEscape_height, mildEscape_height + 5], 'Color', mildEscape_col);
                %             line([curr_x, curr_x], [trueEscape_height, trueEscape_height + 5], 'Color', else_col);
            else
                %             line([curr_x, curr_x], [mildEscape_height, mildEscape_height + 5], 'Color', else_col);
                %             line([curr_x, curr_x], [trueEscape_height, trueEscape_height + 5], 'Color', else_col);
            end
            
            if j==raster_stim_frame
                line([curr_x, curr_x], [min_y, max_y], 'Color', 'k');
            end
            
            if j==raster_stim_end_frame
                bar_length = curr_x - (raster_stim_end_frame-raster_stim_frame);
                text_loc = curr_x - (raster_stim_end_frame-raster_stim_frame)/2;
                line([bar_length, curr_x], [min_y+1, min_y+1], 'Color', 'k');
                text(text_loc, min_y+0.5, num2str(i));
            end
            
            if j==raster_end_frame
                line([curr_x, curr_x], [min_y, max_y], 'LineStyle', '--','Color', 'k');
            end
            
        end
        
        curr_x = curr_x + gap;
        
    end
    xlim([0, curr_x+floor(frate)]);
    set(gca, 'Color', [0.96, 0.96, 0.74]);
    h = get(gca);
    box off;
    h.XAxis.Visible = 'off';
    h.YAxis.Visible = 'off';
    
    set(gcf, 'Position', get(0, 'Screensize'));
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperOrientation','landscape');
    saveas(gcf, [factors.filepath filesep [factors.name '_ResponsePattern.png']]);
    print('-painters','-dpdf', '-bestfit',[factors.filepath filesep [factors.name '_ResponsePattern.pdf']]);
    close;
    
    %% Create the structure variables
    
    EscapeRes.shelter = shelter;
    EscapeRes.border = border;
    EscapeRes.freeze = freeze;
    EscapeRes.escape = escape;
    EscapeRes.shelter_edge = shelter_edge;
    EscapeRes.num_stim = num_stim;
    EscapeRes.stim = stim;
    EscapeRes.frate =frate;
    EscapeRes.curr_duration = curr_duration;
    EscapeRes.show_duration = show_duration;
    EscapeRes.label_escape = label_escape;
    EscapeRes.label_freeze = label_freeze;
    EscapeRes.attemptedEscape = attemptedEscape;
    EscapeRes.fastEscape = fastEscape;
    EscapeRes.slowEscape = slowEscape;
    EscapeRes.enterEscape_frame = enterEscape_frame;
    EscapeRes.beginEscape_frame = beginEscape_frame;
    EscapeRes.longFreeze = longFreeze;
    EscapeRes.shortFreeze = shortFreeze;
    EscapeRes.NA = NA;
    EscapeRes.freezetimes = freezetimes;
    EscapeRes.fastfreeze_end = fastfreeze_end;
    EscapeRes.frames = factors.frames;
    EscapeRes.home_x = home_x;
    EscapeRes.home_y = home_y;
    EscapeRes.var_x = var_x;
    EscapeRes.var_y = var_y;
    EscapeRes.vel = vel;
    
end