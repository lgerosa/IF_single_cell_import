function [] = plot_20180320_P1234(DataP1234)
%PLOT_20171213 plots average and single cell results from 384 well plate
%screening of multiple drugs for 24 hrs with or without 10 mins EGF

%load data
%load('DataP1234./.mat');
Data=DataP1234;
%set or load the cell lines, drugs etc..
pERK_signal='NucleiNoBorder_IntensityCytoplasmAlexa647Mean';
Drugs={'Vemurafenib' 'Cobimetinib'};
DrugsComboDil={'Vemurafenib' 'Cobimetinib' 'Cobimetinib'};
DrugsComboFixed={'' '' 'Vemurafenib'};
DrugsComboFixedConc=[NaN; NaN; 1];
GFs={'EGF'};
GFsConc=unique(Data.EGF);
FBSperc=unique(Data.FBS);
cellLines=unique(Data.Cell_line);
%load the concentrations of each drug
DrugsConc={};
for i=1:length(DrugsComboDil)
    DrugsConc{i}=unique(Data.(DrugsComboDil{i}));
    %remove zero because that values is going be extracted from DMSO controls
    DrugsConc{i}(DrugsConc{i}==0)=[];
end
DrugsConcPlot=DrugsConc;

%% Create structure to save in excell
%encode the variable -1 in the range 
excell_dataset={};
excell_dataset=['Cell_Line' Drugs(:)' 'EGF' 'Time_Drug' 'Time_EGF' 'pERK' 'pMEK' repmat({'Concentration (uM)'},9,1)' repmat({'Mean'},9,1)' repmat({'Std'},9,1)'];

%%plot
f1=figure('Name','Average pERK without and with EGF (5 mins)','Color','White');
f2=figure('Name','Average log pERK without and with EGF (5 mins)','Color','White');
f3=figure('Name','Replicate pERK without and with EGF (5 mins)','Color','White');
f4=figure('Name','Single cell pERK without and with EGF (5 mins)','Color','White');
nrow=3;
ncol=3; 
colorOrder = get(gca, 'ColorOrder');
lineType={'-' ':'};

%keep data from one plate and the other always separate so to have controls
%that come from the same plate
cntr_P={'20180320_P1_10perc_BckSub' '20180320_P2_10perc_BckSub' '20180320_P3_05perc_BckSub' '20180320_P4_05perc_BckSub'};
cntr_field='PlateName';

%initialize control structure
for j=1:length(GFsConc)
    for p=1:length(cntr_P)
        pERK_cntr{j}{p}=[];
        pERK_cntr{j}{p}=[];
    end
end    

%find control cells with and without EGF
for j=1:length(GFsConc)
    ind=find_Data(Data,{'EGF' Drugs{:}},num2cell([GFsConc(j) repmat(0,1,length(Drugs))]));
    %put together all controls
    for p=1:length(ind)
        irep=find(strcmp(cntr_P,Data(ind(p),:).(cntr_field)));
        sc_data=Data(ind(p),:).SingleCell{1}.(pERK_signal);     
        sc_data(isnan(sc_data))=[];
        sc_data(isinf(sc_data))=[];
        %as it if were two replicate, for consistency with drug measurements
        pERK_cntr{j}{irep}=[pERK_cntr{j}{irep}; sc_data];
    end
end


%for each drug
for i=1:length(DrugsComboDil)
    %for the two different FBS concentrations in media
    for k=1:length(FBSperc)
        %for without and with GFs
        for j=1:length(GFsConc)
            pERK={};
            %pERK_norm_index={};
            pERK_ave=[];
            pERK_ave_corr=[];
            pERK_corr_log=[];
            %for each concentration extract the data
            for z=1:length(DrugsConc{i})
                %search for data with right concetration of that drug 
                DrugConcSearch=repmat(0,1,length(Drugs));
                DrugConcSearch(find(strcmp(Drugs,DrugsComboDil{i})))=DrugsConc{i}(z);
                %add a second drug at fix doses if it is a combo
                fixedDrug=DrugsComboFixed{i};
                if (~isempty(fixedDrug))
                   DrugConcSearch(find(strcmp(Drugs,fixedDrug)))=DrugsComboFixedConc(i);
                end    
                %add a fixed Vemurafenib or Dabrafenib if it was a combo
                ind=find_Data(Data,{'EGF' 'FBS' Drugs{:}},num2cell([GFsConc(j) FBSperc(k) DrugConcSearch ]));
                %extract all replicates
                for r=1:length(ind)
                    sc_data=Data(ind(r),:).SingleCell{1}.(pERK_signal);
                    %clean nan values
                    sc_data(isnan(sc_data))=[]; 
                    sc_data(isinf(sc_data))=[];
                    %find which replicates is it (plate 1 or 2)
                    irep=find(strcmp(cntr_P,Data(ind(r),:).(cntr_field)));
                    pERK{r}{z+1}=sc_data; 
                    %set zero drug normalization data
                    irep=find(strcmp(cntr_P,Data(ind(r),:).(cntr_field)));
                    %pERK_norm_index{r}{1}=irep;  
                    %set zero drug normalization data
                    pERK{r}{1}=pERK_cntr{1}{irep};
                end
            end    

            %normalize and average data taking into consideration replicates
            for r=1:length(pERK) %two replicate for each conditions
                    pERK_ave(r,:)=cellfun(@nanmean,pERK{r});
                    %pERK_std(r,:)=cellfun(@nanstd,pERK{r});
                    %irep=pERK_norm_index{r}{1};
                    pERK_ave_corr(r,:)=pERK_ave(r,:)./nanmean(pERK{r}{1});
                    %pERK_std_corr(r)=pERK_std(r)./nanmean(pERK_cntr{1});
                    pERK_corr_log(r,:)=log(pERK_ave_corr(r,:));%cellfun(@log,pERK_ave_corr,'UniformOutput',0);            
                    %pERK_corr_std_log(r)=pERK_std_corr(r)./pERK_corr_log(r);%cellfun(@nanstd,pERK_log);
            end    
            %remove the 1 at the start that was used to normalize        
            pERK_ave(:,1)=[];
            pERK_ave_corr(:,1)=[];
            pERK_corr_log(:,1)=[];
            
            %plot average lin scale
            figure(f1);
            subplot(nrow,ncol,sub2ind([ncol nrow],k,i));
            %plot([10^-5 DrugsConc{i}(:)'],pERK_ave_corr,'Marker','o','MarkerFaceColor','auto','MarkerEdgeColor','auto','LineWidth',2);
            errorbar([DrugsConcPlot{i}(:)'],mean(pERK_ave_corr),std(pERK_ave_corr),'Marker','o','MarkerSize',4,'MarkerFaceColor','auto','MarkerEdgeColor','auto','LineWidth',1.5)
            hold all;
            set(gca,'XScale','log');
            if (~isempty(fixedDrug))
               title(sprintf('FBS:%2.2f %s+%s(%0.2fuM)',FBSperc(k),DrugsComboDil{i},DrugsComboFixed{i},DrugsComboFixedConc(i)),'Interpreter','None','FontSize',8);
            else
               title(sprintf('FBS:%2.2f  %s(24h)',FBSperc(k),DrugsComboDil{i}),'Interpreter','None','FontSize',8); 
            end    
            xlim([0.000001 100]);
            ylim([0 2]);
            set(gca,'XTick',10.^[-4:2:1]);
            if(j==1)
              ylabel('pERK (au)');
            end 
            xlabel('Drug Conc (uM)');
            
            %load data in the data excell, but only for the 10% GF media
            if (FBSperc(k)==10)    
                idrug=find(strcmp(Drugs,DrugsComboDil{i}));
                ifixdrug=find(strcmp(Drugs,DrugsComboFixed{i}));
                drugcell=num2cell(repmat(0,length(Drugs),1))';
                %set -1 to drug that is changing
                drugcell{idrug}=-1;
                %set fixed concentration if there is a fixed drug
                if (~isempty(ifixdrug))
                    drugcell{ifixdrug}=DrugsComboFixedConc(i);
                end    
                excell_dataset(end+1,:)=['HT29' drugcell num2cell(GFsConc(j)) num2cell([24 8]) num2cell([1 0]) num2cell(DrugsConcPlot{i})'  num2cell(mean(pERK_ave_corr))  num2cell(std(pERK_ave_corr))];
            end
            %plot in the final all together
            subplot(nrow,ncol,sub2ind([ncol nrow],3,i));
            errorbar([DrugsConcPlot{i}(:)'],mean(pERK_ave_corr),std(pERK_ave_corr),'Marker','o','MarkerSize',4,'MarkerFaceColor',colorOrder(j,:),'MarkerEdgeColor',colorOrder(j,:),'LineWidth',1.5,'Linestyle',lineType{k},'Color',colorOrder(j,:))
            hold all;
            set(gca,'XScale','log');
            if (~isempty(fixedDrug))
               title(sprintf('FBS:all %s+%s(%0.2fuM)',DrugsComboDil{i},DrugsComboFixed{i},DrugsComboFixedConc(i)),'Interpreter','None','FontSize',8);
            else
               title(sprintf('FBS:all  %s(24h)',DrugsComboDil{i}),'Interpreter','None','FontSize',8); 
            end    
            xlim([0.000001 100]);
            ylim([0 2]);
            set(gca,'XTick',10.^[-4:2:1]);
            if(j==1)
              ylabel('pERK (au)');
            end 
            xlabel('Drug Conc (uM)');
            

            %plot average log scale
            figure(f2);
            subplot(nrow,ncol,sub2ind([ncol nrow],k,i));
            %plot([10^-5 DrugsConc{i}(:)'],pERK_corr_log,'Marker','o','MarkerFaceColor','auto','MarkerEdgeColor','auto','LineWidth',2);
            errorbar([DrugsConcPlot{i}(:)'],mean(pERK_corr_log),std(pERK_corr_log),'Marker','o','MarkerSize',4,'MarkerFaceColor','auto','MarkerEdgeColor','auto','LineWidth',1.5)
            hold all;
            set(gca,'XScale','log');
            if (~isempty(fixedDrug))
               title(sprintf('FBS:%2.2f %s+%s(%0.2fuM)',FBSperc(k),DrugsComboDil{i},DrugsComboFixed{i},DrugsComboFixedConc(i)),'Interpreter','None','FontSize',8);
            else
               title(sprintf('FBS:%2.2f  %s(24h)',FBSperc(k),DrugsComboDil{i}),'Interpreter','None','FontSize',8); 
            end    
            set(gca,'XTick',10.^[-4:2:1]);
            xlim([0.000001 100]);
            ylim([-3.3 1.5]);
            if(j==1)
              ylabel('log pERK (au)');
            end   
            xlabel('Drug Conc (uM)');
            
            %plot in the final all together
             subplot(nrow,ncol,sub2ind([ncol nrow],3,i));
            %plot([10^-5 DrugsConc{i}(:)'],pERK_corr_log,'Marker','o','MarkerFaceColor','auto','MarkerEdgeColor','auto','LineWidth',2);
            errorbar([DrugsConcPlot{i}(:)'],mean(pERK_corr_log),std(pERK_corr_log),'Marker','o','MarkerSize',4,'MarkerFaceColor',colorOrder(j,:),'MarkerEdgeColor',colorOrder(j,:),'LineWidth',1.5,'Linestyle',lineType{k},'Color',colorOrder(j,:));
            hold all;
            set(gca,'XScale','log');
            if (~isempty(fixedDrug))
               title(sprintf('FBS:all %s+%s(%0.2fuM)',DrugsComboDil{i},DrugsComboFixed{i},DrugsComboFixedConc(i)),'Interpreter','None','FontSize',8);
            else
               title(sprintf('FBS:all %s(24h)',DrugsComboDil{i}),'Interpreter','None','FontSize',8); 
            end    
            set(gca,'XTick',10.^[-4:2:1]);
            xlim([0.000001 100]);
            ylim([-3.3 1.5]);
            if(j==1)
              ylabel('log pERK (au)');
            end   
            xlabel('Drug Conc (uM)');

            %plot the replicates separately
            figure(f3);
            subplot(nrow,ncol,sub2ind([ncol nrow],k,i));
            plot([DrugsConcPlot{i}(:)'],pERK_ave_corr,'Marker','o','MarkerSize',4,'MarkerFaceColor',colorOrder(j,:),'MarkerEdgeColor',colorOrder(j,:),'LineWidth',1.5,'Linestyle',lineType{k},'Color',colorOrder(j,:));
            hold all;
            set(gca,'XScale','log');
            if (~isempty(fixedDrug))
               title(sprintf('FBS:%2.2f %s+%s(%0.2fuM)',FBSperc(k),DrugsComboDil{i},DrugsComboFixed{i},DrugsComboFixedConc(i)),'Interpreter','None','FontSize',8);
            else
               title(sprintf('FBS:%2.2f  %s(24h)',FBSperc(k),DrugsComboDil{i}),'Interpreter','None','FontSize',8); 
            end    
            xlim([0.000001 100]);
            ylim([0 2]);
            set(gca,'XTick',10.^[-4:2:1]);
            if(j==1)
              ylabel('pERK (au)');
            end 
            xlabel('Drug Conc (uM)');
            
            %plot in the final all together
            subplot(nrow,ncol,sub2ind([ncol nrow],3,i));
            plot([DrugsConcPlot{i}(:)'],pERK_ave_corr,'Marker','o','MarkerSize',4,'MarkerFaceColor',colorOrder(j,:),'MarkerEdgeColor',colorOrder(j,:),'LineWidth',1.5,'Linestyle',lineType{k},'Color',colorOrder(j,:));
            hold all;
            set(gca,'XScale','log');
            if (~isempty(fixedDrug))
               title(sprintf('FBS:all %s+%s(%0.2fuM)',DrugsComboDil{i},DrugsComboFixed{i},DrugsComboFixedConc(i)),'Interpreter','None','FontSize',8);
            else
               title(sprintf('FBS:all  %s(24h)',DrugsComboDil{i}),'Interpreter','None','FontSize',8); 
            end    
            xlim([0.000001 100]);
            ylim([0 2]);
            set(gca,'XTick',10.^[-4:2:1]);
            if(j==1)
              ylabel('pERK (au)');
            end 
            xlabel('Drug Conc (uM)');

            figure(f4);
            %plot single cells distributions
            %select subplot depending on being with EGF or without
            for r=1:2 %two replicate for each conditions
                 subplot(nrow,ncol-1,sub2ind([ncol-1 nrow],k,i));
                pERK_norm_sc=cellfun(@(x) x./nanmean(pERK{r}{1}),pERK{r},'UniformOutput',0);
                pERK_log_norm_sc=cellfun(@log,pERK_norm_sc,'UniformOutput',0);
                %remove -Inf values in the single cell data
                for pt=1:length(pERK_log_norm_sc)
                    pERK_log_norm_sc{pt}(isinf(pERK_log_norm_sc{pt}))=[];
                end        
                plot_single_cells_violin_shape(log10([DrugsConcPlot{i}(:)']),pERK_log_norm_sc,0.1,2000,colorOrder(j,:),'dots');
                hold all;
                ylim([-4.5 2.5]);
                xlim([-5.5 1.5]);
                if(j==1)
                   ylabel('pERK (au)');
                end 
                %if(subppos==4)
                  xlabel('Drug Conc (uM)');
                %end    
                 if (~isempty(fixedDrug))
                   title(sprintf('FBS:%2.2f %s+%s(%0.2fuM)',FBSperc(k),DrugsComboDil{i},DrugsComboFixed{i},DrugsComboFixedConc(i)),'Interpreter','None','FontSize',8);
                 else
                   title(sprintf('FBS:%2.2f %s(24h)',FBSperc(k),DrugsComboDil{i}),'Interpreter','None','FontSize',8); 
                 end    

            end          
        end  
    end   
end    

%add legend only on the right upper corner plot
figure(f1);
subplot(nrow,ncol,sub2ind([ncol nrow],ncol,1));
legend({ '+EGF' '-EGF'});

figure(f2);
subplot(nrow,ncol,sub2ind([ncol nrow],ncol,1));
legend({ '+EGF' '-EGF'});

%figure(f4);
%subplot(nrow,ncol,sub2ind([ncol nrow],ncol,1));
%legend({ '+EGF' '-EGF'});

%% save data in excel (only average)
exc_file='/dataset_excell/20180320_dataset.xlsx';
xlswrite(exc_file,excell_dataset,'pERK 10FBS');

end

