function [ ind_data ] = find_Data(Data,Fields,Values)
%FINDDATA search in a data structure the rows for which all Values in the given Fields are matching 
 
%initialize with all the indexes and then filter them in the loop
ind_data=1:size(Data,1);
for i=1:length(Fields)
    %define if Values is a string or integer 
    if (ischar(Values{i})==1)
       %is a string, use strcmp to check equality
       ind_found=find(strcmp(Data.(Fields{i}),Values{i})); 
    else
       %assume is numerical, use == to check equality 
       ind_found=find(Data.(Fields{i})==Values{i}); 
    end    
    %keep only indexes that past previous tests
    ind_data=intersect(ind_data,ind_found);   
end
end

