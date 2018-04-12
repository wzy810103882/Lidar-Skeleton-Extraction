clear all;
% tried to implement anisotrpoic / kernel low pass to reduce noise /
% preserve edge but since the frame image size is 128x128, there is no need
% to further blur the image

% tried to implement a custom canny edge detector adapted to dead pixels
% but ended up implementing a function that fixs the dead pixels and use
% the matlab embedded canny edge detector

% tried inpainting and imfill to fix deadpixel problems
% tried people dector for human detection
% tried binarize image using different algorithms to extract information (allowing faster morphological operation)
% used average for dead pixel fix, could've used median

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
IntensityGrayFixedByAveraging = IntensityGray;
%8 connectivity
IntensityGrayFixed = imfill(IntensityGray,8);

%window size 4, iteraton 10 times 
[IntensityGrayFixedByAveraging] = deadPixelFix(IntensityGray,4,10);



peopleDetector = vision.PeopleDetector('UprightPeople_96x48');
peopleDetector.ClassificationThreshold = 1;
peopleDetector.WindowStride = 4;

[bboxes,scores] = step(peopleDetector,IntensityGrayFixedByAveraging);
humandetection1 = insertObjectAnnotation(IntensityGrayFixedByAveraging,'rectangle',bboxes,scores);
subplot(3,3,8)
imshow(humandetection1)
title('Detected people and detection scores using IntensityGrayFixedByAveraging');

[scoremax,maxindex] = max(scores);

MagFactor = 2;
x1 = (bboxes(maxindex,1))*MagFactor;
x2 = (bboxes(maxindex,1)+bboxes(maxindex,3)-1)*MagFactor;
y1 = (bboxes(maxindex,2))*MagFactor;
y2 = (bboxes(maxindex,4)+bboxes(maxindex,2)-1)*MagFactor;


%submatrix = IntensityGray(i-winsize:i+winsize,j-winsize:j+winsize);
subplot(3,3,1)
imshow(IntensityGray)
title('IntensityGray')





Low = IntensityGrayFixedByAveraging;

High = SuperresCode(Low, MagFactor);    %%% magnify the input image 'Low' by the factor of 'MagFactor' along each dimension.
humansubimage = High(y1:y2,x1:x2);


%NNLow = imresize(Low, MagFactor);
%NNLow = edge(NNLow,'canny');
[CannyHuman,threshold] = edge(humansubimage,'canny',[],3);
%CannyHuman = bwareaopen(CannyHuman,100);
% level1 = graythresh(NNLow)*0.6;
level2 = graythresh(humansubimage)*0.4;
% NNLow = imbinarize(NNLow,level1);
binaryImage = imbinarize(humansubimage,level2*1.6);


% subplot(3,3,2)
% imshow(CannyHuman)
% title('canny low res')

[cannyentire,thresholdentire] = edge(High,'canny',[],3);

cannyentire = cannyentire(y1:y2,x1:x2);
cannyentire = imclearborder(cannyentire,4);
cannyentire = bwmorph(cannyentire, 'spur',7);
cannyentire = bwareaopen(cannyentire,30);
cannyentire = imclearborder(cannyentire);

subplot(3,3,2)
imshow(cannyentire)
title('canny entire image')

% Skeleton = bwmorph(CannyHuman,'thicken',10);
% subplot(3,3,6)
% imshow(Skeleton)
% title('Skeleton')

CannyHuman = imclearborder(CannyHuman);
%CannyHuman = bwmorph(CannyHuman,'open');

% subplot(3,3,5)
% imshow(CannyHuman)
% title('canny edge human')

RefinedSkeleton = bwmorph(CannyHuman, 'spur',10);
RefinedSkeleton = bwareaopen(RefinedSkeleton,30);
RefinedSkeleton = imclearborder(RefinedSkeleton);

subplot(3,3,3)
imshow(RefinedSkeleton)
title('canny subimage')

data = zeros(100,2);
[m,n] = size(RefinedSkeleton);
initial = 1;
xvalues = 0;
yvalues = 0;
 for i = 1:m
        for j = 1:n
            if (RefinedSkeleton(i,j) == 1 )
                data(initial,2) = i;
                data(initial,1) = j;
                initial = initial + 1;
                xvalues = xvalues + j;
                yvalues = yvalues + i;
            end
            
        end
 end

 xvalues = int64(xvalues / (initial-1));
 yvalues = int64(yvalues / (initial-1));
 
params.N = 7;

params.MaxIt = 80;

params.tmax = 8000;

params.epsilon_initial = 0.9;
params.epsilon_final = 0.4;

params.lambda_initial = 10;
params.lambda_final = 1;

params.T_initial = 5;
params.T_final = 10;

net = NeuralGasNetwork(data, params, false);

skeletonpoints = int64(net.w);

x = (double(skeletonpoints(:,1))).';
y = (double(skeletonpoints(:,2))).';
x(end+1) = xvalues;
y(end+1) = yvalues;
x(end+1) = xvalues;
y(end+1) = min(y) + (yvalues - min(y))/2;
%x(end+1) = xvalues;
%y(end+1) = max(y) - (max(y) - yvalues)/2;

subplot(3,3,9)
imshow(humansubimage)
title('Human')
hold on;
plot(x, y, 'r+', 'MarkerSize', 5, 'LineWidth', 3); 



