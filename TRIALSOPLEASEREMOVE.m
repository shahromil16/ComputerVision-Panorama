I1 = double(OrigI{1});                         	% loads image 1
 [h1, w1, d1] = size(I1); 
I2 = double(OrigI{2});                       	% load images 2
 [h2, w2, d2] = size(I2);  

%  figure; 		 	              	% creates a new figure window
% subplot(1,2,1); 			% divides current figure into 1(row) by 2(columns), it focuses 
% %				     on the 1st subfigure
% image(I1/255); 			% displays the image
% axis image; 				% displays the axis on the image
% hold on; 
% title('first input image'); 
% [X1, Y1] = ginput(2); 			% gets two points from the user 	
% subplot(1,2,2); 			% takes the previous figure window and focuses 
% 				    % on the 2nd subfigure
% image(I2/255); axis image; hold on; 
% title('second input image'); 
% [X2, Y2] = ginput(2); % get two points from the user  

X1 = [originliers(4,1);originliers(end-3,1)];
X2 = [inliers(4,1);inliers(end-3,1)];
Y1 = [originliers(4,2);originliers(end-3,2)];
Y2 = [inliers(4,2);inliers(end-3,2)];

% estimate parameter vector (t) 
Z = [ X2' Y2'; Y2' -X2' ; 1 1 0 0; 0 0 1 1 ]';
xp = [ X1 ; Y1 ];
t = Z \ xp;                                      % solve the linear system
a = t(1); % = s cos(alpha)
b = t(2); % = s sin(alpha)
tx = t(3); 
ty = t(4);  

% construct transformation matrix (T) 
T = ([a b tx ; -b a ty ; 0 0 1]);  

% warps incoming corners to determine the size of the output image (in to out) 
cp = T*[ 1 1 w2 w2 ; 1 h2 1 h2 ; 1 1 1 1 ];
Xpr = min( [ cp(1,:) 0 ] ) : max( [cp(1,:) w1] ); % min x : max x 
Ypr = min( [ cp(2,:) 0 ] ) : max( [cp(2,:) h1] ); % min y : max y 
[Xp,Yp] = ndgrid(Xpr,Ypr); 
[wp hp] = size(Xp); % = size(Yp)  

% do backwards transform (from out to in) 
X = T \ [ Xp(:) Yp(:) ones(wp*hp,1) ]'; % warp  

% re-sample pixel values with bilinear interpolation 
clear Ip; 
xI = reshape( X(1,:),wp,hp)'; 
yI = reshape( X(2,:),wp,hp)'; 
Ip(:,:,1) = interp2(I2(:,:,1), xI, yI, '*bilinear'); % red 
Ip(:,:,2) = interp2(I2(:,:,2), xI, yI, '*bilinear'); % green 
Ip(:,:,3) = interp2(I2(:,:,3), xI, yI, '*bilinear'); % blue  

% offset and copy original image into the warped image 
offset =  -round( [ min( [ cp(1,:) 0 ] ) min( [ cp(2,:) 0 ] ) ] ); 
Ip(1+offset(2):h1+offset(2),1+offset(1):w1+offset(1),:) = double(I1(1:h1,1:w1,:));  

% show the result 
figure; image(rgb2gray(uint8(Ip/255))); axis image; 
title('mosaic image');
