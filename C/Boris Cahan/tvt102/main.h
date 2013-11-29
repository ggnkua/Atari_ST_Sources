#ifndef  _MAIN_H
#define  _MAIN_H

   #define  TRUE -1
   #define  FALSE 0

/*   #define  WINTYPE     (NAME | MOVE | CLOSE | SMALLER | INFO | FULLER | SIZER | UPARROW | DNARROW | VSLIDE | LFARROW | RTARROW | HSLIDE)*/
   #define  WINTYPE     (NAME | MOVE | CLOSE | INFO )

   #define MAX_WID      work_out[0]+1
   #define MAX_HGT      work_out[1]+1



   #define DOUBLEW      0x01
   #define BOLD   	  	0x02
   #define LIGHT   			0x04
   #define BLINK				0x04
   #define UNDERSCORE   0x08
   #define REVERSE      0x10
   #define NEWFONT			0x20
   #define DOUBLE3  		0x40
   #define DOUBLE4			0x80
/*
   #define NEWFONT      0x01
   #define BOLD   	  	0x02
   #define LIGHT   			0x04
   #define UNDERSCORE   0x08
   #define REVERSE      0x10
   #define DOUBLEW			0x20
   #define DOUBLE3  		0x40
   #define DOUBLE4			0x80
*/

   #define  OPENABLE 		0x01
   #define  OPENING     0x02
   #define  OPEN    		0x04
   #define CLOSING      0x08

   typedef struct {
	    short handle;
  	  MFDB work;
			GRECT w_rect;
  	  GRECT b_rect;
			short	x_offset;      
			short y_offset;
			short srow;
  	  short col;
  	  short row;
			short saverow;
			short savecol;
			short cursorcol;
			short cursorrow;
			short	scrolltop;
			short scrollbot;
			short sstop;
			short ssbot;
			short flags;
			short	font_no;
			short gfont_no;
			short	font_size;
			short	gfont_size;
      } WINDOW;

	#define MAX_ROW 50
	#define MAX_COL 132

		typedef	char	(*(TERM_buf[MAX_ROW]))[MAX_COL];
	typedef char	LINE_buf[MAX_COL];
#endif
