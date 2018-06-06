%----------
% @file DispImage.m
% @brief Create and output image stimulus. �Î~�摜�h���̍쐬�A�o�́B
%
% Create and output image stimulus. �Î~�摜�h���̍쐬�A�o�́B
% 
% @author	T.Higashi
% @date		2008/01/24
%
% @par Change log
% - 2008/02/06	T.Higashi	:Add processing to free memory. �������J�������ǉ��B
% - 2008/01/25	T.Higashi	:Support image data input. �t�@�C���p�X�łȂ��f�[�^���̂̓ǂݍ��݂ɂ��Ή��B
% - 2008/01/24	T.Higashi	:New. �V�K�쐬�B
% 
%%
%----------
% varargout = DispImage(iselector, varargin)
% @param	iselector	:Selector to change process('init', 'draw', 'clear' or 'get'). �����̐؂�ւ�('init', 'draw', 'clear','get')�B
% @param	varargin	:Input argments related to selector. �����ɉ��������͈����B
% @retval	varargout	:Onput argments related to selector. �����ɉ������o�͈����B
% 
% imgp = DispImage('init', wpt, 'flPath', pntImg, scl, sclAll)
% DispImage('draw', wpt, imgp)
% DispImage('clear', imgp)
% DispImage('get', imgp)
% wpt		:Window pointer. �E�B���h�E�|�C���^�B
% imgp		:Image pointer. �C���[�W�|�C���^�B
% flPath	:Path to image file. �Î~�摜�t�@�C���ւ̃p�X�B
% pntImg	:Point setting. �摜�\���ʒu�ݒ�B
% scl		:Scale setting. �摜�X�P�[���ݒ�B
% sclAll	:Entire scale setting. �S�̃X�P�[���ݒ�B
% 
%%
function varargout = DispImage(iselector, varargin)

	persistent SETTING

	switch iselector

	case 'init'
		% Initialize image data.
		% �摜�p�f�[�^�̏������B
		if length(varargin) == 5

			[wpt, flPath, pntImg, scl, sclAll] = deal(varargin{:});
			[SETTING, imgp] = CreateSetting(SETTING, wpt, flPath, pntImg, scl, sclAll);
			varargout = {imgp};

		else

			error('DispImage(''init'', wpt, ''flPath'', pntImg, scl, sclAll)');

		end


	case 'draw'

		% Draw image.
		% �摜�f�[�^�̕`��B
		if length(varargin) == 2

			[wpt, imgp] = deal(varargin{:});
			TEX = SETTING{imgp, 1};
			RECT = SETTING{imgp, 2};
			Screen('DrawTexture', wpt, TEX, [], RECT );

		else

			error('DispImage(''draw'', wpt, imgp)');

		end


	case 'clear'

		% clear image data.
		% �摜�f�[�^�̍폜�B
		if length(varargin) == 1

			[imgp] = deal(varargin{:});
			TEX = SETTING{imgp, 1};
			if ~isempty(TEX)
				Screen('Close', TEX);
			end
			if imgp == size(SETTING, 1);
				SETTING(imgp,:) = [];
			else
				SETTING(imgp,:) = repmat({[]}, 1, size(SETTING, 2));
			end

		else

			error('DispImage(''clear'', imgp)');

		end


	case 'get'

		% Get image data.
		% �摜�f�[�^�̎擾�B
		if length(varargin) == 1

			[imgp] = deal(varargin{:});
			if isempty(imgp)
				varargout = {SETTING};
			else
				varargout = {SETTING(imgp,:)};
			end

		else

			error('DispImage(''get'', imgp)');

		end

	end


function [oSETTING, oidx] = CreateSetting(iSETTING, iwpt, iflPath, ipntImg, iscl, isclAll)

	% Make texture.
	% �e�N�X�`�����쐬�B
	if ischar(iflPath)
		imgDat = imread(iflPath);
	else
		imgDat = iflPath;
	end
	TEX = Screen('MakeTexture', iwpt, imgDat );

	if isequal(ipntImg, [0, 0]) && isequal(iscl, 100) && (isequal(isclAll, [100, 100]) || isempty(isclAll))
		% No need to convert shape.
		% �`���ύX����K�v�Ȃ��B

		RECT = [];

	else

		% Coordinate transform.
		% ���W�n�����킹��B
		[sizW, sizH] = Screen('WindowSize', iwpt);
		pntO = round([sizW, sizH] / 2);
		ipntImginW = ipntImg + pntO;

		% Transesate to display position and zoom.
		% �\���ʒu�ւ̈ړ��Ɗg��k���B
		sizImg = size(imgDat);
		RECT = [0, 0, sizImg(2), sizImg(1)];
		RECT = CenterRectOnPoint(RECT, ipntImginW(1), ipntImginW(2));
		RECT = ZoomRect(RECT, iscl, ipntImginW);

		% Adjust image size.
		% �T�C�Y�𒲐߁B
		if ~isempty(isclAll)
			RECT = ZoomRect(RECT, isclAll, pntO);
		end

	end

	if isempty(iSETTING)
		oidx = [];
	else
		oidx = min(find(cellfun('isempty', iSETTING(:,1))));
	end

	if isempty(oidx)
		% Append new data.
		% �V�����f�[�^��ǉ��B
		oSETTING = [iSETTING; {TEX, RECT}];
		oidx = size(oSETTING, 1);
	else
		% Assign new data to empty place.
		% �V�����f�[�^���J���Ă���ꏊ�ɒǉ��B
		oSETTING = iSETTING;
		oSETTING(oidx, :) = {TEX, RECT};
	end
