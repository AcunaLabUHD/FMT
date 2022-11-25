clear all;

folder = 'E:\Users\Sanket\MATLAB\New Looming';
animal = '181';
condition = 'Test';
newfactors.test = 1;
newfactors.draw_fig = 0;
newfactors.frame_rate = 29.36507937;
loom(1) = Main_LoomSweep(animal, condition, folder,newfactors);

animal = '181';
condition = 'TestB';
newfactors.test = 1;
newfactors.draw_fig = 0;
newfactors.frame_rate = 29.39758506;
loom(2) = Main_LoomSweep(animal, condition, folder,newfactors);

animal = '182';
condition = 'Test';
newfactors.test = 1;
newfactors.draw_fig = 0;
newfactors.frame_rate = 29.38764;
loom(3) = Main_LoomSweep(animal, condition, folder,newfactors);

animal = '182';
condition = 'TestB';
newfactors.test = 1;
newfactors.draw_fig = 0;
newfactors.frame_rate = 29.40089;
loom(4) = Main_LoomSweep(animal, condition, folder,newfactors);

animal = '183';
condition = 'Test';
newfactors.test = 1;
newfactors.draw_fig = 0;
newfactors.frame_rate = 29.39989174;
loom(5) = Main_LoomSweep(animal, condition, folder,newfactors);

animal = '183';
condition = 'TestB';
newfactors.test = 1;
newfactors.draw_fig = 0;
newfactors.frame_rate = 29.40266558;
loom(6) = Main_LoomSweep(animal, condition, folder,newfactors);

animal = '184';
condition = 'Test';
newfactors.test = 1;
newfactors.draw_fig = 0;
newfactors.frame_rate = 29.38388079;
loom(7) = Main_LoomSweep(animal, condition, folder,newfactors);

animal = '184';
condition = 'TestB';
newfactors.test = 1;
newfactors.draw_fig = 0;
newfactors.frame_rate = 29.40098002;
loom(8) = Main_LoomSweep(animal, condition, folder,newfactors);


animal = '208';
condition = 'Test';
newfactors.test = 1;
newfactors.draw_fig = 0;
newfactors.frame_rate = 29.40470077;
loom(9) = Main_LoomSweep(animal, condition, folder,newfactors);

animal = '211';
condition = 'Test';
newfactors.test = 1;
newfactors.draw_fig = 0;
newfactors.frame_rate = 29.40530385;
loom(10) = Main_LoomSweep(animal, condition, folder,newfactors);

animal = '211';
condition = 'TestB';
newfactors.test = 1;
newfactors.draw_fig = 0;
newfactors.frame_rate = 29.40583709;
loom(11) = Main_LoomSweep(animal, condition, folder,newfactors);

animal = '212';
condition = 'Test';
newfactors.test = 1;
newfactors.draw_fig = 0;
newfactors.frame_rate = 29.40538867;
loom(12) = Main_LoomSweep(animal, condition, folder,newfactors);

save([folder filesep 'Looming_Cumulative_data']);
animal = {'181', '181', '182', '182', '183', '183', '184', '184', '208', '211', '211', '212'};
cond = {'Test', 'TestB', 'Test', 'TestB', 'Test', 'TestB', 'Test', 'TestB', 'Test',...
    'Test', 'TestB', 'Test'};

%% Summary plot for understanding Escape Responses

folder = 'E:\Users\Sanket\MATLAB\New Looming';
load([folder filesep 'Looming_Cumulative_data']);
animal = {'181', '181', '182', '182', '183', '183', '184', '184', '208', '211', '211', '212'};
cond = {'Test', 'TestB', 'Test', 'TestB', 'Test', 'TestB', 'Test', 'TestB', 'Test',...
    'Test', 'TestB', 'Test'};


max_escape_speed = nan(20,12);
tot_freeze_time = nan(20,12);
delay = nan(20,12);

for i=1:size(loom,2)
    currRes = loom(i);
    
    response_sum_path = [folder filesep animal{i} filesep 'ResponseSummaries'];
    if ~exist(response_sum_path, 'dir')
        mkdir(response_sum_path);
    end
    
    response_patterns_path = [folder filesep animal{i} filesep 'ResponsePatterns'];
    if~exist(response_patterns_path, 'dir')
        mkdir(response_patterns_path);
    end

    for j = 1:currRes.num_stim
        
        if ismember(j,currRes.trueFreeze) || ismember(j,currRes.mildFreeze)
            freezetimes = currRes.freezetimes;
            tot_freeze_time(j,i) = sum(freezetimes{1,j}(:,2) - freezetimes{1,j}(:,1)+1)/currRes.frate;
            delay(j,i) = (freezetimes{1,j}(1,1) - floor((currRes.stim(j)*currRes.frate)))/currRes.frate;
        end
        
        if ismember(j,currRes.trueEscape) || ismember(j,currRes.mildEscape)
            start_frame = currRes.beginEscape_frame(j);
            end_frame = currRes.enterEscape_frame(j);
            max_escape_speed(j,i) = max(currRes.vel(start_frame:end_frame,1));
            
            if isnan(delay(j,i))
                delay(j,i) = (start_frame - floor(currRes.stim(j)*currRes.frate))/currRes.frate;
            end
        end
        
        
        % Plot the response_pattern
        subplot(2,1,1);
        start_frame = floor(currRes.stim(j,1)*currRes.frate);
        end_frame = ceil((currRes.stim(j,1)+currRes.show_duration(j))*currRes.frate);
        plot(currRes.var_x(start_frame:end_frame,1), currRes.var_y(start_frame:end_frame,1), '-', 'Color','b');
        ylim([0 50]);
        xlim([0 50]);
        hold all;
        plot(currRes.var_x(start_frame,1), currRes.var_y(start_frame,1), 'ro', 'MarkerSize', 5, 'Color', 'b');
        
        box off;
        plot([0 50 50 0 0], [0 0 50 50 0], 'Color', 'k')
        hold all;
        plot([0 currRes.home_x currRes.home_x 0 0], [0 0 currRes.home_y currRes.home_y 0], 'Color', 'k');
        h = get(gca);
        h.XAxis.Visible = 'off';
        h.YAxis.Visible = 'off';
        set(gca, 'Position', [0.25, 0.46, 0.5, 0.5])
        
        
        subplot(2,1,2);
        base_frame = floor((currRes.stim(j,1)-1)*currRes.frate);
        start_frame = floor(currRes.stim(j,1)*currRes.frate);
        end_frame = ceil((currRes.stim(j,1)+currRes.show_duration(j))*currRes.frate);
        
        plot(currRes.vel(base_frame:end_frame,1), '-', 'Color', 'b');
        hold;
        num_freezetimes = size(currRes.freezetimes{j},1);
        if ~isnan(currRes.freezetimes{j})
            for k = 1:num_freezetimes
                curr_freezetime_start = currRes.freezetimes{j}(k,1);
                curr_freezetime_end = currRes.freezetimes{j}(k,2)-1;     
                plot(curr_freezetime_start-base_frame+1:curr_freezetime_end-base_frame+1,currRes.vel(curr_freezetime_start:curr_freezetime_end,1), '-', 'Color', 'r');
                hold all;
            end
        end
        
        
        xline(currRes.frate);
        ylim([-5 150]);
        h = get(gca);
        set(gca, 'XTick', get(gca, 'Xtick')/currRes.frate);
    
        h.XAxis.Visible = 'off';
        line([20, 20+currRes.frate], [-5, -5], 'Color', 'k');
        yline(40, '--');
        box off;
   
        
        saveas(gcf, [response_patterns_path filesep [animal{i} '_' cond{i} '_' num2str(j) '_ResponsePattern.png']]);
        print('-painters','-dpdf', '-bestfit',[response_patterns_path filesep [animal{i} '_' cond{i} '_' num2str(j) '_ResponsePattern.pdf']]);
        close;
    end
    
    % Summary plot for velocity, freeze time and delay
    subplot(3,1,1);
    plot(max_escape_speed(:,i), 'o');
    box off;
    xlim([0,currRes.num_stim]);
    set(gca, 'tickdir', 'out');
    title('Max Velocity');
    ylabel('cm/sec');
    
    subplot(3,1,2);
    plot(tot_freeze_time(:,i),'o');
    box off;
    xlim([0,currRes.num_stim]);
    set(gca, 'tickdir', 'out');
    title('Total Freezing time');
    ylabel('sec');
    
    subplot(3,1,3);
    plot(delay(:,i),'o');
    box off;
    xlim([0,currRes.num_stim]);
    set(gca, 'tickdir', 'out');
    title('Delay in response');
    ylabel('sec');
    
    saveas(gcf, [response_sum_path filesep [animal{i} '_' cond{i} '_RespSummary.png']]);
    print('-painters','-dpdf', '-bestfit',[response_sum_path filesep [animal{i} '_' cond{i} '_RespSummary.pdf']]);
    close;
    
    % Note the response summary details in excel sheet
    response_details_path = [folder filesep 'ResponseSummaries.xlsx'];
    sheet = [animal{i} '_' cond{i}];
    for j = 1:currRes.num_stim
        writematrix('Stimulus Number',response_details_path,'Sheet',sheet,'Range',['A' num2str(1)]);
        writematrix(num2str(j),response_details_path,'Sheet',sheet,'Range',['A' num2str(j+1)]);
        
        writematrix('Stimulus Time',response_details_path,'Sheet',sheet,'Range',['B' num2str(1)]);
        writematrix(num2str(currRes.stim(j)),response_details_path,'Sheet',sheet,'Range',['B' num2str(j+1)]);
        
        writematrix('Delay in Response',response_details_path,'Sheet',sheet,'Range',['C' num2str(1)]);
        writematrix(num2str(delay(j,i)),response_details_path,'Sheet',sheet,'Range',['C' num2str(j+1)]);
        
        
        % Noting down the Escape Responses
        writematrix('Escape Response',response_details_path,'Sheet',sheet,'Range',['D' num2str(1)]);
        writematrix('Begin Escape',response_details_path,'Sheet',sheet,'Range',['E' num2str(1)]);
        writematrix('Reach Shelter',response_details_path,'Sheet',sheet,'Range',['F' num2str(1)]);
        writematrix('Max Speed',response_details_path,'Sheet',sheet,'Range',['G' num2str(1)]);
        if ismember(j, currRes.trueEscape)
            writematrix('True Escape',response_details_path,'Sheet',sheet,'Range',['D' num2str(j+1)]);
            writematrix(num2str(currRes.beginEscape_frame(j)/currRes.frate),response_details_path,'Sheet',sheet,'Range',['E' num2str(j+1)]);
            writematrix(num2str(currRes.enterEscape_frame(j)/currRes.frate),response_details_path,'Sheet',sheet,'Range',['F' num2str(j+1)]);
        elseif ismember(j, currRes.mildEscape)
            writematrix('Mild Escape',response_details_path,'Sheet',sheet,'Range',['D' num2str(j+1)]);
            writematrix(num2str(currRes.beginEscape_frame(j)/currRes.frate),response_details_path,'Sheet',sheet,'Range',['E' num2str(j+1)]);
            writematrix(num2str(currRes.enterEscape_frame(j)/currRes.frate),response_details_path,'Sheet',sheet,'Range',['F' num2str(j+1)]);
        elseif ismember(j, currRes.attemptedEscape)
            writematrix('Attempted Escape',response_details_path,'Sheet',sheet,'Range',['D' num2str(j+1)]);
        end
        writematrix(max_escape_speed(j,i),response_details_path,'Sheet',sheet,'Range',['G' num2str(j+1)]);
        
        
        % Noting down the Freeze Responses
        writematrix('Freeze Response',response_details_path,'Sheet',sheet,'Range',['H' num2str(1)]);
        writematrix('Freeze Duration',response_details_path,'Sheet',sheet,'Range',['I' num2str(1)]);
        if ismember(j, currRes.trueFreeze)
            writematrix('True Freeze',response_details_path,'Sheet',sheet,'Range',['H' num2str(j+1)]);
            writematrix(num2str(tot_freeze_time(j,i)),response_details_path,'Sheet',sheet,'Range',['I' num2str(j+1)]);
        elseif ismember(j, currRes.mildFreeze)
            writematrix('Mild Freeze',response_details_path,'Sheet',sheet,'Range',['H' num2str(j+1)]);
            writematrix(num2str(tot_freeze_time(j,i)),response_details_path,'Sheet',sheet,'Range',['I' num2str(j+1)]);
        end
%         if ~isnan(currRes.freezetimes{j})
%             writecell(currRes.freezetimes{j}/currRes.frate, response_details_path, 'Sheet', sheet, 'Range', ['J' num2str(j+1)]);
%         end
        
    end
end

histogram(reshape(tot_freeze_time,1,[]),10);
box off;
set(gca, 'tickdir', 'out');
xlabel('Duration in sec');
ylabel('Frequency');
title(['Freezing Duration n=' num2str(size(tot_freeze_time,1))]);
saveas(gcf, [folder filesep ['FreezingDuration_Histogram_100.png']]);
print('-painters','-dpdf', '-bestfit',[folder filesep ['FreezingDuration_Histogram_100.pdf']]);
close;

histogram(reshape(max_escape_speed,1,[]),10);
box off;
set(gca, 'tickdir', 'out');
xlabel('Velocity in cm/sec');
ylabel('Frequency');
title(['Max Speed during Escape n=' num2str(size(max_escape_speed,1))]);
saveas(gcf, [folder filesep ['MaxEscapeSpeed_Histogram_100.png']]);
print('-painters','-dpdf', '-bestfit',[folder filesep ['MaxEscapeSpeed_Histogram_100.pdf']]);
close;

histogram(reshape(delay,1,[]),10);
box off;
set(gca, 'tickdir', 'out');
xlabel('Delay in sec');
ylabel('Frequency');
title(['Delay in Response n=' num2str(size(delay,1))]);
saveas(gcf, [folder filesep ['Delay_Histogram_Less100.png']]);
print('-painters','-dpdf', '-bestfit',[folder filesep ['Delay_Histogram_Less100.pdf']]);
close; 


%% Draw the path responses based on color coding

folder = 'E:\Users\Sanket\MATLAB\New Looming';
load([folder filesep 'Looming_Cumulative_data']);
animal = {'181', '181', '182', '182', '183', '183', '184', '184', '208', '211', '211', '212'};
cond = {'Test', 'TestB', 'Test', 'TestB', 'Test', 'TestB', 'Test', 'TestB', 'Test',...
    'Test', 'TestB', 'Test'};

trueFreeze_col = [1,0,0]; %1
mildFreeze_col = [0.6,0,0]; %2
trueEscape_col = [0,0,1]; %3
mildEscape_col = [0, 0.4, 0.6]; %3
shelter_col = 'c'; %4
border_col = 'g'; %5
shelter_edge_col = 'm'; %6



for i=1:size(loom,2)
    currRes = loom(i);
    
    state = zeros(currRes.frames,1);
    for k=1:currRes.frames
        
        % Recording position within shelter
        shelter_frames = find(currRes.shelter==1);
        state(shelter_frames,1) = 4;
        
        % Recording position around edges
        edge_frames = find(currRes.border==1);
        state(edge_frames,1) = 5;
        
        % Recording position around shelter edges
        shelterEdge_frames = find(currRes.shelter_edge==1);
        state(shelterEdge_frames) = 6;
        
        % Record Freezing behavior
        for stim_no = 1:currRes.num_stim
            if ismember(stim_no, currRes.trueFreeze)
                curr_freezetimes = currRes.freezetimes{stim_no};
                
                for m = 1:size(curr_freezetimes,1)
                    state(curr_freezetimes(m,1):curr_freezetimes(m,2),1) = 1;
                end
                
            elseif ismember(stim_no, currRes.mildFreeze)
                curr_freezetimes = currRes.freezetimes{stim_no};
                
                for m = 1:size(curr_freezetimes,1)
                    state(curr_freezetimes(m,1):curr_freezetimes(m,2),1) = 2;
                end
            end
        end
        
        % Recording escape frames
        escape_frames = find(currRes.escape==1);
        state(escape_frames,1) = 3;
        
    end
    
    
    response_sum_path = [folder filesep animal{i} filesep 'ResponsePatterns_Color'];
    if ~exist(response_sum_path, 'dir')
        mkdir(response_sum_path);
    end
    
    for j = 1:currRes.num_stim
        start_frame = floor(currRes.stim(j,1)*currRes.frate);
        end_frame = ceil((currRes.stim(j,1)+currRes.show_duration(j))*currRes.frate);
        
        for frame = start_frame:end_frame
            if state(frame,1) == 1
                plot(currRes.var_x(frame:frame+1,1), currRes.var_y(frame:frame+1,1), '-', 'Color', trueFreeze_col);
                hold all;
                plot(currRes.var_x(frame,1), currRes.var_y(frame,1), 'ro', 'MarkerSize', 5, 'Color', trueFreeze_col);
                hold all;
            elseif state(frame,1) == 2
                plot(currRes.var_x(frame:frame+1,1), currRes.var_y(frame:frame+1,1), '-', 'Color', mildFreeze_col);
                hold all;
                plot(currRes.var_x(frame,1), currRes.var_y(frame,1), 'ro', 'MarkerSize', 5, 'Color', mildFreeze_col);
                hold all;
            elseif state(frame,1) == 3
                plot(currRes.var_x(frame:frame+1,1), currRes.var_y(frame:frame+1,1), '-', 'Color', trueEscape_col);
                hold all;
            elseif state(frame,1) == 4
                plot(currRes.var_x(frame:frame+1,1), currRes.var_y(frame:frame+1,1), '-', 'Color', shelter_col);
                hold all;
            elseif state(frame,1) == 5
                plot(currRes.var_x(frame:frame+1,1), currRes.var_y(frame:frame+1,1), '-', 'Color', border_col);
                hold all;
            elseif state(frame,1) == 6
                plot(currRes.var_x(frame:frame+1,1), currRes.var_y(frame:frame+1,1), '-', 'Color', shelter_edge_col);
                hold all;
            else
                plot(currRes.var_x(frame:frame+1,1), currRes.var_y(frame:frame+1,1), '-', 'Color', 'k');
                hold all;
            end        
        end
        ylim([0 50]);
        xlim([0 50]);
        hold all;
        plot(currRes.var_x(start_frame,1), currRes.var_y(start_frame,1), 'ro', 'MarkerSize', 5, 'Color', 'k');
        box off;
        plot([0 50 50 0 0], [0 0 50 50 0], 'Color', 'k')
        hold all;
        plot([0 currRes.home_x currRes.home_x 0 0], [0 0 currRes.home_y currRes.home_y 0], 'Color', 'k');
        h = get(gca);
        h.XAxis.Visible = 'off';
        h.YAxis.Visible = 'off';
        
        saveas(gcf, [response_sum_path filesep [animal{i} '_' cond{i} '_' num2str(j) '_ResponsePattern_Color.png']]);
        print('-painters','-dpdf', '-bestfit',[response_sum_path filesep [animal{i} '_' cond{i} '_' num2str(j) '_ResponsePattern_Color.pdf']]);
        close;

    end
end
