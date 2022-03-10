#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "dma.h"
#include "chinon.h"
#include "cdplayer.h"
#include "globals.h"

int cx, cy, cw, ch ;
Prect cntr = { &cx, &cy, &cw, &ch } ;
Rect zero_box = { 0, 0, 0, 0 } ;
Rect screen ;
MFORM it ;

char            * disp_text ;
char            * rept_text ;

OBJECT          * form_addr ;
OBJECT          * disp_addr ;
OBJECT          * rept_addr ;
OBJECT          * menu_addr ;

int               current_track ;
int               disp_id ;
int               rept_id ;
int               diag_id ;
int               panel_id ;

int               event ;
int               dummy1 ;
int               dummy2 ;
int               bstate ;
int               ev_mmox ;
int               ev_mmoy ;
int               ev_mmbutton ;
int               ev_mmokstate ;
int               ev_buffer[128] ;

double            time_remaining ;

SUB_CHANNEL_DATA  sub_channel ; /* buffer to hold audio status */
TOC_DATA_FORMAT   toc ;         /* buffer to hold data to/from cd-rom */
TOC_DATA_FORMAT   toc_tmp ;
char              scrap[512] ;  /* buffer to hold junk data */

int cur_index ;

/* */
/* int       ID,LUN ;             /* global SCSI ID/LUN          */
/* Com_Rec   Command ;            /* global SCSI command buffer  */
/* Dat_Rec   SecBuf ;             /* global sector buffer        */
/* */