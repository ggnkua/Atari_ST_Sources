/*  CPX DATA STRUCTURES
 *==========================================================================
 *  XCPB structure is passed TO the CPX
 *  CPXINFO structure pointer is returned FROM the CPX
 *
 *  xcpb structure is initialized in XCONTROL.C
 */

typedef struct {
     short handle;
     short booting;
     short reserved;  
     short SkipRshFix;

     void    *cdecl (*res1)( void );	    /* ON distribution disk...         */
     BOOLEAN cdecl (*res2)( void *ptr );  /* These 2 would be void *reserved */
     
     void  cdecl (*rsh_fix)( int num_obs, int num_frstr, int num_frimg,
      		       int num_tree, OBJECT *rs_object, 
                       TEDINFO *rs_tedinfo, BYTE *rs_strings[],
                       ICONBLK *rs_iconblk, BITBLK *rs_bitblk,
                       long *rs_frstr, long *rs_frimg, long *rs_trindex,
                       struct foobar *rs_imdope );
                       
     void  cdecl (*rsh_obfix)( OBJECT *tree, int curob );

     short cdecl (*Popup)( char *items[], int num_items, int default_item,
                     int font_size, GRECT *button, GRECT *world );

     void  cdecl (*Sl_size)( OBJECT *tree, int base, int slider, int num_items,
                             int visible, int direction, int min_size );
     
     void  cdecl (*Sl_x)( OBJECT *tree, int base, int slider, int value,
                          int num_min, int num_max, void (*foo)() );
                    
     void  cdecl (*Sl_y)( OBJECT *tree, int base, int slider, int value,
                          int num_min, int num_max, void (*foo)() );
                    
     void  cdecl (*Sl_arrow)( OBJECT *tree, int base, int slider, int obj,
                              int inc, int min, int max, int *numvar,
                              int direction, void (*foo)() );
                        
     void  cdecl (*Sl_dragx)( OBJECT *tree, int base, int slider, int min,
     			      int max, int *numvar, void (*foo)() );
                        
     void  cdecl (*Sl_dragy)( OBJECT *tree, int base, int slider, int min,
                              int max, int *numvar, void (*foo)() );
     
     WORD    cdecl (*Xform_do)( OBJECT *tree, WORD start_field, WORD puntmsg[] );
     GRECT   *cdecl (*GetFirstRect)( GRECT *prect );
     GRECT   *cdecl (*GetNextRect)( void );
     
     void    cdecl (*Set_Evnt_Mask)( int mask, MOBLK *m1, MOBLK *m2, long time );
     BOOLEAN cdecl (*XGen_Alert)( int id );
     BOOLEAN cdecl (*CPX_Save)( void *ptr, long num );
     void    *cdecl (*Get_Buffer)( void );

     int     cdecl (*getcookie)( long cookie, long *p_value );
  
     int     Country_Code;        
     
     void    cdecl (*MFsave)( BOOLEAN saveit, MFORM *mf );
} XCPB;



typedef struct {
     BOOLEAN	cdecl (*cpx_call)( GRECT *work );
     
     void	cdecl (*cpx_draw)( GRECT *clip );
     void	cdecl (*cpx_wmove)( GRECT *work );
     
     void	cdecl (*cpx_timer)( int *event );
     void	cdecl (*cpx_key)( int kstate, int key, int *event );
     void	cdecl (*cpx_button)( MRETS *mrets, int nclicks, int *event );
     void	cdecl (*cpx_m1)( MRETS *mrets, int *event );
     void	cdecl (*cpx_m2)( MRETS *mrets, int *event );
     BOOLEAN	cdecl (*cpx_hook)( int event, int *msg, MRETS *mrets,
                	 	   int *key, int *nclicks );

     void  	cdecl (*cpx_close)( BOOLEAN flag );
}CPXINFO;


