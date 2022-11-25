%% Baseline

name = 'VG2T20';
cond = 'Basal';
filename = 'VG2T20_Basal_ADLC_resnet50_Calb-1Jul13shuffle1_150000_filtered.csv'; 
datasheet_path = 'D:\ACL\Calb-1 09.07.21';
factors.plot = 0;
[measures_b_20, risk_b_20, factors_b_20, escape_b_20] = Main_CatOdor(name, cond, filename, datasheet_path, factors);


name = 'VG2T21';
cond = 'Basal';
filename = 'VG2T21_Basal_ADLC_resnet50_Calb-1Jul13shuffle1_150000_filtered.csv'; 
datasheet_path = 'D:\ACL\Calb-1 09.07.21';
factors.plot = 0;
[measures_b_21, risk_b_21, factors_b_21, escape_b_21] = Main_CatOdor(name, cond, filename, datasheet_path, factors);


name = 'VG2T24';
cond = 'Basal';
filename = 'VG2T24_Basal_ADLC_resnet50_Calb-1Jul13shuffle1_150000_filtered.csv'; 
datasheet_path = 'D:\ACL\Calb-1 09.07.21';
factors.plot = 0;
[measures_b_24, risk_b_24, factors_b_24, escape_b_24] = Main_CatOdor(name, cond, filename, datasheet_path, factors);


name = 'VG2T28';
cond = 'Basal';
filename = 'VG2T28_Basal_ADLC_resnet50_Calb-1Jul13shuffle1_150000_filtered.csv'; 
datasheet_path = 'D:\ACL\Calb-1 09.07.21';
factors.plot = 0;
[measures_b_28, risk_b_28, factors_b_28, escape_b_28] = Main_CatOdor(name, cond, filename, datasheet_path, factors);

%%  Cat Odour

name = 'VG2T20';
cond = 'Cat';
filename = 'VG2T20_Cat_BDLC_resnet50_Calb-1Jul13shuffle1_150000_filtered.csv'; 
datasheet_path = 'D:\ACL\Calb-1 09.07.21';
factors.plot = 0;
factors.std_length = factors_b_20.std_length;
factors.avg_length = factors_b_20.avg_length;
[measures_c_20, risk_c_20, factors_c_20, escape_c_20] = Main_CatOdor(name, cond, filename, datasheet_path, factors);

name = 'VG2T21';
cond = 'Cat';
filename = 'VG2T21_Cat_BDLC_resnet50_Calb-1Jul13shuffle1_150000_filtered.csv'; 
datasheet_path = 'D:\ACL\Calb-1 09.07.21';
factors.plot = 0;
factors.std_length = factors_b_21.std_length;
factors.avg_length = factors_b_21.avg_length;
[measures_c_21, risk_c_21, factors_c_21, escape_c_21] = Main_CatOdor(name, cond, filename, datasheet_path, factors);

name = 'VG2T24';
cond = 'Cat';
filename = 'VG2T24_Cat_BDLC_resnet50_Calb-1Jul13shuffle1_150000_filtered.csv'; 
datasheet_path = 'D:\ACL\Calb-1 09.07.21';
factors.plot = 0;
factors.std_length = factors_b_24.std_length;
factors.avg_length = factors_b_24.avg_length;
[measures_c_24, risk_c_24, factors_c_24, escape_c_24] = Main_CatOdor(name, cond, filename, datasheet_path, factors);

name = 'VG2T28';
cond = 'Cat';
filename = 'VG2T28_Cat_BDLC_resnet50_Calb-1Jul13shuffle1_150000_filtered.csv'; 
datasheet_path = 'D:\ACL\Calb-1 09.07.21';
factors.plot = 0;
factors.std_length = factors_b_28.std_length;
factors.avg_length = factors_b_28.avg_length;
[measures_c_28, risk_c_28, factors_c_28, escape_c_28] = Main_CatOdor(name, cond, filename, datasheet_path, factors);

%% Analysis - speed
analysis_sheet = 'D:\ACL\MethodsPaper\Cat Odor\Analysis.xlsx';

fig_path = [factors_c_20.datasheet_path filesep '..\MethodsPaper'];
if ~exist(fig_path)
    mkdir(fig_path);
end

speed_basal = [mean(escape_b_20.speed), mean(escape_b_21.speed), mean(escape_b_24.speed), mean(escape_b_28.speed)];
speed_cat = [mean(escape_c_20.speed), mean(escape_c_21.speed), mean(escape_c_24.speed), mean(escape_c_28.speed)];
writematrix(speed_basal',analysis_sheet,'Sheet','Basal','Range',['B' num2str(2)]);
writematrix(speed_cat',analysis_sheet,'Sheet','Cat','Range',['B' num2str(2)]);

x = [2 3];
xdiff = x(2)-x(1);
maxY = max(max(speed_basal), max(speed_cat)) + std(speed_cat);
minY = min(min(speed_basal), min(speed_cat)) - std(speed_cat);


for i = 1:length(speed_basal)
    plot(x,[speed_basal(i) speed_cat(i)],'color','k');
    hold all;
    scatter(x(1),speed_basal(i),'Marker','.','SizeData',200,'MarkerFaceColor','k','MarkerEdgeColor','k');
    hold all;
    scatter(x(2),speed_cat(i),'Marker','.','SizeData',200,'MarkerFaceColor','k','MarkerEdgeColor','k');
    hold all;
end

xlim([x(1)-xdiff/2 x(2)+xdiff/2]);
ylim([minY, maxY]);
set(gca,'xTick',x);
h = get(gca);
set(gca,'xTickLabel',{'Basal' 'Cat'});
xlabel('Velocity', 'FontSize',15);
h.XAxis.Label.Visible = 'on';
box off;
p_value = signrank(speed_cat, speed_basal);
title(['n=' num2str(length(speed_basal)) ', p=' num2str(p_value,'%0.1e')]);

set(gcf,'PaperPositionMode','auto');
set(gcf,'PaperOrientation','landscape');
saveas(gcf, [fig_path filesep ['EscapeVelocityComparison.png']]);
print('-painters','-dpdf', '-bestfit',[fig_path filesep ['EscapeVelocityComparison.pdf']]);
close;





%% Analysis - risk assessment

perc_b_20_s = risk_b_20.count_afterStart/(factors_b_20.time_fab-factors_b_20.time_start);
perc_b_21_s = risk_b_21.count_afterStart/(factors_b_21.time_fab-factors_b_21.time_start);
perc_b_24_s = risk_b_24.count_afterStart/(factors_b_24.time_fab-factors_b_24.time_start);
perc_b_28_s = risk_b_28.count_afterStart/(factors_b_28.time_fab-factors_b_28.time_start);
perc_b_s =[perc_b_20_s, perc_b_21_s, perc_b_24_s, perc_b_28_s];

perc_c_20_s = risk_c_20.count_afterStart/(factors_c_20.time_fab-factors_c_20.time_start);
perc_c_21_s = risk_c_21.count_afterStart/(factors_c_21.time_fab-factors_c_21.time_start);
perc_c_24_s = risk_c_24.count_afterStart/(factors_c_24.time_fab-factors_c_24.time_start);
perc_c_28_s = risk_c_28.count_afterStart/(factors_c_28.time_fab-factors_c_28.time_start);
perc_c_s =[perc_c_20_s, perc_c_21_s, perc_c_24_s, perc_c_28_s];

perc_b_20_sd = risk_b_20.count_afterStart_DangerZone/(factors_b_20.time_fab-factors_b_20.time_start);
perc_b_21_sd = risk_b_21.count_afterStart_DangerZone/(factors_b_21.time_fab-factors_b_21.time_start);
perc_b_24_sd = risk_b_24.count_afterStart_DangerZone/(factors_b_24.time_fab-factors_b_24.time_start);
perc_b_28_sd = risk_b_28.count_afterStart_DangerZone/(factors_b_28.time_fab-factors_b_28.time_start);
perc_b_sd =[perc_b_20_sd, perc_b_21_sd, perc_b_24_sd, perc_b_28_sd];

perc_c_20_sd = risk_c_20.count_afterStart_DangerZone/(factors_c_20.time_fab-factors_c_20.time_start);
perc_c_21_sd = risk_c_21.count_afterStart_DangerZone/(factors_c_21.time_fab-factors_c_21.time_start);
perc_c_24_sd = risk_c_24.count_afterStart_DangerZone/(factors_c_24.time_fab-factors_c_24.time_start);
perc_c_28_sd = risk_c_28.count_afterStart_DangerZone/(factors_c_28.time_fab-factors_c_28.time_start);
perc_c_sd =[perc_c_20_sd, perc_c_21_sd, perc_c_24_sd, perc_c_28_sd];

writematrix(perc_b_s',analysis_sheet,'Sheet','Basal','Range',['C' num2str(2)]);
writematrix(perc_c_s',analysis_sheet,'Sheet','Cat','Range',['C' num2str(2)]);
writematrix(perc_b_sd',analysis_sheet,'Sheet','Basal','Range',['D' num2str(2)]);
writematrix(perc_c_sd',analysis_sheet,'Sheet','Cat','Range',['D' num2str(2)]);

x = [2 3];
xdiff = x(2)-x(1);
maxY = max(max(perc_b_s), max(perc_c_s)) + std(perc_c_s);
minY = min(min(perc_b_s), min(perc_c_s)) - std(perc_c_s);


for i = 1:length(perc_b_s)
    plot(x,[perc_b_s(i) perc_c_s(i)],'color','k');
    hold all;
    scatter(x(1),perc_b_s(i),'Marker','.','SizeData',200,'MarkerFaceColor','k','MarkerEdgeColor','k');
    hold all;
    scatter(x(2),perc_c_s(i),'Marker','.','SizeData',200,'MarkerFaceColor','k','MarkerEdgeColor','k');
    hold all;
end

xlim([x(1)-xdiff/2 x(2)+xdiff/2]);
ylim([minY, maxY]);
set(gca,'xTick',x);
h = get(gca);
set(gca,'xTickLabel',{'Basal' 'Cat'});
xlabel('Stretched Length', 'FontSize',15);
h.XAxis.Label.Visible = 'on';
box off;
p_value = signrank(perc_b_s, perc_c_s);
title(['n=' num2str(length(perc_b_s)) ', p=' num2str(p_value,'%0.1e')]);

set(gcf,'PaperPositionMode','auto');
set(gcf,'PaperOrientation','landscape');
saveas(gcf, [fig_path filesep ['StretchLengthComparison.png']]);
print('-painters','-dpdf', '-bestfit',[fig_path filesep ['StretchLengthComparison.pdf']]);
close;


x = [2 3];
xdiff = x(2)-x(1);
maxY = max(max(perc_b_sd), max(perc_c_sd)) + std(perc_c_sd);
minY = min(min(perc_b_sd), min(perc_c_sd)) - std(perc_c_sd);


for i = 1:length(perc_b_sd)
    plot(x,[perc_b_sd(i) perc_c_sd(i)],'color','k');
    hold all;
    scatter(x(1),perc_b_sd(i),'Marker','.','SizeData',200,'MarkerFaceColor','k','MarkerEdgeColor','k');
    hold all;
    scatter(x(2),perc_c_sd(i),'Marker','.','SizeData',200,'MarkerFaceColor','k','MarkerEdgeColor','k');
    hold all;
end

xlim([x(1)-xdiff/2 x(2)+xdiff/2]);
ylim([minY, maxY]);
set(gca,'xTick',x);
h = get(gca);
set(gca,'xTickLabel',{'Basal' 'Cat'});
xlabel('StretchedLength in Danger Zone', 'FontSize',15);
h.XAxis.Label.Visible = 'on';
box off;
p_value = signrank(perc_b_sd, perc_c_sd);
title(['n=' num2str(length(perc_b_sd)) ', p=' num2str(p_value,'%0.1e')]);

set(gcf,'PaperPositionMode','auto');
set(gcf,'PaperOrientation','landscape');
saveas(gcf, [fig_path filesep ['StretchLengthComparisonDZ.png']]);
print('-painters','-dpdf', '-bestfit',[fig_path filesep ['StretchLengthComparisonDZ.pdf']]);
close;


%% Analysis - TO-fro

to_fro_b_20 = risk_b_20.count_run/(factors_b_20.time_fab-factors_b_20.time_start);
to_fro_b_21 = risk_b_21.count_run/(factors_b_21.time_fab-factors_b_21.time_start);
to_fro_b_24 = risk_b_24.count_run/(factors_b_24.time_fab-factors_b_24.time_start);
to_fro_b_28 = risk_b_28.count_run/(factors_b_28.time_fab-factors_b_28.time_start);
to_fro_b = [to_fro_b_20, to_fro_b_21, to_fro_b_24, to_fro_b_28];


to_fro_c_20 = risk_c_20.count_run/(factors_c_20.time_fab-factors_c_20.time_start);
to_fro_c_21 = risk_c_21.count_run/(factors_c_21.time_fab-factors_c_21.time_start);
to_fro_c_24 = risk_c_24.count_run/(factors_c_24.time_fab-factors_c_24.time_start);
to_fro_c_28 = risk_c_28.count_run/(factors_c_28.time_fab-factors_c_28.time_start);
to_fro_c = [to_fro_c_20, to_fro_c_21, to_fro_c_24, to_fro_c_28];

x = [2 3];
xdiff = x(2)-x(1);
maxY = max(max(to_fro_c), max(to_fro_b)) + std(to_fro_c);
minY = min(min(to_fro_c), min(to_fro_b)) - std(to_fro_c);

writematrix(to_fro_b',analysis_sheet,'Sheet','Basal','Range',['E' num2str(2)]);
writematrix(to_fro_c',analysis_sheet,'Sheet','Cat','Range',['E' num2str(2)]);


for i = 1:length(to_fro_c)
    plot(x,[to_fro_b(i) to_fro_c(i)],'color','k');
    hold all;
    scatter(x(1),to_fro_b(i),'Marker','.','SizeData',200,'MarkerFaceColor','k','MarkerEdgeColor','k');
    hold all;
    scatter(x(2),to_fro_c(i),'Marker','.','SizeData',200,'MarkerFaceColor','k','MarkerEdgeColor','k');
    hold all;
end

xlim([x(1)-xdiff/2 x(2)+xdiff/2]);
ylim([minY, maxY]);
set(gca,'xTick',x);
h = get(gca);
set(gca,'xTickLabel',{'Basal' 'Cat'});
xlabel('ToFro', 'FontSize',15);
h.XAxis.Label.Visible = 'on';
box off;
p_value = signrank(to_fro_c, to_fro_b);
title(['n=' num2str(length(to_fro_b)) ', p=' num2str(p_value,'%0.1e')]);

set(gcf,'PaperPositionMode','auto');
set(gcf,'PaperOrientation','landscape');
saveas(gcf, [fig_path filesep ['ToFroComparison.png']]);
print('-painters','-dpdf', '-bestfit',[fig_path filesep ['ToFroComparison.pdf']]);
close;

%% Writing Lengths

avg_len_b = [risk_b_20.avg_len, risk_b_21.avg_len, risk_b_24.avg_len, risk_b_28.avg_len];
avg_len_c = [risk_c_20.avg_len, risk_c_21.avg_len, risk_c_24.avg_len, risk_c_28.avg_len];

avg_len_left_b = [risk_b_20.avg_len_left, risk_b_21.avg_len_left, risk_b_24.avg_len_left, risk_b_28.avg_len_left];
avg_len_left_c = [risk_c_20.avg_len_left, risk_c_21.avg_len_left, risk_c_24.avg_len_left, risk_c_28.avg_len_left];

avg_len_right_b = [risk_b_20.avg_len_right, risk_b_21.avg_len_right, risk_b_24.avg_len_right, risk_b_28.avg_len_right];
avg_len_right_c = [risk_c_20.avg_len_right, risk_c_21.avg_len_right, risk_c_24.avg_len_right, risk_c_28.avg_len_right];

avg_len_middle_b = [risk_b_20.avg_len_middle, risk_b_21.avg_len_middle, risk_b_24.avg_len_middle,risk_b_28.avg_len_middle];
avg_len_middle_c = [risk_c_20.avg_len_middle, risk_c_21.avg_len_middle, risk_c_24.avg_len_middle, risk_c_28.avg_len_middle];

avg_len_above_thresh_b = [risk_b_20.avg_len_above_thresh, risk_b_21.avg_len_above_thresh, risk_b_24.avg_len_above_thresh, risk_b_28.avg_len_above_thresh];
avg_len_above_thresh_c = [risk_c_20.avg_len_above_thresh, risk_c_21.avg_len_above_thresh, risk_c_24.avg_len_above_thresh, risk_c_28.avg_len_above_thresh];

avg_len_above_thresh_x_b = [risk_b_20.avg_len_above_thresh_x, risk_b_21.avg_len_above_thresh_x, risk_b_24.avg_len_above_thresh_x, risk_b_28.avg_len_above_thresh_x];
avg_len_above_thresh_x_c = [risk_c_20.avg_len_above_thresh_x, risk_c_21.avg_len_above_thresh_x, risk_c_24.avg_len_above_thresh_x, risk_c_28.avg_len_above_thresh_x];



writematrix(avg_len_b',analysis_sheet,'Sheet','Basal','Range',['F' num2str(2)]);
writematrix(avg_len_left_b',analysis_sheet,'Sheet','Basal','Range',['G' num2str(2)]);
writematrix(avg_len_right_b',analysis_sheet,'Sheet','Basal','Range',['H' num2str(2)]);
writematrix(avg_len_middle_b',analysis_sheet,'Sheet','Basal','Range',['I' num2str(2)]);
writematrix(avg_len_above_thresh_b',analysis_sheet,'Sheet','Basal','Range',['J' num2str(2)]);
writematrix(avg_len_above_thresh_x_b',analysis_sheet,'Sheet','Basal','Range',['K' num2str(2)]);

writematrix(avg_len_c',analysis_sheet,'Sheet','Cat','Range',['F' num2str(2)]);
writematrix(avg_len_left_c',analysis_sheet,'Sheet','Cat','Range',['G' num2str(2)]);
writematrix(avg_len_right_c',analysis_sheet,'Sheet','Cat','Range',['H' num2str(2)]);
writematrix(avg_len_middle_c',analysis_sheet,'Sheet','Cat','Range',['I' num2str(2)]);
writematrix(avg_len_above_thresh_c',analysis_sheet,'Sheet','Cat','Range',['J' num2str(2)]);
writematrix(avg_len_above_thresh_x_c',analysis_sheet,'Sheet','Cat','Range',['K' num2str(2)]);

%% Writing Speed and distance

writematrix(escape_b_20.speed',analysis_sheet,'Sheet','VG2T20','Range',['A' num2str(2)]);
writematrix(escape_c_20.speed',analysis_sheet,'Sheet','VG2T20','Range',['B' num2str(2)]);
writematrix(escape_b_20.dist',analysis_sheet,'Sheet','VG2T20','Range',['C' num2str(2)]);
writematrix(escape_c_20.dist',analysis_sheet,'Sheet','VG2T20','Range',['D' num2str(2)]);

writematrix(escape_b_21.speed',analysis_sheet,'Sheet','VG2T21','Range',['A' num2str(2)]);
writematrix(escape_c_21.speed',analysis_sheet,'Sheet','VG2T21','Range',['B' num2str(2)]);
writematrix(escape_b_21.dist',analysis_sheet,'Sheet','VG2T21','Range',['C' num2str(2)]);
writematrix(escape_c_21.dist',analysis_sheet,'Sheet','VG2T21','Range',['D' num2str(2)]);

writematrix(escape_b_24.speed',analysis_sheet,'Sheet','VG2T24','Range',['A' num2str(2)]);
writematrix(escape_c_24.speed',analysis_sheet,'Sheet','VG2T24','Range',['B' num2str(2)]);
writematrix(escape_b_24.dist',analysis_sheet,'Sheet','VG2T24','Range',['C' num2str(2)]);
writematrix(escape_c_24.dist',analysis_sheet,'Sheet','VG2T24','Range',['D' num2str(2)]);

writematrix(escape_b_28.speed',analysis_sheet,'Sheet','VG2T28','Range',['A' num2str(2)]);
writematrix(escape_c_28.speed',analysis_sheet,'Sheet','VG2T28','Range',['B' num2str(2)]);
writematrix(escape_b_28.dist',analysis_sheet,'Sheet','VG2T28','Range',['C' num2str(2)]);
writematrix(escape_c_28.dist',analysis_sheet,'Sheet','VG2T28','Range',['D' num2str(2)]);