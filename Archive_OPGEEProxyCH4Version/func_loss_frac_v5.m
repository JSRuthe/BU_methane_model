function tranche_norm_mean = func_loss_frac_v5(equipdata_tot, prod_ind, j)

%  - - INPUTS - - 

% col 1 - 16 = equipment array
% col 17     = tranche iteration (1-74)
% col 18     = well productivity [kg/well/d]
% col 19     = well productivity [scf/well/d]

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
plotting = 0;
counter = 0;
s = [];
t = [];


%(i) Separate by categories

if prod_ind == 1
    vec = vertcat(equipdata_tot.drygas(:,:,j), equipdata_tot.gaswoil(:,:,j));
else
    vec = vertcat(equipdata_tot.oil(:,:,j), equipdata_tot.assoc(:,:,j));
end

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


    
    %% SAMPLING

    if length(tranche.i1) > 10000
        tranche_sample.i1 = datasample(tranche.i1,10000,'Replace',false);
    else
        tranche_sample.i1 = tranche.i1;
    end

    if length(tranche.i2) > 10000
        tranche_sample.i2 = datasample(tranche.i2,10000,'Replace',false);
    else
        tranche_sample.i2 = tranche.i2;
    end
    
    if length(tranche.i3) > 10000
        tranche_sample.i3 = datasample(tranche.i3,10000,'Replace',false);
    else
        tranche_sample.i3 = tranche.i3;
    end
    
    if length(tranche.i4) > 10000
        tranche_sample.i4 = datasample(tranche.i4,10000,'Replace',false);
    else
        tranche_sample.i4 = tranche.i4;
    end
    
    if length(tranche.i5) > 10000
        tranche_sample.i5 = datasample(tranche.i5,10000,'Replace',false);
    else
        tranche_sample.i5 = tranche.i5;
    end
    
    if length(tranche.i6) > 10000
        tranche_sample.i6 = datasample(tranche.i6,10000,'Replace',false);
    else
        tranche_sample.i6 = tranche.i6;
    end
    
    if length(tranche.i7) > 10000
        tranche_sample.i7 = datasample(tranche.i7,10000,'Replace',false);
    else
        tranche_sample.i7 = tranche.i7;
    end
    
    if length(tranche.i8) > 10000
        tranche_sample.i8 = datasample(tranche.i8,10000,'Replace',false);
    else
        tranche_sample.i8 = tranche.i8;
    end
    
    if length(tranche.i9) > 10000
        tranche_sample.i9 = datasample(tranche.i9,10000,'Replace',false);
    else
        tranche_sample.i9 = tranche.i9;
    end

    
    if length(tranche.i10) > 10000
        tranche_sample.i10 = datasample(tranche.i10,10000,'Replace',false);
    else
        tranche_sample.i10 = tranche.i10;
    end
    
     tranche_sample.none = datasample(tranche.none,10000,'Replace',false);
    
%     counter = 1;
%     color = StanfordRed;
%     [s, t, tranche_sample_norm.none] = OPGEE_Fast_Bins_v8(s, t, counter, tranche_sample.none, color, plotting);
%     
     
    counter = 1;
    color = StanfordRed;
    [s, t, tranche_sample_norm.i1] = OPGEE_Fast_Bins_v8(s, t, counter, tranche_sample.i1, plotting, prod_ind);

    counter = 2;
    color = StanfordOrange;
    [s, t, tranche_sample_norm.i2] = OPGEE_Fast_Bins_v8(s, t, counter, tranche_sample.i2, plotting, prod_ind);
    
    counter = 3;
    color = StanfordYellow;
    [s, t, tranche_sample_norm.i3] = OPGEE_Fast_Bins_v8(s, t, counter, tranche_sample.i3, plotting, prod_ind);

    counter = 4;
    color = StanfordLGreen;
    [s, t, tranche_sample_norm.i4] = OPGEE_Fast_Bins_v8(s, t, counter, tranche_sample.i4, plotting, prod_ind);

    counter = 5;
    color = StanfordDGreen;
    [s, t, tranche_sample_norm.i5] = OPGEE_Fast_Bins_v8(s, t, counter, tranche_sample.i5, plotting, prod_ind);
    
    counter = 6;
    color = StanfordBlue;
    [s, t, tranche_sample_norm.i6] = OPGEE_Fast_Bins_v8(s, t, counter, tranche_sample.i6, plotting, prod_ind);

    counter = 7;
    color = StanfordPurple;
    [s, t, tranche_sample_norm.i7] = OPGEE_Fast_Bins_v8(s, t, counter, tranche_sample.i7, plotting, prod_ind);

    counter = 8;
    color = Sandstone;
    [s, t, tranche_sample_norm.i8] = OPGEE_Fast_Bins_v8(s, t, counter, tranche_sample.i8, plotting, prod_ind);
    
    counter = 9;
    color = LightGrey;
    [s, t, tranche_sample_norm.i9] = OPGEE_Fast_Bins_v8(s, t, counter, tranche_sample.i9, plotting, prod_ind);
    
    counter = 10;
    color = 'k';
    [s, t, tranche_sample_norm.i10] = OPGEE_Fast_Bins_v8(s, t, counter, tranche_sample.i10, plotting, prod_ind);

    
if length(tranche.i1) < 10000 && ~isempty(tranche.i1)    
    tranche_sample_norm.i1 = tranche_sample_norm.i1;
     tranche_sample_norm.i1 = [repmat(tranche_sample_norm.i1, floor(10000/size(tranche_sample_norm.i1,1)),1);...
         tranche_sample_norm.i1(1:mod(10000, size(tranche_sample_norm.i1,1)),:)];
end

if length(tranche.i2) < 10000 && ~isempty(tranche.i2)    
    tranche_sample_norm.i2 = tranche_sample_norm.i2;
     tranche_sample_norm.i2 = [repmat(tranche_sample_norm.i2, floor(10000/size(tranche_sample_norm.i2,1)),1);...
         tranche_sample_norm.i2(1:mod(10000, size(tranche_sample_norm.i2,1)),:)];
end

if length(tranche.i3) < 10000 && ~isempty(tranche.i3) 
    tranche_sample_norm.i3 = tranche_sample_norm.i3;
     tranche_sample_norm.i3 = [repmat(tranche_sample_norm.i3, floor(10000/size(tranche_sample_norm.i3,1)),1);...
         tranche_sample_norm.i3(1:mod(10000, size(tranche_sample_norm.i3,1)),:)];
end

if length(tranche.i4) < 10000 && ~isempty(tranche.i4) 
    tranche_sample_norm.i4 = tranche_sample_norm.i4;
     tranche_sample_norm.i4 = [repmat(tranche_sample_norm.i4, floor(10000/size(tranche_sample_norm.i4,1)),1);...
         tranche_sample_norm.i4(1:mod(10000, size(tranche_sample_norm.i4,1)),:)];
end

if length(tranche.i5) < 10000 && ~isempty(tranche.i5) 
    tranche_sample_norm.i5 = tranche_sample_norm.i5;
     tranche_sample_norm.i5 = [repmat(tranche_sample_norm.i5, floor(10000/size(tranche_sample_norm.i5,1)),1);...
         tranche_sample_norm.i5(1:mod(10000, size(tranche_sample_norm.i5,1)),:)];
end

if length(tranche.i6) < 10000 && ~isempty(tranche.i6)
    tranche_sample_norm.i6 = tranche_sample_norm.i6;
     tranche_sample_norm.i6 = [repmat(tranche_sample_norm.i6, floor(10000/size(tranche_sample_norm.i6,1)),1);...
         tranche_sample_norm.i6(1:mod(10000, size(tranche_sample_norm.i6,1)),:)];
end

if length(tranche.i7) < 10000 && ~isempty(tranche.i7)
    tranche_sample_norm.i7 = tranche_sample_norm.i7;
     tranche_sample_norm.i7 = [repmat(tranche_sample_norm.i7, floor(10000/size(tranche_sample_norm.i7,1)),1);...
         tranche_sample_norm.i7(1:mod(10000, size(tranche_sample_norm.i7,1)),:)];
end

if length(tranche.i8) < 10000 && ~isempty(tranche.i8)
    tranche_sample_norm.i8 = tranche_sample_norm.i8;
     tranche_sample_norm.i8 = [repmat(tranche_sample_norm.i8, floor(10000/size(tranche_sample_norm.i8,1)),1);...
         tranche_sample_norm.i8(1:mod(10000, size(tranche_sample_norm.i8,1)),:)];
end
     
if length(tranche.i9) < 10000 && ~isempty(tranche.i9)    
    tranche_sample_norm.i9 = tranche_sample_norm.i9;
     tranche_sample_norm.i9 = [repmat(tranche_sample_norm.i9, floor(10000/size(tranche_sample_norm.i9,1)),1);...
         tranche_sample_norm.i9(1:mod(10000, size(tranche_sample_norm.i9,1)),:)];
end
     
if length(tranche.i10) < 10000 && ~isempty(tranche.i10)
    tranche_sample_norm.i10 = tranche_sample_norm.i10;
     tranche_sample_norm.i10 = [repmat(tranche_sample_norm.i10, floor(10000/size(tranche_sample_norm.i10,1)),1);...
         tranche_sample_norm.i10(1:mod(10000, size(tranche_sample_norm.i10,1)),:)];
end

%     tranche_mat = cat(3, tranche_sample_norm.i1(:,[1:12,15,20]), tranche_sample_norm.i2(:,[1:12,15,20]), tranche_sample_norm.i3(:,[1:12,15,20]), ...
%         tranche_sample_norm.i4(:,[1:12,15,20]), tranche_sample_norm.i5(:,[1:12,15,20]), tranche_sample_norm.i6(:,[1:12,15,20]), ...
%         tranche_sample_norm.i7(:,[1:12,15,20]), tranche_sample_norm.i8(:,[1:12,15,20]), tranche_sample_norm.i9(:,[1:12,15,20]),...
%         tranche_sample_norm.i10(:,[1:12,15,20]));

    
        DataMerged = [];
        if any(tranche_sample_norm.i1(:)); DataMerged = cat(3, DataMerged, tranche_sample_norm.i1(:,[1:12,15,20])); end
        if any(tranche_sample_norm.i2(:)); DataMerged = cat(3, DataMerged, tranche_sample_norm.i2(:,[1:12,15,20])); end
        if any(tranche_sample_norm.i3(:)); DataMerged = cat(3, DataMerged, tranche_sample_norm.i3(:,[1:12,15,20])); end
        if any(tranche_sample_norm.i4(:)); DataMerged = cat(3, DataMerged, tranche_sample_norm.i4(:,[1:12,15,20])); end
        if any(tranche_sample_norm.i5(:)); DataMerged = cat(3, DataMerged, tranche_sample_norm.i5(:,[1:12,15,20])); end
        if any(tranche_sample_norm.i6(:)); DataMerged = cat(3, DataMerged, tranche_sample_norm.i6(:,[1:12,15,20])); end
        if any(tranche_sample_norm.i7(:)); DataMerged = cat(3, DataMerged, tranche_sample_norm.i7(:,[1:12,15,20])); end
        if any(tranche_sample_norm.i8(:)); DataMerged = cat(3, DataMerged, tranche_sample_norm.i8(:,[1:12,15,20])); end
        if any(tranche_sample_norm.i9(:)); DataMerged = cat(3, DataMerged, tranche_sample_norm.i9(:,[1:12,15,20])); end
        if any(tranche_sample_norm.i10(:)); DataMerged = cat(3, DataMerged, tranche_sample_norm.i10(:,[1:12,15,20])); end
        tranche_mat = DataMerged;
    
tranche_norm_mean = mean(tranche_mat,1);
tranche_norm_mean = squeeze(tranche_norm_mean);
%     csvwrite('Gas_Tranche_none.csv',tranche_sample_norm.none(:,[1:12,15,20]));
    

    
    for k = 1:10
        [~,idx] = sort(tranche_mat(:,14,k)); % sort just the first column
        tranche_mat(:,:,k) = tranche_mat(idx,:,k);   % sort the whole matrix using the sort indices
   
    end

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
    
     x = 1;
     
end





