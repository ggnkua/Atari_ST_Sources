/***********************************************************************/
/*                                                                     */
/*                                                                     */
/***********************************************************************/
/*                           INCLUDE FILES                             */
/***********************************************************************/

#include <portab.h>                             /* portable coding conv */
#include <machine.h>                            /* machine depndnt conv */
#include <obdefs.h>                             /* object definitions   */
#include <treeaddr.h>                           /* tree address macros  */
#include <gembind.h>                            /* gem binding structs  */
#include <tosdefs.h>
#include <osbind.h>
#include "backup.h"

/***********************************************************************/
/*                            DEFINES                                  */
/***********************************************************************/

#define FILENM	"TIMESTMP.HD"		/* Timestamp File ID	*/

#define window_kind (NAME|CLOSER)

#define SFILE_ATTR 0x07		/* Look for files */
#define SFILE_DIR  0x10		/* Directory File attribute    */

#define ARROW           0
#define HOUR_GLASS      2

#define END_UPDATE      0
#define BEG_UPDATE      1

/***********************************************************************/
/*                        GLOBAL VARIABLES                             */
/***********************************************************************/

/* Disk Transfer Address (DTA) structure */
struct disk_buf
   {
   char system[21];     /* first 21 bytes reserved for system	*/
   char attr;           /* file attribute */
   int  ftime;          /* file time stamp */
   int  fdate;          /* file date stamp */
   long fsize;          /* file size in bytes */
   char fname[14];      /* file name and extension */
   };

struct disk_buf dtabuf; /* Dta buffer 				*/
struct disk_buf dta1buf;/* Dta buffer 1				*/
struct disk_buf *dta; 	/* pointer 'dta' will point to structure */
struct disk_buf *dta1; 	/* pointer 'dta' will point to structure */

long sysdta;	/* Save System DTA address	*/

int wi_handle, ap_id, phys_handle, ph, intin[128],work_in[11],h,w,hh,ww;
int contrl[12],ptsin[128],intout[128],ptsout[128],work_out[60];
int xdesk, ydesk, wdesk, hdesk, dum, clip[4];
long tree;
int mausx, mausy, dummy;
int xwork, ywork, wwork, hwork;

int type_update = FILE;	/* Type of update entered; time, timestamp, or All */
int  autowrite = TRUE;	/* FALSE = query for file overwrite	*/
char src[]  = "C:";	/* Source Drive				*/
char dest[] = "A:";	/* Destination Drive			*/
int  isrc  = 3;		/* Source drive use A 			*/
int  idest = 1;		/* Destination Drive use 'M'		*/

OBJECT *obj;		/* OBJECT Structure - map into resource file	*/
TEDINFO *ted;		/* TED Structure - map into resource file	*/

int res;		/* Screen Res				*/
int date_backup[2];	/* Hold backup file date/time		*/
char dir[255];		/* Hold Directory search path		*/
char dta_sav[255];	/* recursive save 1st 21 bytes of dta between calls */
char *icp, *ocp;	/* Temp pointers global because of recursive call */
int cnt;		/*   "     "        "      "    "      "       "  */
 
long  dsk_blk[4];	/* Free Alloc Units|Total|Bytes/Sect|Phys Sect/Alloc */
/***********************************************************************/
/*                            ALERT BOXES                              */
/***********************************************************************/

char alert1[] = "[1][XXXXXXXXXXXXXXXXXXXX| TED String Found!][Cont]";
char alert4[] = "[1][XXXXXXXX.XXX found|To be Backed UP!][Cont]";
char alert5[] = "[1][XXXXXXXX.XXX found|Processing Directory!][Cont]";
char alert6[] = "[1][XXXXXXXXXXXXXXXXXXXX|Processing Directory!|(find_file)][Cont]";
char alert8[] = "[3][XXXXXXXXXXXXXXXXXXXX|Error Opening|Input file!][Cont]";
char alert9[] = "[3][XXXXXXXXXXXXXXXXXXXX|Error Opening|Output File!][Cont]";
char alerta[] = "[3][XXXXXXXXXXXXXXXXXXXX|  Bad Create | Directory! ][Cont]";
char alertb[] = "[1][XXXXXXXXXXXXXXXXXXXX|  Making | Directory! ][Cont]";
char alertc[] = "[3][XXXXXXXXXXXXXXXXXXXX|  Bad | Change Drive! ][Cont]";
char alertd[] = "[3][XXXXXXXXXXXXXXXXXXXX| On Destination Drive | Overwrite File? ][ YES | NO ]";
char alertf[] = "[3][XXXXXXXXXXXXXXXXXXXX| Not All of File | Copied! ][Cont]";
char alertg[] = "[3][XXXXXXXXXXXXXXXXXXXX| File Write Error! ][Cont]";
char alerth[] = "[1][XXXXXXXXXXXXXXXXXXXX| Checking for | Directory! ][Cont]";
char alertj[] = "[3][ Problem | Creating | OR | Deleting | TIMESTMP.HD! ][Cont ]";
char alertx[] = "[3][XXXXXXXXXXXXXXXXXXXX| Exists as file. Cannot | Create Directory. | Please Insert | Another Diskette! ][Cont]";

/***********************************************************************/
/***********************************************************************/
/*                                                                     */
/*                          PROGRAM CONTROL                            */
/*                                                                     */
/***********************************************************************/
/***********************************************************************/
main()
{
WORD    term_type;

if ( !(term_type = pgm_init()) )
    if ( ask_scn() == 0 )
        if ( get_parms() == 0 ) {
            if ( type_update == DATE ) {
		if ( opt_date() == 0 )
		    file_backup();
		}
	    else
	        file_backup();	 
	    }
pgm_term(term_type);
}

file_backup()	/* Main Processing - find, check, and backup files */
{
	
int ret;

dta  = &dtabuf;         /* pointer 'dta' will point to structure */
dta1 = &dta1buf;        /* 		X			 */
Fsetdta(dta);		/* Set DTA buffer			*/
strcpy(dir, src);
do_dir(dta_sav);       	/*start the backup */
if ( (ret = form_alert(1, "[2][ Backup Completed | Create / Update | TIMESTMP.HD? ][ YES | NO ]")) == 1 )
    updat_ts();		/* Update timestamp file	*/        

}
		 
do_dir(dtasv)
char *dtasv;		/* Start of dta save area (1st 21 bytes)	*/

/***************************************************************************

        Find Files That needs to be backed up
        
****************************************************************************/

{
int  status;	
long dirlen;		/* Length of path up to this point (+1)	*/

dirlen = strlen(dir) + 1;	/* Save length of pathname to this point */
strcat(dir, "\\*.*");   /* Start with 1st file		*/
//cpynchar(alert6 + 4L, dir, 20);
//form_alert(1,alert6);

status = Fsfirst(dir, SFILE_ATTR); 
while ( status == E_OK ) {	/* Do for all files first	*/
    if ( cmp_datime(&dta->ftime) ) {
//        cpynchar(alert4 + 4L, dta->fname, 12);	
//        form_alert(1,alert4);
        LBCOPY(dta1, dta, 44);
        do {	/* Until Space & all required subdirectories are present */
            check_dest();
            status = make_dir(dirlen); /* Make any needed dirs */
            }
        while ( status != 0 );
        LBCOPY(&dta->attr, &dta1->attr, 23);
        backup_file(dirlen);
        LBCOPY(dta, dta1, 21);
        }
    status = Fsnext();    
    }    

strcpy(dir + dirlen, "*.*");   /* Start with 1st Directory		*/
//cpynchar(alert6 + 4L, dir, 20);
//form_alert(1,alert6);
    	
status = Fsfirst(dir, SFILE_DIR); /* Start processing any Sub-Directories */
while ( status == E_OK ) {
    if ( dta->attr ==  (char)SFILE_DIR            &&
         strncmp(dta->fname, ". ", 2)  != 0       &&
         strncmp(dta->fname, ".. ", 3) != 0 ) {
//        cpynchar(alert5 + 4L, dta->fname, 12); 	
//        form_alert(1,alert5);
        strcpy(dir + dirlen, dta->fname);
        LBCOPY(dtasv, dta->system, 21);
        do_dir(dtasv + 21);		/* Recursive call for next dir */
        LBCOPY(dta->system, dtasv, 21);
        }
    status = Fsnext();        
    }

}

int make_dir(dirlen)
long dirlen;     /* Length of Path up to this point	*/
/***************************************************************************

	Make any directories on target (if space exists for file)
	
***************************************************************************/
{

char  *ip, *ip1;	/* Temp char pointers	*/
int   ret;		/* System Return code	*/
int   retcd = 0;	/* Set return code to good 	*/

dir[0] = dest[0];	/* Correct filename to destination drive	*/

for ( ip = dir + dirlen - 1L; *ip != '\\'; ip-- ) /* Get to last \	*/
    ;
if ( ip > dir + 2L ) {	/* See if subdirectories	*/    
    ip1 = dir + 3L;
    while ( 1 ) { 	/* Do for every subdirectory	*/
	for ( ; *ip1 != '\\'; ip1++ ) /* Get to end of 1st dir */
            ;
        *ip1 = NULL;
//        cpynchar(alerth + 4L, dir, 20);
//        form_alert(1, alerth);
        if ( (ret = Fsfirst(dir, 0x1f)) != 0 ) {
//            cpynchar(alertb + 4L, dir, 20);
//            form_alert(1, alertb);
	    if ( (retcd = Dcreate(dir)) != 0 ) {
    	        cpynchar(alerta + 4L, dir, 20); 	
                form_alert(1, alerta);
                break;
        	}
            }
        else
            if ( dta->attr != (char)SFILE_DIR ) {
                cpynchar(alertx +4L, dir, 20);
                form_alert(1,alertx);
                retcd = 1;
                break;
                }    	
    	*(ip1++) = '\\';            
        if ( ip1 > ip )
    	    break;
	}        
    }    

dir[0] = dest[0];	/* Correct filename to destination drive	*/
return(retcd);

}

check_dest()	
/***************************************************************************

  		Check Destination For enought Space for File to Copy
  		
***************************************************************************/
{  	
			/* Disk Block	*/
long  alloc_req;	/* Number of allocation units required for curr file */

while ( 1 ) {
    Dfree(&dsk_blk, idest);	/* Get Free space from Destination Drive */
    alloc_req =  ( dta1->fsize + (dsk_blk[2] * dsk_blk[3] - 1) )
               / (dsk_blk[2] * dsk_blk[3]);
    if ( alloc_req <= dsk_blk[0] )
        break;
    form_alert(1,
             "[3][Not Enought Space on| Destination. Change Disk!][ OK ]");
    }
}
	
backup_file(dirlen)
long dirlen;	/* Length of Path up to this point		*/

/***************************************************************************

	Backup File that has been selected
	
***************************************************************************/
{
int ret, handle;
long ret2, sbyte;
char *ptr;

strcpy(dir + dirlen, dta->fname);	/* Append file to path	*/
    
dir[0] = dest[0];	/* Set drive to Destination	*/          	
sbyte = dta->fsize;

if ((ret = Fsfirst(dir, 0x00)) == 0) {
    cpynchar(alertd + 4L, dir, 20);	
    if ( autowrite == TRUE      ||
         (ret =form_alert(1, alertd)) == 1 ) {
    	if ( (ret2 = Fdelete(dir)) != 0 ) {
            cpynchar(alert9 + 4L, dir, 20); 	 
            form_alert(1, alert9);        
            dir[0] = src[0];
            return;
    	    }    	
        }    
    else {	
        dir[0] = src[0];
        return;
	}
    }	

if ((ptr = Malloc(sbyte)) == 0)
    form_alert(1, "[3][ Can't Allocate | Memory! ][Cont]");
else {
    dir[0] = src[0];	/* Set drive to source	*/          	
    if ((handle = Fopen(dir, 0x00)) < 0) {
        cpynchar(alert8 + 4L, dir, 20); 	 
        form_alert(1, alert8);
        }
    else {
        if ((ret2 = Fread(handle, sbyte, ptr)) != sbyte) {
            cpynchar(alertf + 4L, dir, 20);	
            form_alert(1, alertf);
            }
        Fclose(handle);
        dir[0] = dest[0];	/* Set drive to Destination	*/          	
        if ((handle = Fcreate(dir, 0x00)) < 0) {
            cpynchar(alert9 + 4L, dir, 20); 	 
            form_alert(1, alert9);        
            }
        else {
            if ((ret2 = Fwrite(handle, ret2, ptr)) < 0) {
            	cpynchar(alertg + 4L, dir, 20);
                form_alert(1, alertg);
                }
            Fclose(handle);
            }
        Mfree(ptr);
        }
    }    

dir[0] = src[0];	/* Set drive back to Source	*/           

return;

}	

int cmp_datime(dt)
int  *dt;

/*****************************************************************************

        Compare file time/date with backup date/time
        
       Return: TRUE (File needs to be backed up)
               FALSE (File date earlier than backup date (no need to backup)
	
*****************************************************************************/

{

if ( type_update == ALL         ||
     date_backup[1] < dt[1]     ||
     ( date_backup[1] == dt[1]  &&  date_backup[0] <= dt[0] ) )
    return(TRUE);
else
    return(FALSE);

}	

updat_ts()

/*****************************************************************************

	Update (delete, and create) or create timestamp file

******************************************************************************/

{
int	handle;		/* File Descriptor	*/
char	filenm[14];
int	ret;

strcpy(filenm, src);
strcat(filenm, "\\");
strcat(filenm, FILENM);

if ( (ret = Fsfirst(filenm, 0x1f)) == E_OK )
    if ( (ret = Fdelete(filenm)) != 0 ) {
        form_alert(1, alertj);
        return;
        }

if ((handle = Fcreate(filenm, 0x00)) < 0)
    form_alert(1, alertj);        
else    
    Fclose(handle);
}

/***********************************************************************/
/***********************************************************************/
/*                                                                     */
/*                       SCREEN  DISPLAYS                              */
/*                                                                     */
/***********************************************************************/
/***********************************************************************/

/*------------------------------*/
/*      pgm_init                */
/*------------------------------*/
WORD pgm_init()
{
static char winame[] = "    ******    Hard Disk Backup    ******    ";
WORD    work_in[11];
WORD    i;

ap_id = appl_init();			/* Initialize Libraries	*/
if ( ap_id == -1 )
    return(4);
wind_update(BEG_UPDATE);
graf_mouse(HOUR_GLASS, 0x0L);
if ( !rsrc_load( ADDR("BACKUP.RSC") ) ) {
    graf_mouse(ARROW, 0x0L);
    form_alert(ADDR("[3][Fatal Error !|BACKUP.RSC|File Not Found][ Abort ]"));
    return(1);
    }

/* open virtual workstation */
/* allocate undo buffer */
for ( i = 0; i < 10; i++ )
    work_in[i] = 1;
work_in[10] = 2;
work_in[0] = ap_id;
ph = graf_handle(&h,&w,&hh,&ww);
v_opnvwk(work_in, &ph, work_out);
if ( ph == 0 )
    return(1);

wind_get(0,WF_WXYWH,&xdesk,&ydesk,&wdesk,&hdesk);
wi_handle = wind_create(window_kind,xdesk,ydesk,wdesk,hdesk);
if ( wi_handle == -1 ) {
    form_alert(1, "[3][Bad Window Create!!][ABORT]");
    return(3);
    }
wind_set(wi_handle,WF_NAME,winame,0,0);
wind_open(wi_handle,xdesk,ydesk,wdesk,hdesk);
clip[0] = xdesk;
clip[1] = ydesk;
clip[2] = wdesk;
clip[3] = hdesk;

return(0);
}

/*------------------------------*/
/*      pgm_term                */
/*------------------------------*/
pgm_term(term_type)
WORD    term_type;
{
switch (term_type) {     /* NOTE: all cases fall through         */
    case (0 /* normal termination */):
        wind_close(wi_handle);
        wind_delete(wi_handle);
    case (3):
    case (2):
        v_clsvwk( ph );
    case (1):
        wind_update(END_UPDATE);
        appl_exit();
    case (4):
        break;
    }
}

int ask_scn()	/* Show Initial Screen And Ask For Continue	*/
{
int xdial, ydial, wdial, hdial;
int x = 0;
int y = 0;
int w = 0;
int h = 0;
int retn;

rsrc_gaddr(R_TREE, STRT, &tree);
form_center(tree, &xdial, &ydial, &wdial, &hdial);
form_dial(0, x, y, w, h, xdial, ydial, wdial, hdial);
form_dial(1, x, y, w, h, xdial, ydial, wdial, hdial);
objc_draw(tree, ROOT, MAX_DEPTH, xdial, ydial, wdial, hdial);

graf_mouse(ARROW, 0x0L);
if ( form_do(tree, 0) == STRTCANC )
    retn = 1;
else
    retn = 0;    

graf_mouse(HOUR_GLASS, 0x0L);
form_dial(2, x, y, w, h, xdial, ydial, wdial, hdial);
form_dial(3, x, y, w, h, xdial, ydial, wdial, hdial);

return(retn);
}

get_parms()	/* Get Options from operator		*/
{
int xdial, ydial, wdial, hdial;
int x = 0;
int y = 0;
int w = 0;
int h = 0;
int retn;	/* Return From case call */
long  avail_drives;
long  drv_mask;
int	fhandle;	/* File Descriptor	*/
char	filenm[14];

rsrc_gaddr(R_TREE, BACKUP, &tree);
form_center(tree, &xdial, &ydial, &wdial, &hdial);
form_dial(0, x, y, w, h, xdial, ydial, wdial, hdial);
form_dial(1, x, y, w, h, xdial, ydial, wdial, hdial);
objc_change(tree,VERNO, 0,xwork,ywork,wwork,hwork,SELECTED,1);
objc_change(tree,FILE,0,xwork,ywork,wwork,hwork,SELECTED,1);
objc_draw(tree, ROOT, MAX_DEPTH, xdial, ydial, wdial, hdial);

graf_mouse(ARROW, 0x0L);

for ( retn = -1; retn == -1; ) {
    switch ( form_do(tree, SRC) ) {
        case SRC:		/* Source Drive	*/
            break;
        
        case DEST:		/* Destination Drive	*/
            break;
        
        case FILE:		/* Backup by TIMESTMP.HD file timestamp	*/
            type_update = FILE;
            objc_change(tree,FILE,0,xwork,ywork,wwork,hwork,SELECTED,1);
            objc_change(tree,DATE,0,xwork,ywork,wwork,hwork,NORMAL,1);
            objc_change(tree,ALL ,0,xwork,ywork,wwork,hwork,NORMAL,1);
            break;
        
        case DATE:		/* Backup by Entered Date	*/
            type_update = DATE;
            objc_change(tree,DATE,0,xwork,ywork,wwork,hwork,SELECTED,1);
            objc_change(tree,FILE,0,xwork,ywork,wwork,hwork,NORMAL,1);
            objc_change(tree,ALL ,0,xwork,ywork,wwork,hwork,NORMAL,1);
            break;
        
        case ALL:		/* Backup ALL Files	*/
            type_update = ALL;
            objc_change(tree,ALL,0,xwork,ywork,wwork,hwork,SELECTED,1);
            objc_change(tree,FILE,0,xwork,ywork,wwork,hwork,NORMAL,1);
            objc_change(tree,DATE,0,xwork,ywork,wwork,hwork,NORMAL,1);
            break;
        
        case VERNO:		/* No verification on replace copy	*/
            autowrite = TRUE;
            objc_change(tree,VERNO, 0,xwork,ywork,wwork,hwork,SELECTED,1);
            objc_change(tree,VERYES,0,xwork,ywork,wwork,hwork,NORMAL,1);
            break;
        
        case VERYES:	/* Verification on replace copy	*/
            autowrite = FALSE;
            objc_change(tree,VERYES,0,xwork,ywork,wwork,hwork,SELECTED,1);
            objc_change(tree,VERNO, 0,xwork,ywork,wwork,hwork,NORMAL,1);
            break;
        
        case CANCEL:	/* No Copy - Exit Program	*/
            retn = 1;
            break;
        
        case START:		/* Start Copy	*/
            rsrc_gaddr(R_TREE, BACKUP, &obj);
            ted = (TEDINFO *)obj[SRC].ob_spec;
            LBCOPY(src, ted->te_ptext, 1);
            isrc = src[0] - '@';
            ted = (TEDINFO *)obj[DEST].ob_spec;
            LBCOPY(dest, ted->te_ptext, 1);
            idest = dest[0] - '@';
            if ( src[0] == dest[0] ) {
    		form_alert(1, "[3][       Source|        and|     Destination|Cannot by the same!!][ OK ]");
                objc_change(tree,START, 0,xwork,ywork,wwork,hwork,NORMAL,1);
                break;
    		}
	    avail_drives = Drvmap();	/* Get Available Drives	*/
	    drv_mask = 1 << (isrc - 1);	/* See if source drive exists	*/
	    if ( (avail_drives & drv_mask) == 0 ) {
    		form_alert(1, "[3][    Source Drive|  Does not exist!!][ OK ]");
                objc_change(tree,START, 0,xwork,ywork,wwork,hwork,NORMAL,1);
                break;
        	}
	    drv_mask = 1 << (idest - 1);	/* See if source drive exists	*/
	    if ( (avail_drives & drv_mask) == 0 ) {
    		form_alert(1, "[3][  Destination Drive|  Does not exist!!][ OK ]");
                objc_change(tree,START, 0,xwork,ywork,wwork,hwork,NORMAL,1);
                break;
        	}
	    
	    if ( type_update == FILE ) {
		strcpy(filenm, src);
		strcat(filenm, "\\");
		strcat(filenm, FILENM);
		if ( (fhandle = Fopen(filenm, 0)) > 0 ) { /*See if file exists*/
    		    Fdatime(&date_backup, fhandle, 0);	/* Get date and time */
    		    Fclose(fhandle);
    		    }
		else {	/* File doesn't exist */
		    form_alert(1, "[3][     TIMESTMP.HD|  Doesn't Exist on|    Source Drive|  Select Backup by|    DATE or ALL?][ CONTINUE ]");
                    objc_change(tree,FILE,0,xwork,ywork,wwork,hwork,NORMAL,1);
                    objc_change(tree,DATE,0,xwork,ywork,wwork,hwork,SELECTED,1);
                    type_update = DATE;
                    objc_change(tree,START, 0,xwork,ywork,wwork,hwork,NORMAL,1);
                    break;
                    }
        	}
            retn = 0;	/* Source, Dest, & Type ok	*/
            break;
        }
    }

graf_mouse(HOUR_GLASS, 0x0L);
form_dial(2, x, y, w, h, xdial, ydial, wdial, hdial);
form_dial(3, x, y, w, h, xdial, ydial, wdial, hdial);

return(retn);
}

opt_date()	/* Get Date from operator - If date Selected	*/
{
int xdial, ydial, wdial, hdial;
int x = 0;
int y = 0;
int w = 0;
int h = 0;
int retn;	/* Return From case call */

rsrc_gaddr(R_TREE, OPERDATE, &tree);
form_center(tree, &xdial, &ydial, &wdial, &hdial);
form_dial(0, x, y, w, h, xdial, ydial, wdial, hdial);
form_dial(1, x, y, w, h, xdial, ydial, wdial, hdial);
objc_draw(tree, ROOT, MAX_DEPTH, xdial, ydial, wdial, hdial);

graf_mouse(ARROW, 0x0L);

for ( retn = -1; retn == -1; ) {
    switch ( form_do(tree, OPDATE) ) {
        case OPDATE:		/* Get DATE	*/
            break;
        
        case OPTIME:		/* Get Time	*/
            break;
        
        case DOCANCEL:	/* No Copy - Exit Program	*/
            retn = 1;
            break;
        
        case DOBAK:		/* Start Copy	*/

            rsrc_gaddr(R_TREE, OPERDATE, &obj);
            ted = (TEDINFO *)obj[OPDATE].ob_spec;
            if ( conv_date(ted->te_ptext) == FALSE ) {
            	form_alert(1, "[3][ Invalid Date!! ][ OK ]");
                objc_change(tree,DOBAK, 0,xwork,ywork,wwork,hwork,NORMAL,1);
        	}
            else {
                ted = (TEDINFO *)obj[OPTIME].ob_spec;            	
                if ( conv_time(ted->te_ptext) == FALSE ) {
            	    form_alert(1, "[3][ Invalid Time!! ][ OK ]");
            	    objc_change(tree,DOBAK, 0,xwork,ywork,wwork,hwork,NORMAL,1);
            	    }
		else
            	    retn = 0;
                }    
            break;
        }
    }

graf_mouse(HOUR_GLASS, 0x0L);
form_dial(2, x, y, w, h, xdial, ydial, wdial, hdial);
form_dial(3, x, y, w, h, xdial, ydial, wdial, hdial);

return(retn);
}

int conv_date(string)	/* Convert string to date */
char *string;
{
int mm, dd, yy;
	
if ( string[0] > '1'                          ||
     (string[0] == '1'  &&  string[1] > '2')  ||
     string[2] > '3'                          ||
     (string[2] == '3'  &&  string[3] > '1') )	
    return(FALSE);

mm = char2int(&string[0]) << 5;          	
dd = char2int(&string[2]);
yy = char2int(&string[4]) + 1900;

if ( yy < 1980 )
    yy = 0;
else
    yy = (yy - 1980) << 9;
date_backup[1] = mm | dd | yy;
   	
return(TRUE);    
}

int conv_time(string)	/* Convert string to time	*/
char *string;
{

int  hrs, min;
	
if ( string[0] > '2'                         ||
     (string[0] == '2'  && string[1] > '3')  ||
     string[2] > '5' )
    return(FALSE);

hrs = char2int(&string[0]) << 11;          	
min = char2int(&string[2]) << 5;
date_backup[0] = hrs | min;
return(TRUE);	
}

int char2int(string)	/* Convert 2 ascii numerics to an int	*/
char *string;
{
return( (string[0] & 0x0f) * 10 + (string[1] & 0x0f) );	
}
