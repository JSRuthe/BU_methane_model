function [tranche_OPGEE] = tranche_gen_func(Basin_Select, Basin_Index)


%% Import data

% LU Types for year 2015 based on 2020 GHGI
LU_type = importdata('LU_type.csv');
% Gas composition
% C1_frac = importdata('C1_frac.csv');

if Basin_Select == 0
    LU_type = [0.1036 0.0714 0.825];
    % C1 frac adjusted in function
%     C1_frac = 0;    
else
    LU_type = LU_type(Basin_Select, :);
%     C1_frac = C1_frac(Basin_Select,:);
end


if Basin_Select == 0
    csvFileName = 'david_lyon_2015_no_offshore.csv';
    file = fopen(csvFileName);
    M_in = csvread(csvFileName,0,0);
    fclose(file);
else
    load('Basin_Identifier_Export.mat');
end


%% Analysis

if Basin_Select ~= 0

    logind = ismember(Basin_Name, Basin_Index{Basin_Select});
    M_all = [Prior_12_Oil, Prior_12_Gas, Well_Count];
    ind = logind;
    ind = int16(ind);
    M_in = M_all(ind == 1,:);
end

[plot_dat, OPGEE_bin] = di_scrubbing_func(M_in, Basin_Select, Basin_Index);
[tranche_OPGEE] = OPGEE_rows_func(Basin_Select, OPGEE_bin, LU_type);


%% UNUSED PLOTTING CODE


% figure(1)
% hold on
%     ColorMat = [140/255,21/255,21/255;...%Stanford red
%                 233/255,131/255,0/255;...% Stanford orange
%                 234/255,171/255,0/255;...% Stanford yello
%                 0/255,155/255,118/255;...% Stanford light green
%                 23/255,94/255,84/255;... % Stanford dark green
%                 0/255,152/255,219/255;...% Stanford blue
%                 83/255,40/255,79/255;... % Stanford purple
%                 0.66, 0.66, 0.66;...
%                 140/255,21/255,21/255;...%Stanford red
%                 233/255,131/255,0/255;...% Stanford orange
%                 234/255,171/255,0/255;...% Stanford yello
%                 0/255,155/255,118/255;...% Stanford light green
%                 23/255,94/255,84/255;... % Stanford dark green
%                 0/255,152/255,219/255];
%     
% for i = 1:length(Basin_Index)
%     ind = logind(:,i);
%     ind = int16(ind);
%     M_in = M_all(ind == 1,:);  
%    [plot_dat, OPGEE_bin] = di_scrubbing_func(M_in, Basin_Index(i));
%    [tranche_OPGEE] = OPGEE_rows_func(OPGEE_bin, Basin_Index(i), LU_type(i,:), C1_frac(i));
%    
%    Plotting
%     legend('-DynamicLegend');
%     N = 40;
%     start = 10^-1;
%     stop = 10^5;
%     b = 10.^linspace(log10(start),log10(stop),N+1);
% 
%     h = histogram(plot_dat,b,...
%         'Normalization','probability','DisplayStyle','stairs','LineStyle','-','LineWidth',2,'EdgeColor',ColorMat(i,:),...
%         'DisplayName', char(Basin_Index(i)));
%     legend('show');
% end
% 
% set(gca,'FontSize',10);
% set(gca,'FontName','Arial')
% ylabel('Probability');
% ylim([0 0.1]);  
% set(gca,'xscale','log')
% 
% 
% 
% end
end
