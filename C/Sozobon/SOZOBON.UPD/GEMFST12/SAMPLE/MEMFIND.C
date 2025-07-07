
/**************************************************************************
 *
 * MEMFIND.C - An example program for AESFAST which uses just dialogs.
 *
 *  Public Domain example program by Ian Lepore.
 *
 *  This is distributed as an example of how to write a simple program using
 *  my AESFAST public domain GEM bindings.  This example uses a few of
 *  the nifty utilities from AESFAST, but it's pretty much straightforward
 *  dialog-handling code.
 *
 *  This beast may be marginally useful beyond its value as an example.
 *  It will find and report on the 5 biggest blocks of free memory in 
 *  the system, giving a somewhat more acurate view than programs which
 *  report only the largest free block.
 *
 *  This code is pretty heavily commented.  Please excuse me if some of 
 *  the comments seem obvious, but I figure the audience for this will 
 *  include both beginning C programmers, and old-timers who just need to
 *  see how my bindings work as opposed to other bindings.
 *
 *************************************************************************/

#include <gemfast.h>
#include <osbind.h>
#include "memfind.h"

#ifndef TRUE
#define TRUE  1
#define FALSE 0
#endif

#define NO_RSRC   -2783        /* a random number */

/**************************************************************************
 *
 * global vars
 *
 *************************************************************************/

typedef struct {
        char *pmem;
        long lmem;
        int  objlink;
        char displaystr[25];
        } MEM_BLOCK;

#define NUM_BLOCKS 5

MEM_BLOCK mem_ctl[NUM_BLOCKS];

OBJECT    *maintree;

char map_template[] = "$%06lx    %4dk";    /* template for printf() */

char no_rsrc_alert[] = "[3][ | Can't open/load RSC file! | ][ Fatal ]";

/**************************************************************************
 *
 * prg_exit - Cleanup and terminate.
 *  If the exit code is our magic number NO_RSRC (indicating that we're
 *  exiting because the resource load failed), we skip the rsrc_free call.
 *
 *************************************************************************/

void
prg_exit(code)
        int code;
{
        if (code != NO_RSRC) {
                rsrc_free();
        }

        appl_exit();
        Pterm(code);
}

/**************************************************************************
 *
 * prg_init.
 *
 *  This routine does mundance AES init stuff, and makes the connections
 *  between the string objects in the resource tree and the elements in
 *  our memory control array.
 *
 *  The connections concept is based upon accessing arrays of strings in
 *  a dialog box without knowing the actual object indicies (names) of
 *  the string objects.  (Some discussion of this can also be found in 
 *  the MINICOLR accessory example code).  I'll be the first to admit
 *  that this technique is overkill for this little program, since only
 *  five text strings are involved.  On the other hand, you can increase
 *  the number of displayed memory fragments simply by going into the 
 *  resource file and making a few more copies of the display strings, 
 *  then coming into this source code and increasing NUM_BLOCKS to match
 *  the new number of display strings in the resource file.  No other 
 *  changes are necessary, and *that's* something you can't say about
 *  'normal' GEM coding techniques.
 *
 *   What this technique really does is isolate the location of the objects
 *   in the RSC file from the program code.  Thus, a hacker-type can munge
 *   up the resource file and the program will still run correctly, even
 *   if objects are added, deleted, moved, or sorted.
 *
 *   In this implementation, I've set an 'extended object type' on each
 *   of the display string objects, using my resource editor.  I chose
 *   a value of '1' for the extended type, but this is completely 
 *   arbitrary.
 *
 *   Just for grins, I'll list here the code I would have used if I hadn't
 *   implemented the location-independant connections concept.  First, I'll
 *   explain my standard for naming objects...
 *       nnnnttxx
 *       ||||||++--- 2 char arbitrary id (my object name)
 *       ||||++----- object type (see list below)
 *       ++++------- name of the tree holding the object
 *     Object types for naming standards are:
 *        BX  - Button (eXit)
 *        BR  - Button (Radio) (also used for radio boxchars)
 *        ST  - STring
 *        TX  - TeXt (display only)
 *        TE  - Text (Editable)
 *        PB  - Parent Box (usually invisible, parent for radio buttons)
 *        TREE- Special-case name, indicates a root (R_TREE) objct.
 *     Thus, using this standard, you might have:
 *        MAINBXOK - Exit button 'OK' in main dialog box.
 *        DEVSBRDA - Radio Button for drive A in device selection dialog.
 *        MAINSTM1 - Display string M1 in main dialog.
 *
 *   Anyway, enough standards.  You don't have to use my standard, but
 *   I'd advise you to use *some* kind of naming standard that ties object
 *   names to the trees they live in, if you want to maintain your sanity.
 *
 *   So, IF I had done this program in the 'normal' way, the loop below
 *   which does the 'connections' works would be replaced by the following:
 *
 *      rsc_sstrings(maintree,
 *                      MAINSTM1,mem_ctl[0].displaystr,
 *                      MAINSTM2,mem_ctl[1].displaystr,
 *                      MAINSTM3,mem_ctl[2].displaystr,
 *                      MAINSTM4,mem_ctl[3].displaystr,
 *                      MAINSTM5,mem_ctl[4].displaystr,
 *                      -1);
 *
 *   The rsc_sstrings routine is an AESFAST library routine that sets the
 *   ob_spec pointers for 1-n strings within a dialog tree.
 *************************************************************************/

void
prg_init()
{
        int                dmy;
        register int       objcounter;
        register int       strcounter;
        register OBJECT    *ptree;
        register MEM_BLOCK *pblock;
        
/*
 * call AES init, then try to load the resource file.  if the RSC load
 * fails, go whine at the user and exit.
 */

        appl_init();
        
        if (!rsrc_load("MEMFIND.RSC")) {
                form_alert(no_rsrc_alert);
                prg_exit(NO_RSRC);
        }

/*
 * get the address of the dialog tree and center the d-box.
 */
     
        rsrc_gaddr(R_TREE, MAINTREE, &maintree);
        form_center(maintree, &dmy, &dmy, &dmy, &dmy);
   
/*
 * connect up the links between the memory control structures and the
 * object structures... (see notes above).
 *
 * go through the object tree, and each time we encounter an object
 * with the right extended object type, connect that object's ob_spec
 * pointer to the display string in the memory control structure, and
 * make note of the object's index in the objlink field of the memory
 * control structure.  normally, only the ob_spec link would be made,
 * but for our application we need to be able to set an object's flags
 * to HIDETREE if we discover an empty block in the memory control struct.
 *
 * the loop control here will stop if we run out of memory control blocks
 * or if we run out of objects in the tree.  this means that if someone
 * munges up the resource file and removes some of our string objects,
 * then some memory blocks won't be displayed, but at least nothing dies.
 */     
        objcounter = strcounter = 0;
        do      {
                ptree = &maintree[objcounter];
                if (1 == (ptree->ob_type >> 8)) {
                        pblock = &mem_ctl[strcounter];
                        ptree->ob_spec  = (long)pblock->displaystr;
                        pblock->objlink = objcounter;
                        strcounter++;
                }
                objcounter++;
        } while ( (strcounter < NUM_BLOCKS) &&
                  (!(ptree->ob_flags & LASTOB)) );

/* 
 * init all done, change the mouse from a busy-bee to an arrow.
 */
        graf_mouse(ARROW, 0L);
}

/**************************************************************************
 *
 * dial_do - Generic dialog handler.
 *
 *  This routine handles dialog interaction for any dialog box.  If the
 *  d-box has editable text objects, pass this routine the object index
 *  of the first text object to edit.  If there are no edit objects, just
 *  pass a zero.  This routine assumes that a form_center call has already
 *  been done (I always do the center calls during init processing, since
 *  it makes no sense to center the same dialog box multiple times if the
 *  dialog is invoked multiple times).  This routine does NOT do the 
 *  annoying graphics calls (FMD_GROW and FMD_SHRINK).  You can put them
 *  in if you have the patience to watch little lines zoom around on the
 *  screen.
 *
 *  Since form_center is the usual source of info on the dialog box's 
 *  clipping rectangle, and we don't do a form_center, we call the AESFAST
 *  utility routine 'objcl_calc()' to calculate a clipping rectangle for
 *  the dialog box tree.  This is faster than the form_center call anyway.
 *
 *  Another library routine, 'objst_change' is used to de-select the exit
 *  object.  The object is not changed visually on the screen (it looks
 *  ugly if you do it that way), but will display as non-selected the next
 *  time the dialog box is displayed.  It should be noted that it is 
 *  probably faster to de-select the object with a line of code like:
 *    tree[exitobj].ob_state &= ~SELECTED;
 *  but I think the function call is more readable.
 *
 *  This routine returns the index of the object used to exit the dialog.
 *************************************************************************/

int
dial_do(tree, startedit)
        register OBJECT *tree;
        int             startedit;
{
        int   exitobj;
        GRECT cliprect; 
       
        objcl_calc(maintree, R_TREE, &cliprect, 0L);
        
        form_dial(FMD_START, 0,0,0,0, cliprect);

        objc_draw(tree, R_TREE, MAX_DEPTH, cliprect);

        exitobj = form_do(tree, startedit);

        objst_change(tree, exitobj, ~SELECTED, FALSE);

        form_dial(FMD_FINISH, 0,0,0,0, cliprect);
        
        return exitobj;
}

/**************************************************************************
 *
 * main routine - Call init routine, map out the memory blocks, display
 *  the map, then call the exit routine.
 *
 *************************************************************************/

main()
{
        register int       counter;
        register int       kbytes;
        register MEM_BLOCK *pblock;

/*
 * go do GEM initialization...
 */
 
        prg_init();

/*
 * find the biggest memory blocks available in the system.  for each
 * loop iteration, ask TOS what the biggest available memory block is.
 * if TOS returns a zero, we've found all available fragments already,
 * so set the corresponding object's flags to HIDETREE so it won't 
 * display anything.  (if the objlink field in the memory control struct
 * points to object 0 (R_TREE), we don't set the HIDE flag, because the
 * whole dialog box would be hidden.  this is only to handle the case
 * where we ran out of strings in the object tree before we ran out of
 * memory control blocks when we were setting the links in the init 
 * routine. any links that didn't get set would be 0.)
 *
 * when a block of memory is found, allocate it, and save its pointer so
 * we can free it later.  format the display string to contain the memory
 * block's address and size, then continue with the next loop iteration. 
 */
 
        for (counter = 0; counter < NUM_BLOCKS; counter++) {
        
                pblock = &mem_ctl[counter];
                pblock->lmem = Malloc(-1L);

                if (pblock->lmem > 0L) {
                        kbytes = (int)(pblock->lmem / 1024);
                        
                        if (kbytes == 0)        /* fake a small block   */
                                kbytes = 1;     /* into looking like 1k */

                        pblock->pmem = (char *)Malloc(pblock->lmem);

                        sprintf(pblock->displaystr, map_template, 
                                  pblock->pmem, kbytes );
                } 
                else { /* memory-block size == 0 */
                        if (pblock->objlink != R_TREE) {
                                objfl_change(maintree, pblock->objlink, 
                                                HIDETREE, FALSE);
                        }
                }
        }

/* 
 * we've built and formatted the memory map, so now we can free all
 * the blocks we allocated.
 */
 
        for (counter = 0; counter < NUM_BLOCKS; counter++) {
                Mfree(mem_ctl[counter].pmem);
        }

/*
 * now display the results of the mapping, and exit.
 */
 
        dial_do(maintree,0);
        
        prg_exit(0);
}

