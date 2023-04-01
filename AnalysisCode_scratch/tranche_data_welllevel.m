function [tranche] = tranche_data_welllevel(M)

%(i) Separate by categories
    
    %   Dry gas from gas wells
%         ind.drygas = logind(:,1);
%         ind.drygas = int16(ind.drygas);
%         M.drygas = M.raw(ind.drygas == 1,:);
    
        ind.i1 = M.drygas(:,2) < 1;
        ind.i2 = M.drygas(:,2) > 1 & M.drygas(:,2) < 5;
        ind.i3 = M.drygas(:,2) > 5 & M.drygas(:,2) < 10;
        ind.i4 = M.drygas(:,2) > 10 & M.drygas(:,2) < 20;
        ind.i5 = M.drygas(:,2) > 20 & M.drygas(:,2) < 50;
        ind.i6 = M.drygas(:,2) > 50 & M.drygas(:,2) < 100;
        ind.i7 = M.drygas(:,2) > 100 & M.drygas(:,2) < 500;
        ind.i8 = M.drygas(:,2) > 500 & M.drygas(:,2) < 1000;
        ind.i9 = M.drygas(:,2) > 1000 & M.drygas(:,2) < 10000;
        ind.i10 = M.drygas(:,2) > 10000;

        tranche.i1 = M.drygas(ind.i1,:);
        tranche.i2 = M.drygas(ind.i2,:);
        tranche.i3 = M.drygas(ind.i3,:);
        tranche.i4 = M.drygas(ind.i4,:);
        tranche.i5 = M.drygas(ind.i5,:);
        tranche.i6 = M.drygas(ind.i6,:);
        tranche.i7 = M.drygas(ind.i7,:);
        tranche.i8 = M.drygas(ind.i8,:);
        tranche.i9 = M.drygas(ind.i9,:);
        tranche.i10 = M.drygas(ind.i10,:);
        
    %   Gas with associated oil
%         ind.gaswoil = logind(:,3);
%         ind.gaswoil = int16(ind.gaswoil);
%         M.gaswoil = M.raw(ind.gaswoil == 1,:);
    
        ind.i11 = M.gaswoil(:,2) < 1;
        ind.i12 = M.gaswoil(:,2) > 1 & M.gaswoil(:,2) < 5;
        ind.i13 = M.gaswoil(:,2) > 5 & M.gaswoil(:,2) < 10;
        ind.i14 = M.gaswoil(:,2) > 10 & M.gaswoil(:,2) < 20;
        ind.i15 = M.gaswoil(:,2) > 20 & M.gaswoil(:,2) < 50;
        ind.i16 = M.gaswoil(:,2) > 50 & M.gaswoil(:,2) < 100;
        ind.i17 = M.gaswoil(:,2) > 100 & M.gaswoil(:,2) < 500;
        ind.i18 = M.gaswoil(:,2) > 500 & M.gaswoil(:,2) < 1000;
        ind.i19 = M.gaswoil(:,2) > 1000 & M.gaswoil(:,2) < 10000;
        ind.i20 = M.gaswoil(:,2) > 10000;

        tranche.i11 = M.gaswoil(ind.i11,:);
        tranche.i12 = M.gaswoil(ind.i12,:);
        tranche.i13 = M.gaswoil(ind.i13,:);
        tranche.i14 = M.gaswoil(ind.i14,:);
        tranche.i15 = M.gaswoil(ind.i15,:);
        tranche.i16 = M.gaswoil(ind.i16,:);
        tranche.i17 = M.gaswoil(ind.i17,:);
        tranche.i18 = M.gaswoil(ind.i18,:);
        tranche.i19 = M.gaswoil(ind.i19,:);
        tranche.i20 = M.gaswoil(ind.i20,:);

    %   Oil only
%         ind.oil = logind(:,2);
%         ind.oil = int16(ind.oil);
%         M.oil = M.raw(ind.oil == 1,:);    
        
        ind.i31 = M.oil(:,2) < 0.5;
        ind.i32 = M.oil(:,2) > 0.5 & M.oil(:,2) < 1;
        ind.i33 = M.oil(:,2) > 1 & M.oil(:,2) < 10;
        ind.i34 = M.oil(:,2) > 10;

        tranche.i31 = M.oil(ind.i31,:);
        tranche.i32 = M.oil(ind.i32,:);
        tranche.i33 = M.oil(ind.i33,:);
        tranche.i34 = M.oil(ind.i34,:);
        
    %   Oil with gas
%         ind.oilwgas = logind(:,4);
%         ind.oilwgas = int16(ind.oilwgas);
%         M.oilwgas = M.raw(ind.oilwgas == 1,:);      

        ind.i21 = M.oilwgas(:,2) < 1;
        ind.i22 = M.oilwgas(:,2) > 1 & M.oilwgas(:,2) < 5;
        ind.i23 = M.oilwgas(:,2) > 5 & M.oilwgas(:,2) < 10;
        ind.i24 = M.oilwgas(:,2) > 10 & M.oilwgas(:,2) < 20;
        ind.i25 = M.oilwgas(:,2) > 20 & M.oilwgas(:,2) < 50;
        ind.i26 = M.oilwgas(:,2) > 50 & M.oilwgas(:,2) < 100;
        ind.i27 = M.oilwgas(:,2) > 100 & M.oilwgas(:,2) < 500;
        ind.i28 = M.oilwgas(:,2) > 500 & M.oilwgas(:,2) < 1000;
        ind.i29 = M.oilwgas(:,2) > 1000 & M.oilwgas(:,2) < 10000;
        ind.i30 = M.oilwgas(:,2) > 10000;

        tranche.i21 = M.oilwgas(ind.i21,:);
        tranche.i22 = M.oilwgas(ind.i22,:);
        tranche.i23 = M.oilwgas(ind.i23,:);
        tranche.i24 = M.oilwgas(ind.i24,:);
        tranche.i25 = M.oilwgas(ind.i25,:);
        tranche.i26 = M.oilwgas(ind.i26,:);
        tranche.i27 = M.oilwgas(ind.i27,:);
        tranche.i28 = M.oilwgas(ind.i28,:);
        tranche.i29 = M.oilwgas(ind.i29,:);
        tranche.i30 = M.oilwgas(ind.i30,:);
        
