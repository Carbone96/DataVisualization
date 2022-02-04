function [] = CheckAccelData_nochange(AccelData)

    % Shows the fft of the different fft in a 5figures subplot.
    % Additionnaly, shows the fundamental for each plot + 4th harmonic
    FundamentalFreq = AccelData.RPM / 60;
    
    figure
    sgtitle('Spectrum of acceleration data (no changes)')
    subplot4Check(AccelData.fvec,AccelData.X, 'X-accel' , 1, FundamentalFreq)
    subplot4Check(AccelData.fvec,AccelData.X, 'Y-accel' , 2, FundamentalFreq)
    subplot4Check(AccelData.fvec,AccelData.Z, 'Z-accel' , 3, FundamentalFreq)
    subplot4Check(AccelData.fvec,AccelData.ZT, 'Zt-accel', 4, FundamentalFreq)
    subplot4Check(AccelData.fvec,AccelData.AE, 'Acoustic', 5, FundamentalFreq)

end

function [] = subplot4Check(fvec, spectrumVec,dataname, subplot_num, FundamentalFreq)
        
        % Get the spectrum in Decibels
        spectrumVecDB = db(spectrumVec);
        % Prepare the subplot
        subplot(5,1,subplot_num)
        hold on
        plot(fvec(1:11200),smooth(spectrumVecDB(1:11200)),'DisplayName',dataname) % Plot spectrum
        % Plot the fundamental and the 4th harmonics
        
        

        minPeakHeight = max(smooth(spectrumVecDB))*1.8;
        [pks, locs] = findpeaks(smooth(spectrumVecDB),'MinPeakDistance',1500, 'MinPeakHeight', minPeakHeight );
        plot(fvec(locs(1:5)),pks(1:5),'o','MarkerSize',3) % Fundamental
       
        hold off
        lgd = legend;
        lgd.FontSize = 10;
        title(dataname)
        ylabel('Acceleration [dB]')
        xlabel('Frequency [Hz]')
end

