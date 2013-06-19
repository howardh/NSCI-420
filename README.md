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
