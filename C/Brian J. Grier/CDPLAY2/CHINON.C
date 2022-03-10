/*

 a program to play audio CDs on the Chinon CDX-431 drive
 and any other player that follows the SCSI-II spec.
 NOTE NEC players DO NOT follow the spec.

*/
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dma.h"
#include "chinon.h"
#include "cdplayer.h"
#include "globals.h"

#define DESKTOP 0         /* the window handle for the desktop */

char *DISC_STOPPED = "T 00  00:00" ;
char *REPEAT_STRINGS[3] = { "            ",
                            "Repeat: SONG",
                            "Repeat: DISC" } ;

main(int argc,char *argv[],char *enpv[])
{
int          disp_id ;
int          rept_id ;
int          diag_id ;
int          repeat_mode = 0 ;
int          complete ;
int          panel_id ;
int          result ;
int          play_mode ;
int          tmp_trk ;
int          tmp_time ;
time_t       stime = 0 ;
time_t       tmptime = 0 ;
FILE       * fp ;

char       * tmp_addr ;

  ID = 0 ;
  LUN = 0 ;
  cur_index = -1 ;
  play_mode = INIT_MODE ;
  if (appl_init() == -1)
    return 1 ;

  if (rsrc_load("cdplayer.rsc") == 0)
  {
    appl_exit() ;
    return 2 ;
  }
  wind_get(DESKTOP, WF_FULLXYWH, &cx, &cy, &cw, &ch) ;

  if (ch >= 300)
  {
    diag_id = HIGH ;
    panel_id = PANELH ;
    disp_id = DISPH ;
    rept_id = REPTH ;
  }
  else
  {
    diag_id = MEDIUM ;
    panel_id = PANELM ;
    disp_id = DISPM ;
    rept_id = REPTM ;
  }

  if (rsrc_gaddr(0, diag_id, &form_addr) == 0)
  {
    rsrc_free() ;
    appl_exit() ;
    return 3 ;
  }

  disp_text = form_addr[disp_id].ob_spec.tedinfo->te_ptext ;

  rept_text = form_addr[rept_id].ob_spec.tedinfo->te_ptext ;

  strcpy(rept_text, REPEAT_STRINGS[repeat_mode]) ;

  rsrc_gaddr(0, MENUBAR, &menu_addr) ;

  menu_bar(menu_addr, 1) ;

  ID = 16 ;
  if ((fp = fopen("CDPLAYER.DAT", "r")) != NULL)
  {
    fscanf(fp, "%d", &ID) ;
    if ((ID < 0) || (ID > 15))
    {
      form_alert(1,"[1][File: CDPLAYER.DAT|ID out of range 0..15][Please Fix]") ;
      ID = 16 ;
    }
  }

  if (ID == 16)
    find_Chinon() ;  /* find the CDS-43x */

  if (ID == 16)
  {
    form_alert(1,"[3][Could not locate CD-Rom][Ok]") ;
  }
  else
  {
/*
   check for playing already in progress and if disk is/isnot
   an audio CD
*/
    read_TOC(&toc) ;
    time_remaining = Get_Time_Remain() ;
    if (time_remaining == (double)0.0)
      play_mode = INIT_MODE ;
    else
    {
      play_mode = PLAY_MODE ;
      stime = time(&tmptime) ;
    }
    Create_Window() ;
    Update_Window(diag_id) ;

    bstate = 1 ;
    complete = FALSE ;
    while(complete != TRUE)
    { 
      event = evnt_multi(MU_BUTTON | MU_TIMER | MU_MESAG,
                 1, 1, bstate,
                 0, 0, 0, 0, 0,
                 0, 0, 0, 0, 0,
                 ev_buffer,
                 2000, 0,
                 &ev_mmox, &ev_mmoy,
                 &ev_mmbutton, &ev_mmokstate, &dummy1, &dummy2) ;
 
      if (event == MU_MESAG)
      {
        complete = Process_Message() ;
      }

      if ((event & MU_BUTTON) != 0)
      {
        if (bstate == 0)
        {
          bstate = 1 ;
        }
        else
        {
/* need to check if the disk was changed */
          read_TOC(&toc_tmp) ;
          if ( toc_cmp(&toc, &toc_tmp) != 0 )
          {
            play_mode = INIT_MODE ;  /* new disk... everything changes */
            toc_copy(&toc, &toc_tmp) ;
            current_track = next_track(-1) ;
          }

          bstate = 0 ;
          graf_mkstate(&ev_mmox, &ev_mmoy, &ev_mmbutton, &ev_mmokstate) ;
          result = objc_find(form_addr, panel_id, 8, ev_mmox, ev_mmoy) ;
          switch (result) {
            case EXITH   : complete = TRUE ;
                           break ;
            case EJECTH  : stop_audio() ;
                           eject_cd() ;
                           play_mode = INIT_MODE ;
                           break ;
            case STOPH   : stop_audio() ;
                           play_mode = INIT_MODE ;
                           strcpy(disp_text, DISC_STOPPED) ;
                           objc_draw(form_addr, disp_id, MAX_DEPTH, cx, cy, cw, ch) ;
                           break ;
            case PLAYH   : switch (play_mode) 
                           {
                             case INIT_MODE  : current_track = next_track(-1) ;
                                               if (current_track != -1)
                                               {
                                                 play_audio(current_track) ;
                                                 time_remaining = t_sec(&(toc.tracks[current_track + 1].addr)) 
                                                                - t_sec(&(toc.tracks[current_track].addr)) ;
                                                 play_mode = PLAY_MODE ;
                                                 stime = time(&tmptime) ;
                                               }
                                               break ;
                             case PLAY_MODE  : stop_audio() ;
                                               play_mode = PAUSE_MODE ;
                                               break ;
                             case PAUSE_MODE : continue_audio() ;
                                               time_remaining = t_sec(&(toc.tracks[current_track + 1].addr)) 
                                                              - t_sec(&(sub_channel.abs_addr)) ;
                                               play_mode = PLAY_MODE ;
                                               stime = time(&tmptime) ;
                                               break ;
                           }
                           break ;
            case BACKH   : if (play_mode != INIT_MODE)
                           {
                             tmp_trk = prev_track(current_track) ;
                             if (tmp_trk != -1)
                             {
                               stop_audio() ;
                               current_track = tmp_trk ;
                               play_audio(current_track) ;
                               time_remaining = t_sec(&(toc.tracks[current_track + 1].addr)) 
                                              - t_sec(&(toc.tracks[current_track].addr)) ;
                               play_mode = PLAY_MODE ;
                               stime = time(&tmptime) ;
                             }
                           }
                           break ;
            case FWDH    : if (play_mode != INIT_MODE)
                           {
                             tmp_trk = next_track(current_track) ;
                             if (tmp_trk != -1)
                             {
                               stop_audio() ;
                               current_track = tmp_trk ;
                               play_audio(current_track) ;
                               time_remaining = t_sec(&(toc.tracks[current_track + 1].addr)) 
                                              - t_sec(&(toc.tracks[current_track].addr)) ;
                               play_mode = PLAY_MODE ;
                               stime = time(&tmptime) ;
                             }
                           }
                           break ;
            case RPTH    : repeat_mode++ ;
                           if (repeat_mode > 2)
                              repeat_mode = 0 ;
                           strcpy(rept_text, REPEAT_STRINGS[repeat_mode]) ;
                           objc_draw(form_addr, rept_id, MAX_DEPTH, cx, cy, cw, ch) ;
                           break ;
          }
          form_addr[result].ob_state &= ~SELECTED ;
        }       
      }
      if ((event & MU_TIMER) != 0)
      {
        if (time_remaining < difftime(time(&tmptime), stime))
        {
          switch (repeat_mode)
          {
            case 1: current_track = prev_track(current_track) ;
                    break ;
            case 2: if (next_track(current_track) == -1)
                      current_track = -1 ;
                    break ;
          }
          current_track = next_track(current_track) ;
          if (current_track == -1)
            play_mode = INIT_MODE ;   /* no more audio tracks */
          else
          {
            if (play_mode == PLAY_MODE)
            {
              stop_audio() ;
              play_audio(current_track) ;
              time_remaining = t_sec(&(toc.tracks[current_track + 1].addr)) 
                             - t_sec(&(toc.tracks[current_track].addr)) ;
              stime = time(&tmptime) ;
            }
          }
        }
      }
/*
   It is time to update the display
*/
      if (play_mode == PLAY_MODE)
      {
        tmp_time = (int) time_remaining - difftime(time(&tmptime), stime) ;
        sprintf(disp_text, "T %2.2d  %2.2d:%2.2d", current_track+1,
                (tmp_time / 60), (tmp_time % 60)) ;
        Update_Window(disp_id) ;
      }
    }
  }

  menu_bar(menu_addr, 0) ;
  Remove_Window() ;
  rsrc_free() ;
  appl_exit() ;
  return (0) ;
}

double t_sec(ABS_CD_ROM_ADDR * addr)
{
double result ;

  result = (double)(addr->minute * 60) ;
  result += (double)(addr->second) ;
  result += ((double)addr->field / (double)256.0 ) ;
  return (result) ;
}

void toc_copy(TOC_DATA_FORMAT * dest, TOC_DATA_FORMAT * src) 
{
int i ;
char * d ;
char * s ;

  d = (char *)dest ;
  s = (char *)src ;

  for ( i=0; i < sizeof(TOC_DATA_FORMAT); i++)
    *d++ = *s++ ;
}

int toc_cmp(TOC_DATA_FORMAT * toc1, TOC_DATA_FORMAT * toc2) 
{
int i ;
char * d ;
char * s ;

  d = (char *)toc1 ;
  s = (char *)toc2 ;

  i=0 ;
  while ((*d++ == *s++) && (i < sizeof(TOC_DATA_FORMAT)) )
    i++ ;

  if (i < sizeof(TOC_DATA_FORMAT) )
    return (1) ;
  else
    return (0) ;
}

int next_track(int cur_trk)
{
loop:
  cur_trk++ ;
  if (cur_trk >= toc.header.last_track)
    return -1 ;
/*
  make sure that the new track is an audio track
*/
  if ((toc.tracks[cur_trk].addr_cntrl &0xf) != 0)
    goto loop ;

  return cur_trk ;
}

int prev_track(int cur_trk)
{
loop:
  cur_trk-- ;
  if (cur_trk < (toc.header.first_track-1))
    return -1 ;
/*
  make sure that the new track is an audio track
*/
  if ((toc.tracks[cur_trk].addr_cntrl &0xf) != 0)
    goto loop ;

  return cur_trk ;
}