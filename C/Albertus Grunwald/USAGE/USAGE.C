/* USAGE by Albertus Grunwald */
/* (c) MAXON Computer 1993    */

#include <stddef.h>
#include <time.h>
#include <aes.h>
#include <vdi.h>


#define SIZE_X  100
#define SIZE_Y  70
#define W_KIND  NAME | CLOSER | MOVER

#define MAX(a, b)   ((a) >= (b) ? (a) : (b))
#define MIN(a, b)   ((a) <= (b) ? (a) : (b))


int v_hndl, w_hndl,
    desk_x, desk_y, desk_w, desk_h,
    wind_x, wind_y, wind_w, wind_h,
    usage[SIZE_X], curr_percent;


void    evnt_hndl(void);
void    draw_wind(int xc, int yc, int wc, int hc);
int     rc_intersect(GRECT *p1, GRECT *p2);


int main(void)
 {
    int ap_id, d,
        work_in[11], work_out[57];

    register int    i;

    ap_id = appl_init();
    if(ap_id < 0)
     {
        form_alert(1, "[3][Applikation kann nicht|"
                      "angemeldet werden.][  OK  ]");
        return(100);
     }
    v_hndl = graf_handle(&d, &d, &d, &d);
    for(i = 0; i < 10; i++)
        work_in[i] = 1;
    work_in[10] = 2;
    v_opnvwk(work_in, &v_hndl, work_out);
    vsf_color(v_hndl, 0);
    vst_height(v_hndl, 4, &d, &d, &d, &d);
    vst_alignment(v_hndl, 0, 5, &d, &d);

    wind_get(0, WF_WORKXYWH, &desk_x, &desk_y,
             &desk_w, &desk_h);
    w_hndl = wind_create(W_KIND, desk_x, desk_y,
                         desk_w, desk_h);
    if(w_hndl < 0)
     {
        form_alert(1, "[3][Kein Fenster-Handle verfgbar.]"
                      "[  OK  ]");
        v_clsvwk(v_hndl);
        appl_exit();
        return(101);
     }
    wind_set(w_hndl, WF_NAME, " Usage ");
    wind_calc(WC_BORDER, W_KIND, 0, 0, SIZE_X, SIZE_Y,
              &d, &d, &wind_w, &wind_h);
    wind_x = desk_x + desk_w - wind_w - 1;
    wind_y = desk_y;
    wind_open(w_hndl, wind_x, wind_y, wind_w, wind_h);
    wind_get(w_hndl, WF_WORKXYWH, &wind_x, &wind_y, &d, &d);

    evnt_hndl();

    wind_close(w_hndl);
    wind_delete(w_hndl);
    v_clsvwk(v_hndl);
    appl_exit();
    return(0);
 }


void    evnt_hndl(void)
 {
    int     ev_mmgpbuf[8];
    int     which, d;
    long    tcount = 0, tbase = 0;
    time_t  curr_t, old_t = time(NULL), diff_t = 0;

    register int    i, j;

    for(;;)
     {
        which= evnt_multi(MU_MESAG | MU_TIMER,
                          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                          ev_mmgpbuf, 0, 0,
                          &d, &d, &d, &d, &d, &d );
    
        if(which & MU_MESAG && ev_mmgpbuf[3] == w_hndl)
         {
            if(ev_mmgpbuf[0] == WM_REDRAW)
             {
                draw_wind(ev_mmgpbuf[4], ev_mmgpbuf[5],
                          ev_mmgpbuf[6], ev_mmgpbuf[7]);
             }
            else if(ev_mmgpbuf[0] == WM_MOVED)
             {
                wind_set(w_hndl, WF_CURRXYWH,
                         ev_mmgpbuf[4], ev_mmgpbuf[5],
                         wind_w, wind_h);
                wind_get(w_hndl, WF_WORKXYWH, &wind_x, &wind_y,
                         &d, &d);
             }
            else if(ev_mmgpbuf[0] == WM_TOPPED)
                wind_set(w_hndl, WF_TOP, w_hndl);
            else if(ev_mmgpbuf[0] == WM_CLOSED)
                break;
         }

        if(which & MU_TIMER)
         {
            tcount++;
            curr_t = time(NULL);
            if(curr_t != old_t)
             {
                diff_t = (curr_t - old_t) / 2;

                for(j = 0; j < diff_t; j++)
                 {
                    for(i = 0; i < SIZE_X - 1; i++)
                        usage[i] = usage[i + 1];
                    if(tbase < tcount)
                        tbase = tcount;
                    usage[SIZE_X - 1] =
                    (int)(+((tbase - tcount) * SIZE_Y) / tbase);
                    curr_percent =
                     (int)(+((tbase - tcount) * 100) / tbase);
                    draw_wind(wind_x, wind_y, SIZE_X, SIZE_Y);
                 }
                tcount = 0;
                old_t = curr_t;
             }
         }
     }
 }


void    draw_wind(int xc, int yc, int wc, int hc)
 {
    static char str[] = "00";

    int     pxy[SIZE_X * 2], clip[4];
    GRECT   t1, t2, t3;

    register int i, j;

    for(i = 0, j = 0; i < SIZE_X; i++)
     {
        pxy[j++] = wind_x + i;
        pxy[j++] = wind_y + SIZE_Y - usage[i] - 1;
     }

    wind_update(BEG_UPDATE);
    graf_mouse(M_OFF, NULL);
    t2.g_x = xc;
    t2.g_y = yc;
    t2.g_w = wc;
    t2.g_h = hc;
    t3.g_x = desk_x;
    t3.g_y = desk_y;
    t3.g_w = desk_w;
    t3.g_h = desk_h;
    wind_get(w_hndl, WF_FIRSTXYWH, &t1.g_x, &t1.g_y,
             &t1.g_w, &t1.g_h);
    while(t1.g_w && t1.g_h)
     {
        if(rc_intersect(&t2, &t1) && rc_intersect(&t3, &t1))
         {
            clip[0] = t1.g_x;
            clip[1] = t1.g_y;
            clip[2] = t1.g_x + t1.g_w - 1;
            clip[3] = t1.g_y + t1.g_h - 1;
            vs_clip(v_hndl, 1, clip);
            v_bar(v_hndl, clip);
            v_pline(v_hndl, SIZE_X, pxy);
            str[0] = curr_percent / 10 + '0';
            str[1] = curr_percent % 10 + '0';
            v_gtext(v_hndl, wind_x + 1, wind_y + 1, str);
            vs_clip(v_hndl, 0, clip);
         }
        wind_get(w_hndl, WF_NEXTXYWH, &t1.g_x, &t1.g_y,
                 &t1.g_w, &t1.g_h);
     }
    graf_mouse(M_ON, NULL);
    wind_update(END_UPDATE);
 }


int rc_intersect(GRECT *p1, GRECT *p2)
 {
    int tx, ty, tw, th;

    tw = MIN(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
    th = MIN(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
    tx = MAX(p2->g_x, p1->g_x);
    ty = MAX(p2->g_y, p1->g_y);

    p2->g_x = tx;
    p2->g_y = ty;
    p2->g_w = tw - tx;
    p2->g_h = th - ty;

    return((tw > tx) && (th > ty));
 }
