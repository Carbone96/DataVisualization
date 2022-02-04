%% Amplitude comparison for the different output spectrum


%%%% =============== SELECT RPM =========================== %%%%

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

file_num = 4;

folder_num = 5;


datapath1 = 'D:\Vibrations-data-15_12\211104\ap1-0';
datapath2 = 'D:\Vibrations-data-15_12\211104\ap1-5';
datapath3 = 'D:\Vibrations-data-15_12\211104\ap2-0';
datapath4 = 'D:\Vibrations-data-15_12\211104\ap3-0';
datapath5 = 'D:\Vibrations-data-15_12\211104\ap4-0';
datapath6 = 'D:\Vibrations-data-15_12\211104\ap5-0';
datapath7 = 'D:\Vibrations-data-15_12\211104\ap9-0';
datapath_list = [datapath1;datapath2;datapath3;datapath4;datapath5;datapath6;datapath7];

%% 1) Import data


[accel,ae,file] = vib_data_loader(file_num, folder_num,datapath_list);
   
N = file.N;
idx = 1:N;                     % N  number of points in the measurements
time = 0:1/file.fs:(N-1)/file.fs;   % time vector
Nf = ceil((N+1)/2);                 % Half the total number of points
fvec = ((0:Nf-1)*(file.fs/Nf))';    % Frequency vector (half the points ? Nyquist)

% ---------- SHOW THE DESCRIPTION OF ACCELERATION DATA -------- %
%                   chDescr = file.chDescr ; 
% ------------------------------------------------------------- %
    
zt = accel(:,1);      % Table z-acceleration
z = accel(:,2);       % Spindle z-acceleration
x = accel(:,3);       % Spindle x-acceleration
y = accel(:,4);       % Spindle y-acceleration

index = IndexFinder(zt);

start_point = index(1);
end_point = index(2);
    
x_exp = x(start_point : end_point);  
y_exp = y(start_point : end_point);  
z_exp = z(start_point : end_point);  
zt_exp = zt(start_point : end_point); 
ae_exp = ae(start_point : end_point);

N_acc = length(x_exp); % Would be the same with any vector



function [Spectrum, max_val,max_freq,PSD] = spectrum_analysis(fvec,fs,accel_data,dataname)

    disp(['The spectrum analysis for ', dataname, ' shows']);
    % fs = sampling frequency
    filter = hanning(length(accel_data));
    %filter = ones(length(accel_data),1);
    filtered_data = filter.*accel_data;
    cut_data = lowpass(filtered_data,25000,fs);
    
    Spectrum = fft(cut_data);
    Spectrum = Spectrum(1: floor(length(Spectrum)/2)+1);
    Spectrum = 2*Spectrum/length(Spectrum);
    
    % Plot spectrum :
    figure
    subplot(3,1,1)
    plot(fvec(1:50000),db(Spectrum(1:50000)));
    title(['Spectrum ', dataname])
    ylabel('Amplitude')
    xlabel('Frequency [Hz]')
    
    [max_val, index_val] = max(Spectrum);
    max_freq= fvec(index_val);
    disp([' Highest peak from sprectrum at ', num2str(max_freq), 'Hz'])
    disp([' Highest peak for sprectrum ', num2str(max_val), 'V'])
    
    %{
    % Plot Spectrogramme :
    window = 3000;
    overlap = 200;
    subplot(3,1,2)
    spectrogram(filtered_data,window,overlap,[],fs,'yaxis')
    title(['Spectrogram ', dataname]) 
    %} 
    % Power spectral density :
    subplot(3,1,3)
    PSD = (Spectrum.*conj(Spectrum));
    plot(fvec(1:50000),db(PSD(1:50000)));
    title(['PSD ', dataname])
    ylabel('Amplitude')
    xlabel('Frequency [Hz]')
    
    [max_val, index_val] = max(PSD);
    disp([' Highest energy peak from PSD at ', num2str(fvec(index_val)), 'Hz'])
    disp([' Highest peak for sprectrum ', num2str(max_val), 'V'])
    
    
end


