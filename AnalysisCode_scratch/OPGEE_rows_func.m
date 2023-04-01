function [tranche_OPGEE] = OPGEE_rows_func(Replicate, OPGEE_bin, LU_type, flare_tab, M)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function takes input data from Enverus and GHGRP (gathered in the
% main "tranche_gen_func" and prepares it in a column format suitable for
% the methane model
%
% (i)   Classify Enverus data as dry gas, gas w oil, associated gas, or oil
%       only and assign to gas productivity tranches (asame as
%       di_scrubbing)
% (ii)  Iterate acros all wells and assign model parameters
%
% Inputs:
%   M: Enverus Basin Data
%               Col 1 = oil (bbl/day)
%               Col 2 = gas (Mscf/day)
%               Col 3 = GOR (Mscf/bbl)
%   OPGEE_bin:
%               Col 1 = well count
%               Col 2 = Average gas productivity (mscf/well/day)
%               Col 3 = Total gas production (mscf/day)
%               Col 4 = Total oil production (bbl/day)
%               Col 5 = Headers
%               Col 6 = Heaters
%               Col 7 = Separators
%               Col 8 = Meters
%               Col 9 = Tanks
%               Col 10 = Tanks
%               Col 11 = Reciprocating compressors
%               Col 12 = Dehydrators
%               Col 13 = CIPs
%               Col 14 = PCs
%               Col 15 = Oil controls 
%               Col 16 = Average methane content 
% Outputs:
%   tranche_OPGEE:
%               Col 1 = Tranche #
%               Col 2 = Well-level oil production [bbl/well/day]
%               Col 3 = Well count (1 based on recent edit)
%               Col 4 = C1 [molar fraction]
%               Col 5 = well-level GOR [scf/bbl]
%               Col 6 = LU type [binary]
%               Col 7 = fraction of wells flaring
%               Col 8 =  Headers per well
%               Col 9 = Heaters per well
%               Col 10 = Separators per well
%               Col 11 = Meters per well
%               Col 12 = Tanks per well
%               Col 13 = Tanks per well
%               Col 14 = Reciprocating compressors per well
%               Col 15 = Dehydrators per well
%               Col 16 = CIPs per well
%               Col 17 = PCs per well
%               Col 18 = Oil throughput controlled [fraction]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[tranche] = tranche_data_welllevel(M);
      
%%  For dry gas bins
% Enverus bins = 1-10
% Rows = 1 - 30

tranche_data = OPGEE_bin.gasdry;
tranche_OPGEE = [];
% if Basin_Select == 0
%  C1_frac = 83.2; 
% end

for i = 1: length(tranche_data(:,1))

    % Col 1 = oil (bbl/day)
    % Col 2 = gas (Mscf/day)
    % Col 3 = GOR (mscf/bbl)
    fn = sprintf('i%d', i);
    tranche_wells_mat = tranche.(fn);

    wells = tranche_data(i,1);

    %(1 = plunger, 2 = no plunger, 3 = no liquids unloading)
    ind1 = floor(wells * LU_type(1));
    ind2 = floor(wells * LU_type(2));
    mat1 = tranche_wells_mat(1:ind1,:);
    mat2 = tranche_wells_mat((ind1+1):ind2,:);
    mat3 = tranche_wells_mat((ind2+1):end,:);
    
    for j = 1:3
%         wells = tranche_data(i,1) * LU_type(j);
%         wells = round(wells);
%         prod_mscf = tranche_data(i,3) * LU_type(j);
%         prod_bbl = tranche_data(i,4) * LU_type(j);

        if j == 1
            prod_mscf = mat1(:,2);
            prod_bbl = mat1(:,1);
            prod_GOR = mat1(:,3)*1000;
        elseif j == 2
            prod_mscf = mat2(:,2);
            prod_bbl = mat2(:,1);
            prod_GOR = mat2(:,3)*1000; 
        else
            prod_mscf = mat3(:,2);
            prod_bbl = mat3(:,1);
            prod_GOR = mat3(:,3)*1000;             
        end

        if Replicate  ~= 1
            flare_frac = flare_tab.gasdry(i,4) * LU_type(j);
        else
            flare_frac = 0;
        end
        
%         if prod_bbl < 0.4
%             prod_bbl = 0.4;
%         end
        
        %prod_GOR = (prod_mscf*1000)/prod_bbl;
        
        %vec = [prod_bbl wells (tranche_data(i,16)*100) prod_GOR j flare_frac tranche_data(i,5:15)];
        vec = repmat([i 0 1 (tranche_data(i,16)*100) 0 j flare_frac tranche_data(i,5:15)],length(prod_bbl),1);
        vec(:,2) = prod_bbl;
        vec(:,5) = prod_GOR;
        tranche_OPGEE = [tranche_OPGEE; vec];
    end    
end

%%  For gas + oil bins
% Enverus bins = 11-20
% Rows = 31 - 60

tranche_data = OPGEE_bin.gasassoc;
% if Basin_Select == 0
%  C1_frac = 83.2; 
% end

for i = 1: length(tranche_data(:,1))
    
    % Col 1 = oil (bbl/day)
    % Col 2 = gas (Mscf/day)
    % Col 3 = GOR (mscf/bbl)
    fn = sprintf('i%d', i + 10);
    tranche_wells_mat = tranche.(fn);

    wells = tranche_data(i,1);

    %(1 = plunger, 2 = no plunger, 3 = no liquids unloading)
    ind1 = floor(wells * LU_type(1));
    ind2 = floor(wells * LU_type(2));
    mat1 = tranche_wells_mat(1:ind1,:);
    mat2 = tranche_wells_mat((ind1+1):ind2,:);
    mat3 = tranche_wells_mat((ind2+1):end,:);
    
    for j = 1:3
%         wells = tranche_data(i,1) * LU_type(j);
%         wells = round(wells);
%         prod_mscf = tranche_data(i,3) * LU_type(j);
%         prod_bbl = tranche_data(i,4) * LU_type(j);
        
        if j == 1
            prod_mscf = mat1(:,2);
            prod_bbl = mat1(:,1);
            prod_GOR = mat1(:,3)*1000;
        elseif j == 2
            prod_mscf = mat2(:,2);
            prod_bbl = mat2(:,1);
            prod_GOR = mat2(:,3)*1000; 
        else
            prod_mscf = mat3(:,2);
            prod_bbl = mat3(:,1);
            prod_GOR = mat3(:,3)*1000;             
        end
        
        
        if Replicate  ~= 1
            flare_frac = flare_tab.gasassoc(i,4) * LU_type(j);
        else
            flare_frac = 0;
        end   
    
%         if prod_bbl < 0.4
%             prod_bbl = 0.4;
%         end
%         
%         prod_GOR = (prod_mscf*1000)/prod_bbl;
%            
%         vec = [prod_bbl wells (tranche_data(i,16)*100) prod_GOR j flare_frac tranche_data(i,5:15)];
        vec = repmat([(i+10) 0 1 (tranche_data(i,16)*100) 0 j flare_frac tranche_data(i,5:15)],length(prod_bbl),1);
        vec(:,2) = prod_bbl;
        vec(:,5) = prod_GOR;
        tranche_OPGEE = [tranche_OPGEE; vec];
    end    
end

%%  For gas + oil bins
% Enverus bins = 21-30
% Rows = 61 - 70

tranche_data = OPGEE_bin.oilwgas;
% if Basin_Select == 0
%  C1_frac = 68.3; 
% end

for i = 1: length(tranche_data(:,1))
    
    % Col 1 = oil (bbl/day)
    % Col 2 = gas (Mscf/day)
    % Col 3 = GOR (mscf/bbl)
    fn = sprintf('i%d', i + 20);
    tranche_wells_mat = tranche.(fn);
    
    wells = tranche_data(i,1);
    
    %     wells = round(wells);
    %     prod_mscf = tranche_data(i,3);
    %     prod_bbl = tranche_data(i,4);
    
    prod_mscf = tranche_wells_mat(:,2);
    prod_bbl = tranche_wells_mat(:,1);
    prod_GOR = tranche_wells_mat(:,3)*1000;

    if Replicate  ~= 1
        flare_frac = flare_tab.oilwgas(i,4);
    else
        flare_frac = 0;
    end

%     if prod_bbl < 0.4
%         prod_bbl = 0.4;
%     end
%     
%     prod_GOR = (prod_mscf*1000)/prod_bbl;
            
%     vec = [prod_bbl wells (tranche_data(i,16)*100) prod_GOR 3 flare_frac tranche_data(i,5:15)];
    vec = repmat([(i+20) 0 1 (tranche_data(i,16)*100) 0 3 flare_frac tranche_data(i,5:15)],length(prod_bbl),1);
    vec(:,2) = prod_bbl;
    vec(:,5) = prod_GOR;

    tranche_OPGEE = [tranche_OPGEE; vec];
end

%%  For oil bins
% Enverus bins = 31-34
% Rows = 71 - 74

tranche_data = OPGEE_bin.oil;
% if Basin_Select == 0
%  C1_frac = 68.3; 
% end

for i = 1: length(tranche_data(:,1))
    
    % Col 1 = oil (bbl/day)
    % Col 2 = gas (Mscf/day)
    % Col 3 = GOR (mscf/bbl)
    fn = sprintf('i%d', i + 30);
    tranche_wells_mat = tranche.(fn);
    
    wells = tranche_data(i,1);
    
%     wells = round(wells);
%     prod_mscf = tranche_data(i,3);
%     prod_bbl = tranche_data(i,4);

    prod_mscf = tranche_wells_mat(:,2);
    prod_bbl = tranche_wells_mat(:,1);
    prod_GOR = tranche_wells_mat(:,3)*1000;

    if Replicate  ~= 1
        flare_frac = flare_tab.oil(i,4);
    else
        flare_frac = 0;
    end
    
%     if prod_bbl < 0.4
%         prod_bbl = 0.4;
%     end
%     
%     prod_GOR = (prod_mscf*1000)/prod_bbl;
        
            
%     vec = [prod_bbl wells (tranche_data(i,16)*100) prod_GOR 3 flare_frac tranche_data(i,5:15)];
    vec = repmat([(i+30) 0 1 (tranche_data(i,16)*100) 0 3 flare_frac tranche_data(i,5:15)],length(prod_bbl),1);
    vec(:,2) = prod_bbl;
    vec(:,5) = prod_GOR;

    tranche_OPGEE = [tranche_OPGEE; vec];   
end

end

