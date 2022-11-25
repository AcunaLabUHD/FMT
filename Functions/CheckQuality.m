function CheckQuality(table, factors, time_start, time_end, index)
% A variable quality_thresh is defined, currently the value is 0.95. The 
% idea of this threshold is that the likelihood of the markers should be 
% at least greater than or equal to 95%.


checks = 15; % Number of variables
count_var = zeros(1,checks);
bad_var = zeros(1,checks);
bad_count = 0;


for i=time_start:time_end
    flag = 1;

    for j = 1:checks
        count_var(1, j) = count_var(1, j)+1;
    end
    
    if table.nose_2(i,1) < factors.quality_thresh
        bad_var(1,1) = bad_var(1,1) + 1;
        if flag
            bad_count = bad_count + 1;
            flag = 0;
        end
    end
    if table.point1_2(i,1) < factors.quality_thresh
        bad_var(1,2) = bad_var(1,2) + 1;
        if flag
            bad_count = bad_count + 1;
            flag = 0;
        end
    end
    if table.point2_2(i,1) < factors.quality_thresh
        bad_var(1,3) = bad_var(1,3) + 1;
        if flag
            bad_count = bad_count + 1;
            flag = 0;
        end
    end
    if table.point3_2(i,1) < factors.quality_thresh
        bad_var(1,4) = bad_var(1,4) + 1;
        if flag
            bad_count = bad_count + 1;
            flag = 0;
        end
    end
    if table.bodycentre_2(i,1) < factors.quality_thresh
        bad_var(1,5) = bad_var(1,5) + 1;
        if flag
            bad_count = bad_count + 1;
            flag = 0;
        end
    end
    if table.point4_2(i,1) < factors.quality_thresh
        bad_var(1,6) = bad_var(1,6) + 1;
        if flag
            bad_count = bad_count + 1;
            flag = 0;
        end
    end 
    if table.point5_2(i,1) < factors.quality_thresh
        bad_var(1,7) = bad_var(1,7) + 1;
        if flag
            bad_count = bad_count + 1;
            flag = 0;
        end
    end
    if table.point6_2(i,1) < factors.quality_thresh
        bad_var(1,8) = bad_var(1,8) + 1;
        if flag
            bad_count = bad_count + 1;
            flag = 0;
        end
    end
    if table.tailbase_2(i,1) < factors.quality_thresh
        bad_var(1,9) = bad_var(1,9) + 1;
        if flag
            bad_count = bad_count + 1;
            flag = 0;
        end
    end
    if table.leftear_2(i,1) < factors.quality_thresh
        bad_var(1,10) = bad_var(1,10) + 1;
        if flag
            bad_count = bad_count + 1;
            flag = 0;
        end
    end
    if table.rightear_2(i,1) < factors.quality_thresh
        bad_var(1,11) = bad_var(1,11) + 1;
        if flag
            bad_count = bad_count + 1;
            flag = 0;
        end
    end
    if table.tl_2(i,1) < factors.quality_thresh
        bad_var(1,12) = bad_var(1,12) + 1;
        if flag
            bad_count = bad_count + 1;
            flag = 0;
        end
    end
    if table.tr_2(i,1) < factors.quality_thresh
        bad_var(1,13) = bad_var(1,13) + 1;
        if flag
            bad_count = bad_count + 1;
            flag = 0;
        end
    end
    if table.bl_2(i,1) < factors.quality_thresh
        bad_var(1,14) = bad_var(1,14) + 1;
        if flag
            bad_count = bad_count + 1;
            flag = 0;
        end
    end
    if table.br_2(i,1) < factors.quality_thresh
        bad_var(1,15) = bad_var(1,15) + 1;
        if flag
            bad_count = bad_count + 1;
            flag = 0;
        end
    end
end

bad_perc = zeros(1,checks+1);

for j = 1:checks
    bad_perc(1,j) = 100*bad_var(1,j)/count_var(1,j);
end

bad_perc(1,checks + 1) = 100*bad_count/count_var(1,1);
% disp(bad_perc);
% disp(bad_var);
% disp(count_var);


writematrix(bad_perc,factors.datasheet_fullpath,'Sheet','Quality','Range',['G' num2str(index+1)]);







    