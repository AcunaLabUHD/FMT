function start_frame = DetectStartofEscape(vel, stim_frame, enter_frame, maxspeed_trueEscape, frate)

check_start_frame = enter_frame - ceil(frate);
[peak_y, peak_x] = findpeaks(vel(check_start_frame:enter_frame,1), 'MinPeakHeight',maxspeed_trueEscape);
peak_x = peak_x + check_start_frame - 1;

first_peak = peak_x(1,1);

j=1;
if first_peak<stim_frame
    while first_peak < stim_frame && j<size(peak_x,1)
        j = j+1;
        first_peak = peak_x(j,1);
    end
end
if first_peak<stim_frame
    first_peak = stim_frame;
end

curr_vel = vel(first_peak,1);
start_frame = first_peak;
while curr_vel > 5
    first_peak = first_peak - 1;
    curr_vel = vel(first_peak,1);
end

if first_peak < stim_frame
    first_peak = stim_frame;
end
start_frame = first_peak;
end