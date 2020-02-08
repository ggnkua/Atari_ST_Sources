/*
		vdi_ext.h

        extended GEM VDI definitions 
        
        TC-VDI 0.7 / 10.5.92

        Copyright (c) MATRIX Daten Systeme GmbH 1992
*/


# include "vdi_extc.h"


/* set / get rgb color values 					*/

extern void vsf_rgb ( int handle, int *rgb ) ;
extern void vst_rgb ( int handle, int *rgb ) ;
extern void vsl_rgb ( int handle, int *rgb ) ;

extern void vrf_rgb ( int handle, int *rgb ) ;
extern void vrt_rgb ( int handle, int *rgb ) ;
extern void vrl_rgb ( int handle, int *rgb ) ;

/*
	explanation					works like
	--------------------------------------------------------------
	vs<x>_rgb ( h, rgb ) ;	==	vs_color ( h, vdiix, rgb ) ;
								vs<x>_color ( h, vdiix ) ;

								( vdiix = any free color index )


	vr<x>_rgb ( h, rgb ) ;	==	vq_color ( h, vdiix, rgb ) ;

								( vdiix = color index used
											in last vs<x>_color	)
*/



/* functions to set / get pixels values	*/

extern void vs_pixcol ( int handle, int x, int y, int vdi_ix ) ;
	/* set pixel through soft palette	*/

extern void vq_pixcol ( int handle, int x, int y,
						int *phys_ix, int *vdi_ix ) ;
	/* == v_get_pixel	*/


extern void vs_pixrgb ( int handle, int x, int y, int *rgb ) ;
	/* set pixel rgb color	*/
	
extern void vq_pixrgb ( int handle, int x, int y, int *rgb ) ;
	/* get pixel rgb color	*/


/*.... color runs .................................................*/

extern void vrun_rect ( int handle, int *pts, int *rgbs ) ;
	/* pts = rectangle ( 2 points ), rgbs = 4 * rgb values, one for each corner	*/

extern void vrun_parallel ( int handle, int *pts, int *rgbs ) ;
	/* pts = parallelogram ( 3 points ), rgbs = 4 * rgb values, one for each corner	*/

extern void vrun_triangle ( int handle, int *pts, int *rgbs ) ;
	/* pts = triangle ( 3 points ), rgbs = 3 * rgb values, one for each corner	*/



/*.... block transfers ............................................*/

/*
	Image Formats ( MFDB.stand )
	============================
	
		DEV_FORM = 0	;	interleaved planes on ATARI Systems,
						;	== PCK_FORM on MATRIX boards
		STD_FORM = 1	;	plane[0],..,plane[N-1]	
   new:	PCK_FORM = 2	;	pixel[0],..,pixel[M-1]

		It doesn't make sense to use the VDI-Standard-Format
		with more than 4 planes, because it's impossible to
		write efficient code for image processing etc. in this
		format.
		Therefore we defined another format named PCK_FORM,
		in which the information of one pixel is available
		within one memory access.
		This format is identical to DEV_FORM on MATRIX graphic
		boards.


		PCK_FORMats :

		planes			organisation		a:r:g:b	 (1)
		-----------------------------------------------------
		 8						   v7..0   	  (2)
		15			 a,r4..0,g4..0,b4..0	1:5:5:5
		16			   r4..0,g5..0,b4..0	-:5:6:5
		24		       r7..0,g7..0,b7..0	-:8:8:8
		32		a7..a0,r7..0,g7..0,b7..0	8:8:8:8

		Notes :	(1)	a = alpha/overlay planes
				(2) VDI-Color Index ( or physical pixel value ? )


	void vrt_cpyfm ( int handle, int vr_mode, int *pxyarray,
                     MFDB *psrcMFDB, MFDB *pdesMFDB,
                     int *color_index );


    New Modes
    =========

	(1) Copy Multi Color Image to Screen

						planes		format
		-----------------------------------------
		source			8			PCK_FORM
		destination 	8,32		DEV_FORM

		Copy source to destination, convert vdi color numbers to
		pixel values, in 32 bpp expand pixel through soft palette

		Legal writing modes 'vr_mode' :
		
			REPLACE :		'color_index' not used
			TRANSPARENT :	'color_index[0]' == transparent color,
							source pixels with this color are
							not copied, destination unchanged
			others :		no action

		Application:	Display 256-Color images, icons etc.
		----------- 	( CLUT-optimised images )

	(2) Expand packed 24 bpp Images to Screen

						planes		format
		-----------------------------------------
		source			24			PCK_FORM
		destination 	32			DEV_FORM

		Expand 24 bpp source  ( byte sequence : R0,G0,B0,R1,G1,B1,.. )
		to 32 bit destination ( byte sequence :  0,R0,G0,B0, 0,R1,G1,B1,.. )

		Legal writing mode 'vr_mode' :

			REPLACE :		'color_index' not used
			others :		no action

		Application:	Display True Color images, stored in packed
		------------	format on host disk / memory ( Cranach-ESM ).

*/

/*.... color calibration ..........................................*/

extern int vs_calibrate ( int handle, int *table, int onoff ) ;

extern int vq_calibrate ( int handle ) ;



/*.... color palette setting ......................................*/

extern void vs_colors ( int handle, int from, int to,
						int *rgb_table );

	/*	set a palette sequence	*/

extern void vq_colors ( int handle, int from, int to,
					    int set_flag, int *rgb_table ) ;

	/*	get a palette sequence	*/
