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

data = load('spiral');
X = data.X;

%% Create and Train Neural Gas Network

params.N = 100;

params.MaxIt = 80;

params.tmax = 8000;

params.epsilon_initial = 0.9;
params.epsilon_final = 0.4;

params.lambda_initial = 10;
params.lambda_final = 1;

params.T_initial = 5;
params.T_final = 10;

net = NeuralGasNetwork(X, params, true);
