%If the directory exists, then go to that directory
%Otherwise, create that directory first
function cdForce(dir)
	if ~exist(dir,'dir')
		mkdir(dir);
	end
	cd(dir);
end
