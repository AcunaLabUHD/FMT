function dist = Diagonal(tbl, factors, time_start, time_end, index)

tl_x_mean = mean(tbl.tl(time_start: time_end, 1));
tl_y_mean = mean(tbl.tl_1(time_start: time_end, 1));
br_x_mean = mean(tbl.br(time_start: time_end, 1));
br_y_mean = mean(tbl.br_1(time_start: time_end, 1));

points = [tl_x_mean, tl_y_mean; br_x_mean, br_y_mean];
dist = pdist(points, 'euclidean');

writematrix(dist,factors.datasheet_fullpath,'Sheet','Basics','Range',['F' num2str(index+1)]);
