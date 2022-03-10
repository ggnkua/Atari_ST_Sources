#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "CDPlayer.h"
#include "Chinon.h"
#include "globals.h"

int          w_hand ;
int          v_hand ;
int          vw[4] ;
int	         cwidth, cheight, bwidth, bheight ;
int          work_in[11] = {1,1,1,1,1,1,1,1,1,1,2} ;
int          work_out[57] ;

void Create_Window(void)
{
  form_center(form_addr, cntr.x, cntr.y, cntr.w, cntr.h) ;
  w_hand = wind_create(0, cx, cy, cw, ch) ;
  wind_open(w_hand, cx, cy, cw, ch) ;
  v_hand = graf_handle(&cwidth, &cheight, &bwidth, &bheight) ;
  v_opnvwk(work_in, &v_hand, work_out) ;

}

void Update_Window(int object)
{
  wind_update(BEG_UPDATE) ;
  wind_get(w_hand, WF_FIRSTXYWH, &cx, &cy, &cw, &ch) ;
  while (cw && ch)
  {
    vw[0] = cx ;
    vw[1] = cy ;
    vw[2] = cx + cw - 1 ;
    vw[3] = cy + ch - 1 ;
    vs_clip(v_hand, 1, vw) ;
    objc_draw(form_addr, object, MAX_DEPTH, cx, cy, cw, ch) ;
    wind_get(w_hand, WF_NEXTXYWH, &cx, &cy, &cw, &ch) ;
  }
  wind_update(END_UPDATE) ;
}

void Remove_Window(void)
{
  v_clsvwk(v_hand) ;
  wind_close(w_hand) ;

  wind_delete(w_hand) ;
}

int Process_Message(void)
{
int nowhere ;

  switch (ev_buffer[0])
  {
    case MN_SELECTED : if (ev_buffer[4] == QUIT)
                         return TRUE ;
    case WM_REDRAW   : Update_Window(panel_id) ;
                       break ;
    case WM_NEWTOP   :
    case WM_TOPPED   : wind_set(ev_buffer[3], WF_TOP, &nowhere,
                                &nowhere, &nowhere, &nowhere) ;
                       break ;
  }
  return FALSE ;
}

double Get_Time_Remain()
{
  read_sub_channel() ;

  if (sub_channel.audio_status == AUDIO_STATUS_PLAY)
  {
    current_track = BCD_to_UCHAR(sub_channel.track) - 1 ;
    return ( t_sec(&(toc.tracks[current_track + 1].addr)) 
           - t_sec(&(sub_channel.abs_addr)) ) ;
  }
  else
    return ((double)0.0) ;
}