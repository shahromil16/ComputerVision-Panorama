clc;
clear all;
close all;

I2 = imread('DSC_0315.jpg');
I1 = imread('lena.png');
figure;
imshow(I1);
figure;
imshow(I2);

Igrey1 = (rgb2gray(I1));
Igrey2 = (rgb2gray(I2));

%imshow(I1); [x1,y1] = ginput(4);
x1 = [1;128;128;1]; y1 = [1;1;128;128];
imshow(I2); [x2,y2] = ginput(4);

x1 = x1(1:4);
x2 = x2(1:4);
y1 = y1(1:4);
y2 = y2(1:4);
A = zeros(size(x1,1)*2, 9);
for i = 1:size(x1,1)
A(2*i-1,:) = [x1(i),y1(i),1, 0,0,0, -x1(i)*x2(i),-x2(i)*y1(i),-x2(i)];
A(2*i,:) = [0,0,0, x1(i),y1(i),1, -x1(i)*y2(i),-y2(i)*y1(i),-y2(i)];
end

[U,S,V] = svd(A);
h = V(:,9);
H = [h(1),h(2),h(3);h(4),h(5),h(6);h(7),h(8),h(9)];

p1s = [1; 1; 1];
p2s = [size(Igrey1,2); 1; 1];
p3s = [1; size(Igrey1,1); 1];
p4s = [size(Igrey1,2); size(Igrey1,1); 1];
p1sd = H*p1s; p1sd = p1sd/p1sd(3);
p2sd = H*p2s; p2sd = p2sd/p2sd(3);
p3sd = H*p3s; p3sd = p3sd/p3sd(3);
p4sd = H*p4s; p4sd = p4sd/p4sd(3);

p1dd = [1; 1; 1];
p2dd = [size(Igrey2,2); 1; 1];
p3dd = [1; size(Igrey2,1); 1];
p4dd = [size(Igrey2,2); size(Igrey2,1); 1];

minx = floor(min([p1dd(1), p2dd(1), p3dd(1), p4dd(1), p1sd(1), p2sd(1), p3sd(1), p4sd(1)]));
miny = floor(min([p1dd(2), p2dd(2), p3dd(2), p4dd(2), p1sd(2), p2sd(2), p3sd(2), p4sd(2)]));
maxx = ceil(max([p1dd(1), p2dd(1), p3dd(1), p4dd(1), p1sd(1), p2sd(1), p3sd(1), p4sd(1)]));
maxy = ceil(max([p1dd(2), p2dd(2), p3dd(2), p4dd(2), p1sd(2), p2sd(2), p3sd(2), p4sd(2)]));

[xi, yi] = meshgrid(minx:maxx,miny:maxy);
h = inv(H);

xx = (h(1,1)*xi+h(1,2)*yi+h(1,3))./(h(3,1)*xi+h(3,2)*yi+h(3,3));
yy = (h(2,1)*xi+h(2,2)*yi+h(2,3))./(h(3,1)*xi+h(3,2)*yi+h(3,3));

% source
pixs = (xx > 1) & (xx < size(Igrey1,2)) & (yy > 1) & (yy < size(Igrey1,1));
    
%destination
pixd = zeros(size(xx));
xd = 1:size(Igrey2,2);
yd = 1:size(Igrey2,1);
ydd = yd - miny + 1;
xdd = xd - minx + 1;

sigma = 3;

feather = bsxfun(@times,...
    normpdf(ydd,mean(ydd),size(Igrey2,1)/(2*sigma)).',...
    normpdf(xdd,mean(xdd),size(Igrey2,2)/(2*sigma)));
pixd(ydd,xdd) = feather;
pixw = bsxfun(@times,...
    normpdf(xx,mean([1 size(Igrey1,2)]),size(Igrey1,2)/(2*sigma)),...
    normpdf(yy,mean([1 size(Igrey1,1)]),size(Igrey1,1)/(2*sigma)));
% set weight of valid pixels for the source image
pixs = pixs .* pixw;

rel_weight = 100;

pixs = pixs .* rel_weight;
% interpolate source image values to map them to the destination image
Source_mapped = uint8(interp2(double(Igrey1),xx,yy)/255);

% map the destination to the expanded coordinate system
Dest_mapped = uint8(zeros(size(Source_mapped)));
Dest_mapped(ydd, xdd) = Igrey2;

% average the overlapping pixels
Source_mapped = double(Source_mapped);
Dest_mapped = double(Dest_mapped);

sum_im = Source_mapped.*pixs + Dest_mapped.*pixd;
pix = pixs + pixd;
overlap_pix = pix > 0;
sum_im(overlap_pix) = sum_im(overlap_pix) ./ pix(overlap_pix);

stitched_Im = uint8(sum_im);


stitched_im = stitch_images(Igrey1,Igrey2,H,100);
figure;
imshow(stitched_im);