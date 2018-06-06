function run_BDM_item_new(subID)
%% run_BDM_item_new('888-1')
%% run_BDM_item_new('004-3')
Screen('Preference','SkipSyncTests', 1);
try
    
    debug = 0;
    
    KbName('UnifyKeyNames');
    
    %Screen('Preference','SkipSyncTests', 2);
    
    % Load image files for the subject
    file_items = ['data/item_list_sub_',subID];
    load(file_items) % item_ids is loaded
    item_list = bdm_item_seq;
    
    % Set window pointer
    if debug
        %[wpt, rect] = Screen('OpenWindow', 0, [0, 0, 0], [0 0 960 540] * 1.5); w = rect(3); h = rect(4);
        [wpt, rect] = Screen('OpenWindow', 0, [0, 0, 0], [0 0 1800 900]); w = rect(3); h = rect(4);
    else
        [wpt, rect] = Screen('OpenWindow', 0, [0, 0, 0]); w = rect(3); h = rect(4);
    end
    
    Screen('BlendFunction', wpt, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('Preference','TextRenderer', 1)
    
    % Preparation
    durITI = 0.5;
    durOUT = 0.5;
    num_trials = length(item_list);
    %d_tics = prep_tics_item(wpt, w, h);
    w_bin = linspace(w * 0.2, w * 0.8, 6);
    str_question = DispString('init', wpt, 'How much are you willing to pay for this item?', [0,-h/2.75], floor(h/17), [255, 255, 255], []);
    
    % Prepare data
    time_ITI = []; time_DEC = []; time_OUT = [];
    value = []; item = []; init_V = []; num_L = []; num_R = [];
    
    % Ready
    disp_ready(wpt, w, h);
    
    % Start BDM
    time_zero = GetSecs;
    for i = 1:num_trials
        
        % ITI
        disp(['trial #',num2str(i),': ',num2str(item_list(i))])
        time_ITIstrt = GetSecs - time_zero;
        disp_fix(wpt, w, h, durITI)
        time_ITIend = GetSecs - time_zero;
        time_ITI = [time_ITI; [time_ITIstrt, time_ITIend]];
        
        % BDM
        if item_list(i) < 100
            shown_item = ['data/imgs_food/item_',num2str(item_list(i)),'.jpg'];
            itm_img = DispImage('init', wpt, shown_item, [0,-h/15], w/50, [140000/w,140000/w]);
        elseif item_list(i) > 100
            shown_item = ['data/imgs_trinkets/item_',num2str(item_list(i)-100),'.jpg'];
            itm_img = DispImage('init', wpt, shown_item, [0,-h/15], w/50, [140000/w,140000/w]);
        end
        
        %target = ceil(rand() * length(w_bin));
        %init_valueBDM = 4 * (target - 1) / (length(w_bin) - 1);numL_tmp = 0; numR_tmp = 0;
        
        FlushEvents
        time_DECstrt = GetSecs - time_zero;
        bid=100;
        while 1
            DispImage('draw', wpt, itm_img);
            DispString('draw', wpt, str_question);
            bid_display(wpt, w, h, bid)
            Screen(wpt,'Flip');
            
            keyRes = GetChar;
            [keyIsDown,secs,keyCode] = KbCheck;
            keyName = KbName(find(keyCode));
            %disp('Pressed')
            %disp(keyName(1))
            %key_num = str2num(keyRes);
            if length(keyName) > 0 && ischar(keyName)
%                 disp('inside if statement')
%                 disp(class(keyName))
%                 disp(keyName(1))
%                 disp(keyName)
%                 disp(length(keyName(1)))
%                 disp(length(keyName))
                key_num = str2num(keyName(1));
            else
                key_num = [];
            end
            if ~isempty(key_num)
                if bid == 100
                %first starting trial, go from blank to first number press
                    bid = key_num;
                elseif bid == 1 && isempty(key_num) == 0
                %if a 1 is typed first a number can be entered after it
                    bid = 10 + key_num;
                elseif bid == 2 && isempty(key_num) == 0
                %if a 2 is typed first only 0 entered after it
                    bid = 20;
                end
            end
            
            %input your bid directly
            if isequal(keyName,'Return')
                break
            elseif isequal(keyName,'BackSpace')
                bid = 100;
            elseif isequal(keyName,'q')
                Screen('CloseAll');
                FlushEvents
                break
            end
            %if isequal(keyRes,'3')
            %use other hand and use 0 to input answer
%             if isequal(keyRes,'0')
%                 break
%             elseif isequal(keyRes,'1')
%                 target = target - 1; numL_tmp = numL_tmp + 1; if target < 1, target = 1; end
%             elseif isequal(keyRes,'2')
%                 target = target + 1; numR_tmp = numR_tmp + 1; if target > length(w_bin), target = length(w_bin); end
%             elseif isequal(keyRes,'q')
%                 Screen('CloseAll');
%                 break
%             end
            FlushEvents
        end
        time_DECend = GetSecs - time_zero;
        time_DEC = [time_DEC; [time_DECstrt, time_DECend]];
        valueBDM = bid;
        
        % OUTCOME (FEEDBACK)
        time_OUTstrt = GetSecs - time_zero;
        disp_out(wpt, w, h, valueBDM, durOUT)
        time_OUTend = GetSecs - time_zero;
        time_OUT = [time_OUT; [time_OUTstrt, time_OUTend]];
        
        % save data
        value = [value; valueBDM];
        item = [item; item_list(i)];
       
        DispImage('clear', itm_img);
        
    end 
    
    % data save and closing
    fname_log = ['logs/bdm_items_sub_',subID];
    save(fname_log,'value','item','init_V','num_L','num_R');
    
    durITI = 2;
    time_ITIstrt = GetSecs - time_zero;
    disp_fix(wpt, w, h, durITI)
    time_ITIend = GetSecs - time_zero;
    time_ITI = [time_ITI; [time_ITIstrt, time_ITIend]];
    
    fname_log_time = ['logs/bdm_items_sub_',subID,'_time'];
    save(fname_log_time, 'time_ITI', 'time_DEC', 'time_OUT');
    
    Screen('CloseAll');

catch
    
    Screen('CloseAll');
    psychrethrow(psychlasterror);

end

end