function [ data ] = add_singlecell_data(dirname,filename,data,wellNames,filterHeaders)
%ADD_SINGLECELL_DATA adds single cells information to an average data structure from Columbus


dataSC={};

%generate name of expected files
expFiles={};
for i=1:length(wellNames)
    expFiles{end+1}=[filename wellNames{i}];
end    

%search for the filenames of the corresponding files in the directory
listFiles = dir(dirname);
%for each expected file
for i=1:length(expFiles)
    %search in the directory
    iF=[];
    for j=1:length(listFiles)
      %record index if found
      if (~isempty(strfind(listFiles(j).name, expFiles{i})))
          iF=j;
      end
    end
    %check if found
    if (~isempty(iF))
       %load the file
       M = csvimport([dirname listFiles(iF).name],'delimiter','\t');      
       %check if there are columns that are numbers but the presence of NaN
       %screwed up the automatic conversion 
       for j=1:size(M,2)
           iNaN=find(strcmp(M(:,j),'NaN'));
           if ~isempty(iNaN)
              M(2:end,j)=num2cell(cellfun(@str2num,M(2:end,j)));
           end     
       end    
       %keep only the selected headers (if any)
       if (~isempty(filterHeaders))
          [~,ikeep,~]=intersect(M(1,:),filterHeaders);
          M=M(:,ikeep);
       end    
       %convert data into a table
       Headers=M(1,:);
       cleanHeaders=cleanHeadersNames(Headers);
       %create a array of single cell data in the order of main data
       iAve=find(strcmp(data.WellName,wellNames{i}));
       dataSC{iAve}=cell2table(M(2:end,:),'variablenames',cleanHeaders);  
       
       
    else
        %print error if not found
        fprintf(1,'%s NOT found.\n',expFiles{i});
    end    
    
end
%merge single cell data into average data
TableSC=cell2table(dataSC','variablenames',{'SingleCell'});
data=[data TableSC];

end

