function [index] = IndexFinder(Z_t)

%{

The function will find the start and end of the cut based on the table
acceleration data, Z_Table .

%}


averaged_Zt = movmean(abs(Z_t),3);
threshold = max(averaged_Zt)*0.18;
index = [0,0];
% Searching the far left value above threshold
i = 1;
while index(1) == 0
    if averaged_Zt(i) > threshold
        index(1) = i; 
    end
    i = i+1;
end
% Searching the far right value above threshold
j = length(zt);
while index(2) == 0
    if averaged_Zt(j) > threshold
        index(2) = j;
    end
    j = j-1;
end


end