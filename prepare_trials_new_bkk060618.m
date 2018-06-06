function prepare_trials_new(subID)
%% prepare_trials_new('006-1')

close all;

inc_food_ids = [];
inc_trinket_ids = [];
exc_food_ids = [];
exc_trinket_ids = [];

num_food = 70;
num_trinket = 40;
%how many trials, cant do every combo of bundles
num_trials = 220;

subj = str2num(subID(1:3));
subj_seed = 121 + subj;

%randomly permute food and trinket trials
rng(subj_seed)
food_ids = randperm(num_food);
rng(subj_seed)
trinket_ids = randperm(num_trinket);

%Prepare BDM ITEM

%randomize the ordering of all the items for BDM Item
%add 100 to the trinket IDs to distinguish them

bdm_item_seq = [food_ids, (trinket_ids + 100)];
idx_rnd = randperm(length(bdm_item_seq));
bdm_item_seq = bdm_item_seq(idx_rnd);

%get combinations of all items
%create a N x 2 array of item pairs, starting with each item paired
%with itself
day_food_list = food_ids;
day_trinket_list = (trinket_ids + 100);
combo_list = [[day_food_list';day_trinket_list'],[day_food_list';day_trinket_list']];
all_items = [day_food_list, day_trinket_list];
temp_combos = nchoosek(all_items, 2);
combo_list = [combo_list; temp_combos];

%randomly select NUM_TRIALS trials for this participant
idx_rnd = randperm(length(combo_list));
combo_list = combo_list(idx_rnd(1:num_trials),:);

%make half of the trials have food on left half with food on right
half_num = length(combo_list)/2;
lr_conds = [ones(1,half_num)*1, ones(1,half_num)*2];
idx_rnd = randperm(half_num*2);
lr_conds = lr_conds(idx_rnd);

%randomize the ordering
num_trials = length(combo_list);
idx_rnd = randperm(num_trials);
bundle_item_seq = combo_list(idx_rnd,:);
lr_conds = lr_conds(idx_rnd);
num_trials = length(bundle_item_seq);

%flip the left right order of bundles with condition 2 
for i=1:num_trials
    if lr_conds(i) == 2
        bundle_item_seq(i,:) = fliplr(bundle_item_seq(i,:));
    end
end

f_name = ['data/item_list_sub_',subID];
if isequal(exist([f_name,'.mat'],'file'),0)
    save(f_name,'bdm_item_seq','bundle_item_seq');
    disp('Done!')
else
    disp('WARNING: The file already exists!')
end

end

