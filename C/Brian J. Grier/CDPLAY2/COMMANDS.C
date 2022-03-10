#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dma.h"
#include "chinon.h"
#include "cdplayer.h"
#include "globals.h"

void inquire_device(char * buffer) ;

void find_Chinon(void)
{
char buffer[128] ;

  for (ID = 0; ID < 16; ID++)
  {
    inquire_device(buffer) ;
    if (strncmp(&buffer[8], "CHINON  CD-ROM CDS-43", 21) == 0)
      return ;
  }
  return ;
}

void inquire_device(char * buffer)
{
int result ;

  Command.Data[0] = CD_INQUIRY_length ;
  Command.Data[1] = CD_INQUIRY ;
  Command.Data[2] = 0;
  Command.Data[3] = 0;
  Command.Data[4] = 0;
  Command.Data[5] = 64;
  Command.Data[6] = 0;
  Command.Data[7] = 0;
  Command.Data[8] = 0;
  Command.Data[9] = 0;
  Command.Data[10] = 0;

  result = _xdma(ID,Command.Data,buffer,READ_DIR+FULLSCSI,nBlocks,30l*ONE_SECOND) ;
  return ;
}

void read_TOC(TOC_DATA_FORMAT * toc)
{
int result ;
int i ;
int num_tracks ;

  Command.Data[0] = CD_READ_TOC_length;
  Command.Data[1] = CD_READ_TOC ;
  Command.Data[2] = 2;
  Command.Data[3] = 0;
  Command.Data[4] = 0;
  Command.Data[5] = 0;
  Command.Data[6] = 0;
  Command.Data[7] = 0;
  Command.Data[8] = ((256 >> 8) & 0xff) ;
  Command.Data[9] = (256 &0xff) ;
  Command.Data[10] = 0;

  result = _xdma(ID,Command.Data,(char *)toc,READ_DIR+FULLSCSI,nBlocks,30l*ONE_SECOND) ;

    toc->header.first_track = BCD_to_UCHAR(toc->header.first_track) ;
    toc->header.last_track = BCD_to_UCHAR(toc->header.last_track) ;
/*
  Convert the track numbers from BCD to unsigend char
*/
    num_tracks = toc->header.last_track - toc->header.first_track + 1 ;
    for (i=0; i < num_tracks; i++)
    {
      toc->tracks[i].number = BCD_to_UCHAR(toc->tracks[i].number) ;
    }
  return ;
}

void read_sub_channel(void)
{
int result ;

  Command.Data[0] = CD_READ_SUBCHANNEL_length;
  Command.Data[1] = CD_READ_SUBCHANNEL ;
  Command.Data[2] = 2;
  Command.Data[3] = 0x40;   /* flag to cause sub_channel data to be transfered */
/* 
  only 0 works with the 431 3 should give MPC and ISRC 
  see 13.2.10 of SCSI-II Spec for details
*/
  Command.Data[4] = 0;   /* Sub-Channel format */
  Command.Data[5] = 0;
  Command.Data[6] = 0;
  Command.Data[7] = 0;
  Command.Data[8] = ((sizeof(SUB_CHANNEL_DATA) >> 8) & 0xff) ;
  Command.Data[9] = (sizeof(SUB_CHANNEL_DATA) &0xff) ;
  Command.Data[10] = 0;

  result = _xdma(ID,Command.Data,(char *)&sub_channel,READ_DIR+FULLSCSI,nBlocks,30l*ONE_SECOND) ;

  return ;
}
void    eject_cd(void)
{
int result ;

  Command.Data[0] = CD_EJECT_DISK_length;
  Command.Data[1] = CD_EJECT_DISK ;
  Command.Data[2] = 0;
  Command.Data[3] = 0;
  Command.Data[4] = 0;
  Command.Data[5] = 0;
  Command.Data[6] = 0;
  Command.Data[7] = 0;
  Command.Data[8] = 0 ;
  Command.Data[9] = 0 ;
  Command.Data[10] = 0;

  result = _xdma(ID,Command.Data,scrap,READ_DIR+FULLSCSI,nBlocks,30l*ONE_SECOND) ;

  return ;
}

void    stop_audio(void)
{
int result ;

  Command.Data[0] = CD_STOP_AUDIO_length;
  Command.Data[1] = CD_STOP_AUDIO ;
  Command.Data[2] = 0;
  Command.Data[3] = 0;
  Command.Data[4] = 0;
  Command.Data[5] = 0;
  Command.Data[6] = 0;
  Command.Data[7] = 0;
  Command.Data[8] = 0 ;
  Command.Data[9] = 0 ;
  Command.Data[10] = 0;

  result = _xdma(ID,Command.Data,scrap,READ_DIR+FULLSCSI,nBlocks,30l*ONE_SECOND) ;

  return ;
}
void    pause_audio(void)
{
int result ;

  Command.Data[0] = CD_PAUSE_AUDIO_length;
  Command.Data[1] = CD_PAUSE_AUDIO ;
  Command.Data[2] = 0;
  Command.Data[3] = 0;
  Command.Data[4] = 0;
  Command.Data[5] = 0;
  Command.Data[6] = 0;
  Command.Data[7] = 0;
  Command.Data[8] = 0 ;
  Command.Data[9] = 0 ;
  Command.Data[10] = 0;

  result = _xdma(ID,Command.Data,scrap,READ_DIR+FULLSCSI,nBlocks,30l*ONE_SECOND) ;

  return ;
}
void    resume_audio(void)
{
int result ;

  Command.Data[0] = CD_PAUSE_AUDIO_length;
  Command.Data[1] = CD_PAUSE_AUDIO ;
  Command.Data[2] = 0;
  Command.Data[3] = 0;
  Command.Data[4] = 0;
  Command.Data[5] = 0;
  Command.Data[6] = 0;
  Command.Data[7] = 0;
  Command.Data[8] = 0 ;
  Command.Data[9] = 1 ;
  Command.Data[10] = 0;

  result = _xdma(ID,Command.Data,scrap,READ_DIR+FULLSCSI,nBlocks,30l*ONE_SECOND) ;

  return ;
}

void    play_audio(int track)
{
int result ;

  track++ ;
  Command.Data[0] = CD_PLAY_TRACK_length;
  Command.Data[1] = CD_PLAY_TRACK ;
  Command.Data[2] = 0;
  Command.Data[3] = 0;
  Command.Data[4] = 0;
  Command.Data[5] = (char) track;
  Command.Data[6] = 1;
  Command.Data[7] = 0;
  Command.Data[8] = (char) track;
  Command.Data[9] = 0x99;
  Command.Data[10] = 0;

/*
  Command.Data[0] = CD_PLAY_AUDIO_length;
  Command.Data[1] = CD_PLAY_AUDIO ;
  Command.Data[2] = 0;
  Command.Data[3] = 0;
  Command.Data[4] = toc.tracks[track].addr.minute ;
  Command.Data[5] = toc.tracks[track].addr.second ;
  Command.Data[6] = toc.tracks[track].addr.field ;
  track++ ;
  Command.Data[7] = toc.tracks[track].addr.minute ;
  Command.Data[8] = toc.tracks[track].addr.second ;
  if (toc.tracks[track].addr.field == 0)
  {
    Command.Data[8] -= 1 ;
    Command.Data[9] = 0 ;
  }
  else
    Command.Data[9] = toc.tracks[track].addr.field - 1 ;
  Command.Data[10] = 0;
*/

  result = _xdma(ID,Command.Data,scrap,READ_DIR+FULLSCSI,nBlocks,30l*ONE_SECOND) ;

  return ;
}

void    continue_audio(void)
{
int result ;

  read_sub_channel() ;

  Command.Data[0] = CD_PLAY_AUDIO_length;
  Command.Data[1] = CD_PLAY_AUDIO ;
  Command.Data[2] = 0;
  Command.Data[3] = 0;
  Command.Data[4] = sub_channel.abs_addr.minute ;
  Command.Data[5] = sub_channel.abs_addr.second ;
  Command.Data[6] = sub_channel.abs_addr.field ;
  Command.Data[7] = toc.tracks[sub_channel.track+1].addr.minute ;
  Command.Data[8] = toc.tracks[sub_channel.track+1].addr.second ;
  if (toc.tracks[sub_channel.track+1].addr.field == 0)
  {
    Command.Data[8] -= 1 ;
    Command.Data[9] = 0 ;
  }
  else
    Command.Data[9] = toc.tracks[sub_channel.track+1].addr.field - 1 ;
  Command.Data[10] = 0;

  result = _xdma(ID,Command.Data,scrap,READ_DIR+FULLSCSI,nBlocks,30l*ONE_SECOND) ;

  return ;
}


/*
===========================================================================
                Some examples of DMA type calls
                -------------------------------
*/

/* examples of ACSI format commands */
int Read_Sector (char *buffer, long secno, int blocks)
{
  Command.Data[0] = 0x08;
  Command.Data[1] = (secno & 0xFF0000l) / 0x10000l + 0x20*LUN;
  Command.Data[2] = (secno & 0x00FF00l) / 0x100l;
  Command.Data[3] = secno & 0x0000FFl;
  Command.Data[4] = blocks;
  Command.Data[5] = 0;
  return( _xdma(ID,Command.Data,buffer,READ_DIR,blocks,30l*ONE_SECOND) );
}



int Write_Sector (char * buffer, long secno, int blocks)
{
  Command.Data[0] = 0x0A;
  Command.Data[1] = (secno & 0xFF0000l) / 0x10000l + 0x20*LUN;
  Command.Data[2] = (secno & 0x00FF00l) / 0x100l;
  Command.Data[3] = secno & 0x0000FFl;
  Command.Data[4] = blocks;
  Command.Data[5] = 0;
  return( _xdma(ID,Command.buf,buffer,WRITE_DIR,blocks,30*ONE_SECOND) );
}

/* example of a FULL SCSI command */
long Read_Capacity(void)
{
int   i ;
  Command.Data[0] = 10;               /* 10 bytes in command frame  */
  Command.Data[1] = 0x25;             /* read capacity command      */
  Command.Data[2] = 0x20*LUN;
  for (i=3; i<=10; i++)
    Command.Data [i] = 0;

  if (_sxdma(ID,Command.buf,SecBuf.buf,READ_DIR+FULLSCSI,1,3*ONE_SECOND)== 0 )
     return SecBuf.longs[0] ;
  else
     return 0;
}
