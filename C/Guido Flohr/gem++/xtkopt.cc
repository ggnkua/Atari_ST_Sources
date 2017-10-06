// Modular AES Desktop Environment - MADe.
// Copyright (C) 1997 by Guido Flohr <gufl0000@stud.uni-sb.de>.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */
//
// $Date$  
// $Revision$  
// $State$  


// MADload.
 
#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#ifdef STDC_HEADERS
# include <stdlib.h>
#endif

#ifdef HAVE_STRING_H
# include <string.h>
#endif

#include <limits.h>

#include <support.h> // gethostname () should be in unistd.h, but ...
#include <sys/param.h>
#include <portlib.h> // and MAXHOSTNAMELEN should be in sys/param.h..

#include <system.h>
#ifndef MAXHOSTNAMELEN
# define MAXHOSTNAMELEN 64
#endif
#ifndef ENAMETOOLONG
# define ENAMETOOLONG 0  // Define it as no error.
#endif

#include <system.h>

// #include <getopt.h>
#include <stdarg.h>

#include <gemal.h>
#include <vdi++.h>

#include "xtkopt.h"  // Implemented here.

#undef  _(a)
#define	_(a)	a

#define GEOMETRY 0
#define BGCOLOR 1
#define BORDERCOLOR 2
#define FGCOLOR 3
#define FONT 4
#define ICONIC 5
#define APPNAME 6
#define WIND_TITLE 7
#define XNLLANGUAGE 8
#define HIGHLIGHTCOLOR 9
#define JUMPSCROLL 10
#define LABEL 11
#define SCALE 14
#define UPDATE 15
#define REVERSE 16
#define WIND_INFO 17
#define NOLABEL 18
#define FIXED 19
#define PRECISION 20

ToolkitOptions::ToolkitOptions (int argc, char* const* argv) :
    nolabel (0),
    iconic (0),
    reverse (0),
    update (10),
    scale (1),
    bg (WHITE),
    fg (BLACK),
    hl (RED),
    jumpscroll (-1),  // Means one window half.
    title (default_title),
    label (NULL),
    info (false),
    width (-1),
    height (-1),
    right_ref (false),
    left_ref (false),
    top_ref (false),
    bottom_ref (false),
    fixed (false),
    precision (2)
{
  size_t chunksize = MAXHOSTNAMELEN;
  do {
    label = new char[chunksize];
    if (gethostname (label, chunksize) < 0) {
      delete label;
      label = NULL;
      chunksize += MAXHOSTNAMELEN;
    } else
      break;
  } while (errno == ENAMETOOLONG);
  
/*
  opterr = 0;  // Inhibit warnings about unrecognized options.

  struct option long_options[] = {
    { "geometry", required_argument, NULL, GEOMETRY },
    { "bg", required_argument, NULL, BGCOLOR },
    { "background", required_argument, NULL, BGCOLOR },
    { "bd", required_argument, NULL, BORDERCOLOR },
    { "border", required_argument, NULL, BORDERCOLOR },
    { "fg", required_argument, NULL, FGCOLOR },
    { "foreground", required_argument, NULL, FGCOLOR },
    { "fn", required_argument, NULL, FONT },
    { "font", required_argument, NULL, FONT },
    { "iconic", no_argument, NULL, ICONIC },
    { "name", required_argument, NULL, APPNAME },
    { "rv", no_argument, NULL, REVERSE },
    { "reverse", no_argument, NULL, REVERSE },
    { "title", required_argument, NULL, WIND_TITLE },
    { "xnllanguage", required_argument, NULL, XNLLANGUAGE },
    { "hl", required_argument, NULL, HIGHLIGHTCOLOR },
    { "highlight", required_argument, NULL, HIGHLIGHTCOLOR },
    { "jumpscroll", required_argument, NULL, JUMPSCROLL },
    { "label", required_argument, NULL, LABEL },
    { "nolabel", no_argument, NULL, NOLABEL },
    { "scale", required_argument, NULL, SCALE },
    { "update", required_argument, NULL, UPDATE },
    { "info", no_argument, NULL, WIND_INFO },
    { "fixed", no_argument, NULL, FIXED },
    { "precision", required_argument, NULL, PRECISION },
    { NULL, 0, NULL, 0 }
  };

  while (true) {
    int option_index;
    int the_option = getopt_long_only (argc, argv, "", 
      long_options, &option_index);
    if (the_option == -1)
      break;
    switch (the_option) {
      case '?':
        {
          if (strlen (argv[optind - 1]) > 26)
            argv[optind - 1][26] = 0;
          char AlertString[] = N_("\
 Warning: Invalid option or |\
 invalid use of option | `%s\'!");
          GEMalert Opterr (_(AlertString), _("Ignored"));
          Opterr.Alertf (1, argv[optind - 1]);
        }
        break;
      case BGCOLOR:
        {
          int color = Color2VDI (optarg);
          if (color >= 0) {
            bg = color;
          } else {
            if (strlen (argv[optind - 1]) > 26)
              argv[optind - 1][26] = 0;
            char AlertString[] = N_(" Invalid color specification | `%s\'.");
            GEMalert Opterr (_(AlertString), _("Ignored"));
            Opterr.Alertf (1, argv[optind - 1]);
          }
        }
        break;
        
      case FGCOLOR:
        {
          int color = Color2VDI (optarg);
          if (color >= 0) {
            fg = color;
          } else {
            if (strlen (optarg) > 26)
              optarg[26] = 0;
            char AlertString[] = N_(" Invalid color specification | `%s\'.");
            GEMalert Opterr (_(AlertString), ("Ignored"));
            Opterr.Alertf (1, optarg);
          }
        }
        break;
        
      case HIGHLIGHTCOLOR:
        {
          int color = Color2VDI (optarg);
          if (color >= 0) {
            hl = color;
          } else {
            if (strlen (optarg) > 26)
              optarg[26] = 0;
            char AlertString[] = N_(" Invalid color specification | `%s\'.");
            GEMalert Opterr (_(AlertString), _("Ignored"));
            Opterr.Alertf (1, optarg);
          }
        }
        break;
        
      case UPDATE:
        update = strtoul (optarg, NULL, 10);
        if (update < 1)
          update = 1;
        break;
        
      case JUMPSCROLL:
        jumpscroll = strtoul (optarg, NULL, 10);
        if (jumpscroll < 1)
          jumpscroll = -1;
        break;
      
      case WIND_TITLE:
        title = optarg;
        break;
      
      case LABEL:
        if (label)
          delete label;
        label = new char[strlen (optarg) + 1];
        strcpy (label, optarg);
        break;
      
      case GEOMETRY:
        GetGeometry (optarg);
        break;
      
      case WIND_INFO:
        info = true;
        break;
      
      case NOLABEL:
        label = NULL;
        break;
        
      case FIXED:
        fixed = true;
        break;
      
      case PRECISION:
        precision = strtoul (optarg, NULL, 10);
        break;
      
      case ICONIC:
        iconic = true;
        break;
      
      case REVERSE:
        reverse = true;
        break;
        
      case SCALE:
        scale = strtoul (optarg, NULL, 10);
        if (scale < 1)
          scale = 1;
        break;
        
      default:
        break;
    }
  }
*/
  
  if (reverse) {
    int c = bg;
    bg = fg;
    fg = c;
  }
}

int ToolkitOptions::Color2VDI (const char* color) const
{
  if (strcasecmp ("WHITE", color) == 0)
    return WHITE;
  else if (strcasecmp ("BLACK", color) == 0)
    return BLACK;
  else if (strcasecmp ("RED", color) == 0)
    return RED;
  else if (strcasecmp ("GREEN", color) == 0)
    return GREEN;
  else if (strcasecmp ("YELLOW", color) == 0)
    return YELLOW;
  else if (strcasecmp ("BLUE", color) == 0)
    return BLUE;
  else if (strcasecmp ("MAGENTA", color) == 0)
    return MAGENTA;
  else if (strcasecmp ("CYAN", color) == 0)
    return CYAN;
  else if (strcasecmp ("LWHITE", color) == 0)
    return LWHITE;
  else if (strcasecmp ("LBLACK", color) == 0)
    return LBLACK;
  else if (strcasecmp ("LRED", color) == 0)
    return LRED;
  else if (strcasecmp ("LGREEN", color) == 0)
    return LGREEN;
  else if (strcasecmp ("LYELLOW", color) == 0)
    return LYELLOW;
  else if (strcasecmp ("LBLUE", color) == 0)
    return LBLUE;
  else if (strcasecmp ("LMAGENTA", color) == 0)
    return LMAGENTA;
  else if (strcasecmp ("LCYAN", color) == 0)
    return LCYAN;
  else if (strcasecmp ("LIGHTWHITE", color) == 0)
    return LWHITE;
  else if (strcasecmp ("LIGHTBLACK", color) == 0)
    return LBLACK;
  else if (strcasecmp ("LIGHTRED", color) == 0)
    return LRED;
  else if (strcasecmp ("LIGHTGREEN", color) == 0)
    return LGREEN;
  else if (strcasecmp ("LIGHTYELLOW", color) == 0)
    return LYELLOW;
  else if (strcasecmp ("LIGHTBLUE", color) == 0)
    return LBLUE;
  else if (strcasecmp ("LIGHTMAGENTA", color) == 0)
    return LMAGENTA;
  else if (strcasecmp ("LIGHTCYAN", color) == 0)
    return LCYAN;
  else
    return -1;
}

void ToolkitOptions::ClearGeometry ()
{
  width = height = -1;
  xoffset = yoffset = 0;
  left_ref = right_ref = top_ref = bottom_ref = false;
}

void ToolkitOptions::GetGeometry (char* geometry)
{
  char* cursor = geometry;
  ClearGeometry ();
  char* tail;
  
  GEMalert Invalid (_("\
 Warning: | Invalid geometry | specification!"), _("Ignored"));
  GEMalert Overflow (_("\
 Warning: | Overflow in geometry | specification!"), _("Ignored"));
 
  // Have we got a dimension specification?
  if (cursor[0] != '+' && cursor[0] != '-') {
    width = strtoul (cursor, &tail, 10);
    if (tail == cursor) {
      Invalid.Alert ();
      ClearGeometry ();
      return;
    } else if (width >= SHRT_MAX) {
      Overflow.Alert ();
      ClearGeometry ();
      return;
    }
    cursor = tail;
    if (*cursor != 'x') {
      Invalid.Alert ();
      ClearGeometry ();
      return;
    }
    cursor++;
    height = strtoul (cursor, &tail, 10);
    if (tail == cursor) {
      Invalid.Alert ();
      ClearGeometry ();
      return;
    } else if (height >= SHRT_MAX) {
      Overflow.Alert ();
      ClearGeometry ();
      return;
    }
    cursor = tail;
  }
  // Coordinates specified?
  if (*cursor == '\0')
    return;
    
  if (*cursor == '+') {
    left_ref = true;
  } else if (*cursor == '-') {
    right_ref = true;
  } else {
    Invalid.Alert ();
    ClearGeometry ();
    return;
  }
  cursor++;
  xoffset = strtol (cursor, &tail, 10);
  if (tail == cursor) {
    Invalid.Alert ();
    ClearGeometry ();
    return;
  } else if (xoffset <= SHRT_MIN || xoffset >= SHRT_MAX) {
    Overflow.Alert ();
    ClearGeometry ();
    return;
  }
  cursor = tail;
  
  if (*cursor == '+') {
    top_ref = true;
  } else if (*cursor == '-') {
    bottom_ref = true;
  } else {
    Invalid.Alert ();
    ClearGeometry ();
    return;
  }
  cursor++;
  yoffset = strtol (cursor, &tail, 10);
  if (tail == cursor) {
    Invalid.Alert ();
    ClearGeometry ();
    return;
  } else if (yoffset <= SHRT_MIN || yoffset >= SHRT_MAX) {
    Overflow.Alert ();
    ClearGeometry ();
    return;
  }
  cursor = tail;
  if (*cursor != '\0') {
    Invalid.Alert ();
    ClearGeometry ();
  }
}

char* ToolkitOptions::default_title = "MADload";
