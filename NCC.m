function [XY,OFFXY,newImg] = NCC(img1, img2, Cout1, Cout2, colimg1, colimg2)

[n,m] = size(img1);
L1 = length(Cout1);
L2 = length(Cout2);
xpeak = 1;
ypeak = 1;
cnt = 0;
for i=1:L2
    if Cout2(i,1)>45 & Cout2(i,1)<m-45 & Cout2(i,2)>45 & Cout2(i,2)<n-45
        patch2 = img2(Cout2(i,2)-45:Cout2(i,2)+45,Cout2(i,1)-45:Cout2(i,1)+45);
        c = normxcorr2(patch2,img1);
        [ypeak, xpeak] = find(c==max(c(:)));
        yoffSet = ypeak-size(patch2,1);
        xoffSet = xpeak-size(patch2,2);
        for j=1:L1
            if Cout1(j,1)>45 & Cout1(j,1)<m-45 & Cout1(j,2)>45 & Cout1(j,2)<n-45
                patch1 = img1(Cout1(j,2)-45:Cout1(j,2)+45,Cout1(j,1)-45:Cout1(j,1)+45);
                if corr2(patch1,patch2)>0.8
                    cnt = cnt + 1;
                    XY(cnt,1) = Cout2(i,1)+m;
                    XY(cnt,2) = Cout2(i,2);
                    OFFXY(cnt,1) = Cout1(j,1);
                    OFFXY(cnt,2) = Cout1(j,2);
                end
            end
        end
    end
end

newImg = [colimg1, colimg2];
figure;
imshow(newImg);
hold on;
plot([OFFXY(:,1) XY(:,1)]',[OFFXY(:,2) XY(:,2)]','-Og');
hold off;