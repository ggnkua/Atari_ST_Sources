/*  FILE: CPXHANDL.C
 *==========================================================================
 *  DATE: February 8, 1990
 *  DESCRIPTION:  Handles CPX calls..ie: Load and execute
 *					 Internal CPX Node Management
 *
 *  INCLUDE FILENAME: CPXHANDL.H
 * 
 *  07/07/92 cjg - if AES Version >= 3.2, save and restore mouse form
 *		   otherwise, do nothing...
 */



/*  INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <string.h>
#include <tos.h>
#include <stdlib.h>

#include "country.h"
#include "xcontrol.h"			/* xcontrol defines		*/

#include "cpxdata.h"			/* These 3 must remain in order */
#include "xstructs.h"			/* Slots.h requires defines in  */
#include "slots.h"			/* cpxdata.h and xsctructs.h    */

#include "xconfig.h"
#include "xcontrl2.h"			
#include "xform_do.h"
#include "windows.h"
#include "xerror.h"
#include "stuffptr.h"
#include "xoptions.h"
#include "mover.h"



/*  PROTOTYPES
 *==========================================================================
 */
long	loadcpx( char *filename );
long    loadprg( char *filename );
long    *loadfile( char *fname );
CPXINFO *cdecl (*CPXinit)( XCPB *xcpb );
void    init_cpxs( void );
void    handle_cpx( int obj, int nclicks );
void	free_baseptr( void );
BOOLEAN cpx_reload( BOOLEAN flag );


CPXNODE	*Get_Last_Node( void );
void	Header_Check( CPXNODE *newptr );
int	count_inactive_nodes( void );


CPXNODE *add_cpxnode( void );
void    clear_node( CPXNODE *tptr, int flag );
void    align_cpxnodes( void );
void	move_to_tail( CPXNODE *curptr );
CPXNODE *get_free_node( char *fname );
void	count_active_nodes( void );
int     load_header( CPXNODE *newptr, char *fname );
void	delete_node( CPXNODE *newptr );


long    *load_bootcpx( char *fname, CPXNODE *newptr, BOOLEAN AllowRes );
void    get_boot_cpxs( DTA *thedta );
char	*make_path( char *fname, char *dirpath );


void	SetCPXstate( BOOLEAN flag );
BOOLEAN IsCPXActive( void );
BOOLEAN IsXCPXActive( void );
BOOLEAN IsCallCPXActive( void );
void    Shut_CPX_Down( int flag );


void	unload_cpx( void );
BOOLEAN cdecl CPX_Save( void *ptr, long num );
void	setup_node( CPXNODE *newptr, DTA *thedta );

BOOLEAN	Disk_Check( CPXNODE *curptr, DTA *thedta );

void    Set_Active_Node( CPXNODE *curptr );
void	Clear_Active_Node( void );
CPXNODE *Get_Active_Node( void );

DTA	*Set_DTA( DTA *thedta );

EXTERN  int AES_Version;

/* DEFINES
 *==========================================================================
 */
#define MIN_NODES	10			/* Minimum # of nodes    */
						/* for headers		 */
#define RESIDENT_OK	1			/* Flags to allow        */
#define NO_RESIDENT	0			/* load_bootcpx to load  */
						/* cpxs and keep resident*/

/* CPX Active Status Flags */
#define CPX_INACTIVE	  0			/* NO CPXs Active...	 */
#define CPX_ACTIVE	  1			/* A CPX is active	 */
#define XCPX_ACTIVE	  1			/* Xform cpx active	 */
#define CALL_CPX_ACTIVE	  2			/* Calls type cpx active */
#define ANY_CPX_ACTIVE	  3	/* 1 + 2 */	/* Either x or call activ*/

#define DFT_BUFFER_SIZE	  38000L		/* Default CPX Buffer size if
						 * no cpxs are loaded AND
						 * Dynamic flag == 0
						 */



/* GLOBALS
 *==========================================================================
 */
int	 cpx_active_flag;	/* CPX displayed or not...
				 * See above for defines
				 */
					 
XCPB	 xcpb;			/* Structure passed to CPXs  */

CPXINFO  *cpxinfo = NULL;	/* Ptr to structure returned from the cpx*/
						
long     *baseptr = NULL;	/* Pointer to the memory where the cpx was
				 * Loaded... ( period ) :-)
				 * The first long contains the address
				 * of the Text Segment ( cpx_init() )
				 * If the cpx is marked 'resident',
				 * the cpx's baseptr can be found in the
				 * baseptr field of its Node.
				 */
/*KB*/long	*loadbuf = NULL; /* static load buffer, used after boot time */
/*KB*/long	loadbufsize = 0L; /* size of static load buffer */

           
CPXNODE *hdptr  = NULL;		/* Parent Head CPX Node Pointer to
				 * the CPX linked list.
				 */

CPXNODE *active_node;		/* This node is SET only by init_cpx
				 * reload_cpx, and handle_cpx
				 * and is the current node. This can 
				 * ONLY be called while a cpx is active
				 * else the address found cannot be
				 * guaranteed.
				 * It is cleared in Shut_Down_CPX()
				 * which is called whenever a cpx was
				 * active, AND the cpx is exiting.
				 * It is used to return the 64 byte
				 * buffer in Get_Buffer()
				 */
				 
int num_active  = 0;		/* # of cpx nodes active...
				 * Does not include blank nodes
				 */
						   
int num_nodes = 0;		/* # of cpx nodes actually available
				 * including blank nodes.
				 * Blanks + Active = num_nodes
				 */
				 
int num_res = 0;		/* # of resident cpxs loaded   */
int num_set = 0;		/* # of set-only cpxs executed */

char newpath[ 128 ];		/* Resulting path and filename for make_path()*/

/* FUNCTIONS
 *==========================================================================
 */



/* init_cpxs()
 *==========================================================================
 * Initializes the cpxs at bootup time.
 * 
 * IN: 	void
 * OUT: void
 *
 * GLOBALS: extern char dirpath[]:	Directory path of cpxs
 *   	    long *baseptr:		Address to load CPX to
 *   	    int  num_active:		Number of Actual Active Nodes
 *   	    int  num_nodes:		Number of Total Nodes
 *	    CPXNODE *hdptr:		Head Pointer to Nodes
 *	    int  active_slot:		Flag for slot status
 *
 * When loading the headers:   -1:      Error has occurred, skip and go on
 *					But, clear the node first
 *				0:	Everything just A Number One
 *				1:	Set-Only CPX...clear the node
 */
void
init_cpxs( void )
{
     DTA thedta, *saved;
     CPXNODE *newptr;
     CPXNODE *curptr;
     int i;
     int flag;
     int vacant_nodes;
     int Total_Nodes;
     long cpxsize;
          
     /* STEP ONE: Using Fsfirst() and Fsnext(), 
      *		1) Load ALL CPX headers into the linked list.
      *		2) As each is loaded, verify them for id and version #s
      *		3) If the header is rejected for any reason, clear the
      *		   node so that it is vacant.
      *	The result is a linked list of cpx headers with potential 
      *	vacant nodes between active nodes.
      * NOTE: In regards to resident CPXs, since we've cleaned out the
      *       older versions of the CPXs, a resident CPX will be the 
      *	      latest version anyways. The only problem that may occur is
      *	      when there is a File I/O error.
      */
     active_slot = NO_SLOT_ACTIVE;
     saved = Set_DTA( &thedta );
     
     if( Fsfirst( dirpath, 0x01 ) == 0 )
     {
         do
         {
              newptr = add_cpxnode();
              
              /* If newptr is zero, we had a malloc error of some
               * sort, so no new slots are going to be allocated.
               * We therefore, just exit this loop.
               */
              if( !newptr )
                       break;

	      /* if an error occurred while loading the header,
	       * skip header initialization and go on to the next cpx.
	       * It will just be a vacant node.
	       */
              flag = load_header( newptr, thedta.d_fname );
              if( flag != -1 )
              {
                 setup_node( newptr, &thedta );
                 Header_Check( newptr );
              }   
              
         }while( Fsnext() == 0 ); 
     }
     Fsetdta( saved );

     /* At this point, we have a linked list of headers.
      * The active headers are mixed in with the inactive headers.
      * There is no count as to the number of CPXs, Resident CPXs,
      * and Set-Only CPXs executed.
      */
      
     /* Now,
      * 0) Align the CPXs so that all inactive CPXs are at the end.
      *    Go through the Linked list and...
      * 1) Initialize the CPXs
      * 2) Maintain the count of CPXs
      */
      
     loadbufsize = 0L;
      
     if( hdptr )		/* We might not have ANY CPX headers */
     {
        align_cpxnodes(); 
        curptr = hdptr;
        /* There should be NO gaps in between active nodes now.
         * So the first time we see one, we have reached the end of
         * the active slots.
         */
        while( curptr && curptr->vacant )
        {
            /* Initialize ONLY non-vacant slots that
             * have their boot-init | resident | set-only flag set
             */
            if( curptr->cpxhead.flags.bootinit ||
                curptr->cpxhead.flags.resident ||
                curptr->cpxhead.flags.setonly )
            {
            
               /* update our counters for set-onlys and resident cpxs */
               if( curptr->cpxhead.flags.setonly ) num_set++;
               
               if( curptr->cpxhead.flags.resident &&
                   !curptr->cpxhead.flags.setonly ) num_res++;
                   
               Set_Active_Node( curptr );
               baseptr = load_bootcpx( &curptr->fname[0], curptr, RESIDENT_OK );
               
               /* Clear the node if ...
                * 1) Set-Only CPX
                * 2) If an error has occurred.
                * NOTE: Baseptr can be ZERO because if the CPX is resident
                *       it clears the baseptr for us.
                */
	       if( ( !baseptr && !curptr->cpxhead.flags.resident ) ||
	           ( baseptr == ( long *)-1L ) ||
	           ( curptr->cpxhead.flags.setonly ) )               
	       {    
                   clear_node( curptr, FALSE );
               }
               free_baseptr();
            }
/*KB*/	    if( !curptr->cpxhead.flags.setonly )
/*KB*/	    {
/*KB*/		cpxsize = curptr->prghead.tsize +
/*KB*/			  curptr->prghead.dsize +
/*KB*/			  curptr->prghead.bsize +
/*KB*/			  CPX_CHICKEN;
/*KB*/		if( cpxsize > loadbufsize ) loadbufsize = cpxsize;
/*KB*/	    }

            curptr = curptr->next;
        }        			/* while( curptr->vacant ) */

#if 0
/*KB*/	if( loadbufsize && !Dynamic )
/*KB*/	{
/*KB*/	    loadbuf = (long *)Malloc( loadbufsize );
/*KB*/	}
	else
	    loadbufsize = 0L;
#endif
	    
     }					/* if( hdptr ) */

     /* if we want Dynamic Allocation of CPXs,
      * Zero out the loadbufsize variable.
      * NO CPX buffer is allocated.
      * OTHERWISE
      * we MUST have a CPX buffer.
      * if there are CPXs, we malloc the largest requested size,
      * otherwise, we will malloc a default size - DFT_BUFFER_SIZE
      * IF a malloc error occurs, loadbuf will be equal to null and
      * normal dynamic mallocing will occur. However, considering that
      * we couldn't even get a buffer, it should be time for the
      * user to reboot.
      *
      * Dynamic ==  0 - Allocate the cpx buffer if needed.
      *             1 - Don't allocate buffer at all. Will execute
      *		   CPXs dynamically.
      */
     if( !Dynamic )
     {
        if( !loadbufsize )
        	loadbufsize = DFT_BUFFER_SIZE;
        loadbuf = ( long *)Malloc( loadbufsize );
     }
     else
        loadbufsize = 0L;
        	
     
     /* At this point, we have initialized the CPXs.
      * However, Set-Only CPXs have had their slots cleared.
      * Therefore, we must align them again.
      * In addition, we now have an unknown number of active and
      * inactive slots.
      * We DO know how many resident and set-only cpxs have been
      * executed.
      */
     Clear_Active_Node();
     align_cpxnodes();
     
     /* we need to count the number of active and inactive slots.
      * then we need to add additional blank slots to the minimum or
      * 1-1/2 times the number of active slots.
      * THEN, we need to assign the CPXs to the XCONTROL Menu starting
      * from the head CPX pointer.
      */
      count_active_nodes();
      vacant_nodes = count_inactive_nodes();      
      
      num_nodes = max(  ( num_active + ( num_active / 2 ) ),
      			num_default_nodes );
      			
      /* vacant_nodes are the number of empty nodes that we already have
       * num_nodes are the TOTAL number of nodes that we want.
       * num_active is the number of active nodes
       * Total_Nodes is the number of both active and non-active nodes that
       * exist currently.
       * NOTE: we might have more vacant nodes than are required, so
       *       we might have to either add more nodes, or even, remove some
       * If there is an error while adding nodes, just exit and
       * use the number of nodes that we DO have...
       */
      Total_Nodes = vacant_nodes + num_active;
      if( num_nodes >= Total_Nodes )	/* Need to Add some blank nodes */
      {
	  num_nodes -= Total_Nodes;
	  for( i = 0; i < num_nodes; i ++ )
	  {
	      newptr = add_cpxnode();
	      if( !newptr )
	      	     break;
	  }      
      }
      else				/* Need to REMOVE some blank nodes*/
      {
      	  num_nodes = Total_Nodes - num_nodes;
      	  for( i = 0; i < num_nodes; i++ )
      	  {
      	      newptr = Get_Last_Node();
      	      delete_node( newptr );
      	  }
      }
      
      /* need to count the number of total nodes now
       * both active and inactive.
       */
      num_nodes = num_active + count_inactive_nodes();
      assign_slots( hdptr );
}





/* Header_Check();
 *==========================================================================
 * Called ONLY by init_cpxs()
 * After loading a new cpx into a node, 
 *	1)   Go thru the link list of nodes comparing
 *	     ID#s and Version #s
 *	2)   if the ID# is not found, use the new cpx in this node
 *		NO ERROR
 *	3)   if FOUND   1) compare the VERSION #
 *			   if( oldnode >= to version #, return error )
 *			       which will not init the cpx and
 *			       clear out the node.
 *			   if( oldnode < version #, clear out oldnode
 *			       including if its resident )
 *			       and use the new cpx in this node
 *			       Free the old node and is baseptr if
 *			       necessary. Adjust the linked list.
 *			       adjust the counts also.
 *			2) Even if found, don't forget to check
 *			   remaining nodes and adjust according to
 *			   the comparing of version #s.
 *
 * IN: CPXNODE *newptr:		Pointer to new node
 * OUT: BOOLEAN	flag:		TRUE - AOK, FALSE - new node deleted.
 */
void
Header_Check( CPXNODE *newptr )
{
    CPXNODE *curptr;
    
    curptr = hdptr;
    
    while( curptr && ( curptr != newptr ))
    {
        if( curptr->vacant &&
            ( curptr->cpxhead.cpx_id == newptr->cpxhead.cpx_id ) )
        {
        
           /* if the current header version number is greater than or
            * equal to the new header, don't clear out the node of the
            * OLD header. Instead, clear out the NEW header and return.
            */
           if( curptr->cpxhead.cpx_version >= 
               newptr->cpxhead.cpx_version )
           {
               clear_node( newptr, FALSE );
               return;
           }
           
           
           /* the OLD cpx header has a version number LESS than the
            * new CPX header. Clear the old one, keep the new one.
            * THEN, we continue and search more nodes.
            */
           if( curptr->cpxhead.cpx_version <
               newptr->cpxhead.cpx_version )
           {    
               clear_node( curptr, FALSE );
           }    
        }
        curptr = curptr->next;
    }
}




/* count_inactive_nodes()
 *==========================================================================
 * Counts the number of inactive nodes in the linked list.
 * IN: void
 * OUT: int:	The number of inactive nodes.
 */
int
count_inactive_nodes( void )
{
   CPXNODE *curptr;
   int     count = 0;
   
   curptr = hdptr;
   while( curptr )
   {
       if( !curptr->vacant )
            count++;
       curptr = curptr->next;
   }
   return( count );
}





/* Get_Last_Node()
 *==========================================================================
 * Returns a pointer to the last NODE in the linked list. 
 */
CPXNODE
*Get_Last_Node( void )
{
    CPXNODE *curptr;
    
    curptr = hdptr;
    
    if( !curptr )
    	return( (CPXNODE *)NULL );
    else
    {
        while( curptr->next )
	   curptr = curptr->next;
	return( curptr );        
    }
}






/* add_cpxnode()
 *==========================================================================
 * A new header node is created and added to the linked list.
 *
 * IN:  void
 * OUT: Returns a pointer to a node
 *
 * GLOBALS:    CPXNODE *hdptr:	   Head Pointer to Nodes
 */
CPXNODE
*add_cpxnode( void )
{
  CPXNODE *newptr;
  CPXNODE *curptr;

  newptr = ( CPXNODE *)Malloc( sizeof( CPXNODE ) );
  if( newptr )
  {
     if( hdptr == NULL )
       	hdptr = newptr;
     else
     {
        curptr = hdptr;
           
        while( curptr->next != NULL )
      		curptr = curptr->next;
        curptr->next = newptr;
     }
     clear_node( newptr, TRUE );
  }  
  return( newptr );
}



/* delete_node()
 *==========================================================================
 * Deletes the node that is passed in.
 * Should be used only when it will not cause fragmentation.
 */
void
delete_node( CPXNODE *newptr )
{
   CPXNODE *curptr;
   
   curptr = hdptr;
   if( newptr == hdptr )
       hdptr = hdptr->next;
   else
   {
       while( curptr->next != newptr )
       		curptr = curptr->next;
       curptr->next = newptr->next;
   }
   if( newptr->baseptr )
       	  Mfree( newptr->baseptr );
   
   if( newptr )    	  
        Mfree( newptr );
   newptr = NULL;     
}



/* free_baseptr()
 *==========================================================================
 * The baseptr points to the address of the load address of the cpx.
 * Note that *baseptr contains the address of Textbase.
 * Baseptr is only good for non-resident cpxs. Resident cpxs do not use
 * this variable.
 *
 * IN:  void
 * OUT: void
 *
 * GLOBALS:  long *baseptr:	Pointer to load address of cpx
 */
void
free_baseptr( void )
{

   if( baseptr && ( baseptr != ( long *)-1L ) && (baseptr != loadbuf) )
   	Mfree( baseptr );
   baseptr = NULL;
}




/* handle_cpx()
 *==========================================================================
 * Load and execute a selected cpx. Resident cpxs are not loaded, of course
 *
 * IN: int obj:		SLOT selected - there are only 4 slots
 *     int nclicks:	1 = Single Click, 2 = Double Click
 *
 * OUT: void
 *
 * GLOBALS: struct SLOT slots[]:   SLOT structure array  - 4 slots total
 *	    long   *baseptr:	   Load address of cpx
 *	    WINFO  w:		   window structure
 *	    XCPB   xcpb:	   XCONTROL struct passed to CPX
 *	    CPXINFO cpxinfo:       Structure RETURNED from CPX
 */
void
handle_cpx( int obj, int nclicks )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];
   unsigned int sindex;
   BOOLEAN  nflag;
   MRETS    m;
   DTA	    thedta, *saved;
   BOOLEAN  found = FALSE;
   CPXNODE  *curptr;
         
   if( (nflag = check_active_slot( obj )) == FALSE  )
   {
      clear_active_slot( TRUE );
      set_active_slot( obj );
   }

      	   		 
   if( nclicks == 1 )
   {
       if( nflag )
            clear_active_slot( TRUE );
       wait_up();
       return;
   }     	       	   			
   
   Evnt_button( 1, 1, 0, &m );	
   
   sindex = ( obj - SLOT0 ) >> 2;
   curptr = slots[ sindex ].sptr;

   if( curptr )
   {
     MFsave( MFSAVE, &mfOther );
     if( AES_Version >= 0x320 )		/* Change ONLY if we're AES 3.2 or > */
        graf_mouse( BUSYBEE, 0L );


     /* Format for Executing CPXs in regards to locating cpx
      * if Resident, just execute it...
      *-------------------------------
      * check if on disk based on filename
      * FOUND? execute
      * NOT FOUND? 1) search *.cpx for NON-setonly cpxs
      *		      and compare ID# and VERSION#  to that in node
      *		   2) no match? File Not Found Error Message
      *		   3) Match? Change node filename to new filename
      *		      Execute
      */
      
     /* Check if residet CPX or not... */
     if( !curptr->cpxhead.flags.resident ) 
     {
        saved = Set_DTA( &thedta );
	found = Disk_Check( curptr, &thedta );
   	if( found )
   	{
           baseptr = loadfile( &curptr->fname[0] );
           MFsave( MFRESTORE, &mfOther );
           if( !baseptr )
              form_alert( 1, Alert5 );
           xcpb.SkipRshFix = FALSE;
        }
        else
        {
           MFsave( MFRESTORE, &mfOther );
           free_baseptr();
           XGen_Alert( FILE_NOT_FOUND );
        }
        Fsetdta( saved );
     }
     else
     {
        MFsave( MFRESTORE, &mfOther );
        xcpb.SkipRshFix = curptr->SkipRshFix;
     }

     
     /*
      * If the cpx is resident, baseptr==NULL and curptr->baseptr==address
      * Otherwise, its the other way around. If both are null or -1L, then
      * we skip the loading process entirely
      */
     if( ( baseptr && ( baseptr != ( long *)-1L ) ) || ( curptr->baseptr ))
     {
       Set_Active_Node( curptr );
       CPXinit = (( curptr->cpxhead.flags.resident ) ? 
       		 ( ( void *)*curptr->baseptr ) :
       		 ( ( void *) *baseptr ));
       cpxinfo = (*CPXinit)( &xcpb );
       
       if( cpxinfo )
       {
	  SetCPXstate( CPX_ACTIVE );
          if( !(*cpxinfo->cpx_call)( &w.work ))
          {
             Shut_CPX_Down( FALSE );
             clear_active_slot( FALSE );  /* CJG 10/23/90 */
          }   
	  else
	     SetCPXstate( CALL_CPX_ACTIVE );
       }
       else
       {
         Shut_CPX_Down( FALSE );
         clear_active_slot( FALSE );   /* CJG 10/23/90 */
       }  
         
       	/* If CPX is a Call-type cpx, we don't clear the CPXACTIVE flag,
       	 * Instead, we set it to CALL_CPX_ACTIVE ( see 1 line above )
       	 */
       if(  curptr->cpxhead.flags.resident && 
           !curptr->SkipRshFix )
            curptr->SkipRshFix = TRUE;
           
       xcpb.SkipRshFix = FALSE;
/*       clear_active_slot( FALSE );	CJG 10/23/90 Moved this to 2 locations above.
 *					Only Clear the Active Slot if Form CPX or
 *					if the Event CPX is exiting. 
 *					Previous bug was that this cleared 'Active_Slot'
 *					all the time and we don't want to for 'Event_CPX's.
 */
       CheckXAccClose();
       CheckXWmClose();
       
       if( !IsCPXActive() && ( w.id != NO_WINDOW ) )
       {
       	     Slot_Color_Update();
             do_redraw( tree, ROOT, &w.work );
       }      
     }
     else
       clear_active_slot( TRUE );
   }
}



/* IsCallCPXActive()
 *==========================================================================
 * Checks if a Call-type cpx is active
 *
 * IN:	void
 * OUT: BOOLEAN
 *
 * GLOBAL:	int cpx_active_flag:	See defines for status flags
 */
BOOLEAN
IsCallCPXActive( void )
{
     return( cpx_active_flag & CALL_CPX_ACTIVE );
    
}



/* IsCPXActive()
 *==========================================================================
 * Checks if ANY cpx is active
 *
 * IN:	void
 * OUT: BOOLEAN
 *
 * GLOBAL:	int cpx_active_flag:	See defines for status flags
 */
BOOLEAN
IsCPXActive( void )
{
     return( cpx_active_flag & ANY_CPX_ACTIVE );
}



/* IsXCPXActive()
 *==========================================================================
 * Checks if an Xform_do type cpx is active
 *
 * IN:	void
 * OUT: BOOLEAN
 *
 * GLOBAL:	int cpx_active_flag:	See defines for status flags
 */
BOOLEAN
IsXCPXActive( void )
{
    return( cpx_active_flag & XCPX_ACTIVE );
}



/* SetCPXstate()
 *==========================================================================
 * Set the CPX active flag 
 *
 * #define CPX_INACTIVE	        0		 NO CPXs Active...	
 * #define CPX_ACTIVE	        1		 A CPX is active	 
 * #define XCPX_ACTIVE	  	1		 Xform cpx active	
 * #define CALL_CPX_ACTIVE	2		 Calls type cpx active
 * #define ANY_CPX_ACTIVE	3		 Either x or call active
 *
 * IN: BOOLEAN flag:		New state of cpx_active_flag
 * OUT: void
 *
 * GLOBAL:   int cpx_active_flag:	See states possible
 */
void
SetCPXstate( BOOLEAN flag )
{
    cpx_active_flag = flag;
}



/* loadfile()
 *==========================================================================
 * Append the cpx directory path and cpx filename and call load routine
 *
 * IN:	char *fname:	filename without the directory path
 * OUT: long *ptr:	Pointer to load address of cpx.
 *			if 0  or -1, an error had occurred.
 *
 * GLOBALS:  char dirpath[]:	directory path of cpxs
 */
long *loadfile( char *fname )
{
    long *cpx_ldaddr;
    char *filename;
        
    filename = make_path( fname, dirpath );
           
    /* returns 0, -1, or basepage address */
    cpx_ldaddr = ( long *)loadcpx( filename );
    return( cpx_ldaddr );
}






/* make_path
 *==========================================================================
 * Appends the filename onto the directory path. The directory path 
 * is shortened to the farthest right '\\' or '\0'
 *
 * IN: char *fname:	filename
 *     char *dirpath:   directory path
 *
 * OUT: returns a pointer to a 128 byte character buffer
 *
 * GLOBAL: char newpath[ 128 ];
 */
char
*make_path( char *fname, char *dirpath )
{
    long i;

    strcpy( newpath, dirpath );
    
    for( i = strlen( newpath );
         i && ( newpath[ i ] != '\\' );
         newpath[ i-- ] = '\0' );
         
    strcat( newpath, fname );
    
    return( &newpath[ 0 ] );
}


/* load_header()
 *==========================================================================
 * Opens CPX and reads in the header.
 * Take the header and shoves it into the CPXNODE.
 * If there is an error, or if the CPX is a set-only cpx, the calling
 * routine should clear the node.
 *
 * IN:  CPXNODE *newptr:		CPXNODE to store header in
 *      char *fname:			filename of cpx to load
 *
 * OUT: 0 - AOK, nothing special, cpx loaded just fine
 *      1 - AOK, but the cpx is a SET-ONLY cpx, ergo, clear node afterwards
 *     -1 - ERROR - An error occurred for whatever reason.
 *
 * GLOBAL:  char dirpath[]:	Directory path of cpxs
 */
int
load_header( CPXNODE *newptr, char *fname )
{
  int  fd;
  long bytes;
  char *filename;
  
  filename = make_path( fname, dirpath );
  if( ( fd = Fopen( filename, 0 ) ) > 0 )
  {
      bytes = Fread( fd, sizeof(CPXHEAD) + sizeof(Prghead), &newptr->cpxhead );
      Fclose( fd );
      if( bytes != sizeof(CPXHEAD) + sizeof(Prghead) )
         return( -1 );

      /* Return Error if file isn't even a CPX */
      if( newptr->cpxhead.magic != MAGIC_CPX_NUM )
       	   return( -1 );
      return( newptr->cpxhead.flags.setonly );
  }
  /* fd can be numbers < 0, so force them to -1, else return fd */
  return(( ( fd < 0) ? ( -1 ) : ( fd ) ));
}





/* cpx_reload()
 *==========================================================================
 * Reloads cpxs
 * 1) If cpx is resident, it is not reloaded.
 * 2) Otherwise, we will unload ALL other CPXs
 * 3) New CPXs on the disk are loaded and initiaized.
 * 4) New CPXs marked as resident are treated as regular cpxs.
 * 5) New cpxs that exceend the number of available.
 * 6) Set-Only CPXs are ignored?
 *
 * IN:  TRUE - Reload From MOVER/RENAME
 *      FALSE - Reload From XCONFIG
 *
 * OUT: TRUE - OK
 *      FALSE - Cancel
 *
 * GLOBALS:   char dirpath[]:	Directory path of cpxs
 *	      CPXNODE *hdptr:   Head Pointer of nodes
 */
BOOLEAN
cpx_reload( BOOLEAN flag )
{
    OBJECT *ad_xinfo = ( OBJECT *)rs_trindex[ XINFO ];
    OBJECT *ad_tree  = ( OBJECT *)rs_trindex[ XCONTROL ];
    OBJECT *tree;
    
    CPXNODE *curptr;
    DTA thedta, *saved;
    BOOLEAN button = FALSE;
    
    if( !flag )		/* Called from XCONFIG */
    {
      ActiveTree( ad_xinfo );
      select( tree, RELOAD );
      wait_up();
    }
			/* else, RENAME/MOVER called it */
			    
    if( XGen_Alert( RELOAD_CPXS ) )
    {
      MFsave( MFSAVE, &mfOther );
      if( AES_Version >= 0x320 )		/* Change ONLY if we're AES 3.2 or > */
         graf_mouse( BUSYBEE, 0L );
      
      ActiveTree( ad_tree );
      saved = Set_DTA( &thedta );

      curptr = hdptr;
      do
      {
         /* Break if there are no more active nodes */
         if( !curptr->vacant )
         	break;

         /* All nodes that are not resident are freed up.
          * Flush the node, but keep the pointer.
          */
	 if( !curptr->cpxhead.flags.resident )
	         clear_node( curptr, FALSE );
	 curptr = curptr->next;         
      }while( curptr );
      align_cpxnodes();

      /*
       * For NEW CPXs not in the nodes yet...
       * See get_boot_cpxs() for actual details...
       * Brief explanation...
       *------------------------------------------
       * Search for *.CPX
       * For EVERY CPX....
       * 
       * 1) Check ID#s to those in nodes
       *       If FOUND, skip
       *    NOTE: only resident CPXs will have remained.
       * 2) Load otherwise, unless the CPX is > loadbuffsize
       * 3) If RESIDENT CPX, ignore flag and treat as a normal CPX.
       * 4) Set-Only CPXs are executed.
       */
      get_boot_cpxs( &thedta );
      
      count_active_nodes();
      assign_slots( hdptr );
      Fsetdta( saved );
      init_slider();
      MFsave( MFRESTORE, &mfOther );
      button = TRUE;
    }
    
    if( !flag )
    {    
      ActiveTree( ad_xinfo );
      Deselect( RELOAD );
      Objc_draw( tree, RLDBASE, MAX_DEPTH, NULL );  
    }
    return( button );  
}



/* count_active_nodes()
 *==========================================================================
 * Count the number of actual existing loaded cpx nodes
 * NOTE: This assumes that ALL of the active nodes have already been 
 * aligned. Therefore, before calling this, you must align the nodes
 * so that there are no empty nodes between active ones.
 *
 * IN:	void
 * OUT: void
 *
 * GLOBALS:	CPXNODE *hdptr:	Headpointer to cpx nodes
 *		int num_active: Number of cpx nodes active
 */
void
count_active_nodes( void )
{
    CPXNODE *curptr;
    int count = 0;
    
    curptr = hdptr;
    
    while( curptr && ( curptr->vacant ))
    {
        count++;
    	curptr = curptr->next;
    }
    num_active = count;
}



/* clear_node()
 *==========================================================================
 * Zero out a cpx node
 * If flag == true, destroy the next link ptr also
 *
 * IN: CPXNODE *tptr:	   Pointer to cpx node to zero out
 *     int     flag:       TRUE - zero out tptr->next also
 *
 * OUT: void
 */
void
clear_node( CPXNODE *tptr, int flag )
{
   tptr->fname[0] = '\0';
   tptr->baseptr  = NULL;
   tptr->vacant   = FALSE;	/* Only this one really counts */
   tptr->cpxhead.flags.resident = FALSE;
   tptr->SkipRshFix = FALSE;
      
   if( flag )
   	tptr->next = NULL;
}



/* align_cpxnodes()
 *==========================================================================
 * Sort the nodes so that all active nodes are at the beginning of the
 * linked list. Therefore, there are no blank nodes between any two
 * active nodes.
 *
 * IN:	void
 * OUT: void
 *
 * GLOBALS:   CPXNODE *hdptr:	Head Pointer to cpx nodes
 *	      int  num_nodes:   Number of total cpx nodes
 */
void
align_cpxnodes( void )
{
    CPXNODE *curptr;
    CPXNODE *prevptr;
    CPXNODE *lastptr;
    
    lastptr = prevptr = curptr = hdptr;
    
    while( lastptr && lastptr->next )
    	 lastptr = lastptr->next;
    	 
    while( curptr && ( curptr != lastptr ) )
    {
        if( curptr == NULL )
        	break;
        	
        if( curptr->vacant )
        {
           prevptr = curptr;
           curptr  = curptr->next;
        }
        else
        {
           if(( prevptr == hdptr ) && ( curptr == hdptr ) )
           {
              prevptr = prevptr->next;
              move_to_tail( curptr );
              hdptr = curptr = prevptr;
           }
           else
           {
              prevptr->next = curptr->next;
              move_to_tail( curptr );
              curptr = prevptr->next;
           }
        }
    } 
}




/* move_to_tail()
 *==========================================================================
 * Move the node to the end of the linked list
 *
 * IN:	CPXNODE *curptr:	Pointer to node which is to go to the tail
 * OUT: void
 *
 * GLOBALS:  CPXNODE *hdptr:    head pointer to cpx nodes
 */
void
move_to_tail( CPXNODE *newptr )
{
   CPXNODE *curptr;
   
   curptr = hdptr;
   
   while( curptr->next )
   	 curptr = curptr->next;
   curptr->next = newptr;
   newptr->next = NULL;   
}




/* get_boot_cpxs()
 *==========================================================================
 * Load the cpxs and call their cpx_init routines
 * This routine is called by the actual entry routines.
 *
 * IN:  DTA *thedta		Pointer to the DTA
 * OUT: void
 *
 * GLOBALS:  char dirpath[]:    Directory path for cpxs
 *           long *baseptr:	Load Address of cpxs
 *	     XCPB xcpb.booting: TRUE - treat cpxinit calls
 *				as cold boots, vs warm boots
 */
void
get_boot_cpxs( DTA *thedta )
{
   CPXNODE *newptr;
   int     flag;
   BOOLEAN match = FALSE;
   CPXNODE *curptr;
   long cpxsize;

   /*
    * For NEW CPXs not in the nodes yet...
    * See get_boot_cpxs() for actual details...
    * Brief explanation...
    *------------------------------------------
    * Search for *.CPX
    * For EVERY CPX....
    * 1) Check ID#s to those in nodes
    *    If FOUND, skip
    * 2) Load CPX, unless size of cpx > buffer size available.
    * 3) If RESIDENT CPX, ignore flag
    * 4) Set-Only's are executed.
    */
   
   
   xcpb.booting = TRUE;
   if( Fsfirst( dirpath, 0x01 ) == 0 )
   {
      do
      {
	 match = FALSE;
         newptr = get_free_node( thedta->d_fname );
         if( ( newptr != NULL ) && ( newptr != ( CPXNODE *)-1 ))
         {

	    /* 0 - OK CPX, 1 = Set-Only CPXs, -1 = Error! */
 	    flag = load_header( newptr, thedta->d_fname );
            if( !flag || ( flag == 1 ) )
            {
               /* 
                * Search thru the linked list for matching ID#
                * We'll skip the load and clear the node IF
                * a match is found...
                * Note that ONLY Resident CPXs remain.
                */
	       curptr = hdptr;
	       while( curptr )
               {
                  if( ( curptr->cpxhead.cpx_id == newptr->cpxhead.cpx_id )
                      && curptr->vacant )
		      match = TRUE;
	          curptr = curptr->next;
               }
               setup_node( newptr, thedta );


	       /* The NEW cpx isn't loaded, but we check first to
	        * see if it will even fit in the existing buffer.
	        * If NOT, alert message, and go on to the next iteration
	        * Check Here because we want to check ALL cpxs that are
	        * being reloaded.
	        */
	       if( !match && loadbufsize )
	       {
		  cpxsize = newptr->prghead.tsize +
			    newptr->prghead.dsize +
			    newptr->prghead.bsize +
			    CPX_CHICKEN;
			    
		  if( cpxsize > loadbufsize )
		  {
   		      strcpy( newpath, Alert4A );
   		      strcat( newpath, thedta->d_fname );
		      strcat( newpath, Alert4B );
   		      form_alert( 1, newpath );
		      match = TRUE;	/* The size is greater than the buffer.
		      			 * Set the 'match' flag to clear the node 
		      			 */
		  }
	          
	       } 
	        
	        
	        
	       /*-----------------------------------------------
                * The NEW cpx isn't loaded, based on ID#s
                * So go ahead and load the cpx
                * AND don't load it if cpxsize is > loadbufsize 
                */
               if( !match &&
                   ( newptr->cpxhead.flags.bootinit ||
                     newptr->cpxhead.flags.setonly  ||
                     newptr->cpxhead.flags.resident ) )
               {
                 Set_Active_Node( newptr );
                 baseptr = load_bootcpx( thedta->d_fname, newptr, NO_RESIDENT );

		 /* if an error occurred, we will want to free up the node also. */
                 if( !baseptr || ( baseptr == ( long *)-1L ))
                       flag = 1;
                 free_baseptr();
               }
            }
          
	    /*------------------------------------------- 
             * Clear the node if Set-Only CPX or bad load
             * or when ID#s match
             */
            if( flag || match )
	        clear_node( newptr, FALSE );
         }       

      }while( newptr && ( Fsnext() == 0 ));
   }
   Clear_Active_Node();
   xcpb.booting = FALSE;
}




/* setup_node()
 *==========================================================================
 * Loads the cpxs DTA information into the CPXNODE
 * IN addition, it set the node to non-vacant
 */
void
setup_node( CPXNODE *newptr, DTA *thedta )
{
    strcpy( &newptr->fname[0], thedta->d_fname );
    newptr->vacant = TRUE;    
}





/* get_free_node()
 *==========================================================================
 * Locate an available zero'ed node in the linked list
 *
 * IN: char *fname:   filename of cpx without the directory path
 * OUT: Pointer to the node or NULL if none available
 *
 * GLOBAL: CPXNODE *hdptr:	head pointer to nodes
 */
CPXNODE 
*get_free_node( char *fname )
{
  CPXNODE *curptr;
  
  curptr = hdptr;
  while( curptr && ( curptr->vacant ) )
  {
     if(  ( curptr->vacant ) && !strcmp( curptr->fname, fname ) )
     {
     	curptr = ( CPXNODE *)-1;
     	break;
     }
     else
  	curptr = curptr->next;
  }

  if( !curptr )
        XGen_Alert( NO_NODES_ERR );
  return( curptr );
}




/* load_bootcpx()
 *==========================================================================
 * Load a cpx and call its' cpx_init
 * Check also to see if the cpx is resident or not and whether to
 * install it as such.
 *
 * IN:	char *fname:	   filename of cpx without directory path
 *	CPXNODE *newptr:   node to stuff header info into
 *	BOOLEAN AllowRes:  Allow Resident cpxs: TRUE - yes
 *
 * OUT: long		   return baseptr which can be 0, -1 or 
 *			   the load address of the cpx.
 *
 * GLOBAL: CPXINFO cpxinfo: ptr to structure returned from cpx
 *	   CPXinit:	    Pointer to function to init cpxs
 */
long
*load_bootcpx( char *fname, CPXNODE *newptr, BOOLEAN AllowRes )	
{
    long *baseptr;
    
    baseptr = loadfile( fname );
    if( baseptr && ( baseptr != ( long *)-1L ) )
    {
       CPXinit = ( void *)*baseptr;
       cpxinfo = (*CPXinit)( &xcpb );

       if( cpxinfo )
       {
	  /* Notice that Set-only cpxs are skipped */
          if( AllowRes && newptr->cpxhead.flags.resident &&
              !newptr->cpxhead.flags.setonly )
          {
             newptr->baseptr = baseptr;
             baseptr = NULL;
          }
          else
             newptr->cpxhead.flags.resident = FALSE;    
       }
    }
    return( baseptr );
}






/* unload_cpx()
 *==========================================================================
 * Unload a cpx from the linked list.
 * Do not unload a resident cpx...
 */
void
unload_cpx( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];
   CPXNODE  *cur_node; 

   if( XGen_Alert( UNLOAD_CPX ) )
   {
      cur_node = get_cpx_from_slot();
      if( cur_node && !cur_node->cpxhead.flags.resident )
      {
         clear_node( cur_node, FALSE );
	 clear_active_slot( FALSE );
         align_cpxnodes();
         count_active_nodes();
         assign_slots( hdptr );
         init_slider();
         Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
      }
     else
       XGen_Alert( NO_RELOAD );
   }
}





/*==========================================================================
 * Routines to Handle CPXs that don't use XFORM_DO
 */
 
 
/* SetEvntMask()
 *==========================================================================
 * Sets the event that the cpx is looking for.
 * XCONTROL however, must have its own mask also, as shown in Event_Mask
 *
 * IN:  int mask:	event mask - ie: Evnt_Mesag
 *      MOBLK *m1:	Mouse hot spot rectangle
 *	MOBLK *m2:  	Mouse hot spot rectangle
 *	long timer:	Timer	- 2000L  = 2 secs
 *
 * OUT: void
 *
 * GLOBAL: int Event_Mask:  Mask that Xcontrol always needs for events
 */ 
void
cdecl
SetEvntMask( int mask, MOBLK *m1, MOBLK *m2, long timer )
{
     evnt_set( Event1_Mask | mask , 2, 1, 1, m1, m2, timer );
}



/* Close_Call_CPX()
 *==========================================================================
 * Is used during ACC_CLOSE and WM_CLOSED messages
 * We call the CPX close routine, they free up any memory
 * then we return and close up Xcontrol with whatever...
 *
 * IN:  TRUE - ACC_CLOSE() - treat like a CANCEL
 *      FALSE - WM_CLOSED() - treat like an OK!
 *
 * OUT: void
 *
 * GLOBAL: CPXINFO cpxinfo:	pointer to structure returned from cpx
 */
void
Close_Call_CPX( BOOLEAN flag )
{
   if( IsCallCPXActive() )
   {
	if( cpxinfo && cpxinfo->cpx_close )
		(*cpxinfo->cpx_close)( flag );	
   }
}



/* Shut_CPX_Down()
 *==========================================================================
 * Used to Clear out evidence that a CPX even existed...
 * Baseptr is cleared, but remember, this does not clear out resident
 * cpxs.
 *
 * IN:    int flag:	After shutting down cpx, redraw? TRUE - yes
 * OUT:   void
 *
 * GLOBAL:  CPXINFO cpxinfo:	Pointer to structure returned from cpx
 *	    WINFO   w:		window structure
 */
void
Shut_CPX_Down( int flag )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];

   cpxinfo = NULL;
   Clear_Active_Node();
   SetCPXstate( CPX_INACTIVE );
   free_baseptr();
   evnt_set( Event1_Mask, 2, 1, 1, NULL, NULL, 30000L );
   if( flag )
   {
       Slot_Color_Update();
       do_redraw( tree, ROOT, &w.work );
   }    
}



/* cpx_button()
 *==========================================================================
 * Calls the cpx button routines
 *
 * IN:	MRETS *mrets:	mouse rectangle info
 *	int   nclicks:  Number of clicks during event
 * OUT: void
 *
 * GLOBAL:  CPXINFO cpxinfo:  Pointer to structure returned from cpx
 */
void
cpx_button( MRETS *mrets, int nclicks )
{
   int flag = FALSE;			/* Shut CPX down flag */
   
   if( IsXCPXActive() )
	return;
       	
   if( IsCallCPXActive() )
   {
     if( cpxinfo && cpxinfo->cpx_button )
     {
        (*cpxinfo->cpx_button)( mrets, nclicks, &flag );
        if( flag )
        {
             clear_active_slot( FALSE );  /* CJG 10/23/90 */
     	     Shut_CPX_Down( TRUE );
     	}     
     }
   }		
}



/* cpx_timer()
 *==========================================================================
 * Calls the cpx timer routines
 *
 * IN:	void
 * OUT: void
 *
 * GLOBAL:  CPXINFO cpxinfo: Pointer to structure returned from cpx
 */
void
cpx_timer( void )
{
   int flag = FALSE;			/* Shut CPX down flag */
   
   if( IsCallCPXActive())
   {
     if( cpxinfo && cpxinfo->cpx_timer )
     {
	 (*cpxinfo->cpx_timer)( &flag );
	 if( flag )
	 {
             clear_active_slot( FALSE );  /* CJG 10/23/90 */
   	     Shut_CPX_Down( TRUE );
	 } 	  
     }
   }
}




/* cpx_draw()
 *==========================================================================
 * Calls the cpx redraw routines
 *
 * IN: GRECT *rect:	Area for cpx to redraw. Note, cpx must still
 *			go down the rectangle list.
 * OUT: void
 *
 * GLOBAL:  CPXINFO cpxinfo: Ptr to structure returned from cpx
 */
void
cpx_draw( GRECT *rect )
{
   if( IsCallCPXActive() )
   {
      if( cpxinfo && cpxinfo->cpx_draw )
          	(*cpxinfo->cpx_draw)( rect );
   }
}




/* cpx_move()
 *==========================================================================
 * Calls the cpx window has moved routines
 *
 * IN:   GRECVT *rect:		New GRECT location of window work area
 * OUT:  void
 *
 * GLOBAL:  CPXINFO cpxinfo: Ptr to structure returned from cpx
 */
void
cpx_move( GRECT *rect )
{
     if( IsCallCPXActive() )
     {
        if( cpxinfo && cpxinfo->cpx_wmove )
          (*cpxinfo->cpx_wmove)( rect );
     }
}





/* cpx_key()
 *==========================================================================
 * calls the CPX keyboard routines
 *
 * IN:   int keystate:		Well, keystate info
 *       int key:		which key was pressed
 *
 * OUT:  void
 *
 * GLOBAL:   CPXINFO cpxinfo: Ptr to structure returned from cpx
 */
void
cpx_key( int keystate, int key )
{
   int flag = FALSE;		/* Shut CPX down flag */
   
   if( IsCallCPXActive() )
   {
       if( cpxinfo && cpxinfo->cpx_key )
          	(*cpxinfo->cpx_key)( keystate, key, &flag );
       if( flag )
       {
          clear_active_slot( FALSE );  /* CJG 10/23/90 */
	  Shut_CPX_Down( TRUE );
       }	  
   }
}



/* cpx_m1()
 *==========================================================================
 * Calls the cpx hot spot mouse rectangle number one routines
 *
 * IN:    MRETS *mrets:		Mouse rectangle information
 * OUT:   void
 * 
 * GLOBALS:   CPXINFO cpxinfo:  ptr to structure returned form cpx
 */
void
cpx_m1( MRETS *mrets )
{
   int flag = FALSE;		/* Shut CPX down flag */
   
   if( IsCallCPXActive() )
   {
      if( cpxinfo && cpxinfo->cpx_m1 )
      {
         (*cpxinfo->cpx_m1)( mrets, &flag );
         if( flag )
         {
             clear_active_slot( FALSE );  /* CJG 10/23/90 */
             Shut_CPX_Down( TRUE );
         }	
      }
   }
}





/* cpx_m2()
 *==========================================================================
 * Calls the cpx hot spot mouse rectangle number two routines
 *
 * IN:   MRETS *mrets:		mouse rectangle information
 * OUT:  void
 * 
 * GLOBAL:  CPXINFO cpxinfo:  Ptr to structure returned from cpx
 */
void
cpx_m2( MRETS *mrets )
{
  int flag = FALSE;			/* Shut CPX down flag */
  
  if( IsCallCPXActive() )
  {
     if( cpxinfo && cpxinfo->cpx_m2 )
     {
        (*cpxinfo->cpx_m2)( mrets, &flag );
        if( flag )
        {
             clear_active_slot( FALSE );  /* CJG 10/23/90 */
             Shut_CPX_Down( TRUE );
        }     
     }
  }
}



/* cpx_hook()
 *==========================================================================
 * Calls hook event routines which is BEFORE event-multi processing
 *
 * IN:   int event:			Event that occurred
 *       MRETS *mrets:		        mouse rectangle information
 *	 int   *key:			key click?
 *	 int   *nclicks:		Number of button clicks
 *
 * OUT:  BOOLEAN:	TRUE or FALSE - True to preempt regular
 *			                event_multi processing.
 *
 * GLOBAL:  CPXINFO cpxinfo:	Ptr to structure returned from cpx
 */
BOOLEAN
cpx_hook( int event, int *msg, MRETS *mrets, int *key, int *nclicks )
{
    int flag = FALSE;
    
    if( IsCallCPXActive() )
    {
       if( cpxinfo && cpxinfo->cpx_hook )
       	   flag = (*cpxinfo->cpx_hook )( event, msg, mrets, key, nclicks );
    }
    return( flag );
}


/*==========================================================================
 * END of Event CPX routines.
 *==========================================================================
 */





/* CPX_Save()
 *==========================================================================
 * Writes X number of bytes specified FROM the pointer supplied TO
 * the Data segment of the active CPX.
 *
 * IN:   void *ptr:	Pointer to data
 *	 long num:	Number of bytes to write at DATA segment
 *
 * OUT:  BOOLEAN	TRUE  - OK
 *			FALSE - ERROR
 */
BOOLEAN
cdecl
CPX_Save( void *ptr, long num )
{
    CPXNODE *curptr;
    int  fd;
    Prghead cpxbase;    
    long    bytes;
    BOOLEAN found = FALSE;
    DTA	    thedta, *saved;
    char    *filename;
                
    curptr = get_cpx_from_slot();
    saved = Set_DTA( &thedta );
    found = Disk_Check( curptr, &thedta );
    Fsetdta( saved );

   if( found )
   {
      filename = make_path( curptr->fname, dirpath );
      if( (fd = Fopen( filename, 2 )) > 0 )
      {
        /* seek past the cpx header - 512 bytes */
        Fseek( sizeof( CPXHEAD ) , fd, 0 );
    
        /* read in the pseudo-base page */
        Fread( fd, sizeof( cpxbase ),  &cpxbase );
    
        /* Seek past the text segment */
        Fseek( cpxbase.tsize, fd, 1 );

	/*
         * Now at Data Segment, so start writing num bytes from ptr
         * Check for errors, ie, disk is write protected.
         */
         
        bytes = Fwrite( fd, num, ptr );
        found =  ( bytes == num );
        Fclose( fd );
      }
      else
      {
         found = FALSE;
         XGen_Alert( FILE_ERR );
      }   
    }  
    else
      XGen_Alert( FILE_NOT_FOUND );
    
    return( found ); /* returns 1 if ok, 0 if error occured... */
}
   
   
   
/* Get_Buffer()
 *==========================================================================
 * Return a pointer to the 64 byte buffer in the cpx node for
 * use by the CPX. This area is meant to be used by cpxs that require
 * read only registers and need a non-volatile area to store its stuff.
 */
void
*cdecl Get_Buffer( void )
{
   CPXNODE *curptr;
					   
   curptr = Get_Active_Node();		
   if( curptr )
       return( curptr->cpxhead.buffer );
   else
       return( NULL );					 
}




/* Get_Head_Node()
 *==========================================================================
 * Returns the CPXNODE head pointer to the linked list.
 * This is ONLY for the cpx file that will be modifying the header.
 * Nobody else should be messing with this.
 */
void
*cdecl Get_Head_Node( void )
{
    return( ( void * )hdptr );
}



/* Save_Header()
 *==========================================================================
 * Save the CPX header to its file
 * Note, this should ONLY be called from the special cpx that is modifying
 * the cpxnode linked list.
 *
 * IN: void *ptr:	The pointer to the cpx node in which the header
 *			is to be saved.
 *			It must be cast to CPXNODE structure pointer.
 */
BOOLEAN
cdecl
Save_Header( void *ptr )
{
     CPXNODE *curptr;
     unsigned magic;
     int  fd;
     BOOLEAN found = FALSE;
     DTA     thedta, *saved;
     long    bytes;
     char    *filename;
        
     
     curptr = ptr;
     /* proceed to save the header...following the usual
      * routes of checking for id# and version# if file not found
      * initially...
      */
     if( curptr->vacant )
     {
	 saved = Set_DTA( &thedta ); 
	 found = Disk_Check( curptr, &thedta );
         Fsetdta( saved );
     
     
      if( found )
      {
         filename = make_path( curptr->fname, dirpath );
         if( (fd = Fopen( filename, 2 )) > 0 )
         {
            MFsave( MFSAVE, &mfOther );
            if( AES_Version >= 0x320 )		/* Change ONLY if we're AES 3.2 or > */
               graf_mouse( BUSYBEE, 0L );

            Fread( fd, 2L, &magic );
            if( magic == curptr->cpxhead.magic ) 
      	    {
      	       /* move the file pointer back to the front */
               Fseek( 0L, fd, 0 );
               bytes = Fwrite( fd, sizeof( CPXHEAD ), &curptr->cpxhead );
               found = ( bytes == sizeof( CPXHEAD ) );
            }
            else
            {
              XGen_Alert( FILE_NOT_CPX );
              found = FALSE;
            }
            Fclose( fd );
            MFsave( MFRESTORE, &mfOther );
         }
         else
         {
            found = FALSE;
            XGen_Alert( FILE_ERR );
         }          
       }
       else
         XGen_Alert( FILE_NOT_FOUND );  
         
     }
     return( found );	/* 1 = OK, 0 == ERROR */
}






/*  Disk_Check()
 *==========================================================================
 *  
 *  There is a request to do something with the associated CPX file that
 *  currently resides in the node linked list.
 *  Disk check will search for that file FIRST.
 *  1) if it find cannot find the file, XCONTROL will search the other
 *     cpxs and compare for a matching id# and version#.
 *     If found, xcontrol will rename the node's filename to the new cpx
 *     just found and return true.
 *     if not found, return false.
 *  2) if the original file is found, check that the id# and version#
 *     are the same, otherwise, search the rest of the cpxs and
 *     compare id#s and verson#s.
 */
BOOLEAN
Disk_Check( CPXNODE *curptr, DTA *thedta )
{
  int     flag;
  BOOLEAN found = FALSE;
  CPXNODE tmpnode;

  flag = load_header( &tmpnode, curptr->fname );
  if( flag != -1 )
  {
     if( ( curptr->cpxhead.cpx_id == tmpnode.cpxhead.cpx_id )
           && ( curptr->cpxhead.cpx_version == 
                tmpnode.cpxhead.cpx_version ) )
     found = TRUE;
  }

  if( !found && Fsfirst( dirpath, 0x1 ) == 0 )
  {
      do
      {
         flag = load_header( &tmpnode, thedta->d_fname );
         if( flag != -1 )
         {
 	   if( ( curptr->cpxhead.cpx_id == tmpnode.cpxhead.cpx_id )
	         && ( curptr->cpxhead.cpx_version ==
	              tmpnode.cpxhead.cpx_version )
	         && !tmpnode.cpxhead.flags.setonly )
	   {
	       found = TRUE;
	       strcpy( curptr->fname, thedta->d_fname );
	   }
         }
      }while(( Fsnext() == 0 ) && !found );
  }
  return( found );
}



/* Set_Active_Node();
 *==========================================================================
 * It was discovered that there was no way to get a pointer to the
 * current active node other than going through the active slot, which
 * is not valid during a reload or init_cpx() call.
 * This routine will SET the active_node.
 */
void
Set_Active_Node( CPXNODE *curptr )
{
    active_node = curptr;
}



/* Clear_Active_Node()
 *==========================================================================
 * Call this to clear the active_node pointer.
 * It should be cleared whenever there is no CPX active.
 * Shut_Down_CPX() calls this routine and should be able to handle
 * all cases.
 */
void
Clear_Active_Node( void )
{
    active_node = NULL;
}



/* Get_Active_Node()
 *==========================================================================
 * Return the active cpx node currently in use. Null otherwise.
 */
CPXNODE
*Get_Active_Node( void )
{
  return( active_node );
}



/* Set_DTA()
 *==========================================================================
 * Set the DTA and return the old DTA
 */
DTA 
*Set_DTA( DTA *thedta )
{
   DTA *saved;
   
   saved = Fgetdta();
   Fsetdta( thedta );
   return( saved );
}



/* Clear_All_Nodes();
 *==========================================================================
 * Delete ALL of the nodes in the XControl Linked List.
 * We go straight downt he chain deleting nodes along with the baseptr
 * if it is present.
 * This used for the  Shutdown XControl Routine and shouldn't be used at
 * any other time.
 * We also Free up the malloc'ed buffer for CPX's to load into.
 */
void
Clear_All_Nodes( void )
{
   CPXNODE *curptr;
   CPXNODE *ptr;
   
   ptr = curptr = hdptr;
   
   while( curptr )
   {
       ptr = curptr->next;
       delete_node( curptr );
       curptr = ptr;
   }
   hdptr = NULL;

   /* Ths will clear out the buffer malloc'ed to hold th CPX */
   /* DON'T need to worry abot baseptr, because it in order to
    * execute the SHUTDOWN, no CPXs are in memory at that time.
    */
   if( loadbuf )
   	 Mfree( loadbuf );
   baseptr = loadbuf = NULL;
}
