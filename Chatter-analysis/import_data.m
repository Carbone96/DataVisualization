
% The purpose of this code is to read the different files of vibrat° data
% Then it returns a file txt showing the RPM, depth of cut and if the
% experiment produced chatter.

% ---------------------------------------------------------------------


% 1) Fetch the files :


% This should contain a list of all files beginning with "datapath"
function [data_name,n_files] = import_data(datapath)
    files = dir(strcat(datapath,'\','*mat'));
    n_files = size(files,1); 
    data_name = cell(1,n_files);

    for file_number = 1:n_files
        data_name{1,file_number} = files(file_number).name;
    end
end
