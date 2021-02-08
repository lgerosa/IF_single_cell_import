function [] = plot_single_cells(x,y,step_x)
%PLOT_SINGLE_CELLS plots single cell data with x axis and y cell array of
%data distribution 

tf = ishold;
for i=1:length(x)  
    ns= length(y{i});
    xr = step_x*rand(ns,1)-(step_x./2);
    scatplot(x(i)+xr,y{i},'circles');
    hold on;
end


end

