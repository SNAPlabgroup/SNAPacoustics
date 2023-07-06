sweptDPOAE
===========
Software used at the `Systems Neuroscience of Auditory Perception lab <https://engineering.purdue.edu/SNAPLab>`_ at University of Pittsburgh
and Purdue University for DPOAE measurements. This folder is only setup to work with the RZ6 ER-10X combo of hardware and has not been made modular like the
other directories. Thus adapting to other hardware might be tricky. It is included here just for completeness and will be edited over time
to fit with the more modular structure where the functions in cardAPI are used.

Basic usage
-----------
The primary function is::

    Run_DPswept_Auto

It doesn't take any arguments but will prompt the experimenter to enter more information.
It plays stimuli for DPOAE measurements with f2 primary frequency sweeping
from 0.5 to 16 kHz. All sweeps are logarithmic chirps
with decreasing frequency over time and are constant voltage. If desired, the transfer
functions from FPLclick can be used to prefilter the chirps to yield constant FPL primaries.
The default sweep rate is -1 octaves/sec. The analysis windows can be tailored for separating the
reflection and distortion components with these defaults.


References
----------

Long, G. R., Talmadge, C. L., & Lee, J. (2008). Measuring distortion product otoacoustic emissions using continuously sweeping primaries. The Journal of the Acoustical Society of America, 124(3), 1613-1626.

Abdala, C., Luo, P., & Shera, C. A. (2015). Optimizing swept-tone protocols for recording distortion-product otoacoustic emissions in adults and newborns. The Journal of the Acoustical Society of America, 138(6), 3785-3799.

