/* Metamorph by Mark Kimball */
/* (C) Copyright 1990 by Antic Publishing, Inc. */

        /* definitions for CAD-3D communication pipe */

/* object and storage manipulation */

#define RAMSTATUS 0x3d00	/* requests ram status */
#define NEW       0x3d01	/* deletes objects */
#define GETNUM	  0x3d02	/* gets internal obnum from name */
#define CHGNAME	  0x3d03	/* change object name */
#define CHGCOLOR  0x3d04	/* change object name */
#define SENDOBJ   0x3d05	/* load object info into cad-3d */
#define GETOBJ    0x3d06	/* get object from cad-3d */
#define DELOBJ	  0x3d07	/* delete object from cad-3d */
#define MAKEOBJ   0x3d08	/* make  new object */
#define DUPOBJ    0x3d09	/* duplicate object */
#define SETBG     0x3d10	/* set background color */
#define LOADCOLOR 0x3d11	/* load color palette */
#define GETCOLOR  0x3d12	/* get color palette info from cad-3d */
#define LOADFILL  0x3d13	/* set fill pattern */
#define GETFILL   0x3d14	/* get fill pattern from cad-3d */
#define GETLINE   0x3d15	/* get line colors */
#define LINECOLOR 0x3d16	/* set line colors */

/* define view parameters */

#define SETZOOM   0x3d20	/* set zoom factor */
#define SETPER	  0x3d21	/* set perspective factor */
#define SETCAM1	  0x3d22	/* set camera1 horangle,vangle,bangle */
#define SETCAM2   0x3d23	/* set camera2 position,view-point,bangle */
#define SETCAM3   0x3d24	/* set camera3 position, angles,focus */
#define SETVMODE  0x3d25	/* set view mode: solid, wireframe,etc */
#define SETDORF   0x3d26	/* set draft or final rendering mode */
#define SET3DSEP  0x3d27	/* set 3D separation */
#define SET3DMODE 0x3d28	/* set 3D mode */
#define SET3D     0x3d29	/* turn 3D on/off */
#define ALIAS     0x3d2a	/* anti-alias superview */
#define SETEDGES  0x3d2b	/* set edge mode */
#define MOVECAM1  0x3d2c	/* move camera1 */
#define MOVECAM2  0x3d2d	/* move camera2 */
#define MOVECAM3  0x3d2e	/* move camera3 */
#define CHGZP     0x3d2f	/* change zoom & perspective by delta value */
#define SETBGVIEW 0x3d30	/* set background switches */
#define CLEARBG   0x3d31	/* erase background buffer */
#define COPYSUPER 0x3d32	/* copy super-view to background */
#define FINDBUFFS 0x3d33	/* get addresses of buffers */


/* recorder operations */

#define STARTANI  0x3d40	/* start recording */
#define RECORD	  0x3d41	/* record a frame */
#define STOPANI   0x3d42	/* stop the recording */

/* miscellaneous operations */

#define SUPER	  0x3d48	/* generate super view image */
#define GETCAMS   0x3d49	/* returns various view parameters:
				   drawing mode,draft/final,stereo/mono,
				   stereo effect,stereo separation */
#define SLCTGRP   0x3d50	/* select group */
#define HOME      0x3d51	/* homes the current group */
#define SCALE     0x3d52	/* scales the current group */
#define ROTTYPE   0x3d53	/* sets rotation/scaling type */
#define ROTCENTER 0x3d54	/* sets rotation/scaling center */
#define ROTGRP    0x3d55	/* rotates current group */
#define SCALEXYZ  0x3d56	/* scales group along axes */
#define XLAT	  0x3d57	/* move group */
#define SELOBJ    0x3d58	/* select/deselect object in group */
#define CLEARGRP  0x3d59	/* deselects all objects in group */
#define SLCTALL   0x3d5a	/* select all objects in group */

/* light controls */

#define LTONOFF   0x3d60	/* turns lights on or off */
#define LTSOURCE  0x3d61	/* defines light placement and intensity */


/* there are a few more things, but nothing necessary for ray-tracing */
