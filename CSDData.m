classdef CSDData
    properties
		expName
        testName

        data		%CSD data (Channel * Time * Trials [* Conditions])
					% CSDMapping: 32 * 2001 * 300
					% Grating: 32 * 3501 * 20 * 16
		tuningCurve %Tuning curve data

		alignment = CSDAlignment;	%CSDAlignment object

        stimulus
        prefOrientation
        stimulusObject

		timeWindow=[1000:1200];
		channelWindow=[1:32];
    end
    methods
        function ret=save(this)
			%Make sure the directory exists
			dir = [Const.DATA_DIRECTORY pathname(this.expName)];
			if ~exist(dir, 'dir')
				mkdir(dir);
			end
			%Save the data
			size(this.data)
            save([Const.DATA_DIRECTORY pathname(this.expName) this.testName '.mat'], 'this');
			size(this.data)
        end

		%Discard everything except the data over the defined time window
		function ret=trim(this)
			try
				ret=this.data(this.channelWindow,this.timeWindow,:,:);
			catch err
				s = size(this.data);
				this.channelWindow = 1:s(1);
				ret=this.data(this.channelWindow,this.timeWindow,:,:);
			end
		end

		%Takes the conditions with the same orientations, and average them within the trial
		function ret=avgConditions(this)
			s = size(this.data);
			if (s(4) == 16)
				a=this.data(:,:,:,[1:8]);
				b=this.data(:,:,:,[9:16]);
				ret=(a+b)/2;
			else
				ret=this.data;
			end
		end
		%Take the conditions with the same orientation, and add them as another trial
		function ret=mergeConditions(this)
			a=this.data(:,:,:,[1:8]);
			b=this.data(:,:,:,[9:16]);
			ret=cat(3,a,b);
		end

		%Computes prefered orientation
		function ret=getPrefOrientation(this)
			if (isempty(this.tuningCurve)) %Combined CSD data will not have a tuning curve
				ret=1;
				return;
			end
			x=mean(this.tuningCurve,1);
			a=x([1:8]);
			b=x([9:16]);
			ret=argmax(a+b);
		end

		function ret=isGrating(this)
			ret=strcmp(this.stimulus, 'Gratings');
		end
		function ret=isCSDMapping(this)
			ret=strcmp(this.stimulus, 'CSDmapping');
		end
		function ret=isFullField(this)
			ret=strcmp(this.stimulusObject.TextureType, 'FullField');
		end
		function ret=isChecker(this)
			ret=strcmp(this.stimulusObject.TextureType, 'Checkers');
		end
    end
end
