function tbl = TransformCoordinates(tbl)

%% --- Defining the variables ---
origin_x = mean(tbl.bl);
origin_y = mean(tbl.bl_1);

tl_x = mean(tbl.tl);
tl_y = mean(tbl.tl_1);

br_x = mean(tbl.br);
br_y = mean(tbl.br_1);

% pixel_x_rate finds the cm equivalent of 1 pixel in x direction. ideally,
% this should be equal to that in the y direction had the camera recorded
% the box from a perpendicular view.
pixel_x_rate = 50/abs(br_x - origin_x);

% Height at which the camera was placed
height = 35;

% false_L variable stores the value of the visible cm distance in the y
% direction
false_L_px = abs(tl_y - origin_y);
false_L_cm = false_L_px * pixel_x_rate;


%% --- Find the angle of inclination ---

% These are some iterator variables
diff = 100;
correct_angle = -1;
length_diff = [];
angles = 10:0.001:25;

% Finds the correct angle of inclination for the camera
for i=1:length(angles)
    curr_angle = angles(i);
    
    true_L_cm = (false_L_cm * cosd(curr_angle) * height)/(height - (false_L_cm * sind(curr_angle)));
    
    if abs(true_L_cm - 50) < diff
        correct_angle = curr_angle;
        diff = abs(true_L_cm - 50);
    end
    length_diff(i) = abs(true_L_cm - 50);
    
end


%% --- Transform the Coordinates ---

tl_x = mean(tbl.tl) - origin_x;
tl_y = origin_y - mean(tbl.tl_1);

br_x = mean(tbl.br) - origin_x;
br_y = origin_y - mean(tbl.br_1);

tr_x = mean(tbl.tr) - origin_x;
tr_y = origin_y - mean(tbl.tr_1);

for j = 1:8
    
    if j == 1
        var_x = tbl.nose;
        var_y = tbl.nose_1;
    elseif j==2
        var_x = tbl.tailbase;
        var_y = tbl.tailbase_1;
    elseif j==3
        var_x = tbl.bodycentre;
        var_y = tbl.bodycentre_1;
    elseif j==4
        var_x = tbl.home;
        var_y = tbl.home_1;
    elseif j==5
        var_x = tbl.tl;
        var_y = tbl.tl_1;
    elseif j==6
        var_x = tbl.tr;
        var_y = tbl.tr_1;
    elseif j==7
        var_x = tbl.bl;
        var_y = tbl.bl_1;
    elseif j==8
        var_x = tbl.br;
        var_y = tbl.br_1;
    end
    
    
    for i=1:size(tbl,1)
        
        % Correct the x coordinate
        curr_x = var_x(i,1) - origin_x;
        curr_y = origin_y - var_y(i,1);
        
        R_y = curr_y;
        R_x = tl_x * R_y/tl_y;
        
        z = tl_x;
        z_prime = R_x;
        RP = curr_x - R_x;
        
        dist_1 = abs(tl_x - tr_x);
        dist_2 = abs(tl_y - tr_y);
        y = sqrt(dist_1*dist_1 + dist_2*dist_2);
        a = y + 2*(z-z_prime);
        
        correct_x = RP + (2*z_prime*RP)/a;
        var_x(i,1) = correct_x * pixel_x_rate;
        
        % Correct the y coordinate
        
        L = false_L_cm*curr_y/tl_y;
        
        correct_y = (L*cosd(correct_angle)*height)/(height - L*sind(correct_angle));
        var_y(i,1) = correct_y;
        
    end
    
    
    if j == 1
        tbl.nose = var_x;
        tbl.nose_1 = var_y;
    elseif j==2
        tbl.tailbase = var_x;
        tbl.tailbase_1 = var_y;
    elseif j==3
        tbl.bodycentre = var_x;
        tbl.bodycentre_1 = var_y;
    elseif j==4
        tbl.home = var_x;
        tbl.home_1 = var_y;
    elseif j==5
        tbl.tl = var_x;
        tbl.tl_1 = var_y;
    elseif j==6
        tbl.tr = var_x;
        tbl.tr_1 = var_y;
    elseif j==7
        tbl.bl = var_x;
        tbl.bl_1 = var_y;
    elseif j==8
        tbl.br = var_x;
        tbl.br_1 = var_y;
    end
    
end

