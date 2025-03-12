Chunky to planar routines

For Atari Falcon/TT 8-plane screens.


Notice:
BPLSIZE in the Kalms routines should be set to xres*yres/8



c2p1x1_4.s		4 plane c2p by Mikael Kalms.

				input:  8bit chunky (4 lower bits used)
				output: Falcon/TT 8-plane screen buffer


c2p1x1_6.s		6-plane c2p by Mikael Kalms.

		  		input:  8bit chunky (6 lower bits used)
				output: Falcon/TT 8-plane screen buffer
				

c2p1x1_8.s		8-plane c2p by Mikael Kalms.

				input:  8bit chunky (all bits used)
				output: Falcon/TT 8-plane screen bufffer


c2p.s			8-plane c2p by Mikro and Mikael Kalms.
				Optimized for superscalar 060-mode.

				input:  8bit chunky (all bits used)
				output: Falcon/TT 8-plane screen buffer
				 
