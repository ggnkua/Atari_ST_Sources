/* GEN2.H
 *==========================================================================
 * Prototypes and external variables from GENERAL.C
 */
 #include "..\cpxdata.h"
 
 
 
 /* DEFINES
  *=========================================================================
  */
  
  #define UP 	0				/* wait button up   */
  #define DOWN 	1				/* wait button down */

  typedef struct _gen
  {
     int  keyclick;	/* Keyclick   On/Off       	    */
     int  bell;		/* Bell	      On/Off	   	    */
     int  dclick;	/* Double click rate: 0, 1, 2, 3, 4 */
   
     int  repeat;	/* Keyboard repeat rate		    */
     int  response;	/* Keyboard response rate	    */
   
     int  BlitCache;	/* Blitter/TT Cache On/Off          */
   
     int  TT_Speaker;   /* TT Speaker  On/Off		    */
     int  STE_Chip;     /* STE Chip SPeed   8 Mhz
     			 *                 16 Mhz - No Cache
     			 *                 16 Mhz - Cache
     			 */
  }GEN;
  

struct foobar {
	WORD	dummy;
	WORD	*image;
	};
	
  
 
 /* PROTOTYPES
  *=========================================================================
  */
  
void wait_button( int flag );
int  Pop_Handle( int button, char *items[], int num_items,
                 int *default_item, int font_size, int width );
void  do_redraw( OBJECT *tree, int obj );
void  pop_data( void );
void  Set_Data( void );  
void  XSelect( OBJECT *tree, int button );
void  XDeselect( OBJECT *tree, int button );


 /* EXTERNS
  *=========================================================================
  */
 extern long rs_trindex[];
 extern GEN  cur_value;
 extern XCPB *xcpb;
 extern OBJECT *xtree;
  