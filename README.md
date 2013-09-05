# NSCI-420

## main.m

* main()
* runAll()
	* Runs everything in the correct order.
	* Note: Some intermediate images (such as the graphical representation of circular variance) are not generated through this function.

## Const.m

* Contents:
	* A list of all experiments, insertions, and tests
		* Const.ALL_EXPERIMENTS
		* Const.ALL_TESTS
		* Const.ALL_INSERTIONS
	* All directories in which scripts and their outputs reside
		* Const.ROOT_DIRECTORY
		* Const.SCRIPT_DIRECTORY
		* Const.DATA_DIRECTORY
		* Const.RESULT_DIRECTORY
		* Const.ALIGNMENT_DIRECTORY
	* A list of bad channels for each experiment
		* Const.BAD_CHANNELS

## Test1

* Statistical analysis
* Two tailed test to show where a significant difference is found

## Test2

* Statistical analysis
* Basically a two tailed test, but shows the direction of the difference using colours
* Files generated:
	* ...

## Test3

* Ignore

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
* Alignments can be manually inputted in the runOnce() function (search for "Exceptions" in the comments to find it)
	* 
* Note: Once Test5 has been run, the alignment needs to be reloaded into the CSD Data files. Set CSDLoader.fReloadAlignment=1 and then reload using convertAllData() in main.m.

## Test 6 (Genetic algorithm, Fisher)

* Requires having run Test5 first (Uses the alignment data)
* Searches for sets of channels which give the best performance when used in Fisher linear discriminant analysis.
* Outputs:
	* Images representing the best selection of channels found
	* The same data represented in a mat file
		* pop{i,1} = the gene representation
		* pop{i,2} = fitness (i.e. Error rate from cross validation using Fisher linear discriminant)
		* channels = Channels from which the subsets were taken.
* generateDataSet()
	* Creates a training set from all available grating stimuli runs
	* Classification: 1 for prefered orientation, 0 for non-prefered orientation
* analyze()
	* Outputs: image containing three figures (separation, Fisher score, weights)

## Test 7 (Mutual Information)

* Currently only works under Linux
* Requires the "Mutual information computation" package by Hanchuan Peng

## Test 8

* Unused
* Finds all tests that are well tuned, and puts them together in a test named "all".
* evaluateTuningCurve
	* Input: CSDData
	* Output: True if the data is well tuned, and false otherwise
* viewCircVariance
	* Output: an image representing the circular variances of each channel
