%@param csd
%	CSD data
%@param div
%	Size of the time subdivisions
function ret=CSDStatAnalysis(csd,div)
    % Col 1: 32
    %   Channels
    % Col 2: 3501
    %   Time in ms?
    % Col 3: 10? variable size
    %   Trials
    % Col 4: 16
    %   Conditions

	%Default arguments
	if (nargin == 1)
		disp('CSDStatAnalysis: div not specified. Defaulting to 20');
		div=20;
	end

	csd.data=csd.trim();
	csd.data=csd.mergeConditions();
    sizes=size(csd.data);

    ret=zeros(sizes(4),sizes(4),sizes(1),floor(sizes(2)/div));
    for cond1=1:sizes(4)
        for cond2=cond1:sizes(4)
            disp([num2str(cond1) '-' num2str(cond2)]);
            tic
            for ch=1:sizes(1)
				t=[1:div];
				tCount=1;
				while (t(end)<=sizes(2))
                    dist1 = csd.data(ch,t,:,cond1);
                    dist2 = csd.data(ch,t,:,cond2);
                    ret(cond1,cond2,ch,tCount) = test(dist1(:),dist2(:));
                    ret(cond2,cond1,ch,tCount) = ret(cond1,cond2,ch,tCount);

					t=t+div;
					tCount=tCount+1;
                end
            end
            toc
        end
    end
end

function ret=test(dist1,dist2)
    ret=ttest2(dist1,dist2);
end
