function [artifact_coords ] = load_artifacts_coords( filename )
%LOAD_ARTIFACTS_COORDS loads the informations to remove cells that have
%measurements values that are artifacts

%load excell table
[~,~,artifact_coords] = xlsread(filename);
end

