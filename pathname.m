%Returns a platform independent path
function ret=pathname(varargin)
	if isunix
		pathsep='/';
	else
		pathsep='\';
	end

	ret='';
	for i=1:nargin
		ret=[ret varargin{i} pathsep];
	end
end
