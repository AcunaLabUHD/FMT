function H = densityplot(x,y,varargin)

if isrow(x)
    x = x(:);
end
if isrow(y)
    y = y(:);
end
% combine
X = [x,y];

% Creating a 2d histogram
% N is a matrix containing the number of elements of X that fall in 
%   each bin of the grid.
% C returns the positions of the bin centers in a 1-by-2 cell array
%   of numeric vectors.
[N,C] = hist3(X, varargin{:});

%Get polygon half widths
wx=C{1}(:);
wy=C{2}(:);

% Create the density plot
figure
H = pcolor(wx, wy, N');
box on
shading interp
set(H,'edgecolor','none');
m = colorbar
colormap jet
set(m, 'Ticks', [0, 0.2*max(max(N)), 0.4*max(max(N)), 0.6*max(max(N)), 0.8*max(max(N)), max(max(N))]); 
set(m, 'TickLabels', {'0', '20%', '40%', '60%', '80%', '100%'});
