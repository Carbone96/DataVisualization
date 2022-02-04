% Create the spectrum of an acceleration vector
        function [Spectrum] = SpectrumMaker(accelVec)
            Spectrum = fft(accelVec);
            % Because fft is symmetrical -> take 1/2 of length
            Spectrum = Spectrum(1: floor(length(Spectrum)/2)+1);
            % Correction for amplitude (NEEDS TO BE CHECKED)
            Spectrum = 2*Spectrum/length(Spectrum);
        end