function speed = Speed(var_x, var_y)

total_dist = 0;
numFrames = length(var_x);

for i=1:numFrames-1
    dist_x(i,1) = abs(var_x(i,1) - var_x(i+1,1));
    dist_y(i,1) = abs(var_y(i,1) - var_y(i+1,1));
    dist_x(i,1) = dist_x(i,1)*dist_x(i,1);
    dist_y(i,1) = dist_y(i,1)*dist_y(i,1);
    speed(i,1) = sqrt(dist_x(i,1) + dist_y(i,1));
end



% For calculating the average speed per second i.e. after of every 25
% frames
% You can change return value as avg_speed
j = 0;
m = 1;
total_speed = 0;
for i=1:numFrames-2
    total_speed = total_speed + speed(i,1);
    j= j + 1;
    if j==25
       avg_speed(m,1) = total_speed/25;
       total_speed = 0;
       j = 0;
       m = m+1;
    end
end

return


