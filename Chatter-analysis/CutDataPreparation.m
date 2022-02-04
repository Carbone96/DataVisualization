classdef CutDataPreparation < DataPreparation
      
    properties

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
        % Constructor of the cutData
        function [obj] = CutDataPreparation(file_N,accelMatrix,fs)

            obj = DataPreparation(file_N,accelMatrix,fs);
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