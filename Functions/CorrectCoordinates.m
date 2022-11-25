function [tbl, measures] = CorrectCoordinates(tbl,factors,start_time)
% Only the pixel coordinates after the start time are used for generating
% the correction parameters

% Find the Mean x-y coordinates for the bottom left
bl_x_mean  = mean(tbl.bl(start_time:length(tbl.bl)-10, 1));
bl_y_mean = mean(tbl.bl_1(start_time:length(tbl.bl)-10, 1));

% Find the Mean x-y coordinates for the bottom right and top left
br_x = tbl.br - bl_x_mean;
br_y = bl_y_mean - tbl.br_1;
br_x_mean = mean(br_x(start_time:length(br_x)-10, 1));
br_y_mean = mean(br_y(start_time:length(br_y)-10, 1));

tl_x = tbl.tl - bl_x_mean;
tl_y = bl_y_mean - tbl.tl_1;
tl_x_mean = mean(tl_x(start_time:length(tl_x)-10, 1));
tl_y_mean = mean(tl_y(start_time:length(tl_y)-10, 1));


% From the true length, find pixel to cm conversion in x and y directions
Coords_X_dist = [0 0; br_x_mean br_y_mean];
Xslope_dist = pdist(Coords_X_dist, 'euclidean');
true_x = (factors.xlen * br_x_mean)/Xslope_dist;
x_pixel2cm = true_x/br_x_mean;

Coords_Y_dist = [0 0; tl_x_mean tl_y_mean];
Yslope_dist = pdist(Coords_Y_dist, 'euclidean');
true_y = (factors.ylen * tl_y_mean)/Yslope_dist;
y_pixel2cm = true_y/tl_y_mean;


% Correction of all the coordinates
tbl.nose = (tbl.nose - bl_x_mean)*x_pixel2cm;
tbl.point1 = (tbl.point1 - bl_x_mean)*x_pixel2cm;
tbl.point2 = (tbl.point2 - bl_x_mean)*x_pixel2cm;
tbl.point3 = (tbl.point3 - bl_x_mean)*x_pixel2cm;
tbl.bodycentre = (tbl.bodycentre - bl_x_mean)*x_pixel2cm;
tbl.point4 = (tbl.point4 - bl_x_mean)*x_pixel2cm;
tbl.point5 = (tbl.point5 - bl_x_mean)*x_pixel2cm;
tbl.point6 = (tbl.point6 - bl_x_mean)*x_pixel2cm;
tbl.tailbase = (tbl.tailbase - bl_x_mean)*x_pixel2cm;
tbl.leftear = (tbl.leftear - bl_x_mean)*x_pixel2cm;
tbl.rightear = (tbl.rightear - bl_x_mean)*x_pixel2cm;
tbl.tl = (tbl.tl - bl_x_mean)*x_pixel2cm;
tbl.tr = (tbl.tr - bl_x_mean)*x_pixel2cm;
tbl.bl = (tbl.bl - bl_x_mean)*x_pixel2cm;
tbl.br = (tbl.br - bl_x_mean)*x_pixel2cm;

tbl.nose_1 = (bl_y_mean - tbl.nose_1)*y_pixel2cm;
tbl.point1_1 = (bl_y_mean - tbl.point1_1)*y_pixel2cm;
tbl.point2_1 = (bl_y_mean - tbl.point2_1)*y_pixel2cm;
tbl.point3_1 = (bl_y_mean - tbl.point3_1)*y_pixel2cm;
tbl.bodycentre_1 = (bl_y_mean - tbl.bodycentre_1)*y_pixel2cm;
tbl.point4_1 = (bl_y_mean - tbl.point4_1)*y_pixel2cm;
tbl.point5_1 = (bl_y_mean - tbl.point5_1)*y_pixel2cm;
tbl.point6_1 = (bl_y_mean - tbl.point6_1)*y_pixel2cm;
tbl.tailbase_1 = (bl_y_mean - tbl.tailbase_1)*y_pixel2cm;
tbl.leftear_1 = (bl_y_mean - tbl.leftear_1)*y_pixel2cm;
tbl.rightear_1 = (bl_y_mean - tbl.rightear_1)*y_pixel2cm;
tbl.tl_1 = (bl_y_mean - tbl.tl_1)*y_pixel2cm;
tbl.tr_1 = (bl_y_mean - tbl.tr_1)*y_pixel2cm;
tbl.bl_1 = (bl_y_mean - tbl.bl_1)*y_pixel2cm;
tbl.br_1 = (bl_y_mean - tbl.br_1)*y_pixel2cm;

measures.x_pixel2cm = x_pixel2cm;
measures.y_pixel2cm = y_pixel2cm;
measures.true_x = true_x;
measures.true_y = true_y;
measures.bl_x = mean(tbl.bl(start_time:length(tbl.bl)-10,1));
measures.bl_y = mean(tbl.bl_1(start_time:length(tbl.bl_1)-10,1));
measures.tl_x = mean(tbl.tl(start_time:length(tbl.tl)-10,1));
measures.tl_y = mean(tbl.tl_1(start_time:length(tbl.tl_1)-10,1));
measures.br_x = mean(tbl.br(start_time:length(tbl.br)-10,1));
measures.br_y = mean(tbl.br_1(start_time:length(tbl.br_1)-10,1));
measures.tr_x = mean(tbl.tr(start_time:length(tbl.tr)-10,1));
measures.tr_y = mean(tbl.tr_1(start_time:length(tbl.tr_1)-10,1));
