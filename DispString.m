%----------
% @file DispString.m
% @brief Create and output string stimulus. ������h���̍쐬�A�o�́B
%
% Create and output string stimulus. ������h���̍쐬�A�o�́B
% 
% @author	T.Higashi
% @date		2008/01/24
%
% @par Change log
% - 2008/02/06	T.Higashi	:Change to use height scale. ���A���������k�ڂ̍����̂ݗ��p���邱�Ƃɂ����B
% - 2008/01/24	T.Higashi	:New. �V�K�쐬�B
% 
%%
%----------
% varargout = DispString(iselector, varargin)
% @param	iselector	:Selector to change process('init', 'draw', 'clear' or 'get'). �����̐؂�ւ�('init', 'draw', 'clear','get')�B
% @param	varargin	:Input argments related to selector. �����ɉ��������͈����B
% @retval	varargout	:Onput argments related to selector. �����ɉ������o�͈����B
% 
% strp = DispString('init', wpt, str, pntStr, sizStr, clrStr, sclAll)
% DispString('draw', wpt, strp)
% DispString('clear', strp)
% DispString('get', strp)
% wpt		:Window pointer. �E�B���h�E�|�C���^�B
% strp		:Image pointer. ������|�C���^�B
% str		:String. ������B
% pntStr	:Point setting. ������\���ʒu�ݒ�B
% sizStr	:Font size setting. �t�H���g�T�C�Y�ݒ�B
% clrStr	:String color setting. �����F�ݒ�B
% sclAll	:Entire scale setting. �S�̃X�P�[���ݒ�B
% 
%%
function varargout = DispString(iselector, varargin)

	persistent SETTING

	switch iselector

	case 'init'
		% Initialize string data.
		% ������p�f�[�^�̏������B
		if length(varargin) == 6

			[wpt, str, pntStr, sizStr, clrStr, sclAll] = deal(varargin{:});
			[SETTING, strp] = CreateSetting(SETTING, wpt, str, pntStr, sizStr, clrStr, sclAll);
			varargout = {strp};

		else

			error('DispString(''init'', wpt, str, pntStr, sizStr, clrStr, sclAll)');

		end


	case 'draw'

		% Draw string.
		% ������̕`��B
		if length(varargin) == 2

			[wpt, strp] = deal(varargin{:});
			SIZSTR = SETTING{strp, 1};
			STR = SETTING{strp, 2};
			RECT = SETTING{strp, 3};
			CLRSTR = SETTING{strp, 4};
			Screen('TextSize', wpt, SIZSTR);
			Screen('DrawText', wpt, STR, RECT(1), RECT(2), CLRSTR);

		else

			error('DispString(''draw'', wpt, strp)');

		end


	case 'clear'

		% clear string data.
		% ������f�[�^�̍폜�B
		if length(varargin) == 1

			[strp] = deal(varargin{:});
			if strp == size(SETTING, 1);
				SETTING(strp,:) = [];
			else
				SETTING(strp,:) = repmat({[]}, 1, size(SETTING, 2));
			end

		else

			error('DispString(''clear'', strp)');

		end


	case 'get'

		% Get string data.
		% ������f�[�^�̎擾�B
		if length(varargin) == 1

			[strp] = deal(varargin{:});
			if isempty(strp)
				varargout = {SETTING};
			else
				varargout = {SETTING(strp,:)};
			end

		else

			error('DispString(''get'', strp)');

		end

	end


function [oSETTING, oidx] = CreateSetting(iSETTING, iwpt, STR, ipntStr, SIZSTR, CLRSTR, isclAll)

	% Coordinate transform.
	% ���W�n�����킹��B
	[sizW, sizH] = Screen('WindowSize', iwpt);
	pntO = round([sizW, sizH] / 2);
	ipntStr = ipntStr + pntO;

	% Get text rectangle.
	% ������\���̈�擾�B
	Screen( 'TextSize', iwpt, SIZSTR );
	RECT = Screen('TextBounds', iwpt, STR);

	% Transesate to display position.
	% �\���ʒu�ւ̈ړ��B
	RECT = CenterRectOnPoint(RECT, ipntStr(1), ipntStr(2));

	% Adjust image size.(use height scale. Don't use width scale.)
	% �T�C�Y�𒲐�(���������̂ݗ��p)�B
	if ~isempty(isclAll) && ~isequal(isclAll, [100, 100])
		tmpRECT = ZoomRect(RECT, isclAll, pntO);
		[cx, cy] = RectCenter(tmpRECT);
		SIZSTR = round(SIZSTR * isclAll(2) / 100);
		Screen( 'TextSize', iwpt, SIZSTR );
		RECT = Screen('TextBounds', iwpt, STR);
		RECT = CenterRectOnPoint(RECT, cx, cy);
	end


	if isempty(iSETTING)
		oidx = [];
	else
		oidx = min(find(cellfun('isempty', iSETTING(:,1))));
	end

	if isempty(oidx)
		% Append new data.
		% �V�����f�[�^��ǉ��B
		oSETTING = [iSETTING; {SIZSTR, STR, RECT, CLRSTR}];
		oidx = size(oSETTING, 1);
	else
		% Assign new data to empty place.
		% �V�����f�[�^���J���Ă���ꏊ�ɒǉ��B
		oSETTING = iSETTING;
		oSETTING(oidx, :) = {SIZSTR, STR, RECT, CLRSTR};
	end

