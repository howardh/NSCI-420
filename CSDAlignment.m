classdef CSDAlignment < handle
	properties
		expName;
		testName;
		insertion;	%Insertion number

		chWindow;	%Channels that were compared for the alignment
		tWindow;	%Time window

		firstChannel;	%First channel in the brain
		lastChannel; 	%Last channel in the grey matter

		layerI;
		layerII;
		layerIII;
		layerIV;
		layerV;
		layerVI;

		stimulus; %Grating | Checkerboard | Fullfield
	end
	methods
		function updateLayers(this)
			this.layerI = this.firstChannel;

			this.layerII = [1 2 3 4] + this.firstChannel;
			this.layerIII = [1 2 3 4] + this.firstChannel;

			this.layerIV = [5 6 7 8] + this.firstChannel;

			this.layerV = [9 10 11] + this.firstChannel;

			this.layerVI = [12 13 14] + this.firstChannel;
		end
	end
end
