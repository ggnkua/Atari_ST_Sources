/*
 * This file contains the routines which implement the uw protocol.
 * Code has been migrating here from winmain.c, but its not all here yet.
 */

#include <stdio.h>
#include <osbind.h>
#include <gemdefs.h>
#include "wind.h"
#include "uw.h"
#include "windefs.h"

#define LIMIT	300

extern	struct	wi_str	w[];
extern int outport;			/* ports used with uw */
extern int inwind, outwind;		/* windows for input/output */
extern int uw_runs;			/* is uw running ? */
FNT	*curfont;			/* font in use */

/* proto_out sends length chars from str to the window defined by outport. */
proto_out(outport, str, length)
int outport, length;
char *str;

{
static int oldoutport = 1;
int key, i;
int outwind;

outwind = find_wind(outport);
  if (w[outwind].w_local == TRUE)	/* local window? */
  {
    char *found, *index();
    char strcr[3] = "\r\n";

    str[length] = '\0';
    while (found = index(str, '\r'))
    {
      char line[500];
      strncpy(line, str, found - str);
      line[found-str] = '\0';
      w_output(outwind, line);
      w_output(outwind, strcr);
      str = found + 1;
    }
    w_output(outwind, str);
    return;
  }
  for (key = *str, i = 0; i < length; key = str[++i])
  {
    if (uw_runs)
    {
      if (outport != oldoutport)
      {
        xmitcmd(CB_FN_ISELW|outport);
        oldoutport = outport;
      }
      if (key & 0x80) {
        key &= 0x7f;
	xmitcmd(CB_FN_META);
      }
      switch (key)
      {
      case XON:
        xmitcmd(CB_FN_CTLCH|CB_CC_ON);
        break;
 
      case XOFF:
        xmitcmd(CB_FN_CTLCH|CB_CC_OFF);
        break;

      case IAC:
        xmitcmd(CB_FN_CTLCH|CB_CC_IAC);
        break;

      default:
        Bconout(1, key);
        break;
      }
    } else
      Bconout(1, key);	/* need mask with 0x7f? */
  }
}

/*
 * proto_close closes the current window and notifies the remote.  The new
 * current window is returned.
 */
int proto_close(curwind)
int curwind;
{
  long dummy;

  if (uw_runs && (find_port(curwind) < MAX_WIND))
  {
    xmitcmd(CB_FN_KILLW|find_port(curwind));
  }
  w_close(curwind);
  wind_get(0, WF_TOP, &curwind, &dummy, &dummy, &dummy);
  return (curwind);
/*  } else
  {
    w_close(curwind);
    return (0);
  } */
}

/* proto_in receives characters from the serial port. */
proto_in()
#define NORMSTATE 0
#define IACSTATE 1
/* #define METASTATE 2  replaced with seenmeta flag. */
#define INITSTATE 3
{
  register char	*ptr;
  char	str[LIMIT+2];
  register char	chr;
  register int	cnt;
  long dummy;
  static int state;
  static int seenmeta = 0;

      ptr = str;
      cnt = 0;
      while (Bconstat(1) && cnt++<LIMIT)
      {
	chr = Bconin(1)&0x7f;
	switch (state)
	{
	case NORMSTATE:
	  if (!chr || chr=='\177') continue;
	  if (chr == IAC)
	  {
	    if (uw_runs)
	      state = IACSTATE;
	    else
	      state = INITSTATE;
	    continue;
	  }
	  if (seenmeta) {
	    seenmeta = 0;
	    *ptr++ = chr|0x80;
	  }
	  else *ptr++ = chr;
	  break;
	case INITSTATE:
	  if (chr == CB_FN_MAINT | CB_MF_ENTRY){
	    xmitcmd(CB_FN_MAINT|CB_MF_ENTRY);
	    uw_runs = 1;
	    outport = 0;
	    outwind = 0;
	  }
	  else {
	    *ptr++ = IAC;
	    *ptr++ = chr;
	  }
	  state = NORMSTATE;
	  break;
	case IACSTATE:
	  state = NORMSTATE;
	  if (chr&CB_DIR_MTOH) continue;
	  switch (chr&CB_FN)
	  {
	  case CB_FN_NEWW:
	    outport = w_open(chr&CB_WINDOW, "Terminal", curfont->def_win_x,
	      curfont->def_win_y);
	    outwind = find_wind(outport);
	    xmitcmd(CB_FN_ISELW|outport);
	    break;

	  case CB_FN_KILLW:
	    w_close(find_wind(chr&CB_WINDOW));
	    wind_get(0, WF_TOP, &outwind, &dummy, &dummy, &dummy);
	    outport = find_port(outwind);
	    break;

	  case CB_FN_OSELW:
	    if (inwind != find_wind(chr&CB_WINDOW))
	    {
	      *ptr = '\0';
	      if (ptr != str)
	      {
	        if (w[inwind].kerm_act)
		  rpack(" ", NULL, str);
		else
		  w_output(inwind, str);
	      }
	      ptr = str;
	    }
	    inwind = find_wind(chr&CB_WINDOW);
	    break;

	  case CB_FN_META:
	    seenmeta = 1;
	    break;

	  case CB_FN_CTLCH:
	    switch (chr&CB_CC)
	    {
	    case CB_CC_IAC:
	      if (seenmeta) {
	        seenmeta = 0;
	        *ptr++ = IAC|0x80;
	      }
	      else *ptr++ = IAC;
	      break;

	    case CB_CC_ON:
	      if (seenmeta) {
	        seenmeta = 0;
	        *ptr++ = XON|0x80;
	      }
	      else *ptr++ = XON;
	      break;

	    case CB_CC_OFF:
	      if (seenmeta) {
	        seenmeta = 0;
	        *ptr++ = XOFF|0x80;
	      }
	      else *ptr++ = XOFF;

	      break;
	    }
	    break;

	  case CB_FN_MAINT:
	    switch (chr&CB_MF)
	    {
	    case CB_MF_ENTRY:
	      xmitcmd(CB_FN_MAINT|CB_MF_ENTRY);
	      uw_runs = 1;
	      outport = 0;
	      outwind = 0;
	      break;

	    case CB_MF_EXIT:
	      uw_runs = 0;
	      return (-1);
	    }
	    break;
	  }
	  break;
	}
      }
      *ptr = '\0';
      if (ptr!=str)
      {
        if (w[inwind].kerm_act)
	  rpack(" ", NULL, str);
	else
	  w_output(inwind, str);
      }
      return (0);
}
