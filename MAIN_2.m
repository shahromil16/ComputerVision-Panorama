clear all
clc

imgList = dir('C:\Users\rams1\Desktop\Spring2016\CV\Projects\Project_2\DanaHallWay1\*.jpg');
imgNos = length(imgList);

dx = 0.25*[-1 0 1; -2 0 2; -1 0 1]; % The Mask 
dy = dx';
sigma = 0.5;
gauss = fspecial('gaussian',[5,5],sigma);

scale = 1;

cd('C:\Users\rams1\Desktop\Spring2016\CV\Projects\Project_2\DanaHallWay1\')
filename = imgList(1).name;
OrigI = imresize(imread(filename),scale);
I = rgb2gray(OrigI);
img = I;
Ix2 = conv2(img(:,:), dx, 'same').^2; Sx2 = conv2(Ix2,gauss, 'same');
Iy2 = conv2(img(:,:), dy, 'same').^2; Sy2 = conv2(Iy2,gauss, 'same');
Ixy = conv2(img(:,:), dx, 'same').*conv2(img(:,:), dy, 'same'); Sxy = conv2(Ixy,gauss, 'same');
[H,R,C] = harrisResponse(Sx2,Sy2,Sxy);
cd('C:\Users\rams1\Desktop\Spring2016\CV\Projects\Project_2\');
Cout= nonMaxSup(C,Sxy);
I2 = double(rgb2gray(OrigI));
I1 = double(rgb2gray(imread('lena.png')));
[um,un,~]=size(I2);

imshow(OrigI); [X2, Y2] = ginput(4);
X1 = [1;un;un;1];
Y1 = [1;1;um;um];

h = [X1 Y1]\[X2 Y2];
h = [h [0;0]; 0 0 1];
[xi, yi] = meshgrid(1:512, 1:340);
h = [1 0 X2(1);0 1 Y2(1); 0 0 1] * (h) * [1 0 -X2(2); 0 1 Y2(2); 0 0 1];
%h = inv(h); %TAKE INVERSE FOR USE WITH INTERP2
xx = (h(1,1)*xi+h(1,2)*yi+h(1,3))./(h(3,1)*xi+h(3,2)*yi+h(3,3));
yy = (h(2,1)*xi+h(2,2)*yi+h(2,3))./(h(3,1)*xi+h(3,2)*yi+h(3,3));
foo = uint8(interp2(I1,xx/2,yy/2)/255);
[m,n] = size(foo);

for i=1:m
    for j=1:n
        if foo(i,j)<2
            newimg(i,j,:) = OrigI(i,j,:);
        else
            newimg(i,j,:) = foo(i,j);
        end
    end
end

figure; imshow(newimg)