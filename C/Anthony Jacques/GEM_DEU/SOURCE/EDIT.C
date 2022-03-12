/*
   Doom Editor Utility, by Brendon Wyber and Rapha‰l Quinet.

   GEM-DEU by Anthony Jacques.

   You are allowed to use any parts of this code in another program, as
   long as you give credits to the authors in the documentation and in
   the program itself.  Read the file README.1ST for more information.

   This program comes with absolutely no warranty.

   EDIT.C - Editor routines.
*/

/* the includes */
#include "deu.h"
#include "levels.h"
extern Bool InfoShown;		/* should we display the info bar? */
#ifdef CIRRUS_PATCH
extern char HWCursor[];		/* Cirrus hardware cursor data */
#endif /* CIRRUS_PATCH */

short MoveSpeed = 20;		/* movement speed */


/*
   the driving program
*/

void EditLevel( short episode, short mission, Bool newlevel)
{
   ReadWTextureNames();
   ReadFTextureNames();
   CheckMouseDriver();

   if (episode < 1 || mission < 1)
      SelectLevel( &episode, &mission);

   if (episode > 0 && mission > 0)
   {
    ReadLevelData( episode, mission);
    if (newlevel)
      {
       ForgetLevelData();
       MapMinX = -4000;
       MapMinY = -4000;
       MapMaxX = 4000;
       MapMaxY = 4000;
      }
    LogMessage( ": Editing E%dM%d...\n", episode, mission);
    EditorLoop( episode, mission);
    LogMessage( ": Finished editing E%dM%d...\n", episode, mission);
    if (!Registered && !NoRegisteredChecks)
         form_alert(1, "[1]Please register DOOM if you |want to be able to save your changes.[Ok.]");
    ForgetLevelData();
    /* forget the level pointer */
    Level = NULL;
   }
   ForgetWTextureNames();
   ForgetFTextureNames();
}



/*
   select a level
*/

void SelectLevel( short *episode, short *mission)
{
 OBJECT *form;
 short xdial,ydial,wdial,hdial,seld;
 MDirPtr dir;
 char *name;
 char **levels;
 short n = 0;

 dir = MasterDir;
 while (dir)
   {
    if (dir->dir.size == 0 && dir->dir.name[ 0] == 'E' && dir->dir.name[ 2] == 'M' && dir->dir.name[ 4] == '\0')
      {
       if (n == 0) levels = GetMemory( sizeof( char *));
          else levels = ResizeMemory( levels, (n + 1) * sizeof( char *));
       levels[ n] = dir->dir.name;
       n++;
      }
    dir = dir->next;
   }


 rsrc_gaddr(0,SELECTLEVELDIAG,&form);

 form_center ( form, &xdial, &ydial, &wdial, &hdial );
 form_dial ( 0, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
 objc_draw (form, 0, 2, xdial, ydial, wdial, hdial );
 
 seld=form_do ( form, 0 ); 

 form_dial ( 3, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
 objc_change (form,seld,-1,-1,-1,-1,-1,NORMAL,1);

 name=objc_text( form, LEVELNUM);
 *episode = name[0]-'0';
 *mission = name[1]-'0';

 /* Should check that level is in DIR, but who cares... */
}



/*
   get the name of the new WAD file
*/

char *GetWadFileName( short episode, short mission)
{
   char *outfile = GetMemory( 80);
   char *dotp;
   WadPtr wad;

   /* get the file name */
   if (! strcmp(Level->wadfile->filename, MainWad))
      sprintf( outfile, "E%dM%d.WAD", episode, mission);
   else
      strcpy( outfile, Level->wadfile->filename);
   do
   {
      InputFileName( -1, -1, "Name of the new WAD file:", 79, outfile);
   }
   while (!strcmp(outfile, MainWad));
   /* escape */
   if (outfile[ 0] == '\0')
   {
      FreeMemory( outfile);
      return NULL;
   }
   /* if the WAD file already exists, rename it to "*.BAK" */
   for (wad = WadFileList; wad; wad = wad->next)
      if (!stricmp( outfile, wad->filename))
      {
	 dotp = strrchr( wad->filename, '.');
	 if (dotp == NULL)
	    strcat( wad->filename, ".BAK");
	 else
	    strcpy( dotp, ".BAK");
	 /* need to close, then reopen: problems with SHARE.EXE */
	 fclose( wad->fileinfo);
	 if (rename( outfile, wad->filename) < 0)
	 {
	    if (unlink( wad->filename) < 0)
	       ProgError( "could not delete file \"%s\"", wad->filename);
	    if (rename( outfile, wad->filename) < 0)
	       ProgError( "could not rename \"%s\" to \"%s\"", outfile, wad->filename);
	 }
	 wad->fileinfo = fopen( wad->filename, "rb");
	 if (wad->fileinfo == NULL)
	    ProgError( "could not reopen file \"%s\"", wad->filename);
	 break;
      }
   return outfile;
}



/*
   display the help screen
 */

void DisplayHelp( short objtype, short grid) /* SWAP! */
{
 printf("In displayhelp() [why?]. objtype=%d, grid=%d\n", objtype,grid);
}


   short vdi_rect[4];



/*
** Translates a keyboard shortcut to a menu entry
*/
Bool trans_keyb(short men,short kbstate,short key,short msgbuf[])
{
 char **xlate;

 xlate=Keytbl((char *)-1,(char *)-1,(char *)-1);

 key = (key >> 8) & 0x7f;
 key = *(*xlate+key);
 key=toupper(key);

 switch (men)
   {
    case EDITMENU:
         switch (key)
           {
            case 27:  msgbuf[3]=T_EFILE;
                      msgbuf[4]=EDITEXIT;
                      return(TRUE);
            case 'I': msgbuf[3]=T_EEDIT;
                      msgbuf[4]=EDITADD;
                      return(TRUE);
            case '\b':msgbuf[3]=T_EEDIT;
                      msgbuf[4]=EDITDELETE;
                      return(TRUE);
            case 13:  msgbuf[3]=T_EEDIT;
                      msgbuf[4]=EDITEDITOBJ;
                      return(TRUE);
            case 'M': msgbuf[3]=T_EEDIT;
                      msgbuf[4]=MARKUNMARK;
                      return(TRUE);
            case 'C': msgbuf[3]=T_EEDIT;
                      msgbuf[4]=CLEARMARKS;
                      return(TRUE);
            case 'N': msgbuf[3]=T_ESEARCH;
                      msgbuf[4]=EDITNEXT;
                      return(TRUE);
            case 'P': msgbuf[3]=T_ESEARCH;
                      msgbuf[4]=EDITPREV;
                      return(TRUE);
            case 'J': msgbuf[3]=T_ESEARCH;
                      msgbuf[4]=EDITJUMPTONEXT;
                      return(TRUE);
            case 'T': msgbuf[3]=T_EMODES;
                      msgbuf[4]=EDITMODE_THING;
                      return(TRUE);
            case 'V': msgbuf[3]=T_EMODES;
                      msgbuf[4]=EDITMODE_VERTEX;
                      return(TRUE);
            case 'L': msgbuf[3]=T_EMODES;
                      msgbuf[4]=EDITMODE_LINE;
                      return(TRUE);
            case 'S': msgbuf[3]=T_EMODES;
                      msgbuf[4]=EDITMODE_SECTORS;
                      return(TRUE);
            case '\t':msgbuf[3]=T_EMODES;
                      if (kbstate==K_RSHIFT || kbstate==K_LSHIFT)
                          msgbuf[4]=EDITMODE_NEXT;
                        else msgbuf[4]=EDITMODE_PREV;
                      return(TRUE);
            case '3': msgbuf[3]=T_EMODES;
                      msgbuf[4]=EDITMODE_3D;
                      return(TRUE);
            case '+': msgbuf[3]=T_EMISC;
                      msgbuf[4]=INCSCALE;
                      return(TRUE);
            case '-': msgbuf[3]=T_EMISC;
                      msgbuf[4]=DECSCALE;
                      return(TRUE);
            case 'G': msgbuf[3]=T_EMISC;
                      msgbuf[4]=DISPLAYGRID;
                      return(TRUE);
            default:  printf("You pressed %c - code %d\n",(char)key,key);
           }         
   }

return(FALSE);
}


/*
** the editor main loop
*/
void EditorLoop( short episode, short mission) /* SWAP! */
{
   short  EditMode = OBJ_THINGS;
   short  CurObject = -1;
   short  OldObject = -1;
   Bool   RedrawMap = TRUE;
   Bool   RedrawObj = FALSE;
   Bool   DragObject = FALSE;
   short  altkey, buttons, oldbuttons;
   short  GridScale = 32;
   Bool   GridShown = FALSE;
   SelPtr Selected = NULL;
   char   keychar;
   short  SelBoxX = 0;
   short  SelBoxY = 0;
   short  OldPointerX = 0;
   short  OldPointerY = 0;
   Bool   StretchSelBox = FALSE;
   Bool   ShowRulers = FALSE;
   short  PrevMode;

   Bool doquit = FALSE; 

   OBJECT *form;
   short xdial,ydial,wdial,hdial,seld,event;
 
   /* all the window variables. */
   short win_hand,win_x,win_y,win_w,win_h, dummy, old_x, old_y, old_w, old_h;

   short mousebut, kbstate, key;

   char title[30];
   char temp[10];
   short tempi;

   SelPtr cur, NewSel;

   MadeChanges = FALSE;
   MadeMapChanges = FALSE;
   if (InitialScale < 1)
      InitialScale = 1;
   else if (InitialScale > 20)
      InitialScale = 20;
   Scale = (float) (1.0 / InitialScale);

/*   if (NumThings > 0)
      {
       GetObjectCoords( OBJ_THINGS , 0, &xpos, &ypos);
       CenterMapAroundCoords( xpos, ypos);
      }
    else*/
       CenterMapAroundCoords( (MapMinX + MapMaxX) / 2, (MapMinY + MapMaxY) / 2);

/*
 SetDoomPalette( 0);
*/
 rsrc_gaddr(0,EDITMENU,&menu);
 menu_bar(menu,1);

 menu_icheck(menu,EDITMODE_THING,1);
 menu_icheck(menu,EDITMODE_LINE,0);
 menu_icheck(menu,EDITMODE_VERTEX,0);
 menu_icheck(menu,EDITMODE_SECTORS,0);
 menu_icheck(menu,EDITHELP_INFOBAR,InfoShown);
 menu_icheck(menu,DISPLAYGRID,GridShown);

 wind_get(0,WF_WORKXYWH,&win_x,&win_y,&win_w,&win_h);
 old_x=win_x; old_y=win_y;
 old_w=win_w; old_h=win_h;

 win_hand=wind_create(NAME|INFO|CLOSER|FULLER|MOVER|UPARROW|DNARROW|LFARROW|RTARROW|SIZER|HSLIDE|VSLIDE 
                      , win_x, win_y
                      , win_w, win_h);
 wind_open(win_hand, win_x, win_y, win_w, win_h);

 sprintf(title,"GEM-DEU: Editing E%dM%d.",episode,mission);
 wind_title(win_hand,title);
/* wind_set(win_hand,WF_INFO,title);
*/
 wind_set(win_hand,WF_HSLSIZE,500);
 wind_set(win_hand,WF_VSLSIZE,500);
 wind_set(win_hand,WF_HSLIDE,501);
 wind_set(win_hand,WF_VSLIDE,501);

 do
   {
 event=evnt_multi(MU_KEYBD | MU_BUTTON | MU_MESAG,
                  1,1,1,
                  0,0,0,0,0,
                  0,0,0,0,0,
                  msgbuf,0,0,
                  &PointerX,&PointerY,&mousebut,&kbstate,&key,&dummy);

if (event & MU_BUTTON)
  {
   if (mousebut==1)
      {
       msgbuf[3]=T_EEDIT; 
       msgbuf[4]=MARKUNMARK;
       event = event | MU_MESAG;
      }
    else
      {
       StretchSelBox = FALSE;
       if (DragObject)
          {
           DragObject = FALSE;
           if (EditMode == OBJ_VERTEXES)
              {
               if (Selected == NULL && CurObject >= 0)
                  {
                   SelectObject( &Selected, CurObject);
                   if (AutoMergeVertices( &Selected))
                       RedrawMap = TRUE;
                   ForgetSelection( &Selected);
                  }
                else if (AutoMergeVertices( &Selected))
                         RedrawMap = TRUE;
               }
             else if (EditMode == OBJ_LINEDEFS)
                     {
/*                    SelPtr NewSel, cur;
*/                    ObjectsNeeded( OBJ_LINEDEFS, 0);
                      NewSel = NULL;
                      if (Selected == NULL && CurObject >= 0)
                         {
                          SelectObject( &NewSel, LineDefs[ CurObject].start);
                          SelectObject( &NewSel, LineDefs[ CurObject].end);
                         }
                       else
                         {
                          for (cur = Selected; cur; cur = cur->next)
                              {
                               if (!IsSelected( NewSel, LineDefs[ cur->objnum].start))
                                   SelectObject( &NewSel, LineDefs[ cur->objnum].start);
                               if (!IsSelected( NewSel, LineDefs[ cur->objnum].end))
                                   SelectObject( &NewSel, LineDefs[ cur->objnum].end);
                              }
                         }
                      if (AutoMergeVertices( &NewSel))
                          RedrawMap = TRUE;
                      ForgetSelection( &NewSel);
                     }
          }
        else
          {
           DragObject = TRUE;
           if (EditMode == OBJ_THINGS && CurObject >= 0)
               MoveObjectsToCoords( EditMode, NULL, Things[ CurObject].xpos, Things[ CurObject].ypos, 0);
           else if (EditMode == OBJ_VERTEXES && CurObject >= 0)
                MoveObjectsToCoords( EditMode, NULL, Vertexes[ CurObject].x, Vertexes[ CurObject].y, 0);
           else MoveObjectsToCoords( EditMode, NULL, MAPX( PointerX), MAPY( PointerY), GridScale);
          }
      }
  }

if (event & MU_KEYBD)
  {
   if (trans_keyb(EDITMENU,kbstate,key,msgbuf)) /* modifies msgbuf to simulate menu accesses */
      {
       event = event | MU_MESAG;
       menu_tnormal(menu,msgbuf[3],0);
      }
  }
if (event & MU_MESAG)
  {
   switch(msgbuf[0])
      {
       case WM_REDRAW:
            RedrawMap=TRUE;
            break;
       case WM_TOPPED:
            if (msgbuf[3]==win_hand)
                wind_set(win_hand,WF_TOP,dummy,dummy,dummy,dummy);
            break;
       case WM_BOTTOM: 
            if (msgbuf[3]==win_hand)
                wind_set(win_hand,25,dummy,dummy,dummy,dummy);
            break;
       case AP_TERM:
       case WM_CLOSED:
            ForgetSelection( &Selected);
            RedrawMap=FALSE;
            break;
       case WM_FULLED:
            if (msgbuf[3]!=win_hand) break;
            wind_get(0,WF_WORKXYWH,&msgbuf[4],&msgbuf[5],&msgbuf[6],&msgbuf[7]);
            if   (msgbuf[4]==win_x && msgbuf[5]==win_y
               && msgbuf[6]==win_w && msgbuf[7]==win_h)
                 {
                  msgbuf[4]=old_x;
                  msgbuf[5]=old_y;
                  msgbuf[6]=old_w;
                  msgbuf[7]=old_h;
                 }
            win_x=msgbuf[4];
            win_y=msgbuf[5];
            win_w=msgbuf[6];
            win_h=msgbuf[7];
            wind_set(win_hand,WF_CURRXYWH,win_x,win_y,win_w,win_h);
            wind_set(win_hand,WF_HSLIDE,501);
            wind_set(win_hand,WF_VSLIDE,501);
            break;
       case WM_SIZED:
            RedrawMap=TRUE;
       case WM_MOVED:
            if (msgbuf[3]!=win_hand) break;
            win_x=msgbuf[4];
            win_y=msgbuf[5];
            win_w=msgbuf[6];
            win_h=msgbuf[7];
            wind_set(win_hand,WF_CURRXYWH,win_x,win_y,win_w,win_h);
            wind_set(win_hand,WF_HSLIDE,501);
            wind_set(win_hand,WF_VSLIDE,501);
            old_x=win_x;
            old_y=win_y;
            old_w=win_w;
            old_h=win_h;
            break;
       case WM_ARROWED:
            switch(msgbuf[4])
              {
               case WA_LFPAGE:
                    OrigX -= (short) ((ScrMaxX/2) / Scale);
                    RedrawMap = TRUE;
                    break;
               case WA_RTPAGE:
                    OrigX += (short) ((ScrMaxX/2) / Scale);
                    RedrawMap = TRUE;
                    break;
               case WA_LFLINE:
                    OrigX -= (short) (16 / Scale);
                    RedrawMap = TRUE;
                    break;
               case WA_RTLINE:
                    OrigX += (short) (16 / Scale);
                    RedrawMap = TRUE;
                    break;
               case WA_UPPAGE:
                    OrigY += (short) ((ScrMaxY/2) / Scale);
                    RedrawMap = TRUE;
                    break;
               case WA_DNPAGE:
                    OrigY -= (short) ((ScrMaxY/2) / Scale);
                    RedrawMap = TRUE;
                    break;
               case WA_UPLINE:
                    OrigY += (short) (16 / Scale);
                    RedrawMap = TRUE;
                    break;
               case WA_DNLINE:
                    OrigY -= (short) (16 / Scale);
                    RedrawMap = TRUE;
                    break;
              }
            break;
       case WM_HSLID: 
            OrigX += (short) (((float)(msgbuf[4]-500)*ScrMaxX/1000.0) / Scale);
            RedrawMap = TRUE;
            break;
       case WM_VSLID: 
            OrigY -= (short) (((float)(msgbuf[4]-500)*ScrMaxY/1000.0) / Scale);
            RedrawMap = TRUE;
            break;
       case MN_SELECTED:
            switch(msgbuf[3])
              {
               case T_EDESK:
                    rsrc_gaddr(0,ABOUTGEMDEU,&form);
                    form_center ( form, &xdial, &ydial, &wdial, &hdial );
                    form_dial ( 0, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
                    objc_draw (form, 0, 2, xdial, ydial, wdial, hdial );
                    seld=form_do ( form, 0 ); 
                    form_dial ( 3, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
                    objc_change (form,seld,-1,-1,-1,-1,-1,NORMAL,1);
                    break;
               case T_EFILE:
                    switch (msgbuf[4])
                       {
                        case EDITSAVE:
                             if (Registered || NoRegisteredChecks)
                                {
                                 char *outfile;
                                 if (CheckStartingPos())
                                    {
                                     outfile = GetWadFileName( episode, mission);
                                     if (outfile)
                                     SaveLevelData( outfile);
                                    }
                                 RedrawMap = TRUE;
                                }
                              break;
                        case EDITSAVEAS:
                             if (Registered || NoRegisteredChecks)
                                {
                                 char *outfile;
                                 short e, m;
                                 MDirPtr newLevel, oldl, newl;
                                 char name[ 7];
        
                                 if (CheckStartingPos())
                                    {
                                     outfile = GetWadFileName( episode, mission);
                                     if (outfile)
                                        {
                                         e = episode;
                                         m = mission;
                                         SelectLevel( &e, &m);
                                         if (e > 0 && m > 0 && (e != episode || m != mission))
                                            {
                                             /* horrible but it works... */
                                             episode = e;
                                             mission = m;
                                             sprintf( name, "E%dM%d", episode, mission);
                                             newLevel = FindMasterDir( MasterDir, name);
                                             oldl = Level;
                                             newl = newLevel;
                                             for (m = 0; m < 11; m++)
                                                 {
                                                  newl->wadfile = oldl->wadfile;
                                                  if (m > 0)
                                                     newl->dir = oldl->dir;
                                              /****
                                              *   if (!strcmp( outfile, oldl->wadfile->filename))
                                              *        {
                                              *         oldl->wadfile = WadFileList;
                                              *         oldl->dir = lost...
                                              *        }
                                              ****/
                                                  oldl = oldl->next;
                                                  newl = newl->next;
                                                 }
                                             Level = newLevel;
                                            }
                                         SaveLevelData( outfile);
                                        }
                                    }
                                 RedrawMap = TRUE;
                                }
                             break;
                        case EDITEXIT:
         	                 ForgetSelection( &Selected);
        	                 if (CheckStartingPos())
                                {
                                 if ((Registered || NoRegisteredChecks) && MadeChanges)
                                    {
                                     char *outfile;
                                     outfile = GetWadFileName( episode, mission);
                                     if (outfile)
                                        {
                                         SaveLevelData( outfile);
                                         break;
                                        }
                                    }
        	                    }
        	                 RedrawMap = TRUE;
                             break;
                       }
               case T_EEDIT:
                    switch (msgbuf[4])
                       {
                        case EDITCOPY:
                             /* copy the object(s) */
                             if (Selected == NULL)
                                SelectObject( &Selected, CurObject);
                             CopyObjects( EditMode, Selected);
                             /* enter drag mode */
                             DragObject = TRUE;
                             CurObject = Selected->objnum;
                             if (EditMode == OBJ_THINGS)
                                  MoveObjectsToCoords( EditMode, NULL, Things[ CurObject].xpos, Things[ CurObject].ypos, 0);
                             else if (EditMode == OBJ_VERTEXES)
                                  MoveObjectsToCoords( EditMode, NULL, Vertexes[ CurObject].x, Vertexes[ CurObject].y, 0);
                             else MoveObjectsToCoords( EditMode, NULL, MAPX( PointerX), MAPY( PointerY), GridScale);
                             RedrawMap = TRUE;
                             StretchSelBox = FALSE;
                             break;
                        case EDITADD:
                             /* first special case: if several Vertices are selected, add new LineDefs */
                             if (EditMode == OBJ_VERTEXES && Selected != NULL && Selected->next != NULL)
                                {
                                 short firstv;
        
                                 ObjectsNeeded( OBJ_LINEDEFS, 0);
                                 if (Selected->next->next != NULL) firstv = Selected->objnum;
                                    else firstv = -1;
                                 EditMode = OBJ_LINEDEFS;
                                 /* create LineDefs between the Vertices */
                                 for (cur = Selected; cur->next; cur = cur->next)
                                     {
                                      /* check if there is already a LineDef between the two Vertices */
                                      for (CurObject = 0; CurObject < NumLineDefs; CurObject++)
                                      if ((LineDefs[ CurObject].start == cur->next->objnum && LineDefs[ CurObject].end == cur->objnum)
                                          || (LineDefs[ CurObject].end == cur->next->objnum && LineDefs[ CurObject].start == cur->objnum))
                                          break;
                                      if (CurObject < NumLineDefs) cur->objnum = CurObject;
                                         else
                                             {
                                              InsertObject( OBJ_LINEDEFS, -1, 0, 0);
                                              CurObject = NumLineDefs - 1;
                                              LineDefs[ CurObject].start = cur->next->objnum;
                                              LineDefs[ CurObject].end = cur->objnum;
                                              cur->objnum = CurObject;
                                             }
                                     }
                                 /* close the polygon if there are more than 2 Vertices */
        	                     if (firstv >= 0 && (kbstate==K_LSHIFT || kbstate==K_RSHIFT))  /* shift key pressed */
                                    {
                                     for (CurObject = 0; CurObject < NumLineDefs; CurObject++)
                                     if ((LineDefs[ CurObject].start == firstv && LineDefs[ CurObject].end == cur->objnum)
                                        || (LineDefs[ CurObject].end == firstv && LineDefs[ CurObject].start == cur->objnum))
                                        break;
                                     if (CurObject < NumLineDefs) cur->objnum = CurObject;
                                        else
                                            {
                                             InsertObject( OBJ_LINEDEFS, -1, 0, 0);
                                             CurObject = NumLineDefs - 1;
                                             LineDefs[ CurObject].start = firstv;
                                             LineDefs[ CurObject].end = cur->objnum;
                                             cur->objnum = CurObject;
                                            }
                                    }
                                  else UnSelectObject( &Selected, cur->objnum);
                                }
        	                 /* second special case: if several LineDefs are selected, add new SideDefs and one Sector */
                             else if (EditMode == OBJ_LINEDEFS && Selected != NULL)
                                  {
                                   ObjectsNeeded( OBJ_LINEDEFS, 0);
                                   for (cur = Selected; cur; cur = cur->next)
                                       if (LineDefs[ cur->objnum].sidedef1 >= 0 && LineDefs[ cur->objnum].sidedef2 >= 0)
                                          {
                                           char msg[ 80];
                                           Beep();
                                           sprintf( msg, "LineDef #%d already has two SideDefs", cur->objnum);
                                           Notify( -1, -1, "Error: cannot add the new Sector", msg);
                                           break;
                                          }
                                   if (cur == NULL)
                                      {
                                       EditMode = OBJ_SECTORS;
                                       InsertObject( OBJ_SECTORS, -1, 0, 0);
                                       CurObject = NumSectors - 1;
                                       for (cur = Selected; cur; cur = cur->next)
                                           {
                                            InsertObject( OBJ_SIDEDEFS, -1, 0, 0);
                                            SideDefs[ NumSideDefs - 1].sector = CurObject;
                                            ObjectsNeeded( OBJ_LINEDEFS, OBJ_SIDEDEFS, 0);
                                            if (LineDefs[ cur->objnum].sidedef1 >= 0)
                                               {
                                                short s;
        
                                                s = SideDefs[ LineDefs[ cur->objnum].sidedef1].sector;
                                                if (s >= 0)
                                                   {
                                                    Sectors[ CurObject].floorh = Sectors[ s].floorh;
                                                    Sectors[ CurObject].ceilh = Sectors[ s].ceilh;
                                                    strncpy( Sectors[ CurObject].floort, Sectors[ s].floort, 8);
                                                    strncpy( Sectors[ CurObject].ceilt, Sectors[ s].ceilt, 8);
                                                    Sectors[ CurObject].light = Sectors[ s].light;
                                                   }
                                                LineDefs[ cur->objnum].sidedef2 = NumSideDefs - 1;
                                                LineDefs[ cur->objnum].flags = 4;
                                                strncpy( SideDefs[ NumSideDefs - 1].tex3, "-", 8);
                                                strncpy( SideDefs[ LineDefs[ cur->objnum].sidedef1].tex3, "-", 8);
                                               }
                                            else LineDefs[ cur->objnum].sidedef1 = NumSideDefs - 1;
                                           }
                                       ForgetSelection( &Selected);
                                       SelectObject( &Selected, CurObject);
                                      }
                                   }
                             /* normal case: add a new object of the current type */
                             else
                                 {
                                  ForgetSelection( &Selected);
                                  if (GridScale > 0)
                                       InsertObject( EditMode, CurObject, (MAPX( PointerX) + GridScale / 2) & ~(GridScale - 1), (MAPY( PointerY) + GridScale / 2) & ~(GridScale - 1));
                                  else InsertObject( EditMode, CurObject, MAPX( PointerX), MAPY( PointerY));
                                  CurObject = GetMaxObjectNum( EditMode);
                                  if (EditMode == OBJ_LINEDEFS)
                                     {
                                      if (! Input2VertexNumbers( -1, -1, "Choose the two vertices for the new LineDef",
                                          &(LineDefs[ CurObject].start), &(LineDefs[ CurObject].end)))
                                           {
                                            DeleteObject( EditMode, CurObject);
                                            CurObject = -1;
                                           }
                                     }
                                  else if (EditMode == OBJ_VERTEXES)
                                     {
                                      SelectObject( &Selected, CurObject);
                                      if (AutoMergeVertices( &Selected)) RedrawMap = TRUE;
                                      ForgetSelection( &Selected);
                                     }
                                 }
                             DragObject = FALSE;
                             StretchSelBox = FALSE;
                             RedrawMap = TRUE;
                             break;
                        case EDITDELETE:
                             if (EditMode == OBJ_THINGS || Expert || form_alert(2,"[1]Do you really want to delete this object? |This will also delete the objects bound to them. [Yes|Cancel]")==1)
                                {
                                 if (Selected) DeleteObjects( EditMode, &Selected);
                                    else DeleteObject( EditMode, CurObject);
                                 CurObject = -1;
                                }
                             DragObject = FALSE;
                             StretchSelBox = FALSE;
                             RedrawMap = TRUE;
                             break;
                        case EDITEDITOBJ:
                             if (Selected)
                                 EditObjectsInfo( 0, 30, EditMode, Selected);
                               else
                                 {
                                  SelectObject( &Selected, CurObject);
                                  EditObjectsInfo( 0, 30, EditMode, Selected);
                                  UnSelectObject( &Selected, CurObject);
                                 }
                             RedrawMap = TRUE;
                             DragObject = FALSE;
                             StretchSelBox = FALSE;
                             break;
                        case MARKUNMARK:
                             if (StretchSelBox)
                                {
                                 SelPtr oldsel;

                                 /* select all objects in the selection box */
                                 StretchSelBox = FALSE;
                                 RedrawMap = TRUE;
                                 /* additive selection box or not? */
                                 if (AdditiveSelBox == FALSE)
                                     ForgetSelection( &Selected);
                                   else oldsel = Selected;
                                 Selected = SelectObjectsInBox( EditMode, SelBoxX, SelBoxY, MAPX( PointerX), MAPY( PointerY));
                                 if (AdditiveSelBox == TRUE)
                                     while (oldsel != NULL)
                                       {
                                        if (! IsSelected( Selected, oldsel->objnum))
                                            SelectObject( &Selected, oldsel->objnum);
                                        UnSelectObject( &oldsel, oldsel->objnum);
                                       }
                                 if (Selected)
                                    {
                                     CurObject = Selected->objnum;
                                     PlaySound( 440, 10);
                                    }
                                  else CurObject = -1;
                                 }
                               else if (kbstate!=K_LSHIFT && kbstate!=K_RSHIFT)  /* no shift keys */
                                 {
                                  if (CurObject >= 0)
                                     {
                                      /* mark or unmark one object */
                                      if (IsSelected( Selected, CurObject))
                                          UnSelectObject( &Selected, CurObject);
                                        else SelectObject( &Selected, CurObject);
                                      HighlightObject( EditMode, CurObject, GREEN);
                                      if (Selected) PlaySound( 440, 10);
                                      DragObject = FALSE;
                                     }
                                   else Beep();
                                 }
                               else
                                 {
                                  /* begin "stretch selection box" mode */
                                  SelBoxX = MAPX( PointerX);
                                  SelBoxY = MAPY( PointerY);
                                  StretchSelBox = TRUE;
                                  DragObject = FALSE;
                                 }
                             break;
                        case CLEARMARKS:
                             ForgetSelection( &Selected);
                             RedrawMap = TRUE;
                             DragObject = FALSE;
                             StretchSelBox = FALSE;
                             break;
                        case EDITPREFS:
                             Preferences( -1, -1);
                             RedrawMap = TRUE;
                             break;
                       }
               case T_ESEARCH:
                    switch (msgbuf[4])
                       {
                        case EDITFIND:
                        case EDITREPEATFIND:
                        case EDITNEXT:
                             if (CurObject < GetMaxObjectNum( EditMode))
                                     CurObject++;
                             else if (GetMaxObjectNum( EditMode) >= 0)
                                     CurObject = 0;
                             else    CurObject = -1;
                             RedrawMap = TRUE;
                             break;
                        case EDITPREV:
                             if (CurObject > 0)
                                CurObject--;
                             else
                                CurObject = GetMaxObjectNum( EditMode);
                             RedrawMap = TRUE;
                             break;
                        case EDITJUMPTONEXT:
                             rsrc_gaddr(0,JUMPTO,&form);
                             tempi=GetMaxObjectNum(EditMode);
                             sprintf(temp,"%d",tempi);
                             objc_newtext(form,JUMPTOEND,temp);
                             objc_newtext(form,JUMPTOTYPE,GetObjectTypeName(EditMode));
                             form_center ( form, &xdial, &ydial, &wdial, &hdial );
                             form_dial ( 0, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
                             objc_draw (form, 0, 2, xdial, ydial, wdial, hdial );
                             seld=form_do ( form, 0 ); 
                             form_dial ( 3, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
                             objc_change (form,seld,-1,-1,-1,-1,-1,NORMAL,1);
                            
                             OldObject=atoi(objc_text(form,JUMPTONUM));
                             if (OldObject >= 0 && OldObject <= GetMaxObjectNum(EditMode))
                                {
                                 CurObject = OldObject;
                                 GoToObject( EditMode, CurObject);
                                }
                              else OldObject = CurObject;
                              RedrawMap = TRUE;
                              break;
                       }
               case T_EMODES: /* These require extra code (below) before they will work correctly. */
                    PrevMode = EditMode;
                    switch (msgbuf[4])
                       {
                        case EDITMODE_THING:
                             EditMode = OBJ_THINGS;
                             menu_icheck(menu,EDITMODE_THING,1);
                             menu_icheck(menu,EDITMODE_LINE,0);
                             menu_icheck(menu,EDITMODE_VERTEX,0);
                             menu_icheck(menu,EDITMODE_SECTORS,0);
                             RedrawMap = TRUE;
                             break;
                        case EDITMODE_LINE:
                             EditMode = OBJ_LINEDEFS;
                             menu_icheck(menu,EDITMODE_THING,0);
                             menu_icheck(menu,EDITMODE_LINE,1);
                             menu_icheck(menu,EDITMODE_VERTEX,0);
                             menu_icheck(menu,EDITMODE_SECTORS,0);
                             RedrawMap = TRUE;
                             break;
                        case EDITMODE_VERTEX:
                             EditMode = OBJ_VERTEXES;
                             menu_icheck(menu,EDITMODE_THING,0);
                             menu_icheck(menu,EDITMODE_LINE,0);
                             menu_icheck(menu,EDITMODE_VERTEX,1);
                             menu_icheck(menu,EDITMODE_SECTORS,0);
                             RedrawMap = TRUE;
                             break;
                        case EDITMODE_SECTORS:
                             EditMode = OBJ_SECTORS;
                             menu_icheck(menu,EDITMODE_THING,0);
                             menu_icheck(menu,EDITMODE_LINE,0);
                             menu_icheck(menu,EDITMODE_VERTEX,0);
                             menu_icheck(menu,EDITMODE_SECTORS,1);
                             RedrawMap = TRUE;
                             break;
                        case EDITMODE_NEXT: 
                             menu_icheck(menu,EDITMODE_THING,0);
                             menu_icheck(menu,EDITMODE_LINE,0);
                             menu_icheck(menu,EDITMODE_VERTEX,0);
                             menu_icheck(menu,EDITMODE_SECTORS,0);
                             switch (EditMode)
                                {
                                 case OBJ_THINGS:
                                      EditMode = OBJ_VERTEXES;
                                      menu_icheck(menu,EDITMODE_VERTEX,1);
                                      break;
                                 case OBJ_VERTEXES:
                                      EditMode = OBJ_LINEDEFS;
                                      menu_icheck(menu,EDITMODE_LINE,1);
                                      break;
                                 case OBJ_LINEDEFS:
                                      EditMode = OBJ_SECTORS;
                                      menu_icheck(menu,EDITMODE_SECTORS,1);
                                      break;
                                 case OBJ_SECTORS:
                                      EditMode = OBJ_THINGS;
                                      menu_icheck(menu,EDITMODE_THING,1);
                                      break;
                                }
                             RedrawMap = TRUE;
                             break;
                        case EDITMODE_PREV:
                             menu_icheck(menu,EDITMODE_THING,0);
                             menu_icheck(menu,EDITMODE_LINE,0);
                             menu_icheck(menu,EDITMODE_VERTEX,0);
                             menu_icheck(menu,EDITMODE_SECTORS,0);
                             switch (EditMode)
                                {
                                 case OBJ_THINGS:
                                      EditMode = OBJ_SECTORS;
                                      menu_icheck(menu,EDITMODE_SECTORS,1);
                                      break;
                                 case OBJ_VERTEXES:
                                      EditMode = OBJ_THINGS;
                                      menu_icheck(menu,EDITMODE_THING,1);
                                      break;
                                 case OBJ_LINEDEFS:
                                      EditMode = OBJ_VERTEXES;
                                      menu_icheck(menu,EDITMODE_VERTEX,1);
                                      break;
                                 case OBJ_SECTORS:
                                      EditMode = OBJ_LINEDEFS;
                                      menu_icheck(menu,EDITMODE_LINE,1);
                                      break;
                                 }
                             RedrawMap = TRUE;
                             break;
                        case EDITMODE_3D:
                             NotImplemented();
                             break;
                       }
               case T_EMISC:
                    switch (msgbuf[4])
                       {
                        case SHOWRULERS:
                             break;
                        case DISPLAYGRID:
                             GridShown = !GridShown;
                             menu_icheck(menu,DISPLAYGRID,GridShown);
                             RedrawMap = TRUE;
                             break;
                        case INCGRIDSCALE:
                             if (GridScale == 0) GridScale = 8;
                                else if (GridScale < 256) GridScale *= 2;
                                else GridScale = 0;
                             RedrawMap=TRUE;
                             break;
                        case DECGRIDSCALE:
                             if (GridScale == 0) GridScale = 256;
                                else if (GridScale > 8) GridScale /= 2;
                                else GridScale = 0;
                             RedrawMap=TRUE;	    
                             break;
                        case INCSCALE:
                             if (Scale < 4.0)
                                {
                                 OrigX += (short) ((PointerX - ScrCenterX) / Scale);
                                 OrigY += (short) ((ScrCenterY - PointerY) / Scale);
                                 if (Scale < 1.0)
                                     Scale = 1.0 / ((1.0 / Scale) - 1.0);
                                   else
                                     Scale = Scale * 2.0;
                                 OrigX -= (short) ((PointerX - ScrCenterX) / Scale);
                                 OrigY -= (short) ((ScrCenterY - PointerY) / Scale);
                                 RedrawMap = TRUE;
                                }
                             break;
                        case DECSCALE:
                             if (Scale > 0.05)
                                {
                                 OrigX += (short) ((PointerX - ScrCenterX) / Scale);
                                 OrigY += (short) ((ScrCenterY - PointerY) / Scale);
                                 if (Scale < 1.0)
                                     Scale = 1.0 / ((1.0 / Scale) + 1.0);
                                   else
                                     Scale = Scale / 2.0;
                                 OrigX -= (short) ((PointerX - ScrCenterX) / Scale);
                                 OrigY -= (short) ((ScrCenterY - PointerY) / Scale);
                                 RedrawMap = TRUE;
                                }
                             break;
                        case SETSCALE:
                             OrigX += (short) ((PointerX - ScrCenterX) / Scale);
                             OrigY += (short) ((ScrCenterY - PointerY) / Scale);

                             rsrc_gaddr(0,SETSCALEDIAG,&form);
                             if (Scale < 1) tempi=1;
                                 else tempi=Scale;
                             sprintf(temp,"%d",tempi);
                             objc_newtext(form,SCALETOP,temp);
                             if (Scale < 1) tempi=1.0/Scale;
                                 else tempi=1;
                             sprintf(temp,"%d",tempi);
                             objc_newtext(form,SCALEBOT,temp);
                             form_center ( form, &xdial, &ydial, &wdial, &hdial );
                             form_dial ( 0, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
                             objc_draw (form, 0, 2, xdial, ydial, wdial, hdial );
                             seld=form_do ( form, 0 ); 
                             form_dial ( 3, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
                             objc_change (form,seld,-1,-1,-1,-1,-1,NORMAL,1);

	                         Scale = (float)(atoi(objc_text(form,SCALETOP))) /(float)(atoi(objc_text(form,SCALEBOT))) ;
                             OrigX -= (short) ((PointerX - ScrCenterX) / Scale);
                             OrigY -= (short) ((ScrCenterY - PointerY) / Scale);
                             RedrawMap = TRUE;
                             break;
                       }
               case T_ECHECK:
                    switch (msgbuf[4])
                       {
                        case CHECK_STATS:
                             Statistics(-1,-1);
                             break;
                        case CHECK_SECTORS:
                             CheckSectors();
                             break;
                        case CHECK_XREFS:
                             CheckCrossReferences();
                             break;
                        case CHECK_TEXTURES:
                             CheckTextures();
                             break;
                       }
               case T_EHELP:
                    switch (msgbuf[4])
                       {
                        case EDITHELP_CONTROL:
                             rsrc_gaddr(0,HELPFORM,&form);
                             form_center ( form, &xdial, &ydial, &wdial, &hdial );
                             form_dial ( 0, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
                             objc_draw (form, 0, 2, xdial, ydial, wdial, hdial );
                             seld=form_do ( form, 0 ); 
                             form_dial ( 3, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
                             objc_change (form,seld,-1,-1,-1,-1,-1,NORMAL,1);
                             break;
                        case EDITHELP_INFOBAR:
                             InfoShown = !InfoShown;
                             RedrawMap = TRUE;
                             menu_icheck(menu,EDITHELP_INFOBAR,InfoShown);
                             break;
                        case EDIT_ABOUT:
                             rsrc_gaddr(0,ABOUTGEMDEU,&form);
                             form_center ( form, &xdial, &ydial, &wdial, &hdial );
                             form_dial ( 0, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
                             objc_draw (form, 0, 2, xdial, ydial, wdial, hdial );
                             seld=form_do ( form, 0 ); 
                             form_dial ( 3, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
                             objc_change (form,seld,-1,-1,-1,-1,-1,NORMAL,1);
                             break;
                       }
              }
            menu_tnormal(menu,msgbuf[3],1);                                  
            break;
      }

    if (RedrawMap)
       {
        wind_get(win_hand,WF_WORKXYWH,&vdi_rect[0], &vdi_rect[1], &vdi_rect[2], &vdi_rect[3]);
        ScrMaxX=vdi_rect[2];
        ScrMaxY=vdi_rect[3];
        ScrCenterX=ScrMaxX/2;
        ScrCenterY=ScrMaxY/2;
        vdi_rect[2]=vdi_rect[2]+vdi_rect[0] - 1;
        vdi_rect[3]=vdi_rect[3]+vdi_rect[1] - 1;
        vs_clip(workstation, 1, vdi_rect);
        graf_mouse(256, 0);

        DrawMap( EditMode, GridScale, GridShown, win_hand);
        HighlightSelection( EditMode, Selected);
        RedrawMap=FALSE;

        graf_mouse(0, 0);
        graf_mouse(257, 0);
       }
      }     

    if (event & MU_MESAG)
       {
        if (msgbuf[0]==MN_SELECTED && msgbuf[4]==EDITEXIT) doquit=TRUE;
        if (msgbuf[0]==WM_CLOSED) doquit=TRUE;      
       }
   } while (!doquit);

 /* Restore system. (remove window/menu) */
 menu_bar(menu,0);

 wind_close(win_hand);
 wind_delete(win_hand);

 return;


/*
** OLD PC code. Should NEVER reach this.
*/
   for (;;)
   {
      key = 0;
      altkey = 0;

      /* get mouse position and button status */
      if (UseMouse)
      {
	 if (FakeCursor || ShowRulers)
	 {
	    HideMousePointer();
	    DrawPointer( ShowRulers);
	    ShowMousePointer();
	 }
	 GetMouseCoords( &PointerX, &PointerY, &buttons);
	 if (FakeCursor || ShowRulers)
	 {
	    HideMousePointer();
	    DrawPointer( ShowRulers);
	    ShowMousePointer();
	 }
	 if ( buttons == 1 && PointerY < 17)
	 {
	    /* kluge for the menu bar */
	    altkey = 0x08;
	    if (PointerX < 12)
	       Beep();
	    else if (PointerX < 60)
	       key = 0x2100; /* 'F' */
	    else if (PointerX < 108)
	       key = 0x1200; /* 'E' */
	    else if (PointerX < 172)
	       key = 0x1f00; /* 'S' */
	    else if (PointerX < 228)
	       key = 0x3200; /* 'M' */
	    else if (PointerX < 276)
	       key = 0x1700; /* 'I' */
	    else if (PointerX < 348)
	       key = 0x1800; /* 'O' */
	    else if (PointerX < 406)
	       key = 0x2E00; /* 'C' */
	    else if (PointerX < ScrMaxX - 43)
	       Beep();
	    else
	       key = 0x2300; /* 'H' */
	 }
	 else
	 {
printf("Reached keyboard stuff.\n");
 oldbuttons=1;
	    if (buttons != oldbuttons)
	    {
	       switch (buttons)
	       {
	       case 1:
		  if (SwapButtons)
		     key = 0x000D;
		  else
		     key = 'M';      /* Press left button = Mark/Unmark ('M') */
		  break;
	       case 2:
		  if (! DragObject)
		     key = 'D';      /* Press right button = Drag */
		  break;
	       case 3:
	       case 4:
		  if (SwapButtons)
		     key = 'M';
		  else
		     key = 0x000D;   /* Press middle button = Edit ('Enter') */
		  break;
	       default:
		  if (StretchSelBox) /* Release left button = End Selection Box */
		     key = 'M';
		  if (DragObject)    /* Release right button = End Drag */
		     key = 'D';
		  break;
	       }
	       altkey = 0x08; bioskey( 2);
	    }
	 }
	 oldbuttons = buttons;
      }

      /* drag object(s) */
      if (DragObject)
      {
	 Bool forgetit = FALSE;

	 if (IsSelected( Selected, CurObject) == FALSE)
	    ForgetSelection( &Selected);
	 else if (Selected->objnum != CurObject)
	 {
	    /* current object must be first in the list */
	    UnSelectObject( &Selected, CurObject);
	    SelectObject( &Selected, CurObject);
	 }
	 if (Selected == NULL && CurObject >= 0)
	 {
	    SelectObject( &Selected, CurObject);
	    forgetit = TRUE;
	 }
	 if (Selected)
	 {
	    if (MoveObjectsToCoords( EditMode, Selected, MAPX( PointerX), MAPY( PointerY), GridScale))
	       RedrawMap = TRUE;
	    if (forgetit)
	       ForgetSelection( &Selected);
	 }
	 else
	 {
	    Beep();
	    DragObject = FALSE;
	 }
      }
      else if (StretchSelBox)
      {
	 short x = MAPX( PointerX);
	 short y = MAPY( PointerY);

	 /* draw selection box */
	 SetColor( CYAN);
/*	 setwritemode( XOR_PUT);
*/	 if (UseMouse)
	    HideMousePointer();
	 DrawMapLine( SelBoxX, SelBoxY, SelBoxX, y);
	 DrawMapLine( SelBoxX, y, x, y);
	 DrawMapLine( x, y, x, SelBoxY);
	 DrawMapLine( x, SelBoxY, SelBoxX, SelBoxY);
	 if (UseMouse)
	    ShowMousePointer();
	 delay( 50);
	 if (UseMouse)
	    HideMousePointer();
	 DrawMapLine( SelBoxX, SelBoxY, SelBoxX, y);
	 DrawMapLine( SelBoxX, y, x, y);
	 DrawMapLine( x, y, x, SelBoxY);
	 DrawMapLine( x, SelBoxY, SelBoxX, SelBoxY);
/*	 setwritemode( COPY_PUT);
*/	 if (UseMouse)
	    ShowMousePointer();
      }
      else if (!RedrawObj)
      {
	 /* check if there is something near the pointer */
	 OldObject = CurObject;
	 if ((bioskey( 2) & 0x03) == 0x00)  /* no shift keys */
	    CurObject = GetCurObject( EditMode, MAPX( PointerX - 4), MAPY( PointerY - 4), MAPX( PointerX + 4), MAPY( PointerY + 4));
	 if (CurObject < 0)
	    CurObject = OldObject;
      }

      /* draw the map */
      if (RedrawMap)
      {
	 if (UseMouse)
	    HideMousePointer();
	 DrawMap( EditMode, GridScale, GridShown, win_hand);
	 HighlightSelection( EditMode, Selected);
	 if (UseMouse)
	    ShowMousePointer();
      }

      /* highlight the current object and display the information box */
      if (RedrawMap || CurObject != OldObject || RedrawObj)
      {
	 RedrawObj = FALSE;
	 if (UseMouse)
	    HideMousePointer();
	 if (!RedrawMap && OldObject >= 0)
	    HighlightObject( EditMode, OldObject, YELLOW);
	 if (CurObject != OldObject)
	 {
	    PlaySound( 50, 10);
	    OldObject = CurObject;
	 }
	 if (CurObject >= 0)
	    HighlightObject( EditMode, CurObject, YELLOW);
	 if (bioskey( 1)) /* speedup */
	    RedrawObj = TRUE;
	 else
	    DisplayObjectInfo( EditMode, CurObject);
	 if (UseMouse)
	    ShowMousePointer();
      }

      /* redraw the pointer if necessary */
      if (RedrawMap && (FakeCursor || ShowRulers))
      {
	 if (UseMouse)
	    HideMousePointer();
	 DrawPointer( ShowRulers);
	 if (UseMouse)
	    ShowMousePointer();
      }

      /* display the current pointer coordinates */
      if (RedrawMap || PointerX != OldPointerX || PointerY != OldPointerY)
      {
	 SetColor(7);
	 DrawScreenBox( ScrMaxX - 170, 4, ScrMaxX - 50, 12);
	 SetColor( BLUE);
	 DrawScreenText( ScrMaxX - 170, 4, "%d, %d", MAPX( PointerX), MAPY( PointerY));
	 OldPointerX = PointerX;
	 OldPointerY = PointerY;
      }

      /* the map is up to date */
      RedrawMap = FALSE;

      /* get user input */
/*      if (bioskey( 1) || key)
*/
key=kbhit();
if (key)
      {
/*	 if (! key)
*/	 {
printf("Got it!\n");
	    key = bioskey( 0);
	    altkey = bioskey( 2);
	    
/*	    key=kbhit();
*/	    altkey=0x08;
	 }

	 /* user wants to access the drop-down menus */
	 if (altkey & 0x08)    /* if alt is pressed... */
	 {
printf("menu\n");
/*	    if ((key & 0xFF00) == 0x2100)*/       /* Scan code for F */
	 if (key=='f' || key=='F')
       key = PullDownMenu( 18, 19,
				   "Save         F2", 0x3C00,    (int) 'S', 1,
				   "Save As ExMx F3", 0x3D00,    (int) 'A', 6,
				   "Print          ", -1,        (int) 'P', -1,
				   "Quit          Q", (int) 'Q', (int) 'Q', 1,
				   NULL);
	    else if ((key & 0xFF00) == 0x1200)  /* Scan code for E */
	    {
	       key = PullDownMenu( 66, 19,
				   "Copy object(s)      O", (int) 'O', (int) 'C', 1,
				   "Add object        Ins", 0x5200,    (int) 'A', 1,
				   "Delete object(s)  Del", 0x5300,    (int) 'D', 1,
				   ((EditMode == OBJ_VERTEXES) ?
				   NULL :
				   "Preferences        F5"), 0x3F00,   (int) 'P', 1,
				   NULL);
	    }
	    else if ((key & 0xFF00) == 0x1F00)  /* Scan code for S */
	       key = PullDownMenu( 114, 19,
				   "Find/Change       F4", -1,        (int) 'F', -1,
				   "Repeat last find    ", -1,        (int) 'R', -1,
				   "Next object        N", (int) 'N', (int) 'N', 1,
				   "Prev object        P", (int) 'P', (int) 'P', 1,
				   "Jump to object...  J", (int) 'J', (int) 'J', 1,
				   NULL);
	    else if ((key & 0xFF00) == 0x3200)  /* Scan code for M */
	       key = PullDownMenu( 178, 19,
				   ((EditMode == OBJ_THINGS) ?
				   "û Things              T" :
				   "  Things              T"), (int) 'T', (int) 'T', 3,
				   ((EditMode == OBJ_LINEDEFS) ?
				   "û Linedefs+Sidedefs   L" :
				   "  Linedefs+Sidedefs   L"), (int) 'L', (int) 'L', 3,
				   ((EditMode == OBJ_VERTEXES) ?
				   "û Vertexes            V" :
				   "  Vertexes            V"), (int) 'V', (int) 'V', 3,
				   ((EditMode == OBJ_SECTORS) ?
				   "û Sectors             S" :
				   "  Sectors             S"), (int) 'S', (int) 'S', 3,
				   "  Next mode         Tab",  0x0009,    (int) 'N', 3,
				   "  Last mode   Shift+Tab",  0x0F00,    (int) 'L', 3,
				   "  3D Preview          3",  (int) '3', (int) '3', -1,
				   NULL);
	    else if ((key & 0xFF00) == 0x1700)  /* Scan code for I */
	    {
	       key = 0;
	       /* code duplicated from 'F8' - I hate to do that */
	       if (Selected)
		  MiscOperations( 234, 19, EditMode, &Selected);
	       else
	       {
		  if (CurObject >= 0)
		     SelectObject( &Selected, CurObject);
		  MiscOperations( 234, 19, EditMode, &Selected);
		  if (CurObject >= 0)
		     UnSelectObject( &Selected, CurObject);
	       }
	       CurObject = -1;
	       DragObject = FALSE;
	       StretchSelBox = FALSE;
	    }
	    else if ((key & 0xFF00) == 0x1800)  /* Scan code for O */
	    {
	       short savednum, i;

	       key = 0;
	       /* don't want to create the object behind the menu bar... */
	       if (PointerY < 20)
	       {
		  PointerX = ScrCenterX;
		  PointerY = ScrCenterY;
	       }
	       /* code duplicated from 'F9' - I hate to do that */
	       savednum = NumLineDefs;
	       InsertStandardObject( 282, 19, MAPX( PointerX), MAPY( PointerY));
	       if (NumLineDefs > savednum)
	       {
		  ForgetSelection( &Selected);
		  EditMode = OBJ_LINEDEFS;
		  for (i = savednum; i < NumLineDefs; i++)
		     SelectObject( &Selected, i);
		  CurObject = NumLineDefs - 1;
		  OldObject = -1;
		  DragObject = FALSE;
		  StretchSelBox = FALSE;
	       }
	    }
	    else if ((key & 0xFF00) == 0x2E00)  /* Scan code for C */
	    {
	       key = 0; 
	       CheckLevel( 354, 19);
	    }
	    else if ((key & 0xFF00) == 0x2300)  /* Scan code for H */
	       key = PullDownMenu( ScrMaxX, 19,
				   "  Keyboard & mouse  F1",  0x3B00,    (int) 'K', 3,
				   (InfoShown ?
				   "û Info bar           I" :
				   "  Info bar           I"), (int) 'I', (int) 'I', 3,
				   "  About DEU...        ",  -1,        (int) 'A', -1,
				   NULL);
	    else
	    {
	       Beep();
	       key = 0;
	    }
	    RedrawMap = TRUE;
	 }

	 /* User wants to do the impossible. */
	 if (key == -1)
	 {
	    NotImplemented();
	    RedrawMap = TRUE;
	 }

	 /* erase the (keyboard) pointer */
	 if (FakeCursor || ShowRulers)
	 {
	    HideMousePointer();
	    DrawPointer( ShowRulers);
	    ShowMousePointer();
	 }

keychar='Q'; /* To remove a warning... */
	 /* user wants to exit */
	 if (keychar == 'Q')
	 {
	 }
	 else if ((key & 0x00FF) == 0x001B) /* 'Esc' */
	 {
	    if (DragObject)
	       DragObject = FALSE;
	    else if (StretchSelBox)
	       StretchSelBox = FALSE;
	    else
	    {
	       ForgetSelection( &Selected);
	       if (!MadeChanges || Confirm(-1, -1, "You have unsaved changes.  Do you really want to quit?", NULL))
		  break;
	       RedrawMap = TRUE;
	    }
	 }

	 /* user is lost */
	 else if ((key & 0xFF00) == 0x3B00) /* 'F1' */
	 {
	 }

	 /* user wants to save the level data */
	 else if ((key & 0xFF00) == 0x3C00 && Registered) /* 'F2' */
	 {
	 }

	 /* user wants to save and change the episode and mission numbers */
	 else if ((key & 0xFF00) == 0x3D00 && Registered) /* 'F3' */
	 {
	 }

	 /* user wants to get the 'Preferences' menu */
	 else if ((key & 0xFF00) == 0x3F00) /* 'F5' */
	 {
	 }
	 /* user wants to get the menu of misc. ops */
	 else if ((key & 0xFF00) == 0x4200) /* 'F8' */
	 {
	    if (Selected)
	       MiscOperations( -1, -1, EditMode, &Selected);
	    else
	    {
	       if (CurObject >= 0)
		  SelectObject( &Selected, CurObject);
	       MiscOperations( -1, -1, EditMode, &Selected);
	       if (CurObject >= 0)
		  UnSelectObject( &Selected, CurObject);
	    }
	    CurObject = -1;
	    RedrawMap = TRUE;
	    DragObject = FALSE;
	    StretchSelBox = FALSE;
	 }

	 /* user wants to insert a standard shape */
	 else if ((key & 0xFF00) == 0x4300) /* 'F9' */
	 {
	    short savednum, i;

	    savednum = NumLineDefs;
	    InsertStandardObject( -1, -1, MAPX( PointerX), MAPY( PointerY));
	    if (NumLineDefs > savednum)
	    {
	       ForgetSelection( &Selected);
	       EditMode = OBJ_LINEDEFS;
	       for (i = savednum; i < NumLineDefs; i++)
		  SelectObject( &Selected, i);
	       CurObject = NumLineDefs - 1;
	       OldObject = -1;
	       DragObject = FALSE;
	       StretchSelBox = FALSE;
	    }
	    RedrawMap = TRUE;
	 }

	 /* user wants to check his level */
	 else if ((key & 0xFF00) == 0x4400) /* 'F10' */
	 {
	    RedrawMap = TRUE;
	 }

	 /* user wants to display/hide the info box */
	 else if (keychar == 'I')
	 {
	 }

	 /* user wants to change the scale */
	 else if ((keychar == '+' || keychar == '=') && Scale < 4.0)
	 {
	 }
	 else if ((keychar == '-' || keychar == '_') && Scale > 0.05)
	 {
	 }

	 /* user wants to set the scale directly */
	 else if (keychar >= '0' && keychar <= '9')
	 {
	 }

	 /* user wants to move */
	 else if ((key & 0xFF00) == 0x4800 && (PointerY - MoveSpeed) >= 0)
	 {
	 }

	 /* user wants to scroll the map (scroll one half page at a time) */
	 else if ((key & 0xFF00) == 0x4900 && MAPY( ScrCenterY) < MapMaxY)
	 {
	 }
	 else if ((key & 0xFF00) == 0x5100 && MAPY( ScrCenterY) > MapMinY)
	 {
	 }
	 else if ((key & 0xFF00) == 0x4700 && MAPX( ScrCenterX) > MapMinX)
	 {
	 }
	 else if ((key & 0xFF00) == 0x4F00 && MAPX( ScrCenterX) < MapMaxX)
	 {
	 }

	 /* user wants to change the movement speed */
	 else if (keychar == ' ')
	    MoveSpeed = MoveSpeed == 1 ? 20 : 1;

	 /* user wants to change the edit mode */
	 else if ((key & 0x00FF) == 0x0009 || (key & 0xFF00) == 0x0F00 || keychar == 'T' || keychar == 'V' || keychar == 'L' || keychar == 'S')
	 {

/*
** NOTE: This must be called by ALL of the 'change mode' routines.
**
*/
/*	    if (Selected)
	    {
	       if (PrevMode == OBJ_SECTORS && EditMode == OBJ_LINEDEFS)
	       {
		  short l, sd;

		  ObjectsNeeded( OBJ_LINEDEFS, OBJ_SIDEDEFS, 0);
		  NewSel = NULL;
		  for (l = 0; l < NumLineDefs; l++)
		  {
		     sd = LineDefs[ l].sidedef1;
		     if (sd >= 0 && IsSelected( Selected, SideDefs[ sd].sector))
			SelectObject( &NewSel, l);
		     else
		     {
			sd = LineDefs[ l].sidedef2;
			if (sd >= 0 && IsSelected( Selected, SideDefs[ sd].sector))
			   SelectObject( &NewSel, l);
		     }
		  }
		  ForgetSelection( &Selected);
		  Selected = NewSel;
	       }
	       else if (PrevMode == OBJ_LINEDEFS && EditMode == OBJ_VERTEXES)
	       {
		  ObjectsNeeded( OBJ_LINEDEFS, 0);
		  NewSel = NULL;
		  while (Selected)
		  {
		     if (!IsSelected( NewSel, LineDefs[ Selected->objnum].start))
			SelectObject( &NewSel, LineDefs[ Selected->objnum].start);
		     if (!IsSelected( NewSel, LineDefs[ Selected->objnum].end))
			SelectObject( &NewSel, LineDefs[ Selected->objnum].end);
		     UnSelectObject( &Selected, Selected->objnum);
		  }
		  Selected = NewSel;
	       }
	       else if (PrevMode == OBJ_LINEDEFS && EditMode == OBJ_SECTORS)
	       {
		  short l, sd;

		  ObjectsNeeded( OBJ_LINEDEFS, OBJ_SIDEDEFS, 0);
		  NewSel = NULL;
		  for (l = 0; l < NumSectors; l++)
		     SelectObject( &NewSel, l);
		  for (l = 0; l < NumLineDefs; l++)
		     if (!IsSelected( Selected, l))
		     {
			sd = LineDefs[ l].sidedef1;
			if (sd >= 0)
			   UnSelectObject( &NewSel, SideDefs[ sd].sector);
			sd = LineDefs[ l].sidedef2;
			if (sd >= 0)
			   UnSelectObject( &NewSel, SideDefs[ sd].sector);
		     }
		  ForgetSelection( &Selected);
		  Selected = NewSel;
	       }
	       else if (PrevMode == OBJ_VERTEXES && EditMode == OBJ_LINEDEFS)
	       {
		  short l;

		  ObjectsNeeded( OBJ_LINEDEFS, 0);
		  NewSel = NULL;
		  for (l = 0; l < NumLineDefs; l++)
		     if (IsSelected( Selected, LineDefs[ l].start) && IsSelected( Selected, LineDefs[ l].end))
			SelectObject( &NewSel, l);
		  ForgetSelection( &Selected);
		  Selected = NewSel;
	       }
	       else
		  ForgetSelection( &Selected);
	    }
	    if (GetMaxObjectNum( EditMode) >= 0 && Select0 == TRUE)
	       CurObject = 0;
	    else
	       CurObject = -1;
	    OldObject = -1;
	    DragObject = FALSE;
	    StretchSelBox = FALSE;
	    RedrawMap = TRUE;
*/	 }

	 /* user wants to change the grid scale */
	 else if (keychar == 'G')
	 {
	 }

	 /* user wants to display or hide the grid */
	 else if (keychar == 'H')
	 {
	 }

	 /* user wants to toggle the rulers */
	 else if (keychar == 'R')
	    ShowRulers = !ShowRulers;

	 /* user wants to toggle drag mode */
	 else if (keychar == 'D')
	 {
	    StretchSelBox = FALSE;
	    if (DragObject)
	    {
	       DragObject = FALSE;
	       if (EditMode == OBJ_VERTEXES)
	       {
		  if (Selected == NULL && CurObject >= 0)
		  {
		     SelectObject( &Selected, CurObject);
		     if (AutoMergeVertices( &Selected))
			RedrawMap = TRUE;
		     ForgetSelection( &Selected);
		  }
		  else
		     if (AutoMergeVertices( &Selected))
			RedrawMap = TRUE;
	       }
	       else if (EditMode == OBJ_LINEDEFS)
	       {
/*		  SelPtr NewSel, cur;
*/
		  ObjectsNeeded( OBJ_LINEDEFS, 0);
		  NewSel = NULL;
		  if (Selected == NULL && CurObject >= 0)
		  {
		     SelectObject( &NewSel, LineDefs[ CurObject].start);
		     SelectObject( &NewSel, LineDefs[ CurObject].end);
		  }
		  else
		  {
		     for (cur = Selected; cur; cur = cur->next)
		     {
			if (!IsSelected( NewSel, LineDefs[ cur->objnum].start))
			   SelectObject( &NewSel, LineDefs[ cur->objnum].start);
			if (!IsSelected( NewSel, LineDefs[ cur->objnum].end))
			   SelectObject( &NewSel, LineDefs[ cur->objnum].end);
		     }
		  }
		  if (AutoMergeVertices( &NewSel))
		     RedrawMap = TRUE;
		  ForgetSelection( &NewSel);
	       }
	    }
	    else
	    {
	       DragObject = TRUE;
	       if (EditMode == OBJ_THINGS && CurObject >= 0)
		  MoveObjectsToCoords( EditMode, NULL, Things[ CurObject].xpos, Things[ CurObject].ypos, 0);
	       else if (EditMode == OBJ_VERTEXES && CurObject >= 0)
		  MoveObjectsToCoords( EditMode, NULL, Vertexes[ CurObject].x, Vertexes[ CurObject].y, 0);
	       else
		  MoveObjectsToCoords( EditMode, NULL, MAPX( PointerX), MAPY( PointerY), GridScale);
	    }
	 }

	 /* user wants to select the next or previous object */
	 else if (keychar == 'N' || keychar == '>')
	 {
	 }
	 else if (keychar == 'P' || keychar == '<')
	 {
	 }
	 else if (keychar == 'J' || keychar == '#')
	 {
	 }

	 /* user wants to mark/unmark an object or a group of objects */
	 else if (keychar == 'M')
	 {
	 }

	 /* user wants to clear all marks and redraw the map */
	 else if (keychar == 'C')
	 {
	 }

	 /* user wants to copy a group of objects */
	 else if (keychar == 'O' && CurObject >= 0)
	 {
	 }

	 /* user wants to edit the current object */
	 else if ((key & 0x00FF) == 0x000D && CurObject >= 0) /* 'Enter' */
	 {
	 }

	 /* user wants to delete the current object */
	 else if ((key & 0xFF00) == 0x5300 && CurObject >= 0) /* 'Del' */
	 {
	 }

	 /* user wants to insert a new object */
	 else if ((key & 0xFF00) == 0x5200) /* 'Ins' */
	 {
	 }

	 /* user likes music */
	 else if (key)
	    Beep();

	 /* redraw the (keyboard) pointer */
	 if (FakeCursor || ShowRulers)
	 {
	    HideMousePointer();
	    DrawPointer( ShowRulers);
	    ShowMousePointer();
	 }
      }

      /* check if Scroll Lock is off */
      if ((bioskey( 2) & 0x10) == 0x00)
      {
	 /* move the map if the pointer is near the edge of the screen */
	 if (PointerY <= (UseMouse ? 2 : 20))
	 {
	 }
	 if (PointerY >= ScrMaxY - (UseMouse ? 8 : 20))
	 {
	 }
	 if (PointerX <= (UseMouse ? 8 : 20))
	 {
	 }
	 if (PointerX >= ScrMaxX - (UseMouse ? 8 : 20))
	 {
	 }
      }
   }

}



/*
   draw the actual game map
*/

void DrawMap( short editmode, short grid, Bool drawgrid, short win_hand) /* SWAP! */
{
   short  n, m;
   char tempstring[100];
   char tempstring2[50];

   /* clear the window */
   vr_recfl(workstation, vdi_rect);

   SetColor(1);

   /* draw the grid */
   if (drawgrid == TRUE && grid > 0)
   {
      short mapx0 = MAPX( 0) & ~(grid - 1);
      short mapx1 = (MAPX( ScrMaxX) + grid) & ~(grid - 1);
      short mapy0 = (MAPY( ScrMaxY) - grid) & ~(grid - 1);
      short mapy1 = MAPY( 0) & ~(grid - 1);

      SetColor( CYAN);

      for (n = mapx0; n <= mapx1; n += grid)
	 DrawMapLine( n, mapy0, n, mapy1);
      for (n = mapy0; n <= mapy1; n += grid)
	 DrawMapLine( mapx0, n, mapx1, n);
   }

   /* draw the linedefs to form the map */
   switch (editmode)
   {
   case OBJ_THINGS:
      ObjectsNeeded( OBJ_LINEDEFS, OBJ_VERTEXES, 0);
      for (n = 0; n < NumLineDefs; n++)
      {
	 if (LineDefs[ n].flags & 1)
	    SetColor( BLACK);
	 else
	    SetColor( 7);
	 DrawMapLine( Vertexes[ LineDefs[ n].start].x, Vertexes[ LineDefs[ n].start].y,
		      Vertexes[ LineDefs[ n].end].x, Vertexes[ LineDefs[ n].end].y);
      }
      break;
   case OBJ_VERTEXES:
      ObjectsNeeded( OBJ_LINEDEFS, OBJ_VERTEXES, 0);
      SetColor(7);
      for (n = 0; n < NumLineDefs; n++)
	 DrawMapVector( Vertexes[ LineDefs[ n].start].x, Vertexes[ LineDefs[ n].start].y,
			Vertexes[ LineDefs[ n].end].x, Vertexes[ LineDefs[ n].end].y);
      break;
   case OBJ_LINEDEFS:
      ObjectsNeeded( OBJ_LINEDEFS, OBJ_VERTEXES, 0);
      for (n = 0; n < NumLineDefs; n++)
      {
	 if (LineDefs[ n].type > 0)
	 {
	    if (LineDefs[ n].tag > 0)
	       SetColor(13);
	    else
	       SetColor(10);
	 }
	 else if (LineDefs[ n].tag > 0)
	    SetColor(12);
	 else if (LineDefs[ n].flags & 1)
	    SetColor( 10);
	 else
	    SetColor( 7);
	 DrawMapLine( Vertexes[ LineDefs[ n].start].x, Vertexes[ LineDefs[ n].start].y,
		      Vertexes[ LineDefs[ n].end].x, Vertexes[ LineDefs[ n].end].y);
      }
      break;
   case OBJ_SECTORS:
      ObjectsNeeded( OBJ_LINEDEFS, OBJ_SIDEDEFS, 0);
      for (n = 0; n < NumLineDefs; n++)
      {
	 if ((m = LineDefs[ n].sidedef1) < 0 || (m = SideDefs[ m].sector) < 0)
	    SetColor(12);
	 else
	 {
	    if (Sectors[ m].tag > 0)
	       SetColor(10);
	    else if (Sectors[ m].special > 0)
	       SetColor( 11);
	    else if (LineDefs[ n].flags & 1)
	       SetColor(12);
	    else
	       SetColor(7);
	    if ((m = LineDefs[ n].sidedef2) >= 0)
	    {
	       if ((m = SideDefs[ m].sector) < 0)
		  SetColor(12);
	       else if (Sectors[ m].tag > 0)
		  SetColor(10);
	       else if (Sectors[ m].special > 0)
		  SetColor(11);
	    }
	 }
	 ObjectsNeeded( OBJ_LINEDEFS, OBJ_VERTEXES, 0);
	 DrawMapLine( Vertexes[ LineDefs[ n].start].x, Vertexes[ LineDefs[ n].start].y,
		      Vertexes[ LineDefs[ n].end].x, Vertexes[ LineDefs[ n].end].y);
      }
      break;
   }

   /* draw in the vertices */
   if (editmode == OBJ_VERTEXES)
   {
      SetColor(10);
      for (n = 0; n < NumVertexes; n++)
      {
	 DrawMapLine( Vertexes[ n].x - OBJSIZE, Vertexes[ n].y - OBJSIZE, Vertexes[ n].x + OBJSIZE, Vertexes[ n].y + OBJSIZE);
	 DrawMapLine( Vertexes[ n].x + OBJSIZE, Vertexes[ n].y - OBJSIZE, Vertexes[ n].x - OBJSIZE, Vertexes[ n].y + OBJSIZE);
      }
   }

   /* draw in the things */
   ObjectsNeeded( OBJ_THINGS, 0);
   if (editmode == OBJ_THINGS)
   {
      for (n = 0; n < NumThings; n++)
      {
	 m = GetThingRadius( Things[ n].type);
	 SetColor( GetThingColour( Things[ n].type));
	 DrawMapLine( Things[ n].xpos - m, Things[ n].ypos, Things[ n].xpos + m, Things[ n].ypos);
	 DrawMapLine( Things[ n].xpos, Things[ n].ypos - m, Things[ n].xpos, Things[ n].ypos + m);
	 DrawMapCircle( Things[ n].xpos, Things[ n].ypos, m);
      }
   }
   else
   {
      SetColor(7);
      for (n = 0; n < NumThings; n++)
      {
	 DrawMapLine( Things[ n].xpos - OBJSIZE, Things[ n].ypos, Things[ n].xpos + OBJSIZE, Things[ n].ypos);
	 DrawMapLine( Things[ n].xpos, Things[ n].ypos - OBJSIZE, Things[ n].xpos, Things[ n].ypos + OBJSIZE);
      }
   }

   /* draw in the title bar */
/*   DrawScreenBox3D( 0, 0, ScrMaxX, 16);
   SetColor(1);
   DrawScreenText( 20,  4, "File  Edit  Search  Modes  Misc  Objects  Check");
   DrawScreenText( 20,  6, "_     _     _       _       _    _        _    ");
   DrawScreenText( ScrMaxX - 45, 4, "Help");
   DrawScreenText( ScrMaxX - 45, 6, "_   ");
*/
   /* draw the bottom line, if needed */
   if (InfoShown)
   {
/*      DrawScreenBox3D( 0, ScrMaxY - 11, ScrMaxX, ScrMaxY);
*/      if (MadeMapChanges == TRUE)
         {
          sprintf(tempstring, "Editing %s on %s #", GetEditModeName( editmode), Level->dir.name);
/*          DrawScreenText( 5, ScrMaxY - 8,tempstring);
*/         }
      else if (MadeChanges == TRUE)
         {
          sprintf(tempstring, "Editing %s on %s *", GetEditModeName( editmode), Level->dir.name);
/*          DrawScreenText( 5, ScrMaxY - 8,tempstring);
*/         }
      else
         {
          sprintf(tempstring, "Editing %s on %s", GetEditModeName( editmode), Level->dir.name);
/*          DrawScreenText( 5, ScrMaxY - 8, tempstring);
*/         }
      if (Scale < 1.0)
         {
          sprintf(tempstring2,"Scale: 1/%d  Grid: %d", (short) (1.0 / Scale + 0.5), grid);
/*          DrawScreenText( ScrMaxX - 176, ScrMaxY - 8, tempstring);
*/         }
      else
         {
          sprintf(tempstring2, "Scale: %d/1  Grid: %d", (short) Scale, grid);
/*          DrawScreenText( ScrMaxX - 176, ScrMaxY - 8, tempstring);
*/         }
    strcat(tempstring,"     ");
    strcat(tempstring,tempstring2);
/*    wind_set(win_hand,WF_INFO,tempstring2);
*/

 wind_title(win_hand,tempstring);
   }
}



/*
   center the map around the given coords
*/

void CenterMapAroundCoords( short xpos, short ypos)
{
   OrigX = xpos;
   OrigY = ypos;
   PointerX = ScrCenterX;
   PointerY = ScrCenterY;
}



/*
   center the map around the object and zoom in if necessary
*/

void GoToObject( short objtype, short objnum) /* SWAP! */
{
   short xpos, ypos;
   short xpos2, ypos2;
   short n;
   short sd1, sd2;
   float oldscale;

   GetObjectCoords( objtype, objnum, &xpos, &ypos);
   CenterMapAroundCoords( xpos, ypos);
   oldscale = Scale;

   /* zoom in until the object can be selected */
   while (Scale < 4.0 && GetCurObject( objtype, MAPX( PointerX - 4), MAPY( PointerY - 4), MAPX( PointerX + 4), MAPY( PointerY + 4)) != objnum)
   {
      if (Scale < 1.0)
	 Scale = 1.0 / ((1.0 / Scale) - 1.0);
      else
	 Scale = Scale * 2.0;
   }

   /* Special case for Sectors: if several Sectors are one inside another, then    */
   /* zooming in on the center won't help.  So I choose a LineDef that borders the */
   /* Sector, move a few pixels towards the inside of the Sector, then zoom in.    */
   if (objtype == OBJ_SECTORS && GetCurObject( OBJ_SECTORS, OrigX, OrigY, OrigX, OrigY) != objnum)
   {
      /* restore the Scale */
      Scale = oldscale;
      for (n = 0; n < NumLineDefs; n++)
      {
	 ObjectsNeeded( OBJ_LINEDEFS, 0);
	 sd1 = LineDefs[ n].sidedef1;
	 sd2 = LineDefs[ n].sidedef2;
	 ObjectsNeeded( OBJ_SIDEDEFS, 0);
	 if (sd1 >= 0 && SideDefs[ sd1].sector == objnum)
	    break;
	 if (sd2 >= 0 && SideDefs[ sd2].sector == objnum)
	    break;
      }
      if (n < NumLineDefs)
      {
	 GetObjectCoords( OBJ_LINEDEFS, n, &xpos2, &ypos2);
	 n = ComputeDist( abs( xpos - xpos2), abs( ypos - ypos2)) / 7;
	 if (n <= 1)
	   n = 2;
	 xpos = xpos2 + (xpos - xpos2) / n;
	 ypos = ypos2 + (ypos - ypos2) / n;
	 CenterMapAroundCoords( xpos, ypos);
	 /* zoom in until the sector can be selected */
	 while (Scale > 4.0 && GetCurObject( OBJ_SECTORS, OrigX, OrigY, OrigX, OrigY) != objnum)
	 {
	    if (Scale < 1.0)
	       Scale = 1.0 / ((1.0 / Scale) - 1.0);
	    else
	       Scale = Scale / 2.0;
	 }
      }
   }
   if (UseMouse)
      SetMouseCoords( PointerX, PointerY);
}



/* end of file */
