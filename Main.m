clear all
clc

imgList = dir('C:\Users\rams1\Desktop\Spring2016\CV\Projects\Project_2\DanaHallWay2\*.jpg');
imgNos = length(imgList);

dx = 0.25*[-1 0 1; -2 0 2; -1 0 1]; % The Mask 
dy = dx';
sigma = 0.5;
gauss = fspecial('gaussian',[5,5],sigma);

scale = 1;

for i=1:imgNos
    cd('C:\Users\rams1\Desktop\Spring2016\CV\Projects\Project_2\DanaHallWay2\')
    filename = imgList(i).name;
    OrigI{i} = imresize(imread(filename),scale);
    I{i} = rgb2gray(OrigI{i});
    img = I{i};
    Ix2 = conv2(img(:,:), dx, 'same').^2; Sx2{i} = conv2(Ix2,gauss, 'same');
    Iy2 = conv2(img(:,:), dy, 'same').^2; Sy2{i} = conv2(Iy2,gauss, 'same');
    Ixy = conv2(img(:,:), dx, 'same').*conv2(img(:,:), dy, 'same'); Sxy{i} = conv2(Ixy,gauss, 'same');
    [H{i},R{i},C{i}] = harrisResponse(Sx2{i},Sy2{i},Sxy{i});
    cd('C:\Users\rams1\Desktop\Spring2016\CV\Projects\Project_2\');
    figure(i)
    Cout{i} = nonMaxSup(C{i},Sxy{i});
    imshow(OrigI{i});
    hold on; 
    plot(Cout{i}(:,1),Cout{i}(:,2),'r*');
    hold off;
end

[XY,OFFXY,stitch1] = NCC(I{1}, I{2}, Cout{1}, Cout{2}, OrigI{1}, OrigI{2});

[originliers, inliers, origoutliers, outliers] = INLIERS(OFFXY,[XY(:,1)-512,XY(:,2)],400);
inliers(:,1) = inliers(:,1) + 512;
outliers(:,1) = outliers(:,1) + 512;
figure;
imshow(stitch1);
hold on;
plot([originliers(:,1) inliers(:,1)]',[originliers(:,2) inliers(:,2)]','-Og',...
    [origoutliers(:,1) outliers(:,1)]',[origoutliers(:,2) outliers(:,2)]','-Or');
hold off;

figure;
imshow(stitch1);
hold on;
for i=1:length(inliers)
    hold on;
    plot([originliers(i,1) inliers(i,1)]',[originliers(i,2) inliers(i,2)]');
end
hold off;

inliers(:,1) = inliers(:,1) - 512;
outliers(:,1) = outliers(:,1) - 512;

generateOutput(OrigI{1},OrigI{2},inliers,originliers,OFFXY,XY);