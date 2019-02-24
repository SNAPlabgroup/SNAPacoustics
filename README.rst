SNAPacoustics
===========

Software used at the `Systems Neuroscience of Auditory Perception lab <https://engineering.purdue.edu/SNAPLab>`_ at Purdue University
for acoustic calibrations and measurements. 
Included are routines for measurement and calculation of Thevenin-equivalent pressure and impedance parameters of OAE probes,
immittance properties of the ear,
otoacoustic emission measurements, middle-ear muscle reflex measurements, and calibration of OAE microphones. 
All routines are based on using the TDT RZ6 sound card along with the ER-10X probe system. Access to the ER-10X MATLAB API is assumed.
Functions that interface with the RZ6 card are encapsulated in the in cardAPI directory.
If suitable replacements of those functions are provided for other sound cards (e.g., using playrec for RME or MOTU soundcards),
the remaining routines can be used with other sound cards as well.
In case a different OAE system from the ER-10X is used, Thevenin calibrations will have to be done manually
(e.g., using the FPLclick code provided, but manually changing the standard loads).
The OAE, immittance, and reflex routines can be used
Parts of this software were develeoped  simply by adaptating from code generously contributed by peers, 
while the rest were developed in house.

Get the latest code
-------------------

To get the latest code using git, simply type::

    git clone https://github.com/SNAPsoftware/SNAPacoustics.git

Hardware-specific functions for audio play and capture
------------------------------------------------------
As can be seen in most scripts, a routine to play a stimulus and synchronously record a response
needs to be supplied. This will be hardware specific and will vary from lab to lab.
These should be placed in cardAPI and replace playCapture2.m.
Minimally, this function should take in a stimulus signal (of length T), a number of repetitions (N) for which to play the stimulus,
and return an N x T-sized array of the synchronously captured audio response to each stimulus presentation.

Getting Started
---------------

The best place to start is the configuration folder.
That folder provides routines for getting basic information about your setup
(like sound card delays, voltage range of the D/A device, etc.).
Once you have that info, you may need to adapt some of the functions in cardAPI.
If you are using the TDT RZ6 card, you'll likely not need to do any of this.

Once you are able to successfully play and record sounds synchronously, please proceed to the FPLclick directory
which provides routines for Thevenin calibration of the OAE probe,
and immittance measurements of the ear (or any other load). If probe and ear calibrations work successfully,
most other routines should work.

Individual folders have some more documentation.

Attributions/Citations
----------------------

If you are using this software, we request that you include a statement acknowledging this resource in your output.
A manuscript that makes use of these methods is under review; if and when the paper is accepted,
information about the paper will be included here.
At that point, please cite it if you use this software.

NOTE
++++
Previously, the individual folders in this repository were separate repos in their own right.
This repository merges and replaces them.

