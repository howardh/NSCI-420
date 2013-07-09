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
			mkdir([Const.DATA_DIRECTORY pathname(this.expName)]);
			%Save the data
            save([Const.DATA_DIRECTORY pathname(this.expName) this.testName '.mat'], 'this');
        end

		%Discard everything except the data over the defined time window
		function ret=trim(this)
			ret=this.data(this.channelWindow,this.timeWindow,:,:);
		end

		%Takes the conditions with the same orientations, and average them within the trial
		function ret=avgConditions(this)
			a=this.data(:,:,:,[1:8]);
			b=this.data(:,:,:,[9:16]);
			ret=(a+b)/2;
		end
		%Take the conditions with the same orientation, and add them as another trial
		function ret=mergeConditions(this)
			a=this.data(:,:,:,[1:8]);
			b=this.data(:,:,:,[9:16]);
			ret=cat(3,a,b);
		end

		%Computes prefered orientation
		function ret=getPrefOrientation(this)
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
