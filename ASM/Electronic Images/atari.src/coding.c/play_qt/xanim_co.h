
/*
 * xanim_config.h
 *
 * Copyright (C) 1990,1991,1992,1993,1994 by Mark Podlipec.
 * All rights reserved.
 *
 * This software may be freely copied, modified and redistributed
 * without fee provided that this copyright notice is preserved
 * intact on all copies and modified copies.
 *
 * There is no warranty or other guarantee of fitness of this software.
 * It is provided solely "as is". The author(s) disclaim(s) all
 * responsibility and liability with respect to this software's usage
 * or its effect upon hardware or computer systems.
 *
 */

/* These defines are used to initialize the various flags that control
 * the behavious of XAnim. They all can be overriden on the command
 * line except for DEFAULT_PLUS_IS_ON and DEFAULT_X11_VERBOSE_FLAG.
 */


/* If this is TRUE then '+' will turn an option on and '-' will turn it off.
 * if this is FALSE then '+' will turn an option off and '-' will turn
 * it on.
 */
#define DEFAULT_PLUS_IS_ON	TRUE

/* If TRUE then animations will be buffered ahead of time. Uses more memory.
 */
#define DEFAULT_BUFF_FLAG	FALSE

/* If TRUE then animations will be read from disk. This and BUFF_FLAG are
 * mutually exclusive with BUFF_FLAG having priority.
 */
#define DEFAULT_FILE_FLAG	FALSE

/* If TRUE then iff animations will always loop back to 1st frame instead
 * of to the 2nd delta. There is no easy way of knowing this ahead of time
 * and and is rare and so it should be kept FALSE.
 */
#define DEFAULT_IFF_LOOP_OFF	FALSE

/* If TRUE then IFF CRNG (color cycling chunks) will be activated for
 * single image IFF files.
 */
#define DEFAULT_CYCLE_IMAGE_FLAG	TRUE

/* If TRUE then IFF CRNG (color cycling chunks) will be activated for
 * IFF animation files.
 */
#define DEFAULT_CYCLE_ANIM_FLAG		FALSE

/* If TRUE then image height is reduced by half if an IFF image/animation
 * is interlaced.
 */
#define DEFAULT_ALLOW_LACE_FLAG		FALSE

/* If TRUE then the cmap will fade to black between files. Only works
 * on PSEUDO_COLOR displays.
 */
/* NOTE: CURRENTLY NOT SUPPORTED */
#define DEFAULT_FADE_FLAG	FALSE
#define DEFAULT_FADE_TIME	20

/* If TRUE then window will be the size of the largest image. Smaller
 * images and animations will be in upper left hand corner.
 */

#define DEFAULT_NORESIZE_FLAG	FALSE

/* If TRUE then a window can be resized with the mouse. This results
 * in the animation being scaled to fit and window. This also overrides
 * DEFAULT_NORESIZE_FLAG.
 */
#define DEFAULT_ALLOW_RESIZING	FALSE

/* This affect IFF type 5 and J compressions as well as most FLI/FLC type
 * compressions. Only the minimum area of the screen is updated that
 * contains the changes from one image to the next. This is forced off
 * in MONOCHROME mode due to peculiarities of the Floyd-Steinburg
 * dithering algorithm. Having this on can cause "apparent" pauses in
 * the animation because of the time difference between updating the
 * entire screen and just part of it. This will occur if your hardware
 * can not display the images at the specified rate. Turning optimization
 * off will force the entire animation to go at the slower rate.
 */
#define DEFAULT_OPTIMIZE_FLAG	TRUE

/* If this is TRUE and DEFAULT_BUFF_FLAG is TRUE, the images will be
 * put into pixmaps. Pixmaps have the following advantages:
 *     they are stored locally  (in case you're running remotely)
 *     they aren't copied twice (like most X11 servers do with XImages)
 *     they could be in display memory(if your hardware has enough of it)
 * It usually speeds things up.
 */
#define DEFAULT_PIXMAP_FLAG	FALSE
/* If TRUE then Floyd-Steinberg dithering is used for MONOCHROME displays
 */
#define DEFAULT_DITHER_FLAG	TRUE

/* This cause XAnim to print out debugging information. Valid levels are
 * from 1 to 5, with 0 being off.
 */
#define DEFAULT_DEBUG		0

/* When this is TRUE it causes XAnim to print out extra information about
 * the animations
 */
#define DEFAULT_VERBOSE		FALSE

/* This is the default number of times to loop through each file before
 * continuing on.
 */
#define DEFAULT_LOOPEACH_FLAG	1

/* When this is TRUE it causes XAnim to "ping-pong" an animation. In other
 * words, the anim will be played forwards to the end and then backwards
 * to the beginning. This will be counted as one loop.
 */
#define DEFAULT_PINGPONG_FLAG	FALSE

/* This is the number of milliseconds between frames of the animation.
 * If 0 then the number of milliseconds is taken from the animation
 * itself.
 */
#define DEFAULT_JIFFY_FLAG	0

/* This is the number of milliseconds for single image cycling IFF files.
 */
#define DEFAULT_CYCLING_TIME   8000

/* Not yet supported
 */
#define DEFAULT_PACK_FLAG	FALSE

/* This causes XAnim to print out more information about the X11
 * display on which it is running.
 */
#define DEFAULT_X11_VERBOSE_FLAG	FALSE


/* COLOR DITHERING. Currently only NONE and FLOYD are supported. FLOYD
 * dithering can add substantially to run and start up times.
 */
#define CMAP_DITHER_NONE	0
#define CMAP_DITHER_FLOYD	1
#define CMAP_DITHER_ORDERED	2

/* COLOR MAP STUFF.
 *    luma_sort:   sorts the color map based on color's brightness
 *    map_to_1st:  remaps new cmaps into 1st cmap. If try_to_1st fails
 *		   or isn't set.
 *    map_to_one:  Creates one colormap from all color maps and then
 *		   remaps all images/anims to that cmap. Eliminates
 *		   flickering, but may reduce color quality.
 *    play_nice:   Allocate colors from X11 defaults cmap. Screen colors
 *		   won't change when mouse is moved into and out of 
 *		   animation window. Color Cyling impossible with this
 *		   option. If you are running with non-default Visual,
 *		   X11 might have to change the colormap anyways.
 *    hist_flag:   If XAnim needs to generate one cmap from multiple
 *		   (ie map_to_one/play_nice or cmap > X11's cmap) then
 *		   do histograms on any uncompressed images to aid in
 *		   color reductions if necessary. More time at startup
 *		   but might help color quality.
 */
#define DEFAULT_CMAP_LUMA_SORT	FALSE
#define DEFAULT_CMAP_MAP_TO_1ST	FALSE
#define DEFAULT_CMAP_MAP_TO_ONE	FALSE
#define DEFAULT_CMAP_PLAY_NICE  TRUE
#define DEFAULT_CMAP_HIST_FLAG  FALSE
#define DEFAULT_CMAP_DITHER_TYPE CMAP_DITHER_NONE

/*
 * Options for Median Cut stuff.
 */
#define CMAP_MEDIAN_SUM    0
#define CMAP_MEDIAN_CENTER 1
#define DEFAULT_CMAP_MEDIAN_TYPE 0

/* These are for TrueColor animatons such and HAM,HAM8 or 24 bit RLE files.
 * true_to_332 means images are truncated to 3 bits red, 3 bits green and
 * 	2 bits blue in order to fit in a 256 entry cmap. If your X11 display
 * 	supports less than 256 cmap entries, these numbers will be less.
 *
 * true_to_gray means TrueColor anims are converted to 8bits of gray.
 * true_to_1st means TrueColor anims have a cmap created by running
 * 	a median cut algorithm on their 1st image and then using that
 *	for the remainder of the images. Anim must be buffered.
 * true_to_all means TrueColor anims have a cmap created by running a
 *	median cut algorithm on each image to create a cmap for each
 *	image. Adds substantially to start up time. Anim must be buffered.
 * true_to_map: This is automatically set when true_to_1st and true_to_all
 *	are turned on. It can be optionally used with true_to_332 and
 *	true_to_gray to used more bits(than332) when dithering TrueColor
 *	anims down to the Displays cmap. Really doesn't make any sense
 *	to set this with true_to_gray unless your display has less than
 *	8 bits of grayscale.
 */
#define DEFAULT_TRUE_TO_332     TRUE
#define DEFAULT_TRUE_TO_GRAY    FALSE
#define DEFAULT_TRUE_TO_1ST     FALSE
#define DEFAULT_TRUE_TO_ALL     FALSE
#define DEFAULT_TRUE_MAP_FLAG	FALSE

/* 6 is 256K, 7 is 2M and 8 is 16M */
#define CMAP_CACHE_MAX_BITS 6
#define DEFAULT_CMAP_MEDIAN_CACHE FALSE

/*
 * Title Options
 *
 * NONE		Title is just "XAnim"
 * FILE		Title is just anim name while running. When stopped the
 *		frame number is included.
 * FRAME	Title is anim anim and frame number while running.
 */

#define XA_TITLE_NONE   0
#define XA_TITLE_FILE   1
#define XA_TITLE_FRAME  2

#define DEFAULT_XA_TITLE_FLAG  1

/*
 * GAMMA Options.
 *
 * DISP_GAMMA:	Is the default gamma of your display. This is to be
 *		used to universally darken or lighten animations. Also
 *		may be used to help gamma correct your display. :^)
 *
 * ANIM_GAMMA:	This is used to specify that all anims(unless specified
 *		on the command line) are treated as if they were color
 *		compensated to this gamma value. Unfortunately, for
 *		the majority of the cases, you have no clue what gamma
 *		value the animation was compensated to.
 */
#define DEFAULT_DISP_GAMMA 1.0
#define DEFAULT_ANIM_GAMMA 1.0

/* 
 * At the end of displaying the command line, xanim will either loop
 * through again(FALSE), exit(TRUE), or pause and wait user input(PAUSE).
 */
#define DEFAULT_XA_EXIT_FLAG  FALSE
