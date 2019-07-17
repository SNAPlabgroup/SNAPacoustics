DPOAEswept
===========
Software used at the `Systems Neuroscience of Auditory Perception lab <https://engineering.purdue.edu/SNAPLab>`_ at Purdue University
for DPOAE measurements. This folder is only setup to work with the RZ6 ER-10X combo of hardware and has not been made modular like the
other directories. Thus adapting to other hardware might be tricky. It is included here just for completeness and will be edited over time
to fit with the more modular structure where the functions in cardAPI are used.

Basic usage
-----------
The two primary functions are::

    Run_DPOAEswept
    Run_DPOAEswept_singleSweep

They don't take any arguments but will prompt the experimenter to enter more information.
They both measure play stimuli for DPOAE measurements with f2 primary frequency sweeping
from 2 to 16 kHz. The former does so in two concurrent sweepts (2 - 8 kHz and 4 - 16 kHz),
whereas the latter does a single sweep from 2 - 16 kHz. All sweeps are logarithmic chirps
with decreasing frequency over time and are constant voltage. If desired, the transfer
functions from FPLclick can be used to prefilter the chirps to yield constant FPL primaries.
The default sweep rate is -0.5 octaves/sec for the single sweep and -0.33 octaves/sec for
the two concurrent sweep version. The analysis windows can be tailored for separating the
reflection and distortion components with these defaults.


References
----------

Long, G. R., Talmadge, C. L., & Lee, J. (2008). Measuring distortion product otoacoustic emissions using continuously sweeping primaries. The Journal of the Acoustical Society of America, 124(3), 1613-1626.

Abdala, C., Luo, P., & Shera, C. A. (2015). Optimizing swept-tone protocols for recording distortion-product otoacoustic emissions in adults and newborns. The Journal of the Acoustical Society of America, 138(6), 3785-3799.

