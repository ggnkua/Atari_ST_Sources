/*
    IDs und Grîûen der SystemzeichensÑtze erfragen

    Julian F. Reschke, 13. Januar 1995
    Verbesserung des Hacks fÅr TOS <4.0, zusÑtzlich
    BerÅcksichtigung von MagiC!, ?AGI, AFnt und SMAL
    Christoph G.A. Zwerschke, 4. Februar 1995
    AFnt in appl_xgetinfo verlegt
    Hayo Schmidt, 18. April 1195
*/

#include <aes.h>
#include <vdi.h>
#include <stdio.h>
#include <tos.h>


/* AES-Font Cookie-Struktur */

typedef struct
{
    long af_magic; /* AES-Font ID (AFnt) */
    int version;   /* Highbyte Cookieversion (BCD-Format)
                      Lowbyte Programmversion (BCD-Format) */
    int installed; /* Flag fÅr Fonts angemeldet */
    int cdecl (*afnt_getinfo)(int af_gtype, /* Aufruf */
        int *af_gout1,int *af_gout2,int *af_gout3,int *af_gout4);
}   AFNT;

int
get_cookie(long cookie,long *value)
{
    long oldstack,*cookiejar;

    oldstack=Super(NULL);
    cookiejar=*(long **)0x5a0;
    Super((void *)oldstack);
    if (cookiejar==NULL) return 0;
    do
    {
        if (cookiejar[0]==cookie)
        {
            if (value) *value=cookiejar[1];
            return 1;
        }
        else
            cookiejar+=2;
    }   while (cookiejar[-2]);
    return 0;
}

int
appl_xgetinfo(int type,int *out1,int *out2,int *out3,int *out4)
{
    static int has_agi=-1; 
    long cookie;
    AFNT *afnt;

    if (has_agi<0)
        has_agi=(_GemParBlk.global[0]>=0x400       /* AES 4.0? */
            || appl_find("?AGI")==0)               /* "?AGI"? */
            || (get_cookie('MagX',&cookie)
                && ((int **)cookie)[2][24]>=0x200);/* MagiC! 2.0? */
    if (has_agi)
        return appl_getinfo(type,out1,out2,out3,out4);
    if (get_cookie('AFnt',(long *)&afnt) && afnt->af_magic == 'AFnt') 
        return afnt->afnt_getinfo(type,out1,out2,out3,out4);
    return 0;
}

static int
load_font (int vdihandle, int fontid)
{
    int loaded = 0;

    if (fontid != vst_font (vdihandle, fontid) && vq_gdos ())
    {
        vst_load_fonts (vdihandle, 0);
        loaded = 1;
    }

    return loaded;
}

void
FontAESInfo (int vdihandle, int *pfontsloaded,
    int *pnormid, int *pnormheight,
    int *piconid, int *piconheight)
{
    static int done = 0;
    static int normid, normheight;
    static int iconid, iconheight;
    int fontsloaded = 0;

    if (!done)
    {
        int aeshandle, cellwidth, cellheight, dummy;

        wind_update (BEG_UPDATE);

        aeshandle = graf_handle (&cellwidth, &cellheight, &dummy, &dummy);

        /* zunÑchst versuchen wir, die Fontids beim AES oder */
        /* mit der Auskunftfunktion von AES-Font zu erfragen */

        if (!(appl_xgetinfo (0, &normheight, &normid, &dummy, &dummy) &&
            appl_xgetinfo (1, &iconheight, &iconid, &dummy, &dummy)))
         {
            /* Hier fragen wir den aktuellen Font der AES-Workstation
            ab. Dies ist ein Hack, aber es funktioniert mit den
            unterschiedlichen Auto-Ordner-Tools und ist eben nur
            bis AES 3.99 nîtig. Wir gehen dabei nicht davon aus,
            daû fÅr beide Textgrîûen dieselbe Schrift verwendet wird */

            static TEDINFO dum_ted = {
                " ", "", "", IBM  , 0,
                TE_LEFT , 0, 0, 0, 2, 1 };

            static OBJECT dum_ob = {
                0, -1, -1, G_TEXT, LASTOB, NORMAL,
                (long)&dum_ted, 0, 0, 0, 0 };

            int attrib[10]; long small;

            dum_ob.ob_width=cellwidth;
            dum_ob.ob_height=cellheight;

            dum_ted.te_font=IBM;
            objc_draw (&dum_ob, 0, 1, 0, 0, 0, 0);
            vqt_attributes (aeshandle, attrib);
            normid = attrib[0]; normheight = attrib[7];

            dum_ted.te_font=SMALL;
            objc_draw (&dum_ob, 0, 1, 0, 0, 0, 0);
            vqt_attributes (aeshandle, attrib);
            iconid = attrib[0]; iconheight = attrib[7];

            /* schlieûlich berÅcksichtigen wir noch den SMAL-Cookie */

            if (get_cookie('SMAL',&small))
            {
                if ((dummy=(int)(small>>16))!=0) normheight=dummy;
                if ((dummy=(int)(small))!=0) iconheight=dummy;
            }
        }

        /* Nun haben wir fÅr beide Fonts die Id und die Pixelgrîûe
        (Parameter fÅr vst_height). Nun sorgen wir dafÅr, daû beide
        Fonts auch wirklich auf der aktuellen virtuellen Workstation
        geladen sind (wir gehen davon, daû sie generell verfÅgbar
        sind, sonst hÑtte sie uns das AES ja nicht melden dÅrfen). */

        fontsloaded |= load_font (vdihandle, normid);
        fontsloaded |= load_font (vdihandle, iconid);

        /* Systemfont in Standardgrîûe einstellen */

        vst_font (vdihandle, normid);
        vst_height (vdihandle, normheight, &dummy, &dummy, &dummy, &dummy);

        wind_update (END_UPDATE);

        done = 1;
    }

    /* RÅckgabewerte */

    if (pnormid) *pnormid = normid;
    if (pnormheight) *pnormheight = normheight;
    if (piconid) *piconid = iconid;
    if (piconheight) *piconheight = iconheight;
    if (pfontsloaded) *pfontsloaded = fontsloaded;
}
