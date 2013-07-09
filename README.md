# NSCI-420

## Test1

* Statistical analysis
* Two tailed test to show where a significant difference is found

## Test2

* Statistical analysis
* Basically a two tailed test, but shows the direction of the difference using colours
* Files generated:
	* ...

## Test3

* Incomplete/wrong
* Same as test2, but with a paired sample t-test
	* Every trials from one test is compared to every trial of another
	* Times can be matched to one another, but what about trials?
* Files generated:
	* ...

## Test4

* Aligns the CSD of all full field and checkerboard stimuli to their respective prototypical CSD
	* Prototypical CSD used can be modified in the loadPrototype() method
* Misc methods
	* stdViewer
		* Usage:
			* set test4.expName and test4.testName
			* run test4.stdViewer
		* Output
			* A figure showing the standard deviation of the data points within each possible window of the CSD data
			* The size of the window is the same as that which is used in the alignment
	* pcsdViewer
		* Usage:
			* run test4.pcsdViewer
	* alignmentViewer
		* Usage:
			* run test4.run() to generate the results.mat
			* set test4.expName and test4.testName to the test whose alignment you want to see
			* run test4.alignmentViewer
		* Output
			* The CSD data of the given experiment and test, with a box around the window aligned with the prototypical CSD data.
* Files generated
	* Saves an image for each comparison
	* results.mat (test4/expName/)
		* Saves the results from each experiment in a single .mat file
		* Contains a map of CSDAlignment objects
		* Key: testName as a string (3 characters with leading zeros)

## Test5

* Requires having run Test4 first (Uses the generated .mat file)
* Interpolates the results to find the alignment for grating stimulus runs
	* Done using linear interpolation and rounding (Seems to work better than spline or nearest neighbour)
* Files generated:
	* results.mat (test5/expName/Covariance/)
	* Plot for each insertion (test5/expName/)

## Test 6

* Requires having run Test5 first (Uses the alignment data)
* Creates a training set from all available grating stimuli runs
	* Classification: 1 for prefered orientation, 0 for non-prefered orientation
* Takes ? channels above the brain surface, and ? channels within.
* Outputs: ???
