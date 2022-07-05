function [EF_flare] = flaring(Emissions, Activity, j)
% Our general approach to calculating methane emissions from flare stacks
% is similar to the GHGRP. Here, the user can edit the probability of an
% unlit flare and flare efficiency is based on Gvakharia, who conducted
% aerial surveys in the Bakken region.

IsUnlit = rand;

% Probability of an unlit flare
a = 0.03; b = 0.07;
Unlit_Frac = ((b-a)*rand)+a;

% Calculate an unlit efficiency (important for maintaining mass balance at
% marginal wells
if (Activity.prod_kg(j)/Activity.wells(j))<10
    Unlit_Eff = 0.2;
else
    Unlit_Eff = 0.05;
end

if IsUnlit < Unlit_Frac
    % Unlit flaring efficiency
    Eff = Unlit_Eff;
else
    % Lit flaring efficiency
    RandomIndex = ceil(rand*98);
    Eff = (1 - Emissions.gvakharia(RandomIndex));
end
% kg CH4/well/day
EF_flare = (Activity.prod_scf(j)/Activity.wells(j))*((16.041 * 1.20233 * (Activity.frac_C1(j) / 100)) / 1000)*(1 - Eff);

end
