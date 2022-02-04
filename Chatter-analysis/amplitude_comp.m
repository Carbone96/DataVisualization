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

file_num = 11;
folder_num = 4;

RPM = [3000 3500 3500 3750 4000 4250 4500 4750 5000 5250 5500 5750 6000 6250 6500 7000 7500 8000 8500 9000 3000];
Ap = [1 15 2 3 4 5 6];


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
global time 
time = (0:1/file.fs:(N-1)/file.fs)';   % time vector;
Nf = ceil((N+1)/2);                 % Half the total number of points
fvec = ((0:Nf-1)*(file.fs/Nf))';    % Frequency vector (half the points ? Nyquist)

global fs
fs = file.fs

% ---------- SHOW THE DESCRIPTION OF ACCELERATION DATA -------- %
%                   chDescr = file.chDescr ; 
% ------------------------------------------------------------- %
    
zt = accel(:,1);      % Table z-acceleration
z = accel(:,2);       % Spindle z-acceleration
x = accel(:,3);       % Spindle x-acceleration
y = accel(:,4);       % Spindle y-acceleration
    

%% 2) Plot 
    
% I use Z_Table because as long as there in cutting, the voltage is 0.
% Therefore it is the most accurate to detect starting and ending of a cut.

averaged_Zt = movmean(abs(zt),3);
threshold = max(averaged_Zt)*0.18;
index = [0,0];
% Searching the far left value above threshold
i = 1;
while index(1) == 0
    if averaged_Zt(i) > threshold
        index(1) = i; 
    end
    i = i+1;
end
% Searching the far right value above threshold
j = length(zt);
while index(2) == 0
    if averaged_Zt(j) > threshold
        index(2) = j;
    end
    j = j-1;
end
    
start_point = index(1);
end_point = index(2);
    
x_exp = x(start_point : end_point);  
y_exp = y(start_point : end_point);  
z_exp = z(start_point : end_point);  
zt_exp = zt(start_point : end_point); 
ae_exp = ae(start_point : end_point);

N_acc = length(x_exp); % Would be the same with any vector


%% Plot the acceleration data/selected acceleration data

%{
do_OnePlotFlag = 1;

[z_spectro,freqVec,timeVec] = all_spectrograms(z,2,'Z-accel',do_OnePlotFlag);
averaged_motor = mean(db([z_spectro(:,1:50),z_spectro(:,250:end)]),2);
spectro_exp = db(z_spectro) - averaged_motor;
%mesh(timeVec,zz)
figure
mesh(timeVec,freqVec/1000,db(z_spectro))
xlabel('Time [s]')
ylabel('Frequency [kHz]')
colorbar
set(gca,'xtick', [0,2,4,6,8,10,12,14,16])
set(gca,'ytick', [0,5,10,15,20,25])
set(gca,'XLim',[0 16])
set(gca,'YLim',[0 25])
title(['Spectro_{Wmotor}', 'RPM-', num2str(RPM(file_num)) , '-Ap', num2str(Ap(folder_num))])
savefig(['Spectro_WMotor_', num2str(RPM(file_num)),'RPM_',num2str(Ap(folder_num))])

figure
mesh(timeVec,freqVec/1000,spectro_exp)
xlabel('Time [s]')
ylabel('Frequency [kHz]')
colorbar
set(gca,'XLim',[0 16])
set(gca,'YLim',[0 25])
set(gca,'xtick', [0,2,4,6,8,10,12,14,16])
set(gca,'ytick', [0,5,10,15,20,25])
title(['Spectro_{WoMotor}', 'RPM-', num2str(RPM(file_num)) ,'-Ap', num2str(Ap(folder_num)),'mm'])
savefig(['Spectro_WoMotor_', num2str(RPM(file_num)),'RPM_',num2str(Ap(folder_num)),'mm'])

%}
%% Figure that represents if the data as been cut correctly.
checkDataSelected = 0;
if checkDataSelected == 1 
    figure
    % X-accel selected data
    verif_plot(x,x_exp,index,3,'X-accel')
    % Y-accel selected data
    verif_plot(y,y_exp,index,4,'Y-accel')
    % Z-accel (spindle) selected data
    verif_plot(z,z_exp,index,2,'Z-accel')  
    % Z-accel (table) selected data
    verif_plot(zt,zt_exp,index,1,'Ztable-accel')
    % Acoustic selected data
    verif_plot(ae,ae_exp,index,5,'Acoustic')
end

%% Try to filter then remove the motor contribution from the Spectrum

[Xw_motor, Xw_cleaned] = SpectrumOfData(z,fs,index,fvec);




%% Check the Spectrogram to Z and Zt to find the proper spectrogram

do_OnePlotFlag = 1;
% Spectrogram X-accel
    %all_spectrograms(x,3,'X-accel',do_OnePlotFlag)
% Spectrogram Y-accel
    %all_spectrograms(y,4,'Y-accel',do_OnePlotFlag)
% Spectrogram Z-accel
    %all_spectrograms(z,2,'Z-accel',do_OnePlotFlag)
% Spectrogram Z_t-accel
    %all_spectrograms(zt,1,'Ztable-accel',do_OnePlotFlag)
% Spectrogram A_e-accel
    %all_spectrograms(ae,5,'Acoustic',do_OnePlotFlag)

 
fvec_exp = (0:N_acc-1)*(file.fs/N_acc)';
tvec = time(start_point:end_point);

%% -----------------------

%% Create the Spectrogram for the different acceleration.

if DoSpectrum == 1

    tic
    spectrum_analysis(fvec_exp,file.fs,x_exp,'X-accel',tvec)
    spectrum_analysis(fvec_exp,file.fs,y_exp,'Y-accel',tvec)
    spectrum_analysis(fvec_exp,file.fs,z_exp,'Z-accel',tvec)
    spectrum_analysis(fvec_exp,file.fs,zt_exp,'Zt-accel',tvec)
    spectrum_analysis(fvec_exp,file.fs,ae_exp,'Ae-accel',tvec)
    toc 
    t=toc

end


function [s,f,t] = all_spectrograms(accel_data,subplot_num, dataname, do_OnePlotFlag)
    
    % Make the spectrogram with raw data data
    % -> goal = highlight the frequency due to the motors.
    global time;
    global fs;
    if do_OnePlotFlag == true  
        % EXPLAINATION : 
        % This is to see only 1 spectrogram. The goal is to visualize the
        % Ztable acceleration data and see what are the frequencies that
        % can be cut out. Ideally, above 10kHz should be truncated from the
        % analysis.
    
        figure
        [s,f,t] = spectrogram(accel_data, 3000, 200,[],fs,'yaxis');
        title(dataname);
        ylabel('Acceleration [V]');
        xlabel('Time [s]');
        
    else 
        subplot(1,1,subplot_num)
        hold on
        spectrogram(accel_data, 3000, 800,[],fs,'yaxis')
        hold off
        title(dataname)
        ylabel('Acceleration [V]')
        xlabel('Time [s]')
    end
    
end  

function [] = verif_plot(accel_data,selected_accel_data,index,subplot_num,dataname)
    
    global time;
    global fs;
    
    startP = index(1);
    endP = index(2);
    
    N_data = length(accel_data);
    data4plot = [zeros(startP,1) ; selected_accel_data; zeros(N_data - endP-1,1)];
    
    subplot(5,1,subplot_num)
    hold on
    plot(time,accel_data,'DisplayName',dataname)
    plot(time,data4plot,'DisplayName','Data for fft')
    hold off
    lgd = legend;
    lgd.FontSize = 12;
    title([dataname, ' ,selected data'])
    ylabel('Acceleration [V]')
    xlabel('Time [s]')
    
end


function [] = spectrum_analysis(fvec,fs,accel_data,dataname,tvec)
       
    %disp(['The spectrum analysis for ', dataname, ' shows']);
   
    filter = hanning(length(accel_data));
    
    %% In case you must plot the 'Before' and 'After' Hanning window
    
    %{
    figure
    plot(tvec,accel_data)
    ylabel('Acceleration [V]')
    xlabel('Time [s]')
    title('Selected Data')
    figure
    plot(tvec,filter.*accel_data)
    ylabel('Acceleration [V]')
    xlabel('Time [s]')
    title('Data with Hanning window')
    %}
    
    %% -------------------------------------------------------------
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
    %disp([' Highest peak from sprectrum at ', num2str(fvec(index_val)), 'Hz'])
    %disp([' Highest peak for sprectrum ', num2str(max_val), 'V'])
    
    % Plot Spectrogramme :
    window = 3000;
    overlap = 200;
    subplot(3,1,2)
    spectrogram(filtered_data,window,overlap,[],fs,'yaxis')
    title(['Spectrogram ', dataname]) 
    
    % Power spectral density :
    subplot(3,1,3)
    PSD = (Spectrum.*conj(Spectrum));
    plot(fvec(1:50000),db(PSD(1:50000)));
    title(['PSD ', dataname])
    ylabel('Amplitude')
    xlabel('Frequency [Hz]')
  
    [max_val, index_val] = max(PSD);
    %disp([' Highest energy peak from PSD at ', num2str(fvec(index_val)), 'Hz'])
    %disp([' Highest peak for sprectrum ', num2str(max_val), 'V'])
end


function [] = Spectro_no_motor(accel,dataname)
    do_OnePlotFlag = 1;
    [z_spectro,freqVec,timeVec] = all_spectrograms(accel,2,dataname,do_OnePlotFlag);
    averaged_motor = mean(db([accel(:,1:50),z_spectro(:,250:end)]),2);
    spectro_exp = db(z_spectro) - averaged_motor;
    mesh(timeVec,zz)
    colorbar
end

function [Motor_accel, Accel_cleaned] = SpectrumOfData(accel,fs,index,fvec)
    

    figure
    Accel = fft(accel);
    plot(fvec(1:10000),db(Accel(1:10000)));
    title('Accel no change')
    
    %% Apply a lowpass filter and remove the motor contribution.
    StartP = index(1);
    EndP = index(2);
    
    accel_filter = lowpass(accel,12000,fs);
    motor_accel = [accel(1:StartP); accel(EndP:end)];
    accel_no_motor = accel_filter(StartP:EndP);
    
    % Create no motor accel
    filter = hanning(length(accel_no_motor));
    accel_filter = filter.*accel_no_motor;
    
    % Create motor accel
    filter = hanning(length(motor_accel));
    motor_accel = filter.*motor_accel;
    
    % FFT of motor
    Motor_accel = fft(motor_accel);
    Motor_accel = Motor_accel(1: floor(length(Motor_accel)/2)+1);
    Motor_accel = 2*Motor_accel/length(Motor_accel);
    
    % FFt of Accel no motor
    Accel = fft(accel_filter);
    Accel = Accel(1: floor(length(Accel)/2)+1);
    Accel = 2*Accel/length(Accel);
    
    % This step removes all high freq but normally they are not considered
    % because of the lowpass filter.
    Accel_cropped = Accel(1:length(Motor_accel));
    Accel_cleaned = db(Accel_cropped) - movmean(db(Motor_accel),5);  
    
    maxF = 4000;
    
    figure
    subplot(3,1,1)
    N_acc = length(Accel_cropped);
    fvec = (0:N_acc) * (fs/N_acc);
    plot(fvec(1:maxF),db(Accel_cropped(1:maxF)))
    title('Accel cropped')
    
    subplot(3,1,2)
    N_acc = length(Motor_accel);
    fvec = (0:N_acc) * (fs/N_acc);
    plot(fvec(1:maxF), db(Motor_accel(1:maxF)))
    title('Motor accel')
    
    subplot(3,1,3)
    N_acc = length(Accel_cleaned);
    fvec = (0:N_acc) * (fs/N_acc);
    plot(fvec(1:maxF), movmean(Accel_cleaned(1:maxF),3))
    title('Accel no motor')
    
    savefig('Z_accel_trial-no_chatt')
    
    
    %% Idea : 
    %{
     It could be interesting to compute the inverse Fourrier transform of
     the value Accel_cleaned. Then to do the spectrogram of it, to see if
     it corresponds to what was obtained when substracting the mean value
     of the spectrogram of the motor acceleration.
    %}
end
