function [data] = load_average_data(filename,filterHeaders)
%LOAD_AVERAGE_DATA creates a structure with the average data from Columbus


%load the platelayout file with content of wells 
M = csvimport([filename '.txt'],'delimiter','\t');

%keep only the selected headers (if any)
if (~isempty(filterHeaders))
   [~,ikeep,~]=intersect(M(1,:),filterHeaders);
   M=M(:,ikeep);
end    

%convert data into a table
Headers=M(1,:);
cleanHeaders=cleanHeadersNames(Headers);
data=cell2table(M(2:end,:),'variablenames',cleanHeaders);

%data.headers=M(1,:);
%data.data=M(2:end,:);


end

