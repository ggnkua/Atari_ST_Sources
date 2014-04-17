
01/28/93 cjg - This version of XCONTROL is the release version
 	       for the FALCON and MULTI-TOS.
	     
	     - NOTE: After building the Control Panel, run PRGFLAGS
	             and set the PROTECTION to SUPERVISOR.
		     This is so that there is no conflict when
		     the exchange mouse button vector occurs.

03/31/93 cjg - This version uses malloc() instead of Malloc().
	       Therefore, this version uses less memory than
	       the previous version under MultiTOS.

	     - The 'Number of Slots' option has been removed.

	     - Still need to set PROTECTION to SUPERVISOR.
