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
imresize
subplot(2,2,1)
imshow(IntensityGray)
IntensityBW = imbinarize(IntensityGray,'adaptive');
subplot(2,2,2)
imshow(IntensityBW)

%Edge = edge(IntensityGray,'sobel');
%BW1 = edge(IntensityGray,'sobel');
[BW1,threshOut] = edge(IntensityBW,'Sobel');
BW2 = edge(IntensityBW,'canny');

subplot(2,2,3)
imshow(BW1)
subplot(2,2,4)
imshow(BW2)

%{
r = 100;
c = 100;
contour = bwtraceboundary(IntensityGray,[r c],'W',8,Inf,'counterclockwise');
hold on;
plot(contour(:,2),contour(:,1),'g','LineWidth',2);
%}

%[video, audio] = mmread('Dave_Todd_13200mm_11200mm_0deg_y_9fov_ND05_5_2016-04-05-10-10-10_RI.seq',[],[],)
%video = mmread('Dave_Todd_13200mm_11200mm_0deg_y_9fov_ND05_5_2016-04-05-10-10-10_RI.seq',[],[],[],[],[],[],true);
%movie(video.frames);

peopleDetector = vision.PeopleDetector('UprightPeople_96x48');
[bboxes,scores] = step(peopleDetector,IntensityGray);

IntensityGray = insertObjectAnnotation(IntensityGray,'rectangle',bboxes,scores);
figure, imshow(IntensityGray)
title('Detected people and detection scores');