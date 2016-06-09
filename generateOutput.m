function generateOutput(I1,I2,inliers,originliers,OFFXY,XY)

quad11 = [];
quad21 = [];
quad12 = [];
quad22 = [];
[m,~] = size(I1);
hmat = originliers\inliers;
% imshow(I1); [X1,Y1]=ginput(4);
% imshow(I2); [X2,Y2]=ginput(4);
% rnd = ([rnd(1) rnd(2) rnd(4) rnd(3)])
% 
% X1 = originliers(rnd,1);
% X2 = inliers(rnd,1);
% Y1 = originliers(rnd,2);
% Y2 = inliers(rnd,2);
% X1 = [originliers(idx1,1);originliers(idx2,1);originliers(idx3,1);originliers(idx4,1)];
% Y1 = [originliers(idx1,2);originliers(idx2,2);originliers(idx3,2);originliers(idx4,2)];
% X2 = [inliers(idx1,1);inliers(idx2,1);inliers(idx3,1);inliers(idx4,1)];
% Y2 = [inliers(idx1,2);inliers(idx2,2);inliers(idx3,2);inliers(idx4,2)];

for i=1:length(inliers)
    if inliers(i,2)<m/2
        quad11 = [quad11;originliers(i,:)];
        quad21 = [quad21;inliers(i,:)];
    else
        quad12 = [quad12;originliers(i,:)];
        quad22 = [quad22;inliers(i,:)];
    end
end

% quad11 = quad11';
% quad21 = quad21';
% quad12 = quad12';
% quad22 = quad22';

[~,id11] = min(quad11(:,1));
[~,id12] = max(quad11(:,1));
[~,id21] = min(quad12(:,1));
[~,id22] = max(quad12(:,1));

rnd1 = [id11,id12];
rnd2 = [id22,id21];
X1 = [quad11(rnd1,1);quad12(rnd2,1)];
X2 = [quad21(rnd1,1);quad22(rnd2,1)];
Y1 = [quad11(rnd1,2);quad12(rnd2,2)];
Y2 = [quad21(rnd1,2);quad22(rnd2,2)];

imgpts1 = [X1 Y1];
imgpts2 = [X2 Y2];
imgptscap2 = imgpts1*hmat;
dist = (sqrt((imgpts2(:,1)-imgptscap2(:,1)).^2 + (imgpts2(:,2)-imgptscap2(:,2)).^2))

if mean(dist)<10
    figure;
    plot([X1],[Y1],'-Og',[X2],[Y2],'-Or')
    
    T = maketform('projective',[X2 Y2],[X1 Y1]);
    h = T.tdata.T;
    [~,xdataim2t,ydataim2t]=imtransform(I2,T);
    
    xdataout=[min(1,xdataim2t(1)) max(size(I1,2),xdataim2t(2))];
    ydataout=[min(1,ydataim2t(1)) max(size(I1,1),ydataim2t(2))];
    
    im2t=imtransform(I2,T,'XData',xdataout,'YData',ydataout);
    im1t=imtransform(I1,maketform('affine',eye(3)),'XData',xdataout,'YData',ydataout);
    
    ims=im1t/2+im2t/2;
    imd=uint8(abs(double(im1t)-double(im2t)));
    ims=max(im1t,im2t);
    
    [m,n]=size(ims);
    a1 = n/4;
    a2 = 3*n/4;
    filtimg = imfilter(ims(:,a1:1:a2),fspecial('gaussian',[1,3]),0.5);
    ims(:,a1:1:a2) = filtimg;
    figure;
    imshow(ims);
    
%     im1_pts = [X1 Y1];
%     im2_pts = [X2 Y2];
%     n = size(im1_pts, 1);
%     
%     A = zeros(2*n, 9);
%     
%     for i=1:n
%         p1 = im1_pts(i, :);
%         p2 = im2_pts(i, :);
%         A(2*i-1, :) = [-p1(1) -p1(2) -1 0 0 0 p2(1)*p1(1) p2(1)*p1(2) p2(1)];
%         A(2*i, :) = [0 0 0 -p1(1) -p1(2) -1 p2(2)*p1(1) p2(2)*p1(2) p2(2)];
%     end
%     [~, ~, V] = svd(A);
%     x = V(:,end);
%     x = x / norm(x);
%     %assert(norm(x) == 1);
%     h = (reshape(x, 3, 3));
%     [xi, yi] = meshgrid(1:512, 1:340);
%     xx = (h(1,1)*xi+h(1,2)*yi+h(1,3))./(h(3,1)*xi+h(3,2)*yi+h(3,3));
%     yy = (h(2,1)*xi+h(2,2)*yi+h(2,3))./(h(3,1)*xi+h(3,2)*yi+h(3,3));
%     foo = (interp2(double(rgb2gray(I2)),xx,yy));
%     figure; image(foo);
    
else
    [originliers, inliers, ~, ~] = INLIERS(OFFXY,[XY(:,1)-512,XY(:,2)],200);
    generateOutput(I1,I2,inliers,originliers,OFFXY,XY);
end