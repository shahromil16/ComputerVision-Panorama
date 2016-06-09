function [ stitched_Im, IM] = stitch_images( Igrey1, Igrey2, H, rel_weight)

%% find min/max x/y coordinates

% find boundaries
% source boundaries, source fram
p1s = [1; 1; 1];
p2s = [size(Igrey1,2); 1; 1];
p3s = [1; size(Igrey1,1); 1];
p4s = [size(Igrey1,2); size(Igrey1,1); 1];

% source boundaries, destination frame
p1sd = H*p1s; p1sd = p1sd/p1sd(3);
p2sd = H*p2s; p2sd = p2sd/p2sd(3);
p3sd = H*p3s; p3sd = p3sd/p3sd(3);
p4sd = H*p4s; p4sd = p4sd/p4sd(3);

% destination boundaries, destination frame
p1dd = [1; 1; 1];
p2dd = [size(Igrey2,2); 1; 1];
p3dd = [1; size(Igrey2,1); 1];
p4dd = [size(Igrey2,2); size(Igrey2,1); 1];

% get min/max coordinates in destination frame
minx = floor(min([p1dd(1), p2dd(1), p3dd(1), p4dd(1), p1sd(1), p2sd(1), p3sd(1), p4sd(1)]));
miny = floor(min([p1dd(2), p2dd(2), p3dd(2), p4dd(2), p1sd(2), p2sd(2), p3sd(2), p4sd(2)]));
maxx = ceil(max([p1dd(1), p2dd(1), p3dd(1), p4dd(1), p1sd(1), p2sd(1), p3sd(1), p4sd(1)]));
maxy = ceil(max([p1dd(2), p2dd(2), p3dd(2), p4dd(2), p1sd(2), p2sd(2), p3sd(2), p4sd(2)]));

% get coords for the destination frame
[xi, yi] = meshgrid(minx:maxx,miny:maxy);
h = inv(H);

% get corresponding coordinates for the source frame using the homography
xx = (h(1,1)*xi+h(1,2)*yi+h(1,3))./(h(3,1)*xi+h(3,2)*yi+h(3,3));
yy = (h(2,1)*xi+h(2,2)*yi+h(2,3))./(h(3,1)*xi+h(3,2)*yi+h(3,3));

%% get boolean 2D array of which pixels are valid
% source
pixs = (xx > 1) & (xx < size(Igrey1,2)) & (yy > 1) & (yy < size(Igrey1,1));
    
%destination
pixd = zeros(size(xx));
xd = 1:size(Igrey2,2);
yd = 1:size(Igrey2,1);
ydd = yd - miny + 1;
xdd = xd - minx + 1;

% 
% feathering
sigma = 3;

%% feathering
sigma = 3; % set standard deviation at the boundary of the image
%  create 2D gaussian kernel
feather = bsxfun(@times,...
    normpdf(ydd,mean(ydd),size(Igrey2,1)/(2*sigma)).',...
    normpdf(xdd,mean(xdd),size(Igrey2,2)/(2*sigma)));
% set weight of valid pixels for the destination image
pixd(ydd,xdd) = feather;

% create 2D gaussian kernel for the source image
pixw = bsxfun(@times,...
    normpdf(xx,mean([1 size(Igrey1,2)]),size(Igrey1,2)/(2*sigma)),...
    normpdf(yy,mean([1 size(Igrey1,1)]),size(Igrey1,1)/(2*sigma)));
% set weight of valid pixels for the source image
pixs = pixs .* pixw;

% set a relative weight
if(nargin<4)
    rel_weight = 1;
end

pixs = pixs .* rel_weight;

%% map and stitch images
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

% display
% figure; imshow(uint8(Source_mapped)); title('Source Image');
% figure; imshow(uint8(Dest_mapped)); title('Destination Image');
% figure; imshow(stitched_Im);

IM.source = Source_mapped;
IM.dest = Dest_mapped;
IM.source_mask = pixs;
IM.dest_mask = pixd;
IM.stitched = stitched_Im;
IM.stitched_mask = pix;

end