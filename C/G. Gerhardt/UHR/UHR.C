/**************************************/
/*                                    */
/*    UHR.C ist PD-SOURCE-SOFTWARE    */
/*                                    */
/*         by G. Gerhardt             */
/*            Siekhammer 34           */
/*            4930  Detmold           */
/*                                    */
/**************************************/

#include <osbind.h>
#include <gemdefs.h>
#include <obdefs.h>

#define POS 65
#define UHR 6
#define WECKER 10
#define WECKZEIT 12
#define OK 13
#define NUM_OBS 14
#define NUM_TI 6

char *strings[]=
{
    "","Bildschirmuhr","by G. Gerhardt",
    "Uhr","Wecker","EIN","AUS",
    "\0___","Weckzeit __:__","9999","OK"
};

TEDINFO txtinfo[]=
{
     1L,  0L,  0L, 3, 6, 2, 0x1180, 0x0, 255, 14, 1,
     2L,  0L,  0L, 5, 6, 2, 0x1180, 0x0, 255, 15, 1,
     3L,  0L,  0L, 3, 6, 2, 0x1100, 0x0, 0,    4, 1,
     4L,  0L,  0L, 3, 6, 2, 0x1100, 0x0, 0,    7, 1,
     7L,  8L,  9L, 3, 6, 2, 0x1180, 0x0, 254,  5, 15,
    10L,  0L,  0L, 3, 6, 2, 0x1180, 0x0, 254,  3, 1
};

OBJECT objekte[]=
{
    -1,  1, 13, G_BOX,      NONE,     OUTLINED, 0x31141L,   0,0, 26,9,
     4,  2,  3, G_BOX,      NONE,     0x30,     0xFE1100L,  2,1, 22,2,
     3, -1, -1, G_TEXT,     NONE,     NORMAL,   0x0L,       0,0, 22,1,
     1, -1, -1, G_TEXT,     NONE,     NORMAL,   0x1L,       0,1, 22,1,
     8,  5,  7, G_BOX,      NONE,     0x30,     0xFE1100L,  2,4, 10,2,
     6, -1, -1, G_TEXT,     NONE,     NORMAL,   0x2L,       0,0, 10,1,
     7, -1, -1, G_BUTTON,   0x11,     SELECTED, 0x5L,       0,1,  5,1,
     4, -1, -1, G_BUTTON,   0x11,     NORMAL,   0x6L,       5,1,  5,1,
    12,  9, 11, G_BOX,      NONE,     0x30,     0xFE1100L, 14,4, 10,2,
    10, -1, -1, G_TEXT,     NONE,     NORMAL,   0x3L,       0,0, 10,1,
    11, -1, -1, G_BUTTON,   0x11,     NORMAL,   0x5L,       0,1,  5,1,
     8, -1, -1, G_BUTTON,   0x11,     SELECTED, 0x6L,       5,1,  5,1,
    13, -1, -1, G_FBOXTEXT, EDITABLE, 0x30,     0x4L,       2,7, 15,1,
     0, -1, -1, G_BOXTEXT,  0x27,     0x30,     0x5L,      19,7,  5,1
};

char snd[]=
{
    0,250,1,0,2,252,3,0,4,254,5,0,6,0,7,0xf8,8,16,9,16,
    10,16,11,0,12,150,13,8,0xff,0
};

char off[]=
{
    7,0xff,8,0,9,0,10,0,0xff,0
};

char uhr[]="00.00.00 00:00";

char blk[]="              ";

char bgr[12];
int contrl[12],intin[128],intout[128],ptsin[128],ptsout[128],buff[57];
int handle,gl_hchar,t,anz=1,weck,ereig,lc,h;
GRECT fm;
extern int gl_apid;

disp(s)
char *s;
{
    int i,f;
    char *adr;

    adr=(char *)Logbase()+240+POS;
    f=1;
    v_hide_c(handle);
    if (Getrez()==2)
    {
        for (i=0;i<12;i++)
        {
            if (bgr[i]!=*adr) f=0;
            adr+=81;
        }
        adr-=12*81;
    }
    if (f)
    {
        v_gtext(handle,POS<<3,gl_hchar-2,s);
        for (i=0;i<12;i++)
        {
            bgr[i]=*adr;
            adr+=81;
        }
    }
    else
    {
        for (i=0;i<12;i++) bgr[i]=0;
    }
    v_show_c(handle,1);
}

main()
{
    appl_init();
    for (h=0;h<NUM_OBS;h++)
    {
        rsrc_obfix(objekte,h);
        switch (objekte[h].ob_type)
        {
            case G_BUTTON:
                objekte[h].ob_spec=(long)strings[objekte[h].ob_spec];
                break;
            case G_TEXT:
            case G_BOXTEXT:
            case G_FBOXTEXT:
                objekte[h].ob_spec=(long)&txtinfo[objekte[h].ob_spec];
        }
    }
    for (h=0;h<NUM_TI;h++)
    {
        txtinfo[h].te_ptext=(long)strings[txtinfo[h].te_ptext];
        txtinfo[h].te_ptmplt=(long)strings[txtinfo[h].te_ptmplt];
        txtinfo[h].te_pvalid=(long)strings[txtinfo[h].te_pvalid];
    }
    form_center(objekte,&fm.g_x,&fm.g_y,&fm.g_w,&fm.g_h);
    handle=graf_handle(&h,&gl_hchar,&h,&h);
    v_opnvwk(buff,&handle,buff);
    vst_color(handle,1);
    menu_register(gl_apid,"  Bildschirmuhr");
    while (1)
    {
        if (anz || weck)
        {
            t=Tgettime()>>5;
            h=t&0x3f;
            uhr[12]=h/10+'0';
            uhr[13]=h%10+'0';
            t>>=6;
            h=t&0x1f;
            uhr[9]=h/10+'0';
            uhr[10]=h%10+'0';
        }
        if (anz)
        {
            t=Tgetdate();
            h=t&0x1f;
            uhr[0]=h/10+'0';
            uhr[1]=h%10+'0';
            t>>=5;
            h=t&0xf;
            uhr[3]=h/10+'0';
            uhr[4]=h%10+'0';
            t>>=4;
            h=((t&0x7f)+80)%100;
            uhr[6]=h/10+'0';
            uhr[7]=h%10+'0';
            uhr[11]=':'+' '-uhr[11];
            disp(uhr);
        }
        if (weck)
            if (uhr[9]==strings[7][0] && uhr[10]==strings[7][1] &&
                uhr[12]==strings[7][2] && uhr[13]==strings[7][3])
            {
                Dosound(snd);
                form_alert(1,
                    "[1][|  Ich m”chte Sie an  |die Uhrzeit erinnern.][ OK ]");
                Dosound(off);
                weck=0;
            }
        if (uhr[11]==':') t=120;
        else t=80;
        lc=10;
        do
        {
            ereig=evnt_multi(MU_TIMER | MU_MESAG,
                0,0,0,0,0,0,0,0,0,0,0,0,0,buff,t,0,&h,&h,&h,&h,&h,&h);
            lc--;
        }
        while (!(ereig&MU_MESAG) && lc);
        if (ereig&MU_MESAG && *buff==AC_OPEN)
        {
            wind_update(BEG_UPDATE);
            form_dial(FMD_START,fm.g_x,fm.g_y,fm.g_w,fm.g_h,
                fm.g_x,fm.g_y,fm.g_w,fm.g_h);
            objc_draw(objekte,ROOT,MAX_DEPTH,fm.g_x,fm.g_y,fm.g_w,fm.g_h);
            form_do(objekte,WECKZEIT);
            form_dial(FMD_FINISH,fm.g_x,fm.g_y,fm.g_w,fm.g_h,
                fm.g_x,fm.g_y,fm.g_w,fm.g_h);
            objekte[OK].ob_state=OUTLINED|SHADOWED;
            h=anz;
            anz=objekte[UHR].ob_state;
            weck=objekte[WECKER].ob_state;
            if (h && !anz) disp(blk);
            wind_update(END_UPDATE);
        }
    }
}

