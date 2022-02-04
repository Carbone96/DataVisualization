function [] = SpectrumOfData(AccelData,AccelVector)

    %% Apply a LowPass filter and remove the motor contribution.
    StartP = AccelData.index(1); %Start of cut
    EndP = AccelData.index(2); % End of cut
    fs = AccelData.fs; % Sampling frequency
    cuttingFreq = 12000; % [Hz]


    LowPass_filter = lowpass(AccelVector, cuttingFreq, fs);
    FilteredAccel = LowPass_filter.* AccelVector ;

    %% Remove the motor contribution

    motorAccelLeft = FilteredAccel(1:StartP);
    motorAccelRight = FilteredAccel(EndP:end);
    CutAccel = FilteredAccel(StartP:EndP);

    %% Create Hanning window for all acceleration

    motorAccelLeft = motorAccelLeft .* CreateHanningWindow(motorAccelLeft);
    motorAccelRight = motorAccelRight .* CreateHanningWindow(motorAccelRight);
    CutAccel = CutAccel .* CreateHanningWindow(CutAccel);

    %% FFT of motor
    Motor_accel = [motorAccelLeft;motorAccelRight];
    Motor_spectrum = SpectrumMaker(Motor_accel);
    Motor_spectrum_DB = db(Motor_spectrum);
    %% FFT of Accel of cutting
    CutSpectrum = SpectrumMaker(CutAccel);
    CutSpectrum_DB = db(CutSpectrum);
    %% Removing the trend of the motors' spectrum from the cutting spectrum
    CutSpectrum_DB = CutSpectrum_DB(1:length(Motor_spectrum_DB));
    De_Trend_CutSpectrum = CutSpectrum_DB - movmean(Motor_spectrum_DB,5);
    
    %% Show plot of the results
    
    maxF = 4000;

    figure
    subplot(3,1,1)
    N_acc = length(CutSpectrum_DB); % Spectrum with motor contribution
    fvec = (0:N_acc) * (fs/N_acc);
    plot(fvec(1:maxF),CutSpectrum_DB(1:maxF))
    title('Spectrum w. motor contribution')

    subplot(3,1,2)
    N_acc = length(Motor_spectrum_DB); % Spectrum motor
    fvec = (0:N_acc) * (fs/N_acc);
    plot(fvec(1:maxF),Motor_spectrum_DB(1:maxF))
    title('Motors spectrum')

    subplot(3,1,3)
    N_acc = length(De_Trend_CutSpectrum); % Spectrum without motor contribution
    fvec = (0:N_acc) * (fs/N_acc);
    plot(fvec(1:maxF),De_Trend_CutSpectrum(1:maxF))
    title('Spectrum w/o. motor contribution')


end

function [windowing] = CreateHanningWindow(AccelVector)
    
    N = length(AccelVector);
    windowing = hanning(N, "symmetric");

end


