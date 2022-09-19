function [tranche_OPGEE] = OPGEE_rows_func(Replicate, OPGEE_bin, LU_type, flare_tab)


% OPGEE binning func

      
% For dry gas bins
tranche_data = OPGEE_bin.gasdry;
tranche_OPGEE = [];
% if Basin_Select == 0
%  C1_frac = 83.2; 
% end

for i = 1: length(tranche_data(:,1))
    for j = 1:3
        wells = tranche_data(i,1) * LU_type(j);
        wells = round(wells);
        prod_mscf = tranche_data(i,3) * LU_type(j);
        prod_bbl = tranche_data(i,4) * LU_type(j);
        if Replicate  ~= 1
            flare_frac = flare_tab.gasdry(i,4) * LU_type(j);
        else
            flare_frac = 0;
        end
        
        if prod_bbl < 0.4
            prod_bbl = 0.4;
        end
        
        prod_GOR = (prod_mscf*1000)/prod_bbl;
        
        vec = [prod_bbl wells (tranche_data(i,16)*100) prod_GOR j flare_frac tranche_data(i,5:15)];
        tranche_OPGEE = [tranche_OPGEE; vec];
    end    
end

% For gas wells with oil
tranche_data = OPGEE_bin.gasassoc;
% if Basin_Select == 0
%  C1_frac = 83.2; 
% end

for i = 1: length(tranche_data(:,1))
    for j = 1:3
        wells = tranche_data(i,1) * LU_type(j);
        wells = round(wells);
        prod_mscf = tranche_data(i,3) * LU_type(j);
        prod_bbl = tranche_data(i,4) * LU_type(j);
        if Replicate  ~= 1
            flare_frac = flare_tab.gasassoc(i,4) * LU_type(j);
        else
            flare_frac = 0;
        end
        
    
        if prod_bbl < 0.4
            prod_bbl = 0.4;
        end
        
        prod_GOR = (prod_mscf*1000)/prod_bbl;
           
        vec = [prod_bbl wells (tranche_data(i,16)*100) prod_GOR j flare_frac tranche_data(i,5:15)];
        tranche_OPGEE = [tranche_OPGEE; vec];
    end    
end

% For oil wells with gas
tranche_data = OPGEE_bin.oilwgas;
% if Basin_Select == 0
%  C1_frac = 68.3; 
% end

for i = 1: length(tranche_data(:,1))
    wells = tranche_data(i,1);
    wells = round(wells);
    prod_mscf = tranche_data(i,3);
    prod_bbl = tranche_data(i,4);
    if Replicate  ~= 1
        flare_frac = flare_tab.oilwgas(i,4);
    else
        flare_frac = 0;
    end

    if prod_bbl < 0.4
        prod_bbl = 0.4;
    end
    
    prod_GOR = (prod_mscf*1000)/prod_bbl;
            
    vec = [prod_bbl wells (tranche_data(i,16)*100) prod_GOR 3 flare_frac tranche_data(i,5:15)];
    tranche_OPGEE = [tranche_OPGEE; vec];   
end

% For oil wells
tranche_data = OPGEE_bin.oil;
% if Basin_Select == 0
%  C1_frac = 68.3; 
% end

for i = 1: length(tranche_data(:,1))
    wells = tranche_data(i,1);
    wells = round(wells);
    prod_mscf = tranche_data(i,3);
    prod_bbl = tranche_data(i,4);
    if Replicate  ~= 1
        flare_frac = flare_tab.oil(i,4);
    else
        flare_frac = 0;
    end
    
    if prod_bbl < 0.4
        prod_bbl = 0.4;
    end
    
    prod_GOR = (prod_mscf*1000)/prod_bbl;
        
    vec = [prod_bbl wells (tranche_data(i,16)*100) prod_GOR 3 flare_frac tranche_data(i,5:15)];
    tranche_OPGEE = [tranche_OPGEE; vec];   
end

% csvwrite(char(strcat(Basin_Index(1),'_OPGEE_trch.csv')),tranche_OPGEE)

end

