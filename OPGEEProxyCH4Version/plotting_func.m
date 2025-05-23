function [] = plotting_func(Basin_Index, Basin_Select)

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


csvFileName = 'david_lyon_2015_no_offshore.csv';
file = fopen(csvFileName);
M_US = csvread(csvFileName,0,0);
fclose(file);

load('Basin_Identifier_Export.mat');
M_all = [Prior_12_Oil, Prior_12_Gas, Well_Count];
ind = ismember(Basin_Name, Basin_Index(Basin_Select));
ind = int16(ind);
M_basin = M_all(ind == 1,:);  



cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE\Outputs_flash_2'
FileName = ['sitedata_out.mat'];
load(FileName);
cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE'
sitedata_US = sitedata_All;

cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE\Outputs_flash_2'
FileName = ['sitedata_' Basin_Index{Basin_Select} 'out.mat'];
load(FileName);
cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE'
sitedata_basin = sitedata_All;


cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE\Outputs_flash_2'
FileName = ['Emissionsdata_out.mat'];
load(FileName);
cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE'
Study_US = EmissionsGas + EmissionsOil;

cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE\Outputs_flash_2'
FileName = ['Emissiondata_' Basin_Index{Basin_Select} 'out.mat'];
load(FileName);
cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE'
Study_basin = EmissionsGas + EmissionsOil;



%% Analysis

% productivity distribution

[plot_dat_basin, OPGEE_bin] = di_scrubbing_func(M_basin, Basin_Select, Basin_Index);
[plot_dat_US, OPGEE_bin] = di_scrubbing_func(M_US, Basin_Select, Basin_Index);

clf;
figure(1)
subplot(2,2,1)

legend('-DynamicLegend');
N = 40;
start = 10^-1;
stop = 10^5;
b = 10.^linspace(log10(start),log10(stop),N+1);

h = histogram(plot_dat_basin,b,...
    'Normalization','probability','DisplayStyle','stairs','LineStyle','-','LineWidth',2,'EdgeColor',ColorMat(Basin_Select,:));  %,...
%     'DisplayName', char(Basin_Index(Basin_Select)));
hold on

h = histogram(plot_dat_US,b,...
    'Normalization','probability','DisplayStyle','stairs','LineStyle','-','LineWidth',2,'EdgeColor',[0.66, 0.66, 0.66]);   %,...
%     'DisplayName', 'US ave');


% legend('show');
dim = [.2 .6 .3 .3];
str = sprintf('%s \nn = %d wells', char(Basin_Index(Basin_Select)), length(plot_dat_basin));
a = annotation('textbox',dim,'String',str,'FitBoxToText','on');
a.FontSize = 8;


xlabel({'Wellpad throughput'; '[mscf d^{-1}, log scale]'});
ylabel('Probability');
ylim([0 0.1]);  
set(gca,'xscale','log')
set(gca,'FontSize',9);
set(gca,'FontName','Arial')

subplot(2,2,3)

x = sitedata_basin;
x = x(:,2);
x = x./24;
x = sort(x);

y = x;
y = cumsum(y);
y = y./max(y);
y = 1 - y;
scatter(x,y,10,ColorMat(Basin_Select,:)); %,'DisplayName',Basin_Index{Basin_Select})
hold on

x = sitedata_US;
x = x(:,2);
x = x./24;
x = sort(x);

y = x;
y = cumsum(y);
y = y./max(y);
y = 1 - y;
scatter(x,y,10, [0.66, 0.66, 0.66]); %,'DisplayName','US ave')

set(gca,'xscale','log')
xlim([0.005 1000])
xlabel('CH_{4} per site [kg h^{-1}, log scale]');
ylabel('Fraction total emissions');
set(gca,'FontSize',9);
set(gca,'FontName','Arial');


subplot(2,2,[2 4])


GatherData_US = ...
    [Study_US(6,:) + Study_US(7,:)+ Study_US(16,:);...
     sum(Study_US(1:5,:))+sum(Study_US(8:9,:));...
     sum(Study_US(10:11,:));...
     Study_US(12,:);...
     Study_US(17,:);...
     sum(Study_US(13:14,:));...
     Study_US(15,:)];

GatherData_basin = ...
    [Study_basin(6,:) + Study_basin(7,:)+ Study_basin(16,:);...
     sum(Study_basin(1:5,:))+sum(Study_basin(8:9,:));...
     sum(Study_basin(10:11,:));...
     Study_basin(12,:);...
     Study_basin(17,:);...
     sum(Study_basin(13:14,:));...
     Study_basin(15,:)];

 GatherData_US_ave = mean(GatherData_US,2);
 GatherData_basin_ave = mean(GatherData_basin,2);
 
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

up = ceil(sum(GatherData_basin_ave(1:5)) * 10) / 10;

xlim([0 3])
ylim([0 up])
ylabel('[Tg CH_{4} yr^{-1}]');
set(gca,'FontSize',9);
set(gca,'FontName','Arial');

set(figure(1),'PaperUnits','inches','PaperPosition',[0 0 8 5.5])

cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE\Outputs_flash_2'
FileName = ['plot_' Basin_Index{Basin_Select} 'out.emf'];
print('-painters','-dmeta',FileName);
cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE'
   

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

