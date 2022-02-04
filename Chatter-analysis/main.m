%% Import the data of a function and preprocess it then save it in .dat

%%% =============== SELECT RPM =========================== %%%%

% Experiment (file number)   1     2    3    4   5     6   7     8    9   10
% RPM                       3000 3500  3750 4000 4250 4500 4750 5000 5250 5500
% 
% Experiment (file number)  11   12   13   14   15   16   17   18  19   20
% RPM                      5750 6000 6250 6500 7000 7500 8000 8500 9000 3000
%%%% ============================================================== %%%%


%%%% =============== SELECT DEPTH OF CUT =========================== %%%%

% Folder (folder number)  1      2    3    4   5     6   7     
% Depth of cut            1     1.5   2    3   4     5   6 [mm]
% 
%%%% ============================================================== %%%%

close all;
clc;

file_num = 12;
folder_num = 4;

datapath1 = 'D:\Vibrations-data-15_12\211104\ap1-0';
datapath2 = 'D:\Vibrations-data-15_12\211104\ap1-5';
datapath3 = 'D:\Vibrations-data-15_12\211104\ap2-0';
datapath4 = 'D:\Vibrations-data-15_12\211104\ap3-0';
datapath5 = 'D:\Vibrations-data-15_12\211104\ap4-0';
datapath6 = 'D:\Vibrations-data-15_12\211104\ap5-0';
datapath7 = 'D:\Vibrations-data-15_12\211104\ap9-0';
datapath_list = [datapath1;datapath2;datapath3;datapath4;datapath5;datapath6;datapath7];


%% 1) Import data
[accel,file] = vib_data_loader(file_num, folder_num,datapath_list);

%% 2) Create the class 
tic
AccelData = DataPreparation(file.N,accel,file.fs,file_num,folder_num);
AccelData = AccelData.ExtractCuttingData(); % computes indices
AccelData = AccelData.CuttingData(); % cut the data in 3 part (left,cut,right)
t = toc;
disp(['The data was ordered in ', num2str(t) , ' seconds']);


% 2.A) Pre-process data



%% 3) Make plots to verify data selection
tic
VerifOfDataSelection(AccelData)
t = toc;
disp(['The plot was done in ', num2str(t) , ' seconds']);

%% 4) Plots to visualize the experimental data as-is (no modification)
tic 
CheckAccelData_nochange(AccelData)
t=toc;
disp(['The spectrum (no change) was done in ', num2str(t) , ' seconds']);

%% 5) Analysis of the spectrogram to remove the motor comp. and choose a filter.
tic 
SpectrogramShowingMotorInfluence(AccelData.x, AccelData.fs, 'X')
t=toc;
disp(['The spectrograms showing motor influce were done in ', num2str(t) , ' seconds']);
%% 6) Create the component with filter and seperate free spindle/cutting parts
tic
SpectrumOfData(AccelData,AccelData.x);
SpectrumOfData(AccelData,AccelData.y);
SpectrumOfData(AccelData,AccelData.z);
SpectrumOfData(AccelData,AccelData.ae);
t=toc;
disp(['The spectrum separation was done in ', num2str(t) , ' seconds']);


%% 9) Cyclic spectral analysis.



%% 10) PSD (Power spectral density) analysis

