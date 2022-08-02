%
% Note:
% - Script cannot be run all at once
%   (1) Set to gas - run equipment leaks
%   (2) Set to oil - run equipment leaks
%   (3) Set to gas - run liquids unloadings
%   (4) Set to oil - run tank flashing


s = [];
t = [];

% Open either gas or oil CSV file
prod_ind = 2; % 1 = gas, 2 = oil
%csvFileName = 'Gas_OPGEE_mat_22.7.30.csv';
csvFileName = 'Oil_OPGEE_mat_22.7.30.csv';
filepath = fullfile(pwd, csvFileName);
dataraw = importdata(filepath);

if prod_ind == 1
    data = reshape(dataraw,[10000,16,10]);
    tranche_mat = data(:,1:13,:);
    tranche_mat_LUp = data(:,14,:);
    tranche_mat_LUnp = data(:,15,:);
else
    data = reshape(dataraw,[10000,14,10]);
    tranche_mat = data(:,1:13,:);
    tranche_mat = data(:,1:13,:);
    tranche_mat_LUp = 0;
    tranche_mat_LUnp = 0;
end



%Equipment leaks 

% Define colors to use in plots
StanfordRed = [140/255,21/255,21/255]; %Stanford red
StanfordOrange = [233/255,131/255,0/255];% Stanford orange
StanfordYellow = [234/255,171/255,0/255];% Stanford yello
StanfordLGreen = [0/255,155/255,118/255];% Stanford light green
StanfordDGreen = [23/255,94/255,84/255];% Stanford dark green
StanfordBlue = [0/255,152/255,219/255];% Stanford blue
StanfordPurple = [83/255,40/255,79/255];% Stanford purple
Sandstone = [210/255,194/255,149/255];
LightGrey = [0.66, 0.66, 0.66];
Black = [46/255, 46/255, 41/255];


ColorMat = [StanfordRed; ...
            StanfordOrange;...
            StanfordYellow;...
            StanfordLGreen;...
            StanfordDGreen;...
            StanfordBlue;...
            StanfordPurple; ...
            Sandstone; ....
            LightGrey;...
            Black];

figure(1)

counter = 1;
color = StanfordRed;
vectot = tranche_mat(:,:,2);
[s, t] = plot_loss_rates(s, t, counter, vectot, prod_ind, color);

counter = 4;
color = StanfordOrange;
vectot = tranche_mat(:,:,4);
[s, t] = plot_loss_rates(s, t, counter, vectot, prod_ind, color);

counter = 6;
color = StanfordPurple;
vectot = tranche_mat(:,:,6);
[s, t] = plot_loss_rates(s, t, counter, vectot, prod_ind, color);

counter = 9;
color = LightGrey;
vectot = tranche_mat(:,:,9);
[s, t] = plot_loss_rates(s, t, counter, vectot, prod_ind, color);

set(figure(1),'PaperUnits','inches','PaperPosition',[0 0 8 5.5])
print('-painters','-dmeta','Equipment_Leaks_Oil_22731.emf');

%% Tanks plots

% Define colors to use in plots
StanfordRed = [140/255,21/255,21/255]; %Stanford red
StanfordOrange = [233/255,131/255,0/255];% Stanford orange
StanfordYellow = [234/255,171/255,0/255];% Stanford yello
StanfordLGreen = [0/255,155/255,118/255];% Stanford light green
StanfordDGreen = [23/255,94/255,84/255];% Stanford dark green
StanfordBlue = [0/255,152/255,219/255];% Stanford blue
StanfordPurple = [83/255,40/255,79/255];% Stanford purple
Sandstone = [210/255,194/255,149/255];
LightGrey = [0.66, 0.66, 0.66];
Black = [46/255, 46/255, 41/255];

% Fraction of total gas based on productivity tranches for oil wells.
% We 
frac_total_gas = [0.002, 0.009, 0.010, 0.019, 0.051, 0.067, 0.265, 0.143, 0.282, 0.152];
cum_frac = cumsum(frac_total_gas);
n_reals = 10000;

for i = 1:n_reals
    rand_draw = rand;
    RandomIndex = ceil(rand*10000);
    if rand_draw <= cum_frac(1)
        % Tranche 1
        EF_vec(i) = tranche_mat(RandomIndex,13,1);
    elseif rand_draw > cum_frac(1) && rand_draw <= cum_frac(2)
        % Tranche 2
        EF_vec(i) = tranche_mat(RandomIndex,13,2);
    elseif rand_draw > cum_frac(2) && rand_draw <= cum_frac(3)
        % Tranche 3
        EF_vec(i) = tranche_mat(RandomIndex,13,3);
    elseif rand_draw > cum_frac(3) && rand_draw <= cum_frac(4)
        % Tranche 4
        EF_vec(i) = tranche_mat(RandomIndex,13,4);
    elseif rand_draw > cum_frac(4) && rand_draw <= cum_frac(5)
        % Tranche 5
        EF_vec(i) = tranche_mat(RandomIndex,13,5);
    elseif rand_draw > cum_frac(5) && rand_draw <= cum_frac(6)
        % Tranche 6
        EF_vec(i) = tranche_mat(RandomIndex,13,6);
    elseif rand_draw > cum_frac(6) && rand_draw <= cum_frac(7)
        % Tranche 7
        EF_vec(i) = tranche_mat(RandomIndex,13,7);
    elseif rand_draw > cum_frac(7) && rand_draw <= cum_frac(8)
        % Tranche 8
        EF_vec(i) = tranche_mat(RandomIndex,13,8);
    elseif rand_draw > cum_frac(8) && rand_draw <= cum_frac(9)
        % Tranche 9
        EF_vec(i) = tranche_mat(RandomIndex,13,9);
    elseif rand_draw > cum_frac(9) && rand_draw <= cum_frac(10)
        % Tranche 10
        EF_vec(i) = tranche_mat(RandomIndex,13,10);
    end
end

EF_vec_init = EF_vec;
EF_vec_control = EF_vec .* (0.25/0.51);
EF_vec_nocontrol = EF_vec .* (0.75/0.51);

figure(1)
    h = cdfplot(EF_vec_init);
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', StanfordRed);
    hold on
    
    h = cdfplot(EF_vec_control);
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', StanfordOrange);
    
    h = cdfplot(EF_vec_nocontrol);
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', LightGrey);
    
    grid('off')   
    title('');
    xlabel('');
    ylabel('');
    
    set(gca,'YLim',[0.5 1]);
    set(gca, 'XScale', 'log');
    set(gca,'FontSize',10)
    set(gca,'FontName','Arial')
    set(gca,'XTick',[10^-3 10^-2 10^-1 10^0 10^1]);
    set(gca,'XTickLabel',{'0.001', '0.01', '0.1', '1', '10'});
    set(gca,'XMinorTick','off','YMinorTick','off')
    set(gca,'TickDir', 'out')
    set(gca,'TickLength',[0.01 0.01])
    
    grid(gca,'off')
    set(gca,'XMinorGrid','off');
    axis_a = gca;
    % set box property to off and remove background color
    set(axis_a,'box','off','color','none')
    % create new, empty axes with box but without ticks
    axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active
    axes(axis_a)
    % link axes in case of zooming
    linkaxes([axis_a axis_b])

    xlabel('Flash factor [kg CH_{4} bbl^{-1}]');
    ylabel('Probability');
    set(gca,'YLim',[0.5 1]);
    set(gca,'XLim',[0.001 10.1])
    
    set(figure(1),'PaperUnits','inches','PaperPosition',[0 0 8 5.5])
    print('-painters','-dmeta','Tank_Flashing_22731.emf');
    
    
%% Liquids unloadings plots

% Define colors to use in plots
StanfordRed = [140/255,21/255,21/255]; %Stanford red
StanfordOrange = [233/255,131/255,0/255];% Stanford orange
StanfordYellow = [234/255,171/255,0/255];% Stanford yello
StanfordLGreen = [0/255,155/255,118/255];% Stanford light green
StanfordDGreen = [23/255,94/255,84/255];% Stanford dark green
StanfordBlue = [0/255,152/255,219/255];% Stanford blue
StanfordPurple = [83/255,40/255,79/255];% Stanford purple
Sandstone = [210/255,194/255,149/255];
LightGrey = [0.66, 0.66, 0.66];
Black = [46/255, 46/255, 41/255];

% Fraction of total gas based on productivity tranches for oil wells.
% We 
frac_total_gas = [0.002, 0.009, 0.010, 0.019, 0.051, 0.067, 0.265, 0.143, 0.282, 0.152];
cum_frac = cumsum(frac_total_gas);
n_reals = 10000;

for i = 1:n_reals
    rand_draw = rand;
    RandomIndex = ceil(rand*10000);
    if rand_draw <= cum_frac(1)
        % Tranche 1
        EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,1);
        EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,1);
    elseif rand_draw > cum_frac(1) && rand_draw <= cum_frac(2)
        % Tranche 2
        EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,2);
        EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,2);
    elseif rand_draw > cum_frac(2) && rand_draw <= cum_frac(3)
        % Tranche 3
        EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,3);
        EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,3);
    elseif rand_draw > cum_frac(3) && rand_draw <= cum_frac(4)
        %Tranche 4
        EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,4);
        EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,4);
    elseif rand_draw > cum_frac(4) && rand_draw <= cum_frac(5)
        % Tranche 5
        EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,5);
        EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,5);
    elseif rand_draw > cum_frac(5) && rand_draw <= cum_frac(6)
        % Tranche 6
        EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,6);
        EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,6);
    elseif rand_draw > cum_frac(6) && rand_draw <= cum_frac(7)
        % Tranche 7
        EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,7);
        EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,7);
    elseif rand_draw > cum_frac(7) && rand_draw <= cum_frac(8)
        % Tranche 8
        EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,8);
        EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,8);
    elseif rand_draw > cum_frac(8) && rand_draw <= cum_frac(9)
        % Tranche 9
        EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,9);
        EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,9);
    elseif rand_draw > cum_frac(9) && rand_draw <= cum_frac(10)
        % Tranche 10
        EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,10);
        EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,10);
    end
end

EF_vec_LUp_init = EF_vec_LUp;
EF_vec_LUp_control = EF_vec_LUp .* 0.1;
EF_vec_LUp_nocontrol = EF_vec_LUp .* 0.01;

EF_vec_LUnp_init = EF_vec_LUnp;
EF_vec_LUnp_control = EF_vec_LUnp .* 0.1;
EF_vec_LUnp_nocontrol = EF_vec_LUnp .* 0.01;

figure(1)
subplot(1,2,1)
    h = cdfplot(EF_vec_LUp_init);
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', StanfordRed);
    hold on
    
    h = cdfplot(EF_vec_LUp_control);
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', StanfordOrange);
    
    h = cdfplot(EF_vec_LUp_nocontrol);
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', LightGrey);
    
    grid('off')   
    title('');
    xlabel('');
    ylabel('');
    
    set(gca, 'XScale', 'log');
    set(gca,'FontSize',10)
    set(gca,'FontName','Arial')
    set(gca,'XTick',[10^-5 10^-3 10^-1 10^0]);
    set(gca,'XTickLabel',{'0.001%', '0.1%', '10%', '100%'});
    set(gca,'XMinorTick','off','YMinorTick','off')
    set(gca,'TickDir', 'out')
    set(gca,'TickLength',[0.01 0.01])
    
    grid(gca,'off')
    set(gca,'XMinorGrid','off');
    axis_a = gca;
    % set box property to off and remove background color
    set(axis_a,'box','off','color','none')
    % create new, empty axes with box but without ticks
    axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active
    axes(axis_a)
    % link axes in case of zooming
    linkaxes([axis_a axis_b])
    set(gca,'YLim',[0.5 1]);
    set(gca,'XLim',[0.00001 1.1])
    xlabel('Loss rate');
    ylabel('Probability');
subplot(1,2,2)
    h = cdfplot(EF_vec_LUnp_init);
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', StanfordRed);
    hold on
    
    h = cdfplot(EF_vec_LUnp_control);
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', StanfordOrange);
    
    h = cdfplot(EF_vec_LUnp_nocontrol);
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', LightGrey);
    
    grid('off')   
    title('');
    xlabel('');
    ylabel('');
    
    set(gca, 'XScale', 'log');
    set(gca,'FontSize',10)
    set(gca,'FontName','Arial')
    set(gca,'XTick',[10^-5 10^-3 10^-1 10^0]);
    set(gca,'XTickLabel',{'0.001%', '0.1%', '10%', '100%'});
    set(gca,'XMinorTick','off','YMinorTick','off')
    set(gca,'TickDir', 'out')
    set(gca,'TickLength',[0.01 0.01])
    
    grid(gca,'off')
    set(gca,'XMinorGrid','off');
    axis_a = gca;
    % set box property to off and remove background color
    set(axis_a,'box','off','color','none')
    % create new, empty axes with box but without ticks
    axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active
    axes(axis_a)
    % link axes in case of zooming
    linkaxes([axis_a axis_b])
    set(gca,'YLim',[0.5 1]);
    set(gca,'XLim',[0.00001 1.1])
    xlabel('Loss rate');
    ylabel('Probability');

     

    set(figure(1),'PaperUnits','inches','PaperPosition',[0 0 8 5.5])
    print('-painters','-dmeta','Liquid_Unloadings_22731.emf');
