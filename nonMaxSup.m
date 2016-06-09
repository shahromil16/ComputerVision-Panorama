function Cout = nonMaxSup(Cin,img)

Cy = Cin(:,1);
Cx = Cin(:,2);

L = length(Cin);
[m,n] = size(img);
count = 0;

for i=1:L
    if Cx(i)>1 & Cy(i)>1 & Cx(i)<m & Cy(i)<n
        if img(Cx(i),Cy(i))>img(Cx(i)-1,Cy(i)) & img(Cx(i),Cy(i))>img(Cx(i)+1,Cy(i)) & img(Cx(i),Cy(i))>img(Cx(i),Cy(i)-1) & img(Cx(i),Cy(i))>img(Cx(i),Cy(i)+1) &...
                img(Cx(i),Cy(i))>img(Cx(i)-1,Cy(i)-1) & img(Cx(i),Cy(i))>img(Cx(i)+1,Cy(i)+1) & img(Cx(i),Cy(i))>img(Cx(i)+1,Cy(i)-1) & img(Cx(i),Cy(i))>img(Cx(i)-1,Cy(i)+1)
            count = count + 1;
            Cout(count,:) = Cin(i,:);
        end
    end
end