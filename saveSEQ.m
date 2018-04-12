%% load seq files 
clear;
addpath(genpath('C:\Users\Mike Wang\Downloads\piotr_toolbox\toolbox')); savepath;
clc; close all; 
path = 'C:\Users\Mike Wang\Desktop\TigerCub';
files = dir(path); 

for i =3:size(files, 1) 
    
    videoName = files(i).name; 
    videoPath = [path, videoName, '\'];
    
    files2 = dir([videoPath, '*.seq']);  
    for j = 1:size(files2, 1) 
        videoname = files2(j).name;
        seqfile = [videoPath, videoname];
        
        videoname2 = strtok(videoname, '.'); 
        
        imgSavePath = [videoPath, videoname2 ,'\'];
        if ~exist(imgSavePath) 
            mkdir(imgSavePath); 
        end 
        
        Is = seqIo( seqfile, 'toImgs', imgSavePath); 
        
    end 
    
end