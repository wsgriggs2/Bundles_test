%Received from Logan 6/1/2018 WG
%Modified to work with new pilot data 6/1/2018 WG
close all;
clearvars;
clc;

subID = '800-1'; %800-1 802-1 888-1

%%add different color coding for different conditions 
histogram_binedges=0:2:20; %Bin size of 2

temp_file = ['logs/bdm_items_sub_',subID,'.mat'];
load(temp_file)
bdm_item_value = value;
bdm_item = item;
bdm_item_category = item>71; %0 is food. 1 is trinket.


fig1 = figure;
item_category_counts=zeros(2,length(histogram_binedges)-1);
for category=0:1
item_category_counts(category+1,:)=histcounts(bdm_item_value(bdm_item_category==category),histogram_binedges);
end
bar(item_category_counts');
baraxis=gca;
baraxis.XTickLabel={'0-1','2-3','4-5','6-7','8-9','10-11','12-13','14-15',...
    '16-17','18-20'};
title('Invididual Item Bids')
xlabel('Value')
ylabel('Count')
legend('Food','Trinket');


temp_file = ['logs/bdm_bundle_sub_',subID,'.mat'];
load(temp_file)
bdm_bundle_value = value;
bdm_bundle_items = item;
bdm_bundle_item_category = bdm_bundle_items>71; %0 is food. 1 is trinket.
bdm_bundle_category=zeros(length(bdm_bundle_value),1);
bdm_bundle_category(bdm_bundle_item_category(:,1)==0 & bdm_bundle_item_category(:,2)==0)=1; %Food bundle
bdm_bundle_category(bdm_bundle_item_category(:,1)==0 & bdm_bundle_item_category(:,2)==1)=2; %Mixed bundle
bdm_bundle_category(bdm_bundle_item_category(:,1)==1 & bdm_bundle_item_category(:,2)==0)=2; %Mixed bundle
bdm_bundle_category(bdm_bundle_item_category(:,1)==1 & bdm_bundle_item_category(:,2)==1)=3; %Trinket bundle


fig2 = figure;
bundle_category_counts=zeros(2,length(histogram_binedges)-1);
for category=1:3
bundle_category_counts(category,:)=histcounts(bdm_bundle_value(bdm_bundle_category==category),histogram_binedges);
end
bar(bundle_category_counts');
baraxis=gca;
baraxis.XTickLabel={'0-1','2-3','4-5','6-7','8-9','10-11','12-13','14-15',...
    '16-17','18-20'};
title('Bundle Bids')
xlabel('Value')
ylabel('Count')
legend('Food bundle','Mixed bundle','Trinket bundle');


% run_num = 1;
% file_name= ['choice_run',num2str(run_num),'_sub_',subID];
% 
% load(['logs/',file_name]);
% item_list = item;
% choice_list = choice;
% 
% for run=2:5
%     file_name= ['choice_run',num2str(run),'_sub_',subID];
%     load(['logs/',file_name]);
%     item_list = [item_list; item];
%     choice_list = [choice_list; choice];
% end
% 
% %where was there no response
% no_response = find(choice_list > 1);
% choice_list(no_response) = 2;
% 
% fig3 = figure;
% histogram(choice_list)
% title('Choices vs Reference Money')
% xlabel('0: Money 1: Item')
% ylabel('Count')

%Assuming that first column is left item and 2nd column is right item.
for j=1:2
    for i=1:length(bdm_bundle_items(:,1))
        bdm_bundle_item_values(i,j)=bdm_item_value(bdm_item==bdm_bundle_items(i,j));
    end
end
LM=fitlm(bdm_bundle_item_values,bdm_bundle_value)

