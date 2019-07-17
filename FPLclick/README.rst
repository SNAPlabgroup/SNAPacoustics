FPLclick
===========
Software used at the `Systems Neuroscience of Auditory Perception lab <https://engineering.purdue.edu/SNAPLab>`_ at Purdue University for calibration approaches that help mitigate ear-canal filtering effects.
Included are routines for measurement and calculation of Thevenin-equivalent pressure and impedance parameters of the probe, and the impedance of the ear.
This code is an adaptation from code generously contributed by peers.

Get the latest code
-------------------

To get the latest code using git, simply type::

    git clone https://github.com/SNAPsoftware/FPLclick.git

Basic usage
-----------
The two primary functions used for calibration are::

    calibProbe
    calibEar

They don't take any arguments but will prompt the experimenter to enter more information
These routines will likely not work out of the box.
You will need to supply hardware-specific functions that will play and record sounds synchronously.
The probe calibration assumes that you have access to an ER-10X with its MATLAB API.
However, if using other standard cavities to calibrate manually, the changes required of calibProbe.m
should be fairly simple.

Hardware-specific functions for audio play and capture
------------------------------------------------------
As can be seen in ``calibProbe.m`` and ``calibEar.m``, a routine to play a stimulus and synchronously record a response
needs to be supplied. This will be hardware specific and will vary from lab to lab.
Minimally, this function should take in a stimulus signal (of length T), a number of repetitions (N) for which to play the stimulus,
and return an N x T-sized array of the synchronously captured audio response to each stimulus presentation.

Expected Behavior
-----------------
Probe Calibration
+++++++++++++++++

Upon running ``calibProbe.m``, the experimenter will be prompted to enter some basic information (e.g., which driver in the probe to calibrate).
The program is designed to play many repetitions of a short click stimulus covering DC to the Nyquist rate with the ER-10X calibrator
cavity set to five different lengths. Synchronous response is recorded, averaged across trials and analyzed.
The average cavity response for each length is plotted along with the estimated impedance which then is iteratively refined and used to calculate
the probe parameters.

.. raw:: html

    <img src="./SampleProbeCal.png" width="500px">
.. raw:: html

    <img src="./sampleProbeCal_Impedance.png" width="500px">

The calibration error is calculated over the 2-8 kHz region.
A value of less than 1 is considered a good calibration.
However, we typically get values between 0.01 and 0.04.
All calculated and measured parameters are stored in a structure called ``calib``.
If ``calib.error`` exceeds 1, a warning is thrown.
The script is currently setup to save the probe calibrations in a directory called ``PROBECAL`` within the same directory as containing the script.
Typically, we run the probe calibration a few minutes before the subject arrives for the study.

Ear Calibration
+++++++++++++++
The script ``calibEar.m`` can be used to measure the immittance properties of the ear.
Upon running it, the experimenter will be prompted to select a probe calibration file and enter a subject ID and ear (left or right).
The same click signal used to calibrate the probe is also used to measure the reponse of the ear.
From these measurements, the impedance of the ear, and all quantities necessary for forward-pressure level (FPL) calibration are calculated and stored.
The absorbance of the ear is plotted. This can be used to check for a tight seal.
The program warns the experimenter of an air leak if the low frequency absorbance is greater than 29% or if the low-frequency admittance phase is
less than 44 degrees in accordance with Groon et al., Ear Hear (2015).
A typical absorbance plot is shown below (See Figure 4 in Liu et al., J Acoust Soc Am, 2008 for some normative values).

.. raw:: html

    <img src="./sampleAbsorbance.png" width="400px">

These calibrations can be used to generate FPL-calibrated stimuli for OAE measurements,
measure the middle-ear muscle reflex (MEMR) as admittance, absorbance, or reflectance changes (see Keefe et al., J Assoc Res Otolaryngol, 2017), 
measure high-frequency audiometric thresholds in FPL units, etc.
If using FPL-calibrated stimuli to elicit OAEs, the emissions can be measured in emitted pressure level (EPL) units (Charaziak & Shera, J Acoust Soc Am, 2017).
We typically run these measurements each time we place the probe in the subject's ear.
If performing long duration measurements (e.g., 1 hour), we repeat these measurements once or twice in between.
These measurements, ear parameters, and calculated transfer functions (e.g., Voltage to FPL) are stored in a structure called ``calib`` in ``./EARCAL/<subjectID>/``.
The structure also has the probe calibration information that was inherited.

References
----------

Charaziak, K. K., & Shera, C. A. (2017). Compensating for ear-canal acoustics when measuring otoacoustic emissions. The Journal of the Acoustical Society of America, 141(1), 515-531.

Groon, K. A., Rasetshwane, D. M., Kopun, J. G., Gorga, M. P., & Neely, S. T. (2015). Air-leak effects on ear-canal acoustic absorbance. Ear and hearing, 36(1), 155.

Keefe, D. H., Feeney, M. P., Hunter, L. L., & Fitzpatrick, D. F. (2017). Aural acoustic stapedius-muscle reflex threshold procedures to test human infants and adults. Journal of the Association for Research in Otolaryngology, 18(1), 65-88.

Liu, Y. W., Sanford, C. A., Ellison, J. C., Fitzpatrick, D. F., Gorga, M. P., & Keefe, D. H. (2008). Wideband absorbance tympanometry using pressure sweeps: System development and results on adults with normal hearing. The Journal of the Acoustical Society of America, 124(6), 3708-3719.

