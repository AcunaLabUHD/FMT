function Lineplot(var_x, var_y, var_p, var_name, startframe, endframe)

if ~exist('startframe', 'var')
    startframe = 1;
end

if ~exist('endframe', 'var')
    endframe = length(var_x) - 10;
end

for i=startframe+1:endframe
    if var_p(i-1,1)<0.5
        c = 'r';
    elseif var_p(i-1,1)<0.8
        c = 'b';
    else
        c = 'c';
    end
    
    plot([var_x(i-1,1) var_x(i,1)], [var_y(i-1,1) var_y(i,1)], c, 'LineWidth', 1);
    hold all;
end

title(var_name);   
xlabel('X Coordinates (cm)');
ylabel('Y Coordinates (cm)');


return;

