function lts = Length(table)

d1 = sqrt((table.nose - table.point1).^2 + (table.nose_1 - table.point1_1).^2);
d2 = sqrt((table.point1 - table.point2).^2 + (table.point1_1 - table.point2_1).^2);
d3 = sqrt((table.point2 - table.point3).^2 + (table.point2_1 - table.point3_1).^2);
d4 = sqrt((table.point3 - table.bodycentre).^2 + (table.point3_1 - table.bodycentre_1).^2);
d5 = sqrt((table.bodycentre - table.point4).^2 + (table.bodycentre_1 - table.point4_1).^2);
d6 = sqrt((table.point4 - table.point5).^2 + (table.point4_1 - table.point5_1).^2);
d7 = sqrt((table.point5 - table.point6).^2 + (table.point5_1 - table.point6_1).^2);
d8 = sqrt((table.point6 - table.tailbase).^2 + (table.point6_1 - table.tailbase_1).^2);

lts = d1 + d2 + d3 + d4 + d5 + d6 + d7 + d8;

return;