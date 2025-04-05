/**************************************/
/*                                    */
/*   MOUSE.C ist PD-SOURCE-SOFTWARE   */
/*                                    */
/*         by G. Gerhardt             */
/*            Siekhammer 34           */
/*            4930  Detmold           */
/*                                    */
/**************************************/

#include <osbind.h>
#include <gemdefs.h>
#include <obdefs.h>

#define F1 6
#define F2 7
#define T1 11
#define T2 12
#define OK 14
#define NUM_OBS 15
#define NUM_TI 5

char *strings[]=
{
    "","Mouse Accelerator","by G. Gerhardt",
    "Factor","1","1.5","2",
    "Trigger","0","1","2",
    "OK"
};

TEDINFO txtinfo[]=
{
     1L,  0L,  0L, 3, 6, 2, 0x1180, 0x0, 255, 18, 1,
     2L,  0L,  0L, 5, 6, 2, 0x1180, 0x0, 255, 15, 1,
     3L,  0L,  0L, 3, 6, 2, 0x1100, 0x0, 255,  7, 1,
     7L,  0L,  0L, 3, 6, 2, 0x1100, 0x0, 255,  8, 1,
    11L,  0L,  0L, 3, 6, 2, 0x1180, 0x0, 254,  3, 1
};

OBJECT objekte[]=
{
    -1,  1, 14, G_BOX,     NONE, OUTLINED, 0x31141L,   0,0, 30,10,
     4,  2,  3, G_BOX,     NONE, 0x30,     0xFE1100L,  2,1, 26,2,
     3, -1, -1, G_TEXT,    NONE, NORMAL,   0x0L,       0,0, 26,1,
     1, -1, -1, G_TEXT,    NONE, NORMAL,   0x1L,       0,1, 26,1,
     9,  5,  8, G_BOX,     NONE, 0x30,     0xFE1100L,  2,4, 26,1,
     6, -1, -1, G_TEXT,    NONE, NORMAL,   0x2L,       0,0, 12,1,
     7, -1, -1, G_BUTTON,  0x11, NORMAL,   0x4L,      12,0,  4,1,
     8, -1, -1, G_BUTTON,  0x11, SELECTED, 0x5L,      17,0,  4,1,
     4, -1, -1, G_BUTTON,  0x11, NORMAL,   0x6L,      22,0,  4,1,
    14, 10, 13, G_BOX,     NONE, 0x30,     0xFE1100L,  2,6, 26,1,
    11, -1, -1, G_TEXT,    NONE, NORMAL,   0x3L,       0,0, 12,1,
    12, -1, -1, G_BUTTON,  0x11, SELECTED, 0x8L,      12,0,  4,1,
    13, -1, -1, G_BUTTON,  0x11, NORMAL,   0x9L,      17,0,  4,1,
     9, -1, -1, G_BUTTON,  0x11, NORMAL,   0xAL,      22,0,  4,1,
     0, -1, -1, G_BOXTEXT, 0x27, 0x30,     0x4L,      11,8,  8,1
};

char speed=2,trigger=0,dxy;
long *kbdvec,oldvec;
extern int gl_apid;

static rega4();
asm
{
    rega4:
    dc.l 0
}

mousemove()
{
asm
{
    movem.l D0/A1/A4,-(A7)
    move.l  rega4(PC),A4
    move.l  oldvec(A4),A1
    move.b  trigger(A4),D0
    cmp.b   1(A0),D0
    blt.s   L1
    neg.b   D0
    cmp.b   1(A0),D0
    bgt.s   L1
    cmp.b   2(A0),D0
    bgt.s   L1
    neg.b   D0
    cmp.b   2(A0),D0
    bge.s   L4
L1: move.b  speed(A4),D0
    jsr     (A1)
    subq.b  #1,D0
    beq.s   L5
    subq.b  #1,D0
    bne.s   L4
    move.b  1(A0),D0
    asr.b   #1,D0
    bcc.s   L2
    bchg    #0,dxy(A4)
    beq.s   L2
    addq.b  #1,D0
L2: move.b  D0,1(A0)
    move.b  2(A0),D0
    asr.b   #1,D0
    bcc.s   L3
    bchg    #1,dxy(A4)
    beq.s   L3
    addq.b  #1,D0
L3: move.b  D0,2(A0)
L4: jsr     (A1)
L5: movem.l (A7)+,D0/A1/A4
}
}

main()
{
    int buff[57],h;
    GRECT fm;

    asm
    {
        lea     rega4(PC),A0
        move.l  A4,(A0)
    }
    appl_init();
    menu_register(gl_apid,"  Mouse Speed");
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
    kbdvec=(long *)Kbdvbase();
    oldvec=kbdvec[4];
    kbdvec[4]=(long)mousemove;
    while (1)
    {
        evnt_multi(MU_MESAG,
            0,0,0,0,0,0,0,0,0,0,0,0,0,buff,0,0,&h,&h,&h,&h,&h,&h);
        if (*buff==AC_OPEN)
        {
            wind_update(BEG_UPDATE);
            form_dial(FMD_START,fm.g_x,fm.g_y,fm.g_w,fm.g_h,
                fm.g_x,fm.g_y,fm.g_w,fm.g_h);
            objc_draw(objekte,ROOT,MAX_DEPTH,fm.g_x,fm.g_y,fm.g_w,fm.g_h);
            form_do(objekte,0);
            form_dial(FMD_FINISH,fm.g_x,fm.g_y,fm.g_w,fm.g_h,
                fm.g_x,fm.g_y,fm.g_w,fm.g_h);
            objekte[OK].ob_state=OUTLINED|SHADOWED;
            if (objekte[F1].ob_state) speed=1;
            else if (objekte[F2].ob_state) speed=2;
            else speed=3;
            if (objekte[T1].ob_state) trigger=0;
            else if (objekte[T2].ob_state) trigger=1;
            else trigger=2;
            wind_update(END_UPDATE);
        }
    }
}

