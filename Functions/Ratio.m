function ratio = Ratio(tbl, factors, index, startframe, endframe)

if ~exist('startframe', 'var')
    startframe = 1;
end

if ~exist('endframe', 'var')
    endframe = length(nose_x)-10;
end

nose_x = tbl.nose;
nose_y = tbl.nose_1;
tailbase_x = tbl.tailbase;
tailbase_y = tbl.tailbase_1;

nose_dist = 0;
tailbase_dist = 0;

for i=startframe+1:endframe
    dist_x(i-1,1) = abs(nose_x(i,1) - nose_x(i-1,1));
    dist_y(i-1,1) = abs(nose_y(i,1) - nose_y(i-1,1));
    dist_x(i-1,1) = dist_x(i-1,1)*dist_x(i-1,1);
    dist_y(i-1,1) = dist_y(i-1,1)*dist_y(i-1,1);
    nose_dist = sqrt(dist_x(i-1,1) + dist_y(i-1,1)) + nose_dist;
end


for i=startframe+1:endframe
    dist_x(i-1,1) = abs(tailbase_x(i,1) - tailbase_x(i-1,1));
    dist_y(i-1,1) = abs(tailbase_y(i,1) - tailbase_y(i-1,1));
    dist_x(i-1,1) = dist_x(i-1,1)*dist_x(i-1,1);
    dist_y(i-1,1) = dist_y(i-1,1)*dist_y(i-1,1);
    tailbase_dist = sqrt(dist_x(i-1,1) + dist_y(i-1,1)) + tailbase_dist;
end

ratio = nose_dist/tailbase_dist;
writematrix(ratio,factors.datasheet_fullpath,'Sheet','Basics','Range',['G' num2str(index+1)]);
return;