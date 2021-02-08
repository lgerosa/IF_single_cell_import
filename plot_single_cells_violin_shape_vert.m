function [] = plot_single_cells_violin_shape_vert(x,y,step_x,bin_num,color,mode)
%PLOT_SINGLE_CELLS plots single cell data with x axis and y cell array of
%data distribution 


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
    %plot either single dots or smoothed distribution countour
    if (strcmp(mode,'dots')==1)
       %add an offest to x that represents the distribution profile and is at maximum as the step requested     
       xr = sign(rand(ns,1)).* bin_counts_norm(bin_identity)'.*step_x.*rand(ns,1);       
       %plot each dots according to the violin distribution 
       plot(y{i},x(i)+xr,'ok','MarkerSize',0.2,'MarkerEdgeColor','auto','MarkerFaceColor','auto','Color',color);
    elseif (strcmp(mode,'dist')==1)   
      %smooth line 
      bin_counts_norm_smooth=smooth(bin_counts_norm,'moving',5);
      %put together the two side of the violin plot and close it 
      lsi=0.2;
      x_vplot=x(i)+bin_counts_norm_smooth.*step_x;
     % plot([x_vplot_lft; x_vplot_rgt(end:-1:1); x_vplot_lft(1)],[bin_edges(1:end-1) bin_edges(end-1:-1:1) bin_edges(1)] ,'-','Color',color,'LineWidth',lsi);
      plot([bin_edges(1:end-1)], [x_vplot] ,'-','Color',color,'LineWidth',lsi);
     
    end
    %plot each point according to 
    %scatplot(x(i)+xr,y{i},'circles');
    hold on;
end


end
