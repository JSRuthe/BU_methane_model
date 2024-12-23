function [s, t, vectot] = OPGEE_Fast_Bins_v8(s, t, counter_2, vectot, plotting, prod_ind)

%% EQUIPMENT-LEVEL EMISSIONS FACTOR PLOTTING SCRIPT


    % Set up bins
    N = 80;
    start = 10^-5;
    stop = 10^5;
    b = 10.^linspace(log10(start),log10(stop),N+1);

    N = 40;
    start = 10^-5;
    stop = 10^5;
    c = 10.^linspace(log10(start),log10(stop),N+1);
    
    
% if counter_2 == 1   
%     s       = [];
%     counter = 1;
%     bottom = 0.72;
%     
%     for jj = 1:3
%         left = 0.07;
%         
%         if jj == 4
%             s(counter) = axes('Position', [left, bottom, 0.18, 0.25], ...
%                 'NextPlot', 'add');
%             left = left + 0.24;
%             counter = counter + 1;
%             break;
%         end
%         
%         for ii = 1:4
%             s(counter) = axes('Position', [left, bottom, 0.18, 0.25], ...
%                 'NextPlot', 'add');
%             left = left + 0.24;
%             counter = counter + 1;
%         end
%         bottom = bottom - 0.32;
%     end
% end


%% NORMALIZE VECTORS

    for i = 1:14
        vectot(:,i) = vectot(:,i)./vectot(:,18);
    end

    % Calculate flash factor
    
%     vectot(:,15) = vectot(:,15)./vectot(:,20);
    
    % Note that we're only interested in columns 1 - 11 (wells to PCs)

    vectot(:,20) = sum(vectot(:,1:11),2);   

if plotting == 1

    %% FIGURE 1
    
    figure(1)
    
   
    % (1) Wells
    
    h = cdfplot(vectot(:,1));
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', color, 'Parent', s(1));
    grid('off')
    set(s(1),'YLim',[0 1])
   set(s(1),'XLim',[0.001 1.1])
   
    title('');
    xlabel('');
    ylabel('');
    
    set(s(1), 'XScale', 'log');
    set(s(1),'FontSize',7)
    set(s(1),'FontName','Arial')
    set(s(1),'XTick',[10^-3 10^-2 10^-1 1]);
    set(s(1),'XTickLabel',{'0.1%', '1%', '10%', '100%'});
    set(s(1),'XMinorTick','off','YMinorTick','off')
    set(s(1), 'TickDir', 'out')
    set(s(1),'TickLength',[0.03 0.035])

    set(s(1),'XMinorGrid','off');
    axis_a = s(1);
    % set box property to off and remove background color
    set(axis_a,'box','off','color','none')
    % create new, empty axes with box but without ticks
    axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active
    axes(axis_a)
    % link axes in case of zooming
    linkaxes([axis_a axis_b])
    set(s(1),'YLim',[0 1])
    set(s(1),'XLim',[0.001 1.1])

    
    % (2) Separators
    
    h = cdfplot(vectot(:,4));
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', color, 'Parent', s(2));
    set(s(2),'YLim',[0 1])
    set(s(2),'XLim',[0.001 1.1])
    
    grid('off')   
    title('');
    xlabel('');
    ylabel('');
    
    set(s(2), 'XScale', 'log');
    set(s(2),'FontSize',7)
    set(s(2),'FontName','Arial')
    set(s(2),'XTick',[10^-3 10^-2 10^-1 1]);
    set(s(2),'XTickLabel',{'0.1%', '1%', '10%', '100%'});
    set(s(2),'XMinorTick','off','YMinorTick','off')
    set(s(2), 'TickDir', 'out')
    set(s(2),'TickLength',[0.03 0.035])

    grid(s(2),'off')
    set(s(2),'XMinorGrid','off');
    axis_a = s(2);
    % set box property to off and remove background color
    set(axis_a,'box','off','color','none')
    % create new, empty axes with box but without ticks
    axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active
    axes(axis_a)
    % link axes in case of zooming
    linkaxes([axis_a axis_b])
    set(s(2),'YLim',[0 1])
    set(s(2),'XLim',[0.001 1.1])
    
    % (3) Dehydrator
    
    h = cdfplot(vectot(:,9));
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', color, 'Parent', s(3));
    set(s(3),'YLim',[0 1])
    set(s(3),'XLim',[0.001 1.1])
    
    grid('off')   
    title('');
    xlabel('');
    ylabel('');
    
    set(s(3), 'XScale', 'log');
    set(s(3),'FontSize',7)
    set(s(3),'FontName','Arial')
    set(s(3),'XTick',[10^-3 10^-2 10^-1 1]);
    set(s(3),'XTickLabel',{'0.1%', '1%', '10%', '100%'});
    set(s(3),'XMinorTick','on','YMinorTick','on')
    set(s(3), 'TickDir', 'out')
    set(s(3),'TickLength',[0.03 0.035])

    grid(s(3),'off')
    set(s(3),'XMinorGrid','off');
    axis_a = s(3);
    % set box property to off and remove background color
    set(axis_a,'box','off','color','none')
    % create new, empty axes with box but without ticks
    axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active
    axes(axis_a)
    % link axes in case of zooming
    linkaxes([axis_a axis_b])
    set(s(3),'YLim',[0 1])
    set(s(3),'XLim',[0.001 1.1])
    
    % (4) Meter
    
    h = cdfplot(vectot(:,5));
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', color, 'Parent', s(4));
    set(s(4),'YLim',[0 1])
    set(s(4),'XLim',[0.001 1.1])
    grid('off')   
    title('');
    xlabel('');
    ylabel('');
    
    set(s(4), 'XScale', 'log');
    set(s(4),'FontSize',7)
    set(s(4),'FontName','Arial')
    set(s(4),'XTick',[10^-3 10^-2 10^-1 1]);
    set(s(4),'XTickLabel',{'0.1%', '1%', '10%', '100%'});
    set(s(4),'XMinorTick','on','YMinorTick','on')
    set(s(4), 'TickDir', 'out')
    set(s(4),'TickLength',[0.03 0.035])

    grid(s(4),'off')
    set(s(4),'XMinorGrid','off');
    axis_a = s(4);
    % set box property to off and remove background color
    set(axis_a,'box','off','color','none')
    % create new, empty axes with box but without ticks
    axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active
    axes(axis_a)
    % link axes in case of zooming
    linkaxes([axis_a axis_b])
    set(s(4),'YLim',[0 1])
    set(s(4),'XLim',[0.001 1.1])
    
    % (5) Pneumatic controllers
    
    h = cdfplot(vectot(:,11));
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', color, 'Parent', s(5));
    set(s(5),'YLim',[0 1])
    set(s(5),'XLim',[0.001 1.1])

    grid('off')   
    title('');
    xlabel('');
    ylabel('');
    
    set(s(5), 'XScale', 'log');
    set(s(5),'FontSize',7)
    set(s(5),'FontName','Arial')
    set(s(5),'XTick',[10^-3 10^-2 10^-1 1]);
    set(s(5),'XTickLabel',{'0.1%', '1%', '10%', '100%'});
    set(s(5),'XMinorTick','on','YMinorTick','on')
    set(s(5), 'TickDir', 'out')
    set(s(5),'TickLength',[0.03 0.035])

    grid(s(5),'off')
    set(s(5),'XMinorGrid','off');
    axis_a = s(6);
    % set box property to off and remove background color
    set(axis_a,'box','off','color','none')
    % create new, empty axes with box but without ticks
    axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active
    axes(axis_a)
    % link axes in case of zooming
    linkaxes([axis_a axis_b])
    set(s(5),'YLim',[0 1])
    set(s(5),'XLim',[0.001 1.1])
    
    % (6) Tank - leaks

    h = cdfplot(vectot(:,6));
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', color, 'Parent', s(6));
    set(s(6),'YLim',[0 1])
    set(s(6),'XLim',[0.001 1.1])

    grid('off')   
    title('');
    xlabel('');
    ylabel('');
    
    set(s(6), 'XScale', 'log');
    set(s(6),'FontSize',7)
    set(s(6),'FontName','Arial')
    set(s(6),'XTick',[10^-3 10^-2 10^-1 1]);
    set(s(6),'XTickLabel',{'0.1%', '1%', '10%', '100%'});
    set(s(6),'XMinorTick','on','YMinorTick','on')
    set(s(6), 'TickDir', 'out')
    set(s(6),'TickLength',[0.03 0.035])

    grid(s(6),'off')
    set(s(6),'XMinorGrid','off');
    axis_a = s(6);
    % set box property to off and remove background color
    set(axis_a,'box','off','color','none')
    % create new, empty axes with box but without ticks
    axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active
    axes(axis_a)
    % link axes in case of zooming
    linkaxes([axis_a axis_b])
    set(s(6),'YLim',[0 1])
    set(s(6),'XLim',[0.001 1.1])
    
    % (7) Tank - thief hatches
    
    h = cdfplot(vectot(:,7));
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', color, 'Parent', s(7));
    set(s(7),'YLim',[0 1])
    set(s(7),'XLim',[0.001 1.1])

    grid('off')   
    title('');
    xlabel('');
    ylabel('');
    
    set(s(7), 'XScale', 'log');
    set(s(7),'FontSize',7)
    set(s(7),'FontName','Arial')
    set(s(7),'XTick',[10^-3 10^-2 10^-1 1]);
    set(s(7),'XTickLabel',{'0.1%', '1%', '10%', '100%'});
    set(s(7),'XMinorTick','on','YMinorTick','on')
    set(s(7),'TickDir', 'out')
    set(s(7),'TickLength',[0.03 0.035])

    grid(s(7),'off')
    set(s(7),'XMinorGrid','off');
    axis_a = s(7);
    % set box property to off and remove background color
    set(axis_a,'box','off','color','none')
    % create new, empty axes with box but without ticks
    axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active
    axes(axis_a)
    % link axes in case of zooming
    linkaxes([axis_a axis_b])
    set(s(7),'YLim',[0 1])
    set(s(7),'XLim',[0.001 1.1])
    
    % (8) Tank - flashing
    
    h = cdfplot(vectot(:,15));
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', color, 'Parent', s(8));
    set(s(8),'YLim',[0 1])
    set(s(8),'XLim',[0.001 1.1])

    grid('off')   
    title('');
    xlabel('');
    ylabel('');
    
    set(s(8), 'XScale', 'log');
    set(s(8),'FontSize',7)
    set(s(8),'FontName','Arial')
    set(s(8),'XTick',[10^-3 10^-2 10^-1 1]);
    set(s(8),'XTickLabel',{'0.1%', '1%', '10%', '100%'});
    set(s(8),'XMinorTick','on','YMinorTick','on')
    set(s(8), 'TickDir', 'out')
    set(s(8),'TickLength',[0.03 0.035])

    grid(s(8),'off')
    set(s(8),'XMinorGrid','off');
    axis_a = s(8);
    % set box property to off and remove background color
    set(axis_a,'box','off','color','none')
    % create new, empty axes with box but without ticks
    axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active
    axes(axis_a)
    % link axes in case of zooming
    linkaxes([axis_a axis_b])
    set(s(8),'YLim',[0 1])
    set(s(8),'XLim',[0.001 1.1])
    
    % (9) Heater
    
    h = cdfplot(vectot(:,3));
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', color, 'Parent', s(9));
    set(s(9),'YLim',[0 1])
    set(s(9),'XLim',[0.001 1.1])
    
    grid('off')   
    title('');
    xlabel('');
    ylabel('');
    
    set(s(9), 'XScale', 'log');
    set(s(9),'FontSize',7)
    set(s(9),'FontName','Arial')
    set(s(9),'XTick',[10^-3 10^-2 10^-1 1]);
    set(s(9),'XTickLabel',{'0.1%', '1%', '10%', '100%'});
    set(s(9),'XMinorTick','on','YMinorTick','on')
    set(s(9),'TickDir', 'out')
    set(s(9),'TickLength',[0.03 0.035])

    grid(s(9),'off')
    set(s(9),'XMinorGrid','off');
    axis_a = s(9);
    % set box property to off and remove background color
    set(axis_a,'box','off','color','none')
    % create new, empty axes with box but without ticks
    axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active
    axes(axis_a)
    % link axes in case of zooming
    linkaxes([axis_a axis_b])
    set(s(9),'YLim',[0 1])
    set(s(9),'XLim',[0.001 1.1])
    
    % (10) REcip (gas) or Header (oil)
    if prod_ind == 1
        h = cdfplot(vectot(:,8));
    else
        h = cdfplot(vectot(:,2));
    end
    
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', color, 'Parent', s(10));
    set(s(10),'YLim',[0 1])
    set(s(10),'XLim',[0.001 1.1])
    
    grid('off')   
    title('');
    xlabel('');
    ylabel('');
    
    set(s(10), 'XScale', 'log');
    set(s(10),'FontSize',7)
    set(s(10),'FontName','Arial')
    set(s(10),'XTick',[10^-3 10^-2 10^-1 1]);
    set(s(10),'XTickLabel',{'0.1%', '1%', '10%', '100%'});
    set(s(10),'XMinorTick','on','YMinorTick','on')
    set(s(10),'TickDir', 'out')
    set(s(10),'TickLength',[0.03 0.035])

    grid(s(10),'off')
    set(s(10),'XMinorGrid','off');
    axis_a = s(10);
    % set box property to off and remove background color
    set(axis_a,'box','off','color','none')
    % create new, empty axes with box but without ticks
    axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active
    axes(axis_a)
    % link axes in case of zooming
    linkaxes([axis_a axis_b])
    set(s(10),'YLim',[0 1])
    set(s(10),'XLim',[0.001 1.1])

    % (11) Liquids unloadings
    
    h = cdfplot(vectot(:,12));
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', color, 'Parent', s(11));
    set(s(11),'YLim',[0 1])
    set(s(11),'XLim',[0.001 1.1])
    
    grid('off')   
    title('');
    xlabel('');
    ylabel('');
    
    set(s(11), 'XScale', 'log');
    set(s(11),'FontSize',7)
    set(s(11),'FontName','Arial')
    set(s(11),'XTick',[10^-3 10^-2 10^-1 1]);
    set(s(11),'XTickLabel',{'0.1%', '1%', '10%', '100%'});
    set(s(11),'XMinorTick','on','YMinorTick','on')
    set(s(11),'TickDir', 'out')
    set(s(11),'TickLength',[0.03 0.035])

    grid(s(11),'off')
    set(s(11),'XMinorGrid','off');
    axis_a = s(11);
    % set box property to off and remove background color
    set(axis_a,'box','off','color','none')
    % create new, empty axes with box but without ticks
    axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active
    axes(axis_a)
    % link axes in case of zooming
    linkaxes([axis_a axis_b])
    set(s(11),'YLim',[0 1])
    set(s(11),'XLim',[0.001 1.1])
    
    
    % (12) Total

%     histogram(vectot(:,19),b,'Normalization','cdf','DisplayStyle','stairs','LineStyle','-','LineWidth',1.5,'EdgeColor',color, 'Parent', s(11));

    h = cdfplot(vectot(:,19));
    set( h, 'LineStyle', '-','LineWidth',1.5,'Color', color, 'Parent', s(12));
     set(s(12),'YLim',[0 1])
    set(s(12),'XLim',[0.001 1.1])
    
    grid('off')   
    title('');
    xlabel('');
    ylabel('');
     
    set(s(12), 'XScale', 'log');
    set(s(12),'FontSize',7)
    set(s(12),'FontName','Arial')
    set(s(12),'XTick',[10^-3 10^-2 10^-1 1]);
    set(s(12),'XTickLabel',{'0.1%', '1%', '10%', '100%'});
    set(s(12),'XMinorTick','on','YMinorTick','on')
    set(s(12),'TickDir', 'out')
    set(s(12),'TickLength',[0.03 0.035])
    
    grid(s(12),'off')
    set(s(12),'XMinorGrid','off');
    axis_a = s(12);
    % set box property to off and remove background color
    set(axis_a,'box','off','color','none')
    % create new, empty axes with box but without ticks
    axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
    % set original axes as active
    axes(axis_a)
    % link axes in case of zooming
    linkaxes([axis_a axis_b])
    set(s(12),'YLim',[0 1])
    set(s(12),'XLim',[0.001 1.1])

    
end
    
end

