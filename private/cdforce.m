%If the directory exists, then go to that directory
%Otherwise, create that directory first
function cdForce(dir)
	mkdir(dir);
	cd(dir);
end
