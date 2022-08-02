clear;
clc;

root_path = 'C:\Users\jruthe\BU_methane_model\Archive_OPGEEProxyCH4Version';

prod_index = 1;

ColorMat = [140/255,21/255,21/255;...%Stanford red
    233/255,131/255,0/255;...% Stanford orange
    234/255,171/255,0/255;...% Stanford yello
    0/255,155/255,118/255;...% Stanford light green
    23/255,94/255,84/255;... % Stanford dark green
    0/255,152/255,219/255;...% Stanford blue
    83/255,40/255,79/255;... % Stanford purple
    0.66, 0.66, 0.66;...
    140/255,21/255,21/255;...%Stanford red
    233/255,131/255,0/255;...% Stanford orange
    234/255,171/255,0/255;...% Stanford yello
    0/255,155/255,118/255;...% Stanford light green
    23/255,94/255,84/255;... % Stanford dark green
    0/255,152/255,219/255];

load('Mat_LFR_22.1.8.mat')
load('Mat_AFR_22.1.8.mat')
sampling_AF1.gas = sampling_AF.gas;
sampling_AF1.oil = sampling_AF.oil;
Mat_LHS1.Gas = Mat_LHS.Gas;
Mat_LHS1.Oil = Mat_LHS.Oil;
load('Mat_LFR_22.1.21.mat')
load('Mat_AFR_22.1.21.mat')
sampling_AF2.gas = sampling_AF.gas;
sampling_AF2.oil = sampling_AF.oil;
Mat_LHS2.Gas = Mat_LHS.Gas;
Mat_LHS2.Oil = Mat_LHS.Oil;
load('Mat_LFR_22.1.22.mat')
load('Mat_AFR_22.1.22.mat')
sampling_AF3.gas = sampling_AF.gas;
sampling_AF3.oil = sampling_AF.oil;
Mat_LHS3.Gas = Mat_LHS.Gas;
Mat_LHS3.Oil = Mat_LHS.Oil;


load('Mat_base_22.1.8.mat')

sampling_AF.gas = cat(1,sampling_AF1.gas,sampling_AF2.gas, sampling_AF3.gas);
sampling_AF.oil = cat(1,sampling_AF1.oil,sampling_AF2.oil, sampling_AF3.oil);
Mat_LHS.Oil = cat(3,Mat_LHS1.Oil, Mat_LHS2.Oil, Mat_LHS3.Oil);
Mat_LHS.Gas = cat(3,Mat_LHS1.Gas, Mat_LHS2.Gas, Mat_LHS3.Gas);

Equipment = {...
    'Wells',...         % (1)
    'Headers',...       % (2)
    'Heaters',...       % (3)
    'Separators',...    % (4)
    'Meters',...        % (5)
    'TanksLeaks',... % (6)
    'TanksUpset',... % (7)
    'Compressors',...   % (8)
    'Dehydrators',...   % (9)
    'InjPumps',...     % (10)
    'PneumControls',...% (11)
    };

% This table is for figure generation
AFR_table = [0.25 1;
             0.5  1;
             0.75 1;
             1    1;
             1.5  1;
             2    1;
             4    1;
             0.25 0.5;
             0.5  0.5;
             0.75 0.5;
             1    0.5;
             1.5  0.5;
             2    0.5;
             4    0.5;
             0.25 2;
             0.5  2;
             0.75 2;
             1    2;
             1.5  2;
             2    2;
             4    2];
             
if prod_index == 1
    n = length(sampling_AF.gas);
    sampling_AF.gas = array2table(sampling_AF.gas,'VariableNames',Equipment);
    sampling_AF.gas_ones = array2table(ones(1,11),'VariableNames',Equipment);
    % For gas systems remove zeros and variables that don't change
    %   - wells (row 1)
    %   - Headers (row 2)

    sampling_AF.gas = sampling_AF.gas(:,[3:11]);
    sampling_AF.gas_ones = sampling_AF.gas_ones(:,[3:11]);
    % sampling_AF.gas = [ones(1,9); sampling_AF.gas];
    % Divide M_LHS by M_Base for LFR

    Mat_LFR.Gas = Mat_LHS.Gas([3:11],:,:)./Mat_base.Gas([3:11],:);
    % Mat_LFR.Gas = [ones(1,9); Mat_LFR.Gas];
else
    n = length(sampling_AF.oil);
    sampling_AF.oil = array2table(sampling_AF.oil,'VariableNames',Equipment);
    sampling_AF.oil_ones = array2table(ones(1,11),'VariableNames',Equipment);
    % For gas systems remove zeros and variables that don't change
    %   - wells      (row 1)
    %   - meters     (row 5)
    %   - compressor (row 8)
    %   - dehydrator (row 9)

    sampling_AF.oil = sampling_AF.oil(:,[2,3,4,6,7,10,11]);
    sampling_AF.oil_ones = sampling_AF.oil_ones(:,[2,3,4,6,7,10,11]);
    % sampling_AF.oil = [ones(1,7); sampling_AF.oil];
    % Divide M_LHS by M_Base for LFR

    Mat_LFR.Oil = Mat_LHS.Oil([2,3,4,6,7,10,11],:,:)./Mat_base.Oil([2,3,4,6,7,10,11],:); 
    % Mat_LFR.Oil = [ones(1,7); Mat_LFR.Oil];
end

%% Re-binning data into groups of 3 instead of 10 tranches
                          

%% Training and testing the model
test_frac= 0.2;

hpartition = cvpartition(n,'Holdout',test_frac);
idxTrain = training(hpartition);
idxNew = test(hpartition);

if prod_index == 1
    for i = 1:9
        figure(i)
        ha = tight_subplot(2,2,0.05,[.08 .02],[.08 .02]);
        for j = 1:3

            if j == 1
                
%                 hpartition = cvpartition(n,'Holdout',test_frac);
%                 idxTrain = training(hpartition);
%                 idxNew = test(hpartition);
                 
                Mat_LFR_gasreduced.set1 = cat(2,squeeze(Mat_LFR.Gas(:,1,idxTrain))...
                                               ,squeeze(Mat_LFR.Gas(:,2,idxTrain))...
                                               ,squeeze(Mat_LFR.Gas(:,3,idxTrain)));
                
                all_test_gasreduced.set1 = cat(1,squeeze(sum(Mat_LHS.Gas([3:11],1,idxNew),1))...
                                ,squeeze(sum(Mat_LHS.Gas([3:11],2,idxNew),1))...
                                ,squeeze(sum(Mat_LHS.Gas([3:11],3,idxNew),1)));
                                           
                Y = Mat_LFR_gasreduced.set1(i,:)';
%                 Y = squeeze(Y);
                X = repmat(sampling_AF.gas(idxTrain,:),3,1);
                
                % weights are covered in the Excel spreadsheet ________
                
                weights = [90000;...
                            repmat(1,15000*(1-test_frac),1);...
                            repmat(1.76,15000*(1-test_frac),1);...
                            repmat(1.22,15000*(1-test_frac),1)];
                
                tblNew = repmat(sampling_AF.gas(idxNew,:),3,1);
                
                Ynew = cat(1,squeeze(Mat_LFR.Gas(i,1,idxNew))...
                                               ,squeeze(Mat_LFR.Gas(i,2,idxNew))...
                                               ,squeeze(Mat_LFR.Gas(i,3,idxNew)));
                
            elseif j == 2
                
%                 hpartition = cvpartition(n,'Holdout',test_frac);
%                 idxTrain = training(hpartition);
%                 idxNew = test(hpartition);
                
                Mat_LFR_gasreduced.set2 = cat(2,squeeze(Mat_LFR.Gas(:,4,idxTrain))...
                                               ,squeeze(Mat_LFR.Gas(:,5,idxTrain))...
                                               ,squeeze(Mat_LFR.Gas(:,6,idxTrain))...
                                               ,squeeze(Mat_LFR.Gas(:,7,idxTrain))); 
                
                all_test_gasreduced.set2 = cat(1,squeeze(sum(Mat_LHS.Gas([3:11],4,idxNew),1))...
                                ,squeeze(sum(Mat_LHS.Gas([3:11],5,idxNew),1))...
                                ,squeeze(sum(Mat_LHS.Gas([3:11],6,idxNew),1))...
                                ,squeeze(sum(Mat_LHS.Gas([3:11],7,idxNew),1)));
                                           
                Y = Mat_LFR_gasreduced.set2(i,:)';
%                 Y = squeeze(Y);
                X = repmat(sampling_AF.gas(idxTrain,:),4,1);               
                
                % weights are covered in the Excel spreadsheet ________
                
                weights = [120000;...
                            repmat(1,15000*(1-test_frac),1);...
                            repmat(1.63,15000*(1-test_frac),1);...
                            repmat(1.07,15000*(1-test_frac),1);...
                            repmat(1.14,15000*(1-test_frac),1)];

                tblNew = repmat(sampling_AF.gas(idxNew,:),4,1);
                
               Ynew = cat(1,squeeze(Mat_LFR.Gas(i,4,idxNew))...
                                               ,squeeze(Mat_LFR.Gas(i,5,idxNew))...
                                               ,squeeze(Mat_LFR.Gas(i,6,idxNew))...
                                               ,squeeze(Mat_LFR.Gas(i,7,idxNew))); 
                
            elseif j == 3
                                
%                 hpartition = cvpartition(n,'Holdout',test_frac);
%                 idxTrain = training(hpartition);
%                 idxNew = test(hpartition);
                
                Mat_LFR_gasreduced.set3 = cat(2,squeeze(Mat_LFR.Gas(:,8,idxTrain))...
                                               ,squeeze(Mat_LFR.Gas(:,9,idxTrain))...
                                               ,squeeze(Mat_LFR.Gas(:,10,idxTrain)));
                
                                            
                all_test_gasreduced.set3 = cat(1,squeeze(sum(Mat_LHS.Gas([3:11],8,idxNew),1))...
                                                ,squeeze(sum(Mat_LHS.Gas([3:11],9,idxNew),1))...
                                                ,squeeze(sum(Mat_LHS.Gas([3:11],10,idxNew),1)));
                                           
                Y = Mat_LFR_gasreduced.set3(i,:)';
%                 Y = squeeze(Y);
                X = repmat(sampling_AF.gas(idxTrain,:),3,1);
                
                % weights are covered in the Excel spreadsheet ________
                
                weights = [90000;...
                            repmat(90.10,15000*(1-test_frac),1);...
                            repmat(78.52,15000*(1-test_frac),1);...
                            repmat(1,15000*(1-test_frac),1)];

                tblNew = repmat(sampling_AF.gas(idxNew,:),3,1);
                
                Ynew = cat(1,squeeze(Mat_LFR.Gas(i,8,idxNew))...
                                               ,squeeze(Mat_LFR.Gas(i,9,idxNew))...
                                               ,squeeze(Mat_LFR.Gas(i,10,idxNew)));
                     
            end
            
            tblTrain = X;
            tblTrain = [sampling_AF.gas_ones; tblTrain];
            tblTrain = [sampling_AF.gas_ones; X];
            
            tblTrain_temp = tblTrain;
            tblTrain_temp(:,i) = [];
            
            tblTrain_Ave = mean(tblTrain_temp{:,1:end},2);
            tblTrain_New = array2table([tblTrain{:,i}, tblTrain_Ave],'VariableNames',{Equipment{i+2}, 'Other_Equip'});
            
            %Ytrain = [1; Y(idxTrain)];
            Ytrain = [1; Y];
            tblTrain_New.Response = Ytrain;

            mdl = fitlm(tblTrain_New,'quadratic','weights',weights,'Intercept',false);

            tblNew_temp = tblNew;
            tblNew_temp(:,i) = [];

            tblNew_Ave = mean(tblNew_temp{:,1:end},2);
            tblNew_New = array2table([tblNew{:,i}, tblNew_Ave],'VariableNames',{Equipment{i+2}, 'Other_Equip'});


            ypred = predict(mdl,tblNew_New);    
            
            if j == 1
                all_pred_gasreduced.set1(i,:) = ypred;
            elseif j == 2
                all_pred_gasreduced.set2(i,:) = ypred;
            elseif j == 3
                all_pred_gasreduced.set3(i,:) = ypred;
            end
            

            LFR_table(:,i,j) = predict(mdl,AFR_table);

            
            axes(ha(j));
            h1 = scatter(Ynew, ypred,4,'filled','MarkerFaceColor',ColorMat(i,:),'MarkerFaceAlpha',0.25);

            mdlfit = fitlm(Ynew, ypred);

            hold on
            h2 = line([0 3], [0 3], 'Color', 'black', 'LineStyle', '--');

            lgd = legend(h1, ...
            sprintf('R^{2} = %0.2f', mdlfit.Rsquared.Ordinary)...
            ,'Location','best');

            lgd.FontSize = 6;

            xlim([0 3])
            ylim([0 3])

            set(gca,'FontSize',8)
            set(gca,'FontName','Arial')

            CTable(:,j) = mdl.Coefficients.Estimate;
            
        end

        txtbox = annotation('textbox',[0.37 0.03 0.61 0.24],...
                'string',sprintf('%s \nTrain n = %d\nTest n = %d',...
                Equipment{i+2},length(Ytrain),length(Ynew)),...
                'BackgroundColor','w');

        cd(strcat(root_path,'\Outputs'))

        FileName = ['plot_' Equipment{i+2} 'out.emf'];
        print('-painters','-dmeta',FileName);

        FileName = ['LM' Equipment{i+2} '_Coef.csv']; 
        csvwrite(FileName,CTable);

        cd(root_path)   
    end
    
%     all_leakage_test = sum(Mat_LHS.Gas([3:11],:,:),1);
%     all_leakage_test = squeeze(all_leakage_test)';
%     all_leakage_test = all_leakage_test(idxNew,:);

                           
%     all_leakage_pred = all_leakage_pred .* Mat_base.Gas([3:11],:);
%     all_leakage_pred = sum(all_leakage_pred,1);
%     all_leakage_pred = squeeze(all_leakage_pred)';


all_pred_gasreduced.set1 = [sum(all_pred_gasreduced.set1(:,1:3000) .* Mat_base.Gas([3:11],1)),...
                            sum(all_pred_gasreduced.set1(:,3001:6000) .* Mat_base.Gas([3:11],2)),...
                            sum(all_pred_gasreduced.set1(:,6001:9000) .* Mat_base.Gas([3:11],3))]';
all_pred_gasreduced.set2 = [sum(all_pred_gasreduced.set2(:,1:3000) .* Mat_base.Gas([3:11],4)),...
                            sum(all_pred_gasreduced.set2(:,3001:6000) .* Mat_base.Gas([3:11],5)),...
                            sum(all_pred_gasreduced.set2(:,6001:9000) .* Mat_base.Gas([3:11],6)),...
                            sum(all_pred_gasreduced.set2(:,9001:12000) .* Mat_base.Gas([3:11],7))]';
all_pred_gasreduced.set3 = [sum(all_pred_gasreduced.set3(:,1:3000) .* Mat_base.Gas([3:11],8)),...
                            sum(all_pred_gasreduced.set3(:,3001:6000) .* Mat_base.Gas([3:11],9)),...
                            sum(all_pred_gasreduced.set3(:,6001:9000) .* Mat_base.Gas([3:11],10))]';


else
    for i = 1:7
        figure(i)
        ha = tight_subplot(2,2,0.05,[.08 .02],[.08 .02]);
        for j = 1:3
            
            if j == 1
                
%                 hpartition = cvpartition(n,'Holdout',test_frac);
%                 idxTrain = training(hpartition);
%                 idxNew = test(hpartition);
                
                Mat_LFR_oilreduced.set1 = cat(2,squeeze(Mat_LFR.Oil(:,1,idxTrain))...
                                               ,squeeze(Mat_LFR.Oil(:,2,idxTrain))...
                                               ,squeeze(Mat_LFR.Oil(:,3,idxTrain)));

                all_test_oilreduced.set1 = cat(1,squeeze(sum(Mat_LHS.Oil([2,3,4,6,7,10,11],1,idxNew),1))...
                                ,squeeze(sum(Mat_LHS.Oil([2,3,4,6,7,10,11],2,idxNew),1))...
                                ,squeeze(sum(Mat_LHS.Oil([2,3,4,6,7,10,11],3,idxNew),1)));
                                           
                Y = Mat_LFR_oilreduced.set1(i,:)';
%                 Y = squeeze(Y);
                X = repmat(sampling_AF.oil(idxTrain,:),3,1);
                
                % weights are covered in the Excel spreadsheet ________
                
                weights = [90000;...
                            repmat(4.45,15000*(1-test_frac),1);...
                            repmat(2.73,15000*(1-test_frac),1);...
                            repmat(1,15000*(1-test_frac),1)];
                
                tblNew = repmat(sampling_AF.oil(idxNew,:),3,1);
                
                Ynew = cat(1,squeeze(Mat_LFR.Oil(i,1,idxNew))...
                            ,squeeze(Mat_LFR.Oil(i,2,idxNew))...
                            ,squeeze(Mat_LFR.Oil(i,3,idxNew)));
                
            elseif j == 2
                
%                 hpartition = cvpartition(n,'Holdout',test_frac);
%                 idxTrain = training(hpartition);
%                 idxNew = test(hpartition);
                
                Mat_LFR_oilreduced.set2 = cat(2,squeeze(Mat_LFR.Oil(:,4,idxTrain))...
                                               ,squeeze(Mat_LFR.Oil(:,5,idxTrain))...
                                               ,squeeze(Mat_LFR.Oil(:,6,idxTrain))...
                                               ,squeeze(Mat_LFR.Oil(:,7,idxTrain))); 

                
                all_test_oilreduced.set2 = cat(1,squeeze(sum(Mat_LHS.Oil([2,3,4,6,7,10,11],4,idxNew),1))...
                                ,squeeze(sum(Mat_LHS.Oil([2,3,4,6,7,10,11],5,idxNew),1))...
                                ,squeeze(sum(Mat_LHS.Oil([2,3,4,6,7,10,11],6,idxNew),1))...
                                ,squeeze(sum(Mat_LHS.Oil([2,3,4,6,7,10,11],7,idxNew),1)));
                                           
                Y = Mat_LFR_oilreduced.set2(i,:)';
%                 Y = squeeze(Y);
                X = repmat(sampling_AF.oil(idxTrain,:),4,1);               
                
                % weights are covered in the Excel spreadsheet ________
                
                weights = [120000;...
                            repmat(1.44,15000*(1-test_frac),1);...
                            repmat(1.69,15000*(1-test_frac),1);...
                            repmat(1,15000*(1-test_frac),1);...
                            repmat(1.30,15000*(1-test_frac),1)];

                tblNew = repmat(sampling_AF.oil(idxNew,:),4,1);
                
               Ynew = cat(1,squeeze(Mat_LFR.Oil(i,4,idxNew))...
                                               ,squeeze(Mat_LFR.Oil(i,5,idxNew))...
                                               ,squeeze(Mat_LFR.Oil(i,6,idxNew))...
                                               ,squeeze(Mat_LFR.Oil(i,7,idxNew))); 
                
            elseif j == 3
                                
%                 hpartition = cvpartition(n,'Holdout',test_frac);
%                 idxTrain = training(hpartition);
%                 idxNew = test(hpartition);
                
                Mat_LFR_oilreduced.set3 = cat(2,squeeze(Mat_LFR.Oil(:,8,idxTrain))...
                                               ,squeeze(Mat_LFR.Oil(:,9,idxTrain))...
                                               ,squeeze(Mat_LFR.Oil(:,10,idxTrain)));

                                            
                all_test_oilreduced.set3 = cat(1,squeeze(sum(Mat_LHS.Oil([2,3,4,6,7,10,11],8,idxNew),1))...
                                                ,squeeze(sum(Mat_LHS.Oil([2,3,4,6,7,10,11],9,idxNew),1))...
                                                ,squeeze(sum(Mat_LHS.Oil([2,3,4,6,7,10,11],10,idxNew),1)));
                                           
                Y = Mat_LFR_oilreduced.set3(i,:)';
%                 Y = squeeze(Y);
                X = repmat(sampling_AF.oil(idxTrain,:),3,1);
                
                % weights are covered in the Excel spreadsheet ________
                
                weights = [90000;...
                            repmat(20.92,15000*(1-test_frac),1);...
                            repmat(12.83,15000*(1-test_frac),1);...
                            repmat(1,15000*(1-test_frac),1)];

                tblNew = repmat(sampling_AF.oil(idxNew,:),3,1);
                
                Ynew = cat(1,squeeze(Mat_LFR.Oil(i,8,idxNew))...
                                               ,squeeze(Mat_LFR.Oil(i,9,idxNew))...
                                               ,squeeze(Mat_LFR.Oil(i,10,idxNew)));
                     
            end
            
            
            equip_index = [2,3,4,6,7,10,11];

            tblTrain = X;
            tblTrain = [sampling_AF.oil_ones; tblTrain];
            tblTrain = [sampling_AF.oil_ones; X];
            
            tblTrain_temp = tblTrain;
            tblTrain_temp(:,i) = [];
            
            tblTrain_Ave = mean(tblTrain_temp{:,1:end},2);
            tblTrain_New = array2table([tblTrain{:,i}, tblTrain_Ave],'VariableNames',{Equipment{equip_index(i)}, 'Other_Equip'});
            
            %Ytrain = [1; Y(idxTrain)];
            Ytrain = [1; Y];
            tblTrain_New.Response = Ytrain;

            mdl = fitlm(tblTrain_New,'quadratic','weights',weights,'Intercept',false);
            
            tblNew_temp = tblNew;
            tblNew_temp(:,i) = [];
            
            tblNew_Ave = mean(tblNew_temp{:,1:end},2);
            tblNew_New = array2table([tblNew{:,i}, tblNew_Ave],'VariableNames',{Equipment{equip_index(i)}, 'Other_Equip'});
                        

            ypred = predict(mdl,tblNew_New);    

            if j == 1
                all_pred_oilreduced.set1(i,:) = ypred;
            elseif j == 2
                all_pred_oilreduced.set2(i,:) = ypred;
            elseif j == 3
                all_pred_oilreduced.set3(i,:) = ypred;
            end
            
            
            LFR_table(:,i,j) = predict(mdl,AFR_table);
            
            axes(ha(j));
            h1 = scatter(Ynew, ypred,4,'filled','MarkerFaceColor',ColorMat(i,:),'MarkerFaceAlpha',0.25);

            mdlfit = fitlm(Ynew, ypred);

            hold on
            h2 = line([0 3], [0 3], 'Color', 'black', 'LineStyle', '--');

            lgd = legend(h1, ...
            sprintf('R^{2} = %0.2f', mdlfit.Rsquared.Ordinary)...
            ,'Location','best');

            lgd.FontSize = 6;

            xlim([0 3])
            ylim([0 3])

            set(gca,'FontSize',8)
            set(gca,'FontName','Arial')

            CTable(:,j) = mdl.Coefficients.Estimate;

        end
        equip_index = [2,3,4,6,7,10,11];
        txtbox = annotation('textbox',[0.37 0.03 0.61 0.24],...
                'string',sprintf('%s \nTrain n = %d\nTest n = %d',...
                Equipment{equip_index(i)},length(Ytrain),length(Ynew)),...
                'BackgroundColor','w');

        cd(strcat(root_path,'\Outputs'))

        FileName = ['plot_' Equipment{equip_index(i)} 'out.emf'];
        print('-painters','-dmeta',FileName);

        FileName = ['LM' Equipment{equip_index(i)} '_Coef.csv']; 
        csvwrite(FileName,CTable);

        cd(root_path)   
    end
    
%     all_leakage_test = sum(Mat_LHS.Oil([2,3,4,6,7,10,11],:,:),1);
%     all_leakage_test = squeeze(all_leakage_test)';
%     all_leakage_test = all_leakage_test(idxNew,:);
% 
%     all_leakage_pred = all_leakage_pred .* Mat_base.Oil([2,3,4,6,7,10,11],:);
%     all_leakage_pred = sum(all_leakage_pred,1);
%     all_leakage_pred = squeeze(all_leakage_pred)';

all_pred_oilreduced.set1 = [sum(all_pred_oilreduced.set1(:,1:3000) .* Mat_base.Oil([2,3,4,6,7,10,11],1)),...
                            sum(all_pred_oilreduced.set1(:,3001:6000) .* Mat_base.Oil([2,3,4,6,7,10,11],2)),...
                            sum(all_pred_oilreduced.set1(:,6001:9000) .* Mat_base.Oil([2,3,4,6,7,10,11],3))]';
all_pred_oilreduced.set2 = [sum(all_pred_oilreduced.set2(:,1:3000) .* Mat_base.Oil([2,3,4,6,7,10,11],4)),...
                            sum(all_pred_oilreduced.set2(:,3001:6000) .* Mat_base.Oil([2,3,4,6,7,10,11],5)),...
                            sum(all_pred_oilreduced.set2(:,6001:9000) .* Mat_base.Oil([2,3,4,6,7,10,11],6)),...
                            sum(all_pred_oilreduced.set2(:,9001:12000) .* Mat_base.Oil([2,3,4,6,7,10,11],7))]';
all_pred_oilreduced.set3 = [sum(all_pred_oilreduced.set3(:,1:3000) .* Mat_base.Oil([2,3,4,6,7,10,11],8)),...
                            sum(all_pred_oilreduced.set3(:,3001:6000) .* Mat_base.Oil([2,3,4,6,7,10,11],9)),...
                            sum(all_pred_oilreduced.set3(:,6001:9000) .* Mat_base.Oil([2,3,4,6,7,10,11],10))]';


end

figure(i+1)
ha = tight_subplot(2,2,0.05,[.08 .02],[.08 .02]);

if prod_index == 1
    axes(ha(1));
    h1 = scatter(all_test_gasreduced.set1, all_pred_gasreduced.set1,4,'filled','MarkerFaceColor',ColorMat(i,:),'MarkerFaceAlpha',0.25);

    mdlfit = fitlm(all_test_gasreduced.set1, all_pred_gasreduced.set1);

    hold on
    h2 = line([0 max(all_test_gasreduced.set1)], [0 max(all_test_gasreduced.set1)], 'Color', 'black', 'LineStyle', '--');

    lgd = legend(h1, ...
    sprintf('R^{2} = %0.2f', mdlfit.Rsquared.Ordinary)...
    ,'Location','best');

    lgd.FontSize = 6;

    set(gca,'FontSize',8)
    set(gca,'FontName','Arial')

    axes(ha(2));
    h1 = scatter(all_test_gasreduced.set2, all_pred_gasreduced.set2,4,'filled','MarkerFaceColor',ColorMat(i,:),'MarkerFaceAlpha',0.25);

    mdlfit = fitlm(all_test_gasreduced.set2, all_pred_gasreduced.set2);

    hold on
    h2 = line([0 max(all_test_gasreduced.set2)], [0 max(all_test_gasreduced.set2)], 'Color', 'black', 'LineStyle', '--');

    lgd = legend(h1, ...
    sprintf('R^{2} = %0.2f', mdlfit.Rsquared.Ordinary)...
    ,'Location','best');

    lgd.FontSize = 6;

    set(gca,'FontSize',8)
    set(gca,'FontName','Arial')

    axes(ha(3));
    h1 = scatter(all_test_gasreduced.set3, all_pred_gasreduced.set3,4,'filled','MarkerFaceColor',ColorMat(i,:),'MarkerFaceAlpha',0.25);

    mdlfit = fitlm(all_test_gasreduced.set3, all_pred_gasreduced.set3);

    hold on
    h2 = line([0 max(all_test_gasreduced.set3)], [0 max(all_test_gasreduced.set3)], 'Color', 'black', 'LineStyle', '--');

    lgd = legend(h1, ...
    sprintf('R^{2} = %0.2f', mdlfit.Rsquared.Ordinary)...
    ,'Location','best');

else
    axes(ha(1));
    h1 = scatter(all_test_oilreduced.set1, all_pred_oilreduced.set1,4,'filled','MarkerFaceColor',ColorMat(i,:),'MarkerFaceAlpha',0.25);

    mdlfit = fitlm(all_test_oilreduced.set1, all_pred_oilreduced.set1);

    hold on
    h2 = line([0 max(all_test_oilreduced.set1)], [0 max(all_test_oilreduced.set1)], 'Color', 'black', 'LineStyle', '--');

    lgd = legend(h1, ...
    sprintf('R^{2} = %0.2f', mdlfit.Rsquared.Ordinary)...
    ,'Location','best');

    lgd.FontSize = 6;

    set(gca,'FontSize',8)
    set(gca,'FontName','Arial')

    axes(ha(2));
    h1 = scatter(all_test_oilreduced.set2, all_pred_oilreduced.set2,4,'filled','MarkerFaceColor',ColorMat(i,:),'MarkerFaceAlpha',0.25);

    mdlfit = fitlm(all_test_oilreduced.set2, all_pred_oilreduced.set2);

    hold on
    h2 = line([0 max(all_test_oilreduced.set2)], [0 max(all_test_oilreduced.set2)], 'Color', 'black', 'LineStyle', '--');

    lgd = legend(h1, ...
    sprintf('R^{2} = %0.2f', mdlfit.Rsquared.Ordinary)...
    ,'Location','best');

    lgd.FontSize = 6;

    set(gca,'FontSize',8)
    set(gca,'FontName','Arial')

    axes(ha(3));
    h1 = scatter(all_test_oilreduced.set3, all_pred_oilreduced.set3,4,'filled','MarkerFaceColor',ColorMat(i,:),'MarkerFaceAlpha',0.25);

    mdlfit = fitlm(all_test_oilreduced.set3, all_pred_oilreduced.set3);

    hold on
    h2 = line([0 max(all_test_oilreduced.set3)], [0 max(all_test_oilreduced.set3)], 'Color', 'black', 'LineStyle', '--');

    lgd = legend(h1, ...
    sprintf('R^{2} = %0.2f', mdlfit.Rsquared.Ordinary)...
    ,'Location','best');
    
    
end


lgd.FontSize = 6;

set(gca,'FontSize',8)
set(gca,'FontName','Arial')

cd(strcat(root_path,'\Outputs'))
FileName = ['plot_AllEquipLeakage_out.emf'];
print('-painters','-dmeta',FileName);


figure(i+2)

if prod_index == 1
    n_equip = 9;
else
    n_equip = 7;
end

ha = tight_subplot(n_equip,3,0.01,[.01 .01],[.01 .01]);

for i = 1:n_equip
    
    for j = 1:3
        
        axes(ha((i-1)*3 + j));
        hold on 
        
        x = AFR_table(1:7,1);
        y = LFR_table(1:7,i,j);
        scatter(x,y,12,'MarkerFaceColor',ColorMat(i,:),'MarkerEdgeColor',ColorMat(i,:),'MarkerFaceAlpha',0.5); 

        x = AFR_table(8:14,1);
        y = LFR_table(8:14,i,j);
        scatter(x,y,12,'d','MarkerEdgeColor',ColorMat(i,:)); 

        x = AFR_table(15:21,1);
        y = LFR_table(15:21,i,j);
        scatter(x,y,12,'s','MarkerFaceColor',ColorMat(i,:),'MarkerEdgeColor',ColorMat(i,:)); 
    
        line([0,12],[0,12],'Color','black','LineStyle','-')
        xlim([0 5]);
        ylim([0 5]);
        
        box on
        
    end
end

if prod_index == 1
    cd(strcat(root_path,'\Outputs'))
    FileName = ['plot_Gas_AF_out.emf'];
    print('-painters','-dmeta',FileName);
else
    cd(strcat(root_path,'\Outputs'))
    FileName = ['plot_Oil_AF_out.emf'];
    print('-painters','-dmeta',FileName);
end


