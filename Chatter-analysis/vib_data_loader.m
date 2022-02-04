function [accel,file] = vib_data_loader(file_num,folder_num,datapath_list)

    % Function that allows to load the data from a directory
    
    % Inputs : 
    %   file_num    = number of the experiment to open
    %   folder_num   = number of the folder (related to depth of cut)
    %   datapath_list = all directory
    
    datapath = datapath_list(folder_num,:);
    [file_names, ~] = import_data(datapath); % Get all files name
    try
        disp('> started loading data ... please hold');
        file = load(strcat(datapath,'\',file_names{file_num}));
        disp('> done.');
        catch err
        warning('Wrong file name/path');
        rethrow(err);
    end
    
    idx = 1:file.N;
    chAccel = [1 2 3 4 5];
    accel = file.data(idx,chAccel);
end