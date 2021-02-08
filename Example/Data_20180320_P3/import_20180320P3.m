function [] = import_20180320P3()
%IMPORT_20160801 import the raw data into MATLAB structures

%set folder to search for rawdata
RawDataFolder = './RawData/';
%set folder to search for platelayout
PlateLayoutFolder = './PlateLayout/';

%% load average cell data and add design information
FilterHeader={}; %specifiy which header you want, if empty is all 
Data=load_average_data([RawDataFolder 'Hoechst_WCB_647_HT29[7974217].result.1'],FilterHeader);

%% add single cell data to average data
FilterHeaderSSC={}; %specifiy which header you want, if empty is all 
Data=add_singlecell_data(RawDataFolder,'Hoechst_WCB_647_HT29[7974217].result.',Data,genWellNames(2:7,2:11),FilterHeaderSSC);

%% add design to data
%load designs from excell and add it to the data
Design = plate_layout_excell_importer([PlateLayoutFolder 'PlateLayout_20180320_P3.xlsx']);
%add the drugs from the D300
%% load and add D300 file information
Design_hpdd=hpdd_importer_from_Marc([PlateLayoutFolder '20180320 HT29 with RAFi & MEKi plus 6h EGF.hpdd']);
%Design.Drugs(find(strcmp({Design.Drugs(:).name},'Dummy')))=[];
for i=1:length(Design_hpdd.Drugs)
    drugname=Design_hpdd.Drugs(i).DrugName;
    drugname(strfind(drugname,'-'))='_';
    Design.Drugs(end+1).name=drugname;
    layoutDrugs=Design_hpdd.Drugs(i).layout;
    Design.Drugs(end).data=num2cell(layoutDrugs);
    Design.Drugs(end).unit='uM';
end   
%save design
save(['./Design.mat'], 'Design');
Data=add_design(Data,Design);

%% save data into a MATLAB structure
save(['./Data.mat'], 'Data');

end

