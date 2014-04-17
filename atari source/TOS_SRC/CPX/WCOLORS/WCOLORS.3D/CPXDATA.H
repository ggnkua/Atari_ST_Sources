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

     void  *reserve1;
     void  *reserve2;
     
     void  (*rsh_fix)( int num_obs, int num_frstr, int num_frimg,
      		       	     int num_tree, OBJECT *rs_object, 
                       	     TEDINFO *rs_tedinfo, BYTE *rs_strings[],
                       	     ICONBLK *rs_iconblk, BITBLK *rs_bitblk,
                       	     long *rs_frstr, long *rs_frimg, long *rs_trindex,
                       	     struct foobar *rs_imdope );
                       
     void  (*rsh_obfix)( OBJECT *tree, int curob );

     short (*Popup)( char *items[], int num_items, int default_item,
                           int font_size, GRECT *button, GRECT *world );

     void  (*Sl_size)( OBJECT *tree, int base, int slider, int num_items,
                             int visible, int direction, int min_size );
                       
     void  (*Sl_x)( OBJECT *tree, int base, int slider, int value,
                          int num_min, int num_max, void (*foo)() );
                    
     void  (*Sl_y)( OBJECT *tree, int base, int slider, int value,
                          int num_min, int num_max, void (*foo)() );
                    
     void  (*Sl_arrow)( OBJECT *tree, int base, int slider, int obj,
                              int inc, int min, int max, int *numvar,
                              int direction, void (*foo)() );
                        
     void  (*Sl_dragx)( OBJECT *tree, int base, int slider, int min,
                              int max, int *numvar, void (*foo)() );
                        
     void  (*Sl_dragy)( OBJECT *tree, int base, int slider, int min,
                              int max, int *numvar, void (*foo)() );
     
     WORD  (*Xform_do)( OBJECT *tree, WORD start_field, WORD puntmsg[] );
     
     GRECT *(*GetFirstRect)( GRECT *prect );
     GRECT *(*GetNextRect)( void );
     
     void  (*Set_Evnt_Mask)( int mask, MOBLK *m1, MOBLK *m2, long time );

     BOOLEAN (*XGen_Alert)( int id );

     BOOLEAN (*CPX_Save)( void *ptr, long num );
     void    *(*Get_Buffer)( void );

     int     (*getcookie)( long cookie, long *p_value );

     int     Country_Code;
     
     void    (*MFsave)( BOOLEAN saveit, MFORM *mf );          
} XCPB;



typedef struct {
     BOOLEAN	(*cpx_call)( GRECT *work );
     
     void	(*cpx_draw)( GRECT *clip );
     void	(*cpx_wmove)( GRECT *work );
     
     void	(*cpx_timer)( int *quit );
     void	(*cpx_key)( int kstate, int key, int *quit );
     void	(*cpx_button)( MRETS *mrets, int nclicks, int *quit );
     void	(*cpx_m1)( MRETS *mrets, int *quit );
     void	(*cpx_m2)( MRETS *mrets, int *quit );
     BOOLEAN	(*cpx_hook)( int event, int *msg, MRETS *mrets,
                                   int *key, int *nclicks );

     void  	(*cpx_close)( BOOLEAN flag );
}CPXINFO;



#define VERTICAL	0
#define HORIZONTAL	1
/*#define NULLFUNC	( void(*)())0L*/

#define SAVE_DEFAULTS	0
#define MEM_ERR		1
#define FILE_ERR	2
#define FILE_NOT_FOUND	3

#define MFSAVE 1
#define MFRESTORE 0
