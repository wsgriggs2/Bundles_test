function run_choice(subID)
%% run_choice('999-1')
%% run_choice('004-3')

try
    debug = 1;
    
    %Input run number
    run_num = input('Run number: ');

    % Load image files for the subject
    file_items = ['data/item_list_sub_',subID];
    load(file_items) % item_ids is loaded
    item_list = choice_item_cell{run_num,1};
    num_trials = length(item_list);
    
    %load median bids
    item_bid_file = ['logs/bdm_items_sub_',subID];
    if exist([item_bid_file,'.mat'],'file') > 0
        load(item_bid_file)
        median_bid_item = median(value);
        %if median bid is zero, change the reference amount to $1 so
        %behavior still matters
        if median_bid_item == 0
            median_bid_item = 1;
        end
    else
        disp('WARNING: No BDM Item File Found. Will use $2 median bid')
        median_bid_item = 2;
    end
    
    med_bid_item = ['$',num2str(median_bid_item)];
    
    bundle_bid_file = ['logs/bdm_bundle_sub_',subID];
    if exist([bundle_bid_file,'.mat'],'file') > 0
        load(bundle_bid_file)
        median_bid_bundle = median(value);
        %if median bid is zero, change the reference amount to $1 so
        %behavior still matters
        if median_bid_bundle == 0
            median_bid_bundle = 1;
        end
    else
        disp('WARNING: No BDM Bundle File Found. Will use $4 median bid')
        median_bid_bundle = 4;
    end
    
    med_bid_bundle = ['$',num2str(median_bid_bundle)];
    
    % Set window pointer
    if debug
        %[wpt, rect] = Screen('OpenWindow', 0, [0, 0, 0], [0 0 800 600] * 1.5); w = rect(3); h = rect(4);
        [wpt, rect] = Screen('OpenWindow', 0, [0, 0, 0], [0 0 1800 900]); w = rect(3); h = rect(4);
    else
        [wpt, rect] = Screen('OpenWindow', 0, [0, 0, 0]); w = rect(3); h = rect(4);
    end
    Screen('BlendFunction', wpt, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('Preference','TextRenderer', 1)
    
    % Preparation
    durITI = linspace(2,9,num_trials);
    durITI = durITI(randperm(num_trials));
    durDEC = 5; durOUT = 0.5;
    %randomize where the reference monetary amount is placed
    ref_pos = randi(2,1,num_trials);
    
    % Prepare data
    time_ITI = []; time_DEC = []; time_OUT = [];
    choice = []; item = [];
    
    % Ready
    disp_ready(wpt, w, h);
    
    % Start BDM
    time_zero = GetSecs;
    for i = 1:num_trials
        
        % ITI
        disp(['trial #',num2str(i),': ',num2str(item_list(i,:))])
        time_ITIstrt = GetSecs - time_zero;
        disp_fix(wpt, w, h, durITI(i))
        time_ITIend = GetSecs - time_zero;
        time_ITI = [time_ITI; [time_ITIstrt, time_ITIend]];
        
        % DEC (PRESENTATION AND RESPONSE)
        %is is an item or bundle trial, item trials have -1 in second
        %column
        if item_list(i,2) == -1
            if item_list(i,1) < 100
                shown_item = ['data/imgs_food/item_',num2str(item_list(i,1)),'.jpg'];
                itm_img = DispImage('init', wpt, shown_item, [0,-h/15], w/50, [140000/w,140000/w]);
            elseif item_list(i,1) > 100
                shown_item = ['data/imgs_trinkets/item_',num2str(item_list(i,1)-100),'.jpg'];
                itm_img = DispImage('init', wpt, shown_item, [0,-h/15], w/10, [140000/w,140000/w]);
            end
            DispImage('draw', wpt, itm_img);
        else
            %else its a bundle
            if item_list(i,1) < 100
                shown_item1 = ['data/imgs_food/item_',num2str(item_list(i,1)),'.jpg'];
                itm_img1 = DispImage('init', wpt, shown_item1, [-w/7.0,-h/15], w/100, [100,100]);
            else
                shown_item1 = ['data/imgs_trinkets/item_',num2str(item_list(i,1)-100),'.jpg'];
                itm_img1 = DispImage('init', wpt, shown_item1, [-w/7.0,-h/15], w/100, [100,100]);
            end
            if item_list(i,2) < 100
                shown_item2 = ['data/imgs_food/item_',num2str(item_list(i,2)),'.jpg'];
                itm_img2 = DispImage('init', wpt, shown_item2, [w/7.0,-h/15], w/100, [100,100]);
            else
                shown_item2 = ['data/imgs_trinkets/item_',num2str(item_list(i,2)-100),'.jpg'];
                itm_img2 = DispImage('init', wpt, shown_item2, [w/7.0,-h/15], w/100, [100,100]);
            end
            DispImage('draw', wpt, itm_img1);
            DispImage('draw', wpt, itm_img2);
        end
        
        %display median bid. is it an item or bundle trial, item trials have -1 in second
        if item_list(i,2) == -1
            res_nums = draw_choices(wpt, w, h, ref_pos(i), med_bid_item);
            med_bid = med_bid_item;
        else
            res_nums = draw_choices(wpt, w, h, ref_pos(i), med_bid_bundle);
            med_bid = med_bid_bundle;
        end
        Screen(wpt,'Flip');
        trial_choice = 100;
        FlushEvents
        time_DECstrt = GetSecs - time_zero;
        t_strt = GetSecs;
        while GetSecs < t_strt + durDEC
            if CharAvail == 1
                keyRes = GetChar;
                %default reference amount on right with ref pos 1, on left with ref pos 2; choice 0 is reference 1
                %is item
                if isequal(keyRes,'0')
                    trial_choice = ref_pos(i) - 1; break
                elseif isequal(keyRes,'1')
                    trial_choice = 2 - ref_pos(i); break
                elseif isequal(keyRes,'q')
                    Screen('CloseAll');
                    break
                end
            end
        end
        disp(trial_choice)
        clear_res_numes(res_nums);
        time_DECend = GetSecs - time_zero;
        time_DEC = [time_DEC; [time_DECstrt, time_DECend]];
        
        % OUTCOME (FEEDBACK)
        time_OUTstrt = GetSecs - time_zero;
        if trial_choice == 0
            outcome = med_bid;
        elseif trial_choice == 1
            outcome = 'ITEM';
        elseif trial_choice == 100
            outcome = 100;
        end
        disp_out(wpt, w, h, outcome, durOUT)
        time_OUTend = GetSecs - time_zero;
        time_OUT = [time_OUT; [time_OUTstrt, time_OUTend]];
        
        % save data
        choice = [choice; trial_choice];
        item = [item; item_list(i,:)];
    end
    
    % data save and closing
    fname_log = ['logs/choice_run',num2str(run_num),'_sub_',subID];
    save(fname_log,'choice','item','ref_pos','median_bid_item','median_bid_bundle');
    
    durITI = 14;
    time_ITIstrt = GetSecs - time_zero;
    disp_fix(wpt, w, h, durITI)
    time_ITIend = GetSecs - time_zero;
    time_ITI = [time_ITI; [time_ITIstrt, time_ITIend]];
    
    fname_log_time = ['logs/choice_run',num2str(run_num),'_sub_',subID,'_time'];
    save(fname_log_time, 'time_ITI', 'time_DEC', 'time_OUT');
    
    Screen('CloseAll');

catch
    
    Screen('CloseAll');
    psychrethrow(psychlasterror);

end

end
    