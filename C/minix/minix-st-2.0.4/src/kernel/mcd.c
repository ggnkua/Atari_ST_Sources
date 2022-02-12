/* This file contains the driver for a Mitsumi cdrom controller.
 *
 * The file contains one entry point:
 *
 *   mcd_task:		main entry when system is brought up
 *
 *  Mar 30 1995			Author: Michel R. Prevenier 
 */


#include "kernel.h"
#include "driver.h"
#include "drvlib.h"
#include <minix/cdrom.h>
#include <sys/ioctl.h>

#if ENABLE_MITSUMI_CDROM

#define MCD_DEBUG		0	/* debug level */

/* Default IRQ. */
#define MCD_IRQ			10

/* Default I/O ports (offset from base address */
#define MCD_IO_BASE_ADDRESS	0x300	
#define MCD_DATA_PORT		(mcd_io_base+0)
#define MCD_FLAG_PORT		(mcd_io_base+1)
#define MCD_CONTROL_PORT	(mcd_io_base+2)


/* Miscellaneous constants. */
#define MCD_SKIP		150     /* Skip first 150 blocks on cdrom */
#define MCD_BLOCK_SIZE		2048    /* Block size in cooked mode */
#define MCD_BLOCK_SHIFT		11	/* for division */
#define MCD_BLOCK_MASK		2047	/* and remainder */
#define	BYTES_PER_SECTOR	2048	/* Nr. of bytes in a sector */
#define SECTORS_PER_SECOND	75	/* Nr. of sectors in a second */
#define SECONDS_PER_MINUTE	60      /* You never know, things change :-) */ 
#define MCD_RETRIES		2	/* Number of retries for a command */
#define REPLY_DELAY		5000	/* Count to wait for a reply */
#define MAX_TRACKS		104	/* Maximum nr. of tracks */
#define LEAD_OUT		0xAA	/* Lead out track is always 0xAA */
#define SUB_PER_DRIVE	(NR_PARTITIONS * NR_PARTITIONS)


/* Drive commands */
#define	MCD_GET_VOL_INFO	0x10	/* Read volume information */
#define MCD_GET_Q_CHANNEL	0x20	/* Read q-channel information */
#define MCD_GET_STATUS		0x40	/* Read status of drive	*/
#define MCD_SET_MODE		0x50	/* Set transmission mode */
#define MCD_RESET		0x60	/* Reset controller */
#define MCD_STOP_AUDIO		0x70	/* Stop audio playing */
#define MCD_SET_DRIVE_MODE	0xA0	/* Set drive mode */
#define MCD_READ_FROM_TO	0xC0	/* Read from .. to .. */
#define MCD_GET_VERSION		0xDC	/* Get version number */
#define MCD_STOP		0xF0	/* Stop everything */
#define MCD_EJECT		0xF6	/* Eject cd */
#define MCD_PICKLE		0x04	/* Needed for newer drive models */


/* Command bits for MCD_SET_MODE command */
#define MCD_MUTE_DATA		0x01	/* 1 = Don't play back data as audio */
#define MCD_GET_TOC		0x04	/* 0 = Get toc on next GET_Q_CHANNEL */
#define MCD_ECC_MODE		0x20	/* 0 = Use secondary ecc */
#define MCD_DATALENGTH		0x40	/* 0 = Read user data only */
#define MCD_COOKED		(MCD_MUTE_DATA)
#define MCD_TOC			(MCD_MUTE_DATA | MCD_GET_TOC)	


/* Status bits */
#define MCD_CMD_ERROR		0x01	/* Command error */
#define MCD_AUDIO_BUSY		0x02	/* Audio disk is playing */
#define MCD_READ_ERROR		0x04	/* Read error */
#define MCD_AUDIO_DISK		0x08	/* Audio disk is in */
#define MCD_SPINNING		0x10	/* Motor is spinning */
#define MCD_DISK_CHANGED	0x20	/* Disk has been removed or changed */
#define MCD_DISK_IN		0x40	/* Disk is in */
#define MCD_DOOR_OPEN		0x80	/* Door is open */

/* Flag bits */
#define MCD_DATA_AVAILABLE	0x02	/* Data available */
#define MCD_BUSY		0x04	/* Drive is busy */

/* Function prototypes */
FORWARD _PROTOTYPE ( int mcd_init, (void));
FORWARD _PROTOTYPE ( int c_handler, (int irq));
FORWARD _PROTOTYPE ( int mcd_play_mss, (struct cd_play_mss));
FORWARD _PROTOTYPE ( int mcd_play_tracks, (struct cd_play_track tracks));
FORWARD _PROTOTYPE ( int mcd_stop, (void));
FORWARD _PROTOTYPE ( int mcd_eject, (void));
FORWARD _PROTOTYPE ( int mcd_pause, (void));
FORWARD _PROTOTYPE ( int mcd_resume, (void));
FORWARD _PROTOTYPE ( u8_t bin2bcd, (u8_t b));
FORWARD _PROTOTYPE ( void bcd2bin, (u8_t *bcd));
FORWARD _PROTOTYPE ( long mss2block, (u8_t *mss));
FORWARD _PROTOTYPE ( void block2mss, (long block, u8_t *mss));
FORWARD _PROTOTYPE ( int mcd_get_reply, (u8_t *reply, int delay));
FORWARD _PROTOTYPE ( int mcd_get_status, (int f));
FORWARD _PROTOTYPE ( int mcd_ready, (int delay));
FORWARD _PROTOTYPE ( int mcd_data_ready, (int delay));
FORWARD _PROTOTYPE ( int mcd_set_mode, (int mode));
FORWARD _PROTOTYPE ( int mcd_send_command, (int command));
FORWARD _PROTOTYPE ( int mcd_get_disk_info, (void));
FORWARD _PROTOTYPE ( int mcd_read_q_channel, (struct cd_toc_entry *qc));
FORWARD _PROTOTYPE ( int mcd_read_toc, (void));
FORWARD _PROTOTYPE ( int ioctl_read_toc, (message *m_ptr));
FORWARD _PROTOTYPE ( int ioctl_disk_info, (message *m_ptr));
FORWARD _PROTOTYPE ( int ioctl_read_sub, (message *m_ptr));
FORWARD _PROTOTYPE ( int ioctl_disk_info, (message *m_ptr));
FORWARD _PROTOTYPE ( int ioctl_play_mss, (message *m_ptr));
FORWARD _PROTOTYPE ( int ioctl_play_ti, (message *m_ptr));
FORWARD _PROTOTYPE ( int mcd_open, (struct driver *dp, message *m_ptr));
FORWARD _PROTOTYPE ( int mcd_close, (struct driver *dp, message *m_ptr));
FORWARD _PROTOTYPE ( int mcd_ioctl, (struct driver *dp, message *m_ptr));
FORWARD _PROTOTYPE ( char *mcd_name, (void));
FORWARD _PROTOTYPE ( struct device *mcd_prepare, (int dev));
FORWARD _PROTOTYPE ( int mcd_schedule, (int proc_nr, struct iorequest_s *iop));
FORWARD _PROTOTYPE ( int mcd_finish, (void));
FORWARD _PROTOTYPE ( void mcd_geometry, (struct partition *entry));


/* Flags displaying current status of cdrom, used with the McdStatus variable */
#define TOC_UPTODATE   0x001     /* Table of contents is up to date */
#define INFO_UPTODATE  0x002     /* Disk info is up to date */
#define DISK_CHANGED   0x004     /* Disk has changed */
#define AUDIO_PLAYING  0x008     /* Cdrom is playing audio */
#define AUDIO_PAUSED   0x010     /* Cdrom is paused (only audio) */
#define AUDIO_DISK     0x020     /* Disk contains audio */
#define DISK_ERROR     0x040     /* An error occured */
#define NO_DISK        0x080     /* No disk in device */

/* Entry points to this driver. */
PRIVATE struct driver mcd_dtab = 
{
#if __minix_vmd
  NULL,		/* No private request buffer */
#endif
  mcd_name,	/* Current device's name */
  mcd_open,	/* Open request read table of contents */
  mcd_close,	/* Release device */
  mcd_ioctl,	/* Do cdrom ioctls */
  mcd_prepare,	/* Prepare for I/O */
  mcd_schedule,	/* Precompute blocks */
  mcd_finish,	/* Do the I/O */
  nop_cleanup,	/* No cleanup to do */
  mcd_geometry	/* Tell geometry */
};


PRIVATE struct trans 
{
  struct iorequest_s *tr_iop;	/* Belongs to this I/O request */
  unsigned long tr_pos;		/* Byte position to transfer from */
  int tr_count;			/* Byte count */
  phys_bytes tr_phys;		/* User physical address */
} mcd_trans[NR_IOREQS];


/* Globals */
#if __minix_vmd
PRIVATE int mcd_tasknr = ANY;
#endif
PRIVATE int mcd_avail;			/* Set if Mitsumi device exists */
PRIVATE int mcd_irq;			/* Interrupt request line */
PRIVATE int mcd_io_base;		/* I/O base register */
PRIVATE struct device *mcd_dv;		/* Active partition */
PRIVATE struct trans *mcd_tp;		/* Pointer to add transfer requests */
PRIVATE unsigned mcd_count;		/* Number of bytes to transfer */
PRIVATE unsigned long mcd_nextpos;	/* Next consecutive position on disk */
PRIVATE struct device mcd_part[DEV_PER_DRIVE];
					/* Primary partitions: cd[0-4] */
PRIVATE struct device mcd_subpart[SUB_PER_DRIVE];
					/* Subpartitions: cd[1-4][a-d] */
PRIVATE int mcd_open_ct;		/* in-use count */
PRIVATE int McdStatus = NO_DISK;        /* A new (or no) disk is inserted */ 
PRIVATE struct cd_play_mss PlayMss;     /* Keep track of where we are if we
                                           pause, used by resume */ 
PRIVATE struct cd_disk_info DiskInfo;   /* Contains toc header */  
PRIVATE struct cd_toc_entry Toc[MAX_TRACKS];  /* Buffer for toc */



/*=========================================================================*
 *				mcd_task				   *
 *=========================================================================*/
PUBLIC void mcd_task()
{
  long v;
  static char var[] = "MCD";
  static char fmt[] = "x:d";

#if __minix_vmd
  mcd_tasknr = proc_number(proc_ptr);
#endif

  /* Configure I/O base and IRQ. */
  v = MCD_IO_BASE_ADDRESS;
  (void) env_parse(var, fmt, 0, &v, 0x000L, 0x3FFL);
  mcd_io_base = v;

  v = MCD_IRQ;
  (void) env_parse(var, fmt, 1, &v, 0L, (long) NR_IRQ_VECTORS - 1);
  mcd_irq = v;

  driver_task(&mcd_dtab);       /* Start driver task for cdrom */
}


/*=========================================================================*
 *				mcd_open				   *	
 *=========================================================================*/
PRIVATE int mcd_open(dp, m_ptr)
struct driver *dp;	/* pointer to this drive */
message *m_ptr;		/* OPEN */
{
  int i, status;

  if (!mcd_avail && mcd_init() != OK) return EIO;

  if (mcd_prepare(m_ptr->DEVICE) == NIL_DEV) return ENXIO;

  /* A CD-ROM is read-only by definition. */
  if (m_ptr->COUNT & W_BIT) return EACCES;

  if (mcd_open_ct == 0)
  {
    i = 20;
    for (;;) {
      if (mcd_get_status(1) == -1) return EIO;   /* set McdStatus flags */
      if (!(McdStatus & NO_DISK)) break;
      if (--i == 0) return EIO;
      milli_delay(100);
    }

    /* Try to read the table of contents of the CD currently inserted */
    if ((status = mcd_read_toc()) != OK)  
      return status;

    mcd_open_ct++;

    /* fill in size of device (= nr. of bytes on the disk) */
    mcd_part[0].dv_base = 0;
    mcd_part[0].dv_size = 
     ((((unsigned long)DiskInfo.disk_length_mss[MINUTES] * SECONDS_PER_MINUTE
      + (unsigned long)DiskInfo.disk_length_mss[SECONDS]) * SECTORS_PER_SECOND)
      + (unsigned long)DiskInfo.disk_length_mss[SECTOR]) * BYTES_PER_SECTOR; 

#if MCD_DEBUG >= 1
    printf("cd size: %lu\n", mcd_part[0].dv_size);
#endif

    /* Partition the disk. */
    partition(&mcd_dtab, 0, P_PRIMARY);
  }
  return OK;
}


/*=========================================================================*
 *				mcd_close				   *	
 *=========================================================================*/
PRIVATE int mcd_close(dp, m_ptr)
struct driver *dp;	/* pointer to this drive */
message *m_ptr;		/* CLOSE */
{
  /* One less reference to the device */

  mcd_open_ct--;
  return OK;
}


/*=========================================================================*
 *				mcd_name				   *	
 *=========================================================================*/
PRIVATE char *mcd_name()
{
  /* Return a name for the device */

  return "cd0";
}


/*=========================================================================*
 *				mcd_ioctl				   *	
 *=========================================================================*/
PRIVATE int mcd_ioctl(dp, m_ptr)
struct driver *dp;	/* pointer to the drive */
message *m_ptr;		/* contains ioctl command */
{
  /* Perform the ioctl request */

  int status;

  if (mcd_prepare(m_ptr->DEVICE) == NIL_DEV) return(ENXIO);

  mcd_get_status(1);	/* Update the status flags */
  if ((McdStatus & NO_DISK) && m_ptr->REQUEST != CDIOEJECT)
    return EIO;

  switch(m_ptr->REQUEST)
  {
    case CDIOPLAYMSS:     status = ioctl_play_mss(m_ptr);break;
    case CDIOPLAYTI:      status = ioctl_play_ti(m_ptr);break;
    case CDIOREADTOCHDR:  status = ioctl_disk_info(m_ptr);break;
    case CDIOREADTOC:     status = ioctl_read_toc(m_ptr);break;
    case CDIOREADSUBCH:   status = ioctl_read_sub(m_ptr);break;
    case CDIOSTOP:        status = mcd_stop();break;
    case CDIOPAUSE:       status = mcd_pause();break;
    case CDIORESUME:      status = mcd_resume();break;
    case CDIOEJECT:       status = mcd_eject();break;
    default:              status = do_diocntl(dp, m_ptr);
  }
  return status;
}


/*=========================================================================*
 *				mcd_get_reply				   *	
 *=========================================================================*/
PRIVATE int mcd_get_reply(reply, delay)
u8_t *reply;		/* variable to put reply in */
int delay;		/* count to wait for the reply */
{
  /* Get a reply from the drive */

  if (mcd_ready(delay) != OK) return EIO;           /* wait for drive to 
                                                       become available */
  *reply = in_byte(MCD_DATA_PORT);	/* get the reply */
  return OK;
}


/*=========================================================================*
 *				mcd_ready				   *	
 *=========================================================================*/
PRIVATE int mcd_ready(delay)
int delay;   /* count to wait for drive to become available again */
{
  /* Wait for drive to become available */

  struct milli_state ms;

  milli_start(&ms);
  do
  {
    if (!(in_byte(MCD_FLAG_PORT) & MCD_BUSY)) return OK; /* OK, drive ready */
  } while(milli_elapsed(&ms) < delay);

  return EIO; /* Timeout */
}


/*=========================================================================*
 *				mcd_data_ready				   *	
 *=========================================================================*/
PRIVATE int mcd_data_ready(delay)
int delay;    	/* count to wait for the data */
{
  /* Wait for the drive to get the data */

  struct milli_state ms;

  milli_start(&ms);
  do
  {
    if (!(in_byte(MCD_FLAG_PORT) & 2)) return OK; /* OK, data is there */
  } while(milli_elapsed(&ms) < delay);

  return EIO;  /* Timeout */
}


/*=========================================================================*
 *				mcd_get_status				   *	
 *=========================================================================*/
PRIVATE int mcd_get_status(f)
int f; 		/* flag */
{
  /* Return status info from the drive and update the global McdStatus */

  u8_t status;

  /* If f = 1, we first send a get_status command, otherwise we just get
     the status info from the drive */ 

  if (f) out_byte(MCD_DATA_PORT, MCD_GET_STATUS);        /* Try to get status */
  if (mcd_get_reply(&status,REPLY_DELAY) != OK) return -1; 

  McdStatus &= ~(NO_DISK | DISK_CHANGED | DISK_ERROR);

  /* Fill in the McdStatus variable */
  if (status & MCD_DOOR_OPEN ||
     !(status & MCD_DISK_IN))         McdStatus = NO_DISK;  
  else if (status & MCD_DISK_CHANGED) McdStatus = DISK_CHANGED; 
  else if (status & MCD_READ_ERROR ||
           status & MCD_CMD_ERROR)    McdStatus = DISK_ERROR; 
  else 
  {
    if (status & MCD_AUDIO_DISK) 
    {
      McdStatus |= AUDIO_DISK;
      if (!(status & MCD_AUDIO_BUSY)) McdStatus &= ~(AUDIO_PLAYING); 
      else McdStatus |= AUDIO_PLAYING;
    }
  }
#if MCD_DEBUG >= 3
  printf("mcd_get_status(%d) = %02x, McdStatus = %02x\n",
	f, status, McdStatus);
#endif
  return status;	/* Return status */
}


/*=========================================================================*
 *				mcd_set_mode				   *	
 *=========================================================================*/
PRIVATE int mcd_set_mode(mode)
int mode; /* new drive mode */
{
  /* Set drive mode */

  int i;

  for (i = 0; i < MCD_RETRIES; i++)
  {
    out_byte(MCD_DATA_PORT, MCD_SET_MODE); /* Send set mode command */
    out_byte(MCD_DATA_PORT, mode);         /* Send which mode */
    if (mcd_get_status(0) != -1 &&
         !(McdStatus & DISK_ERROR)) break; 
  }
  if (i == MCD_RETRIES) return EIO;        /* Operation failed */

  return OK; /* Operation succeeded */
}


/*=========================================================================*
 *				mcd_send_command   			   *	
 *=========================================================================*/
PRIVATE int mcd_send_command(command)
int command;  	/* command to send */
{
  int i;

  for (i = 0; i < MCD_RETRIES; i++)
  {
    out_byte(MCD_DATA_PORT, command);      /* send command */
    if (mcd_get_status(0) != -1 && 
         !(McdStatus & DISK_ERROR)) break; 
  }
  if (i == MCD_RETRIES) return EIO;        /* operation failed */

  return OK;
}


/*=========================================================================*
 *				mcd_init				   *	
 *=========================================================================*/
PRIVATE int mcd_init()
{
  /* Initialize the drive and get the version bytes, this is done only
     once when the system gets up. We can't use mcd_ready because
     the clock task is not available yet.
   */

  u8_t version[3];
  int i;
  u32_t n;
  struct milli_state ms;

  /* Reset the flag port and remove all pending data, if we do
   * not do this properly the drive won't cooperate.
   */
  out_byte(MCD_FLAG_PORT, 0x00); 	
  for (n = 0; n < 1000000; n++)
    (void) in_byte(MCD_FLAG_PORT);

  /* Now see if the drive will report its status */
  if (mcd_get_status(1) == -1)
  {
    /* Too bad, drive will not listen */
    printf("%s: init failed, no Mitsumi cdrom present\n", mcd_name());
    return -1; 
  }

  /* Find out drive version */
  out_byte(MCD_DATA_PORT, MCD_GET_VERSION);
  milli_start(&ms);
  for (i = 0; i < 3; i++)
  {
    while (in_byte(MCD_FLAG_PORT) & MCD_BUSY)
    {
      if (milli_elapsed(&ms) >= 1000) 
      {
	printf("%s: can't get version of Mitsumi cdrom\n", mcd_name());
	return -1;
      }
    }
    version[i] = in_byte(MCD_DATA_PORT);
  }
 
  if (version[1] == 'D')
    printf("%s: Mitsumi FX001D CD-ROM\n", mcd_name());
  else 
    printf("%s: Mitsumi CD-ROM version %02x%02x%02x\n", mcd_name(), 
            version[0], version[1], version[2]);

  /* Newer drive models need this */
  if (version[1] >= 4) out_byte(MCD_CONTROL_PORT, MCD_PICKLE);

  /* Register interrupt vector and enable interrupt 
   * currently the interrupt is not used because
   * the controller isn't set up to do dma.  XXX
   */
  put_irq_handler(mcd_irq, c_handler);
  enable_irq(mcd_irq);

  mcd_avail = 1;
  return OK;
}


/*=========================================================================*
 *				c_handler 	  			   *	
 *=========================================================================*/
PRIVATE int c_handler(irq)
int irq; 	/* irq number */
{
  /* The interrupt handler, I never got an interrupt but its here just
   * in case...
   */

  /* Send interrupt message to cdrom task */
#if XXX
#if __minix_vmd
  interrupt(mcd_tasknr);
#else
  interrupt(CDROM);
#endif
#endif

  return 1;
}


/*=========================================================================*
 *				mcd_play_mss	  			   *	
 *=========================================================================*/
PRIVATE int mcd_play_mss(mss)
struct cd_play_mss mss;  /* from where to play minute:second.sector */
{
  /* Command the drive to start playing at min:sec.sector */

  int i;

#if MCD_DEBUG >= 1
  printf("Play_mss: begin: %02d:%02d.%02d  end: %02d:%02d.%02d\n",
          mss.begin_mss[MINUTES], mss.begin_mss[SECONDS],
          mss.begin_mss[SECTOR], mss.end_mss[MINUTES], 
          mss.end_mss[SECONDS], mss.end_mss[SECTOR]); 
#endif

  for (i=0; i < MCD_RETRIES; i++)     /* Try it more than once */
  {
    lock();        /* No interrupts when we issue this command */

    /* Send command with paramters to drive */
    out_byte(MCD_DATA_PORT, MCD_READ_FROM_TO);
    out_byte(MCD_DATA_PORT, bin2bcd(mss.begin_mss[MINUTES]));
    out_byte(MCD_DATA_PORT, bin2bcd(mss.begin_mss[SECONDS]));
    out_byte(MCD_DATA_PORT, bin2bcd(mss.begin_mss[SECTOR]));
    out_byte(MCD_DATA_PORT, bin2bcd(mss.end_mss[MINUTES]));
    out_byte(MCD_DATA_PORT, bin2bcd(mss.end_mss[SECONDS]));
    out_byte(MCD_DATA_PORT, bin2bcd(mss.end_mss[SECTOR]));

    unlock();	   /* Enable interrupts again */

    mcd_get_status(0);                    /* See if all went well */
    if (McdStatus & AUDIO_PLAYING) break; /* Ok, we're playing */
  }

  if (i == MCD_RETRIES) return EIO;       /* Command failed */

  /* keep in mind where we going in case of a future resume */
  PlayMss.end_mss[MINUTES] = mss.end_mss[MINUTES];
  PlayMss.end_mss[SECONDS] = mss.end_mss[SECONDS];
  PlayMss.end_mss[SECTOR] = mss.end_mss[SECTOR];

  McdStatus &= ~(AUDIO_PAUSED);

  return(OK);
}


/*=========================================================================*
 *				mcd_play_tracks	  			   *	
 *=========================================================================*/
PRIVATE int mcd_play_tracks(tracks)
struct cd_play_track tracks;     /* which tracks to play */
{
  /* Command the drive to play tracks */
  
  int i, err;
  struct cd_play_mss mss;

#if MCD_DEBUG >= 1
  printf("Play tracks: begin: %02d end: %02d\n",
           tracks.begin_track, tracks.end_track);
#endif

  /* First read the table of contents */
  if ((err = mcd_read_toc()) != OK) return err; 
 
  /* Check if parameters are valid */
  if (tracks.begin_track < DiskInfo.first_track ||
      tracks.end_track > DiskInfo.last_track ||
      tracks.begin_track > tracks.end_track)
    return EINVAL;


  /* Convert the track numbers to min:sec.sector */
  for (i=0; i<3; i++)
  {
    mss.begin_mss[i] = Toc[tracks.begin_track].position_mss[i]; 
    mss.end_mss[i] = Toc[tracks.end_track+1].position_mss[i]; 
  }

  return(mcd_play_mss(mss));     /* Start playing */
}


/*=========================================================================*
 *				mcd_get_disk_info			   *	
 *=========================================================================*/
PRIVATE int mcd_get_disk_info()
{
  /* Get disk info */

  int i, err;

  if (McdStatus & INFO_UPTODATE) return OK; /* No need to read info again */

  /* Issue the get volume info command */
  if ((err = mcd_send_command(MCD_GET_VOL_INFO)) != OK) return err;

  /* Fill global DiskInfo */
  for (i=0; i < sizeof(DiskInfo); i++) 
  {
    if ((err = mcd_get_reply((u8_t *)(&DiskInfo) + i, REPLY_DELAY)) !=OK)
      return err;
    bcd2bin((u8_t *)(&DiskInfo) + i);  
  }

#if MCD_DEBUG >= 1
  printf("Mitsumi disk info: first: %d last: %d first %02d:%02d.%02d length: %02d:%02d.%02d\n",
      DiskInfo.first_track,
      DiskInfo.last_track,
      DiskInfo.first_track_mss[MINUTES],
      DiskInfo.first_track_mss[SECONDS],
      DiskInfo.first_track_mss[SECTOR],
      DiskInfo.disk_length_mss[MINUTES],	
      DiskInfo.disk_length_mss[SECONDS],	
      DiskInfo.disk_length_mss[SECTOR]);	
#endif

  /* Update global status info */
  McdStatus |= INFO_UPTODATE; /* toc header has been read */
  McdStatus &= ~TOC_UPTODATE; /* toc has not been read yet */

  return OK;
}



/*=========================================================================*
 *				mcd_read_q_channel 			   *	
 *=========================================================================*/
PRIVATE int mcd_read_q_channel(qc)
struct cd_toc_entry *qc;  /* struct to return q-channel info in */
{
  /* Read the qchannel info, if we we're already playing this returns
   * the relative position and the absolute position of where we are
   * in min:sec.sector. If we're not playing, this returns an entry
   * from the table of contents
   */
 
  int i, err; 

  /* Issue the command */
  if ((err = mcd_send_command(MCD_GET_Q_CHANNEL)) != OK) return err;

  /* Read the info */
  for (i=0; i < sizeof(struct cd_toc_entry); i++)
  {
    /* Return error on timeout */
    if ((err = mcd_get_reply((u8_t *)qc + i, REPLY_DELAY)) != OK) 
      return err;

    bcd2bin((u8_t *)qc + i);  /* Convert value to binary */
  }
 
#if MCD_DEBUG >= 2
  printf("qchannel info: ctl_addr: %d track: %d index: %d length %02d:%02d.%02d pos: %02d:%02d.%02d\n",
      qc->control_address,
      qc->track_nr,
      qc->index_nr,
      qc->track_time_mss[MINUTES],	
      qc->track_time_mss[SECONDS],	
      qc->track_time_mss[SECTOR],
      qc->position_mss[MINUTES],	
      qc->position_mss[SECONDS],	
      qc->position_mss[SECTOR]);
#endif

  return OK;  /* All done */
}


/*=========================================================================*
 *				mcd_read_toc	 			   *	
 *=========================================================================*/
PRIVATE int mcd_read_toc()
{
  /* Read the table of contents (TOC) */

  struct cd_toc_entry q_info;
  int current_track, current_index;
  int err,i;


  if (McdStatus & TOC_UPTODATE) return OK; /* No need to read toc again */
	
  /* Clear toc table */
  for (i = 0; i < MAX_TRACKS; i++) Toc[i].index_nr = 0; 		

  /* Read disk info */
  if ((err = mcd_get_disk_info()) != OK) return err;

  /* Calculate track to start with */ 
  current_track = DiskInfo.last_track - DiskInfo.first_track + 1;

  /* Set read toc mode */
  if ((err = mcd_set_mode(MCD_TOC)) != OK) return err;

  /* Read the complete TOC, on every read-q-channel command we get a random
   * TOC entry depending on how far we are in the q-channel, collect entries
   * as long as we don't have the complete TOC. There's a limit of 600 here,
   * if we don't have the complete TOC after 600 reads we quit with an error
   */
  for (i = 0; (i < 600 && current_track > 0); i++)
  {
    /* Try to read a TOC entry */
    if ((err = mcd_read_q_channel(&q_info)) != OK) break;	

    /* Is this a valid track number and didn't we have it yet ? */
    current_index = q_info.index_nr;    
    if (current_index >= DiskInfo.first_track &&
        current_index <= DiskInfo.last_track &&
        q_info.track_nr == 0)
    {
      /* Copy entry into toc table */
      if (Toc[current_index].index_nr == 0)
      {
        Toc[current_index].control_address = q_info.control_address;
        Toc[current_index].track_nr = current_index;
        Toc[current_index].index_nr = 1;
        Toc[current_index].track_time_mss[MINUTES] = q_info.track_time_mss[MINUTES];
        Toc[current_index].track_time_mss[SECONDS] = q_info.track_time_mss[SECONDS];
        Toc[current_index].track_time_mss[SECTOR] = q_info.track_time_mss[SECTOR];
        Toc[current_index].position_mss[MINUTES] = q_info.position_mss[MINUTES];
        Toc[current_index].position_mss[SECONDS] = q_info.position_mss[SECONDS];
        Toc[current_index].position_mss[SECTOR] = q_info.position_mss[SECTOR];
        current_track--;
      }
    }
  }
  if (err) return err;	 /* Do we have all toc entries? */

  /* Fill in lead out */
  current_index = DiskInfo.last_track + 1;
  Toc[current_index].control_address = 
                                  Toc[current_index-1].control_address;
  Toc[current_index].track_nr = 0;
  Toc[current_index].index_nr = LEAD_OUT;
  Toc[current_index].position_mss[MINUTES] = DiskInfo.disk_length_mss[MINUTES];
  Toc[current_index].position_mss[SECONDS] = DiskInfo.disk_length_mss[SECONDS];
  Toc[current_index].position_mss[SECTOR] = DiskInfo.disk_length_mss[SECTOR];

  /* Return to cooked mode */
  if ((err = mcd_set_mode(MCD_COOKED)) != OK) return err; 

  /* Update global status */
  McdStatus |= TOC_UPTODATE;

#if MCD_DEBUG >= 1
  for (i = DiskInfo.first_track; i <= current_index; i++)
  {
    printf("Mitsumi toc %d: trk %d  index %d  time %02d:%02d.%02d  pos: %02d:%02d.%02d\n",
        i,
        Toc[i].track_nr,
        Toc[i].index_nr,
        Toc[i].track_time_mss[MINUTES],
        Toc[i].track_time_mss[SECONDS],
        Toc[i].track_time_mss[SECTOR],
        Toc[i].position_mss[MINUTES],
        Toc[i].position_mss[SECONDS],
        Toc[i].position_mss[SECTOR]);
  }
#endif

  return OK;
}


/*=========================================================================*
 *				mcd_stop	 			   *	
 *=========================================================================*/
PRIVATE int mcd_stop()
{
  int err;

  if ((err = mcd_send_command(MCD_STOP)) != OK ) return err;

  McdStatus &= ~(AUDIO_PAUSED);

  return OK;
} 


/*=========================================================================*
 *				mcd_eject	 			   *	
 *=========================================================================*/
PRIVATE int mcd_eject()
{
  int err;

  if ((err = mcd_send_command(MCD_EJECT)) != OK) return err;
  return OK;
} 


/*=========================================================================*
 *				mcd_pause	 			   *	
 *=========================================================================*/
PRIVATE int mcd_pause()
{
  int err;
  struct cd_toc_entry qc;

  /* We can only pause when we are playing audio */
  if (!(McdStatus & AUDIO_PLAYING)) return EINVAL;

  /* Look where we are */
  if ((err = mcd_read_q_channel(&qc)) != OK) return err;

  /* Stop playing */
  if ((err = mcd_send_command(MCD_STOP_AUDIO)) != OK) return err;

  /* Keep in mind were we have to start again */
  PlayMss.begin_mss[MINUTES] = qc.position_mss[MINUTES];
  PlayMss.begin_mss[SECONDS] = qc.position_mss[SECONDS];
  PlayMss.begin_mss[SECTOR] = qc.position_mss[SECTOR];

  /* Update McdStatus */
  McdStatus |= AUDIO_PAUSED;

#if MCD_DEBUG >= 1
  printf("Mcd_paused at: %02d:%02d.%02d\n",
      PlayMss.begin_mss[MINUTES],
      PlayMss.begin_mss[SECONDS],
      PlayMss.begin_mss[SECTOR]);
#endif

  return OK;
} 


/*=========================================================================*
 *				mcd_resume	 			   *	
 *=========================================================================*/
PRIVATE int mcd_resume()
{
  int err;

  /* we can only resume if we are in a pause state */
  if (!(McdStatus & AUDIO_PAUSED)) return EINVAL;

  /* start playing where we left off */
  if ((err = mcd_play_mss(PlayMss)) != OK) return err;

  McdStatus &= ~(AUDIO_PAUSED);

#if MCD_DEBUG >= 1
  printf("Mcd resumed at: %02d:%02d.%02d\n",
      PlayMss.begin_mss[MINUTES],
      PlayMss.begin_mss[SECONDS],
      PlayMss.begin_mss[SECTOR]);
#endif

  return OK;
} 


/*=========================================================================*
 *				ioctl_read_sub	 			   *	
 *=========================================================================*/
PRIVATE int ioctl_read_sub(m_ptr)
message *m_ptr;
{
  phys_bytes user_phys;
  struct cd_toc_entry sub;
  int err;

  /* We can only read a sub channel when we are playing audio */
  if (!(McdStatus & AUDIO_PLAYING)) return EINVAL; 

  /* Read the sub channel */
  if ((err = mcd_read_q_channel(&sub)) != OK) return err;

  /* Copy info to user */
  user_phys = numap(m_ptr->PROC_NR, (vir_bytes) m_ptr->ADDRESS, sizeof(sub));
  if (user_phys == 0) return(EFAULT);
  phys_copy(vir2phys(&sub), user_phys, (phys_bytes) sizeof(sub));

  return OK;
}  



/*=========================================================================*
 *				ioctl_read_toc	 			   *	
 *=========================================================================*/
PRIVATE int ioctl_read_toc(m_ptr)
message *m_ptr;
{
  phys_bytes user_phys;
  int err, toc_size;

  /* Try to read the table of contents */
  if ((err = mcd_read_toc()) != OK) return err;

  /* Get size of toc */
  toc_size = (DiskInfo.last_track + 1) * sizeof(struct cd_toc_entry);

  /* Copy to user */
  user_phys = numap(m_ptr->PROC_NR, (vir_bytes) m_ptr->ADDRESS, toc_size);
  if (user_phys == 0) return(EFAULT);
  phys_copy(vir2phys(&Toc), user_phys, (phys_bytes) toc_size);

  return OK;
}  


/*=========================================================================*
 *				ioctl_disk_info	 			   *	
 *=========================================================================*/
PRIVATE int ioctl_disk_info(m_ptr)
message *m_ptr;
{
  phys_bytes user_phys;
  int err;

  /* Try to read the toc header */
  if ((err = mcd_get_disk_info()) != OK) return err;

  /* Copy info to user */
  user_phys = numap(m_ptr->PROC_NR, (vir_bytes) m_ptr->ADDRESS, sizeof(DiskInfo));
  if (user_phys == 0) return(EFAULT);
  phys_copy(vir2phys(&DiskInfo), user_phys, (phys_bytes) sizeof(DiskInfo));

  return OK;
}


/*=========================================================================*
 *				ioctl_play_mss	  			   *	
 *=========================================================================*/
PRIVATE int ioctl_play_mss(m_ptr)
message *m_ptr;
{
  phys_bytes user_phys;
  struct cd_play_mss mss;

  /* Get user data */
  user_phys = numap(m_ptr->PROC_NR, (vir_bytes) m_ptr->ADDRESS, sizeof(mss));
  if (user_phys == 0) return(EFAULT);
  phys_copy(user_phys, vir2phys(&mss), (phys_bytes) sizeof(mss));

  /* Try to play */
  return mcd_play_mss(mss);
}


/*=========================================================================*
 *				ioctl_play_ti	  			   *	
 *=========================================================================*/
PRIVATE int ioctl_play_ti(m_ptr)
message *m_ptr;
{
  phys_bytes user_phys;
  struct cd_play_track tracks;

  /* Get user data */
  user_phys = numap(m_ptr->PROC_NR, (vir_bytes) m_ptr->ADDRESS, sizeof(tracks));
  if (user_phys == 0) return(EFAULT);
  phys_copy(user_phys, vir2phys(&tracks), (phys_bytes) sizeof(tracks));

  /* Try to play */
  return mcd_play_tracks(tracks);
}


/*===========================================================================*
 *				mcd_prepare				     *
 *===========================================================================*/
PRIVATE struct device *mcd_prepare(device)
int device;
{
  /* Nothing to transfer as yet. */
  mcd_count = 0;

  /* Select partition. */
  if (device < DEV_PER_DRIVE) {			/* cd0, cd1, ... */
    mcd_dv = &mcd_part[device];
  } else
  if ((unsigned) (device -= MINOR_hd1a) < SUB_PER_DRIVE) { /* cd1a, cd1b, ... */
    mcd_dv = &mcd_subpart[device];
  } else {
    return NIL_DEV;
  }

  return mcd_dv;
}


/*===========================================================================*
 *				mcd_schedule				     *
 *===========================================================================*/
PRIVATE int mcd_schedule(proc_nr, iop)
int proc_nr;			/* process doing the request */
struct iorequest_s *iop;	/* pointer to read or write request */
{
/* Gather I/O requests on consecutive blocks so they may be read/written
 * in one controller command.  (There is enough time to compute the next
 * consecutive request while an unwanted block passes by.)
 */
  int r, opcode;
  unsigned long pos;
  unsigned nbytes;
  phys_bytes user_phys;

  /* This many bytes to read */
  nbytes = iop->io_nbytes;

  /* From/to this position on the device */
  pos = iop->io_position;

  /* To/from this user address */
  user_phys = numap(proc_nr, (vir_bytes) iop->io_buf, nbytes);
  if (user_phys == 0) return(iop->io_nbytes = EINVAL);

  /* Read or write? */
  opcode = iop->io_request & ~OPTIONAL_IO;

  /* Only read permitted on cdrom */
  if (opcode != DEV_READ) return EIO;

  /* What position on disk and how close to EOF? */
  if (pos >= mcd_dv->dv_size) return(OK);	/* At EOF */
  if (pos + nbytes > mcd_dv->dv_size) nbytes = mcd_dv->dv_size - pos;
  pos += mcd_dv->dv_base;

  if (mcd_count > 0 && pos != mcd_nextpos) {
	/* This new request can't be chained to the job being built */
	if ((r = mcd_finish()) != OK) return(r);
  }

  /* Next consecutive position. */
  mcd_nextpos = pos + nbytes;

  if (mcd_count == 0) 
  {
    /* The first request in a row, initialize. */
    mcd_tp = mcd_trans;
  }

  /* Store I/O parameters */
  mcd_tp->tr_iop = iop;
  mcd_tp->tr_pos = pos;
  mcd_tp->tr_count = nbytes;
  mcd_tp->tr_phys = user_phys;

  /* Update counters */
  mcd_tp++;
  mcd_count += nbytes;
  return(OK);
}


/*===========================================================================*
 *				mcd_finish				     *
 *===========================================================================*/
PRIVATE int mcd_finish()
{
/* Carry out the I/O requests gathered in mcd_trans[]. */

  struct trans *tp = mcd_trans;
  int err, errors;
  u8_t mss[3];
  unsigned long pos;
  unsigned count, n;

  if (mcd_count == 0) return(OK);	/* we're already done */

  /* Update status */
  mcd_get_status(1);
  if (McdStatus & (AUDIO_DISK | NO_DISK))
    return(tp->tr_iop->io_nbytes = EIO);
                                                          
  /* Set cooked mode */
  if ((err = mcd_set_mode(MCD_COOKED)) != OK)
    return(tp->tr_iop->io_nbytes = err);

  while (mcd_count > 0)
  {
    /* Position on the CD rounded down to the CD block size */
    pos = tp->tr_pos & ~MCD_BLOCK_MASK;

    /* Byte count rounded up. */
    count = (pos - tp->tr_pos) + mcd_count;
    count = (count + MCD_BLOCK_SIZE - 1) & ~MCD_BLOCK_MASK;

    /* XXX transfer size limits? */
    if (count > MCD_BLOCK_SIZE) count = MCD_BLOCK_SIZE;

    /* Compute disk position in min:sec:sector */
    block2mss(pos >> MCD_BLOCK_SHIFT, mss);

    /* Now try to read a block */
    errors = 0;
    while (errors < MCD_RETRIES) 
    {
      lock();
      out_byte(MCD_DATA_PORT, MCD_READ_FROM_TO);
      out_byte(MCD_DATA_PORT, bin2bcd(mss[MINUTES])); 
      out_byte(MCD_DATA_PORT, bin2bcd(mss[SECONDS])); 
      out_byte(MCD_DATA_PORT, bin2bcd(mss[SECTOR])); 
      out_byte(MCD_DATA_PORT, 0); 
      out_byte(MCD_DATA_PORT, 0); 
      out_byte(MCD_DATA_PORT, 1); 	/* XXX count in mss form? */
      unlock();

      /* Wait for data */
      if (mcd_data_ready(REPLY_DELAY) == OK) break;
      printf("Mcd: data time out\n");
      errors++;
    }
    if (errors == MCD_RETRIES) return(tp->tr_iop->io_nbytes = EIO);

    /* Prepare reading data. */
    out_byte(MCD_CONTROL_PORT, 0x04);

    while (pos < tp->tr_pos)
    {
      /* Discard bytes before the position we are really interested in. */
      n = tp->tr_pos - pos;
      if (n > DMA_BUF_SIZE) n = DMA_BUF_SIZE;
      port_read_byte(MCD_DATA_PORT, tmp_phys, n);
#if XXX
printf("count = %u, n = %u, tr_pos = %lu, io_nbytes = %u, tr_count = %u, mcd_count = %u\n",
count, n, 0, 0, 0, mcd_count);
#endif
      pos += n;
      count -= n;
    }

    while (mcd_count > 0 && count > 0)
    {
      /* Transfer bytes into the user buffers. */
      n = tp->tr_count;
      if (n > count) n = count;
      port_read_byte(MCD_DATA_PORT, tp->tr_phys, n);
#if XXX
printf("count = %u, n = %u, tr_pos = %lu, io_nbytes = %u, tr_count = %u, mcd_count = %u\n",
count, n, tp->tr_pos, tp->tr_iop->io_nbytes, tp->tr_count, mcd_count);
#endif
      tp->tr_phys += n;
      tp->tr_pos += n;
      tp->tr_iop->io_nbytes -= n;
      if ((tp->tr_count -= n) == 0) tp++;
      count -= n;
      mcd_count -= n;
    }

    while (count > 0)
    {
      /* Discard excess bytes. */
      n = count;
      if (n > DMA_BUF_SIZE) n = DMA_BUF_SIZE;
      port_read_byte(MCD_DATA_PORT, tmp_phys, n);
#if XXX
printf("count = %u, n = %u, tr_pos = %lu, io_nbytes = %u, tr_count = %u, mcd_count = %u\n",
count, n, 0, 0, 0, mcd_count);
#endif
      count -= n;
    }

    /* Finish reading data. */
    out_byte(MCD_CONTROL_PORT, 0x0c);
#if 0 /*XXX*/
    mcd_get_status(1);
    if (!(McdStatus & DISK_ERROR)) done = 1; /* OK, no errors */
#endif
  }
 
  return OK; 
}


/*============================================================================*
 *				mcd_geometry				      *
 *============================================================================*/
PRIVATE void mcd_geometry(entry)
struct partition *entry;		
{
/* The geometry of a cdrom doesn't look like the geometry of a regular disk,
 * so we invent a geometry to keep external programs happy.
 */ 
  entry->cylinders = (mcd_part[0].dv_size >> SECTOR_SHIFT) / (64 * 32);
  entry->heads = 64;
  entry->sectors = 32;
}


/*============================================================================*
 *				misc functions				      *
 *============================================================================*/
PRIVATE u8_t bin2bcd(u8_t b)
{
  /* Convert a number to binary-coded-decimal */
  int u,t;

  u = b%10;
  t = b/10;
  return (u8_t)(u | (t << 4));
}


PRIVATE void bcd2bin(u8_t *bcd)
{
  /* Convert binary-coded-decimal to binary :-) */

  *bcd = (*bcd >> 4) * 10 + (*bcd & 0xf);
}


PRIVATE void block2mss(block, mss)
long block;
u8_t *mss;
{
  /* Compute disk position of a block in min:sec:sector */

  block += MCD_SKIP;
  mss[MINUTES] = block/(SECONDS_PER_MINUTE * SECTORS_PER_SECOND);
  block %= (SECONDS_PER_MINUTE * SECTORS_PER_SECOND);
  mss[SECONDS] = block/(SECTORS_PER_SECOND);
  mss[SECTOR] = block%(SECTORS_PER_SECOND);
}


PRIVATE long mss2block(u8_t *mss)
{
  /* Compute block number belonging to 
   * disk position min:sec:sector 
   */

  return ((((unsigned long) mss[MINUTES] * SECONDS_PER_MINUTE
	+ (unsigned long) mss[SECONDS]) * SECTORS_PER_SECOND)
	+ (unsigned long) mss[SECTOR]) - MCD_SKIP;
}
#endif /* ENABLE_MITSUMI_CDROM */
