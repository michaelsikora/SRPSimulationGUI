function [X,Y] = getLocs(fov,N,label)
%GETPLATLOC function to get user input for x and y coordinates.
% fov - the corners of a rectangle coordinate region. currently ignores
%   z axis
% N - number of points to get

in = figure;
% axis([fov(1,:), fov(2,:)]);
title({'Click on figure region to select',['location(s) for ', label]});
[X,Y] = ginput(N);
outbound = find(X < 0 | X > 1 | Y < 0 | Y > 1);
while ~isempty(outbound)
    [X(outbound), Y(outbound)] = ginput(length(outbound));
    outbound = find(X < 0 | X > 1 | Y < 0 | Y > 1);
end
width = abs(fov(1,2)-fov(1,1));
height = abs(fov(2,2)-fov(2,1));
X = X.*width+fov(1,1);
Y = Y.*height+fov(2,1);
close(in);

end

