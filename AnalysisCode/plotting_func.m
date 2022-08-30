function [] = plotting_func(Basin_Index, Basin_N, Basin_Select, n_trial,basinmapfolder, activityfolder, drillinginfofolder,DI_filename)

ColorMat = [140/255,21/255,21/255;...%Stanford red
    233/255,131/255,0/255;...% Stanford orange
    234/255,171/255,0/255;...% Stanford yello
    0/255,155/255,118/255;...% Stanford light green
    23/255,94/255,84/255;... % Stanford dark green
    0/255,152/255,219/255;...% Stanford blue
    83/255,40/255,79/255;... % Stanford purple
    0.66, 0.66, 0.66;...
    140/255,21/255,21/255;...%Stanford red
    233/255,131/255,0/255;...% Stanford orange
    234/255,171/255,0/255;...% Stanford yello
    0/255,155/255,118/255;...% Stanford light green
    23/255,94/255,84/255;... % Stanford dark green
    0/255,152/255,219/255];

if Basin_Select ~= 0
    formatSpec = '%f%f%f%f%f%f%f%f%f%C';
    filepath = fullfile(pwd, drillinginfofolder,DI_filename);
    DI_data = readtable(filepath,'Format',formatSpec);
    DI_data.Prov_Cod_1(DI_data.Prov_Cod_1 == '160A') = '160';

    catdata = DI_data.Prov_Cod_1;
    strings = string(catdata);
    Basin_Name = double(strings);

    % Note that although the headers in the file are “monthly oil” and “monthly gas”, these are summed across all months for 2020 so the units are “bbl/year” and “mscf/year”.
    Gas_Production = DI_data.Monthly_Ga;
    Oil_Production = DI_data.Monthly_Oi;
    Gas_Production(isnan(Gas_Production)) = 0;
    Oil_Production(isnan(Oil_Production)) = 0;

    Well_Count = ones(numel(Basin_Name),1);
    logind = ismember(Basin_Name, Basin_N(Basin_Select));
    M_all = [Oil_Production, Gas_Production, Well_Count];
    ind = logind;
    ind = int16(ind);
    M_basin = M_all(ind == 1,:);
else
    csvFileName = 'david_lyon_2015_no_offshore.csv';
    filepath = fullfile(pwd, drillinginfofolder,csvFileName);
    %file = fopen(csvFileName);
    M_US = csvread(filepath,0,0);
    %fclose(file);
end
% %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Outputs'
% FileName = ['sitedata_out.mat'];
% filepath = fullfile(pwd, 'Outputs/',FileName);
% load(filepath);
% %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2'
% sitedata_US = sitedata_All;

% %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Outputs'
% FileName = ['Emissionsdata_out.mat'];
% filepath = fullfile(pwd, 'Outputs/',FileName);
% load(filepath);
% %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2'
% Study_US = EmissionsGas + EmissionsOil;

if Basin_Select ~= 0
    %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Outputs'
    FileName = ['Emissiondata_' Basin_Index{Basin_Select} 'out.mat'];
    filepath = fullfile(pwd, 'Outputs/',FileName);
    load(filepath);
    %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2'
    Study_basin = EmissionsGas + EmissionsOil;
end


%% Analysis

% productivity distribution
if Basin_Select ~= 0
    [plot_dat_basin, OPGEE_bin] = di_scrubbing_func(M_basin, Basin_Select, Basin_Index, activityfolder);
else
    [plot_dat_US, OPGEE_bin] = di_scrubbing_func(M_US, 0, Basin_Index, activityfolder);
end

clf;
figure(1)
subplot(2,2,1)

legend('-DynamicLegend');
N = 40;
start = 10^-1;
stop = 10^5;
b = 10.^linspace(log10(start),log10(stop),N+1);

if Basin_Select ~=0
    h = histogram(plot_dat_basin,b,...
        'Normalization','probability','DisplayStyle','stairs','LineStyle','-','LineWidth',2,'EdgeColor',ColorMat(Basin_Select,:));  %,...
%     'DisplayName', char(Basin_Index(Basin_Select)));
% hold on
% 
else
    h = histogram(plot_dat_US,b,...
        'Normalization','probability','DisplayStyle','stairs','LineStyle','-','LineWidth',2,'EdgeColor',[0.66, 0.66, 0.66]);   %,...
    %     'DisplayName', 'US ave');
end

% legend('show');
dim = [.3 .6 .3 .3];

if Basin_Select ~= 0
    str = sprintf('%s \nn = %d wells', char(Basin_Index(Basin_Select)), length(plot_dat_basin));
    a = annotation('textbox',dim,'String',str,'FitBoxToText','on');
    a.FontSize = 8;
end

xlabel({'Wellpad throughput'; '[mscf d^{-1}, log scale]'});
ylabel('Probability');
ylim([0 0.1]);  
set(gca,'xscale','log')
set(gca,'FontSize',9);
set(gca,'FontName','Arial')

subplot(2,2,3)


hold on



for i = 1:n_trial
    if Basin_Select ~= 0
        FileName = ['sitedata_' Basin_Index{Basin_Select} num2str(i) '.csv'];
        filepath = fullfile(pwd, 'Outputs/',FileName);
        sitedata_basin = importdata(filepath);
    else
        FileName = ['sitedata' num2str(i) '.csv'];
        filepath = fullfile(pwd, 'Outputs/',FileName);
        sitedata_basin = importdata(filepath);        
    end
        
        
    x = sitedata_basin(:,2)/24;
    x = sort(x);
    site_ave(i) = sum(x)*(365*24)/1000000000;
    if i == 1
        x_all = [x sitedata_basin(:,4)];
    else
        x_all = vertcat(x_all,[x sitedata_basin(:,4)]);
    end
    well_per_site(i) = mean(sitedata_basin(:,3));
    
    y = x;
    y = cumsum(y);
    y = y./max(y);
    y = 1 - y;
    
%     if i == 1
        if Basin_Select ~= 0
            s = scatter(x,y,0.5,'s','MarkerEdgeColor',ColorMat(Basin_Select,:),'MarkerFaceColor',ColorMat(Basin_Select,:));
        else
            s = scatter(x,y,0.5,'s','MarkerEdgeColor',[140/255,21/255,21/255],'MarkerFaceColor',[140/255,21/255,21/255]);
        end
        s.MarkerFaceAlpha = 0.01;
        s.MarkerEdgeAlpha = 0.01;
%         x = sitedata_US;
%         x = x(:,2);
%         x = x./24;
%         x = sort(x);
%         
%         y = x;
%         y = cumsum(y);
%         y = y./max(y);
%         y = 1 - y;
%         scatter(x,y,10, [0.66, 0.66, 0.66]);
%     else
%         scatter(x,y,5,ColorMat(Basin_Select,:));
%     end
end

n_sites = size(sitedata_basin,1);

% Mean by stacking:
fprintf('Total by stacking = %d \n',(sum(x_all)*(365*24)/1000000000)/100)

% Mean by taking sample (without replacement) of size n_sites:
% https://www.mathworks.com/help/stats/randsample.html
index = randsample(1:length(x_all(:,1)),n_sites);
samp = x_all(index,:);
%fprintf('Mean by random sampling = %d \n',mean(samp))

% x = mean(x_all,2);
x = samp(:,1);
x = sort(x);
y = x;
y = cumsum(y);
y = y./max(y);
y = 1 - y;
scatter(x,y,2,'s','MarkerEdgeColor','k','MarkerFaceColor','k');


set(gca,'xscale','log')
xlim([0.005 1000])
xlabel('CH_{4} per site [kg h^{-1}, log scale]');
ylabel('Fraction total emissions');
set(gca,'FontSize',9);
set(gca,'FontName','Arial');

FileName = ['site_average_' Basin_Index{Basin_Select} '_.xlsx'];
filepath = fullfile(pwd, 'Outputs/',FileName);
xlswrite(filepath, samp)

FileName = ['wellpersite_' Basin_Index{Basin_Select} '.xlsx'];
filepath = fullfile(pwd, 'Outputs/',FileName);
xlswrite(filepath, well_per_site)

subplot(2,2,[2 4])


% GatherData_US = ...
%     [Study_US(6,:) + Study_US(7,:)+ Study_US(16,:);...
%      sum(Study_US(1:5,:))+sum(Study_US(8:9,:));...
%      sum(Study_US(10:11,:));...
%      Study_US(12,:);...
%      Study_US(17,:);...
%      sum(Study_US(13:14,:));...
%      Study_US(15,:)];
% 
%  
% GatherData_US_ave = mean(GatherData_US,2);
 
if Basin_Select ~= 0
    GatherData_basin = ...
        [Study_basin(6,:) + Study_basin(7,:)+ Study_basin(16,:);...
         sum(Study_basin(1:5,:))+sum(Study_basin(8:9,:));...
         sum(Study_basin(10:11,:));...
         Study_basin(12,:);...
         Study_basin(17,:);...
         sum(Study_basin(13:14,:));...
         Study_basin(15,:)];


     GatherData_basin_ave = mean(GatherData_basin,2);

     GatherData_basin_SumTot = sum(GatherData_basin,1);
     GatherData_basin_Prc = prctile(GatherData_basin_SumTot,[2.5 97.5],2);
     GatherData_basin_TotHi = GatherData_basin_Prc(2);
     GatherData_basin_TotLo = GatherData_basin_Prc(1);

     GatherData_basin_TotHi = GatherData_basin_TotHi - sum(GatherData_basin_ave);
     GatherData_basin_TotLo = sum(GatherData_basin_ave) - GatherData_basin_TotLo;
end 
 
%  PlotData_Ave = [GatherData_US_ave GatherData_basin_ave];
%  
%  b = bar(1:7,PlotData_Ave);
%  
%  Labels = {'Tanks','Equipment Leaks','Pneumatic Devices','Liquids Unloadings','Flare methane','Completions & Workovers','Methane slip'};
%  set(gca, 'xtick',1:7, 'XTickLabel', Labels,'XTickLabelRotation',25);
%  
%  set(gca,'FontSize',8)
%  set(gca,'FontName','Arial')
%  ylim([0 3.25])
%  
%  ylabel('Emissions [Tg CH_{4} yr^{-1}]');
%  set(gca,'YMinorTick','on')
%  set(gca, 'TickDir', 'out')

hBar = bar([1;nan], [GatherData_basin_ave(1:5)'; nan(1,5)],'stacked','BarWidth',0.5);

for i = 1:5
   hBar(i).FaceColor = ColorMat(i,:); 
end
% b1(1).FaceColor = LightGrey;
% b1(2).FaceColor = StanfordRed;

% hBar = bar(1,GatherData_basin_ave, 'stacked');
% xt = get(gca, 'XTick');
% set(gca, 'XTick', xt, 'XTickLabel', {'Machine 1' 'Machine 2' 'Machine 3' 'Machine 4' 'Machine 5'})
yd = get(hBar, 'YData');
yjob = {'Tanks','Equipment Leaks','Pneumatic Devices','Liquids Unloadings','Flare methane','Completions & Workovers','Methane slip'};
barbase = cumsum([0; GatherData_basin_ave(1:5-1)]);
joblblpos = GatherData_basin_ave(1:5)/2 + barbase;

text(1.4*ones(5,1), joblblpos, yjob(1:5), 'HorizontalAlignment','left');

if string(Basin_Index{Basin_Select}) == 'CALIFORNIA'
    up = ceil(sum(GatherData_basin_ave(1:5)) * 20) / 20;
elseif string(Basin_Index{Basin_Select}) == 'PERMIAN'...
        || string(Basin_Index{Basin_Select}) == 'APPALACHIAN'...
        || string(Basin_Index{Basin_Select}) == 'WILLISTON'
    up = (ceil(sum(GatherData_basin_ave(1:5)) * 10) / 10) + 0.2;
else
    up = ceil(sum(GatherData_basin_ave(1:5)) * 10) / 10;
end

hold on
er = errorbar(1, sum(GatherData_basin_ave(1:5)), GatherData_basin_TotLo, GatherData_basin_TotHi);
er.Color = [0 0 0];
er.LineStyle = 'none';

xlim([0 3])
ylim([0 up])
ylabel('[Tg CH_{4} yr^{-1}]');
set(gca,'FontSize',9);
set(gca,'FontName','Arial');

set(figure(1),'PaperUnits','inches','PaperPosition',[0 0 8 5.5])

%cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Outputs'
%FileName = ['plot_' Basin_Index{Basin_Select} 'out.emf'];
FileName = ['plot_' Basin_Index{Basin_Select} 'out.jpg'];
filepath = fullfile(pwd, 'Outputs/',FileName);
%print('-painters','-dmeta',filepath);
%cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2/'

print('-djpeg','-r300',filepath);
x = 1;
% figure(1)
% hold on
% for i = 1:13
%     
%     cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE\Outputs'
%     FileName = ['sitedata_' Basin_Index{i} 'out.mat'];
%     load(FileName);
%     cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE'
%     
%     x = sitedata_All;
%     x = x(:,2);
%     x = x./24;
%     x = sort(x);
%     
%     y = x;
%     y = cumsum(y);
%     y = y./max(y);
%     y = 1 - y;
%     
%     if i == 11 || i == 8 || i == 10 || i == 3 || i == 7 || i == 4
%         ax1 = subplot(1,2,1);
%         hold on
%         scatter(x,y,'DisplayName',Basin_Index{i})
%         set(gca,'xscale','log')
%         xlim([0.005 1000])
%         
%     else
%         ax2 = subplot(1,2,2);
%         hold on
%         scatter(x,y,'DisplayName',Basin_Index{i})
%         set(gca,'xscale','log')
%         xlim([0.005 1000])
%         
%     end
% end
% 
% hold off
% legend(ax1, 'location', 'southwest')
% legend(ax2, 'location', 'southeast')


end

