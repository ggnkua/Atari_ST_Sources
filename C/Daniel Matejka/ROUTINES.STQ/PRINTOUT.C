/**********************************************************************/
/* PRINTOUT.C - Unit responsible for Printing Files                   */
/* 20 Mar 86                                                          */
/* Copyright 1986 Daniel Matejka                                      */
/* Feel free to use this (it's been done before),                     */
/* but credit would be appreciated...                                 */
/**********************************************************************/

/*  Procedures of interest are:  startprint(), endprint(), and printstr().
    startprint() initializes whatever needs to be initialized for the
    print session.  endprint() reverses whatever startprint() does that
    needs to be reversed.  printstr() takes a string and shoves it onto
    the output device.
*/

#include <gemdefs.h>
#include <osbind.h>

#define USEMEMOPS    1      /* use the Assembly language unit MEMOPS */

#define PAGELENGTH  58      /* # lines to print before form feed */
#define PAGEWIDTH   80      /* # of columns across page of printer */

static int  oktocontinue,   /* human flagged a stop */
            toprinter,      /* destination */
            pagewidth,      /* number of characters across page */
            curline,        /* current line number, for pagination */
            curcol,         /* current column number, for line wrap */
            dofff,          /* do form feed flag */
            pbindex,        /* index in printer buffer */
            scpixel,        /* screen (vertical) location */
            window,         /* display window handle */
            windrect[4],    /* window work area position and size */
            scrollrect[4],  /* subset of windrect[] for scrolling */
            *scrbase;       /* screen memory location */

static char *pagehdr[2],    /* page header */
            *prnbuffer;     /* (screen) printer buffer */

extern int  schandle,       /* screen handle from v_opnvwk() */
            cellwidth,
            cellheight,     /* current font cell size */
            ptsin[];        /* allocated by main unit for GEM */

/************************************************************************/
/*     Some utility routines useful to the point of being necessary     */
/************************************************************************/

/* C versions of the Assembly procedures in MEMOPS.S */

#if USEMEMOPS == 0
/********** set memory to some byte value **********/
setmem(addr,count,val)
    register char *addr;
    register int count,val; {

    while (count--)
        *addr++ = val;
} /* end setmem */

/********** move memory from one location to another **********/
movmem(source,dest,count)
    register char *source,*dest;
    register int count; {

    if (source > dest)
        while (count--)
            *dest++ = *source++;
    else {
        source += count;
        dest += count;
        while (count--)
            *--dest = *--source;
    }
} /* end movmem */
#endif

/********** return string length **********/
int strlen(s)
    char *s; {

    register char *seeker;

    seeker = s;
    while (*seeker++);
    return (int) (seeker-s) - 1;
} /* end strlen */

/********** copy second string into first string **********/
strcpy(a,b)
    register char *a,*b; {

    while (*a++ = *b++);
} /* end strcpy */

/************************************************************************/
/************************** Printing Routines ***************************/
/************************************************************************/

/********** scroll the active window **********/
scroll(dy)
    int dy; {

    register int linesize,    /* number of words in a screen line */
                 linewidth,   /* number of BYTES in a scrollrect[] line */
                 linestart,   /* beginning of scrollrect[] line */
                 ctr;

    ctr = 2 - Getrez();
    linesize = ctr == 0 ? 40 : 80; /* 40 words high, 80 low/med */
    linewidth = (scrollrect[2] >> 3) << ctr;
    linestart = (scrollrect[0] >> 4) << ctr;

    v_hide_c(schandle);
                        
    /* scroll up dy pixels */
    for (ctr = scrollrect[1]+dy; ctr < scrollrect[1]+scrollrect[3]; ctr++)
        movmem(scrbase + linesize*ctr +      linestart,
               scrbase + linesize*(ctr-dy) + linestart,
               linewidth);

    /* clear duplicate area at bottom */
    ptsin[0] = scrollrect[0];
    ptsin[1] = scrollrect[1] + scrollrect[3];
    ptsin[2] = ptsin[0] + scrollrect[2] - 1;
    ptsin[3] = ptsin[1] - dy;
    vr_recfl(schandle,ptsin);

    v_show_c(schandle,1);
} /* end scroll */

/********** print a status line (screen reports) **********/
static statusline(which)
    int which; {

    char msg[60];

    if (!which) { /* mouse is out there causing trouble */
        v_hide_c(schandle);          /* take mouse back */
        wind_update(BEG_MCTRL);
    }

    /* erase unscrolled area at window bottom */
    ptsin[0] = scrollrect[0] + 1;
    ptsin[2] = scrollrect[0] + scrollrect[2] - 1;
    ptsin[1] = scrollrect[1] + scrollrect[3];
    ptsin[3] = windrect[1] + windrect[3] - 1;
    vr_recfl(schandle,ptsin);

    if (which)
        strcpy(msg,"any key continues ...");
    else
        strcpy(msg,"<Space> pauses, <Return> quits");
    v_gtext(schandle,
        scrollrect[0],scrollrect[1] + scrollrect[3] + 3*cellheight/2,
        msg);

    if (which) {
        wind_update(END_MCTRL);                     /* give mouse back */
        v_show_c(schandle,0);
        evnt_keybd();                               /* hang out */
    }
} /* end statusline */

/********** start a new page **********/
static newpage() {

    curline = 0;                   /* reset line counter */
    if (toprinter) {
        if (*pagehdr[0]) {         /* print first line of page header */
            printstr(pagehdr[0]);
            printchar('\r');
            printchar('\n');
        }
        if (*pagehdr[1])           /* print second line */
            printstr(pagehdr[1]);
        printchar('\r');
        printchar('\n');
        printchar('\n');
    } else {
        if (*pagehdr[0])           /* likewise */
            v_gtext(schandle,scrollrect[0],scrollrect[1]-2*cellheight,
                pagehdr[0]);
        if (*pagehdr[1])
            v_gtext(schandle,scrollrect[0],scrollrect[1]-cellheight,
                pagehdr[1]);
    }
} /* end newpage */

/********** is printer on-line and awake? **********/
static int prstatus() {

    evnt_timer(50,0); /* Atari needs some time to think: 1/20th second */
    return (int) gemdos(0x11);
} /* end prstatus */

/********** did human ask us to pause or stop? **********/
static checkeydown() {

    int key;

    key = 0;
    if ((int) gemdos(0xB) != 0) {              /* key has been pressed */
        key = evnt_keybd() & 0xFF;             /* eat it */
        switch (key) {
            case ' ' :
                if (toprinter)
                    form_alert(1,"[1][Printing Paused][Continue]");
                else {
                    statusline(1);             /* demand another */
                    statusline(0);
                }
                break;
            case '\r' :
                oktocontinue = 0;              /* stop */
        } /* end switch (key) */
    } /* end key pressed */
} /* end checkeydown */

/********** print a character **********/
static printchar(c)
    int c; {

    int ctr,delay;

    if (dofff && c != '\n') { /* form feed flag set: do it first */
        dofff = 0;
        newpage();
    }

    if (c == '\n' && curline >= PAGELENGTH ||
        c == '\0' && curline >= PAGELENGTH+2) /* skip perf */
        c = '\f';
    if (c == '\0') /* '\0' means newline, but delay skip perf */
        c = '\n';
    if (c == '\n' && toprinter)
        curline++;
    if (c == '\f') {
        curline = 0;    /* because '\n' is called repeatedly */
        dofff = 1;
    }

    if (toprinter){
        gemdos(0x05,c);            /* send character to printer */
        if (c == '\r') {
            curcol = 0;            /* new line: reset line counter */
            checkeydown();         /*           check for instructions */
        } else if (c != '\n' && c != '\f')
            curcol++;
    } else                         /* to screen */
        switch (c) {
            case '\n' :
                scpixel += cellheight;
                if (scpixel > scrollrect[1] + scrollrect[3]) {
                    scpixel -= cellheight;
                    scroll(cellheight);
                }
                break;
            case '\f' :     /* page length < 10 go boom, here */
                for (ctr = 0; ctr < 10; ctr++)
                    printchar('\n');
                break;
            case '\r' :
                prnbuffer[pbindex] = 0;
                pbindex = 0;
                curcol = 0;
                v_gtext(schandle,scrollrect[0],scpixel,prnbuffer);
                /* wait a bit, just to slow down the screen printout.
                   evnt_timer() seems to eat the typeahead */
                for (delay = 0; delay < 1000; delay++)
                    checkeydown();
                break;
            default :
                prnbuffer[pbindex++] = c;
                curcol++;
        } /* end switch (c) */
} /* end printchar */

/********** output a string, with wordwrap **********/
printstr(ptr)
    char *ptr; {

    register char *seeker;         /* looks for word boundaries */
    char *rmargin;                 /* don't print past this ... */

    while (oktocontinue && *ptr) {

        /* look for next word end or string end */
        rmargin = ptr + (pagewidth-curcol);
        seeker = ptr;
        if (*ptr == ' ' || *ptr == '\r')
            seeker++;
        while (*seeker != ' ' && *seeker != 0 && *seeker != '\r')
            seeker++;

        /* if word fits on line, or is too long to fit comfortably */
        if (seeker < rmargin || seeker - ptr > pagewidth/2)
            while (ptr < seeker && ptr < rmargin)
                printchar(*ptr++);

        /* go to next line, if necessary */
        if (curcol + (seeker - ptr) >= pagewidth) {
            printchar('\r');
            printchar('\0');
            while (*ptr == ' ')
                ptr++;
        }
    } /* end while */
} /* end printstr */

/********** initialize a print session **********/
static startprint() {

    toprinter = form_alert(1,"[1][Send display to][Screen|Printer]") == 2;

    oktocontinue = 1;
    if (toprinter)
        while (oktocontinue && !prstatus())
            oktocontinue = 1 == form_alert(1,
                "[3][Turn on the printer][OK|Cancel]");
    else {
        if (!openwind()) {
            oktocontinue = 0;
            form_alert(1,"[3][Please close|some windows.][ OK ]");
            /* zero these pointers so endprint()'s free() won't choke */
            prnbuffer = 0;
            pagehdr[0] = 0;
            pagehdr[1] = 0;
            return;
        }
        clrwindow();
        statusline(0);
    }
    if (toprinter)
        pagewidth = PAGEWIDTH;
    else
        pagewidth = scrollrect[2]/cellwidth;

    if (pagewidth & 1)   /* make it even */
        pagewidth++;

    prnbuffer = Malloc((long) (pagewidth+2));
    pagehdr[0] = Malloc((long) (pagewidth+2));
    pagehdr[1] = Malloc((long) (pagewidth+2));
    curline = 0;
    curcol = 0;
    pbindex = 0;
    dofff = 1;
    scpixel = scrollrect[1] + cellheight - 1;
    scrbase = (int *) xbios(3);
} /* end startprint */

/********** end a print session **********/
static endprint() {

    if (toprinter) {
        if (prstatus())         /* was printer-turn-on cancelled? */
            printchar('\f');
    } else {
        statusline(1);
        wind_close(window);
        wind_delete(window);
    }

    if (pagehdr[1])
        Mfree(pagehdr[1]);
    if (pagehdr[0])
        Mfree(pagehdr[0]);
    if (prnbuffer)
        Mfree(prnbuffer);
} /* endprint */

/********** center a pageheader **********/
centerhdr(hdr)
    char *hdr; {

    int hdrlen,hdroff;

    hdrlen = strlen(hdr);
    hdroff = (pagewidth-hdrlen)/2;
    if (hdroff > 0) {
        movmem(hdr,hdr+hdroff,hdrlen+1);
        setmem(hdr,hdroff,' ');
    }
} /* end centerhdr */

/************************************************************************/
/************************* Dealing with Windows *************************/
/************************************************************************/

/********** clear the display window **********/
clrwindow() {

    v_hide_c(schandle);

    ptsin[0] = windrect[0];
    ptsin[1] = windrect[1];
    ptsin[2] = windrect[0]+windrect[2]-1;
    ptsin[3] = windrect[1]+windrect[3]-1;
    vr_recfl(schandle,ptsin);

    v_show_c(schandle,1);
} /* end clrwindow */

/********** open the display window **********/
/* Value returned is nonzero iff it worked */
int openwind() {

    int wbx,wby,wbw,wbh,      /* window border size and position */
        algn;                 /* alignment guide */

    wind_get(0,WF_WORKXYWH,&wbx,&wby,&wbw,&wbh); /* desktop window size */

    /* use something less than the whole screen for the display window */
    wbh /= 2;
    wby += wbh/2;
    wbw = 4*wbw/5;
    wbx += wbw/10;

    wind_calc(WC_WORK,NAME,wbx,wby,wbw,wbh,
        &windrect[0],&windrect[1],&windrect[2],&windrect[3]);
    window = wind_create(NAME,wbx,wby,wbw,wbh);
    if (window < 0)
        return 0;
    wind_set(window,WF_NAME," See the file... ");
    wind_open(window,wbx,wby,wbw,wbh);

    /* set up scroll area, which is subset of window on a word boundary */
    movmem(windrect,scrollrect,4*sizeof(int));

    /* allow some space for unscrolled lines on top and bottom */
    scrollrect[1] += 3*cellheight;  /* three on top */
    scrollrect[3] -= 5*cellheight;  /* and two on bottom */
    scrollrect[3] = cellheight*(scrollrect[3]/cellheight);

    /* align scrollrect[] on a word boundary */
    algn = scrollrect[0] & 0xF;    /* is it already? */
    if (algn) {                     /* No, adjust scroll area */
        scrollrect[0] = (scrollrect[0] + 0x10) & ~0xF;
        scrollrect[2] = (scrollrect[2] + algn - 0x10) & ~0xF;
    } else
        scrollrect[2] &= ~0xF;

    return 1;
} /* end openwind */

/************************************************************************/
/************************** The Driver Routine **************************/
/************************************************************************/

/********** read and display a file **********/
showfile(fname)
    char *fname; {

    int  fhandle,                  /* file TOS handle */
         readlen,                  /* number of bytes to read */
         actlen;                   /* number of bytes actually read */
    long flength,                  /* number of bytes in file */
         fpos;                     /* current position */
    char *buffer;                  /* read/print buffer */

    fhandle = Fopen(fname,0);
    if (fhandle < 0) {
        form_alert(1,"[1][That file doesn't exist.][ Fool ]");
        return;
    }
    flength = Fseek(0L,fhandle,2); /* inquire file length */
    Fseek(0L,fhandle,0);           /* back to the beginning */
    buffer = Malloc(514L);  /* one block + space needed by printstr() */
    startprint();
    fpos = 0L;

    strcpy(pagehdr[0],"Some Sort of");
    strcpy(pagehdr[1],"Header");
    centerhdr(pagehdr[0]);
    centerhdr(pagehdr[1]);

    while (oktocontinue) {
        readlen = flength-fpos > 512 ? 512 : flength-fpos;
        if (readlen > 0) {
            actlen = Fread(fhandle,(long) readlen,buffer);
            fpos += actlen;
            buffer[actlen] = 0;
            printstr(buffer);
            if (actlen != readlen) {
                form_alert(1,"[3][File is damaged][OK|Not OK]");
                oktocontinue = 0;
            }
        } else
            oktocontinue = 0;
    }

    endprint();
    Mfree(buffer);
    Fclose(fhandle);
} /* end showfile */

static char copyright[] = { "(C) 1986 by Daniel Matejka " };

