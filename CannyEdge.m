clear;

%clear all;
numpix = 16384; %number of pixels in the Array
iframe = 903:903; %indices of frames to be used for analysis
[fname,sdir,filtx] = uigetfile('*.SEQ','Select Raw Sequence File', 'MultiSelect', 'off');
fstartri = 512; %offset to begin R&I data
framesize = 66960; %size of each frame in bytes
fid1 = fopen([sdir fname],'r+'); %open file
xpxl = 1:128; %X pixel region
ypxl = 1:128; %Y pixel region

for frame=iframe(1):iframe(1)+size(iframe,2)-1;
fseek(fid1, fstartri+(frame-1)*framesize,'bof');   % start of R&I data
RIvector =  uint32(fread(fid1,numpix,'uint32','l')); % read R&I vector
RIvector = fliplr(flipud(reshape(RIvector,128,128))); %orient image
Intensity(:,:,frame-iframe(1)+1) = bitand(RIvector(ypxl,xpxl),4095); %Intensity Matrix
Range(:,:,frame-iframe(1)+1) = double(bitshift(RIvector(ypxl,xpxl),-12))./64; %Range Matrix
end
fclose(fid1);
IntensityGray = mat2gray(Intensity);
%imshow(IntensityGray)
subplot(1,2,1);
imshow(IntensityGray);

%load an image, convert to float and extract luminance
%img = imread('flower.jpg');
%img = imread('mechanical.png');
%gray_img = rgb2gray(img);
%float_gray_img = im2double(gray_img);
%imshow(float_gray_img);
%construct a gaussian filter and convolve with image
I = IntensityGray;
%derivative of gaussian

%size 10, sigma = 2 for the flower image
%size 10, sigma = 2.8 for the mechanical image
Size = 10;
sigma = 2.8 ;
interval = -Size : Size;
[X Y] = meshgrid(interval, interval);
Gauss = exp(-(X.^2 + Y.^2) / (2*sigma^2));
Gauss = Gauss / sum(Gauss(:));

%convolve with derivative of gaussian in x&y directions
I_gauss = conv2(IntensityGray, Gauss ,'same');

%Fx,Fy
[Fx,Fy] = imgradientxy(I_gauss);
%strength F
F = sqrt(Fx.^2 + Fy.^2);

%orientation D
D = atan2(Fy, Fx);
[m,n] = size(D);
for i = 1:m
    for j = 1:n
        if D(i,j) < 0
            D(i,j) = D(i,j) + pi;
        end 
    end 
end 


%nonmax suppression
D_star = zeros(m,n);

for i = 1: m   % traversing rows
    for j = 1: n  %traversing columns     
        if D(i,j) >= 0 && D(i,j) <= pi/4
            if D(i,j) < (pi/4 - D(i,j))
                D_star(i,j) = 0;
            else 
                D_star(i,j) = pi/4;
            end 
        elseif D(i,j) > pi/4 && D(i,j) <= pi/2
            if (D(i,j)-pi/4) < (pi/2 - D(i,j))
                D_star(i,j) = pi/4;
            else 
                D_star(i,j) = pi/2;
            end 
        elseif D(i,j) > pi/2 && D(i,j) <= 3*pi/4
            if (D(i,j)-pi/2) < (3*pi/4 - D(i,j))
                D_star(i,j) = pi/2;
            else 
                D_star(i,j) = 3*pi/4;
            end 
        else 
            if (D(i,j)-3*pi/4) < (2*pi - D(i,j))
                D_star(i,j) = 3*pi/4;
            else 
                D_star(i,j) = 0;
            end            
        end 
    end 
end 

for i = 2: m-1   % traversing rows
    for j = 2: n-1  %traversing columns     
        if I(i,j) == 0
            if F(i,j) < F(i,j+1) || F(i,j) < F(i,j-1)
                I(i,j) = 0;
            else 
                I(i,j) = F(i,j);
            end 
        elseif I(i,j) == pi/4
            if F(i,j) < F(i-1,j+1) || F(i,j) < F(i+1,j-1)
                I(i,j) = 0;
            else 
                I(i,j) = F(i,j);
            end 
        elseif I(i,j) == pi/2
            if F(i,j) < F(i-1,j) || F(i,j) < F(i+1,j)
                I(i,j) = 0;
            else 
                I(i,j) = F(i,j);
            end 
        else 
            if F(i,j) < F(i-1,j-1) || F(i,j) < F(i+1,j+1)
                I(i,j) = 0;
            else 
                I(i,j) = F(i,j);
            end            
        end 
    end 
end 

%T_low = 0.03, T_high=0.065 for the flower image
%T_low = 0.05, T_high=0.07 for the mechanical image
T_low = 0.03;
T_high = 0.065;

I_2 = I;
for i = 1:m
    for j = 1:n
        if I(i,j) >= T_high
            I_2(i,j) = 1;
        elseif I(i,j) < T_high && I(i,j) >= T_low
            I_2(i,j) = 0.5;
        else 
            I_2(i,j) = 0;
        end 
    end 
end 

I_3 = I_2;
for i = 2:m-1
    for j = 2:n-1
        if I_2(i,j) == 1
            if I_2(i+1,j) == 0.5
                I_3(i+1,j) = 1;
            end 
            if I_2(i-1,j) == 0.5
                I_3(i-1,j) = 1;
            end 
            if I_2(i,j-1) == 0.5
                I_3(i,j-1) = 1; 
            end 
            if I_2(i,j+1) == 0.5  
                I_3(i,j+1) = 1;
            end 
            if I_2(i+1,j+1) == 0.5
                I_3(i+1,j+1) = 1;
            end 
            if I_2(i-1,j-1) == 0.5
                I_3(i-1,j-1) = 1;
            end 
            if I_2(i-1,j+1) == 0.5
                I_3(i-1,j+1) = 1;
            end 
            if I_2(i+1,j-1) == 0.5
                I_3(i+1,j-1) = 1;
            end  
        end 
    end 
end 

for i = 1:m
    for j = 1:n
        if I_3(i,j) == 0.5
        I_3(i,j) = 0;
        end 
    end 
end 

%imshow(I_3); % I_3 is the end result

subplot(1,2,2);
imshow(I_3);

