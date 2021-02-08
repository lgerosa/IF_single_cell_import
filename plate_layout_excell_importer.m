function [ design ] = plate_layout_excell_importer( filedirname )
%PLATE_LAYOUT_EXCELL_IMPORTER loads a plate layout into a design structure

design=[];

%% load headers information from META_INFO
%expected headers
expHeaders={'Field name' 'Sheet' 'Unit'};
%open the excell file searching for the META_INFO sheet
[~,WellsContent,~] = xlsread(filedirname,'META_INFO');
%find the correct column for each header
iexpHeaders=[];
for i=1:length(expHeaders)
    iexpHeaders(i)=find(strcmp(WellsContent(1,:),expHeaders{i}));
end
%extract the fields to be created, the corresponding sheet, type and unit
metaInfoContent=WellsContent(2:end,:);
strucNames=metaInfoContent(:,iexpHeaders(find(strcmp(expHeaders,'Field name'))));
[strucNamesU, ~, iU]=unique(strucNames);
for i=1:length(strucNamesU)
    design.(strucNamesU{i})={}; 
end

%for each field, create a structure and load the information from the corresponding sheet
for i=1:size(metaInfoContent,1)
    %load the sheet information
    fieldName=metaInfoContent{i,find(strcmp(expHeaders,'Field name'))};
    sheetName=metaInfoContent{i,find(strcmp(expHeaders,'Sheet'))};
    %load the sheet data
    [SheetContentNum,SheetContentStr,SheetContentRaw] = xlsread(filedirname,sheetName);
    SheetContent=SheetContentRaw;
    %check if it is the only entry with that field name
    nEntry=sum(iU==find(strcmp(strucNamesU,fieldName)));
    %if it is single create the corresponding field
    if (nEntry==1)
       design.(fieldName)=SheetContent;
    elseif (nEntry>1)
       design.(fieldName)(end+1).name=sheetName; 
       design.(fieldName)(end).data=SheetContent;
       design.(fieldName)(end).unit=metaInfoContent{i,find(strcmp(expHeaders,'Unit'))};
    else
        fprintf(1,'Error: Fieldname not found.\n');
    end    
        
end    




end

