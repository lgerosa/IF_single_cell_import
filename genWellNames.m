function [wellNames] = genWellNames(rows,cols)
%GENWELLNAMES generates the well names (identifiers) for the rows and
%columns defined

%Identifiers
rowN={'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P'};
colN={'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' '11' '12' '13' '14' '15' '16' '17' '18' '19' '20' '21' '22' '23' '24'};

%generate names
wellNames={};
for i=1:length(rows)
    for j=1:length(cols)
        wellNames{end+1}=[rowN{rows(i)} colN{cols(j)}];
    end
end    

end

