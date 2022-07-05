function [EF_LU] = liquidsunloadings(Emissions, Activity, j)
% Liquids unloading data are obtained from Allen et al. (2015)
% Direct measurement data in Allen et al. is available for wells both with
% and without plunger lifts. The primary activity dataset should be
% partioned within tranches to indicate LU type for wells (1 = plunger, 2 =
% no plunger, 3 or empty = no liquids unloading). Emission factor
% distributions are corrected for the average number of unloading events
% per year per well.

% Draw random number
RandomIndex = ceil(rand*1000);

% Draw emission factor from dataset based on indicated LU Type
if Activity.LU(j) == 1
    
    % kg CH4/well/day
    EF_LU = Emissions.LU(1,RandomIndex);
elseif Activity.LU(j) == 2
    
    % kg CH4/well/day
    EF_LU = Emissions.LU(2,RandomIndex);
else
    EF_LU = 0;
end

end
