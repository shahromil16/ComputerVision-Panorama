im1_pts = [X1 Y1];
im2_pts = [X2 Y2];
n = size(im1_pts, 1);

A = zeros(2*n, 9);

for i=1:n
    p1 = im1_pts(i, :);
    p2 = im2_pts(i, :);
    A(2*i-1, :) = [-p1(1) -p1(2) -1 0 0 0 p2(1)*p1(1) p2(1)*p1(2) p2(1)];
    A(2*i, :) = [0 0 0 -p1(1) -p1(2) -1 p2(2)*p1(1) p2(2)*p1(2) p2(2)];
end
[~, ~, V] = svd(A);
x = V(:,end);
x = x / norm(x);
%assert(norm(x) == 1);
h = (reshape(x, 3, 3));

[xi, yi] = meshgrid(1:512, 1:340);
xx = (h(1,1)*xi+h(1,2)*yi+h(1,3))./(h(3,1)*xi+h(3,2)*yi+1);
yy = (h(2,1)*xi+h(2,2)*yi+h(2,3))./(h(3,1)*xi+h(3,2)*yi+1);
foo = uint8(interp2(double(I{3}),xx,yy));
figure; imshow(foo);