/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren, this file Dj. Vukovic
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <np_aes.h>
#include <vdi.h> 
#include <error.h>
#include <xerror.h>
#include <xdialog.h>
#include <boolean.h>
#include "resource.h"
#include "desk.h"
#include "showinfo.h"
#include "events.h"

static XDINFO fdinfo;

extern void force_mediach ( char * path );

/* 
 * Routine fpartoftext inserts data about current floppy disk format 
 * into ftext to be displayed and/or edited in the dialog;
 * then it re-draws these fields                     
 */
 
static void fpartoftext ( 
	int tsides,  /* number of sides */
	int tspt,    /* sectors per track */
	int ttracks, /* number of tracks */ 
	int dirsize  /* number of directory entries in root */
)
{
	rsc_ltoftext(fmtfloppy, FSIDES,   (long)tsides );
	rsc_ltoftext(fmtfloppy, FSECTORS, (long)tspt );
	rsc_ltoftext(fmtfloppy, FTRACKS,  (long)ttracks ); 
	rsc_ltoftext(fmtfloppy, FDIRSIZE,  (long)dirsize );
	xd_draw ( &fdinfo, FPAR3, MAX_DEPTH );
} 


/* 
 * Routine fpenable enables/disables editting of floppy format params
 * bu (re)setting the DISABLED ob_state flags 
 */

static void fpenable ( 
	int e  /* e=1: enable */
)
{
	if ( e ){ 
		fmtfloppy[FSIDES].ob_state   &= ~DISABLED;
		fmtfloppy[FTRACKS].ob_state  &= ~DISABLED;
		fmtfloppy[FSECTORS].ob_state &= ~DISABLED;
		fmtfloppy[FDIRSIZE].ob_state &= ~DISABLED;
		fmtfloppy[FLABEL].ob_state   &= ~DISABLED;
	}
	else
	{
		fmtfloppy[FSIDES].ob_state   |= DISABLED;
		fmtfloppy[FTRACKS].ob_state  |= DISABLED;
		fmtfloppy[FSECTORS].ob_state |= DISABLED;
		fmtfloppy[FDIRSIZE].ob_state |= DISABLED;
		fmtfloppy[FLABEL].ob_state   |= DISABLED;  
	}
}


/* Routine prdisp displays progress percentage */

void prdisp ( 
	int current,  /* current track, =-1 for 0% */
	int total     /* total number of tracks */
)
{
	long perc;			/* percentage of progress */
	
	perc = (current + 1) * 100 / total;
	rsc_ltoftext(fmtfloppy, FPROGRES,  perc );
	fmtfloppy[FPROGRES].ob_flags &= ~HIDETREE;
	xd_draw ( &fdinfo, FPROGRES, 1 );
}

 
/* 
 *  Routine formatfloppy performs formatting or copying of a floppy
 *  with a FAT-12 filesystem  
 */

void formatfloppy(
	char fdrive,  /* drive id letter ( 'A'or 'B' ) */
	int format    /* true for format, false for copy */
)
{
	long 
		filler=0,		/* unused but required filler */
		serial,			/* 24-bit disk serial number */
		mbsize;     	/* allocated memory block size (bytes) */

	int 
		button,			/* index of activeded button */
		istat,			/* function execution status */
		sectors,		/* total number of disk sectors */
		itrack,			/* current track (counter) */
		iside,			/* current side (counter) */
		sbps,			/* source disk bytes per sector */
		tbps,			/* target disk bytes per sector */
		sdevno,			/* source drive id */
		tdevno,			/* target disk drive id */
		ssides,			/* source disk number of sides */
		stracks,		/* source disk number of tracks */
		sspt,			/* source disk number of sectors per track */
		ipass,			/* copy pass counter */
		npass,			/* number of copy passes */
		finished,		/* =1 if successfully finished operation */
		tpp,        	/* tracks per pass  */
		i,j,n;			/* aux. counters, etc. */
	
	static int     		/* keep these from previous call */
		mspt=11,		/* maximum permitted sectors per track */
		tsides,			/* target disk number of sides */
		ttracks,		/* target disk number of tracks */
		tspt,			/* target disk number of sectors per track */
		intleave=1,		/* sector interleave */
		fatsize=3,		/* FAT size (sectors), take other initial values from dialog */
		dirsize;		/* number of directory entries */
	    
	char 
		drive[4],		/* string with drive id */
		*errtxt,		/* errortext */
		nothing = 0,	/* nothing */
		fmtsel;     	/* flag for selected format type */

	unsigned char 
		*sect0,			/* pointer to work buffer for sector/track data */
		*label;			/* pointer to a position within setc0 */
    
	static unsigned char
		fat0;			/* first byte of each FAT */
 
	/* 
	 * Allocate some memory, but at least 40KB; 
	 * if unsuccessfull, exit
	 * (min.allocation is for two max.tracks = 2 * 40*512 bytes = 40960 bytes) 
	 */
	 		
	if ( !format )
		mbsize = (long) options.bufsize * 1024L; /* use copy buffer size */
	if ( mbsize < 40960L ) mbsize = 40960L; 

	if ( (  sect0 = malloc( mbsize ) ) ==NULL ) 
	{
		xform_error ( ENSMEM );
		return;
	}
	
	/* Initial states of some items, depending on action */
  
	drive[1] = 0;	 /* terminator, just in case  */
	fmtsel   = 0;    /* no format selected so far */
	finished = 0;	 /* no success yet */
  
	fpenable(0); /* disable editable format params fields */
  
	fmtfloppy[FSSIDED].ob_state &= ~SELECTED; /* deselect all format buttons */
	fmtfloppy[FDSIDED].ob_state &= ~SELECTED;
	fmtfloppy[FHSIDED].ob_state &= ~SELECTED;
	fmtfloppy[FESIDED].ob_state &= ~SELECTED;
  
	fmtfloppy[FPROGRES].ob_flags |= HIDETREE; /* hide progress display */

	if ( format )	/* format disk */
	{
		rsc_title(fmtfloppy, FLTITLE, DTFFMT);		/* title */
		fmtfloppy[FTGTDRV].ob_flags |= HIDETREE;  	/* hide "to ... " text */
		fmtfloppy[FSSIDED].ob_state &= ~DISABLED; 	/* enable all format buttons */
		fmtfloppy[FDSIDED].ob_state &= ~DISABLED;
		fmtfloppy[FHSIDED].ob_state &= ~DISABLED;
		fmtfloppy[FESIDED].ob_state &= ~DISABLED;
		fmtfloppy[FPAR3].ob_flags   &= ~HIDETREE; 	/* show editable fields */
		fmtfloppy[FLABEL].ob_flags  &= ~HIDETREE; 	/* show label field */
		fmtfloppy[FLABEL].ob_state  &= ~DISABLED; 	/* it is editable */
		tdevno = (int)fdrive - 65;					/* target drive */
	}
	else 					/* copy disk */
	{
		rsc_title(fmtfloppy, FLTITLE, DTFCPY);		/* Title */
		fmtfloppy[FTGTDRV].ob_flags  &= ~HIDETREE;	/* show "to ..." text */
		fmtfloppy[FPAR3].ob_flags    |= HIDETREE;	/* hide format param fields */
		fmtfloppy[FSSIDED].ob_state  |= DISABLED;	/* disable all format buttons */
		fmtfloppy[FDSIDED].ob_state  |= DISABLED;
		fmtfloppy[FHSIDED].ob_state  |= DISABLED;
		fmtfloppy[FESIDED].ob_state  |= DISABLED;    
		fmtfloppy[FLABEL].ob_flags   |= HIDETREE;	/* hide label field */
		sdevno = (int)fdrive - 65;  									/* source drive */
		tdevno = 1 & (1^sdevno);  									/* the other one */
		drive[0] = tdevno + 65;     									/* target drive letter */
		strcpy(fmtfloppy[FTGTDRV].ob_spec.tedinfo->te_ptext, drive); 
	}

	drive[0] = fdrive; /* source drive for copy, target for format */
	strcpy(fmtfloppy[FSRCDRV].ob_spec.tedinfo->te_ptext, drive); 
  
 
	/* Open dialog */
		
	xd_open(fmtfloppy, &fdinfo);
	
	button = FDSIDED; /* anything but OK or Cancel */
	
	/* Loop until OK or Cancel */
	
	while ( button != FMTOK && button != FMTCANC ){

		again: /* return here if invalid format parameters */
      
		button = xd_form_do ( &fdinfo, ROOT );
          
    /* Set formatting parameters */
       
		if ( format )
		{
      
			/* Read params for diverse floppy disk formats from dialog */

			tsides =  atoi(fmtfloppy[FSIDES].ob_spec.tedinfo->te_ptext);
			tspt =    atoi(fmtfloppy[FSECTORS].ob_spec.tedinfo->te_ptext);
			ttracks = atoi(fmtfloppy[FTRACKS].ob_spec.tedinfo->te_ptext);
			dirsize = atoi(fmtfloppy[FDIRSIZE].ob_spec.tedinfo->te_ptext); 

			/* Configure format; always use "optimized" (i.e. smaller) FAT size */
			
			switch (button)
			{
				case FSSIDED:		/* SS DD disk */
					fmtsel = 1;
					tsides = 1;
					tspt = 9;
					mspt = 11;
					ttracks = 80;
					intleave = 1;
					fatsize = 3;
					dirsize = 112;
					fat0 = 0xf9;
					break;
				case FDSIDED:		/* DS DD disk */
					fmtsel = 1;
					tsides = 2;
					tspt = 9;
					mspt = 11;
					ttracks = 80;
					intleave = 1;
					fatsize = 3;
					dirsize = 112;
					fat0 = 0xf9;
					break;
				case FHSIDED:		/* DS HD disk */
					fmtsel = 1;
					tsides = 2;
					tspt = 18;
					mspt = 20;
					ttracks = 80;
					intleave = 1;
					fatsize = 5;
					dirsize = 224;
					fat0 = 0xf0;
					break;
				case FESIDED:		/* DS ED disk (not tested) */
				  fmtsel = 1;
					tsides = 2;
					tspt = 36;
					mspt = 40;			/* is it so? */
					ttracks = 80;
					intleave = 1;
					fatsize = 9;
					dirsize = 448;  /* is it so? never seen an ED disk */
					fat0 = 0xf0;    /* is it so ? */
					break;
				default:				/* no change */
          			break;       
			} /* switch */   

		}  /* format ? */
   
  
		/* Update displayed params regarding selected or found format */
 
		if ( fmtsel ) fpenable(1);
    
		fpartoftext( tsides, tspt, ttracks, dirsize );
  
	} /* while... */

	/* If selected OK */
  
	if ( button == FMTOK ){

		/* Reset pressed OK button */
	  		
		xd_change( &fdinfo, FMTOK, NORMAL, TRUE );

		/* Check format parameters */
	  
		if ( format )
		{
			/*  
			 *  Max.possible number of dir.entries should not, (for my convenience)
			 *  exceed end of second track (disk will be zeroed only so far);
			 *  formula below gives maximum 143 for DD, 287 for HD; 
			 *  FATs should, for convenience too, remain within first track;
			 */
		  
			tbps = 512; /* always 512 bytes per sector */
		  
			if ( ( tsides  <  1  ) || ( tsides > 2 )   ||
			   ( ttracks <  1 ) || ( ttracks > 84 ) || /* 84=physical limit, most often it is 83 */
			   ( tspt < 3 )  || ( tspt > mspt ) ||     /* mspt depends on disk type */
			   ( fatsize < 1 ) || ( fatsize > ((tspt - 1) / 2) ) || /* two fats + sector 0 fit on a track */
			   ( dirsize < 32) || ( dirsize > ( (tspt * tbps) / 32 - 1) ) ) /* 32 byes per entry */
			{
				button = alert_printf ( 1, MFPARERR );
				goto again; /* go back to dialog if params not correct*/
			}
		}         
                   
		/* Confirm destructive action ("all data will be erased...") */
    
		button = alert_printf ( 2, MERADISK );
    
		if ( button == 1 ){ /* yes, do it */
    
			if ( format ) /* format disk */
 			{
				/* Now format each track... */
				
				prdisp ( -1, 100 );
          
				for ( itrack = 0; itrack < ttracks; itrack++ )
				{       
					for ( iside = 0; iside < tsides; iside++ )
					{
        
						retry: /* come here for a retry after formatting error */

						/*
						 *  Calling xbios... produces slightly smaller code
						 *  than calling Flopfmt, Floprd, Flopwr...
						 */
						 						
						istat = xbios(10, sect0, filler, tdevno, tspt, itrack, iside, intleave, 0x87654321L, 0xE5E5 ); 

						/* In case of error inquire what to do */
						
						if ( istat != 0 )
						{
							/* Disk protected is the most common error */

							if ( istat == WRITE_PROTECT )
								errtxt = get_freestring( TWPROT );
							else
								errtxt = &nothing;
							button = alert_printf( 3, MFMTERR, istat, itrack, errtxt );
							switch ( button )
							{
								case 1:				/* retry same track */
									goto retry;
								case 3:				/* abort */
									goto endall;
								default:			/* ignore and continue */
									break;
							} /* switch */
						} /* istat ? */
						else
							if ( escape_abort(FALSE) )
								goto endall;
          
					} /* iside */
          
					/* Report formatting progress after each track */
          
					prdisp ( itrack, ttracks );
                         
				} /* itrack */
        
				/* 
				 * Produce boot sector and write it 
				 * all bytes not explicitely specified will be zeros 
				 *
				 * for simplicity's sake always create optimized 
				 * (smaller) FATs 
				 */

				j = tspt * tbps * 2; 										/* two full tracks */
				for ( i = 0; i < j; i++ ) 
					sect0[i] = 0x00; 	/* zero buffer */
        
				sect0[0] = 0xeb;
				sect0[1] = 0x34;    /* maybe put here 0x3c for hd ? */
				sect0[2] = 0x90;
				sect0[3] = 'I';			/* OEM code */
				sect0[4] = 'B';
				sect0[5] = 'M';
				sect0[6] = ' ';
				sect0[7] = ' ';
        
				serial = xbios(17);						  										/* produce random number */
				sect0[8] = (unsigned char)( serial & 0xFF );        /* disk serial */
				sect0[9] = (unsigned char)( (serial >> 8) && 0xFF );
				sect0[0x0a] = (unsigned char)( (serial >> 16) & 0xFF );
                               
				sect0[0x0c] = (char)(tbps >> 8); /* bytes/128 per sector */
		       
				sect0[0x0d] = 0x02;            /* sectors per cluster */
				sect0[0x0e] = 0x01;            /* reserved sectors */
				sect0[0x10] = 0x02;            /* number of FATS */
				
				sect0[0x11] = (unsigned char)( dirsize & 0xFF ); /* dir entries */
				sect0[0x12] = (unsigned char)( dirsize >> 8 ); 
		    
        		/* 
				 * calculate FAT size; always use optimized 12-bit FATs; 
				 * for each cluster use use 3/2 bytes, add 2 for FAT header 
				 * fomula below will generally give 3- and 5-sector FATs 
				 * for DD and HD respectively 
				 */
		   		   						
				sectors = tspt * ttracks * tsides;   /* total sectors  */
				fatsize = (sectors + 2) * 3 / 2048 + 1; 
        
				sect0[0x13] = (unsigned char)(sectors & 0xFF);   /* total sectors */
				sect0[0x14] = (unsigned char)(sectors >> 8); 
		        
				sect0[0x15] = 0xf9;            /* media id. */
				sect0[0x16] = (char)fatsize;   /* sectors per fat: 3 ... 9 */
				
				sect0[0x18] = (unsigned char)tspt;      /* sectors per track */
				
				sect0[0x1a] = (unsigned char)tsides;    /* sides */
				
				label = sect0 + 0x20L;				 /* location of unused space in boot sector */
				strcpy ( label, " Formatted by TeraDesk " );
        
				i = tbps;					/* locate at start of sector 1 */	
				sect0[i++] = fat0;			/* start of first FAT */
				sect0[i++] = 0xff;
				sect0[i++] = 0xff;
        
				i = (fatsize + 1) * tbps;		 /* locate at start of FAT 2 */
				sect0[i++] = fat0;			/* start of second FAT */
				sect0[i++] = 0xff;
				sect0[i++] = 0xff;
       
				i = (2 * fatsize + 1) * tbps;	/* locate at start of root dir */
				label = sect0 + (long)i;		/* where does volume label go */
        
        		strcpy ( label, fmtfloppy[FLABEL].ob_spec.tedinfo->te_ptext );
        
				sect0[i+11] = 0x08;							/* next, insert label attribute */
        
				/* 
				 * write and verify complete first  and second track 
				 * this will surely cover all space used by root dir
				 */
				 				 
				for ( itrack = 0; itrack < 2; itrack++ )
				{
					label = sect0 + tbps * tspt * itrack; /* start of next track in buffer */ 
					istat= xbios( 9, label, filler, tdevno, 1, itrack, 0, tspt );
					if ( !istat )
						istat= xbios( 19, label, filler, tdevno, 1, itrack, 0, tspt );
					if ( istat ) 
						goto abortfmt;
					else
					{
						finished=1;
						goto endall;
					} /* if istat... */
				}	  /* for itrack... */        
      		}
      		else /* disk copy */
      		{
				/* Insert target disk, read boot sector */
        
				drive[0] = 65 + tdevno; /* target drive letter */

				istat = xbios( 8, sect0, filler, tdevno, 1, 0, 0, 1 );
				if ( istat ) goto abortfmt;
				
				/* decode format parameters from boot sector */
 				
				tbps =   ((int)sect0[0x0b]) | (( (int)sect0[0x0c] ) << 8 );
				sectors = ((int)sect0[0x13]) | (( (int)sect0[0x14] ) << 8 );
				tspt =   ((int)sect0[0x18]) | (( (int)sect0[0x19] ) << 8 );
				tsides = ((int)sect0[0x1a]) | (( (int)sect0[0x1b] )<< 8 );
				ttracks = sectors /( tspt * tsides );
          
				/* Insert source disk, read boot sector */
        
				drive[0] = 65 + sdevno; /* source drive letter */

				istat= xbios( 8, sect0, filler, sdevno, 1, 0, 0, 1 );
				if ( istat ) goto abortfmt;

				sbps =   ((int)sect0[0x0b]) | (( (int)sect0[0x0c] ) << 8 );
				sectors =((int)sect0[0x13]) | (( (int)sect0[0x14] ) << 8 );
				sspt =   ((int)sect0[0x18]) | (( (int)sect0[0x19] ) << 8 );
				ssides = ((int)sect0[0x1a]) | (( (int)sect0[0x1b] ) << 8 ); 
				stracks = sectors / (sspt * ssides);
				dirsize = ((int)sect0[0x11]) | (( (int)sect0[0x12] ) << 8 );
								
				/*  
				 *  Do source & target have the same format?
				 *  If not, abort all
				 *  note: this will, unfortunately, prevent copying of "data" disks
				 * 	without a proper boot sector  
				 */
        
				if ( ( sbps != tbps ) ||        /* bytes per sector */
				     ( ssides != tsides ) ||    /* number of sides */
				     ( stracks != ttracks ) ||  /* number of tracks */ 
				     ( sspt != tspt )  )        /* sectors per track */
				{                 
					button = alert_printf ( 1, MDIFERR );
					goto endall;
				}
				
				/* show format parameters of the source disk (they are the same as for target disk) */     
      
				fmtfloppy[FPAR3].ob_flags &= ~HIDETREE;

				fpartoftext( ssides, sspt, stracks, dirsize );
				prdisp ( -1, 100 );
				
				/* 
				 * How tracks to copy in each pass ? 
				 * how many passes ?
				 */
				
				tpp = mbsize / (tbps * tspt * tsides);   
				npass = ttracks / tpp;
				if ( ttracks % tpp ) npass++;
								
				/* Now start copying */
			
				i = 0; j = 0; /* this will now be the source and target track counters */
				
				for ( ipass = 0; ipass < npass; ipass++ )
				{
				  
					/* 
					 * how many tracks to copy indeed
					 * and not pass the end of the floppy disk 
					 */
				   
					n= ttracks-i;
					if ( n > tpp ) n=tpp; 
				  
					/* read and verify (i.e. read twice) a number of tracks, display progress  */
				  
					for ( itrack = 0; itrack < n; itrack++ )
					{				  			  
						for ( iside = 0; iside < tsides; iside++ )
						{
				    
							label = sect0 + ((long)sbps) * sspt * ( itrack * ssides + iside );

							istat = xbios( 8, label, filler, sdevno, 1, i+itrack, iside, sspt );
							if ( !istat )
								istat = xbios( 19, label, filler, sdevno, 1, i+itrack, iside, sspt );
							if ( istat ) goto abortfmt;
							if ( escape_abort(FALSE) )
								goto endall;

						}				    

						prdisp ( i + j + itrack, ttracks * 2 ); /* diplay progress */
 						
					}
					i = i + n;
				  
					/* Write and verify a number of tracks, display progress */
				  
					for ( itrack = 0; itrack < n; itrack++ )
					{
						for ( iside = 0; iside < tsides; iside++ )
						{
				    	
							label = sect0 + ((long)tbps) * tspt * ( itrack * tsides + iside );
				    	
							istat = xbios( 9, label, filler, tdevno, 1, j+itrack, iside, tspt );
							if ( !istat )
								istat= xbios( 19, label, filler, tdevno, 1, j+itrack, iside, sspt );
							if ( istat ) goto abortfmt;
							if ( escape_abort(FALSE) )
								goto endall;
						}
				    
						prdisp ( i + j + itrack, ttracks * 2 );	/* diplay progress */			    
					}
					j = j + n;

				} /* ipass */
	  
				finished=1;    
				goto endall; /* all is well, and finished */
	              
			} 	/* copy-format */
		}		/* button=? */
    
    	/* Come here to report diverse errors (" error while accessing floppy...") */
    
		abortfmt:	
		if ( (button == 1 ) && !finished ) /* if started but not finished */
		{
			if ( istat == WRITE_PROTECT )
				errtxt = get_freestring( TWPROT );
			else
				errtxt = &nothing;
			alert_printf( 1, MERRACC, istat, errtxt );
		}
	}
	else    /* Cancel, reset button state  */
		xd_change(&fdinfo, FMTCANC, NORMAL, FALSE);

	/* Close dialog, free buffer */
  
	endall:
	xd_close(&fdinfo);
	if ( sect0 != NULL ) free(sect0);
	
	/* 
	 * Convince the computer that it has a new disk here; 
	 * Display information on this disk 
	 */

	if ( finished ){
	
		drive[0] = 65 + tdevno;
		drive[1] = ':';
		drive[2] = '\\';
		drive[3] = 0;
		force_mediach ( drive );
		button= si_drive ( drive, &i, &n );  /* last two args are irelevant?  */
		closeinfo(); /* DjV 022 120103 */
	}

}
