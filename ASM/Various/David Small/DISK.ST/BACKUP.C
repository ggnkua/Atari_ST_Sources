/***************************************************************************** 
 *															  * 
 *						  Meg a Minute 						  * 
 *							 by								  * 
 *						Daniel L. Moore						  * 
 *							and								  * 
 *						  David Small							  * 
 *															  * 
 *				    version 1.04  for Megamax C					  * 
 *						   11/16/86							  * 
 *				    version 1.05  for Megamax C					  *
 *						   12/16/86							  *
 *															  * 
 *****************************************************************************
 *															  *
 *	Dedication:												  *
 *		To Rosebud the basselope, who knows what it's like to have one     *
 *		 of those days.										  *
 *															  * 
 *****************************************************************************/


#include <portab.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#include "bckup.rsh"
#include "backup.h"

/* misc defines */
#define TRUE	1
#define FALSE	0
#define NULL	0L
#define DESK	   0
#define WF_WXYWH  4

#define DEBUG	0

/* 
 * hooks into the twister formatter code.
 * These are passed as globals to avoid problems with
 * passing params via Supexec().
 *
 * The actual twister format code is in mmtwst.c.  This file
 * is common to both backup.prg and twister.prg. It is 
 * located in the twister directory on the disk.
 */ 
extern twister();		/* the formatter, obviously		  */

extern int thedisk, 	/* drive number to format (A=0, B=1) */
		 dblsided,	/* sides (0 = single, -1 = double)   */
		 sectoroffset; /* offset for physical sector numbering */
extern long buffer; 	/* Track buffer for format.		  */
extern int badflag; 	/* non-zero means a verify error	  */

/*
 * More external routines.  These are the DMA buss i/o routines
 * that Supra uploaded to the Developers Forum on Compuserve (PCS 57)
 *
 * The source code to these routines is _not_ included.  If you
 * want it you must get it from Compuserve.
 *
 * Dave and I would like to thank Supra for releasing the source
 * code to these routines.  Without them backup.prg would have 
 * been a lot longer in the writing.
 *
 * NOTE: Only the second half of the Supra source file is needed,
 *	    the portion labeled "Actual low level drivers".
 *
 */
extern hd_read();
extern hd_write();
extern hd_sense();

/* 
 * Use a 100K copy buffer.  That gives either 4 or 8 passes per disk,
 * and is small enough that it will be available on 512K machines.
 * (changed from 200K since it seems that hd_read/write can't handle
 * more than 100K in a block.)							  
 */
#define BUF_SIZE   102400L
#define BUF_SECS   200
#define TRACK_SIZE 0x4000L

	/* maximum number of partitions on a drive */
#define MAX_HD 4

/* Stuff to call AES.  */
WORD   contrl[12];
WORD   intin[80];
WORD   ptsin[256];
WORD   intout[45];
WORD   ptsout[12];
WORD   msgbuf[8];
WORD   VDIhandle;

/* external variables (defined in system library) */
extern WORD gl_apid;

/* pointers to dialog trees (are they sure they aren't bushes?) */
OBJECT   *d_direct;
OBJECT   *d_restore;
OBJECT   *d_backup;
OBJECT   *d_newdisk;
OBJECT   *d_backdisk;
OBJECT   *d_whichdrv;
OBJECT   *d_copout;
OBJECT   *d_getfirst;
OBJECT   *d_reboot;
OBJECT   *d_msgbox;

#define void /**/

#define CONFIRM_LEN 16

 /* our "boot" sector format (not compatible with GEMDOS) */
typedef struct my_boot {
	LONG  serial;			   /* unique for a given backup	   */
	WORD  sides;			   /* 1 or 2					   */
	BYTE  confirm[CONFIRM_LEN]; /* confirm is our hd backup format */
	WORD  which_disk,		   /* this disk number in the backup  */
		 total_disk;		   /* number of disks in the image    */
	LONG  start_sec,		   /* first HD sector on disk 	   */
		 end_sec, 		   /* last HD sector on disk		   */
		 part_size,		   /* partition size in sectors	   */
		 part_start;		   /* original partition start sector */
	WORD  part_drive,		   /* original partition number	   */
		 part_type;		   /* original partition type (TRUE = GEMDOS) */
	/* date time structure goes here */
} BOOT_REC, *BOOT_PTR;

typedef struct hd_info {
	WORD  cylinders;
	BYTE  heads,
		 res1;
	WORD  rwcc,
		 wpc;
	BYTE  land,
		 seekrate,
		 interleave,
		 spt;
	LONG  size;
} HDI, *HDI_PTR;

typedef struct hd_part {
	LONG  id;
	LONG  start;
	LONG  size;
} HDP, *HDP_PTR;
	
 /* the backup buffers and variables */ 
BYTE  *hd_buff;			/* our disk i/o buffer			*/
WORD   source_drive,	
	  dest_drive,
	  part_valid[MAX_HD];	/* true if a valid partition		*/
LONG   part_size[MAX_HD],	/* sectors in current partition	*/
	  part_start[MAX_HD],	/* starting sector for partition	*/
	  back_serial; 		/* unique for a given backup (we hope) */
WORD   part_type[MAX_HD];	/* true if GEMDOS partition		*/
LONG   start_sec,			/* current start sector in copy	*/
	  end_sec,			/* end sector for copy			*/
	  last_sec;			/* last sector on partition		*/
WORD   sides,				/* number of sides				*/
	  which_disk,			/* current disk in the backup 	*/
	  how_many;			/* how many disks in the backup	*/
WORD   restore_flag = FALSE;	/* set if a restore is done		*/

/* data for the current backup disks */
BOOT_REC backup_data;		/* data from the first backup disk */
BOOT_REC curr_data; 		/* data from the current disk in backup */

WORD     recno;			/* start sec for track in floprw	*/

char *id_confirm = "MEGaMIN  dlm&dms";

#define WRITE 1
#define READ  0

void
setmem(p, n, c)
register unsigned char *p;
register unsigned int   n;
register unsigned char  c;
{
	for (; n; n--)
		*(p++) = c;
}

void
movmem(s, d, n)
register unsigned char *s, *d;
register unsigned int   n;
{
	/* NOTE: This assumes NO overlap of source and destination! */
	for (; n; n--)
		*(d++) = *(s++);
}

/*
 * floprw - floppy read/write sectors
 *
 * Modified version of the BIOS floprw routine.  This one has
 * been modified for the different sector numbering of MegAMin
 * backup disks.  All code that wasn't relavent was removed.
 */
LONG floprw(rw, buf, start_sec, dev, count)
WORD rw;
LONG buf;
WORD start_sec, dev, count;
{
	register WORD track, side, sect, cnt;
	register LONG ret;

	recno = start_sec;

    /*
	* Read or write sectors.
	* Optimize for multi-sector transfers
	* (as much of a track as possible):
	*/
	while (count) {
		track = recno / (10 * sides); 	/* compute track# */
		sect = recno %  (10 * sides); 	/* compute sector# */

		if (sect < 10)
			side = 0; 		 /* single-sided media */
		else {				 /* two-sided media */
			side = 1;
			sect -= 10;
		}

		if ((10 - sect) < count)
			cnt = 10 - sect;		/* rest of track */
		else 
			cnt = count;			/* part of track */

		sect += 11;			/* ours are numbered 11 to 20 */

		if (rw & 1)				    /* write */
			ret = Flopwr(buf, 0L, dev, sect, track, side, cnt);
		else 					    /* read */
			ret = Floprd(buf, 0L, dev, sect, track, side, cnt);

		if (ret < 0)
			return (ret);

		buf += ((long)cnt << 9); 	/* advance DMA pointer */
		recno += cnt;				/* bump record number */
		count -= cnt;				/* decrement count */
    }

    return (0);				 /* success! */
}

slow_flopread(buffer, sector, drive, count)
register BYTE *buffer;
register WORD sector, drive, count;
{
	/* 
	 * handle reading a floppy with bad sectors.  
	 *
	 * We can pull a slight trick here, recno points to the
	 * first sector on the track that had the i/o error.  We
	 * don't have to start reading single sectors at sector
	 * but at recno instead.  This can save a lot of time.
	 *
	 * First adjust the buffer to point to the sector at
	 * recno.  All earlier sectors are buffered already.
	 * Also adjust the count.
	 */

	show_msg("Slow read of floppy.");

	buffer += (recno - sector) * 512;
	count  -= (recno - sector);

	sector = recno;

	/*
	 * now start reading one sector at a time till done.
	 * on each bad sector set the buffer to "BAD SECTOR"
	 * so they can be easily found on the HD.
	 */
	for (; count; count--) {
		if (floprw(READ, buffer, sector, drive, 1)) {
			/* bad floppy sector */
			setmem(buffer, 512, 0);
			strcpy(buffer, "BAD SECTOR ON FLOPPY");
		}
		buffer += 512;
		sector++;
	}
}

void
init_gem()
/* 
 * setup the "resource" and the pointers to it.  Doing it here saves us from
 * having a .rsc file on the disk which the user can forget to copy.		
 */
{
	register int i, j;
	WORD     work_in[11], work_out[57], junk;
	WORD     x, y, w, h;

	appl_init();		/* be trusting, assume it won't fail. (haha) */

	for (i = 0; i < 10; i++)
		work_in[i] = 1;
	work_in[10] = 2;

	VDIhandle = graf_handle(&junk, &junk, &junk, &junk);

	v_opnvwk(work_in, &VDIhandle, work_out); /* open virtual work stn */

	/* we have now told AES/VDI everything they wanted to know
	   about us but were afraid to ask.  What a pain in the ass. */

	/* clear the screen, and then force a redraw of the dither */
	v_clrwk(VDIhandle);
	wind_get(DESK, WF_WXYWH, &x, &y, &w, &h);
	form_dial(FMD_FINISH, 0L, 0L, x, y, w, h);

	/* 
	 * Now  adjust the object coordinates from character based to pixel
	 * based.  Also hook the strings to the string objects and buttons.  
	 */
	for (i = j = 0; j < NUM_OBS; j++) {
		rsrc_obfix(rs_object, j);		 /* fix the coordinates system */
		if (rs_object[j].type == G_STRING || rs_object[j].type == G_BUTTON)
			rs_object[j].spec = rs_strings[i++];
	}

	/* now setup the pointers to the dialog bushes */
	d_direct	  = &rs_object[rs_trindex[DIRECT]];
	d_backup	  = &rs_object[rs_trindex[BACKUP]];
	d_restore   = &rs_object[rs_trindex[RESTORE]];
	d_newdisk   = &rs_object[rs_trindex[NEWDISK]];
	d_backdisk  = &rs_object[rs_trindex[BACKDISK]];
	d_whichdrv  = &rs_object[rs_trindex[WHICHDRV]];
	d_copout	  = &rs_object[rs_trindex[COPOUT]];
	d_getfirst  = &rs_object[rs_trindex[GETFIRST]];
	d_reboot	  = &rs_object[rs_trindex[REBOOT]];
	d_msgbox	  = &rs_object[rs_trindex[MSGBOX]];

	graf_mouse(0, 0L);		/* arrow */
}

void
make_boot()			/* use genuine alligator hide */
{
	register BOOT_PTR the_sock;

	the_sock = (BOOT_PTR) hd_buff;

	setmem(hd_buff, 512, 0);  /* start by clearing the sector */
	
	the_sock->serial = back_serial;
	the_sock->sides  = sides;

	movmem(id_confirm, the_sock->confirm, CONFIRM_LEN);

	the_sock->which_disk = which_disk;
	the_sock->total_disk = how_many;
	the_sock->start_sec  = start_sec - part_start[source_drive];
	the_sock->end_sec	 = end_sec - part_start[source_drive];
	the_sock->part_size  = part_size[source_drive];
	the_sock->part_start = part_start[source_drive];
	the_sock->part_drive = source_drive;
	the_sock->part_type  = part_type[source_drive];
}

void
get_hdinfo()
/*
 * what about the hard disk, master?
 * well grasshopper it ...			
 */
{
	register HDI_PTR  hdi;
	register HDP_PTR  hdp;
	register WORD i, flag;
	register LONG test;

	/* secnum, count, buffer, dma device */
	hd_read(0L, 1, hd_buff, 0);  /* the partition data sector */

	hdi = (HDI_PTR) (hd_buff + 0x1b6);
	hdp = (HDP_PTR) (hd_buff + 0x1c6);  /* partition 0 */

	for (i = 0; i < MAX_HD; i++) {
		if (*((BYTE *) &hdp[i].id) != 0) { /* valid partition number */
			test = hdp[i].id & 0x00ffffff; /* ignore high byte */
			part_valid[i] = TRUE;
			if (test == 0x0047454d)	  /* "GEM" */
				part_type[i] = TRUE;  /* GEMDOS partition */
			else
				part_type[i] = FALSE;
			part_start[i] = hdp[i].start;
			part_size[i] = hdp[i].size;
		}
		else
			part_valid[i] = FALSE;	/* not a partition */
	}
}

void
slow_read(sector, count, buff)
register LONG	sector;
register WORD	count;
register BYTE *buff;
{
	/*
	 * Do a "slow" hd_read.
	 * 
	 * Since there may be more than one bad sector, just read
	 * them one sector at a time.  This is a LOT slower than
	 * burst reads of the drive, but it is simple and works.
	 */

	show_msg("Slow read of hard disk.");

	for(; count; count--) {
		if (hd_read(sector, 1, buff, 0)) {
			/*
			 * this one is bad.  To make it easy to find just
			 * set the start of the buffer to "BAD SECTOR"
			 * and clear the rest.
			 */
			setmem(buff, 512, 0);
			strcpy(buff, "BAD SECTOR ON HARD DISK");
		}
		buff += 512;
		sector++;
	}
}

void
slow_write(sector, count, buff)
register LONG	sector;
register WORD	count;
register BYTE *buff;
{
	/*
	 * Do a "slow" hd_write.
	 *
	 * Essentially the same as the above routine.
	 */

	show_msg("Slow write to hard disk.");

	for(; count; count--) {
		/* 
		 * since we can't do anything about bad HD sectors
		 * just ignore any errors that may occur.
		 *
		 * Sorry folks.  If it bugs you get a new HD.
		 */
		hd_write(sector, 1, buff, 0);
		buff += 512;
		sector++;
	}
}

WORD
handle_dialog(bush)
OBJECT *bush;
/* 
 * Popup the dialog bush in the center of the screen.	Return the exit
 * leaf picked by the user (heh man, bushes don't have buttons)      
 */
{
	WORD leaf, x, y, w, h;

	graf_mouse(0, 0L);	/* arrow */
	show_msg(0L);
	form_center(bush, &x, &y, &w, &h);
	form_dial(FMD_START, 0L, 0L, x, y, w, h);
	objc_draw(bush, ROOT, 9, x-1, y-1, w+2, h+2);
	leaf = form_do(bush, 0, 0L, 0L);
	bush[leaf].state &= ~SELECTED;   /* deselect the exit button */
	form_dial(FMD_FINISH, 0L, 0L, x, y, w, h);
	return (leaf);
}

VOID
show_msg(string)
BYTE *string;
/* 
 * draw the msg box with string in it.	
 * also set the mouse to a busy bee.
 */
{
	static WORD x, y, w, h;

	if (string) {
		d_msgbox[MSGSTR].spec = string;
		form_center(d_msgbox, &x, &y, &w, &h);
		form_dial(FMD_START, 0L, 0L, x, y, w, h);
		objc_draw(d_msgbox, ROOT, 9, x-1, y-1, w+2, h+2);
		graf_mouse(2, 0L);	/* busy bee */
	}
	else if (x) { /* erase the displayed msg. */
		form_dial(FMD_FINISH, 0L, 0L, x, y, w, h);
		x = 0;
	}
}
 
void
back_dialog()
/* Copy sectors from HD to floppy */
{
		  WORD leaf, x, y, w, h, i, format;
	static WORD hd_drv[] = {BPARTC, BPARTD, BPARTE, BPARTF};

	for (i = 0; i < MAX_HD; i++) {
		if (part_valid[i])
			d_backup[hd_drv[i]].state &= ~DISABLED;
		else
			d_backup[hd_drv[i]].state |= DISABLED;
		d_backup[hd_drv[i]].state &= ~SELECTED;
	}

	source_drive = 0;	/* c, drive part 0 */
	d_backup[BPARTC].state |= SELECTED;

	dest_drive = 0;	/* a */
	d_backup[BFLOPA].state |= SELECTED;
	d_backup[BFLOPB].state &= ~SELECTED;

	sides = 1;
	d_backup[SIDES1].state |= SELECTED;
	d_backup[SIDES2].state &= ~SELECTED;

	format = FALSE;
	d_backup[FORMYES].state &= ~SELECTED;
	d_backup[FORMNO].state |= SELECTED;

	d_backup[BACKUPOK].state &= ~SELECTED;

	form_center(d_backup, &x, &y, &w, &h);
	form_dial(FMD_START, 0, 0, 0, 0, x, y, w, h);
	objc_draw(d_backup, ROOT, MAX_DEPTH, x-1, y-1, w+2, h+2);

	do {
		/* display info for current partition */
		ltoa_mode(part_start[source_drive], d_backup[PARTSTAR].spec, TRUE, 6);
		ltoa_mode(part_size[source_drive], d_backup[PARTSIZE].spec, TRUE, 6);

		if (part_type[source_drive])
			strcpy(d_backup[PARTTYPE].spec, "   yes");
		else
			strcpy(d_backup[PARTTYPE].spec, "    no");

		how_many = (WORD) ((part_size[source_drive] + 1) / ((sides * 800) - 1));
		if (((part_size[source_drive] + 1) % ((sides * 800) - 1)) != 0)
			how_many++;

		ltoa_mode((LONG) how_many, d_backup[PARTDSKS].spec, TRUE, 6);

		/* show current stats */
		objc_draw(d_backup, BACKBOX, MAX_DEPTH, x, y, w, h);

		leaf = form_do(d_backup, 0, 0L, 0L);

		if (leaf == BCKCAN) {
			form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h);
			return(FALSE);
		}

		/* figure out what he said do */
		sides	 = (d_backup[SIDES1].state & SELECTED ? 1 : 2);
		format	 = (d_backup[FORMYES].state & SELECTED ? TRUE : FALSE);
		dest_drive = (d_backup[BFLOPA].state & SELECTED ? 0 : 1);

		for (i = 0; i < MAX_HD; i++)
			if (d_backup[hd_drv[i]].state & SELECTED) {
				source_drive = i;
				break;
			}
	}
	while (leaf != BACKUPOK);
	form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h);

	/* setup the dialog for the copy */
	ltoa_mode((LONG) how_many, d_newdisk[NEWOF].spec, TRUE, 4);
	d_newdisk[NEWPART].spec[0]  = 'C' + source_drive;
	d_newdisk[NEWDRIVE].spec[0] = 'A' + dest_drive;

	/* fix the format button in the new disk dialog bush */
	if (format)
		d_newdisk[NEWFORM].state |= SELECTED;
	else
		d_newdisk[NEWFORM].state &= ~SELECTED;

	back_serial = Random();

	return(TRUE);
}

void
backup_disk()
{
	register WORD	 hsecs, secs = 1, c_sec;
	register BYTE	*buff;
		    WORD	 leaf, x, y, w, h, err_class, err_code, err_flag;
		    char	 string[200];
		    BYTE	 errs[8];
		    LONG	 err_sec, pass_start;

	start_sec = part_start[source_drive];
	last_sec	= start_sec + part_size[source_drive] - 1;
	which_disk = 0;

	while (which_disk < how_many) {  /* more to write? */

		/* save the starting sector of this floppy. */
		pass_start = start_sec;

		/* loop point if there is a floppy i/o error */
back_retry:

		/* run the dialog asking for a new disk */
		ltoa_mode((LONG) which_disk + 1, d_newdisk[NEWNUM].spec, TRUE, 4);
		leaf = handle_dialog(d_newdisk);

		if (leaf == NEWCAN)
			break;		/* oh well.... maybe next time */

		if (d_newdisk[NEWFORM].state & SELECTED) {
			/*
			 * Like wow man, they want us to to do the twist.
			 *
			 * First fill in the format variables.
			 */
			thedisk  = dest_drive;
			dblsided = (sides == 2 ? -1 : 0);
			sectoroffset = 10;	/* sectors 11 to 20, not 1 to 10 */
			leaf = 0; /* quit/continue flag */

			show_msg("Twisting the disk.");

			do {
				Supexec(twister);
				if (badflag) {
					show_msg(0L);
					if (leaf = (form_alert(1, "[3][There was an error formatting the disk.|Insert new disk to try again.][Again|Punt]") == 2))
						break;
				}
			}
			while(badflag);

			if (leaf)
				break;	/* they don't wanna play anymore */
		}

		if (which_disk == 0) {	/* first disk, also gets partition sector */
			hd_read(0L, 1, hd_buff + 512, 0);
			end_sec = start_sec + (800 * sides) - 2;
			buff = hd_buff + 1024;
			hsecs = BUF_SECS - 2;
		}
		else {
			end_sec = start_sec + (800 * sides) - 1;
			buff = hd_buff + 512;
			hsecs = BUF_SECS - 1;
		}

		/* stop the backup at the end of the disk */
		if (end_sec >= last_sec)
			end_sec = last_sec - 2;

		secs  = BUF_SECS;
		c_sec = 0;

		make_boot();

#if DEBUG
	sprintf(string, "start sec = %ld end sec = %ld", start_sec, end_sec);
	v_gtext(VDIhandle, 8, 15, string);
#endif

		while (start_sec < end_sec) {
			if (err_flag = hd_read(start_sec, hsecs, buff, 0)) {
				/* read error, find out what sector */
				hd_sense(0, &errs[8], 4);

				err_code	= errs[0] & 0x0f;
				err_class = errs[0] & 0x30 >> 4;
				err_sec  = errs[1] & 0x1f << 16;
				err_sec |= errs[2] << 8;
				err_sec |= errs[3];
				if (errs[0] & 0x80)
					sprintf(string, "[1][Hard disk read error.|Error sector %ld|I/O sector %ld|error class %d code %d flag %d|Switching to slow i/o.][Continue]",
						   err_sec, start_sec, err_class, err_code, err_flag);
				else
					sprintf(string, "[1][Hard disk read error.|I/O sector %ld|error class %d code %d flag %d|Switching to slow i/o.][Continue]",
						   start_sec, err_class, err_code, err_flag);
				show_msg(0L);
				form_alert(1, string);

				slow_read(start_sec, hsecs, buff);
			}

			show_msg("Writing backup to floppy.");

			if (floprw(WRITE, hd_buff, c_sec, dest_drive, secs)) {
				/* 
				 * If a floppy error occurs, ask for a new disk
				 * and give the user a chance to format it.	Then
				 * start this backup pass over.  (ie. we don't
				 * allow ANY errors on floppy writes.)
				 */
				sprintf(string, "[1][Floppy write error.|Sector %d|Insert new, good floppy.][Continue]");
				show_msg(0L);
				form_alert(1, string);
				start_sec = pass_start;
				goto back_retry;	/* yeah, it's a goto.  Wanna make something out of it? */
			}

			/* update the hard disk and floppy sector counters */
			start_sec += hsecs;
			c_sec += secs;
			buff = hd_buff;

			if (start_sec + BUF_SECS < end_sec)
				secs = hsecs = BUF_SECS;
			else /* partial buffer read/write for last bit */
				secs = hsecs = end_sec - start_sec;
		}  /* more room on floppy */
		which_disk++;
	} /* more room on hard disk */
}

void
get_flopinfo(where)
BOOT_PTR where;
{
	BOOT_PTR what = (BOOT_PTR) hd_buff;

	/* read the boot sector and the partition sector from the floppy */
	floprw(READ, hd_buff, 0, source_drive, 2);

	*where = *what;
}

void
restore_dialog()
{
	register int i, leaf;
	WORD x, y, w, h;
	static WORD hd_drv[] = {RPARTC, RPARTD, RPARTE, RPARTF};

	/* find out where they are restoring from */
	handle_dialog(d_whichdrv);
	if (d_whichdrv[WHDRVA].state & SELECTED)
		source_drive = 0;	/* floppy A or B */
	else
		source_drive = 1;

	d_getfirst[GETDRIVE].spec[0] = 'A' + source_drive;

	do {
		handle_dialog(d_getfirst);
		get_flopinfo(&backup_data);
	}
	while (backup_data.which_disk != 0);
	
	curr_data = backup_data;

	/* fill in the backdisk and restore dialogs */
again:
	dest_drive = -1;
	/* which hd parts will it fit on? */
	for (i = 0; i < MAX_HD; i++) {  /* where will it fit */
		d_restore[hd_drv[i]].state |= DISABLED;
		if (part_valid[i] && part_size[i] >= backup_data.part_size) {
			d_restore[hd_drv[i]].state &= ~DISABLED;
			d_restore[hd_drv[i]].state &= ~SELECTED;
			if (dest_drive < 0) {
				d_restore[hd_drv[i]].state |= SELECTED;
				dest_drive = i;
			}
		}
	}

	dest_drive = 0; /* clean up some of the mess */
	/* setup the backup disk part info */
	ltoa_mode(backup_data.part_size,  d_restore[BCKSIZE].spec, TRUE, 6);
	ltoa_mode(backup_data.part_start, d_restore[BCKSTRT].spec, TRUE, 6);

	if (backup_data.part_type)
		strcpy(d_restore[BCKGEMD].spec, "   yes");
	else
		strcpy(d_restore[BCKGEMD].spec, "    no");

	ltoa_mode((long) backup_data.total_disk, d_restore[BCKDSKS].spec, TRUE, 6);

	setmem(d_restore[BCKDRV].spec, 6, 32);
	d_restore[BCKDRV].spec[5] = 'C' + backup_data.part_drive;

	/* set the restore floppy in the backdisk dialog */
	d_backdisk[BACKDRIV].spec[0] = 'A' + source_drive;
	ltoa_mode((long) backup_data.total_disk, d_backdisk[BACKOF].spec, TRUE, 4);

	/* fix the ok button */
	d_restore[RESTOK].state &= ~SELECTED;

	/* and initially don't restore the partition sector */
	d_restore[RESTPART].state &= ~SELECTED;

	/* now draw the sucker (looks funny when you forget this) */
	form_center(d_restore, &x, &y, &w, &h);
	form_dial(FMD_START, 0, 0, 0, 0, x, y, w, h);
	objc_draw(d_restore, ROOT, MAX_DEPTH, x-1, y-1, w+2, h+2);

	do { /* now loop while till idiot figures out what to do */
		/* display info for current partition */
		ltoa_mode(part_start[dest_drive], d_restore[RCURSTRT].spec, TRUE, 6);
		ltoa_mode(part_size[dest_drive], d_restore[RCURSIZE].spec, TRUE, 6);

		if (part_type[dest_drive])
			strcpy(d_restore[RCURGEMD].spec, "   yes");
		else
			strcpy(d_restore[RCURGEMD].spec, "    no");

		/* show current stats */
		objc_draw(d_restore, RESTBOX, MAX_DEPTH, x, y, w, h);

		leaf = form_do(d_restore, 0, 0L, 0L);

		if (leaf == RESTCAN) {
			form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h);
			d_restore[RESTCAN].state &= ~SELECTED;
			return(FALSE);
		}

		/* see if the user is going to do something foolish now */
		if (leaf == RESTPART) {
			form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h);
			leaf = handle_dialog(d_copout);
			if (leaf == COPREST) { /* brave or foolish person */
				hd_write(0L, 1, hd_buff + 512, 0);
				get_hdinfo();
				get_flopinfo(&backup_data);
			}
			goto again;	/* and start over */
		}

		for (i = 0; i < MAX_HD; i++)
			if (d_restore[hd_drv[i]].state & SELECTED) {
				dest_drive = i;
				break;
			}
	}
	while (leaf != RESTOK);

	form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h);

	for (i = 0; i < MAX_HD; i++)
		if (d_restore[hd_drv[i]].state & SELECTED) {
			dest_drive = i;
			break;
		}
	
	if (i == MAX_HD)
		return(FALSE);

	/* fill in the backup disk dialog */
	d_backdisk[BACKPART].spec[0] = 'C' + dest_drive;

	return(TRUE);
}

void
restore_hard()
{
	register WORD	 secs, c_sec;
		    WORD	 leaf, x, y, w, h, err_class, err_code, err_flag;
		    char	 string[200];
		    BYTE	 errs[8];
		    LONG	 err_sec;


	start_sec = -1;	/* just to make the while true */
	last_sec	= part_start[dest_drive] + backup_data.part_size - 1;

	restore_flag = TRUE;

	which_disk = 0;
	how_many = backup_data.total_disk;

	get_flopinfo(&curr_data);

	while (which_disk < how_many) {  /* more to write? */

		while (curr_data.which_disk != which_disk) {
			/* run the dialog asking for a new disk */
			ltoa_mode((LONG) which_disk + 1, d_backdisk[BACKNUM].spec, TRUE, 4);
			leaf = handle_dialog(d_backdisk);

			if (leaf == BACKCAN)
				return;		 /* oh well.... maybe next time */

			get_flopinfo(&curr_data);

			/* check if this is the correct disk series */
			if (curr_data.serial != backup_data.serial)
				curr_data.which_disk = -1;  /* force a requery */
		}

		sides = curr_data.sides;

		start_sec = curr_data.start_sec + part_start[dest_drive];
		end_sec	= curr_data.end_sec   + part_start[dest_drive];

		if (which_disk == 0)
			c_sec = 2;	/* skip boot and partition */
		else
			c_sec = 1;	/* just skip boot */

		secs  = BUF_SECS;

#if DEBUG
	sprintf(string, "start sec = %ld end sec = %ld", start_sec, end_sec);
	v_gtext(VDIhandle, 8, 15, string);
#endif

		while (start_sec < end_sec && secs) {
			show_msg("Read backup from floppy.");

			if (floprw(READ, hd_buff, c_sec, source_drive, secs)) {
				sprintf(string, "[1][Floppy read error.|Sector %d][Continue]");
				show_msg(0L);
				form_alert(1, string);

				slow_flopread(hd_buff, c_sec, source_drive, secs);
			}

			if (err_flag = hd_write(start_sec, secs, hd_buff, 0)) {
				/* read error, find out what sector */
				hd_sense(0, &errs[8], 4);

				err_code	= errs[0] & 0x0f;
				err_class = errs[0] & 0x30 >> 4;
				err_sec  = errs[1] & 0x1f << 16;
				err_sec |= errs[2] << 8;
				err_sec |= errs[3];
				if (errs[0] & 0x80)
					sprintf(string, "[1][Hard disk write error.|Error sector %ld|I/O sector %ld|error class %d code %d flag %d|Switching to slow i/o.][Continue]",
						   err_sec, start_sec, err_class, err_code, err_flag);
				else
					sprintf(string, "[1][Hard disk write error.|I/O sector %ld|error class %d code %d flag %d|Switching to slow i/o.][Continue]",
						   start_sec, err_class, err_code, err_flag);
				show_msg(0L);
				form_alert(1, string);

				slow_write(start_sec, secs, hd_buff);
			}

			/* update the hard disk and floppy sector counters */
			start_sec += secs;
			c_sec	+= secs;

			if (start_sec + BUF_SECS < end_sec)
				secs = BUF_SECS;
			else /* partial buffer read/write for last bit */
				secs = end_sec - start_sec - 1;
		}  /* more sectors to copy to hd from this floppy */
		which_disk++;
	} /* more floppies to restore to hd */
}

go_for_it()
/* 
 * bring the first dialog bush and ask the user if he wants to crash his
 * hard disk or his floppy.  (Oops..... That should be backup instead of
 * crash.  Sorry for the scare.)								
 */
{
	if (handle_dialog(d_direct) == DIRQUIT)
		return(FALSE);

	if (d_direct[HDTOFLOP].state & SELECTED) {
		if (back_dialog())
			backup_disk();
	}
	else {
		if (restore_dialog())
			restore_hard();
	}

	return(TRUE);
}

/* routine to reboot the ST.	Must be run in super mode */

extern reboot(), exit();

asm {
exit:		/* just to fool the linker */
reboot:	clr.l	0x420		; memvalid
		clr.l	0x4da		; memval2
		movea.l	0, A7		; get startup stack
		movea.l	4, A0		; get startup PC
		jmp		(A0) 		; kaboom!
}

void
main()
{
	init_gem();

	hd_buff = (UBYTE *) Malloc(BUF_SIZE); 
	buffer  = 		Malloc(TRACK_SIZE);

	if (hd_buff == NULL || buffer == NULL)
		form_alert(1, "[3][Unable to allocate buffers.][Abort]");
	else {
		/* go get the drive partitioning info */
		get_hdinfo();

		/* while there is something to do ... */
		while(go_for_it());
	}

	/* if a restore has been done we must force a reboot so GEMDOS
	   can rebuild the drive directory tree.				*/
	if (restore_flag) {
		handle_dialog(d_reboot);
		Supexec(reboot);
		/* never reach here! */
	}

	v_clsvwk(VDIhandle);

	if (buffer)
		Mfree(buffer);
	if (hd_buff)
		Mfree(hd_buff);

	/* tell GEM bye, bye */
	v_clsvwk(VDIhandle);
	appl_exit();

	_exit(0);
}



