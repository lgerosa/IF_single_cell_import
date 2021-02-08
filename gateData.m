function [ DataGated ] = gateData(Data, fieldNames, GateValues )
%GATEDATA this function gates the single cell data that do not pass 
%the minimum and maximal values (GateValues) in the fieldNames and plots
%the resulting gating 

%extract the number of row in the data table
nfieldNames=length(fieldNames);
ndata=size(Data,1);

%for each fieldName plot the overall distribution and show the gated in and out data 
figure;
set(gcf,'Name','Gated Data','numbertitle','off');
set(gcf,'Color','White');
for i=1:nfieldNames
    %extract values from each data row
    allvalues=[];
    gateinvalues=[];
    for j=1:ndata
        values=[Data(j,:).SingleCell{1}.(fieldNames{i})];
        ind_gated_in{i}{j}=intersect(find(values>=GateValues(i,1)),find(values<=GateValues(i,2)));
        allvalues=[allvalues; values]; 
        gateinvalues=[gateinvalues; values(ind_gated_in{i}{j}) ];
    end
    %plot the original distribution  
    subplot(nfieldNames,2,(2*i)-1);
    histogram(allvalues,1000);
    hold on;
    YLimV=get(gca,'YLim');
    plot([GateValues(i,1) GateValues(i,1)],[YLimV(1) YLimV(2)],'r-');
    plot([GateValues(i,2) GateValues(i,2)],[YLimV(1) YLimV(2)],'r-');
    title(sprintf('%s NOT Gated',fieldNames{i}),'interpreter','none');
    %set(gca,'XScale','log');
    %plot the gated distribution  
    subplot(nfieldNames,2,(2*i));
    histogram(gateinvalues,1000);
    hold on;
    YLimV=get(gca,'YLim');
    plot([GateValues(i,1) GateValues(i,1)],[YLimV(1) YLimV(2)],'r-');
    plot([GateValues(i,2) GateValues(i,2)],[YLimV(1) YLimV(2)],'r-');  
    title(sprintf('%s Gated',fieldNames{i}),'interpreter','none');
    %set(gca,'XScale','log');
end
%intersect all the retained data point and create the gated dataset
DataGated=Data;
nRemDataPoints=0;
nTotDataPoints=0;
for j=1:ndata
    ind_all_gated=1:length(Data(j,:).SingleCell{1}.(fieldNames{i}));
    nTotDataPoints=nTotDataPoints+length(ind_all_gated);
    for i=1:nfieldNames
        ind_all_gated=intersect(ind_all_gated,ind_gated_in{i}{j});
    end
    in_not_gated=setdiff(1:length(Data(j,:).SingleCell{1}.(fieldNames{i})),ind_all_gated);
    DataGated(j,:).SingleCell{1}(in_not_gated,:)=[];
    nRemDataPoints=nRemDataPoints+length(in_not_gated);
end
fprintf('Removed %d/%d (%2.5f%%) single cell data points.\n',nRemDataPoints,nTotDataPoints,nRemDataPoints./nTotDataPoints);

end

