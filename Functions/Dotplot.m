function Dotplot(var_x, var_y, startframe, endframe)

if ~exist('startframe', 'var')
    startframe = 1;
end

if ~exist('endframe', 'var')
    endframe = length(var_x)-10;
end

plot(var_x(startframe:endframe, 1), var_y(startframe:endframe, 1), '.');
xlabel('X coordinate (cm)');
ylabel('Y coordinate (cm)');

return;

