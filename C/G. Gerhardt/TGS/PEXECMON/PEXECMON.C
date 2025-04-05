/**************************************/
/*                                    */
/* PEXECMON.C ist PD-SOURCE-SOFTWARE  */
/*                                    */
/*         by G. Gerhardt             */
/*            Siekhammer 34           */
/*            4930  Detmold           */
/*                                    */
/**************************************/

#include <osbind.h>
#include <gemdefs.h>
#include <obdefs.h>

#define OK 13
#define NUM_OBS 14

char titl[]="Programs executed by Pexec";
char cmds[10][71],*com,*fil;
char okbt[]="OK";
int nxtfree;

OBJECT objekte[]=
{
    -1,  1, 13, G_BOX,    NONE, OUTLINED, 0x31141L,    0,0, 74,16,
     2, -1, -1, G_BUTTON, NONE, NORMAL,(long)titl,     2,1, 70,1,
    13,  3, 12, G_BOX,    NONE, NORMAL,   0xFF1100L,   2,3, 70,10,
     4, -1, -1, G_STRING, NONE, NORMAL,(long)cmds[0],  0,0, 70,1,
     5, -1, -1, G_STRING, NONE, NORMAL,(long)cmds[1],  0,1, 70,1,
     6, -1, -1, G_STRING, NONE, NORMAL,(long)cmds[2],  0,2, 70,1,
     7, -1, -1, G_STRING, NONE, NORMAL,(long)cmds[3],  0,3, 70,1,
     8, -1, -1, G_STRING, NONE, NORMAL,(long)cmds[4],  0,4, 70,1,
     9, -1, -1, G_STRING, NONE, NORMAL,(long)cmds[5],  0,5, 70,1,
    10, -1, -1, G_STRING, NONE, NORMAL,(long)cmds[6],  0,6, 70,1,
    11, -1, -1, G_STRING, NONE, NORMAL,(long)cmds[7],  0,7, 70,1,
    12, -1, -1, G_STRING, NONE, NORMAL,(long)cmds[8],  0,8, 70,1,
     2, -1, -1, G_STRING, NONE, NORMAL,(long)cmds[9],  0,9, 70,1,
     0, -1, -1, G_BUTTON, 0x27, NORMAL,(long)okbt,    33,14, 8,1
};

extern int gl_apid;

static rega4();
asm
{
    rega4:
    dc.l 0
}

static oldvec();
asm
{
    oldvec:
    dc.l 0
}

trap1()
{
    int i;

    asm
    {
        move.w  4(A6),D0
        btst    #13,D0
        bne     supmode
        move.l  USP,A0
        bra     save
        supmode:
        lea     10(A6),A0
        save:
        movem.l D0-A5,-(A7)
        move.l  rega4(PC),A4
        move.w  (A0),D0
        cmp.w   #0x4b,D0
        bne     ende
        tst.w   2(A0)
        bne     ende
        move.l  4(A0),fil(A4)
        move.l  8(A0),com(A4)
    }
    if (nxtfree==10)
    {
        nxtfree--;
        for (i=0;i<9;i++)
            strcpy(cmds[i],cmds[i+1]);
    }
    strncpy(cmds[nxtfree],fil,69);
    strncat(cmds[nxtfree],com,70-strlen(cmds[nxtfree]));
    nxtfree++;
    asm
    {
        ende:
        movem.l (A7)+,D0-A5
        unlk    A6
        move.l  oldvec(PC),A0
        jmp     (A0)
    }
}

inittrap()
{
    asm
    {
        lea     rega4(PC),A0
        move.l  A4,(A0)
        lea     oldvec(PC),A0
        move.l  0x84,(A0)
        lea     trap1(PC),A0
        move.l  A0,0x84
    }
}

main()
{
    int buff[57],h;
    GRECT fm;

    appl_init();
    menu_register(gl_apid,"  Pexec Monitor");
    for (h=0;h<NUM_OBS;h++)
        rsrc_obfix(objekte,h);
    form_center(objekte,&fm.g_x,&fm.g_y,&fm.g_w,&fm.g_h);
    Supexec(inittrap);
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
            objekte[OK].ob_state=NORMAL;
            wind_update(END_UPDATE);
        }
    }
}

