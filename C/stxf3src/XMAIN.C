
/***************************************************************************

    XMAIN.C

    - main routine, GEM routines, etc.

    10/31/88 created

    09/09/93 11:00

***************************************************************************/

#include <stdio.h>
#include <osbind.h>
#include <obdefs.h>
#include <gemdefs.h>
#include <strings.h>
#include "xrsc30.h"
#include "xglobal.h"
#include "xsio.h"

#define fsel_exinput(a,b,c,d) fsel_input(a,b,c)

int appl_id;       /* our application ID */
int xdesk,ydesk,hdesk,wdesk;

extern short int planes;
extern short int bytes_lin;
extern short int bytes_2lin;
extern short int bytes_3lin;
extern short int bytes_4lin;
extern short int bytes_5lin;
extern short int bytes_6lin;
extern short int bytes_7lin;
extern short int bytes_8lin;

extern long rs_trindex[];

int fHidden;
int dummy;

OBJECT *objDesktop, *objDrives;

extern int rgwPal[16];
extern int rgwPalSav[16];


/****************************************************************/

int _memfree;
char STfont[1024];

/****************************************************************/

main()
    {
    register long lHeap;
    register int but, i;
    int fRadioBut = FALSE;
    int fRedraw = TRUE;
    register char *q;
	int dummy;

    /* initialize GEM */
    appl_id = appl_init();
    wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);

    graf_mouse(ARROW,0x0L);

    /* save current palette so we can do the Xformer palette */
    for (i=0; i<16; i++)
        rgwPalSav[i] = Setcolor(i, -1);

    /* check resolution */

	if ((fIsMono = Getrez()) == 0)
        {
		if ((wdesk < 600) || (hdesk < 180))
			{
	        form_alert(1,"[1][ Please switch to a higher | screen resolution! ][ OK ]");
    	    goto lQuit2;
			}
        }

    fIsMono >>= 1;      /* 0 = medium, 1 = high */
    lScr = Physbase();   /* get desktop screen address */

    lHeap = Malloc(-1L);
#ifdef DEBUG
    print("\033HFree space = %ld\n", lHeap);
#endif

    _memfree = (int)(lHeap/1024L);

    if (lHeap < 8192L)     /* some spare space to cover screen overflow */
        {
        form_alert(1,"[1][ Low on memory ][ Careful! ]");
        }

    Rsconf(7, 1, -1, -1, -1, -1);   /* set baud, 9=300, 7=1200, 4=2400 */

    fFastFP = FALSE;
    fXCD = FALSE;
    fXCP = FALSE;
    fBasic = TRUE;
    mdFont = 0;

    /* set up resource tree and draw desktop */
    rsc_fix();
    objDesktop = (OBJECT *) rs_trindex[DESKTOP];
    objDrives = (OBJECT *) rs_trindex[DRIVES];

	if (hdesk > (fIsMono ? 400 : 200))
    	form_center(objDesktop, &dummy, &dummy, &dummy, &dummy);
    wind_set(0, WF_NEWDESK, objDesktop, 0, 0);
    set_radio(objDesktop, RBFPFAST, fFastFP+1);
    set_radio(objDesktop, RBBASIC1, fBasic+1);
    set_radio(objDesktop, RBFONT1, mdFont);

    init_SIOV();

    redraw_desktop();

    lMemory = (((long)lMem0 + 65534L) & 0xFFFF0000L);
    lWStat = (long)lWStat0;

    q = (char *) (qoldbank = lMemory + 0x4000L);
    for (i=4; i<8; i++)
        {
        rgqBank[i] = (long)q;
        }

    q = (char *)lMem0;
    for (i=0; i<4; i++)
        {
        if (((unsigned long)lMemory - (unsigned long)q) < 16384L)
            q = (char *)lMemory + 65536L;
        rgqBank[i] = (long)q;
        q += 16384L;
        }

#ifdef DEBUG
    for (i=0; i<8; i++)
        {
        print("rgqBank[%d] = %ld %lx  \n", i, rgqBank[i], rgqBank[i]);
        }
    print("qoldbank = %lx  \n", qoldbank);
    print("lMemory = %lx  \n", lMemory);
    print("lMem0 = %lx  \n", (long)lMem0);
    Bconin(2);
#endif

    /* initialize text plotting routines to bypass GEM */
asm {
    dc.w    0xA000      ; returns A1 = pointer to array of font headers
	move.w  (A0),planes
	move.w	-2(A0),bytes_lin
    move.l  4(A1),A0    ; pointer to 8x8 font
    move.l  76(A0),lFont8
    move.l  8(A1),A0    ; pointer to 8x16 font
    move.l  76(A0),lFont16

    ; stuff STfont
    move.l  lFont8,A0
    lea     STfont,A1
    moveq   #7,D1
_1:
    moveq   #0,D2
_2:
    move.b  (A0)+,D0
    move.b  D0,0(A1,D2.w)
    addq.w  #8,D2
    cmpi.w  #1024,D2
    bne     _2
    lea     128(A0),A0
    addq.l  #1,A1
    dbf     D1,_1
    }

	bytes_2lin = bytes_lin*2;
	bytes_3lin = bytes_lin*3;
	bytes_4lin = bytes_lin*4;
	bytes_5lin = bytes_lin*5;
	bytes_6lin = bytes_lin*6;
	bytes_7lin = bytes_lin*7;
	bytes_8lin = bytes_lin*8;

#ifdef DEBUG
    print("_base = %lx _main = %lx main = %lx _tostack = %lx \n",
        _base, _main, main, _topstack);
    print("Heap locations:  heap: $%lx  \n", heap);
    print("lWStat: $%lx  \n", lWStat);
    print("lScrPtrs = %lx  \n", lScrPtrs);
    print("(display screen) lScr: $%lx  \n",lScr);
    print("lXLRAM = $%lx  \n", lXLRAM);
    print("lMem0 = %lx  \n", lMem0);
    print("(6502 main memory) lMemory: $%lx  \n", lMemory);
    print("fMono: %d  \n",fIsMono);
    print("&objDesktop = %lx  \n", &objDesktop);
    print("objDesktop = %lx  \n", objDesktop);
    print("*(long *)objDesktop = %lx  \n", *(long *)objDesktop);

    Bconin(2);
#endif

    init_atari();

    if (load_context(nameXCX))
        {
        do_do_execute();
        }
	else
		{
		goto Lautoboot;
		}

    loop
        {
        if (!fRadioBut)
            {
            sprint (((TEDINFO *)objDesktop[FRERAM].ob_spec)->te_ptext,
                "Free RAM: %04dK", _memfree);
            objc_draw(objDesktop, FRERAM, 1, xdesk, ydesk, wdesk, hdesk);
            }

        if (fRedraw)
            redraw_desktop();

        fRedraw = FALSE;
        fRadioBut = FALSE;

        but = form_do(objDesktop,0);

        fXCD = objDesktop[RBXCD].ob_state & SELECTED;
        fXCP = objDesktop[RBXCP].ob_state & SELECTED;

        if (but == BUTEXIT)
            break;

        switch(but)
            {
        default:
#ifdef DEBUG
            print("\033HUnknown button!!");
#endif
            break;

        case BUTPORST:
            init_atari();       /* ... and fall through */

        case BUTRESET:
Lautoboot:
            fReboot = TRUE;     /* ... and force a reboot */

        case BUTCONT:
            fTrace = FALSE;
            do_do_execute();
            fRedraw = TRUE;
            break;

        case BUT6502:
            hide_mouse();
            mon();
            show_mouse();
            fRedraw = TRUE;
            break;

        case BUTDEGAS:
            Redraw();
            save_DEGAS();
            break;

        case BUTLCNTX:
            if (!load_context(0L))
                fReboot = TRUE;
            break;

        case BUTSCNTX:
            save_context();
            break;

        case RBBASIC1:   /* normal font */
        case RBBASIC0:   /* international font */
            fRadioBut = TRUE;
            fBasic = but - RBBASIC0;    /* 0 of $FFFF */
            break;

        case RBFONT1:   /* normal font */
        case RBFONT2:   /* international font */
        case RBFONT3:   /* fat font */
        case RBFONT4:   /* ST font */
            fRadioBut = TRUE;
            mdFont = but - RBFONT1;
            break;

        case RBDRIVE1:
        case RBDRIVE2:
        case RBDRIVE3:
        case RBDRIVE4:
        case RBDRIVE5:
        case RBDRIVE6:
        case RBDRIVE7:
        case RBDRIVE8:
            configure_drive(but - RBDRIVE1);
            break;

        case RBFPSTND:
        case RBFPFAST:
            fRadioBut = TRUE;
            fFastFP = but - RBFPSTND;   /* 0 or $FFFF */
            break;

        case RBXCD:
            break;

        case RBXCP:
            break;
            }

        if (!fRadioBut)
            reset_button(but);
        }

    if (lHeap)
        Mfree(lHeap);       /* free the big memory block */

    wind_set( 0, WF_NEWDESK, 0L, 0 );

lQuit2:
    appl_exit();
    Setpalette(rgwPalSav);
    Supexec(_SIO_UnInit);
    exit(0);
    }


hide_mouse()
    {
    if(!fHidden)
        {
        graf_mouse(M_OFF,0x0L);
        fHidden=TRUE;
        }
    }

show_mouse()
    {
    if(fHidden)
        {
        graf_mouse(M_ON,0x0L);
        fHidden=FALSE;
        }
    }

do_dialog(dialog)
register OBJECT *dialog;
    {
    int but=0;
    int cx, cy, cw, ch, xc, yc;

    while (Bconstat(2))
        Bconin(2);

    /* center the dialog box */
    form_center(dialog, &cx, &cy, &cw, &ch);
    xc = cx + cw/2 ;
    yc = cy + ch/2 ;

    form_dial(FMD_START, 0,0,0,0, cx, cy, cw, ch);
    form_dial(FMD_GROW, xc,yc,0,0, cx, cy, cw, ch);
    
    objc_draw(dialog, 0, 10, cx, cy, cw, ch);

    but = form_do(dialog,0);
    dialog[but].ob_state &= ~SELECTED;

    form_dial(FMD_SHRINK, xc,yc,0,0, cx, cy, cw, ch);
    form_dial(FMD_FINISH, 0,0,0,0, cx, cy, cw, ch);

    return(but);
    }

reset_button(but)
int but;
    {
    objDesktop[but].ob_state &= ~SELECTED;
    objc_draw(objDesktop, but, 2, xdesk, ydesk, wdesk, hdesk);
    }

set_button(but)
int but;
    {
    objDesktop[but].ob_state |= SELECTED;
    objc_draw(objDesktop, but, 2, xdesk, ydesk, wdesk, hdesk);
    }


delay(cms)
int cms;
    {
    evnt_timer(cms,0);
    }

redraw_desktop()
    {
    hide_mouse();
    wind_update(BEG_UPDATE);
    Setpalette(rgwPalSav);
    Cconws("\033E");
    form_dial(FMD_START, 0,0,0,0, xdesk, ydesk, wdesk, hdesk);
    form_dial(FMD_FINISH, 0,0,0,0, xdesk, ydesk, wdesk, hdesk);
    wind_update(END_UPDATE);
    show_mouse();
    delay(0);       /* let other tasks get a crack at it */

#if 0
	print("xdesk, ydesk, wdesk, hdesk = %d, %d, %d, %d\n",
		xdesk, ydesk, wdesk, hdesk);
	print("planes = %d, bytes_lin = %d\n", planes, bytes_lin);
#endif
    }

#ifdef DEBUG

void _alert(pch)
register char *pch;
    {
    register int fPrinter;

    fPrinter = Cprnos();

    Cconws("\033j\033H\033p\033lAssertion failed: ");
    while (*pch)
        {
        if (fPrinter)
            Cprnout((int)*pch);
        Bconout(2,(int)*pch++);
        }
    if (fPrinter)
        {
        Cprnout(13);
        Cprnout(10);
        }
    Cconws("\033q\003l\033k\007");
    Bconin(2);
    }

#endif


do_execute()
    {
    if (!fTrace)
        {
        if (planes == 2)
            {
            Setscreen(-1L, -1L, 0);
            Setpalette(rgwAtColors);
            }
        Cconws("\033E");
        newDL();
        Redraw();
        }

    asm
        {
        movem.l D0-D7/A0-A6,-(A7)
        }

    loop
        {
        execute();

        Poke (764,255);     /* clear keyboard before re-entering */

        switch(exit_code)
            {
        default:
            break;
        case 0:
        case 1:
        case 2:
        case 3:
            goto lbreak;
        
        case 4:                     /* warm reset */
            fReboot = TRUE;
            break;

        case 5:                     /* cold reset */
            init_atari();
            fReboot = TRUE;
            break;

        case 8:                     /* SIO call */
            do_SIOV();
            break;

        case 10:                    /* F: open */
            F_open();
            break;

        case 11:                    /* F: close */
            F_close();
            break;

        case 12:                    /* F: get */
            F_get();
            break;

        case 13:                    /* F: put */
            F_put();
            break;

        case 14:                    /* F: status */
            F_stat();
            break;

        case 15:                    /* F: special (XIO) */
            F_XIO();
            break;
            }
        }

lbreak:

    asm
        {
        movem.l (A7)+,D0-D7/A0-A6
        }

    if (!fTrace)
        {
        if (planes == 2)
            Setscreen(-1L, -1L, 1);
        
        if (fIsMono)
            Setcolor(0,0x777);
        }
    }


do_do_do()
    {
    Supexec(do_execute);
    }

/* a kludge, since the Supexec call seems to return one level too high! */
/* a double kludge actually, since we can't seem to write to the keyboard
   in supervisor mode */
do_do_execute()
    {
    m_off();
    do_do_do();
    m_on();
    }

do_SIOV()
    {
    Supexec(SIOV);
    }

/*
**
** given a tree (pobj) and the first object (but) of a group of radio
** buttons, hilite the ith object
**
*/

set_radio(pobj, but, i)
register OBJECT *pobj;  /* pointer to tree */
register int but, i;
    {
    register int j=0;

    pobj += but;   /* pointer to object in tree */

    do
        {
        if (j++ == i)
            pobj->ob_state |= SELECTED;
        else
            pobj->ob_state &= ~SELECTED;
        } while ((++pobj)->ob_flags & RBUTTON);
    }

int get_radio(but)
register int but;
    {
    register int j=0;
    register OBJECT *pobj = &objDesktop[but];

    while (((pobj++)->ob_state & SELECTED) == 0)
        j++;

    return j;
    }

save_DEGAS()
    {
    int h, i=0;
    register char *szSavePic = "stxf_000.pi1";

    Redraw();
    if (fIsMono)
        {
        szSavePic[11] = '3';
        i = 2;
        Cconws("\033E");
        }
    else
        {
        Setscreen(-1L, -1L, 0);
        Setpalette(rgwAtColors);
        }

    newDL();
    Redraw();

    h = Fcreate(szSavePic, 0);
    if (h>=0)
        {
        Fwrite(h, 2L, &i);
        Fwrite(h, 32L, rgwAtColors);
        Fwrite(h, 32000L, lScr);
        Fclose(h);

        /* increment filename */
        if (++szSavePic[7] > '9')
            {
            szSavePic[7] = '0';
            if (++szSavePic[6] > '9')
                {
                szSavePic[6] = '0';
                if (++szSavePic[5] > '9')
                    {
                    szSavePic[5] = '0';
                    }
                }
            }
        }
    if (!fIsMono)
        {
        Setscreen(-1L, -1L, 1);
        }
    redraw_desktop();
    }


load_context(pch)
register char *pch;
    {
    register int h;
    long l = 0;
    int button;
    register int fAuto = FALSE;

    if (pch != (char *)0L)
        {
        fAuto = TRUE;
        goto autoboot;
        }

    pch = pathXCX;
    while (*pch)
        pch++;
    while (*pch != '\\')
        pch--;
    Blit("*.XCX", ++pch);

    fsel_exinput(pathXCX, nameXCX, &button,
          "Load context file...");
    if (button != 1)
        return;

    pch = pathXCX;
    while (*pch)
        pch++;
    while (*pch != '\\')
        pch--;
    Blit(nameXCX, ++pch);

    pch = pathXCX;

autoboot:
    h = Fopen(pch, 0);
    if (h>=0)
        {
        Fread(h, 4L, &l);
        if (l != 0x58460250)        /* check for magic word 'XF'25 */
            {
            h = -1;
            goto mw;
            }
        Fread(h, 220L, lEmul + 36L);
        l = Fread(h, fBasic ? 40960L : 49152L, lMemory);
mw:
        Fclose(h);
        }

    if ((h < 0) || (l < (fBasic ? 40960L : 49152L)))
        {
        if (!fAuto)
            form_alert(1,"[1][ Context load | error ][ Reboot ]");
        return FALSE;
        }
    return TRUE;
    }


save_context()
    {
    register int h;
    register long l;
    register char *pch = pathXCX;
    int button;

    while (*pch)
        pch++;
    while (*pch != '\\')
        pch--;
    Blit("*.XCX", ++pch);

    fsel_exinput(pathXCX, nameXCX, &button,
          "Save context file...");
    if (button != 1)
        return;

    pch = pathXCX;
    while (*pch)
        pch++;
    while (*pch != '\\')
        pch--;
    Blit(nameXCX, ++pch);

    h = Fcreate(pathXCX, 0);
    if (h>=0)
        {
        Fwrite(h, 224L, lEmul + 32L);
        l = Fwrite(h, fBasic ? 40960L : 49152L, lMemory);
        Fclose(h);
        }

    if ((h < 0) || (l < (fBasic ? 40960L : 49152L)))
        form_alert(1,"[1][ Context save | error ][ Yikes ]");
    }


/* reset all hardware registers and state variables to power on condition */

init_atari()
    {
    register int i,j;
    register char *pch;
    register long *pl;

    Blitc(0, lMemory, 49152);

    if (fBasic)
        {
        Blitb(ROMA000, lMemory + 0x0000A000, 0x3000);
        uAtRAM = 40960;
        }
    else
        {
        Blitb(ROMC000, lMemory + 0x0000C000, 0x1000);
        uAtRAM = 49152;
        }

    Blitb(ROMD000, lMemory + 0x0000D000, 0x0800);

    if (fFastFP)
        Blitb(ROMFAST, lMemory + 0x0000D800, 0x0800);
    else
        Blitb(ROMD800, lMemory + 0x0000D800, 0x0800);

    if (mdFont == 0)
        {
        Blitb(ROMCC00, lMemory + 0x0000E000, 0x0200);
        Blitb(ROME200, lMemory + 0x0000E200, 0x0100);
        Blitb(ROMCF00, lMemory + 0x0000E300, 0x0100);
        }
    else if (mdFont == 1)
        {
/*
        Blitb(ROMCC00, lMemory + 0x0000E000, 0x0200);
        Blitb(ROMCE00, lMemory + 0x0000E200, 0x0100);
        Blitb(ROMCF00, lMemory + 0x0000E300, 0x0100);
*/
        Blitb(ROMCC00, lMemory + 0x0000E000, 0x0400);
        }
    else if (mdFont == 2)
        {
        Blitb(ROME000, lMemory + 0x0000E000, 0x0400);
        }
    else if (mdFont == 3)
        {
        Blitb(STfont+256, lMemory + 0x0000E000, 0x0200);
        Blitb(ROME200, lMemory + 0x0000E200, 0x0100);
        Blitb(STfont+768, lMemory + 0x0000E300, 0x0100);
        }

    Blitb(ROME400, lMemory + 0x0000E400, 0x1C00);

#ifdef NEVER
    Poke (0xFC87, 0xEA); Poke (0xFC88, 0xEA); Poke (0xFC89, 0xEA); 
    Poke (0xC410, 0xEA); Poke (0xC411, 0xEA); Poke (0xC412, 0xEA); 
    Poke (0xEEFF, 0xEA); Poke (0xEF00, 0xEA); Poke (0xEF01, 0xEA); 
    Poke (0xEF02, 0xEA); Poke (0xEF03, 0xEA);
    Poke (0xC30B, 0x4C); Poke (0xC30C, 0x27); Poke (0xC30D, 0xC3); 
    Poke (0xC3AB, 0x4C); Poke (0xC3AC, 0xC4); Poke (0xC3AD, 0xC3); 
    Poke (0xC4ED, 0xEA); Poke (0xC4EE, 0xEA); Poke (0xC4EF, 0xEA); 
    Poke (0xC67B, 0x60);

    /* I dunno! */
    Poke (0xF98F, 0xEA); Poke (0xF990, 0xEA);

	/* Special text draw instruction for John Harris's code */
	Poke (0xF2B0, 0x82);
	Poke (0xF2B1, 0x82);
	Poke (0xF2B2, 0xEA);
#endif

    /* set reboot flag in OS variable */
    Poke (580,0xFF);

    /* set wStat array */

    /* make BASIC read-only */
    if (fBasic)
        Blitc(0x80, lWStat + 0xFFFFA000, 0x2000);

    /* make OS, and hardware regs all read-only (bankable) */
    Blitc(0x81, lWStat + 0xFFFFC000, 0x4000);

    /* make the rest of RAM normal */
    Blitc(0x00, lWStat + 0xFFFF8000, fBasic ? 0x2000 : 0x4000);
    Blitc(0x00, lWStat, 0x8000);

    /* clear out RAM under ROM */
    Blitc(0xFF, lXLRAM, 14336);

	/* mark XL ROM/RAM as ROM */
	fXLRAM = 0;

    /* do GTIA, POKEY, ANTIC chips */
    pch = (char *)lWStat + 0xFFFFD000;

    for (i=0; i<256; i++)
        {
        pch[0] = 0x90 + (i & 31);       /* GTIA */
        pch[0x200] = 0xB0 + (i & 15);   /* POKEY */
        pch[0x300] = 0x8C + (i & 3);    /* PIA */
        pch[0x400] = 0xC0 + (i & 15);   /* ANTIC */
        pch++;
        }

    /* disable color registers in mono */
    if (fIsMono)
        {
        Blitc(0x80, lWStat + 0xFFFFD016, 5);
        Blitc(0x80, lWStat + 0xFFFFD036, 5);
        Blitc(0x80, lWStat + 0xFFFFD056, 5);
        Blitc(0x80, lWStat + 0xFFFFD076, 5);
        Blitc(0x80, lWStat + 0xFFFFD096, 5);
        Blitc(0x80, lWStat + 0xFFFFD0B6, 5);
        Blitc(0x80, lWStat + 0xFFFFD0D6, 5);
        Blitc(0x80, lWStat + 0xFFFFD0F6, 5);
        }

    /* setup an initial screen (GR.0) */
    Blitc(0, rgDL, 1000);

    reg_PC = 0xC2AA;

    Supexec(_SIO_Init);
    }

configure_drive(iDrive)
int iDrive;
    {
    register char *pch;
    register DRIVE *pdrive = &rgDrives[iDrive];
    register OBJECT *objDrives = (OBJECT *) rs_trindex[DRIVES];
    register int but=0;
    int button;
    int cx, cy, cw, ch, xc, yc;
    register int i;
    long lLen;
    int h = -1, oldh;

    oldh = pdrive->h;

    switch(pdrive->mode)
        {
    case MD_EXT:
        i = (fXCD ? RBEXTERN : RBOFF);
        break;
    case MD_SD:
    case MD_ED:
    case MD_DD:
    case MD_QD:
        i = RBVIRTFD;
        break;
    case MD_HD:
        i = RBVIRTHD;
        break;
    case MD_35:
        i = RBXF35;
        break;
    case MD_RD:
        i = RBRD;
        break;
    case MD_OFF:
        i = RBOFF;
        break;
        }

    objDrives[RBXF35].ob_state |= DISABLED;

    set_radio(objDrives, RBEXTERN, i-RBEXTERN);

    *(char *)(((TEDINFO *)objDrives[TITLED1].ob_spec)->te_ptext + 3) =
        '1' + iDrive;

    /* center the objDrives box */
    form_center(objDrives, &cx, &cy, &cw, &ch);
    xc = cx + cw/2 ;
    yc = cy + ch/2 ;

    form_dial(FMD_START, 0,0,0,0, xdesk, ydesk, wdesk, hdesk);
    form_dial(FMD_GROW, xc,yc,0,0, cx, cy, cw, ch);
    
    if (pdrive->fWP)
        objDrives[RBWP].ob_state |= SELECTED;
    else
        objDrives[RBWP].ob_state &= ~SELECTED;

    objc_draw(objDrives, 0, 10, cx, cy, cw, ch);

    do
        {
        print("\033Y$W%d ", uBaudClock);

        but=form_do(objDrives,0);

        if (but == RBSPEED0)
            uBaudClock--;
        else if (but == RBSPEED1)
            uBaudClock = CLOCK192K;
        else if (but == RBSPEED2)
            uBaudClock++;
        else
            break;
        } while (TRUE);

    pdrive->fWP = objDrives[RBWP].ob_state & SELECTED;

    if ((pdrive->mode == MD_RD) && (but != RBRD) && (but != DRIVEXIT))
        {
        Mfree(pdrive->pbRAMdisk);
        _memfree += 180;
        }

    switch (but)
        {
    default:
        break;

    case RBEXTERN:
        pdrive->mode = MD_EXT;
        pdrive->wSectorMac = 1440;
        break;

    case RBVIRTFD:
        pch = pdrive->path;     /* force .XFD extender on path */
        while (*pch)
            pch++;
        while (*pch != '\\')
            pch--;
        Blit("*.XFD", ++pch);

        fsel_exinput(pdrive->path, pdrive->name, &button,
              "Configure virtual floppy disk...");
        if ((button == 1) && (file_len(pdrive, &lLen, &h)))
            {
            if (lLen == 368640L)
                {
                pdrive->mode = MD_QD;
                pdrive->wSectorMac = 1440;
                }
            else if (lLen == 184320L)
                {
                pdrive->mode = MD_DD;
                pdrive->wSectorMac = 720;
                }
            else if (lLen == 133120L)
                {
                pdrive->mode = MD_ED;
                pdrive->wSectorMac = 1040;
                }
            else if (lLen == 92160L)
                {                
                pdrive->mode = MD_SD;
                pdrive->wSectorMac = 720;
                }
            else
                {
        /*    print("length of file = %ld\n", lLen);
            Bconin(2); */
                goto lOFF;
                }

            pdrive->h = h;

            break;
            }

lOFF:
        form_alert(1,"[1][ Virtual disk file | is not valid. ][ Yikes! ]");
        pdrive->mode = MD_OFF;
        break;

    case RBVIRTHD:
        pch = pdrive->path;     /* force .XHD extender on path */
        while (*pch)
            pch++;
        while (*pch != '\\')
            pch--;
        Blit("*.XHD", ++pch);

        fsel_exinput(pdrive->path, pdrive->name, &button,
              "Configure virtual hard disk...");

        if ((button == 1) && (file_len(pdrive, &lLen, &h)))
            {
            if ((lLen & 0x00FFL) != 0L)
                goto lOFF;
            pdrive->mode = MD_HD;
            pdrive->wSectorMac = (unsigned)(lLen >> 8);
            pdrive->h = h;
            }
        else
            goto lOFF;
        break;

    case RBXF35:
        pdrive->mode = MD_35;
        pdrive->wSectorMac = 720;
        break;

    case RBRD:
        if (pdrive->mode != MD_RD)
            {
            pdrive->mode = MD_RD;
            pdrive->wSectorMac = 720;
            pdrive->pbRAMdisk = (char *)Malloc(184320L);
            if (pdrive->pbRAMdisk == 0L)
                {
                pdrive->mode = MD_OFF;
                form_alert(1,"[1][ No memory | for RAMdisk ][ oops ]");
                }
            else
                {
                Blitzl(pdrive->pbRAMdisk, 46080);
                _memfree -= 180;
                }
            }
        break;

    case RBOFF:
        pdrive->mode = MD_OFF;
        break;
        }

    if (but == DRIVEXIT)
        objDrives[but].ob_state &= ~SELECTED;
    else
        update_drive(iDrive);

    form_dial(FMD_SHRINK, xc,yc,0,0, cx, cy, cw, ch);
    form_dial(FMD_FINISH, 0,0,0,0, xdesk, ydesk, wdesk, hdesk);

    /* if we opened a new virtual disk, and one was already opened,
    ** close the old one. */
    if ((h >= 0) && (oldh >= 0))
        Fclose(oldh);
    }

update_drive(iDrive)
int iDrive;
    {
    register char *pch;
    char *pchText;

    pchText = ((TEDINFO *)objDesktop[RBDRIVE1+iDrive].ob_spec)->te_ptext;

    switch(rgDrives[iDrive].mode)
        {
    default:
        pch = "???";
        break;

    case MD_EXT:
        pch = " * External *";
        break;

    case MD_SD:
    case MD_ED:
    case MD_DD:
    case MD_QD:
    case MD_HD:
        *pchText++ = rgDrives[iDrive].path[0];
        *pchText++ = ':';
        pch = rgDrives[iDrive].name;
        break;

    case MD_35:
        pch = " * XF35 A: *";
        break;

    case MD_RD:
        pch = " * RAMDISK *";
        break;

    case MD_OFF:
        pch = " * off *";
        break;
        }

    Blit(pch, pchText);
    }

/*
**
** Attempt to open the file, whose path and name are pointed to by pdrive.
** If the file opens, store the handle in *ph, and store the length of
** the file in *pl. Return TRUE.
** If the file does not exist, return FALSE.
**
*/

int file_len(pdrive, pl, ph)
register DRIVE *pdrive;
register long *pl;
register int *ph;
    {
    char rgch[80];
    int err;
    register char *pch = rgch;

    /* set drive */
#ifdef DEBUG
    print("Setting path\n");
#endif
    Dsetdrv(pdrive->path[0] - 'A');

    /* remove file mask from path */
    Blit(&pdrive->path[2], rgch);
    while (*pch)
        pch++;

    while (--pch > rgch)
        {
        if (*pch == '*' || *pch == '?')
            {
            while (*--pch != '\\')
                ;
            *pch = 0;
            break;
            }
        else if (*pch == '\\')
            break;
        }
    *++pch = 0;
    rgch[0] = '\\';


    /* set path */
    err = Dsetpath(rgch);
#ifdef DEBUG
    print("Setpath error = %d\n", err);    
#endif

    /* open file */
    err = Fopen(pdrive->name, pdrive->fWP ? 0 : 2);
#ifdef DEBUG
    print("Fopen error = %d\n", err);    
#endif

    if (err < 0)
        return FALSE;

    *ph = err;

    *pl = Fseek(0L, err, 2);
#ifdef DEBUG
    print("File size = %ld\n", *pl);
#endif
    return TRUE;
    }

