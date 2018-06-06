function run_choice1(subID)
%% run_choice1('999-1')

try

    % Load image files for the subject
    file_items = ['data/bdm_item_id_sub_',subID(1:3)];
    load(file_items) % item_ids is loaded
    day_idx = str2num(subID(end));
    food_list = item_id_sub{day_idx,1};
    trinket_list = item_id_sub{day_idx,2};
    
    median_bid = 2;
    med_bid_string = ['$',num2str(median_bid)];
    
    conditions = [ones(1,10)*1, ones(1,10)*2];
    temp_concat = [food_list, trinket_list];
    item_list = [conditions', temp_concat'];
    idx_rnd = randperm(length(item_list));
    item_list = item_list(idx_rnd,:);
    
    %%VERY TEMPORARY
    load('temp_combo_list');
    item_list = combo_list;
    
    num_trials = length(item_list);
    
    % Set window pointer
    [wpt, rect] = Screen('OpenWindow', 0, [0, 0, 0], [0 0 800 600] * 1.5); w = rect(3); h = rect(4);
    %[wpt, rect] = Screen('OpenWindow', 1, [0, 0, 0]); w = rect(3); h = rect(4);
    Screen('BlendFunction', wpt, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
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
    
    load('temp_combo_list');
    item_list = combo_list;
    
    % Start BDM
    time_zero = GetSecs;
    %for i = 1:num_trials
    for i = 60:num_trials
        
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
                itm_img = DispImage('init', wpt, shown_item, [0,-h/15], w/50, [100,100]);
            elseif item_list(i,1) > 100
                shown_item = ['data/imgs_trinkets/item_',num2str(item_list(i,1)),'.jpg'];
                itm_img = DispImage('init', wpt, shown_item, [0,-h/15], w/10, [100,100]);
            end
            DispImage('draw', wpt, itm_img);
        else
            %else its a bundle
            if item_list(i,1) < 100
                shown_item1 = ['data/imgs_food/item_',num2str(item_list(i,1)),'.jpg'];
                itm_img1 = DispImage('init', wpt, shown_item1, [-170,-h/15], w/100, [100,100]);
            else
                shown_item1 = ['data/imgs_trinkets/item_',num2str(item_list(i,1)-100),'.jpg'];
                itm_img1 = DispImage('init', wpt, shown_item1, [-170,-h/15], w/20, [100,100]);
            end
            if item_list(i,2) < 100
                shown_item2 = ['data/imgs_food/item_',num2str(item_list(i,2)),'.jpg'];
                itm_img2 = DispImage('init', wpt, shown_item2, [170,-h/15], w/100, [100,100]);
            else
                shown_item2 = ['data/imgs_trinkets/item_',num2str(item_list(i,2)-100),'.jpg'];
                itm_img2 = DispImage('init', wpt, shown_item2, [170,-h/15], w/20, [100,100]);
            end
            DispImage('draw', wpt, itm_img1);
            DispImage('draw', wpt, itm_img2);
        end
        
        res_nums = draw_choices(wpt, w, h, ref_pos(i), med_bid_string);
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
            outcome = med_bid_string;
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
    fname_log = ['logs/choice1_sub_',subID];
    save(fname_log,'choice','item','ref_pos');
    
    durITI = 14;
    time_ITIstrt = GetSecs - time_zero;
    disp_fix(wpt, w, h, durITI)
    time_ITIend = GetSecs - time_zero;
    time_ITI = [time_ITI; [time_ITIstrt, time_ITIend]];
    
    fname_log_time = ['logs/choice1_sub_',subID,'_time'];
    save(fname_log_time, 'time_ITI', 'time_DEC', 'time_OUT');
    
    Screen('CloseAll');

catch
    
    Screen('CloseAll');
    psychrethrow(psychlasterror);

end

end
    