/*
 * Demonstrationsprogramm zur Programmierung
 * eines HPG Moduls:
 * Komfortable Anzeige der Systemvariablen
 # und diverser Traps/Vektoren 
 *
 * Version 1.0
 ************************************************
 * von Uwe Hax, M„rz 1992
 * (c) MAXON Computer
 */
 

#include <portab.h>
#include <stdlib.h>
#include <string.h>

#include "hpglib.h"
#include "sysvar.h"

#define RSC_RSH "sysvar.rsh"
#include "rshi.h"

/*
 * aus <stdio.h>: (kann nicht included werden) 
 */

WORD sprintf(BYTE *string, const BYTE *format, 
             ... );
WORD errno;          /* Startup-Code fehlt */

/*
 * Definitionen abschalten, siehe Text
 */

#undef WORD 
#undef BYTE
#undef LONG

/*
 * diverse Konstanten und Definitionen
 */

#define ADDRESS_LEN      9
#define TEXT_LEN         20
#define VALUE_LEN        9
#define VISIBLE          10
#define TRUE             1
#define FALSE            0
#define EOS              '\0'
#define NULL             (VOID *)0L

#define min(a,b)      ((a)<(b) ? (a) : (b))

typedef struct
{
  LONG address;
  WORD size;
  BYTE *text;
} VAR_LINE;

/*
 * darzustellende Listen
 */

VAR_LINE hw_vectors[] =
{
  0x00000000, 4, "Reset SSP",
  0x00000004, 4, "Hardware Reset",
  0x00000008, 4, "Bus Error",
  0x0000000c, 4, "Address Error",
  0x00000010, 4, "Illegal Instruction",
  0x00000014, 4, "Division by Zero",
  0x00000018, 4, "CHK/CHK2",
  0x0000001c, 4, "TRAPV/TRAPcc",
  0x00000020, 4, "Privilege Violation", 
  0x00000024, 4, "Trace",
  0x00000028, 4, "Line A",
  0x0000002c, 4, "Line F",
  -1L
};

VAR_LINE interrupts[] =
{
  0x00000060, 4, "Spurious Interrupt",
  0x00000064, 4, "Interrupt 1",
  0x00000068, 4, "Inter. 2: HBlank",
  0x0000006c, 4, "Interrupt 3",
  0x00000070, 4, "Inter. 3: VBlank",
  0x00000074, 4, "Interrupt 5",
  0x00000078, 4, "Interrupt 6",
  0x0000007c, 4, "Interrupt 7",
  -1L
};

VAR_LINE traps[] = 
{
  0x00000080, 4, "Trap 0",
  0x00000084, 4, "Trap 1: GEMDOS",
  0x00000088, 4, "Trap 2: AES/VDI",
  0x0000008c, 4, "Trap 3",
  0x00000090, 4, "Trap 4",
  0x00000094, 4, "Trap 5",
  0x00000098, 4, "Trap 6",
  0x0000009c, 4, "Trap 7",
  0x000000a0, 4, "Trap 8",
  0x000000a4, 4, "Trap 9",
  0x000000a8, 4, "Trap 10",
  0x000000ac, 4, "Trap 11",
  0x000000b0, 4, "Trap 12",
  0x000000b4, 4, "Trap 13: BIOS",
  0x000000b8, 4, "Trap 14: XBIOS",
  0x000000bc, 4, "Trap 15",
  -1L
};

VAR_LINE unused[] =
{
  0x00000030, 4, "Exception 12",
  0x00000034, 4, "Exception 13",
  0x00000038, 4, "Exception 14",
  0x0000003c, 4, "Exception 15",
  0x00000040, 4, "Exception 16",
  0x00000044, 4, "Exception 17",
  0x00000048, 4, "Exception 18",
  0x0000004c, 4, "Exception 19",
  0x00000050, 4, "Exception 20",
  0x00000054, 4, "Exception 21",
  0x00000058, 4, "Exception 22",
  0x0000005c, 4, "Exception 23",
  0x000000c0, 4, "Exception 48",
  0x000000c4, 4, "Exception 49",
  0x000000c8, 4, "Exception 50",
  0x000000cc, 4, "Exception 51",
  0x000000d0, 4, "Exception 52",
  0x000000d4, 4, "Exception 53",
  0x000000d8, 4, "Exception 54",
  0x000000dc, 4, "Exception 55",
  0x000000e0, 4, "Exception 56",
  0x000000e4, 4, "Exception 57",
  0x000000e8, 4, "Exception 58",
  0x000000ec, 4, "Exception 59",
  0x000000f0, 4, "Exception 60",
  0x000000f4, 4, "Exception 61",
  0x000000f8, 4, "Exception 62",
  0x000000fc, 4, "Exception 63",
  -1L
};

VAR_LINE mfp[] =
{                 
  0x00000100, 4, "Parallel Port",
  0x00000104, 4, "RS232 Carrier Detect",
  0x00000108, 4, "RS232 Clear To Send",
  0x0000010c, 4, "Disabled",
  0x00000110, 4, "Disabled",
  0x00000114, 4, "200 Hz System Clock",
  0x00000118, 4, "Keyboard/Midi",
  0x0000011c, 4, "FDC/HDC Interrupt",
  0x00000120, 4, "Hsync",
  0x00000124, 4, "RS232 Transmit Error",
  0x00000128, 4, "RS232 T.Buffer Empty",
  0x0000012c, 4, "RS232 Receive Error",
  0x00000130, 4, "RS232 R.Buffer Full",
  0x00000134, 4, "Disabled",
  0x00000138, 4, "RS232 Ring Indicator",
  0x0000013c, 4, "Monitor Detect",
  -1L
};

VAR_LINE system_vars[] =
{
  0x000380, 4, "proc_lives",
  0x000384, 4, "proc_reg D0",
  0x000388, 4, "proc_reg D1",
  0x00038c, 4, "proc_reg D2",
  0x000390, 4, "proc_reg D3",
  0x000394, 4, "proc_reg D4",
  0x000398, 4, "proc_reg D5",
  0x00039c, 4, "proc_reg D6",
  0x0003a0, 4, "proc_reg D7",
  0x0003a4, 4, "proc_reg A0",
  0x0003a8, 4, "proc_reg A1",
  0x0003ac, 4, "proc_reg A2",
  0x0003b0, 4, "proc_reg A3",
  0x0003b4, 4, "proc_reg A4",
  0x0003b8, 4, "proc_reg A5",
  0x0003bc, 4, "proc_reg A6",
  0x0003c0, 4, "proc_ssp",
  0x0003c4, 4, "proc_pc",
  0x0003c8, 4, "proc_usp",
  0x0003cc, 2, "proc_stk 0",
  0x0003ce, 2, "proc_stk 1",
  0x0003d0, 2, "proc_stk 2",
  0x0003d2, 2, "proc_stk 3",
  0x0003d4, 2, "proc_stk 4",
  0x0003d6, 2, "proc_stk 5",
  0x000400, 4, "etv_timer",
  0x000404, 4, "etv_critic",
  0x000408, 4, "etv_term",
  0x00040c, 4, "etv_xtra 0",
  0x000410, 4, "etv_xtra 1",
  0x000414, 4, "etv_xtra 2",
  0x000418, 4, "etv_xtra 3",
  0x00041c, 4, "etv_xtra 4",
  0x000420, 4, "memvalid",
  0x000424, 2, "memcntrl",
  0x000426, 4, "resvalid",
  0x00042a, 4, "resvector",
  0x00042e, 4, "phystop",
  0x000432, 4, "_membot",
  0x000436, 4, "_memtop",
  0x00043a, 4, "memval2",
  0x00043e, 2, "flock",
  0x000440, 2, "seekrate",
  0x000442, 2, "_timer_ms",
  0x000444, 2, "_fverify",
  0x000446, 2, "_bootdev",
  0x000448, 2, "palmode",
  0x00044a, 2, "defshiftmd",
  0x00044c, 1, "sshiftmd",
  0x00044e, 4, "_v_bas_ad",
  0x000452, 2, "vblsem",
  0x000454, 2, "nvbls",
  0x000456, 4, "_vblqueue",
  0x00045a, 4, "colorptr",
  0x00045e, 4, "screenpt",
  0x000462, 4, "_vbclock",
  0x000466, 4, "_frclock",
  0x00046a, 4, "hdv_init",
  0x00046e, 4, "swv_vec",
  0x000472, 4, "hdv_bpb",
  0x000476, 4, "hdv_rw",
  0x00047a, 4, "hdv_boot",
  0x00047e, 4, "hdv_mediach",
  0x000482, 2, "_cmdload",
  0x000484, 1, "conterm",
  0x000486, 4, "trp14ret",
  0x00048a, 4, "criticret",
  0x00048e, 4, "themd",
  0x0004a2, 4, "savptr",
  0x0004a6, 2, "_nflops",
  0x0004a8, 4, "con_state",
  0x0004ac, 2, "sav_row",
  0x0004ae, 4, "sav_context",
  0x0004b2, 4, "_bufl",
  0x0004ba, 4, "_hz_200",
  0x0004be, 4, "the_env",
  0x0004c2, 4, "_drvbits",
  0x0004c6, 4, "_dskbufp",
  0x0004ca, 4, "_autopath",
  0x0004ee, 2, "_dumpflg (_ptr_cnt)",
  0x0004f0, 4, "_ptrabt",
  0x0004f2, 4, "_sysbase",
  0x0004f6, 4, "_shell_p",
  0x0004fa, 4, "end_os",
  0x0004fe, 4, "exec_os",
  0x000502, 4, "scr_dump (dump_vec)",
  0x000506, 4, "prv_lsto (prt_stat)",
  0x00050a, 4, "prv_lstv (prt_vec)",
  0x00050e, 4, "prv_auxo (aux_stat)",
  0x000512, 4, "prv_aux (aux_vec)",
  -1L
};

LNGDEF language[] =
{
  SYSVAR, TITLE,      
          " Systemvektoren und -variablen ", "",
  SYSVAR, SHOWN,      "Systemvariablen", "",
  SYSVAR, ADDRESS,    " Adresse ", "",
  SYSVAR, MEANING,    " Bedeutung ", "",
  SYSVAR, VALUE,      " Inhalt ", "",
  SYSVAR, HWTEXT,     "Hardware-Vektoren", "",
  SYSVAR, IRTEXT,     "Interrupts", "",
  SYSVAR, TRAPTEXT,   "Traps", "",
  SYSVAR, UETEXT,     "Unben. Exceptions", "",
  SYSVAR, MFPTEXT,    "MFP-Vektoren", "",
  SYSVAR, VARTEXT,    "Systemvariablen", "",
  SYSVAR, SELECT,     "Anzeige", "",
  -1
};

/*
 * Funktions-Prototypen
 */

VOID main (VOID);
VOID into_window (WORD x, VAR_LINE *lines, 
                  WORD first_line);
WORD draw_window (WORD x, WORD first_line, 
                  WORD count_flag);
VOID init_slider (WORD max);
LONG read_value (LONG address);

OBJECT *sysvar;

/*
 * Das Hauptprogramm (...endlich!)
 */

VOID main (VOID)
{
  WORD radiotexts[6] = 
  { 
    HWTEXT, IRTEXT, TRAPTEXT, UETEXT, MFPTEXT,
    VARTEXT
  };
  WORD radios[6] = 
  { 
    HARDWARE, INTERUPT, TRAPS, UNUSED, MFP, 
    VARIABLE
  };
  WORD button;
  WORD i;
  WORD first_line = 0;
  WORD x,y,title_x,title_y;
  WORD objc_x,objc_y;
  WORD mstatus,mx,my;
  WORD max,pos;

  /*
   * Resource initialisieren
   */

  FIX_RSC();
  fix_language(tree, language);
  sysvar=tree[SYSVAR];
  
  objc_offset(sysvar, OFFSET, &x, &y);
  xmodalign(y);

  /*
   * Dialog ”ffnen
   */

  mouse_off();
  obopen(sysvar);
  max = draw_window(x, first_line, TRUE);
  init_slider(max);
  
  /*
   * Dialog bearbeiten
   */

  mouse_on();
  do
  {
    button = obdoform(sysvar, 0) & 0x7fff;
    mouse_off();

    switch (button)
    {
      /*
       * angeklickten Radio-Button auswerten
       */

      case HARDWARE:
      case INTERUPT:
      case TRAPS:
      case UNUSED:
      case MFP:
      case VARIABLE:

        /* 
         * neue šberschrift setzen
         */
         
        for (i = 0; i < 6; i++)
          if (radios[i] == button)
          {
            sysvar[SHOWN].ob_spec.tedinfo->
              te_ptext = sysvar[radiotexts[i]].
              ob_spec.free_string;
            break;
          }
        objc_offset(sysvar, SHOWN, &title_x,
                    &title_y);
        objc_draw(sysvar, ROOT,MAX_DEPTH,
                  title_x,title_y,
                  sysvar[SHOWN].ob_width,
                  sysvar[SHOWN].ob_height);
                  
        /*
         * Fensterinhalt und Slider zeichnen
         */
         
        first_line = 0;
        max = draw_window(x, first_line, TRUE);
        init_slider(max);
        break;
 
      /*
       * Slider-Objekte bearbeiten
       */
       
      case DOWN:
        if (first_line + VISIBLE < max)
          sl_updaslid((LONG)max, (LONG)VISIBLE,
                      (LONG)(++first_line), 
                      sysvar, BACKGRND, SLIDER);
        draw_window(x, first_line, FALSE);
        break;
      
      case UP:
        if (first_line > 0)
          sl_updaslid((LONG)max, (LONG)VISIBLE,
                      (LONG)(--first_line), 
                       sysvar, BACKGRND, SLIDER);
        draw_window(x, first_line, FALSE);
        break;
        
      case SLIDER:
        pos = sl_dragslid(sysvar, BACKGRND, 
                          SLIDER);
        if (pos >= 0)
        {
          sysvar[SLIDER].ob_y = 
            (WORD)((LONG)(sysvar[BACKGRND].
            ob_height - sysvar[SLIDER].ob_height)
            * (LONG)pos / 1000L);
          obdraw(sysvar, BACKGRND);
          first_line = (WORD)((LONG)(max - 
            VISIBLE) * (LONG)pos / 1000L);
          draw_window(x, first_line, FALSE);
        }
        break;
        
      case BACKGRND:
        vq_mouse(handle, &mstatus, &mx, &my);
        objc_offset(sysvar, SLIDER, &objc_x,
                    &objc_y);
        if (my < objc_y)
        {
          sysvar[SLIDER].ob_y -= 
            (WORD)((LONG)sysvar[BACKGRND].
            ob_height * (LONG)VISIBLE / 
            (LONG)max);
          if (sysvar[SLIDER].ob_y < 0)
            sysvar[SLIDER].ob_y = 0;
          obdraw(sysvar, BACKGRND);
          first_line -= VISIBLE;
          if (first_line < 0)
            first_line = 0;
          draw_window(x, first_line, FALSE);
        }
        else
        {
          sysvar[SLIDER].ob_y += 
            (WORD)((LONG)sysvar[BACKGRND].
            ob_height * (LONG)VISIBLE / 
            (LONG)max);
          if (sysvar[SLIDER].ob_y + 
              sysvar[SLIDER].ob_height >
              sysvar[BACKGRND].ob_height)
            sysvar[SLIDER].ob_y = 
              sysvar[BACKGRND].ob_height
               - sysvar[SLIDER].ob_height;
          obdraw(sysvar, BACKGRND);
          first_line += VISIBLE;
          if (first_line > max - VISIBLE)
            first_line = max - VISIBLE;
          draw_window(x, first_line, FALSE); 
        }
        break;
    }
    mouse_on();
  }
  while (button != CLOSE);
  
  obclose(sysvar);
}

/*
 * Fenster-Inhalt zum Radio-Button ermitteln
 * und ausgeben
 */
 
WORD draw_window (WORD x, WORD first_line, 
                  WORD count_flag)
{
  WORD radios[6] = { HARDWARE, INTERUPT, TRAPS, 
                     UNUSED, MFP, VARIABLE };
  VAR_LINE *texts[6]={ hw_vectors, interrupts, 
            traps, unused, mfp, system_vars };
  WORD i;
  WORD count = 0;
  
  for (i = 0; i < 6; i++)
    if (sysvar[radios[i]].ob_state & SELECTED)
    {
      into_window(x, texts[i], first_line);
      if (count_flag)
      {
        while (texts[i][count++].address != -1L);
        return(count);
      }
      break;
    }
  return(0);
}

/*
 * Fenster-Inhalt ausgeben
 */
 
VOID into_window (WORD x, VAR_LINE *lines, 
                  WORD first_line)
{
  WORD i, j;
  BYTE text[ADDRESS_LEN + 2 + TEXT_LEN + 2 + 
            VALUE_LEN + 1];
  LONG value;
  BYTE temp[10];
  
  for (i = 0; i < VISIBLE; i++)
  {
    if (lines[i + first_line].address == -1L)
    {
      for (j = i; j < VISIBLE; j++)
        nslttgncel(x / cw, j, ADDRESS_LEN + 2 + 
                   TEXT_LEN + 2 + VALUE_LEN);
      return;
    }
      
    sprintf(text, "$%08lx  ", lines[i + 
            first_line].address);
    strcat(text, lines[i + first_line].text);
    
    for (j = (WORD)strlen(text); j < ADDRESS_LEN 
         + 2 + TEXT_LEN + 2; j++)
      text[j] = ' ';
    text[j] = EOS;
    
    value = read_value(lines[i + 
                       first_line].address);
    switch (lines[i + first_line].size)
    {
      case 1:      
        sprintf(temp, "$%02x      ",
                (BYTE)value);     
        break;
                   
      case 2:      
        sprintf(temp, "$%04x    ", 
                (WORD)value);
        break;
      
      case 4:      
        sprintf(temp, "$%08lx", value);
        break;
    }
    strcat(text, temp);
    
    prtstrn(text, x / cw, i, ADDRESS_LEN + 2 + 
            TEXT_LEN + 2 + VALUE_LEN);
  }
}

/*
 * Slider initialisieren
 */ 
 
VOID init_slider (WORD max)
{
  sysvar[SLIDER].ob_y = 0;
  sysvar[SLIDER].ob_height = 
    (WORD)min(sysvar[BACKGRND].ob_height,
    (LONG)sysvar[BACKGRND].ob_height
    * VISIBLE / (LONG)max);
  obdraw(sysvar, BACKGRND);
}

/*
 * Speicheradresse auslesen
 */
 
LONG read_value (LONG address)
{
  LONG ssp;
  LONG value;
  
  ssp=Super(NULL);
  value = *(LONG *)address;
  Super((VOID *)ssp);
  
  return(value);
}
