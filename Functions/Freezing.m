function duration = Freezing(var_x, var_y, image_name, max_dist, min_peak_height, min_peak_dist)
% === Stationarity in Frames ===%
% Three variables values to be manually selected
% 1. Maximum dist variation allowed - can be set to the train error based
% on DLC
% 2. Minimum peak height
% 3. Minimum peak distance

duration = nan;
numFrames = length(var_x);

% Use a small value for max_dist like 0.5 cm, to capture only pure freezing
% behaviours
if ~exist('max_dist', 'var')
    max_dist = 0.25;
%     max_dist = 0.5;
end

% Use a small value for min_peak_height like 25, to capture even small
% freezing responses
if ~exist('min_peak_height', 'var')
    min_peak_height = 9;
end

% Use a small value for min_peak_dist like 25, to capture two or more
% freezing instances separated at a very short duration
if ~exist('min_peak_dist', 'var')
    min_peak_dist = 1;
end


%===Creating the time variable ===%
for i=1:numFrames
    timerange = 1;
    
    var_x_min = var_x(i,1) - max_dist;
    var_x_max = var_x(i,1) + max_dist;
    var_y_min = var_y(i,1) - max_dist;
    var_y_max = var_y(i,1) + max_dist;
    
    for j=i+1:numFrames
        if var_x(j,1)>=var_x_min && var_x(j,1) <= var_x_max && var_y(j,1)>= var_y_min && var_y(j,1)<=var_y_max
            timerange = timerange + 1;
        else
            break;
        end
    end
    time(i,1) = timerange;
end


%===Finding peaks in the time variable ===%
if numFrames > min_peak_dist
    subplot(3,1,1);
    plot(var_x);
    xlim([0 size(var_x,1)]);
    ylabel('X Coordinate (cm)');
    xlabel('Number of Frames');
    subplot(3,1,2);
    findpeaks(time(:,1), 'MinPeakHeight',min_peak_height, 'MinPeakDistance', min_peak_dist);
    ylabel('Frames');
    xlabel('Number of Frames');
    yline(min_peak_height, '--');
    subplot(3,1,3);
    plot(var_y);
    xlim([0 size(var_y,1)]);
    ylabel('Y Coordinate (cm)');
    xlabel('Number of Frames');
    saveas(gcf, [image_name '.png']);
    print('-painters','-dpdf', '-bestfit',[image_name '.pdf']);
    close;
    [peak_y, peak_x] = findpeaks(time(:,1), 'MinPeakHeight',min_peak_height, 'MinPeakDistance', min_peak_dist);
    close;
    
    %===Calculating the starting and ending of stationary periods ===%
    numPeaks = length(peak_x);
    
    % if the animal is already stationary during the stimulus presentation
    if time(1,1) > min_peak_height
        if ~isempty(peak_x)
            if time(1,1)+1 < peak_x(1,1)
                for i=1:numPeaks
                    peak_x(i+1) = peak_x(i);
                    peak_y(i+1) = peak_y(i);
                end
                numPeaks = numPeaks + 1;
                peak_x(1) = 1;
                peak_y(1) = time(1,1);
            else
                peak_x(1,1) = 1;
                peak_y(1,1) = time(1,1);
            end
        elseif isempty(peak_x)
            numPeaks = numPeaks + 1;
            peak_x(1) = 1;
            peak_y(1) = time(1,1);
        end
    end
       
    
    
    
    peak_no = 1;
    next_peak_no = 2;
    m = 1;
    
    while peak_no <= numPeaks
        
        disp(peak_no);
        current_x = peak_x(peak_no,1);
        current_y = peak_y(peak_no,1);
        duration(m,1) = current_x;
        duration(m,2) = current_x + current_y;
        peak_no = next_peak_no;
        next_peak_no = next_peak_no + 1;
        
        
        while peak_no <= numPeaks 
            if peak_x(peak_no,1) <= duration(m,2)
                if peak_y(peak_no,1)+peak_x(peak_no,1) <= duration(m,2)
                    peak_no = next_peak_no;
                    next_peak_no = next_peak_no + 1;
                else
                    duration(m,2) = peak_y(peak_no,1) + peak_x(peak_no,1);
                    peak_no = next_peak_no;
                    next_peak_no = next_peak_no + 1;
                end
            else
                break;
            end
        end
        m = m+1;
       
    end
end



if ~isnan(duration)
    if size(duration,1)>1
        rows_to_rem = [];
        for k = size(duration,1)-1:-1:1
            if duration(k,2)+1 == duration(k+1,1)
                rows_to_rem = [rows_to_rem, k+1];
                duration(k,2) = duration(k+1,2);
            end
        end
        duration(rows_to_rem,:) = [];
    end
end

end