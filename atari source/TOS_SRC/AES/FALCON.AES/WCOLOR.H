/* WCOLOR.H
 * definitions for new wind_set call WF_COLOR and WF_DCOLOR
 * 900614 kbad
 */

#define Color2Border( c )   ( (c) << 12 )
#define Color2Text( c )	    ( (c) << 8 )
#define Color2Fill( c )   ( c )

#define ColorWord( borderColor, textColor, fillColor ) \
  ( Color2Border(borderColor) | \
    Color2Text(textColor) | \
    Color2Fill(fillColor) )

#define WF_COLOR 18	/* set element color words by handle */
#define WF_DCOLOR 19	/* set default element color words  */
/*
 * New wind_set call for setting window element colors:
 * wind_set( WORD w_id, WORD field, WORD element, WORD tcolor, WORD bcolor);
 *
 * field: WF_COLOR set object color words for window element by handle
 * field: WF_DCOLOR set default object color words for window element
 *        (w_id parameter is ignored for WF_DCOLOR)
 * element: part of window to set, defined below
 * tcolor: object color word used when window is topped (-1: ignore)
 * bcolor: object color word used when window is not topped (-1: ignore)
 *
 * A corresponding wind_get call is not provided, because there should
 * be no reason an application should need to read the window color
 * settings.  In the handle case, the application sets the colors itself,
 * and shouldn't need the AES to keep track of the colors for it. In
 * the case that the application wants to set only part of the window
 * object color word, it must set the rest of the colors as well, since
 * the users could have set the default to a color that would render
 * the application's partial change invisible.
 */

/* Window elements 	      object type	description		*/
#define W_BOX		0  /* IBOX	window parent object		*/
#define W_TITLE		1  /* BOX	parent of closer, name, fuller	*/
#define W_CLOSER	2  /* BOXCHAR	close box			*/
#define W_NAME		3  /* BOXTEXT	mover bar			*/
#define W_FULLER	4  /* BOXCHAR	full box			*/
#define W_INFO		5  /* BOXTEXT	info line			*/
#define W_DATA		6  /* IBOX	holds remaining window elements	*/
#define W_WORK		7  /* IBOX	
#define W_SIZER		8  /* BOXCHAR	sizer box			*/
#define W_VBAR		9  /* BOX	holds vertical slider elements	*/
#define W_UPARROW	10 /* BOXCHAR	vert. slider up arrow		*/
#define W_DNARROW	11 /* BOXCHAR	vert. slider down arrow		*/
#define W_VSLIDE	12 /* BOX	vert. slider background		*/
#define W_VELEV		13 /* BOX	vert. slider thumb/elevator	*/
#define W_HBAR		14 /* BOX	holds horizontal slider elements*/
#define W_LFARROW	15 /* BOXCHAR	horz. slider left arrow		*/
#define W_RTARROW	16 /* BOXCHAR	horz. slider right arrow	*/
#define W_HSLIDE	17 /* BOX	horz. slider background		*/
#define W_HELEV		18 /* BOX	horz. slider thumb/elevator	*/
#define NUM_ELEM	19
