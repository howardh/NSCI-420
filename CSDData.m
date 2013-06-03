classdef CSDData
    properties
        testName
        data
		tuningCurve
        stimulus
        prefOrientation
        stimulusObject

		%timeWindow=[1050:1150];
		timeWindow=[1000:1200];
		channelWindow=[1:32];

        %directory='C:\Users\labuser 2\Documents\MATLAB\CSDData\'
		directory=Const.DATA_DIRECTORY;
    end
    methods
        function ret=save(this)
			%TODO: Should store the experiment too
            save([this.directory this.testName '.mat'], 'this');
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
    end
end
