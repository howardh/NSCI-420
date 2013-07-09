classdef CSDAlignment
	properties
		expName;
		testName;
		insertion;	%Insertion number

		chWindow;	%Channels that were compared for the alignment
		tWindow;	%Time window

		firstChannel;	%First channel in the brain
		lastChannel; 	%Last channel in the grey matter

		stimulus; %Grating | Checkerboard | Fullfield
	end
end
