function [sitedata] = wellpersite_func(welldata, tranche, k, AF_basin)

%% PREPROCESSING

% Input data is "welldata"
% Col 1 = tranche # (1 - 74)
% Col 2 = sum of emissions (kg/day)

% Parameters for processing
        
C1_frac = AF_basin(1,12);
%% DRY GAS
    
    well_iteration = welldata.drygas(:,:,k);
    
    site_iteration = zeros(1,1);
    
    counter = 0;
    [totalrows,~] = size(well_iteration);
    startrow = 1;
    startrow = int64(startrow);
    endrow = 1;
    endrow = int64(endrow);
    reset = true;
    
    while endrow < totalrows
        counter = counter + 1;
        
        index = well_iteration(startrow,1);
        
        if index == 1 || index == 2 || index == 3
            tranche_set = tranche.i1;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);  
        end
        
        if index == 4 || index == 5 || index == 6
            tranche_set = tranche.i2;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);   
        end        

        if index == 7 || index == 8 || index == 9
            tranche_set = tranche.i3;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac); 
        end   
        
        if index == 10 || index == 11 || index == 12
            tranche_set = tranche.i4;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);  
        end
        
        if index == 13 || index == 14 || index == 15
            tranche_set = tranche.i5;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);   
        end        
        if index == 16 || index == 17 || index == 18
            tranche_set = tranche.i6;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);  
        end
        
        if index == 19 || index == 20 || index == 21
            tranche_set = tranche.i7;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);  
        end
        
        if index == 22 || index == 23 || index == 24
            tranche_set = tranche.i8;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac); 
        end
        
        if index == 25 || index == 26 || index == 27
            tranche_set = tranche.i9;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);  
        end
        
        if index == 28 || index == 29 || index == 30
            tranche_set = tranche.i10;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);   
        end   
    end


    sitedata.drygas = site_iteration;


    %% GAS W OIL
 
     well_iteration = welldata.gaswoil(:,:,k);
     
     site_iteration = zeros(1,1);
    
     counter = 0;
     [totalrows,~] = size(well_iteration);
     startrow = 1;
     startrow = int64(startrow);
     endrow = 1;
     endrow = int64(endrow);
     reset = true;
    
    while endrow < totalrows
        counter = counter + 1;
        
        index = well_iteration(startrow,1);
        
        if index == 31 || index == 32 || index == 33
            tranche_set = tranche.i11;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);  
        end
        
        if index == 34 || index == 35 || index == 36
            tranche_set = tranche.i12;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);  
        end        

        if index == 37 || index == 38 || index == 39
            tranche_set = tranche.i13;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);  
        end   
        
        if index == 40 || index == 41 || index == 42
            tranche_set = tranche.i14;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);  
        end
        
        if index == 43 || index == 44 || index == 45
            tranche_set = tranche.i15;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);   
        end        
        if index == 46 || index == 47 || index == 48
            tranche_set = tranche.i16;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);   
        end
        
        if index == 49 || index == 50 || index == 51
            tranche_set = tranche.i17;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);   
        end
        
        if index == 52 || index == 53 || index == 54
            tranche_set = tranche.i18;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);   
        end
        
        if index == 55 || index == 56 || index == 57
            tranche_set = tranche.i19;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);   
        end
        
        if index == 58 || index == 59 || index == 60
            tranche_set = tranche.i20;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac); 
        end   
    end


    sitedata.gaswoil = site_iteration;

%% OIL W GAS

    well_iteration = welldata.assoc(:,:,k);
    
    site_iteration = zeros(1,1);
    
    counter = 0;
    [totalrows,~] = size(well_iteration);
    startrow = 1;
    startrow = int64(startrow);
    endrow = 1;
    endrow = int64(endrow);
    reset = true;
    
    while endrow < totalrows && startrow < totalrows
        counter = counter + 1;
        
        index = well_iteration(startrow,1);
        
        if index == 61
            tranche_set = tranche.i21;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);
        end
        
        if index == 62
            tranche_set = tranche.i22;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac); 
        end        

        if index == 63
            tranche_set = tranche.i23;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac); 
        end   
        
        if index == 64
            tranche_set = tranche.i24;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac); 
        end
        
        if index == 65
            tranche_set = tranche.i25;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);  
        end   
        
        if index == 66
            tranche_set = tranche.i26;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);   
        end
        
        if index == 67
            tranche_set = tranche.i27;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);   
        end
        
        if index == 68
            tranche_set = tranche.i28;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);   
        end
        
        if index == 69
            tranche_set = tranche.i29;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac); 
        end
        
        if index == 70
            tranche_set = tranche.i30;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac); 
        end   
    end

 
sitedata.assoc = site_iteration;



%% OIL ONLY

    well_iteration = welldata.oil(:,:,k);
    
    site_iteration = zeros(1,1);
    
    counter = 0;
    [totalrows,~] = size(well_iteration);
    startrow = 1;
    startrow = int64(startrow);
    endrow = 1;
    endrow = int64(endrow);
    reset = true;
    
    while endrow < totalrows && startrow < totalrows
        counter = counter + 1;
        
        index = well_iteration(startrow,1);
        
        if index == 71
            tranche_set = tranche.i31;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);
        end
        
        if index == 72
            tranche_set = tranche.i31;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);
        end

        if index == 73
            tranche_set = tranche.i31;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);
        end
        
        if index == 74
            tranche_set = tranche.i31;
            [startrow, endrow, site_iteration, reset] = clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac);
        end

    end

 
sitedata.oil = site_iteration;        

