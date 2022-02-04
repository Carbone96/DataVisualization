function feat = ExtractSignalFeatures(x,fs)

%{ 
 Inputs : 
 x = any acceleration measurement
 fs = sampling frequency

 Ouputs : 
 feat = vector containing all features to use for ML
   --------------------------------------------------------------------- 
  Generates the vector of features for 1 type of acceleration measurement       
%}

% Initialize the feature vector:
feat = zeros(1,115);

% Average value of the signal for all 5 measurements:
feat(1:5) = mean(x,1);

% Filtering the high frequencies data
LowPassFilter = lp_filter;  
x_filtered = filter(x,LowPassFilter);

% RMS values of the filtered signal for all 5 measurements
feat(6:10) = rms(x,1);

% Spectral Peak features (12 elem each) : heigh + position 6st peaks.
feat(11:70) = SpectralPeakFeatures(x, fs);

% Autocorrelation for all the 5 acceleration component 
% Height/Position of main peak; Height and position of second peak
feat(71: 90) = AutoCorrelationFeat(x, fs);

% Spectral power feature (5 each) : total power in 5 adjacent
% and pre-defined frequency band
feat(91:115) = SpectralPowerFeature(x , fs);


% Helper functions : 
function feat = SpectralPeakFeatures(x,fs)
        
        N_channels = 5;
        
        feat = zeros(1,N_channels*12); % Number of feature
        N = length(x,1); % Number of sample
        
        minDist_Xunits = 0.3;
        minPKdist = floor(minDist_Xunits/ (fs/N));

        %Cycle through number of channels
        N_final_pks = 6;
        for k=1:N_channels
            
            %Look for Pwelch --> look documentation
            x_PSD = return the PSD, f return the freq vector
            [x_PSD, f] = pwelch( x(:,k), rectwin(N, [], window, fs)); 
            
            %Find the pks and their frequency
            [pks, locs] = findpeaks(x_PSD, 'npeaks', 20, 'minpeakdistance',minPKdist);
            
            opks = zeros(N_final_pks, 1);
            if (~isempty(pks))
                mx = min(6,length(pks));
                
                %Sorted in 'descend' order
                [sorted_pks, idx] = sort(pks,'descend');
                sorted_locs = locs(idx);
                %Select the 'mx' highest pks
                pks_selected = sorted_pks(1:mx);
                locs_selected = sorted_locs(1:mx);
                %Sort back the selected peaks by 'ascending' frequency
                [olocks, idx] = sort(locs_selected, 'ascend');
                opks = pks_selected(idx); 
            end
            ofpk = f(olocks); 
            
            % Write the features in vector feat :
                % Write the 6 frequencies
            feat(12*(k-1)+ (1:length(opks)) = ofpk;
                % Write the 6 peaks amplitude
            feat(12*(k-1)+ (7:7+length(opks)) = opks;
        end
end

