function [] = VerifOfDataSelection(AccelData)
    % Compares on the same plot the time-series data that corresponds to
    % the cutting and the time-series of the motors
    
    figure
    sgtitle('Distinction Cutting / Free spindle')
    subplot4Verif(AccelData.tvec,AccelData.x, 'X-accel' , AccelData.index , 1)
    subplot4Verif(AccelData.tvec,AccelData.y, 'Y-accel' , AccelData.index , 2)
    subplot4Verif(AccelData.tvec,AccelData.z, 'Z-accel' , AccelData.index , 3)
    subplot4Verif(AccelData.tvec,AccelData.zt, 'Zt-accel', AccelData.index, 4)
    subplot4Verif(AccelData.tvec,AccelData.ae, 'Acoustic', AccelData.index, 5)
end

    function [] = subplot4Verif(time, accelVec,dataname,indices,subplot_num)
        
        % Create the 5 subplots for the five acceleration measurement.
        
        [data4plot,time4plot] = CutData4Plot(accelVec,time,indices);
        subplot(5,1,subplot_num)
        hold on
        plot(time,accelVec,'DisplayName', 'Free spindle')
        plot(time4plot,data4plot,'DisplayName','Cutting')
        hold off
        lgd = legend;
        lgd.FontSize = 12;
        title([dataname])
        ylabel('Acceleration [V]')
        xlabel('Time [s]')
    end
    
    
    function [data4plot,time4plot] = CutData4Plot(accelVec,tvec,indices)

        startP = indices(1);
        endP = indices(2);
        % Takes the data only of the cut using the indices.
        data4plot = accelVec(startP:endP);
        time4plot = tvec(startP:endP);

    end