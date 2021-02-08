function [ cleanheaders ] = cleanHeadersNames( headers )
%CLEANHEADERSNAMES takes strings cleans them to be valid headers
%for examples removes spaces and replaces - with _

for i=1:length(headers)
    tmpheader=headers{i};
    tmpheader(strfind(tmpheader,' '))=[];
    tmpheader(strfind(tmpheader,'Â'))=[];
    tmpheader(strfind(tmpheader,'Â'))=[];
    tmpheader(strfind(tmpheader,'²'))=[];
    tmpheader(strfind(tmpheader,'µ'))='u';
    tmpheader(strfind(tmpheader,'['))='_';
    tmpheader(strfind(tmpheader,']'))='_';
    tmpheader(strfind(tmpheader,'-'))='_';
    if (length(tmpheader)>63)
        tmpheader=tmpheader(1:63);
    end
    cleanheaders{i}=tmpheader;
end    



end

