clear
clc
close all
%% Read Images
% The size of images must be equal and 2^N must divide size of image where N is level of decomposition
[file, pathname] = uigetfile('*.jpg','Select the First Image ');cd(pathname);
a=imread(file);
a = imresize(a, [160 160]);
[file, pathname] = uigetfile('*.jpg','Select the Second Image ');cd(pathname);
b=imread(file);
b = imresize(b, [160 160]);

%% RGB Component of First Image
R1=a(:,:,1);G1=a(:,:,2);B1=a(:,:,3);

%% RGB Component of Second Image
R2=b(:,:,1);G2=b(:,:,2);B2=b(:,:,3);

%%   IHS Transformation 
I1=(R1+G1+B1)/3;
I2=(R2+G2+B2)/3;

%% Taking swt of first image
[a1,h1,v1,d1] = swt2(I1,3,'db1');
H1 = wcodemat(h1(:,:,1),255);
V1 = wcodemat(v1(:,:,1),255);
D1 = wcodemat(d1(:,:,1),255);

%% Taking swt of second image
[a2,h2,v2,d2] = swt2(I2,3,'db1');
H2 = wcodemat(h2(:,:,1),255);
V2 = wcodemat(v2(:,:,1),255);
D2 = wcodemat(d2(:,:,1),255);

%% Combination Rule
w1=[1/9 1/9 1/9;1/9 1/9 1/9;1/9 1/9 1/9];
w2=[2/15 2/15 2/15;2/15 2/15 2/15;1/15 1/15 1/15];
w3=[4/21 2/21 1/21;4/21 2/21 1/21;4/21 2/21 1/21];
w4=[8/35 4/35 2/35;8/35 4/35 2/35;4/35 2/35 1/35];

%% Calculating activity level and creating decision map
[r,c] = size(R1); 
for i=1:r
    for j=1:c
        A1(i,j)=sum(sum(w3*[H1(i,j);V1(i,j);D1(i,j)]));
        A2(i,j)=sum(sum(w3*[H2(i,j);V2(i,j);D2(i,j)]));
        if(A1(i,j)>A2(i,j))
           M(i,j)=1;
        else M(i,j)=0;
        end
    end
end

%% Consistency verification
for i=1:r
    for j=1:c
        s=0; t=0;
        if(i>1)
           s=s+M(i-1,j); t=t+1;
        end
        if(j>1)
           s=s+M(i,j-1); t=t+1;
        end
        if(i<r)
           s=s+M(i+1,j); t=t+1;
        end
        if(j<c)
           s=s+M(i,j+1); t=t+1;
        end
        if(i>1&&j>1)
           s=s+M(i-1,j-1); t=t+1;
        end
        if(i>1&&j<c)
           s=s+M(i-1,j+1); t=t+1;
        end
        if(i<r&&j>1)
           s=s+M(i+1,j-1); t=t+1;
        end
        if(i<r&&j<c)
           s=s+M(i+1,j+1); t=t+1;
        end
        if(s>t/2)
            M(i,j)=1;
        elseif(s<t/2)
               M(i,j)=0;  
        end
    end
end
Mb=ones(r,c)-M;

%% Fusion of image using decision map
for i=1:r
    for j=1:c
        RN(i,j)=M(i,j)*R1(i,j)+Mb(i,j)*R2(i,j);
        GN(i,j)=M(i,j)*G1(i,j)+Mb(i,j)*G2(i,j);
        BN(i,j)=M(i,j)*B1(i,j)+Mb(i,j)*B2(i,j);
    end
end

%% Combining RGB component of fused image
F(:,:,1)=RN;F(:,:,2)=GN;F(:,:,3)=BN;

%% Output in window
subplot(2,2,1), imshow(a,[])
title('Focus on left') 
subplot(2,2,2), imshow(b,[])
title('Focus on right') 
subplot(2,2,3), imshow(F,[]);
title('Fused Image Based on IHS+SWT Method ') 
