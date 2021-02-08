function [ data ] = add_field_singlecell_data( data, newfieldnames, f, field_name1, field_name2 )
%ADDFIELDSINGLECELL adds a new field in all single cell datasets using a
%function parameterized by the field_names

%for each entry in the dataset
for i=1:size(data,1)
    data(i,:).SingleCell{1}.(newfieldnames)= f(data(i,:).SingleCell{1}.(field_name1),data(i,:).SingleCell{1}.(field_name2));
end

end

