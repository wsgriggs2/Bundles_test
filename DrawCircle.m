%----------
% @file DrawCircle.m
% @brief Create and output circle stimulus. �~�̍쐬�A�o�́B
%
% Create and output circle stimulus. �~�̍쐬�A�o�́B
% 
% @author	T.Higashi
% @date		2008/01/24
%
% @par Change log
% - 2008/01/24	T.Higashi	:New. �V�K�쐬�B
% 
%%
%----------
% varargout = DrawCircle(iselector, varargin)
% @param	iselector	:Selector to change process('init', 'draw', 'clear' or 'get'). �����̐؂�ւ�('init', 'draw', 'clear','get')�B
% @param	varargin	:Input argments related to selector. �����ɉ��������͈����B
% @retval	varargout	:Onput argments related to selector. �����ɉ������o�͈����B
% 
% cirp = DrawCircle('init', wpt, pntC, diaCrl, clrCrl, sclAll, dst)
% DrawCircle('draw', wpt, cirp)
% DrawCircle('clear', cirp)
% DrawCircle('get', cirp)
% wpt		:Window pointer. �E�B���h�E�|�C���^�B
% cirp		:Circle pointer. �~�|�C���^�B
% pntC		:Point setting. �~�̒��_�ʒu�ݒ�B
% diaCrl	:Circle diameter setting. �~�̒��a�ݒ�B
% clrCrl	:Circle color setting. �~�̐F�ݒ�B
% sclAll	:Entire scale setting. �S�̃X�P�[���ݒ�B
% dst		:Distance from the display(mm). �팱�҂ƃf�B�X�v���C�Ƃ̋���(mm)�B
% 
%%
function varargout = DrawCircle(iselector, varargin)

	persistent SETTING

	switch iselector

	case 'init'
		% Initialize random dot data.
		% �~�f�[�^�̏������B
		if length(varargin) == 6

			[wpt, pntC, diaCrl, clrCrl, sclAll, dst] = deal(varargin{:});
			[SETTING, cirp] = CreateSetting(SETTING, wpt, pntC, diaCrl, clrCrl, sclAll, dst);
			varargout = {cirp};

		else

			error('DrawCircle(''init'', wpt, pntC, diaCrl, clrCrl, sclAll, dst)');

		end


	case 'draw'

		% Draw circle.
		% �~�̕`��B
		if length(varargin) == 2

			[wpt, cirp] = deal(varargin{:});
			CLRCRL = SETTING{cirp, 1};
			RECT = SETTING{cirp, 2};
			Screen('FillOval', wpt, CLRCRL, RECT);

		else

			error('DrawCircle(''draw'', wpt, cirp)');

		end


	case 'clear'

		% clear circle data.
		% �~�f�[�^�̍폜�B
		if length(varargin) == 1

			[cirp] = deal(varargin{:});
			if cirp == size(SETTING, 1);
				SETTING(cirp,:) = [];
			else
				SETTING(cirp,:) = repmat({[]}, 1, size(SETTING, 2));
			end

		else

			error('DrawCircle(''clear'', cirp)');

		end


	case 'get'

		% Get circle data.
		% �~�f�[�^�̎擾�B
		if length(varargin) == 1

			[cirp] = deal(varargin{:});
			if isempty(cirp)
				varargout = {SETTING};
			else
				varargout = {SETTING(cirp,:)};
			end

		else

			error('DrawCircle(''get'', cirp)');

		end

	end


function [oSETTING, oidx] = CreateSetting(iSETTING, iwpt, ipntC, idiaCrl, CLRCRL, isclAll, idst)

	% If the distance from the display is given, transform the unit.
	% �f�B�X�v���C�Ƃ̋������w�肳��Ă���Ȃ璷���̒P�ʂ�deg���Ɣ��f���A�P�ʂ�pixel�ϊ�����B
	ppd = GetPpd(iwpt, idst);
	if ppd > 0
		idiaCrl = round(idiaCrl * ppd);
	end


	% Coordinate transform.
	% ���W�n�����킹��B
	[sizW, sizH] = Screen( 'WindowSize', iwpt );
	pntO = round([sizW, sizH] / 2);
	ipntCinW = ipntC + pntO;

	% Transesate to display position and zoom.
	% �\���ʒu�ւ̈ړ��Ɗg��k���B
	RECT = round([0, 0, idiaCrl, idiaCrl]);
	RECT = CenterRectOnPoint(RECT, ipntCinW(1), ipntCinW(2));


	% Adjust image size.
	% �T�C�Y�𒲐߁B
	if ~isempty(isclAll)
		RECT = ZoomRect(RECT, isclAll, pntO);
	end


	if isempty(iSETTING)
		oidx = [];
	else
		oidx = min(find(cellfun('isempty', iSETTING(:,1))));
	end

	if isempty(oidx)
		% Append new data.
		% �V�����f�[�^��ǉ��B
		oSETTING = [iSETTING; {CLRCRL, RECT}];
		oidx = size(oSETTING, 1);
	else
		% Assign new data to empty place.
		% �V�����f�[�^���J���Ă���ꏊ�ɒǉ��B
		oSETTING = iSETTING;
		oSETTING(oidx, :) = {CLRCRL, RECT};
	end
