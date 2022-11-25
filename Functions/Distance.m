function var_dist = Distance(var_x, var_y, startframe, endframe)

if ~exist('startframe', 'var')
    startframe = 1;
end

if ~exist('endframe', 'var')
    endframe = length(var_x)-10;
end

var_dist = 0;

for i=startframe+1:endframe
    dist_x(i-1,1) = abs(var_x(i,1) - var_x(i-1,1));
    dist_y(i-1,1) = abs(var_y(i,1) - var_y(i-1,1));
    dist_x(i-1,1) = dist_x(i-1,1)*dist_x(i-1,1);
    dist_y(i-1,1) = dist_y(i-1,1)*dist_y(i-1,1);
    var_dist = sqrt(dist_x(i-1,1) + dist_y(i-1,1)) + var_dist;
end

return;