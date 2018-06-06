%----------
% @file ZoomRect.m
% @brief Zoom rectangle with input coordinates. ���͗̈����͍��W�𒆐S�Ƃ��Ċg��k������B
%
% Zoom rectangle with input coordinates. ���͗̈����͍��W�𒆐S�Ƃ��Ċg��k������B
% 
% @author	T.Higashi
% @date		2008/01/20
%
% @par Change log
% - 2008/01/20	T.Higashi	:New. �V�K�쐬�B
% 
%%
%----------
% orect = ZoomRect(irect, iscl, ipntC)
% @param	irect		:Rectangle. �����`�̈�B
% @param	iscl		:Scale(%). �����`�̊g��k����%�B
% @param	ipntC		:Center point for zoom. �g��k���̒��S�_�B
% @retval	orectStr	:Rectangle after zoom. �g��k����̒����`�̈�B
% 
%%
function orect = ZoomRect(irect, iscl, ipntC)

	if isequal(size(iscl), [1, 1])
		iscl = [iscl, iscl];
	end

	sclX = iscl(1) / 100;
	sclY = iscl(2) / 100;

	% Distance.
	% �ړ��ʁB
	qttZoom = irect - [ipntC, ipntC];
	qttZoom = qttZoom .* [sclX, sclY, sclX, sclY];

	orect = round([ipntC, ipntC] + qttZoom);
