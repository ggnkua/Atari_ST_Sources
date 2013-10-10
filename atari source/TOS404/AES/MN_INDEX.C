/* MN_INDEX.C
 * ================================================================
 * DESCRIPTION: Index Submenu Routines
 *
 * 01/23/92 cjg - created from submenu.c
 * 01/23/92 cjg - created a dynamic structure for attaching submenus.
 * 01/27/92 cjg - temporary - using PID == 1
 *		- Added comments
 * 01/29/92 cjg - Started conversion over to Alcyon ( AES version )
 * 02/29/92 cjg - merged into AES
 * 04/01/92 cjg - Init Scroll field to FALSE
 * 05/11/92 cjg - Added mn_new() and mn_free() to handle the clearing
 *		  of submenu memory allocation.
 * 05/14/92 cjg - Pass in Process id's to appropriate functions
 * 05/29/92 cjg - Limit for indexs is now 64 MAximum.
 *		- Menu IDs range from 128 - 192
 * 6/4/92	- Fixed at getnewproc()
 */


/* INFORMATION 
 * ================================================================
 
   The structure for maintaining submenu assignments is described 
   as such:

   ----------
   |  head  |
   | pointer|--->[ Process #1 ] --->[ Process #2 ] ---> [ Process #N ]
   ----------          |
		       |
                       v
		   [ cluster ]
                       |
                       v
                   [ cluster ]
		       |
		       v

   The head ptr points to the linked list of process structures.
   Each process structure contains the process id, a pointer to the
   next process and a cluster.

   A cluster is a group of 8 index nodes ( submenu attachment structures ).
   The minimum index id is '1' and the maximum is '254'.
   Clusters are allocated dynamically when a group of 8 are used.
   Clusters will remain allocated until the process is ended. ( ugh ).
   The reason for this is that the coding is much, much easier than
   constantly shuffling around nodes.  At the very least, clusters
   will be allocated in groups of 8.

   Index ID's must remain in order from lowest to highest.

   The allocation of an index ID is done by searching through the
   cluster for a free node and seeing what the previous ID was.
   The ID of the new node is the previous ID plus 1.
 * ================================================================
 */


/* INCLUDE FILES
 * ================================================================
 */
#include <portab.h>
#include <machine.h>
#include <struct88.h>
#include <baspag88.h>
#include <obdefs.h>
#include <taddr.h>
#include <gemlib.h>
#include <osbind.h>
#include <mn_tools.h>


/* EXTERNS
 * ================================================================
 */
EXTERN	BYTE	*dos_alloc();

/* Must be declared here, or else redeclarations occur */
PNODE_PTR	FindProcess();
PNODE_PTR	GetNewProc();
INDEX_PTR	GetIndexPtr();


/* GLOBALS
 * ================================================================
 */
PNODE_PTR   IndexList;		/* Head ptr for process structures*/



/* FUNCTIONS
 * ================================================================
 */

/* FindIndex()
 * ================================================================
 * Find the Index ID this submenu is assigned to based upon
 * the current Process ID#, the OBJECT tree and the menu object.
 *
 * IN: WORD    id;    -  Process id
 *     OBJECT *itree  -  tree that we are looking for
 *     WORD    menu   -  menu object that we are looking for.
 *
 * OUT: WORD - SUCCESS - return the Index ID, if found
 *             FAILURE - return 0
 */
WORD
FindIndex( id, itree, imenu )
WORD    id;			/* Process id */
OBJECT 	*itree;			/* ptr to the tree that we are looking for */
WORD   	imenu;			/* the menu object that we are looking for */
{
   REG WORD  	 i;		/* Used as a counter */
   REG INDEX_PTR IndexPtr;	/* Pointer to the current Index structure  */
   REG CNODE_PTR CurPtr;	/* Pointer to the current Cluster structure*/
   PNODE_PTR 	 ProcPtr;	/* Pointer to the current Process structure*/

   if( ( ProcPtr = FindProcess( id )) == NULLPTR )  /* Look for the process node */
     return( 0 );

   if( !PCOUNT( ProcPtr ) )		/* No Nodes are active	     */
     return( 0 );			/* So, return...	     */


   CurPtr = &PCLUSTER( ProcPtr );	  /* Get pointer to 1st cluster    */ 
   while( CurPtr )
   {
      for( i = 0; i < CMAX; i++ )  /* Go through node 0 - 7 */
      {
        IndexPtr = &CTABLE( CurPtr )[i];  /* Get ptr to current index node*/
        if( INDEX_STATUS( IndexPtr ) )    /* Get status of this node      */
	{				  /* This node is active	  */
					  /* Check if this node has the   */
					  /* Same tree and menu object    */
                                          /* if so, RETURN the ID!	  */
	  if( ( itree == INDEX_TREE( IndexPtr ) ) &&
              ( imenu == INDEX_MENU( IndexPtr ) )
	    )
            return( INDEX_ID( IndexPtr ) );    
        }					  
      }
      CurPtr = CNEXT( CurPtr );	   	  /* Go to the next cluster,if any*/
   }
   return( 0 );  			  /* FAILURE!  */
}




/* Get_New_Index()
 * ================================================================
 * Gets a new index number ( 1-254 ) for this process so that it
 * can attach a submenu to a menu item.
 *
 * IN: WORD   id;    - Process id
 *     OBJECT *itree - The submenu tree to attach
 *     WORD   menu   - The menu object to attach
 *
 * OUT: WORD - SUCCESS - return an Index ID from ( 1 - 254 ).
 *             FAILURE - return 0 for an error or if there are no
 *                       more index id's available.
 */
WORD
Get_New_Index( id, itree, imenu )
WORD    id;			/* Process id			   */
OBJECT	*itree;			/* the submenu tree to attach      */
WORD	imenu;			/* the menu object to attach	   */
{
   OBJECT    	 *tree;		/* OBJECT tree ( for the defines   */
   REG INDEX_PTR IndexPtr;	/* Pointer to the Index structure  */
   REG PNODE_PTR ProcPtr;	/* Pointer to the process structure*/
   WORD      	 Index;		/* The available Index ID!         */

   if( (ProcPtr = FindProcess( id ))==NULLPTR )/* Look for the process node*/
   {
	if( (ProcPtr = GetNewProc( id ))==NULLPTR)	/* Create a new process node */
            return( 0 );		/* Return a 0 index ( error )*/
   }
   if( (Index = GetNewID( ProcPtr ))==NULL)   	/* Get an Index ID!          */
     return( 0 );				/* No more- sorry            */

   if( (IndexPtr = GetIndexPtr( ProcPtr, Index ))==NULLPTR )      /* Get the pntr         */
     return( 0 );

   ActiveTree( itree );				  /* fill the struct      */
   INDEX_TREE( IndexPtr )  = itree;		  /* put in the tree      */
   INDEX_MENU( IndexPtr )  = imenu;		  /* and the menu obj     */
   INDEX_OBJ( IndexPtr )   = ObHead( imenu );     /* Kludge the start obj.*/
   return( Index );    				  /* Return the index id  */
}



/*
 * ================================================================
 * PROCESS ROUTINES
 * ================================================================
 */


/* InitProcess()
 * ================================================================
 * Initialize a new process structure.
 * 
 * IN:  PNODE_PTR CurPtr - ptr to the process structure to init.
 *      WORD      pid    - Process ID to put into the struct.
 *
 * OUT: void
 */
VOID
InitProcess( CurPtr, id )
REG PNODE_PTR	CurPtr;		/* ptr to the process node    */
WORD		id;		/* process id for the node    */
{
   REG CNODE_PTR CPtr;		/* Ptr to cluster             */

   PID( CurPtr )    = id;	/* Install the new process id */
   PCOUNT( CurPtr ) = 0;	/* Clear the # of IDs used    */
   PNEXT( CurPtr )  = NULLPTR;	/* Clear ptr to next process  */

   CPtr = &PCLUSTER( CurPtr );	/* Get pointer to cluster     */
   InitCluster( CPtr );	        /* Initialize the cluster     */
}



/* FindProcess()
 * ================================================================
 * Given a process id, we look in the IndexList linked list for
 * that process. Return a pointer to that node if found, otherwise
 * return NULLPTR
 *
 * IN:  WORD id - Process ID to look for.
 * 
 * OUT: SUCCESS - return a pointer to the process structure.
 *      FAILURE - return NULLPTR.
 */
PNODE_PTR
FindProcess( id )
WORD	id;				     /* process id to look for       */
{
   REG PNODE_PTR CurPtr;		     /* Ptr to Current Process struct*/

   CurPtr = IndexList;			      /* Set it to the head */

   while( CurPtr && ( PID( CurPtr ) != id )) /* Go through till the end     */
      CurPtr = PNEXT( CurPtr );		      /* or, until we find the pid   */
  
   return( CurPtr );			      /* Return either NULLPTR or ptr*/
}



/* GetNewProc()
 * ================================================================
 * Given a pid, allocate a new Process structure and initialize it.
 * SUCCESS - return a pointer to this node.
 * FAILURE - return NULLPTR
 */
PNODE_PTR
GetNewProc( id )
WORD	id;				  /* process id to use      */
{
    REG PNODE_PTR CurPtr;		  /* Ptr to Current Process */
    REG PNODE_PTR NewPtr;		  /* Ptr to New Process     */

    /* Allocate memory for a new process structure */
    if( (NewPtr = ( PNODE_PTR )dos_alloc( (LONG)sizeof( PNODE ) )) > NULLPTR )
    {
       InitProcess( NewPtr, id );   

       if( !IndexList )			/* Attach to the head */
	  IndexList = NewPtr;
       else
       {				/* Attach to the end  */
          CurPtr = IndexList;
          while( PNEXT( CurPtr ) )
             CurPtr = PNEXT( CurPtr );
          PNEXT( CurPtr ) = NewPtr;
       }
    }
    return( NewPtr );
}



/* mn_new()
 * ================================================================
 * Clear up the memory used by the submenu attachments.
 * Regardless of their process ID, just clear them now.
 * We loop until the parent Index Node is NULL.
 */
VOID
mn_new( VOID )
{
    while( IndexList )
       mn_free( PID( IndexList ) );
}



/* mn_free()
 * ================================================================
 * Given the Process ID, free up the memory used by the process
 * and Cluster Structures.  Fix up the pointers in the linked list
 * if necessary.
 *
 * IN:  WORD id - the process id to free up.
 *
 * OUT: void
 */
VOID
mn_free( id )
WORD	id;					/* process id to free up */
{
    REG PNODE_PTR CurPtr;			/* ptr to current process*/
    REG PNODE_PTR PrevPtr;			/* ptr to previous proc  */

    if( IndexList )				/* Test the head list    */
    {
      if( (CurPtr = FindProcess( id ))>NULLPTR)/* Find the process!     */
      {						/* YES! found the process*/	
          if( CurPtr == IndexList )		/* Check if its the head */
          {					/* Its the first structure, so*/
              IndexList = PNEXT( CurPtr );	/* update the head poiner     */
          }
          else 
          {
              PrevPtr = IndexList;		/* Its not the first structure*/
	      while( PrevPtr && ( PNEXT( PrevPtr ) != CurPtr ))
		   PrevPtr = PNEXT( PrevPtr );
	      if( PrevPtr )			/* So look for the next struct*/
              {					/* and advance our pointers   */
                  PNEXT( PrevPtr ) = PNEXT( CurPtr );
              }
          }
          FreeClusters( CurPtr );	/* Free up clusters to this PID  */
	  dos_free( CurPtr );		/* Free up the Process structure */
      }
   }
}

/*
 * ================================================================
 * CLUSTER ROUTINES ( GNODES )
 * ================================================================
 */

/* InitCluster()
 * ================================================================
 * Initialize a new cluster
 *
 * IN: CNODE_PTR CurPtr - Pointer to current cluster
 * 
 * OUT: void
 */
VOID
InitCluster( CurPtr )
REG CNODE_PTR	CurPtr;		      /* ptr to the current cluster */
{
   REG WORD i;			      /* Counter		    */
   REG INDEX_PTR IndexPtr;	      /* Ptr to Index structure     */

   CNEXT( CurPtr ) = NULLPTR;	      /* Clear ptr to next cluster  */
   for( i = 0; i < CMAX; i++ ) /* Init each index node       */
   {
      IndexPtr = &CTABLE( CurPtr )[i];       /* Get index node pointer */
      if( IndexPtr )			     /* make sure we have one  */
      {					     /* and update the vars    */
        INDEX_STATUS( IndexPtr )   = FALSE;  /* FALSE - unused         */
        INDEX_ID( IndexPtr )       = 0;	     /* Clear the rest of the  */
        INDEX_TREE( IndexPtr )     = NULLPTR;/* variables...           */
        INDEX_MENU( IndexPtr )     = NIL;
        INDEX_OBJ( IndexPtr )      = NIL;
	INDEX_FLAGSCROLL(IndexPtr) = FALSE;
        INDEX_COUNT( IndexPtr )    = 0;      	     	  
      }
   }
}



/* GetNewCluster()
 * ================================================================
 * Allocates memory for a new CNODE and returns a pointer to it.
 * returns NULLPTR if FAILURE.
 */
CNODE_PTR
GetNewCluster( VOID )
{
    REG CNODE_PTR NewPtr;		/* Ptr to the new cluster*/

    if( ( NewPtr = ( CNODE_PTR )dos_alloc( ( LONG )sizeof( CNODE ) )) > NULLPTR )
       InitCluster( NewPtr );
    return( NewPtr );
}


/* FreeCluster()
 * ================================================================
 * This routine will free ALL of the clusters of a process and
 * return the memory to the heap.
 * It will free the clusters in reverse order ( last malloc'ed,
 * first freed ). Note that the first cluster cannot be freed since
 * it is a part of the Process structure.
 * The Node Count ( PCOUNT ) in the process structure should be
 * updated by the FreeProcess() and DeleteIndex().
 *
 * IN:  PNODE_PTR ProcPtr - Pointer to the process structure of which
 *			    its clusters should be free'd up.
 *
 * OUT: void
 */
VOID
FreeClusters( ProcPtr )
PNODE_PTR	ProcPtr;		/* ptr to the process node           */
{
    REG CNODE_PTR CurPtr;		/* Pointer to current Cluster        */
    REG CNODE_PTR PrevPtr;		/* Pointer to Previous Cluster       */
    REG CNODE_PTR BasePtr;		/* Pointer to the base cluster       */
					/* Which is the un-freeable cluster  */
					/* contained in the process structure*/
    BasePtr  = &PCLUSTER( ProcPtr );	/* Get the ptr to the 1st cluster    */
    while( CNEXT( BasePtr ) )	 	/* Clear until the Base ptr pts NULL */
    {
       PrevPtr = BasePtr;		/* Set the previous pointer          */
       CurPtr  = CNEXT( BasePtr );	/* Get the structure after the base  */
       while( CNEXT( CurPtr ) )		/* Traverse to the last node         */
       {
         PrevPtr = CurPtr;		/* so that we can free up the last   */
         CurPtr  = CNEXT( CurPtr );	/* cluster in use.                   */
       }
       CNEXT( PrevPtr ) = NULLPTR;	/* Clear pointer pting to this node  */
       dos_free( CurPtr );		/* And delete it.                    */
    }

    /* Now, need to zero out the 8 nodes in the process structure */
    InitCluster( BasePtr );
}


/*
 * ================================================================
 * INDEX ROUTINES
 * ================================================================
 */

/* GetNewID()
 * ================================================================
 * Given a process id ptr, find a new available id in the cluster.
 * If the cluster is full, allocate another cluster.
 * If the Index ID number is > 254, return 0
 *
 * INITIALLY -
 * We look for an empty spot by looking in each cluster.
 * The new id number is the last number found + 1.
 * 
 * SUCCESS - return the id number.
 * FAILURE - return 0
 */
WORD
GetNewID( ProcPtr )
PNODE_PTR	ProcPtr;	/* ptr to the process node  */
{
   REG CNODE_PTR CurPtr;	/* ptr to Current Cluster   */
   CNODE_PTR PrevPtr;		/* ptr to previous Cluster  */
   WORD      CurID;		/* Current ID		    */
   WORD      i;			/* Counter...		    */
   REG INDEX_PTR IndexPtr;	/* ptr to current Index node*/

   CurID = MIN_INDEX - 1;	

   /* Check if we're past the limit */
   if( PCOUNT( ProcPtr ) < ( MAX_INDEX - MIN_INDEX ) )
   {
      CurPtr  = &PCLUSTER( ProcPtr );	/* Get pointer to 1st cluster    */ 
      while( CurPtr )
      {
        for( i = 0; i < CMAX; i++ )
        {
          IndexPtr = &CTABLE( CurPtr )[i];   /* Get ptr to current index node*/
          if( IndexPtr )
          {
            if( INDEX_STATUS( IndexPtr ) )     /* Get status of this node      */
	      CurID = INDEX_ID( IndexPtr );    /* ACTIVE! - Get the Index ID!  */
	    else
            {				       /* INACTIVE!		      */
	      INDEX_STATUS( IndexPtr ) = TRUE; /* Make this node ACTIVE!      */
              INDEX_COUNT( IndexPtr )  = 0;    /* Set count to ZERO           */
 					       /* mn_setmn() increments count */
	      INDEX_ID( IndexPtr )     = CurID + 1; /* Set ID to CurID + 1    */
	      PCOUNT( ProcPtr )       += 1;    /* Increment Count...          */
	      return( CurID + 1 );
            }
          }
        }
        PrevPtr = CurPtr;
        CurPtr  = CNEXT( CurPtr );
        
        if( !CurPtr )
        {
           /* If we got this far, then we ran out of room in the cluster
            * and need to allocate a new cluster.
            */
            if( ( CurPtr = GetNewCluster()) == NULLPTR ) /* error */
		return( 0 );
            CNEXT( PrevPtr ) = CurPtr;  /* Attach the cluster onto the end*/
            PrevPtr = CurPtr;		/* and reset the previous ptr.    */
        }
      }
   }
   return( 0 );
}



/* GetIndexPtr()
 * ================================================================
 * Return an Index Ptr to the index node for this index id.
 * Go through the Index Clusters with this process ptr.
 * If the index isn't found, return NULLPTR.
 *
 * IN: PNODE_PTR ProcPtr - Ptr to the process structure.
 *     WORD      index   - The Index ID that we are looking for
 *
 * OUT: INDEX_PTR - SUCCESS - found it! return the pointer to it.
 *                - FAILURE - return NULLPTR.
 */
INDEX_PTR
GetIndexPtr( ProcPtr, index )
PNODE_PTR	ProcPtr;		/* ptr to the process node  */
WORD		index;			/* Index ID to look for     */
{
     REG CNODE_PTR CurPtr;		/* Ptr to current Cluster   */
     REG INDEX_PTR IndexPtr;		/* Ptr to the Index         */
     REG WORD      i;			/* Used as a counter        */

     if( !PCOUNT( ProcPtr ) )		/* If no active nodes, exit */
       return( ( INDEX_PTR )NULLPTR );  /* So return NULLPTR        */

     CurPtr  = &PCLUSTER( ProcPtr );	/* Get pointer to 1st cluster*/ 
     while( CurPtr )
     {
        for( i = 0; i < CMAX; i++ )  /* Go through node 0 - 7 */
        {
          IndexPtr = &CTABLE( CurPtr )[i];  /* Get ptr to current index node*/
          if( INDEX_STATUS( IndexPtr ) )    /* Get status of this node      */
	  {				    /* This node is active	    */
	    if( index == INDEX_ID( IndexPtr ) )   /* Check if its the same  */
	      return( IndexPtr );		  /* index id number        */
          }					  /* if so, RETURN!         */
        }
        CurPtr  = CNEXT( CurPtr );	    /* Go to the next cluster,if any*/
     }
     return( ( INDEX_PTR )NULLPTR );  
}




/* DeleteIndex()
 * ================================================================
 * Deletes a submenu index based upon a ptr to the process structure.
 * if flag is FALSE, delete based upon the IndexCount usage.
 * only if it gets to zero do we delete the whole node.
 * if flag is TRUE, delete the whole node regardless of attachments.
 *
 * Delete Index does NOT free up a cluster, at best, it will simply
 * mark the node as INACTIVE.
 *
 * IN: PNODE_PTR ProcPtr - Pointer to the process structure
 *     WORD      index   - Index ID to delete
 *     BOOLEAN   flag    - FALSE - Decrement the count first, if zero
 * 			           then delete the structure.
 *			 - TRUE  - Disregard the count and immediately
 *				   delete the structure.
 *
 * OUT: void
 */
VOID
DeleteIndex( ProcPtr, index, flag )
PNODE_PTR	ProcPtr;			/* ptr to process node     */
WORD		index;				/* Index ID to delete      */
BOOLEAN		flag;				/* See above description...*/
{
    REG INDEX_PTR IndexPtr;			/* Ptr to Index structure  */

    if( ProcPtr )				/* Make sure its valid     */
    {
       if( (IndexPtr = GetIndexPtr( ProcPtr, index ))>NULLPTR)/* Get ptr to Index struct */
       {
           if( !flag )				/* FALSE! - decrement first*/
           {
	     INDEX_COUNT( IndexPtr ) -= 1;         /* Decrement counter    */
	     if( !INDEX_COUNT( IndexPtr ) )	   /* ANd check it!        */
	     {
                INDEX_STATUS( IndexPtr ) = FALSE;  /* Its ZERO! delete the */
	        PCOUNT( ProcPtr ) -= 1;		   /* Structure!           */
             }					   /* Update proc id of the*/
           }					   /* # of active nodes    */
           else
           {				           /* Flag set to TRUE!    */
             INDEX_COUNT( IndexPtr ) = 1;          /* REset index count    */
             INDEX_STATUS( IndexPtr ) = FALSE;	   /* Clear the status flag*/
	     PCOUNT( ProcPtr ) -= 1;		   /* Update the proc id of*/
           }					   /* the # of active nodes*/
       }    
    }
}
