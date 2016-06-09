function [x,y] = input_cornerpts(image)
figure,imshow(image,[]);
Flag = 1;
hold on
x=[];y=[];
while (Flag==1)
title('Select the corner points');
[xt,yt] = ginput(1);
x = vertcat(x,xt);
y = vertcat(y,yt);
plot(xt,yt,'r.');
title('Press mouse button to continue and any key to exit');
t = waitforbuttonpress;
if t == 1
Flag = 0;
end
end
hold off
close
end