%% Prepare the data by creating a class with all necessary informations


classdef DataPreparation
    
    % Repertoire des experiences réalisées :
    % RPM = RPM dans l'ordre des expériences
    % Ap  = Depth of cut [mm] par ordre des expériences
    properties 
        RPM = [3000 3500 3500 3750 4000 4250 4500 4750 5000 5250 5500 5750 6000 6250 6500 7000 7500 8000 8500 9000 3000];
        Ap = [1 15 2 3 4 5 6];
    end
    
    
    properties
        N   % number of acceleration points
        fs  % Sampling rate
        fvec % frequency vector
        tvec % timevector
        index % Starting and Ending index for the cutting part
        % Time series amplitude
        x
        y
        z
        zt
        ae
        % Spectrum
        X
        Y
        Z
        ZT
        AE
        % Time series of the cut data
        xCut
        yCut
        zCut
        ztCut
        aeCut
        % Time series of the left part of spindle rotating
        xSleft
        ySleft
        zSleft
        ztSleft
        aeSleft
        % Time series of the right part of the spindle rotating
        xSright
        ySright
        zSright
        ztSright
        aeSright
    end
      
    methods 

        % Class constructor
        function [obj] = DataPreparation(file_N,accelMatrix,fs,file_num,folder_num)
            if nargin > 0
                obj.fs = fs;
                obj.N = file_N;
                obj = obj.AccelVecSeparation(accelMatrix);
                obj = obj.TimeVector(); % Any acceleration would work here
                obj = obj.FreqVector(file_N);
                obj.RPM = obj.RPM(file_num);
                obj.Ap = obj.Ap(folder_num);
                
            end
        end

        % Return the frequency vector for the experiment
        function [obj] = FreqVector(obj,Npoints)
            % Npoints = length of the dataset
            if nargin < 0
                Nf = ceil((Npoints+1)/2);
                obj.fvec = ((0:Nf-1)*(obj.fs/Nf))'; 
            else
                Nf = ceil((obj.N+1)/2);
                obj.fvec = ((0:Nf-1)*(obj.fs/Nf))'; 
            end    
        end

        % Return the time vector for a given experiment
        function [obj] = TimeVector(obj)
            % accelVec = acceleration vector
            % fs = sampling rate
            obj.N = length(obj.x);
            obj.tvec = (0:1/obj.fs:(obj.N -1)/obj.fs)';
        end

        % Return the time vector for any acceleration data that WAS CUT !
        function [obj] = TimeVector4CutData(obj,accelVec_cut,accelVec,fs,index_Cut)

            % Inputs : 
            % tvec_accelCut  = time vector of accelVec_cut
            % index_Cut   =  [start_Cut_index, end_Cut,index]
            % accelVec_cut = accel data cut following index_Cut
            % accelVec = original accel data
            % fs = sampling frequency
            % ----------------------------------------------------------
            obj.N = length(obj.x);
            tvecAllData = TimeVector(accelVec,obj.fs);
            t_shift = tvecAllData(index_Cut(1));
            obj.tvec =  TimeVector(accelVec_cut,fs) + t_shift;   
        end
        
        % Return the 5 acceleration data separated
        function [obj] = AccelVecSeparation(obj,accel)

            % Store time series data
           
            
            obj.x = accel(:,4);
            obj.y = accel(:,5);
            obj.z = accel(:,3);
            obj.zt = accel(:,2);
            obj.ae = accel(:,1);

            % Store spectrum data
            obj.X = SpectrumMaker(obj.x);
            obj.Y = SpectrumMaker(obj.y);
            obj.Z = SpectrumMaker(obj.z);
            obj.ZT = SpectrumMaker(obj.zt);
            obj.AE = SpectrumMaker(obj.ae);
        end

        % Cut the data based on the Ztable data 
        function [obj] = ExtractCuttingData(obj)
            averaged_zt = movmean(abs(obj.zt),3);
            threshold = max(averaged_zt)*0.18 ; % Create a zt min value.
            indexVal = [0,0];
            % Searching the far left value above threshold
            i = 1;
            while indexVal(1) == 0
                if averaged_zt(i) > threshold
                    indexVal(1) = i; 
                end
                i = i+1;
            end
            % Searching the far right value above threshold
            j = length(obj.zt);
            while indexVal(2) == 0
                if averaged_zt(j) > threshold
                    indexVal(2) = j;
                end
                j = j-1;
            end
            obj.index = indexVal;
        end


        % Cut the acceleration data based on index values + create spectrum
        function [obj] = CuttingData(obj)
           StartP = obj.index(1); EndP = obj.index(2);
            % Select only the part with the tool cutting
            obj.xCut = obj.x(StartP:EndP);
            obj.yCut = obj.y(StartP:EndP);
            obj.zCut = obj.z(StartP:EndP);
            obj.ztCut = obj.zt(StartP:EndP);
            obj.aeCut = obj.ae(StartP:EndP);
            % Select the left part with spindle rotating
            obj.xSleft = obj.x(1:StartP);
            obj.ySleft = obj.y(1:StartP);
            obj.zSleft = obj.z(1:StartP);
            obj.ztSleft = obj.zt(1:StartP);
            obj.aeSleft = obj.ae(1:StartP);
            % Select the left part with spindle rotating
            obj.xSright = obj.x(EndP:end);
            obj.ySright = obj.y(EndP:end);
            obj.zSright = obj.z(EndP:end);
            obj.ztSright = obj.zt(EndP:end);
            obj.aeSright = obj.ae(EndP:end);
        end
        


        
end  
end

