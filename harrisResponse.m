function [H,R,C] = harrisResponse(Ixx, Iyy, Ixy)

Ixx = double(Ixx);
Iyy = double(Iyy);
Ixy = double(Ixy);

[sx, sy] = size(Ixx);
R = zeros(sy, sx);
for i = 1:sx,
    for j = 1:sy,
        H = [Ixx(i,j), Ixy(i,j);
            Ixy(i,j), Iyy(i,j)];
        R(j,i) = det(H) - 0.04*(trace(H).^2);
    end
end
[Cidx,Cidy] = find(R > 10000);
C = [Cidx,Cidy];
end