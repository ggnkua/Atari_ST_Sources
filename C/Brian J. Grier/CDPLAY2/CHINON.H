/*
   This file includes all of the commands supported by the 
   Chinon CDX-431

   There are a couple of things that need to be clarified
   a cd contains multiple tracks. If a track returns a
   control value other than zero it is NOT AN AUDIO track
*/

#define CD_INQUIRY 0x12
#define CD_INQUIRY_length 6

#define CD_READ_SUBCHANNEL 0x42
#define CD_READ_SUBCHANNEL_length 10

#define CD_READ_TOC 0x43
#define CD_READ_TOC_length 10

#define CD_PLAY_AUDIO 0x47
#define CD_PLAY_AUDIO_length 10

#define CD_PLAY_TRACK 0x48
#define CD_PLAY_TRACK_length 10

#define CD_STOP_AUDIO 0xc6
#define CD_STOP_AUDIO_length 10

#define CD_PAUSE_AUDIO 0x4b
#define CD_PAUSE_AUDIO_length 10

#define CD_EJECT_DISK 0xc0
#define CD_EJECT_DISK_length 10

#define PLAY_MODE   0
#define PAUSE_MODE  1
#define INIT_MODE  -1


#define AUDIO_STATUS_INVALID  0x00
#define AUDIO_STATUS_PLAY     0x11
#define AUDIO_STATUS_PAUSED   0x15

/*
   just a SMALL reminder track number are in BCD format
   meaning that each byte can contain 0->99
*/

#define BCD_to_UCHAR(x) ((((x>>4)&0xf)*10)+(x&0xf))

typedef struct {
   unsigned char    null_1 ;
   unsigned char    minute ;
   unsigned char    second ;
   unsigned char    field ;
} ABS_CD_ROM_ADDR ;

typedef struct {
   unsigned int     data_length ;
   unsigned char    first_track ;
   unsigned char    last_track ;
} TOC_HEADER_DATA ;

typedef struct {
   unsigned char    null_1 ;
   unsigned char    addr_cntrl ;
   unsigned char    number ;
   unsigned char    null_2 ;
   ABS_CD_ROM_ADDR  addr ;
} TOC_TRACK_DESCR ;

typedef struct {
   TOC_HEADER_DATA     header ;
   TOC_TRACK_DESCR     tracks[32] ; /* typicall CDs only have 16 tracks */
} TOC_DATA_FORMAT ;

typedef struct {
   unsigned char   null_1 ;
   unsigned char   audio_status ;
   unsigned int    data_length ;
   unsigned char   null_2 ;
   unsigned char   addr_cntrl ;
   unsigned char   track ;
   unsigned char   index ;
   ABS_CD_ROM_ADDR abs_addr ;
   ABS_CD_ROM_ADDR rel_addr ;
   unsigned char   null_3[32] ;
   unsigned char   UPC_Bar_Code[15] ;
   unsigned char   TCVal ;
   unsigned char   T_ISR_Code[15] ;
} SUB_CHANNEL_DATA ;