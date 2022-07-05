function tranche_norm_mean = func_loss_frac_allcolumns(equipdata_tot, prod_ind, j)

%  - - INPUTS - - 

% col 1 - 16 = equipment array
% col 17     = tranche iteration (1-74)
% col 18     = well productivity [kg/well/d]
% col 19     = well productivity [scf/well/d]
% col 20     = oil productivity [bbl/well/d]

% row 1  - Wells
% row 2  - Header
% row 3  - Heater
% row 4  - separators
% row 5  - Meter
% row 6  - Tanks - leaks
% row 7  - Tanks - vents
% row 8  - Recip Compressor
% row 9  - Dehydrators
% row 10 - CIP
% row 11 - PC
% row 12 - LU
% row 13 - Completions
% row 14 - Workovers
% row 15 - Tank Venting
% row 16 - Flaring methane (ignore in this analysis)

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

gasvectot = zeros(1,1);
oilvectot = zeros(1,1);

sampling = 1;
plotting = 1;
counter = 0;
s = [];
t = [];


%(i) Separate by categories

if prod_ind == 1
    vec = vertcat(equipdata_tot.drygas(:,:,j), equipdata_tot.gaswoil(:,:,j));
else
    vec = vertcat(equipdata_tot.oil(:,:,j), equipdata_tot.assoc(:,:,j));
end

% Vlookup for oil production

oil_prod_tranches = importdata('oil_prod_tranches.csv');
oil_prod_tranches = oil_prod_tranches.data;
%vec(:,20) = oil_prod_tranches((oil_prod_tranches(:,1)==vec(:,17)),2);

[tf, idx] = ismember(vec(:,17), oil_prod_tranches(:,1));
vec(:,20) = oil_prod_tranches(idx(tf),2);

ind.i1 = vec(:,19) < 1000;
ind.i2 = vec(:,19) > 1000 & vec(:,19) < 5000;
ind.i3 = vec(:,19) > 5000 & vec(:,19) < 10000;
ind.i4 = vec(:,19) > 10000 & vec(:,19) < 20000;
ind.i5 = vec(:,19) > 20000 & vec(:,19) < 50000;
ind.i6 = vec(:,19) > 50000 & vec(:,19) < 100000;
ind.i7 = vec(:,19) > 100000 & vec(:,19) < 500000;
ind.i8 = vec(:,19) > 500000 & vec(:,19) < 1000000;
ind.i9 = vec(:,19) > 1000000 & vec(:,19) < 10000000;
ind.i10 = vec(:,19) > 10000000;

tranche.i1 = vec(ind.i1,:);
tranche.i2 = vec(ind.i2,:);
tranche.i3 = vec(ind.i3,:);
tranche.i4 = vec(ind.i4,:);
tranche.i5 = vec(ind.i5,:);
tranche.i6 = vec(ind.i6,:);
tranche.i7 = vec(ind.i7,:);
tranche.i8 = vec(ind.i8,:);
tranche.i9 = vec(ind.i9,:);
tranche.i10 = vec(ind.i10,:);
tranche.none = vec;

% Liquids unloading - plunger
if prod_ind == 1
    plunger = [1:3:58];

    ind_LUp.i1 = vec(:,19) < 1000 & ismember(vec(:,17),plunger);
    ind_LUp.i2 = vec(:,19) > 1000 & vec(:,19) < 5000 & ismember(vec(:,17),plunger);
    ind_LUp.i3 = vec(:,19) > 5000 & vec(:,19) < 10000 & ismember(vec(:,17),plunger);
    ind_LUp.i4 = vec(:,19) > 10000 & vec(:,19) < 20000 & ismember(vec(:,17),plunger);
    ind_LUp.i5 = vec(:,19) > 20000 & vec(:,19) < 50000 & ismember(vec(:,17),plunger);
    ind_LUp.i6 = vec(:,19) > 50000 & vec(:,19) < 100000 & ismember(vec(:,17),plunger);
    ind_LUp.i7 = vec(:,19) > 100000 & vec(:,19) < 500000 & ismember(vec(:,17),plunger);
    ind_LUp.i8 = vec(:,19) > 500000 & vec(:,19) < 1000000 & ismember(vec(:,17),plunger);
    ind_LUp.i9 = vec(:,19) > 1000000 & vec(:,19) < 10000000 & ismember(vec(:,17),plunger);
    ind_LUp.i10 = vec(:,19) > 10000000 & ismember(vec(:,17),plunger);

    tranche_LUp.i1 = vec(ind_LUp.i1,:);
    tranche_LUp.i2 = vec(ind_LUp.i2,:);
    tranche_LUp.i3 = vec(ind_LUp.i3,:);
    tranche_LUp.i4 = vec(ind_LUp.i4,:);
    tranche_LUp.i5 = vec(ind_LUp.i5,:);
    tranche_LUp.i6 = vec(ind_LUp.i6,:);
    tranche_LUp.i7 = vec(ind_LUp.i7,:);
    tranche_LUp.i8 = vec(ind_LUp.i8,:);
    tranche_LUp.i9 = vec(ind_LUp.i9,:);
    tranche_LUp.i10 = vec(ind_LUp.i10,:);

    % Liquids unloading - no plunger

    no_plunger = [2:3:59];

    ind_LUnp.i1 = vec(:,19) < 1000 & ismember(vec(:,17),no_plunger);
    ind_LUnp.i2 = vec(:,19) > 1000 & vec(:,19) < 5000 & ismember(vec(:,17),no_plunger);
    ind_LUnp.i3 = vec(:,19) > 5000 & vec(:,19) < 10000 & ismember(vec(:,17),no_plunger);
    ind_LUnp.i4 = vec(:,19) > 10000 & vec(:,19) < 20000 & ismember(vec(:,17),no_plunger);
    ind_LUnp.i5 = vec(:,19) > 20000 & vec(:,19) < 50000 & ismember(vec(:,17),no_plunger);
    ind_LUnp.i6 = vec(:,19) > 50000 & vec(:,19) < 100000 & ismember(vec(:,17),no_plunger);
    ind_LUnp.i7 = vec(:,19) > 100000 & vec(:,19) < 500000 & ismember(vec(:,17),no_plunger);
    ind_LUnp.i8 = vec(:,19) > 500000 & vec(:,19) < 1000000 & ismember(vec(:,17),no_plunger);
    ind_LUnp.i9 = vec(:,19) > 1000000 & vec(:,19) < 10000000 & ismember(vec(:,17),no_plunger);
    ind_LUnp.i10 = vec(:,19) > 10000000 & ismember(vec(:,17),no_plunger);

    tranche_LUnp.i1 = vec(ind_LUnp.i1,:);
    tranche_LUnp.i2 = vec(ind_LUnp.i2,:);
    tranche_LUnp.i3 = vec(ind_LUnp.i3,:);
    tranche_LUnp.i4 = vec(ind_LUnp.i4,:);
    tranche_LUnp.i5 = vec(ind_LUnp.i5,:);
    tranche_LUnp.i6 = vec(ind_LUnp.i6,:);
    tranche_LUnp.i7 = vec(ind_LUnp.i7,:);
    tranche_LUnp.i8 = vec(ind_LUnp.i8,:);
    tranche_LUnp.i9 = vec(ind_LUnp.i9,:);
    tranche_LUnp.i10 = vec(ind_LUnp.i10,:);
end


    %% SAMPLING

    tranche_sample.i1 = datasample(tranche.i1,10000,'Replace',false);
    tranche_sample.i2 = datasample(tranche.i2,10000,'Replace',false);
    tranche_sample.i3 = datasample(tranche.i3,10000,'Replace',false);
    tranche_sample.i4 = datasample(tranche.i4,10000,'Replace',false);
    tranche_sample.i5 = datasample(tranche.i5,10000,'Replace',false);
    tranche_sample.i6 = datasample(tranche.i6,10000,'Replace',false);
    tranche_sample.i7 = datasample(tranche.i7,10000,'Replace',false);
    tranche_sample.i8 = tranche.i8;
    tranche_sample.i9 = tranche.i9;
    tranche_sample.i10 = tranche.i10;
     tranche_sample.none = datasample(tranche.none,10000,'Replace',false);
    
   
    % Non liquid unloading 
    for i = 1:10
        
            my_field = strcat('i',num2str(i));
            
            % Equipment loss rates
            for i = 1:14
                tranche_sample_norm.(my_field)(:,i) = tranche_sample.(my_field)(:,i)./tranche_sample.(my_field)(:,18);
            end

            % Calculate flash factor
            tranche_sample_norm.(my_field)(:,15) = tranche_sample.(my_field)(:,15)./tranche_sample.(my_field)(:,20);

            % Note that we're only interested in columns 1 - 11 (wells to PCs)
            tranche_sample_norm.(my_field)(:,21) = sum(tranche_sample_norm.(my_field)(:,1:11),2);   
    end

    tranche_sample_norm.i8 = tranche_sample_norm.i8;
     tranche_sample_norm.i8 = [repmat(tranche_sample_norm.i8, floor(10000/size(tranche_sample_norm.i8,1)),1);...
         tranche_sample_norm.i8(1:mod(10000, size(tranche_sample_norm.i8,1)),:)];

    tranche_sample_norm.i9 = tranche_sample_norm.i9;
     tranche_sample_norm.i9 = [repmat(tranche_sample_norm.i9, floor(10000/size(tranche_sample_norm.i9,1)),1);...
         tranche_sample_norm.i9(1:mod(10000, size(tranche_sample_norm.i9,1)),:)];

    tranche_sample_norm.i10 = tranche_sample_norm.i10;
     tranche_sample_norm.i10 = [repmat(tranche_sample_norm.i10, floor(10000/size(tranche_sample_norm.i10,1)),1);...
         tranche_sample_norm.i10(1:mod(10000, size(tranche_sample_norm.i10,1)),:)];

if prod_ind == 1  
    % Liquids unloading - plunger
    
    for i = 1:10

            my_field = strcat('i',num2str(i));        
            counter = i;
            
            tranche_sample_LUp.(my_field) = tranche_LUp.(my_field); 

            % Equipment loss rates
            for i = 1:14
                tranche_sample_norm_LUp.(my_field)(:,i) = tranche_sample_LUp.(my_field)(:,i)./tranche_sample_LUp.(my_field)(:,18);
            end

            % Calculate flash factor
            tranche_sample_norm_LUp.(my_field)(:,15) = tranche_sample_LUp.(my_field)(:,15)./tranche_sample_LUp.(my_field)(:,20);

            % Note that we're only interested in columns 1 - 11 (wells to PCs)
            tranche_sample_norm_LUp.(my_field)(:,21) = sum(tranche_sample_norm_LUp.(my_field)(:,1:11),2);   
            
            tranche_sample_norm_LUp.(my_field) = [repmat(tranche_sample_norm_LUp.(my_field), floor(10000/size(tranche_sample_norm_LUp.(my_field),1)),1);...
            tranche_sample_norm_LUp.(my_field)(1:mod(10000, size(tranche_sample_norm_LUp.(my_field),1)),:)];
    
    end    
    
    % Liquids unloading - non plunger
    
    for i = 1:10

            my_field = strcat('i',num2str(i));        
            counter = i;
            
            tranche_sample_LUnp.(my_field) = tranche_LUnp.(my_field); 

            for i = 1:14
                tranche_sample_norm_LUnp.(my_field)(:,i) = tranche_sample_LUnp.(my_field)(:,i)./tranche_sample_LUnp.(my_field)(:,18);
            end

            % Calculate flash factor
            tranche_sample_norm_LUnp.(my_field)(:,15) = tranche_sample_LUnp.(my_field)(:,15)./tranche_sample_LUnp.(my_field)(:,20);

            % Note that we're only interested in columns 1 - 11 (wells to PCs)
            tranche_sample_norm_LUnp.(my_field)(:,21) = sum(tranche_sample_norm_LUnp.(my_field)(:,1:11),2);   
           
    
            tranche_sample_norm_LUnp.(my_field) = [repmat(tranche_sample_norm_LUnp.(my_field), floor(10000/size(tranche_sample_norm_LUnp.(my_field),1)),1);...
            tranche_sample_norm_LUnp.(my_field)(1:mod(10000, size(tranche_sample_norm_LUnp.(my_field),1)),:)];
        
    end      
end

    tranche_mat = cat(3, tranche_sample_norm.i1(:,[1:11,21,15]), tranche_sample_norm.i2(:,[1:11,21,15]), tranche_sample_norm.i3(:,[1:11,21,15]), ...
        tranche_sample_norm.i4(:,[1:11,21,15]), tranche_sample_norm.i5(:,[1:11,21,15]), tranche_sample_norm.i6(:,[1:11,21,15]), ...
        tranche_sample_norm.i7(:,[1:11,21,15]), tranche_sample_norm.i8(:,[1:11,21,15]), tranche_sample_norm.i9(:,[1:11,21,15]),...
        tranche_sample_norm.i10(:,[1:11,21,15]));

if prod_ind == 1      
    tranche_mat_LUp = cat(3, tranche_sample_norm_LUp.i1(:,12), tranche_sample_norm_LUp.i2(:,12), tranche_sample_norm_LUp.i3(:,12), ...
        tranche_sample_norm_LUp.i4(:,12), tranche_sample_norm_LUp.i5(:,12), tranche_sample_norm_LUp.i6(:,12), ...
        tranche_sample_norm_LUp.i7(:,12), tranche_sample_norm_LUp.i8(:,12), tranche_sample_norm_LUp.i9(:,12),...
        tranche_sample_norm_LUp.i10(:,12));

    tranche_mat_LUnp = cat(3, tranche_sample_norm_LUnp.i1(:,12), tranche_sample_norm_LUnp.i2(:,12), tranche_sample_norm_LUnp.i3(:,12), ...
        tranche_sample_norm_LUnp.i4(:,12), tranche_sample_norm_LUnp.i5(:,12), tranche_sample_norm_LUnp.i6(:,12), ...
        tranche_sample_norm_LUnp.i7(:,12), tranche_sample_norm_LUnp.i8(:,12), tranche_sample_norm_LUnp.i9(:,12),...
        tranche_sample_norm_LUnp.i10(:,12));
end

    tranche_norm_mean = mean(tranche_mat,1);
    tranche_norm_mean = squeeze(tranche_norm_mean);
%     csvwrite('Gas_Tranche_none.csv',tranche_sample_norm.none(:,[1:12,15,20]));
    

    
    for k = 1:10
        [~,idx] = sort(tranche_mat(:,12,k)); % sort just the first column
        tranche_mat(:,:,k) = tranche_mat(idx,:,k);   % sort the whole matrix using the sort indices
        
        if prod_ind == 1  
            [~,idx] = sort(tranche_mat_LUp(:,1,k)); 
            tranche_mat_LUp(:,:,k) = tranche_mat_LUp(idx,1,k);

            [~,idx] = sort(tranche_mat_LUnp(:,1,k)); 
            tranche_mat_LUnp(:,:,k) = tranche_mat_LUnp(idx,1,k);
        end
        
    end

if prod_ind == 1  
    final_mat = [tranche_mat(:,:,1), tranche_mat_LUp(:,:,1), tranche_mat_LUnp(:,:,1), repmat(0,10000,1), ...
                 tranche_mat(:,:,2), tranche_mat_LUp(:,:,2), tranche_mat_LUnp(:,:,2), repmat(0,10000,1), ...
                 tranche_mat(:,:,3), tranche_mat_LUp(:,:,3), tranche_mat_LUnp(:,:,3), repmat(0,10000,1), ...
                 tranche_mat(:,:,4), tranche_mat_LUp(:,:,4), tranche_mat_LUnp(:,:,4), repmat(0,10000,1), ...
                 tranche_mat(:,:,5), tranche_mat_LUp(:,:,5), tranche_mat_LUnp(:,:,5), repmat(0,10000,1), ...
                 tranche_mat(:,:,6), tranche_mat_LUp(:,:,6), tranche_mat_LUnp(:,:,6), repmat(0,10000,1), ...
                 tranche_mat(:,:,7), tranche_mat_LUp(:,:,7), tranche_mat_LUnp(:,:,7), repmat(0,10000,1), ...
                 tranche_mat(:,:,8), tranche_mat_LUp(:,:,8), tranche_mat_LUnp(:,:,8), repmat(0,10000,1), ...
                 tranche_mat(:,:,9), tranche_mat_LUp(:,:,9), tranche_mat_LUnp(:,:,9), repmat(0,10000,1), ...
                 tranche_mat(:,:,10), tranche_mat_LUp(:,:,10), tranche_mat_LUnp(:,:,10), repmat(0,10000,1)];
 
    csvwrite('Gas_OPGEE_mat_22.1.11.csv',final_mat);
else
    final_mat = [tranche_mat(:,:,1), repmat(0,10000,1), ...
                 tranche_mat(:,:,2), repmat(0,10000,1), ...
                 tranche_mat(:,:,3), repmat(0,10000,1), ...
                 tranche_mat(:,:,4), repmat(0,10000,1), ...
                 tranche_mat(:,:,5), repmat(0,10000,1), ...
                 tranche_mat(:,:,6), repmat(0,10000,1), ...
                 tranche_mat(:,:,7), repmat(0,10000,1), ...
                 tranche_mat(:,:,8), repmat(0,10000,1), ...
                 tranche_mat(:,:,9), repmat(0,10000,1), ...
                 tranche_mat(:,:,10), repmat(0,10000,1)];
    csvwrite('Oil_OPGEE_mat_22.1.11.csv',final_mat);
end             

%% PLOTTING SCRIPT
% 
% %Equipment leaks 

% figure(1)
% plot_setting = 1;
% 
% counter = 1;
% color = StanfordRed;
% vectot = tranche_mat(:,:,2);
% vectot_LUp = 0;
% vectot_LUnp = 0;
% [s, t] = plot_loss_rates(s, t, counter, vectot, vectot_LUp, vectot_LUnp, plotting, prod_ind, color, plot_setting);
% 
% counter = 4;
% color = StanfordOrange;
% vectot = tranche_mat(:,:,4);
% vectot_LUp = 0;
% vectot_LUnp = 0;
% [s, t] = plot_loss_rates(s, t, counter, vectot, vectot_LUp, vectot_LUnp, plotting, prod_ind, color, plot_setting);
% 
% counter = 6;
% color = StanfordPurple;
% vectot = tranche_mat(:,:,6);
% vectot_LUp = 0;
% vectot_LUnp = 0;
% [s, t] = plot_loss_rates(s, t, counter, vectot, vectot_LUp, vectot_LUnp, plotting, prod_ind, color, plot_setting);
% 
% counter = 9;
% color = LightGrey;
% vectot = tranche_mat(:,:,9);
% vectot_LUp = 0;
% vectot_LUnp = 0;
% [s, t] = plot_loss_rates(s, t, counter, vectot, vectot_LUp, vectot_LUnp, plotting, prod_ind, color, plot_setting);

    
%     
% % Tank flashing and Liquids unloading
% figure(2)

% plot_setting = 2;
% 
% counter = 1;
% color = StanfordRed;
% vectot = tranche_mat(:,:,2);
% if prod_ind == 1
%     vectot_LUp = tranche_mat_LUp(:,:,2);
%     vectot_LUnp = tranche_mat_LUnp(:,:,2);
% else
%    vectot_LUp = 0;
%     vectot_LUnp = 0; 
% end
% 
% [s, t] = plot_loss_rates(s, t, counter, vectot, vectot_LUp, vectot_LUnp, plotting, prod_ind, color, plot_setting);
% 
% counter = 4;
% color = StanfordOrange;
% vectot = tranche_mat(:,:,4);
% if prod_ind == 1
%     vectot_LUp = tranche_mat_LUp(:,:,4);
%     vectot_LUnp = tranche_mat_LUnp(:,:,4);
% else
%    vectot_LUp = 0;
%     vectot_LUnp = 0; 
% end
% 
% [s, t] = plot_loss_rates(s, t, counter, vectot, vectot_LUp, vectot_LUnp, plotting, prod_ind, color, plot_setting);
% 
% counter = 6;
% color = StanfordPurple;
% vectot = tranche_mat(:,:,6);
% if prod_ind == 1
%     vectot_LUp = tranche_mat_LUp(:,:,6);
%     vectot_LUnp = tranche_mat_LUnp(:,:,6);
% else
%     vectot_LUp = 0;
%     vectot_LUnp = 0; 
% end
% 
% [s, t] = plot_loss_rates(s, t, counter, vectot, vectot_LUp, vectot_LUnp, plotting, prod_ind, color, plot_setting);
% 
% counter = 9;
% color = LightGrey;
% vectot = tranche_mat(:,:,9);
% if prod_ind == 1
%     vectot_LUp = tranche_mat_LUp(:,:,9);
%     vectot_LUnp = tranche_mat_LUnp(:,:,9);
% else
%     vectot_LUp = 0;
%     vectot_LUnp = 0; 
% end
% 
% [s, t] = plot_loss_rates(s, t, counter, vectot, vectot_LUp, vectot_LUnp, plotting, prod_ind, color, plot_setting);



% %% Tanks plots
% 
% frac_total_gas = [0.002, 0.009, 0.010, 0.019, 0.051, 0.067, 0.265, 0.143, 0.282, 0.152];
% cum_frac = cumsum(frac_total_gas);
% n_reals = 10000;
% 
% for i = 1:n_reals
%     rand_draw = rand;
%     RandomIndex = ceil(rand*10000);
%     if rand_draw <= cum_frac(1)
%         % Tranche 1
%         EF_vec(i) = tranche_mat(RandomIndex,13,1);
% %         EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,1);
% %         EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,1);
%     elseif rand_draw > cum_frac(1) && rand_draw <= cum_frac(2)
%         % Tranche 2
%         EF_vec(i) = tranche_mat(RandomIndex,13,2);
% %         EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,2);
% %         EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,2);
%     elseif rand_draw > cum_frac(2) && rand_draw <= cum_frac(3)
%         % Tranche 3
%         EF_vec(i) = tranche_mat(RandomIndex,13,3);
% %         EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,3);
% %         EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,3);
%     elseif rand_draw > cum_frac(3) && rand_draw <= cum_frac(4)
%         % Tranche 4
%         EF_vec(i) = tranche_mat(RandomIndex,13,4);
% %         EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,4);
% %         EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,4);
%     elseif rand_draw > cum_frac(4) && rand_draw <= cum_frac(5)
%         % Tranche 5
%         EF_vec(i) = tranche_mat(RandomIndex,13,5);
% %         EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,5);
% %         EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,5);
%     elseif rand_draw > cum_frac(5) && rand_draw <= cum_frac(6)
%         % Tranche 6
%         EF_vec(i) = tranche_mat(RandomIndex,13,6);
% %         EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,6);
% %         EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,6);
%     elseif rand_draw > cum_frac(6) && rand_draw <= cum_frac(7)
%         % Tranche 7
%         EF_vec(i) = tranche_mat(RandomIndex,13,7);
% %         EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,7);
% %         EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,7);
%     elseif rand_draw > cum_frac(7) && rand_draw <= cum_frac(8)
%         % Tranche 8
%         EF_vec(i) = tranche_mat(RandomIndex,13,8);
% %         EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,8);
% %         EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,8);
%     elseif rand_draw > cum_frac(8) && rand_draw <= cum_frac(9)
%         % Tranche 9
%         EF_vec(i) = tranche_mat(RandomIndex,13,9);
% %         EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,9);
% %         EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,9);
%     elseif rand_draw > cum_frac(9) && rand_draw <= cum_frac(10)
%         % Tranche 10
%         EF_vec(i) = tranche_mat(RandomIndex,13,10);
% %         EF_vec_LUp(i) = tranche_mat_LUp(RandomIndex,1,10);
% %         EF_vec_LUnp(i) = tranche_mat_LUnp(RandomIndex,1,10);
%     end
% end
% 
% EF_vec_init = EF_vec;
% EF_vec_control = EF_vec .* (0.25/0.51);
% EF_vec_nocontrol = EF_vec .* (0.75/0.51);
% 
% % EF_vec_LUp_init = EF_vec_LUp;
% % EF_vec_LUp_control = EF_vec_LUp .* 0.1;
% % EF_vec_LUp_nocontrol = EF_vec_LUp .* 0.01;
% % 
% % EF_vec_LUnp_init = EF_vec_LUnp;
% % EF_vec_LUnp_control = EF_vec_LUnp .* 0.1;
% % EF_vec_LUnp_nocontrol = EF_vec_LUnp .* 0.01;
% 
% figure(1)
%     h = cdfplot(EF_vec_init);
%     set( h, 'LineStyle', '-','LineWidth',1.5,'Color', StanfordRed);
%     hold on
%     
%     h = cdfplot(EF_vec_control);
%     set( h, 'LineStyle', '-','LineWidth',1.5,'Color', StanfordOrange);
%     
%     h = cdfplot(EF_vec_nocontrol);
%     set( h, 'LineStyle', '-','LineWidth',1.5,'Color', LightGrey);
%     
%     grid('off')   
%     title('');
%     xlabel('');
%     ylabel('');
%     
%     set(gca,'YLim',[0.5 1]);
%     set(gca, 'XScale', 'log');
%     set(gca,'FontSize',10)
%     set(gca,'FontName','Arial')
%     set(gca,'XTick',[10^-3 10^-2 10^-1 10^0 10^1]);
%     set(gca,'XTickLabel',{'0.001', '0.01', '0.1', '1', '10'});
%     set(gca,'XMinorTick','off','YMinorTick','off')
%     set(gca,'TickDir', 'out')
%     set(gca,'TickLength',[0.01 0.01])
%     
%     grid(gca,'off')
%     set(gca,'XMinorGrid','off');
%     axis_a = gca;
%     % set box property to off and remove background color
%     set(axis_a,'box','off','color','none')
%     % create new, empty axes with box but without ticks
%     axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
%     % set original axes as active
%     axes(axis_a)
%     % link axes in case of zooming
%     linkaxes([axis_a axis_b])
% 
%     xlabel('Flash factor [kg CH_{4} bbl^{-1}]');
%     ylabel('Probability');
%     set(gca,'YLim',[0.5 1]);
%     set(gca,'XLim',[0.001 10.1])
%     
% % Liquids unloadings plots
% 
% figure(2)
% subplot(1,2,1)
%     h = cdfplot(EF_vec_LUp_init);
%     set( h, 'LineStyle', '-','LineWidth',1.5,'Color', StanfordRed);
%     hold on
%     
%     h = cdfplot(EF_vec_LUp_control);
%     set( h, 'LineStyle', '-','LineWidth',1.5,'Color', StanfordOrange);
%     
%     h = cdfplot(EF_vec_LUp_nocontrol);
%     set( h, 'LineStyle', '-','LineWidth',1.5,'Color', LightGrey);
%     
%     grid('off')   
%     title('');
%     xlabel('');
%     ylabel('');
%     
%     set(gca, 'XScale', 'log');
%     set(gca,'FontSize',10)
%     set(gca,'FontName','Arial')
%     set(gca,'XTick',[10^-5 10^-3 10^-1 10^0]);
%     set(gca,'XTickLabel',{'0.001%', '0.1%', '10%', '100%'});
%     set(gca,'XMinorTick','off','YMinorTick','off')
%     set(gca,'TickDir', 'out')
%     set(gca,'TickLength',[0.01 0.01])
%     
%     grid(gca,'off')
%     set(gca,'XMinorGrid','off');
%     axis_a = gca;
%     % set box property to off and remove background color
%     set(axis_a,'box','off','color','none')
%     % create new, empty axes with box but without ticks
%     axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
%     % set original axes as active
%     axes(axis_a)
%     % link axes in case of zooming
%     linkaxes([axis_a axis_b])
%     set(gca,'YLim',[0.5 1]);
%     set(gca,'XLim',[0.00001 1.1])
%     xlabel('Loss rate');
%     ylabel('Probability');
% subplot(1,2,2)
%     h = cdfplot(EF_vec_LUnp_init);
%     set( h, 'LineStyle', '-','LineWidth',1.5,'Color', StanfordRed);
%     hold on
%     
%     h = cdfplot(EF_vec_LUnp_control);
%     set( h, 'LineStyle', '-','LineWidth',1.5,'Color', StanfordOrange);
%     
%     h = cdfplot(EF_vec_LUnp_nocontrol);
%     set( h, 'LineStyle', '-','LineWidth',1.5,'Color', LightGrey);
%     
%     grid('off')   
%     title('');
%     xlabel('');
%     ylabel('');
%     
%     set(gca, 'XScale', 'log');
%     set(gca,'FontSize',10)
%     set(gca,'FontName','Arial')
%     set(gca,'XTick',[10^-5 10^-3 10^-1 10^0]);
%     set(gca,'XTickLabel',{'0.001%', '0.1%', '10%', '100%'});
%     set(gca,'XMinorTick','off','YMinorTick','off')
%     set(gca,'TickDir', 'out')
%     set(gca,'TickLength',[0.01 0.01])
%     
%     grid(gca,'off')
%     set(gca,'XMinorGrid','off');
%     axis_a = gca;
%     % set box property to off and remove background color
%     set(axis_a,'box','off','color','none')
%     % create new, empty axes with box but without ticks
%     axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
%     % set original axes as active
%     axes(axis_a)
%     % link axes in case of zooming
%     linkaxes([axis_a axis_b])
%     set(gca,'YLim',[0.5 1]);
%     set(gca,'XLim',[0.00001 1.1])
%     xlabel('Loss rate');
%     ylabel('Probability');
%     
%     N = 80;
%     start = 10^-5;
%     stop = 10^5;
%     b = 10.^linspace(log10(start),log10(stop),N+1);
% 
% histogram(EF_vec,b,'Normalization','probability','DisplayStyle','stairs','LineStyle','-','LineWidth',1.5,'EdgeColor',StanfordRed);
% hold on
% set(gca,'YLim',[0 0.1])
% 
%     set(gca, 'XScale', 'log');
%     set(gca,'FontSize',7)
%     set(gca,'FontName','Arial')
%     set(gca,'XTick',[10^-2 10^-1 10^0 10^1]);
%     set(gca,'XTickLabel',{'0.01', '0.1', '1', '10'});
%     set(gca,'XMinorTick','off','YMinorTick','off')
%     set(gca, 'TickDir', 'out')
%     set(gca,'TickLength',[0.03 0.035])
%     set(gca,'XLim',[0.000099 10000])
%     grid(gca,'on')
%     set(gca,'XMinorGrid','off');
%     axis_a = gca;
%     % set box property to off and remove background color
%     set(axis_a,'box','off','color','none')
%     % create new, empty axes with box but without ticks
%     axis_b = axes('Position',get(axis_a,'Position'),'box','on','xtick',[],'ytick',[]);
%     % set original axes as active
%     axes(axis_a)
%     % link axes in case of zooming
%     linkaxes([axis_a axis_b])
%     set(gca,'YLim',[0 0.1])
%      
%     Prciles = prctile(EF_vec,[2.5 50 97.5]);
%     Meen = nanmean(EF_vec);
%     
%         er = errorbar(Prciles(2),0.06, (Prciles(2) - Prciles(1)), (Prciles(3) - Prciles(2)),'horizontal');
%             er.Color = StanfordRed;
%             er.LineWidth = 1;
%             set(get(get(er,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%             hold on
%             ln = plot(Prciles(2),0.6,'x');
%             ln.MarkerEdgeColor = StanfordRed;
%             ln.MarkerSize = 6;
% 
%             ln = plot(Meen,0.06,'s');
%             ln.MarkerEdgeColor = StanfordRed;
%             ln.MarkerFaceColor = StanfordRed;
%             ln.MarkerSize = 6;    label = num2str(Meen,'%3.2f'); c = cellstr(label);
%             
%     dy = 0.005;
%     text(double(Meen), 0.06+dy, c,'Color',StanfordRed, 'FontSize', 7, 'HorizontalAlignment', 'center');

end





