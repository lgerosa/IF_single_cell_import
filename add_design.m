function [ data ] = add_design( data,design )
%ADD_DESIGN adds the information in design in the data structure

%extract the wells identifier for which we need design info
wellNames=data.WellName;
%fields to transfer
fieldsTransfer={'Drugs' 'Perturbations'};
namesTransfer={'Drug' 'Perturbation'};

%create design cell array to append to data
designCArray={};
for i=1:length(fieldsTransfer)
    entStruct=design.(fieldsTransfer{i});
    for j=1:length(entStruct)
        entSingle=entStruct(j);
        designCArray{1,end+1}=entSingle.name;
        designCArray{1,end+1}=[entSingle.name '_Unit'];
        %search infos for each well
        for k=1:length(wellNames)
            [irow, icol]=find(strcmp(design.well_names,wellNames{k}));  
            designCArray{k+1,end-1}=entSingle.data{irow,icol};
            designCArray{k+1,end}=entSingle.unit;
        end
    end    

end    

TableDesign=cell2table(designCArray(2:end,:),'variablenames',designCArray(1,1:end));
data=[data  TableDesign];


end

