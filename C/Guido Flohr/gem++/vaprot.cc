// GEM++.
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

#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#include <aesbind.h>

#include "vaproto.h"

#include "vaprot.h"  // Implemented here.

VAprotocol::VAprotocol (GEMactivity& in, const char* myname,
                        int priority_request) :
  GEMprotocol (in, priority_request),
  server_id (-1),
  client_id (_AESapid)
{
  DefaultFeedback (IgnoredEvent);
  strncpy (client, myname, 8);
  ConvertAESName (client);
  client_id = _AESapid;
  FindServer ();
}

void VAprotocol::DefaultFeedback (const GEMfeedback fb)
{
  SetVaConfontDefault (fb);
  SetVaConsoleopenDefault (fb);
  SetVaCopyCompleteDefault (fb);
  SetVaDragaccwindDefault (fb);
  SetVaDragCompleteDefault (fb);
  SetVaFilefontDefault (fb);
  SetVaFontchangedDefault (fb);
  SetVaObjectDefault (fb);
  SetVaProgstartDefault (fb);
  SetVaProtostatusDefault (fb);
  SetVaSetstatusDefault (fb);
  SetVaStartDefault (fb);
  SetVaThatIzitDefault (fb);
  SetVaWindopenDefault (fb);
  SetVaXopenDefault (fb);
  SetAvAccwindclosedDefault (fb);
  SetAvAccwindopenDefault (fb);
  SetAvAskconfontDefault (fb);
  SetAvCopyDraggedDefault (fb);
  SetAvDragOnWindowDefault (fb);
  SetAvExitDefault (fb);
  SetAvGetstatusDefault (fb);
  SetAvOpenConsoleDefault (fb);
  SetAvOpenwindDefault (fb);
  SetAvPathUpdateDefault (fb);
  SetAvProtocolDefault (fb);
  SetAvSendkeyDefault (fb);
  SetAvStartedDefault (fb);
  SetAvStartprogDefault (fb);
  SetAvStatusDefault (fb);
  SetAvWhatIzitDefault (fb);
  SetAvXwindDefault (fb);
}

void VAprotocol::Server (int id)
{
  server_id = id;
  server[0] = '\0';
}

void VAprotocol::ServerName (const char* name)
{
  strncpy (server, name, 8);
  ConvertAESName (server);
  server_id = appl_find (server);
  if (server_id < 0)
    server[0] = '\0';
}

void VAprotocol::FindServer ()
{
  char* default_server = "AVSERVER";
  
  char* name = getenv (default_server);
  if (!name) {
    shel_envrn (&name, "AVSERVER=");
    if (!name) {
      name = default_server;
    }
  }
  strncpy (server, name, 8);
  ConvertAESName (server);
  server_id = appl_find (server);
  if (server_id < 0)
    server[0] = '\0';
}

GEMfeedback VAprotocol::Dispatch (const GEMevent& event)
{
  if (event.Message (0) < 0x4700)
    return IgnoredEvent;
    
  GEMfeedback retval = IgnoredEvent;
  switch (event.Message (0)) {
    case VA_CONFONT:
      return (VaConfont (event));
    case VA_CONSOLEOPEN:
      return (VaConsoleopen (event));
    case VA_COPY_COMPLETE:
      return (VaCopyComplete (event));
    case VA_DRAGACCWIND:
      return (VaDragaccwind (event));
    case VA_DRAG_COMPLETE:
      return (VaDragComplete (event));
    case VA_FILEFONT:
      return (VaFilefont (event));
    case VA_OBJECT:
      return (VaObject (event));
    case VA_PROGSTART:
      return (VaProgstart (event));
    case VA_PROTOSTATUS:
      return (VaProtostatus (event));
    case VA_SETSTATUS:
      return (VaSetstatus (event));
    case VA_START:
      return (VaStart (event));
    case VA_THAT_IZIT:
      return (VaThatIzit (event));
    case VA_WINDOPEN:
      return (VaWindopen (event));
    case VA_XOPEN:
      return (VaXopen (event));
    case AV_ACCWINDCLOSED:
      return (AvAccwindclosed (event));
    case AV_ACCWINDOPEN:
      return (AvAccwindopen (event));
    case AV_ASKCONFONT:
      return (AvAskconfont (event));
    case AV_COPY_DRAGGED:
      return (AvCopyDragged (event));
    case AV_DRAG_ON_WINDOW:
      return (AvDragOnWindow (event));
    case AV_EXIT:
      return (AvExit (event));
    case AV_GETSTATUS:
      return (AvGetstatus (event));
    case AV_OPENCONSOLE:
      return (AvOpenConsole (event));
    case AV_OPENWIND:
      return (AvOpenwind (event));
    case AV_PATH_UPDATE:
      return (AvPathUpdate (event));
    case AV_PROTOCOL:
      return (AvProtocol (event));
    case AV_SENDKEY:
      return (AvSendkey (event));
    case AV_STARTED:
      return (AvStarted (event));
    case AV_STARTPROG:
      return (AvStartprog (event));
    case AV_STATUS:
      return (AvStatus (event));
    case AV_WHAT_IZIT:
      return (AvWhatIzit (event));
    case AV_XWIND:
      return (AvXwind (event));
    default:
      break;
  }
  return retval;
}
