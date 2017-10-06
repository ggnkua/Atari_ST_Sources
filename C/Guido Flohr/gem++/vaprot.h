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

// The whole entire VAprotocol is based on the vafunc library by Stefan
// Gerle with the extensions made by Mark Richardson.

#ifndef _VAprot_h
#define _VAprot_h

#ifndef _LIBGEMPP
#include <gemprot.h>
#else
#include "gemprot.h"
#endif

// Handle some germanisms.
#ifndef AV_PROTOCOL
# define AV_PROTOCOL AV_PROTOKOLL
#endif
#ifndef AvProtokoll
# define AvProtokoll AvProtocol
#endif
#ifndef AvProtokollDefault
# define AvProtokollDefault AvProtocolDefault
#endif
#ifndef SetAvProtokollDefault
# define SetAvProtokollDefault SetAvProtocolDefault
#endif

#ifndef VA_DRAG_COMPLETE
# define VA_DRAG_COMPLETE 0X4735
#endif
#ifndef VA_XOPEN
# define VA_XOPEN 0x4741
#endif
#ifndef AV_STARTED
# define AV_STARTED 0x4738
#endif
#ifndef AV_XWIND
# define AV_XWIND 0x4740
#endif

class VAprotocol : public GEMprotocol
{
public:
  VAprotocol (GEMactivity& in, const char* myname, 
              int priority_request = INT_MAX);
  
  virtual ~VAprotocol () {}
  
  virtual GEMfeedback Dispatch (const GEMevent& event);

  int Server () const { return server_id; }
  const char* ServerName () const { return server; }
  void Server (int id);
  void ServerName (const char* name);

  void DefaultFeedback (const GEMfeedback fb);
  
  void SetVaConfontDefault (const GEMfeedback fb) { VaConfontDefault = fb; }
  void SetVaConsoleopenDefault (const GEMfeedback fb) { VaConsoleopenDefault = fb; }
  void SetVaCopyCompleteDefault (const GEMfeedback fb) { VaCopyCompleteDefault = fb; }
  void SetVaDragaccwindDefault (const GEMfeedback fb) { VaDragaccwindDefault = fb; }
  void SetVaDragCompleteDefault (const GEMfeedback fb) { VaDragCompleteDefault = fb; }
  void SetVaFilefontDefault (const GEMfeedback fb) { VaFilefontDefault = fb; }
  void SetVaFontchangedDefault (const GEMfeedback fb) { VaFontchangedDefault = fb; }
  void SetVaObjectDefault (const GEMfeedback fb) { VaObjectDefault = fb; }
  void SetVaProgstartDefault (const GEMfeedback fb) { VaProgstartDefault = fb; }
  void SetVaProtostatusDefault (const GEMfeedback fb) { VaProtostatusDefault = fb; }
  void SetVaSetstatusDefault (const GEMfeedback fb) { VaSetstatusDefault = fb; }
  void SetVaStartDefault (const GEMfeedback fb) { VaStartDefault = fb; }
  void SetVaThatIzitDefault (const GEMfeedback fb) { VaThatIzitDefault = fb; }
  void SetVaWindopenDefault (const GEMfeedback fb) { VaWindopenDefault = fb; }
  void SetVaXopenDefault (const GEMfeedback fb) { VaXopenDefault = fb; }
  void SetAvAccwindclosedDefault (const GEMfeedback fb) { AvAccwindclosedDefault = fb; }
  void SetAvAccwindopenDefault (const GEMfeedback fb) { AvAccwindopenDefault = fb; }
  void SetAvAskconfontDefault (const GEMfeedback fb) { AvAskconfontDefault = fb; }
  void SetAvCopyDraggedDefault (const GEMfeedback fb) { AvCopyDraggedDefault = fb; }
  void SetAvDragOnWindowDefault (const GEMfeedback fb) { AvDragOnWindowDefault = fb; }
  void SetAvExitDefault (const GEMfeedback fb) { AvExitDefault = fb; }
  void SetAvGetstatusDefault (const GEMfeedback fb) { AvGetstatusDefault = fb; }
  void SetAvOpenConsoleDefault (const GEMfeedback fb) { AvOpenConsoleDefault = fb; }
  void SetAvOpenwindDefault (const GEMfeedback fb) { AvOpenwindDefault = fb; }
  void SetAvPathUpdateDefault (const GEMfeedback fb) { AvPathUpdateDefault = fb; }
  void SetAvProtocolDefault (const GEMfeedback fb) { AvProtocolDefault = fb; }
  void SetAvSendkeyDefault (const GEMfeedback fb) { AvSendkeyDefault = fb; }
  void SetAvStartedDefault (const GEMfeedback fb) { AvStartedDefault = fb; }
  void SetAvStartprogDefault (const GEMfeedback fb) { AvStartprogDefault = fb; }
  void SetAvStatusDefault (const GEMfeedback fb) { AvStatusDefault = fb; }
  void SetAvWhatIzitDefault (const GEMfeedback fb) { AvWhatIzitDefault = fb; }
  void SetAvXwindDefault (const GEMfeedback fb) { AvXwindDefault = fb; }

protected:
  GEMfeedback VaConfont (const GEMevent&) { return VaConfontDefault; }
  GEMfeedback VaConsoleopen (const GEMevent&) { return VaConsoleopenDefault; }
  GEMfeedback VaCopyComplete (const GEMevent&) { return VaCopyCompleteDefault; }
  GEMfeedback VaDragaccwind (const GEMevent&) { return VaDragaccwindDefault; }
  GEMfeedback VaDragComplete (const GEMevent&) { return VaDragCompleteDefault; }
  GEMfeedback VaFilefont (const GEMevent&) { return VaFilefontDefault; }
  GEMfeedback VaFontchanged (const GEMevent&) { return VaFontchangedDefault; }
  GEMfeedback VaObject (const GEMevent&) { return VaObjectDefault; }
  GEMfeedback VaProgstart (const GEMevent&) { return VaProgstartDefault; }
  GEMfeedback VaProtostatus (const GEMevent&) { return VaProtostatusDefault; }
  GEMfeedback VaSetstatus (const GEMevent&) { return VaSetstatusDefault; }
  GEMfeedback VaStart (const GEMevent&) { return VaStartDefault; }
  GEMfeedback VaThatIzit (const GEMevent&) { return VaThatIzitDefault; }
  GEMfeedback VaWindopen (const GEMevent&) { return VaWindopenDefault; }
  GEMfeedback VaXopen (const GEMevent&) { return VaXopenDefault; }
  GEMfeedback AvAccwindclosed (const GEMevent&) { return AvAccwindclosedDefault; }
  GEMfeedback AvAccwindopen (const GEMevent&) { return AvAccwindopenDefault; }
  GEMfeedback AvAskconfont (const GEMevent&) { return AvAskconfontDefault; }
  GEMfeedback AvCopyDragged (const GEMevent&) { return AvCopyDraggedDefault; }
  GEMfeedback AvDragOnWindow (const GEMevent&) { return AvDragOnWindowDefault; }
  GEMfeedback AvExit (const GEMevent&) { return AvExitDefault; }
  GEMfeedback AvGetstatus (const GEMevent&) { return AvGetstatusDefault; }
  GEMfeedback AvOpenConsole (const GEMevent&) { return AvOpenConsoleDefault; }
  GEMfeedback AvOpenwind (const GEMevent&) { return AvOpenwindDefault; }
  GEMfeedback AvPathUpdate (const GEMevent&) { return AvPathUpdateDefault; }
  GEMfeedback AvProtocol (const GEMevent&) { return AvProtocolDefault; }
  GEMfeedback AvSendkey (const GEMevent&) { return AvSendkeyDefault; }
  GEMfeedback AvStarted (const GEMevent&) { return AvStartedDefault; }
  GEMfeedback AvStartprog (const GEMevent&) { return AvStartprogDefault; }
  GEMfeedback AvStatus (const GEMevent&) { return AvStatusDefault; }
  GEMfeedback AvWhatIzit (const GEMevent&) { return AvWhatIzitDefault; }
  GEMfeedback AvXwind (const GEMevent&) { return AvXwindDefault; }

private:
  void FindServer ();
  int server_id;
  char server[9];
  int client_id;
  char client[9];

  GEMfeedback VaConfontDefault;
  GEMfeedback VaConsoleopenDefault;
  GEMfeedback VaCopyCompleteDefault;
  GEMfeedback VaDragaccwindDefault;
  GEMfeedback VaDragCompleteDefault;
  GEMfeedback VaFilefontDefault;
  GEMfeedback VaFontchangedDefault;
  GEMfeedback VaObjectDefault;
  GEMfeedback VaProgstartDefault;
  GEMfeedback VaProtostatusDefault;
  GEMfeedback VaSetstatusDefault;
  GEMfeedback VaStartDefault;
  GEMfeedback VaThatIzitDefault;
  GEMfeedback VaWindopenDefault;
  GEMfeedback VaXopenDefault;
  GEMfeedback AvAccwindclosedDefault;
  GEMfeedback AvAccwindopenDefault;
  GEMfeedback AvAskconfontDefault;
  GEMfeedback AvCopyDraggedDefault;
  GEMfeedback AvDragOnWindowDefault;
  GEMfeedback AvExitDefault;
  GEMfeedback AvGetstatusDefault;
  GEMfeedback AvOpenConsoleDefault;
  GEMfeedback AvOpenwindDefault;
  GEMfeedback AvPathUpdateDefault;
  GEMfeedback AvProtocolDefault;
  GEMfeedback AvSendkeyDefault;
  GEMfeedback AvStartedDefault;
  GEMfeedback AvStartprogDefault;
  GEMfeedback AvStatusDefault;
  GEMfeedback AvWhatIzitDefault;
  GEMfeedback AvXwindDefault;
};
#endif
