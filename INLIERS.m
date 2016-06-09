function  [originliers, inliers, origoutliers, outliers] = INLIERS(xyoff,xy,iter)

n = length(xyoff);
inliers = [];
originliers = [];
hmat = xyoff\xy;
XYC = (hmat*xyoff')';
% mndist = sqrt((XYC(:,1)-xyoff(:,1)).^2 + (XYC(:,2)-xyoff(:,2)).^2);
% 
for i=1:iter
    sno = randperm(n,4); 
    loc1 = xyoff(sno,:)';
    loc2 = xy(sno,:)';
    if length(unique(loc2','rows'))==4
        H = loc2/loc1;
        xycap = round(H*loc1);
        dist = sqrt((loc2(1,:)-xycap(1,:)).^2 + (loc2(2,:)-xycap(2,:)).^2);
        thresh = 2;
        [~,idy] = find(dist<thresh);
        inliers = [inliers, loc2(:,idy)];
        originliers = [originliers, loc1(:,idy)];
    end
end

mat = unique([inliers', originliers'],'rows');
inliers = mat(:,1:2);
originliers = mat(:,3:4);

[a,b,~] = unique(inliers,'rows');
inliers = a;
originliers = originliers(b,:);

% for i=1:length(inliers)
%     for j=i:length(inliers)
%         if ((inliers(i,1)==inliers(j,1)) & (inliers(i,2)==inliers(j,2))) | ((originliers(i,1)==originliers(j,1)) & (originliers(i,2)==originliers(j,2)))
%             inliers(j,:) = [];
%             originliers(i,:) = [];
%         end
%     end
% end

temp = ismember(xy,inliers);
pos = find(temp(:,1)==0 & temp(:,2)==0);
outliers = xy(pos,:);
origoutliers = xyoff(pos,:);

mat = unique([outliers, origoutliers],'rows');
outliers = mat(:,1:2);
origoutliers = mat(:,3:4);

end