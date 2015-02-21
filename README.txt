AveDESKTOPSITES
(c) Andreas Verhoeven (andreasverhoeven@hotmail.com), 2007
==========================================================

These files may not used for commercial purposes without explicit written permission of the author, Andreas Verhoeven.


The source of AveDesktopSites exists of two parts:

	+ A DLL that hooks into the desktop and reroutes
		desktop-listview-background draw requests back to the
		AveDesktopSites application. (path are hardcoded to c:\desktopapp\ in
		the projects settings - change them as you like).
	Written in C++.

	+ The AveDesktopSites application that launches the hook and handles
		the rerouted desktop-listview-background draw requests to
		draw its own contents.