function [ Data ] = remove_artifacts_single_cells(Data, artifact_coords  )
%REMOVE_ARTIFACTS_SINGLE_CELLS uses the artifacts coordinates to remove
%cells whose value is wrong because of imaging artifacts (identified as the
%location in a well)

%find the columsn associated to the relevant fields in the artifact_coords
name_fields={'Well' 'Field'};
for i=1:length(name_fields)
    ifields(i)=find(strcmp(artifact_coords(1,:),name_fields{i}));
end    
%find the columns associated to the coordiantes
name_coords={'Upper Left Corner (X)' 'Upper Left Corner (Y)' 'Lower Right Corner (X)' 'Lower Right Corner (Y)'};
for i=1:length(name_coords)
    icoords(i)=find(strcmp(artifact_coords(1,:),name_coords{i}));
end 

%for each artifact, find the corresponding well and eliminate cells that are within the square deletion box
for i=2:size(artifact_coords,1)
    %check the field ID is not null
    if (~isempty(artifact_coords{i,1})&&~isnan(artifact_coords{i,1}))
        %find entry in data corresponding to that well
        iWellField=ifields(find(strcmp(name_fields,'Well')));
        iWell=find(strcmp(Data.WellName,artifact_coords{i,iWellField}));
        %find single cells in that well that have the correct Field
        iFieldField=ifields(find(strcmp(name_fields,'Field')));
        iPlane=find(Data(iWell,:).SingleCell{1}.Field==artifact_coords{i,iFieldField});
        iULCX=icoords(find(strcmp(name_coords,'Upper Left Corner (X)')));
        iLRCX=icoords(find(strcmp(name_coords,'Lower Right Corner (X)')));
        iCoordX=intersect(find(Data(iWell,:).SingleCell{1}.X>=artifact_coords{i,iULCX}),find(Data(iWell,:).SingleCell{1}.X<=artifact_coords{i,iLRCX}));
        iULCY=icoords(find(strcmp(name_coords,'Upper Left Corner (Y)')));
        iLRCY=icoords(find(strcmp(name_coords,'Lower Right Corner (Y)')));
        iCoordY=intersect(find(Data(iWell,:).SingleCell{1}.Y>=artifact_coords{i,iULCY}),find(Data(iWell,:).SingleCell{1}.Y<=artifact_coords{i,iLRCY}));
        iDel=intersect(iPlane,iCoordX);
        iDel=intersect(iDel,iCoordY);
        fprintf(1,'Artifacts removed: %d single cells from Field %d of %s\n',length(iDel),artifact_coords{i,iFieldField},artifact_coords{i,iWellField});
        %find 
        Data(iWell,:).SingleCell{1}(iDel,:)=[];
    end
end    



end

