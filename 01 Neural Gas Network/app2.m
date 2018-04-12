%
% Copyright (c) 2015, Yarpiz (www.yarpiz.com)
% All rights reserved. Please read the "license.txt" for license terms.
%
% Project Code: YPML111
% Project Title: Neural Gas Network in MATLAB
% Publisher: Yarpiz (www.yarpiz.com)
% 
% Developer: S. Mostapha Kalami Heris (Member of Yarpiz Team)
% 
% Contact Info: sm.kalami@gmail.com, info@yarpiz.com
%

clc;
clear;
close all;

%% Load Data

data = load('jain');
X = data.X;

%% Create and Train Neural Gas Network

params.N = 6;

params.MaxIt = 40;

params.tmax = 10000;

params.epsilon_initial = 0.5;
params.epsilon_final = 0.01;

params.lambda_initial = 5;
params.lambda_final = 0.5;

params.T_initial = 5;
params.T_final = 10;

net = NeuralGasNetwork(X, params, true);
