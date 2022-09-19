function [EmissionsGas, EmissionsOil, Superemitters, welldata, equipdata] = mat_extend_v2(dataraw, welldata, equipdata, k, welloption, equipoption, activityfolder, Basin_Select, Enverus_tab, AF_basin)

data = dataraw;
[rows, columns] = size(data);

%  - - OUTPUTS - - 

% Study.All

%    gas  oil  dataraw	
% row 1  (18) (6) - Wells
% row 2  (19) (7) - Header
% row 3  (20) (8) - Heater
% row 4  (21) (9) - separators
% row 5  (22) (10) - Meter
% row 6  (23) (11) - Tanks - leaks
% row 7  (24) (12) - Tanks - vents
% row 8  (25) (13) - Recip Compressor
% row 9  (26) (14) - Dehydrators
% row 10 (27) (15) - CIP
% row 11 (28) (16) - PC
% row 12 (29) (17) - LU
% row 13 (30) (18) - completions
% row 14 (31) (19) - workovers
% row 15 (32) (x) - Combustion
% row 16 (33) (20) - Tank Venting
% row 17 (34) (21) - Flare methane

% data raw rows for analysis for different systems

gas_rows = [6 7 8 9 10 11 12 13 14 15 16 17 20 21];
oil_rows = [6 7 8 9 10 11 12 13 14 15 16 17 20 21];

%% Replace completions and workovers with 
% Non-flaring C&W from GHGRP_Master

Gas.workovers = 2.3; % MTCH4/year
Gas.completions = 34.0; % MTCH4/year
Oil.workovers = 0; % MTCH4/year
Oil.completions = 68.5; % MTCH4/year

Gas.workovers = Gas.workovers *(1/1000); %Tg/year
Gas.completions = Gas.completions *(1/1000); %Tg/year
Oil.workovers = Oil.workovers *(1/1000); %Tg/year
Oil.completions = Oil.completions *(1/1000); %Tg/year

%% Combustion emissions output from combustion.v1

Gas.Combustion = 0.0983; % Tg/year

%% EXTEND MATRIX
firstrow = 0;
    for i = 1:60
        matpart = data(data(:,1) == i, :);
        [m,n] = size(matpart);

        % The length of the matrix is transformed to the count of actual
        % wells
        % matpart(1,3) = sample = (actual wells) / (sampled wells)
        % (actual wells) = sample * (sampled wells)
        if m > 0
            len = ceil(matpart(1,3)*m);

            % Extend the matrix to the count of actual wells using Matlab's
            % "repmat" function (duplicates copies of the matrix proportional
            % to (actual wells/sampled wells)
            matpartextend = repmat(matpart,ceil(len/m),1);
            matpartextend = matpartextend(1:len,:);
        end
        
        if m > 0 && firstrow == 0
            matpartextend_full = matpartextend;
            firstrow = 1;
        elseif m > 0 && firstrow == 1
            matpartextend_full = vertcat(matpartextend_full,matpartextend);
        else
            % Do nothing
        end
    end

    % The emissions matrix is broken out as follows:
    % drygas : Gas wells with no oil production
    % gaswoil : Gas wells with oil production and GOR > 100 Mscf/bbl
    
    data = matpartextend_full;
    dataplot.gas = matpartextend_full;
    dataplot.gas(:,22) = sum(dataplot.gas(:,6:21),2);
    dataplot.gas(:,23) = dataplot.gas(:,22)./dataplot.gas(:,4);

    dataplot.drygas = dataplot.gas((dataplot.gas(:,1) < 31),:);
    dataplot.gaswoil = dataplot.gas((dataplot.gas(:,1) > 30 & data(:,1) < 61),:);
    
counter = 0;
for i = 1:17
    if i < 15
        index = i + 5;
    elseif i == 15
        index = 99;
    else
        index = i + 4;
    end
    if ismember(index,gas_rows)
        counter = counter + 1;
        equip_emissions = data(:,gas_rows(counter));
        equip_emissions(equip_emissions==0) = NaN;
        ind = isnan(equip_emissions);
        equip_emissions = equip_emissions(~ind);
        if ~isempty(equip_emissions)
            SortC = sort(equip_emissions,'descend');
            SumC = nansum(equip_emissions);
            NormSortC = SortC/SumC;
            CumCNorm = cumsum(NormSortC);
            CumC = cumsum(SortC);
            Perc5Location(i) = ceil(length(equip_emissions)*0.05);

    % Parameters
            ContributionPerc5(i) = CumC(Perc5Location(i));
            ContributionPerc5Norm(i) = CumCNorm(Perc5Location(i));
            Minimum(i) = min(equip_emissions);
            Maximum(i) = max(equip_emissions);
            Average(i) = mean(equip_emissions);
            MedC(i) = median(equip_emissions);
            SumEmissions(i) = sum(equip_emissions);
        end
    end 
end

%% Oil equipment

data= dataraw;
[rows, columns] = size(data);

%% EXTEND MATRIX
firstrow = 0;
    for i = 61:74
        matpart = data(data(:,1) == i, :);
        [m,n] = size(matpart);
                
        % The length of the matrix is transformed to the count of actual
        % wells
        % matpart(1,3) = sample = (actual wells) / (sampled wells)
        % (actual wells) = sample * (sampled wells)
        
        if m > 0
            len = ceil(matpart(1,3)*m);

            % Extend the matrix to the count of actual wells using Matlab's
            % "repmat" function (duplicates copies of the matrix proportional
            % to (actual wells/sampled wells)

            matpartextend = repmat(matpart,ceil(len/m),1);
            matpartextend = matpartextend(1:len,:);
        end
        
        if m > 0 && firstrow == 0
            matpartextend_full = matpartextend;
            firstrow = 1;
        elseif m > 0 && firstrow == 1
            matpartextend_full = vertcat(matpartextend_full,matpartextend);
        else
            % Do nothing
        end
    end

    data = matpartextend_full;

    % The emissions matrix is broken out as follows:
    % oil : Oil wells with no gas production
    % gaswoil : Oil wells with gas production and GOR < 100 Mscf/bbl
    
    dataplot.assoc = data(data(:,1) < 71 & data(:,1) > 60,:);
    dataplot.assoc(:,22) = sum(dataplot.assoc(:,6:21),2);
    dataplot.assoc(:,23) = dataplot.assoc(:,22)./dataplot.assoc(:,4);
%     dataplot.assoc(:,1) = dataplot.assoc(:,1) + 60;
    dataplot.assoc(:,1) = dataplot.assoc(:,1);

    dataplot.oil = data(data(:,1) > 70,:);
    dataplot.oil(:,22) = sum(dataplot.oil(:,6:21),2);
    dataplot.oil(:,23) = dataplot.oil(:,22)./dataplot.oil(:,4);
%     dataplot.oil(:,1) = dataplot.oil(:,1) + 60;
    dataplot.oil(:,1) = dataplot.oil(:,1);

counter = 0;
for i = 1:17
    if i < 15
        index = i + 5;
    elseif i == 15
        index = 99;
    else
        index = i + 4;
    end
    if ismember(index,oil_rows)
        counter = counter + 1;
        equip_emissions = data(:,oil_rows(counter));
        equip_emissions(equip_emissions==0) = NaN;
        ind = isnan(equip_emissions);
        equip_emissions = equip_emissions(~ind);
        if ~isempty(equip_emissions)
            SortC = sort(equip_emissions,'descend');
            SumC = nansum(equip_emissions);
            NormSortC = SortC/SumC;
            CumCNorm = cumsum(NormSortC);
            CumC = cumsum(SortC);
            Perc5Location(i + 17) = ceil(length(equip_emissions)*0.05);

    % Parameters
            ContributionPerc5(i + 17) = CumC(Perc5Location(i + 17));
            ContributionPerc5Norm(i + 17) = CumCNorm(Perc5Location(i + 17));
            Minimum(i + 17) = min(equip_emissions);
            Maximum(i + 17) = max(equip_emissions);
            Average(i + 17) = mean(equip_emissions);
            MedC(i + 17) = median(equip_emissions);
            SumEmissions(i + 17) = sum(equip_emissions);
        end
    end 
end
    
 
% Convert our data from kg/day to Tg/year
Study.Gas = SumEmissions(1:17) * 365/10^9;

Superemitters = sum(ContributionPerc5) * 365/10^9;

Study.Oil = SumEmissions(18:34) * 365/10^9;

% REPLACE COMPLETIONS AND WORKOVERS
Study.Gas(13) = Gas.completions;
Study.Gas(14) = Gas.workovers;
Study.Gas(15) = Gas.Combustion;

Study.Oil(13) = Oil.completions;
Study.Oil(14) = Oil.workovers;

% Combustion emissions are added to the site-level vectors
filepath = fullfile(pwd, activityfolder,'EF_Comp_v2');
load(filepath);

if Basin_Select ~= 0
    n_compressors = AF_basin(1,7)*...
        (length(dataplot.drygas(:,1)) + length(dataplot.gaswoil(:,1)) + ...
        length(dataplot.assoc(:,1)) + length(dataplot.oil(:,1)));
    
    if n_compressors < 35298 %number of comressors in US (Rutherford et al 2021)
        newlength = length(EF) * (n_compressors/35298);
        newlength = round(newlength);
        newlength = int16(newlength);
        EF = EF(randperm(length(EF)));
        EF = EF(1:newlength);
    end

end
    
gas_length = length(dataplot.drygas(:,1)) + length(dataplot.gaswoil(:,1));
if gas_length > length(EF)
    addlength = length(dataplot.drygas(:,1)) + length(dataplot.gaswoil(:,1));
    EF = [EF; zeros(addlength - length(EF),1)];
end

EF = EF(randperm(length(EF)));

if k == 1
    if welloption == 1
        
        welldata.drygas = dataplot.drygas(:,[1 22]);
        welldata.gaswoil = dataplot.gaswoil(:,[1 22]);
        
        welldata.drygas(:,2) = welldata.drygas(:,2) + EF(1:length(dataplot.drygas(:,1)));
%          if gas_length > length(EF)
            welldata.gaswoil(:,2) = welldata.gaswoil(:,2) + EF((length(dataplot.drygas(:,1))+1):end);
            Gas.Combustion = sum(EF)*365/10^9; % Tg/year
            Study.Gas(15) = Gas.Combustion;
%          else
%              welldata.gaswoil(:,2) = welldata.gaswoil(:,2) + EF((length(dataplot.drygas(:,1))+1):gas_length);
%              Gas.Combustion = sum(EF((length(dataplot.drygas(:,1))+1):gas_length))*365/10^9; % Tg/year
%              Study.Gas(15) = Gas.Combustion;
%          end
        welldata.assoc = dataplot.assoc(:,[1 22]);
        welldata.oil = dataplot.oil(:,[1 22]);


% 
%         fprintf('Welldata, iter %g total = %d \n',k,(sum(welldata.drygas(:,2)) + sum(welldata.gaswoil(:,2)) + sum(welldata.assoc(:,2)) + sum(welldata.oil(:,2)))*(365)/1000000000)
%         x = 1;
    end
    Study.All = [Study.Gas', Study.Oil'];
    
    printtotal_mmbbl = sum(dataplot.drygas(:,2,k))*(365)/1000000 +...
                 sum(dataplot.gaswoil(:,2,k))*(365)/1000000 +...
                 sum(dataplot.assoc(:,2,k))*(365)/1000000 +...
                 sum(dataplot.oil(:,2,k))*(365)/1000000;
    printtotal_Bscf = sum(dataplot.drygas(:,5,k))*(365)/1000000000 +...
                 sum(dataplot.gaswoil(:,5,k))*(365)/1000000000 +...
                 sum(dataplot.assoc(:,5,k))*(365)/1000000000 +...
                 sum(dataplot.oil(:,5,k))*(365)/1000000000;        
    
    Enverus_mmbbl = Enverus_tab{2,3}+Enverus_tab{3,3};
    Enverus_Bscf = Enverus_tab{2,4}+Enverus_tab{3,4};

    fprintf('dataplot - oil, iter 1 total = %d \n',printtotal_mmbbl)
    fprintf('dataplot - gas, iter 1 total = %d \n',printtotal_Bscf)
    fprintf('Enverus - oil, total = %d \n',Enverus_mmbbl)
    fprintf('Enverus - gas, total = %d \n',Enverus_Bscf)
    
else

    if welloption == 1
        
        welldata.drygas(:,:,k) = dataplot.drygas(:,[1 22]);
        welldata.gaswoil(:,:,k) = dataplot.gaswoil(:,[1 22]);
        
        welldata.drygas(:,2,k) = welldata.drygas(:,2,k) + EF(1:length(dataplot.drygas(:,1)));
%          if gas_length > length(EF)
            welldata.gaswoil(:,2,k) = welldata.gaswoil(:,2,k) + EF((length(dataplot.drygas(:,1))+1):end);
            Gas.Combustion = sum(EF)*365/10^9; % Tg/year
            Study.Gas(15) = Gas.Combustion;
%          else
%              welldata.gaswoil(:,2,k) = welldata.gaswoil(:,2,k) + EF((length(dataplot.drygas(:,1))+1):gas_length);
%              Gas.Combustion = sum(EF((length(dataplot.drygas(:,1))+1):gas_length))*365/10^9; % Tg/year
%              Study.Gas(15) = Gas.Combustion;
%          end

        welldata.assoc(:,:,k) = dataplot.assoc(:,[1 22]);
        welldata.oil(:,:,k) = dataplot.oil(:,[1 22]);

% 
%         fprintf('Welldata - drygas, iter %g wells = %d \n',k,length(welldata.drygas(:,2,k)))
%         fprintf('Welldata - gaswoil, iter %g wells = %d \n',k,length(welldata.gaswoil(:,2,k)))
%         fprintf('Welldata - assoc, iter %g wells = %d \n',k,length(welldata.assoc(:,2,k)))
%         fprintf('Welldata - oil, iter %g wells = %d \n',k,length(welldata.oil(:,2,k)))        
%         
%         fprintf('Welldata, iter %g total = %d \n',k,(sum(welldata.drygas(:,2,k)) + sum(welldata.gaswoil(:,2,k)) + sum(welldata.assoc(:,2,k)) + sum(welldata.oil(:,2,k)))*(365)/1000000000)
    end
    Study.All = [Study.Gas', Study.Oil'];
end

if equipoption == 1
    equipdata.drygas = [dataplot.drygas(:,6:21) dataplot.drygas(:,1) dataplot.drygas(:,4) dataplot.drygas(:,5)];
    equipdata.gaswoil = [dataplot.gaswoil(:,6:21) dataplot.gaswoil(:,1) dataplot.gaswoil(:,4) dataplot.gaswoil(:,5)];
    equipdata.assoc = [dataplot.assoc(:,6:21) dataplot.assoc(:,1) dataplot.assoc(:,4) dataplot.assoc(:,5)];
    equipdata.oil = [dataplot.oil(:,6:21) dataplot.oil(:,1) dataplot.oil(:,4) dataplot.oil(:,5)];
end

% Study.All = sum(Study.All,2);
EmissionsGas = Study.All(:,1);
EmissionsOil = Study.All(:,2);

fprintf('%d \n',k,(sum(EmissionsGas(1:12)) + sum(EmissionsGas(15:17)) + sum(EmissionsOil(1:12)) + sum(EmissionsOil(15:17))))




