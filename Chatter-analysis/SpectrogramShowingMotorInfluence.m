function [] = SpectrogramShowingMotorInfluence(AccelVector, fs, dataname)
    
    window = 3000; % Size of a window
    overlap = 200; % Number of point overlapping
    [ValSpectrogram,fVec,tVec] = spectrogram(AccelVector, window, overlap,[],fs,'yaxis');
  
    SpectrogramAverageValue_MotorOnly =  mean(db([ValSpectrogram(:,1:50),ValSpectrogram(:,250:end)]),2);
    spectro_exp = db(ValSpectrogram) - SpectrogramAverageValue_MotorOnly;
    
    figure
    mesh(tVec,fVec/1000,db(ValSpectrogram))
    xlabel('Time [s]')
    ylabel('Frequency [kHz]')
    colorbar
    set(gca,'XLim',[0 16])
    set(gca,'YLim',[0 25])
    set(gca,'xtick', [0,2,4,6,8,10,12,14,16])
    set(gca,'ytick', [0,5,10,15,20,25])
    %title(['Spectro_{WoMotor}', 'RPM-', num2str(RPM(file_num)) ,'-Ap', num2str(Ap(folder_num)),'mm'])
    title(['Spectrogram of ', dataname, ' acceleration'])
    colorbar

    figure
    mesh(tVec,fVec/1000,spectro_exp)
    xlabel('Time [s]')
    ylabel('Frequency [kHz]')
    colorbar
    set(gca,'XLim',[0 16])
    set(gca,'YLim',[0 25])
    set(gca,'xtick', [0,2,4,6,8,10,12,14,16])
    set(gca,'ytick', [0,5,10,15,20,25])
    %title(['Spectro_{WoMotor}', 'RPM-', num2str(RPM(file_num)) ,'-Ap', num2str(Ap(folder_num)),'mm'])
    title(['Spectro_{WoMotor} of ', dataname, ' acceleration'])
    colorbar

end