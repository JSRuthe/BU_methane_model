function tranche_norm_mean = convert2lossfrac(equipdata_tot, prod_ind, j,is_base_case,output_filename)

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

if length(tranche.i1) < 10000 && ~isempty(tranche.i1)    
    tranche_sample_norm.i1 = tranche_sample_norm.i1;
     tranche_sample_norm.i1 = [repmat(tranche_sample_norm.i1, floor(10000/size(tranche_sample_norm.i1,1)),1);...
         tranche_sample_norm.i1(1:mod(10000, size(tranche_sample_norm.i1,1)),:)];
elseif isempty(tranche.i1)
    tranche_sample_norm.i1 = zeros(10000, 21);
end

if length(tranche.i2) < 10000 && ~isempty(tranche.i2)    
    tranche_sample_norm.i2 = tranche_sample_norm.i2;
     tranche_sample_norm.i2 = [repmat(tranche_sample_norm.i2, floor(10000/size(tranche_sample_norm.i2,1)),1);...
         tranche_sample_norm.i2(1:mod(10000, size(tranche_sample_norm.i2,1)),:)];								   
elseif isempty(tranche.i2)
    tranche_sample_norm.i2 = zeros(10000, 21);
end

if length(tranche.i3) < 10000 && ~isempty(tranche.i3) 
    tranche_sample_norm.i3 = tranche_sample_norm.i3;
     tranche_sample_norm.i3 = [repmat(tranche_sample_norm.i3, floor(10000/size(tranche_sample_norm.i3,1)),1);...
         tranche_sample_norm.i3(1:mod(10000, size(tranche_sample_norm.i3,1)),:)];
elseif isempty(tranche.i3)
    tranche_sample_norm.i3 = zeros(10000, 21);
end

if length(tranche.i4) < 10000 && ~isempty(tranche.i4) 
    tranche_sample_norm.i4 = tranche_sample_norm.i4;
     tranche_sample_norm.i4 = [repmat(tranche_sample_norm.i4, floor(10000/size(tranche_sample_norm.i4,1)),1);...
         tranche_sample_norm.i4(1:mod(10000, size(tranche_sample_norm.i4,1)),:)];
elseif isempty(tranche.i4)
    tranche_sample_norm.i4 = zeros(10000, 21);
end

if length(tranche.i5) < 10000 && ~isempty(tranche.i5) 																 
    tranche_sample_norm.i5 = tranche_sample_norm.i5;
     tranche_sample_norm.i5 = [repmat(tranche_sample_norm.i5, floor(10000/size(tranche_sample_norm.i5,1)),1);...
         tranche_sample_norm.i5(1:mod(10000, size(tranche_sample_norm.i5,1)),:)];																											  
elseif isempty(tranche.i5)
    tranche_sample_norm.i5 = zeros(10000, 21);
end

if length(tranche.i6) < 10000 && ~isempty(tranche.i6)
    tranche_sample_norm.i6 = tranche_sample_norm.i6;
     tranche_sample_norm.i6 = [repmat(tranche_sample_norm.i6, floor(10000/size(tranche_sample_norm.i6,1)),1);...
         tranche_sample_norm.i6(1:mod(10000, size(tranche_sample_norm.i6,1)),:)];
elseif isempty(tranche.i6)
    tranche_sample_norm.i6 = zeros(10000, 21);
end

if length(tranche.i7) < 10000 && ~isempty(tranche.i7)
    tranche_sample_norm.i7 = tranche_sample_norm.i7;
     tranche_sample_norm.i7 = [repmat(tranche_sample_norm.i7, floor(10000/size(tranche_sample_norm.i7,1)),1);...
         tranche_sample_norm.i7(1:mod(10000, size(tranche_sample_norm.i7,1)),:)];
elseif isempty(tranche.i7)
    tranche_sample_norm.i7 = zeros(10000, 21);
end

if length(tranche.i8) < 10000 && ~isempty(tranche.i8)
    tranche_sample_norm.i8 = tranche_sample_norm.i8;
     tranche_sample_norm.i8 = [repmat(tranche_sample_norm.i8, floor(10000/size(tranche_sample_norm.i8,1)),1);...
         tranche_sample_norm.i8(1:mod(10000, size(tranche_sample_norm.i8,1)),:)];
elseif isempty(tranche.i8)
    tranche_sample_norm.i8 = zeros(10000, 21);
end
     
if length(tranche.i9) < 10000 && ~isempty(tranche.i9)    
    tranche_sample_norm.i9 = tranche_sample_norm.i9;
     tranche_sample_norm.i9 = [repmat(tranche_sample_norm.i9, floor(10000/size(tranche_sample_norm.i9,1)),1);...
         tranche_sample_norm.i9(1:mod(10000, size(tranche_sample_norm.i9,1)),:)];
elseif isempty(tranche.i9)
    tranche_sample_norm.i9 = zeros(10000, 21);
end
     
if length(tranche.i10) < 10000 && ~isempty(tranche.i10)
    tranche_sample_norm.i10 = tranche_sample_norm.i10;
     tranche_sample_norm.i10 = [repmat(tranche_sample_norm.i10, floor(10000/size(tranche_sample_norm.i10,1)),1);...
         tranche_sample_norm.i10(1:mod(10000, size(tranche_sample_norm.i10,1)),:)];
elseif isempty(tranche.i10)
    tranche_sample_norm.i10 = zeros(10000, 21);
end


tranche_mat = cat(3, tranche_sample_norm.i1(:,[1:11,21,15]), tranche_sample_norm.i2(:,[1:11,21,15]), tranche_sample_norm.i3(:,[1:11,21,15]), ...
    tranche_sample_norm.i4(:,[1:11,21,15]), tranche_sample_norm.i5(:,[1:11,21,15]), tranche_sample_norm.i6(:,[1:11,21,15]), ...
    tranche_sample_norm.i7(:,[1:11,21,15]), tranche_sample_norm.i8(:,[1:11,21,15]), tranche_sample_norm.i9(:,[1:11,21,15]),...
    tranche_sample_norm.i10(:,[1:11,21,15]));

tranche_norm_mean = mean(tranche_mat,1);
tranche_norm_mean = squeeze(tranche_norm_mean);


%% BASE CASE SECTION

if is_base_case == 1
    
    for k = 1:10
        [~,idx] = sort(tranche_mat(:,12,k)); % sort just the first column
        tranche_mat(:,:,k) = tranche_mat(idx,:,k);   % sort the whole matrix using the sort indices
    end
    
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

        for i = 1:10

                my_field = strcat('i',num2str(i));        
                counter = i;
                % Liquids unloading - plunger
                tranche_sample_LUp.(my_field) = tranche_LUp.(my_field); 
                tranche_sample_norm_LUp.(my_field)(:,12) = tranche_sample_LUp.(my_field)(:,12)./tranche_sample_LUp.(my_field)(:,18);   
                tranche_sample_norm_LUp.(my_field) = [repmat(tranche_sample_norm_LUp.(my_field), floor(10000/size(tranche_sample_norm_LUp.(my_field),1)),1);...
                tranche_sample_norm_LUp.(my_field)(1:mod(10000, size(tranche_sample_norm_LUp.(my_field),1)),:)];

                % Liquids unloading - non plunger
                tranche_sample_LUnp.(my_field) = tranche_LUnp.(my_field); 
                tranche_sample_norm_LUnp.(my_field)(:,12) = tranche_sample_LUnp.(my_field)(:,12)./tranche_sample_LUnp.(my_field)(:,18);
                tranche_sample_norm_LUnp.(my_field) = [repmat(tranche_sample_norm_LUnp.(my_field), floor(10000/size(tranche_sample_norm_LUnp.(my_field),1)),1);...
                tranche_sample_norm_LUnp.(my_field)(1:mod(10000, size(tranche_sample_norm_LUnp.(my_field),1)),:)];
        end   

        tranche_mat_LUp = cat(3, tranche_sample_norm_LUp.i1(:,12), tranche_sample_norm_LUp.i2(:,12), tranche_sample_norm_LUp.i3(:,12), ...
            tranche_sample_norm_LUp.i4(:,12), tranche_sample_norm_LUp.i5(:,12), tranche_sample_norm_LUp.i6(:,12), ...
            tranche_sample_norm_LUp.i7(:,12), tranche_sample_norm_LUp.i8(:,12), tranche_sample_norm_LUp.i9(:,12),...
            tranche_sample_norm_LUp.i10(:,12));

        tranche_mat_LUnp = cat(3, tranche_sample_norm_LUnp.i1(:,12), tranche_sample_norm_LUnp.i2(:,12), tranche_sample_norm_LUnp.i3(:,12), ...
            tranche_sample_norm_LUnp.i4(:,12), tranche_sample_norm_LUnp.i5(:,12), tranche_sample_norm_LUnp.i6(:,12), ...
            tranche_sample_norm_LUnp.i7(:,12), tranche_sample_norm_LUnp.i8(:,12), tranche_sample_norm_LUnp.i9(:,12),...
            tranche_sample_norm_LUnp.i10(:,12)); 

        for k = 1:10
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

        csvwrite(output_filename,final_mat);
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
        csvwrite(output_filename,final_mat);
    end             
end

end





