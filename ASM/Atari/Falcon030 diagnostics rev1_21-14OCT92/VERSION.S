* Note on internal RWS version # format: X.YZa
* X - major version number - changed if Y > 9 or other important reasons
* Y - changed for important new additions or Z > 9
* Z - large changes, additions, serious bug fixes, etc
* a - alphanumeric for untested/small changes, small bug fixes, spelling, etc
*     (not commonly tracked, unless at a critical time)  

* 'R' tests done by RWS while TRF also was changing code

* SPARROW TEST -------------------------------------------------
* V0.50 : 17DEC91 : RWS : Started Sparrow Test 0.5 from STe v1.9 (half works)
* V0.51 : 19DEC91 : RWS : Cleaned up menus - Moved to submenu format
* V0.60 : 06DEC92 : RWS : Config Switches in submenu installed
* V0.70 : 16JAN92 : RWS : System Control Menu Added
* V0.70a: 17JAN92 : RWS : Cleaned/Inversed some test titles
* V0.70b: 17JAN92 : RWS : Moved titles & dates to version.s
* V0.71 : 21JAN92 : RWS : Changed Hires & Color to Video
* V0.71a: 22JAN92 : RWS : Cleaned up system.s & video.s menus
* V0.72 : 23JAN92 : RWS : Removed Drive B in hflop - removed some dead code
* V0.80 : 24JAN92 : RWS : Added RTC test
* V0.81 : 27JAN92 : RWS : Added $TOS exit and GOCART.PRG entry rtns.
* V0.82 : 29JAN92 : RWS : made Console.s, cconin, etc 
* V0.83 : 31JAN92 : RWS : NOW ONLY 68030's NEED APPLY - swiped code from TT cart
* V0.84 : 03FEB92 : RWS : Fixed Timing test. REMOVED GENLOCK -PUT IT BACK SOMEDAY!- 
* V0.85 : 05FEB92 : RWS : Added TOS 2.06j USA to ROM.s - add others later
* V0.85a: 06FEB92 : RWS : Changed messages a bit & made RAM/DSP RAM test 
* V0.86 : 06FEB92 : RWS : Added SCC test (from TT, not tested) and SCSI (not linked to test yet)
* V0.87 : 11FEB92 : RWS : Added SP Video tests (ex:3)
* V0.87a: 18FEB92 : RWS : Hacked up for 68000 Sparrow + fixed SDMA A or B with uWire.
* V0.88 : 03MAR92 : RWS : Changed memory sizing for sparrow. Disabled RTC alarm test
* V0.88a: 08MAR92 : RWS : fixed minor sizing bugs.
* VR.89 : 25MAR92 : RWS : Added & Mucked w/video tests - need work. (still buggy hardware)
* VR.90 : 27MAR92 : RWS : Added DSP SRAM and SSI Loopback tests
* VR.91 : 01APR92 : RWS : Fixed FPU error w/rev 1 Combel
* VR.92 : 06APR92 : RWS : Redid most of video tests. vMonitors works. 
* VR.93 : 07APR92 : RWS : Made vModes work (second test only on rev 2+ combels)
* VR.93a: 07APR92 : RWS : Added highlighting to tested keys in keybd test
* VR.93b: 08APR92 : RWS : Made boot w/VGA possible 
* V0.95 : 09APR92 : RWS : Added Expansion, IDE and SCSI tests back in from TF
* V0.96 : 09APR92 : RWS : Cleaned up integration, fixed odd errors. All RWS stuff works now. (Miller Time!)
* V0.97 : 13APR92 : RWS : Added Fixed TRF stuff (SCSI & IDE).
* VR.98 : 18MAR92 : RWS : Added Production test wrapper, started NVRAM stuff... 
* VT.98 : 17APR92 : TLE : Modified init, xblt, blt, wait,
*                   TLE   Modified e_data, and e_exp
* VT.99 : 03MAY92 : TLE and TFR : Modified the following sections:
*                 : scsi, hflop, init, wait, RTC, console, menu - not finished yet 
* V0.99 : 19MAY92 : RWS : added T stuff back in
* V1.00 : 29MAY92 : RWS : NVRAM & New menus.
* V1.01 : 20JUN92 : RWS : Hacked on for Rev 2. Combel's
* V1.02 : 22JUN92 : RWS : Added quick address checker for 16M boards.
* V1.03 : 24JUN92 : RWS : Beat most bugs out of production autotests. Fixed RTC, LAN, DSP, etc. Serial still doesn't work
* V1.04 : 25JUN92 : RWS : Added forced pass mode. Changed visibility scheme in prod. autotests. 
* V1.05 : 26JUN92 : RWS : Finally made operator tests highlightable, added NEED & FORCED bits. (forced can go away later).
* V1.06 : 09JUL92 : RWS : Started hacking on it for rev 3. boards.
* V1.06M: 07JUL92 : TLE : Fixed e_exp, and added genlock test 
* V1.07 : 11JUL92 : RWS : Rearranged test for makefile & STBOOK. merged in Tom Le's stuff. New SCC code doesn't work yet.
* V1.08 : 14JUL92 : RWS : merged in SCC code for serial comm
* V1.09 : 15JUL92 : RWS : made SCC port B test work, split sources more
* V1.10 : 17JUL92 : RWS : Added in DSP Port test. 
* V1.10B: 21JUL92 : RWS : Fixed BERR on exit of SDMA test. Yanked 512 byte dcb.b from rwh_at. 
* V1.11 : 22JUL92 : RWS : Added untested Audio Loopback. Fixed power-up menu format
* V1.12 : 22JUL92 : RWS : Audio (& rest of DSP Port) works. I wanna go home
* V1.13 : 24JUL92 : RWS : Fixed various bugs, redid displays (AGAIN). I wanna go home again.
* V1.13A: 24JUL92 : TLE : Fixed expansion test bugs (lockup)
* V1.13b: 30JUL92 : RWS : Fixed floppy wierdnesses. Removed DMA audio test.
* V1.14 : 05AUG92 : RWS : ReEnabled Bus Errors for Taiwan
* V1.15 : 05AUG92 : RWS : Added repeat tries to Audio LB 
* V1.16 : 06AUG92 : RWS : Added in Tom Le's stuff. Video Requires RS232
* V1.16B: 06AUG92 : RWS : Minor mods to mono & other video tests
* V1.16C: 06AUG92 : RWS : Made video test work w/keyboard in autotest : ROM
* V1.16D: 06AUG92 : RWS : Made RTC & ANALB have # of tries, Added AutoBurnIn
* V1.16E: 07AUG92 : RWS : Hacked rom.s for one chip CRC. Made DSP:111111 restart test.
* V1.17 : 07AUG92 : RWS : ROM works. 14MB Required for PreBurn.
* V1.17B: 07AUG92 : RWS : Added DSP SRAM to set t_RAM fail
* V1.17C: 08AUG92 : RWS : Removed PAL/NTSC, Added Burn-in Cycle counter 
* V1.17D: 10AUG92 : RWS : Added SCC fail message, Made e_exp set nvram always
* V1.17E: 10AUG92 : RWS : New video RGB shades. No floppies is now an error. 
* V1.17F: 10AUG92 : RWS : Light Gun now sets RTC bits. Improved SDMA.s 
* V1.17G: 11AUG92 : RWS : Test sequences changed, FPU & IDE mods, Burn in fail changes
* V1.17H: 11AUG92 : RWS : Made supervisor cart, Fixed t_RAM bug.
* V1.17I: 11AUG92 : RWS : Integrated Exp. Bus Test, Fixed Timing/Key/Midi Errs?
* V1.17J: 12AUG92 : RWS : Lengthened IDE timeout, tried to fix DSP SSI
* V1.17K; 12AUG92 : RWS : Made DSP SSI & SRAM work (copied from f4dsp.s)
* V1.18 : 12AUG92 : RWS : Tried BERR fix. Almost ~= 1.17k
* V1.18A: 17AUG92 : RWS : Fixed Bus Error, Moved XBUS back out, added version control
* V1.18B: 18AUG92 : RWS : Fixed SCC Error on first run (National Parts)
* V1.18C: 19AUG92 : RWS : Put CartLessAutoBurn in.
* --------------------------------------------------------------
*
* STe versions are in menu.s
*

VERSION = 0     ; internal version (0..256) for control purposes..

        .data
hdrmsg: dc.b    cr,lf
        dc.b    tab,tab,'Falcon 030 Production Diagnostic - v1.21',cr,lf
        dc.b    tab,tab,tab,tm,' 1992, Atari Microsystems',cr,lf,eot   

datem:  dc.b    cr,lf,tab,'OCT 14, 1992',cr,lf,eot
