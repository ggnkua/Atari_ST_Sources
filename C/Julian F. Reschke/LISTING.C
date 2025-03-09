/*
    @(#)Atarium/icondemo.c
    (c)1995  MAXON Computer
    Autor: Julian F. Reschke, 20. M„rz 1995
    Demo zum Iconify
*/

#include <aes.h>

/* Erweiterungen fr PureC */

#define SMALLER         0x4000

#define WM_BUTTOMED     33
#define WM_ICONIFY      34
#define WM_UNICONIFY    35
#define WM_ALLICONIFY   36

#define WF_ICONIFY      26
#define WF_UNICONIFY    27

/* appl_getinfo fr AES >= 0x0400 und „ltere
   Systeme mit entsprechender Erweiterung */

static int
appl_xgetinfo (int type, int *out1, int *out2,
    int *out3, int *out4)
{
    static short hasagi = -1;

    if (hasagi < 0)
        hasagi = _GemParBlk.global[0] >= 0x400 ||
            appl_find( "?AGI\0\0\0\0") == 0;

    return !hasagi ? 0 :
        appl_getinfo (type, out1, out2, out3, out4);
}

/* Mittels appl_getinfo wird abgefragt, ob Iconify
   m”glich ist */

static int
has_iconify (void)
{
    static int hasit = -1;

    if (hasit < 0)
    {
        int dum, val = 0;

        hasit = 0;

        appl_xgetinfo (11, &val, &dum, &dum, &dum);
        if (val & 128) hasit = 1;
    }

    return hasit;
}

/* Events bearbeiten */

static void
do_events (int whandle)
{
    int mb[8], which, key, shiftstate;
    int done = 0, dummy;
    int iconified = 0;
    int wx, wy, ww, wh;

    /* Fenstermaže merken */
    wind_get (whandle, WF_CURRXYWH, &wx, &wy, &ww, &wh);

    while (!done)
    {
        which = evnt_multi (MU_KEYBD|MU_MESAG,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            mb, 0, 0, &dummy, &dummy, &dummy,
            &shiftstate, &key, &dummy);

        if (which & MU_KEYBD)
        {
            /* ^Q und ^U beenden */
            if ((key & 0xff) == 17) done = 1;
            if ((key & 0xff) == 21) done = 1;

            /* Vorschlag: Alt-Ctrl-Blank minimiert,
               mit zus„tzlicher Shift-Taste
               entspricht es WM_ALLICONIFY */
 
            if ((key & 0xff00) == 0x3900 &&
                (shiftstate & 12) == 12 &&
                has_iconify ())
            {
                which &= ~MU_KEYBD;
                which |= MU_MESAG;
                mb[0] = WM_ICONIFY;
                mb[3] = whandle;
            }
        }

        if (which & MU_MESAG)
        {
            switch (mb[0])
            {
                case WM_CLOSED:
                    done = 1;
                    break;

                case WM_ICONIFY:
                case WM_ALLICONIFY:
                case WM_UNICONIFY:
                    if (!iconified)
                    {
                        iconified = 1;
                        wind_close (whandle);
                        wind_set (whandle, WF_ICONIFY,
                            -1, -1, -1, -1);
                        wind_open (whandle, -1, -1,
                            -1, -1);
                    }
                    else
                    {
                        iconified = 0;
                        wind_set (whandle, WF_UNICONIFY,
                            wx, wy, ww, wh);
                    }
                    break;
            }
        }
    }
}


/* Fenster erzeugen, Events bearbeiten,
   Fenster schliežen */

static void
doit (void)
{
    int whandle;

    /* Fenster erzeugen und ”ffnen */
    whandle = wind_create (NAME|CLOSER|SMALLER,
        0, 0, 32767, 32767);

    if (whandle < 0) {
        form_alert (1, "[1][Out of window|handles!]"
            "[ OK ]");
        return;
    }

    wind_set (whandle, WF_NAME, " Iconify-Demo ");
    wind_open (whandle, 50, 100, 300, 100);

    /* Eventschleife aufrufen */
    do_events (whandle);

    /* Fenster schliežen und vernichten */
    wind_close (whandle);
    wind_delete (whandle);
}

int
main (void)
{
    appl_init ();
    graf_mouse (ARROW, 0);
    doit ();
    appl_exit ();
    return 0;
}
