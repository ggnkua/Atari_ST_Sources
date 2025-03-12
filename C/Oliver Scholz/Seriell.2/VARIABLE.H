/*
 * VARIABLE.H
 * Globale Variablen fÅr TT44TT
 * Copyright (c) 1991 by MAXON Computer
 * Autoren: Oliver Scholz & Uwe Hax
 */

GLOBAL WORD gl_apid;
GLOBAL WORD distances[5],effects[3];
GLOBAL WORD num_aux,aux_offset;
GLOBAL WORD curr_icon=-1;
GLOBAL WORD curr_device=-1;
GLOBAL WORD top_window=-1;
GLOBAL WORD vdi_handle;
GLOBAL WORD dummy;
GLOBAL WORD zoomflag = TRUE;
GLOBAL WORD wchar,hchar,wbox,hbox;
GLOBAL WORD tos_version;
GLOBAL CHAR inf_path[128];
GLOBAL CHAR inf_name[14];
GLOBAL OBJECT *menu,*newdesk,*port_dial,
       *info_box;
GLOBAL CONF_RS port[4];
GLOBAL TERMINAL terminal[4];
GLOBAL WORD elements=NAME | CLOSER | FULLER |
       MOVER | INFO | SIZER | UPARROW | DNARROW |
       VSLIDE | LFARROW | RTARROW | HSLIDE;
GLOBAL WORD iconlist[4]=
       { MFP1, SCC2, MFP2, SCC1 };
GLOBAL WINDOW window[4]=
{ -1," Modem 1 ","",8,32,304,192,   FALSE,0,0,
  -1," Modem 2 ","",320,32,304,192, FALSE,0,0,
  -1," Serial 1 ","",8,224,304,192,  FALSE,0,0,
  -1," Serial 2 ","",320,224,304,192,FALSE,0,0,
};


