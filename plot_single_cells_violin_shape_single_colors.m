function [] = plot_single_cells_violin_shape_single_colors(x,y,step_x,bin_num,color,mode, markersize)
%PLOT_SINGLE_CELLS plots single cell data with x axis and y cell array of
%data distribution 

if ~exist('markersize','var')
     % third parameter does not exist, so default it to something
      markersize = 0.7;
end

tf = ishold;
%cycle through all the x data points
for i=1:length(x)  
    %obtain number of point making up the distribution
    ns= length(y{i});
    %count elements in bins using the method selected by the user
    if (bin_num==-1)
        %optimal number of bins using Freedman-Diaconis rule 
       [bin_counts,bin_edges,bin_identity] = histcounts(y{i},'BinMethod','fd');
    else
        %generate counts for bins decided by user 
        [bin_counts,bin_edges,bin_identity] = histcounts(y{i},bin_num);
    end
    %normalize bins to maximal of 1
    bin_counts_norm=bin_counts/max(bin_counts);
    %add a bit of spacing
    bin_counts_norm=bin_counts_norm;%+0.1;
    %plot either single dots or smoothed distribution countour
    if (strcmp(mode,'dots')==1)
       %add an offest to x that represents the distribution profile and is at maximum as the step requested     
       xr = sign(rand(ns,1)-0.5).* bin_counts_norm(bin_identity)'.*step_x.*rand(ns,1)*2;       
       %plot each dots according to the violin distribution 
       scatter(x(i)+xr,y{i},markersize,color{i});   
    end
    hold on;
end


end
