/*
   Doom Editor Utility, by Brendon Wyber and Rapha‰l Quinet.

   You are allowed to use any parts of this code in another program, as
   long as you give credits to the authors in the documentation and in
   the program itself.  Read the file README.1ST for more information.

   This program comes with absolutely no warranty.

   EDITOBJ.C - object editing routines.
*/

/* the includes */
#include "deu.h"
#include "levels.h"


/*
   display the information about one object
*/

void DisplayObjectInfo( short objtype, short objnum) /* SWAP! */
{
   char texname[ 9];
   short tag, n;
   short sd1, sd2, s1, s2;
   short x0, y0;

   ObjectsNeeded( objtype, 0);
   switch (objtype)
   {
   case OBJ_THINGS:
      x0 = 0;
      y0 = ScrMaxY - 60;
      if (InfoShown)
	 y0 -= 13;
      DrawScreenBox3D( x0, y0, x0 + 260, y0 + 60);
      if (objnum < 0)
      {
	 DrawScreenText( x0 + 60, y0 + 20, "Use the cursor to");
	 DrawScreenText( x0 + 72, y0 + 30, "select a Thing  ");
	 break;
      }
      SetColor( YELLOW);
      DrawScreenText( x0 + 5, y0 + 5, "Selected Thing (#%d)", objnum);
      SetColor( BLACK);
      DrawScreenText( -1, y0 + 20, "Coordinates:  (%d, %d)", Things[ objnum].xpos, Things[ objnum].ypos);
      DrawScreenText( -1, -1, "Type:         %s", GetThingName( Things[ objnum].type));
      DrawScreenText( -1, -1, "Angle:        %s", GetAngleName( Things[ objnum].angle));
      DrawScreenText( -1, -1, "Appears when: %s", GetWhenName( Things[ objnum].when));
      break;
   case OBJ_LINEDEFS:
      x0 = 0;
      y0 = ScrMaxY - 80;
      if (InfoShown)
	 y0 -= 13;
      DrawScreenBox3D(   x0, y0, x0 + 218, y0 + 80);
      if (objnum >= 0)
      {
	 SetColor( YELLOW);
	 DrawScreenText( x0 + 5, y0 + 5, "Selected LineDef (#%d)", objnum);
	 SetColor( BLACK);
	 DrawScreenText( -1, y0 + 20, "Flags:%3d    %s", LineDefs[ objnum].flags, GetLineDefFlagsName( LineDefs[ objnum].flags));
	 DrawScreenText( -1, -1, "Type: %3d %s", LineDefs[ objnum].type, GetLineDefTypeName( LineDefs[ objnum].type));
	 sd1 = LineDefs[ objnum].sidedef1;
	 sd2 = LineDefs[ objnum].sidedef2;
	 tag = LineDefs[ objnum].tag;
	 s1 = LineDefs[ objnum].start;
	 s2 = LineDefs[ objnum].end;
	 ObjectsNeeded( OBJ_VERTEXES, 0);
	 n = ComputeDist( Vertexes[ s2].x - Vertexes[ s1].x, Vertexes[ s2].y - Vertexes[ s1].y);
	 DrawScreenText( x0 + 160, y0 + 60, "Length:");
	 DrawScreenText( x0 + 170, y0 + 70, "%d", n);
	 ObjectsNeeded( OBJ_SIDEDEFS, OBJ_SECTORS, 0);
	 if (tag > 0)
	 {
	    for (n = 0; n < NumSectors; n++)
	       if (Sectors[ n].tag == tag)
		  break;
	 }
	 else
	    n = NumSectors;
	 if (n < NumSectors)
	    DrawScreenText( x0 + 5, y0 + 40, "Sector tag:  %d (#%d)", tag, n);
	 else
	    DrawScreenText( x0 + 5, y0 + 40, "Sector tag:  %d (none)", tag);
	 DrawScreenText( -1, -1, "Vertexes:    (#%d, #%d)", s1, s2);
	 DrawScreenText( -1, -1, "1st SideDef: #%d", sd1);
	 DrawScreenText( -1, -1, "2nd SideDef: #%d", sd2);
	 if (sd1 >= 0)
	    s1 = SideDefs[ sd1].sector;
	 else
	    s1 = -1;
	 if (sd2 >= 0)
	    s2 = SideDefs[ sd2].sector;
	 else
	    s2 = -1;
      }
      else
      {
	SetColor(8);
	DrawScreenText( x0 + 25, y0 + 35, "(No LineDef selected)");
      }
      x0 = 220;
      y0 = ScrMaxY - 80;
      if (InfoShown)
	 y0 -= 13;
      DrawScreenBox3D( x0, y0, x0 + 218, y0 + 80);
      if (objnum >= 0 && sd1 >= 0)
      {
	 SetColor( YELLOW);
	 DrawScreenText( x0 + 5, y0 + 5, "First SideDef (#%d)", sd1);
	 SetColor( BLACK);
	 texname[ 8] = '\0';
	 strncpy( texname, SideDefs[ sd1].tex3, 8);
	 DrawScreenText( -1, y0 + 20, "Normal texture: %s", texname);
	 strncpy( texname, SideDefs[ sd1].tex1, 8);
	 if (s1 >= 0 && s2 >= 0 && Sectors[ s1].ceilh > Sectors[ s2].ceilh)
	 {
	    if (texname[ 0] == '-' && texname[ 1] == '\0')
	       SetColor( RED);
	 }
	 else
	    SetColor(8);
	 DrawScreenText( -1, -1, "Upper texture:  %s", texname);
	 SetColor( BLACK);
	 strncpy( texname, SideDefs[ sd1].tex2, 8);
	 if (s1 >= 0 && s2 >= 0 && Sectors[ s1].floorh < Sectors[ s2].floorh)
	 {
	    if (texname[ 0] == '-' && texname[ 1] == '\0')
	       SetColor( RED);
	 }
	 else
	    SetColor( 8);
	 DrawScreenText( -1, -1, "Lower texture:  %s", texname);
	 SetColor( BLACK);
	 DrawScreenText( -1, -1, "Tex. X offset:  %d", SideDefs[ sd1].xoff);
	 DrawScreenText( -1, -1, "Tex. Y offset:  %d", SideDefs[ sd1].yoff);
	 DrawScreenText( -1, -1, "Sector:         #%d", s1);
      }
      else
      {
	SetColor( 8);
	DrawScreenText( x0 + 25, y0 + 35, "(No first SideDef)");
      }
      x0 = 440;
      y0 = ScrMaxY - 80;
      if (InfoShown)
	 y0 -= 13;
      DrawScreenBox3D( x0, y0, x0 + 200, y0 + 80);
      if (objnum >= 0 && sd2 >= 0)
      {
	 SetColor( YELLOW);
	 DrawScreenText( x0 + 5, y0 + 5, "Second SideDef (#%d)", sd2);
	 SetColor( BLACK);
	 texname[ 8] = '\0';
	 strncpy( texname, SideDefs[ sd2].tex3, 8);
	 DrawScreenText( -1, y0 + 20, "Normal texture: %s", texname);
	 strncpy( texname, SideDefs[ sd2].tex1, 8);
	 if (s1 >= 0 && s2 >= 0 && Sectors[ s2].ceilh > Sectors[ s1].ceilh)
	 {
	    if (texname[ 0] == '-' && texname[ 1] == '\0')
	       SetColor( RED);
	 }
	 else
	    SetColor( 8);
	 DrawScreenText( -1, -1, "Upper texture:  %s", texname);
	 SetColor( BLACK);
	 strncpy( texname, SideDefs[ sd2].tex2, 8);
	 if (s1 >= 0 && s2 >= 0 && Sectors[ s2].floorh < Sectors[ s1].floorh)
	 {
	    if (texname[ 0] == '-' && texname[ 1] == '\0')
	       SetColor( RED);
	 }
	 else
	    SetColor( 8);
	 DrawScreenText( -1, -1, "Lower texture:  %s", texname);
	 SetColor( BLACK);
	 DrawScreenText( -1, -1, "Tex. X offset:  %d", SideDefs[ sd2].xoff);
	 DrawScreenText( -1, -1, "Tex. Y offset:  %d", SideDefs[ sd2].yoff);
	 DrawScreenText( -1, -1, "Sector:         #%d", s2);
      }
      else
      {
	SetColor( 8);
	DrawScreenText( x0 + 25, y0 + 35, "(No second SideDef)");
      }
      break;
   case OBJ_VERTEXES:
      x0 = 0;
      y0 = ScrMaxY - 30;
      if (InfoShown)
	 y0 -= 13;
      DrawScreenBox3D( x0, y0, x0 + 220, y0 + 30);
      if (objnum < 0)
      {
	 SetColor( 8);
	 DrawScreenText( x0 + 30, y0 + 12, "(No Vertex selected)");
	 break;
      }
      SetColor( YELLOW);
      DrawScreenText( x0 + 5, y0 + 5, "Selected Vertex (#%d)", objnum);
      SetColor( BLACK);
      DrawScreenText( -1, y0 + 20, "Coordinates: (%d, %d)", Vertexes[ objnum].x, Vertexes[ objnum].y);
      break;
   case OBJ_SECTORS:
      x0 = 0;
      y0 = ScrMaxY - 90;
      if (InfoShown)
	 y0 -= 13;
      DrawScreenBox3D( x0, y0, x0 + 255, y0 + 90);
      if (objnum < 0)
      {
	SetColor( 8);
	DrawScreenText( x0 + 48, y0 + 35, "(No Sector selected)");
	break;
      }
      SetColor( YELLOW);
      DrawScreenText( x0 + 5, y0 + 5, "Selected Sector (#%d)", objnum);
      SetColor( BLACK);
      DrawScreenText( -1, y0 + 20, "Floor height:    %d", Sectors[ objnum].floorh);
      DrawScreenText( -1, -1, "Ceiling height:  %d", Sectors[ objnum].ceilh);
      texname[ 8] = '\0';
      strncpy( texname, Sectors[ objnum].floort, 8);
      DrawScreenText( -1, -1, "Floor texture:   %s", texname);
      strncpy( texname, Sectors[ objnum].ceilt, 8);
      DrawScreenText( -1, -1, "Ceiling texture: %s", texname);
      DrawScreenText( -1, -1, "Light level:     %d", Sectors[ objnum].light);
      DrawScreenText( -1, -1, "Type: %3d        %s", Sectors[ objnum].special, GetSectorTypeName( Sectors[ objnum].special));
      tag = Sectors[ objnum].tag;
      ObjectsNeeded( OBJ_LINEDEFS, 0);
      if (tag == 0)
	 n = NumLineDefs;
      else
	 for (n = 0; n < NumLineDefs; n++)
	    if (LineDefs[ n].tag == tag)
	       break;
      if (n < NumLineDefs)
	 DrawScreenText( -1, -1, "LineDef tag:     %d (#%d)", tag, n);
      else if (tag == 99 || tag == 999)
	 DrawScreenText( -1, -1, "LineDef tag:     %d (stairs?)", tag);
      else if (tag == 666)
	 DrawScreenText( -1, -1, "LineDef tag:     %d (lower@end)", tag);
      else
	 DrawScreenText( -1, -1, "LineDef tag:     %d (none)", tag);
      break;
   }
}



/*
   display and execute a "things" menu
*/

short DisplayThingsMenu( short x0, short y0, char *menutitle, ...)
{
   va_list args;
   short   val, num;
   short   thingid[ 30];
   char   *menustr[ 30];
   short  dummy[ 30];

   /* put the va_args in the menustr table */
   num = 0;
   va_start( args, menutitle);
   while ((num < 30) && ((thingid[ num] = va_arg( args, int)) >= 0))
   {
      menustr[ num] = GetThingName( thingid[ num]);
      num++;
   }
   va_end( args);

   /* display the menu */
   val = DisplayMenuArray( x0, y0, menutitle, num, NULL, menustr, dummy) - 1;

   /* return the thing id, if valid */
   if (val < 0 || val >= num)
     return -1;
   return thingid[ val];
}



/*
   display and execute a "linedef type" menu
*/

short DisplayLineDefTypeMenu( short x0, short y0, char *menutitle, ...)
{
   va_list args;
   short   val, num, n;
   short   typeid[ 30];
   char   *menustr[ 30];
   short   dummy[ 30];

   /* put the va_args in the menustr table */
   num = 0;
   val = 0;
   va_start( args, menutitle);
   while ((num < 30) && ((typeid[ num] = va_arg( args, int)) >= 0))
   {
      menustr[ num] = GetMemory( 80 * sizeof( char));
      sprintf( menustr[ num], "%-79s", GetLineDefTypeLongName( typeid[ num]));
      if (strlen( GetLineDefTypeLongName( typeid[ num])) > val)
         val = strlen( GetLineDefTypeLongName( typeid[ num]));
      num++;
   }
   va_end( args);

   /* put the type numbers at the end of the lines */
   for (n = 0; n < num; n++)
      sprintf( menustr[ n] + val + 1, "[%3d]", typeid[ n]);

   /* display the menu */
   val = DisplayMenuArray( x0, y0, menutitle, num, NULL, menustr, dummy) - 1;
   for (n = 0; n < num; n++)
      FreeMemory( menustr[ n]);

   /* return the thing id, if valid */
   if (val < 0 || val >= num)
     return -1;
   return typeid[ val];
}



/*
   ask for an object number and check for maximum valid number
   (this is just like InputIntegerValue, but with a different prompt)
*/

short InputObjectNumber( short x0, short y0, short objtype, short curobj)
{
   short val, key;
   char prompt[ 80];

   if (UseMouse)
      HideMousePointer();
   sprintf( prompt, "Enter a %s number between 0 and %d:", GetObjectTypeName( objtype), GetMaxObjectNum( objtype));
   if (x0 < 0)
      x0 = (ScrMaxX - 25 - 8 * strlen( prompt)) / 2;
   if (y0 < 0)
      y0 = (ScrMaxY - 55) / 2;
   DrawScreenBox3D( x0, y0, x0 + 25 + 8 * strlen( prompt), y0 + 55);
   SetColor( WHITE);
   DrawScreenText( x0 + 10, y0 + 8, prompt);
   val = curobj;
   while (((key = InputInteger( x0 + 10, y0 + 28, &val, 0, GetMaxObjectNum( objtype))) & 0x00FF) != 0x000D && (key & 0x00FF) != 0x001B)
      Beep();
   if (UseMouse)
      ShowMousePointer();
   return val;
}



/*
   ask for an object number and display a warning message
*/

short InputObjectXRef( short x0, short y0, short objtype, Bool allownone, short curobj)
{
   short val, key;
   char prompt[ 80];

   if (UseMouse)
      HideMousePointer();
   sprintf( prompt, "Enter a %s number between 0 and %d%c", GetObjectTypeName( objtype), GetMaxObjectNum( objtype), allownone ? ',' : ':');
   val = strlen( prompt);
   if (val < 40)
      val = 40;
   if (x0 < 0)
      x0 = (ScrMaxX - 25 - 8 * val) / 2;
   if (y0 < 0)
      y0 = (ScrMaxY - (allownone ? 85 : 75)) / 2;
   DrawScreenBox3D( x0, y0, x0 + 25 + 8 * val, y0 + (allownone ? 85 : 75));
   SetColor( WHITE);
   DrawScreenText( x0 + 10, y0 + 8, prompt);
   if (allownone)
      DrawScreenText( x0 + 10, y0 + 18, "or -1 for none:");
   SetColor( RED);
   DrawScreenText( x0 + 10, y0 + (allownone ? 60 : 50), "Warning: modifying the cross-references");
   DrawScreenText( x0 + 10, y0 + (allownone ? 70 : 60), "between some objects may crash the game.");
   val = curobj;
   while (((key = InputInteger( x0 + 10, y0 + (allownone ? 38 : 28), &val, allownone ? -1 : 0, GetMaxObjectNum( objtype))) & 0x00FF) != 0x000D && (key & 0x00FF) != 0x001B)
      Beep();
   if (UseMouse)
      ShowMousePointer();
   return val;
}



/*
   ask for two vertex numbers and check for maximum valid number
*/

Bool Input2VertexNumbers( short x0, short y0, char *prompt1, short *v1, short *v2)
{
   short key;
   short maxlen, first;
   Bool ok;
   char prompt2[ 80];

   if (UseMouse)
      HideMousePointer();
   sprintf( prompt2, "Enter two numbers between 0 and %d:", NumVertexes - 1);
   if (strlen( prompt1) > strlen( prompt2))
      maxlen = strlen( prompt1);
   else
      maxlen = strlen( prompt2);
   if (x0 < 0)
      x0 = (ScrMaxX - 25 - 8 * maxlen) / 2;
   if (y0 < 0)
      y0 = (ScrMaxY - 75) / 2;
   DrawScreenBox3D( x0, y0, x0 + 25 + 8 * maxlen, y0 + 75);
   DrawScreenText( x0 + 10, y0 + 36, "From this Vertex");
   DrawScreenText( x0 + 180, y0 + 36, "To this Vertex");
   SetColor( WHITE);
   DrawScreenText( x0 + 10, y0 + 8, prompt1);
   DrawScreenText( x0 + 10, y0 + 18, prompt2);
   first = TRUE;
   key = 0;
   for (;;)
   {
      ok = TRUE;
      DrawScreenBox3D( x0 + 10, y0 + 48, x0 + 71, y0 + 61);
      if (*v1 < 0 || *v1 >= NumVertexes)
      {
	 SetColor( 8);
	 ok = FALSE;
      }
      DrawScreenText( x0 + 14, y0 + 51, "%d", *v1);
      DrawScreenBox3D( x0 + 180, y0 + 48, x0 + 241, y0 + 61);
      if (*v2 < 0 || *v2 >= NumVertexes)
      {
	 SetColor( 8);
	 ok = FALSE;
      }
      DrawScreenText( x0 + 184, y0 + 51, "%d", *v2);
      if (first)
	 key = InputInteger( x0 + 10, y0 + 48, v1, 0, NumVertexes - 1);
      else
	 key = InputInteger( x0 + 180, y0 + 48, v2, 0, NumVertexes - 1);
      if ((key & 0xFF00) == 0x4B00 || (key & 0xFF00) == 0x4D00 || (key & 0x00FF) == 0x0009 || (key & 0xFF00) == 0x0F00)
	 first = !first;
      else if ((key & 0x00FF) == 0x001B)
	 break;
      else if ((key & 0x00FF) == 0x000D)
      {
	 if (first)
	    first = FALSE;
	 else if (ok)
	    break;
	 else
	    Beep();
      }
      else
	 Beep();
   }
   if (UseMouse)
      ShowMousePointer();
   return ((key & 0x00FF) == 0x000D);
}



/*
*/

char *GetTaggedLineDefFlag( short linedefnum, short flagndx)
{
   static char ldstr[ 9][ 50];

   if ((LineDefs[ linedefnum].flags & (0x01 << (flagndx - 1))) != 0)
      strcpy( ldstr[ flagndx - 1], "\04 ");
   else
      strcpy( ldstr[ flagndx - 1], "  ");
   strcat( ldstr[ flagndx - 1], GetLineDefFlagsLongName( 0x01 << (flagndx - 1)));
   return ldstr[ flagndx - 1];
}



/*
   edit an object or a group of objects
*/

void EditObjectsInfo( short x0, short y0, short objtype, SelPtr obj) /* SWAP! */
{
   char  *menustr[ 30];
   short  dummy[ 30];
   char   texname[ 9];
   short  n, val;
   SelPtr cur, sdlist;
   OBJECT *form;
   short xdial, ydial, wdial, hdial, seld;

   ObjectsNeeded( objtype, 0);
   if (obj == NULL)
      return;
   switch (objtype)
   {
   case OBJ_THINGS:
      for (n = 0; n < 6; n++)
	 menustr[ n] = GetMemory( 60);
      sprintf( menustr[ 5], "Edit Thing #%d", obj->objnum);
      sprintf( menustr[ 0], "Change Type          (Current: %s)", GetThingName( Things[ obj->objnum].type));
      sprintf( menustr[ 1], "Change Angle         (Current: %s)", GetAngleName( Things[ obj->objnum].angle));
      sprintf( menustr[ 2], "Change When Appears  (Current: %s)", GetWhenName( Things[ obj->objnum].when));
      sprintf( menustr[ 3], "Change X position    (Current: %d)", Things[ obj->objnum].xpos);
      sprintf( menustr[ 4], "Change Y position    (Current: %d)", Things[ obj->objnum].ypos);
      val = DisplayMenuArray( x0, y0, menustr[ 5], 5, NULL, menustr, dummy);
      for (n = 0; n < 6; n++)
	 FreeMemory( menustr[ n]);
      switch (val)
      {
      case 1:
	 switch (DisplayMenu( x0 + 42, y0 + 34, "Select Class",
			      "Player",
			      "Enemy",
			      "Weapon",
			      "Bonus",
			      "Decoration",
			      "Decoration (light sources)",
			      "Decoration (dead bodies)",
			      "Decoration (hanging bodies)",
			      "Teleport landing",
			      "(Enter a decimal value)",
			      NULL))
	 {
	 case 1:
	    val = DisplayThingsMenu( x0 + 84, y0 + 68, "Select Start Position Type",
				     THING_PLAYER1,
				     THING_PLAYER2,
				     THING_PLAYER3,
				     THING_PLAYER4,
				     THING_DEATHMATCH,
				     -1);
	    break;

	 case 2:
	    val = DisplayThingsMenu( x0 + 84, y0 + 78, "Select Enemy",
				     THING_TROOPER,
				     THING_SARGEANT,
				     THING_IMP,
				     THING_DEMON,
				     THING_SPECTOR,
				     THING_BARON,
				     THING_LOSTSOUL,
				     THING_CACODEMON,
				     THING_CYBERDEMON,
				     THING_SPIDERBOSS,
				     -1);
	    break;

	 case 3:
	    val = DisplayThingsMenu( x0 + 84, y0 + 88, "Select Weapon",
				     THING_SHOTGUN,
				     THING_CHAINGUN,
				     THING_LAUNCHER,
				     THING_PLASMAGUN,
				     THING_CHAINSAW,
				     THING_SHELLS,
				     THING_AMMOCLIP,
				     THING_ROCKET,
				     THING_ENERGYCELL,
				     THING_BFG9000,
				     THING_SHELLBOX,
				     THING_AMMOBOX,
				     THING_ROCKETBOX,
				     THING_ENERGYPACK,
				     THING_BACKPACK,
				     -1);
	    break;

	 case 4:
	    val = DisplayThingsMenu( x0 + 84, y0 + 98, "Select Bonus",
				     THING_REDCARD,
				     THING_YELLOWCARD,
				     THING_BLUECARD,
				     THING_REDSKULLKEY,
				     THING_YELLOWSKULLKEY,
				     THING_BLUESKULLKEY,
				     THING_ARMBONUS1,
				     THING_GREENARMOR,
				     THING_BLUEARMOR,
				     THING_HLTBONUS1,
				     THING_STIMPACK,
				     THING_MEDKIT,
				     THING_SOULSPHERE,
				     THING_BLURSPHERE,
				     THING_MAP,
				     THING_RADSUIT,
				     THING_LITEAMP,
				     THING_BESERK,
				     THING_INVULN,
				     -1);
	    break;

	 case 5:
	    val = DisplayThingsMenu( x0 + 84, y0 + 108, "Select Decoration",
				     THING_BARREL,
				     THING_TECHCOLUMN,
				     THING_TGREENPILLAR,
				     THING_TREDPILLAR,
				     THING_SGREENPILLAR,
				     THING_SREDPILLAR,
				     THING_PILLARHEART,
				     THING_PILLARSKULL,
				     THING_EYEINSYMBOL,
				     THING_BROWNSTUB,
				     THING_GREYTREE,
				     THING_BROWNTREE,
				     -1);
	    break;

	 case 6:
	    val = DisplayThingsMenu( x0 + 84, y0 + 118, "Select Decoration",
				     THING_CANDLE,
				     THING_LAMP,
				     THING_CANDELABRA,
				     THING_TBLUETORCH,
				     THING_TGREENTORCH,
				     THING_TREDTORCH,
				     THING_SBLUETORCH,
				     THING_SGREENTORCH,
				     THING_SREDTORCH,
				     -1);
	    break;

	 case 7:
	    val = DisplayThingsMenu( x0 + 84, y0 + 128, "Select Decoration",
				     THING_DEADPLAYER,
				     THING_DEADTROOPER,
				     THING_DEADSARGEANT,
				     THING_DEADIMP,
				     THING_DEADDEMON,
				     THING_DEADCACODEMON,
				     THING_BONES,
				     THING_BONES2,
				     THING_POOLOFBLOOD,
				     THING_SKULLTOPPOLE,
				     THING_HEADSKEWER,
				     THING_PILEOFSKULLS,
				     THING_IMPALEDBODY,
				     THING_IMPALEDBODY2,
				     THING_SKULLSINFLAMES,
				     -1);
	    break;

	 case 8:
	    val = DisplayThingsMenu( x0 + 84, y0 + 138, "Select Decoration",
				     THING_HANGINGSWAYING,
				     THING_HANGINGARMSOUT,
				     THING_HANGINGONELEG,
				     THING_HANGINGTORSO,
				     THING_HANGINGLEG,
				     THING_HANGINGSWAYING2,
				     THING_HANGINGARMSOUT2,
				     THING_HANGINGONELEG2,
				     THING_HANGINGTORSO2,
				     THING_HANGINGLEG2,
				     -1);
	    break;

	 case 9:
	    val = THING_TELEPORT;
	    break;

	 case 10:
	    val = InputIntegerValue( x0 + 84, y0 + 158, 0, 9999, Things[ obj->objnum].type);
	    break;

	 default:
	    Beep();
	    return;
	 }
	 if (val >= 0)
	 {
	    for (cur = obj; cur; cur = cur->next)
	       Things[ cur->objnum].type = val;
	    MadeChanges = TRUE;
	 }
	 break;

      case 2:
	 switch (DisplayMenu( x0 + 42, y0 + 44, "Select Angle",
			      "North",
			      "NorthEast",
			      "East",
			      "SouthEast",
			      "South",
			      "SouthWest",
			      "West",
			      "NorthWest",
			      NULL))
	 {
	 case 1:
	    for (cur = obj; cur; cur = cur->next)
	       Things[ cur->objnum].angle = 90;
	    MadeChanges = TRUE;
	    break;
	 case 2:
	    for (cur = obj; cur; cur = cur->next)
	       Things[ cur->objnum].angle = 45;
	    MadeChanges = TRUE;
	    break;
	 case 3:
	    for (cur = obj; cur; cur = cur->next)
	       Things[ cur->objnum].angle = 0;
	    MadeChanges = TRUE;
	    break;
	 case 4:
	    for (cur = obj; cur; cur = cur->next)
	       Things[ cur->objnum].angle = 315;
	    MadeChanges = TRUE;
	    break;
	 case 5:
	    for (cur = obj; cur; cur = cur->next)
	       Things[ cur->objnum].angle = 270;
	    MadeChanges = TRUE;
	    break;
	 case 6:
	    for (cur = obj; cur; cur = cur->next)
	       Things[ cur->objnum].angle = 225;
	    MadeChanges = TRUE;
	    break;
	 case 7:
	    for (cur = obj; cur; cur = cur->next)
	       Things[ cur->objnum].angle = 180;
	    MadeChanges = TRUE;
	    break;
	 case 8:
	    for (cur = obj; cur; cur = cur->next)
	       Things[ cur->objnum].angle = 135;
	    MadeChanges = TRUE;
	    break;
	 }
	 break;

      case 3:
	 val = DisplayMenu( x0 + 42, y0 + 54, "Choose the difficulty level(s)",
			    "D12          (Easy only)",
			    "D3           (Medium only)",
			    "D12, D3      (Easy and Medium)",
			    "D45          (Hard only)",
			    "D12, D45     (Easy and Hard)",
			    "D3, D45      (Medium and Hard)",
			    "D12, D3, D45 (Easy, Medium, Hard)",
			    "Toggle \"Deaf/Ambush\" bit",
			    "Toggle \"Multi-player only\" bit",
			    "(Enter a decimal value)",
			    NULL);
	 switch (val)
	 {
	 case 1:
	 case 2:
	 case 3:
	 case 4:
	 case 5:
	 case 6:
	 case 7:
	    for (cur = obj; cur; cur = cur->next)
	       Things[ cur->objnum].when = (Things[ cur->objnum].when & 0x18) | val;
	    MadeChanges = TRUE;
	    break;
	 case 8:
	    for (cur = obj; cur; cur = cur->next)
	       Things[ cur->objnum].when ^= 0x08;
	    MadeChanges = TRUE;
	    break;
	 case 9:
	    for (cur = obj; cur; cur = cur->next)
	       Things[ cur->objnum].when ^= 0x10;
	    MadeChanges = TRUE;
	    break;
	 case 10:
	    val = InputIntegerValue( x0 + 84, y0 + 158, 1, 31, Things[ obj->objnum].when);
	    if (val > 0)
	    {
	       for (cur = obj; cur; cur = cur->next)
		  Things[ cur->objnum].when = val;
	       MadeChanges = TRUE;
	    }
	    break;
	 }
	 break;

      case 4:
	 val = InputIntegerValue( x0 + 42, y0 + 64, MapMinX, MapMaxX, Things[ obj->objnum].xpos);
	 if (val >= MapMinX)
	 {
	    n = val - Things[ obj->objnum].xpos;
	    for (cur = obj; cur; cur = cur->next)
	       Things[ cur->objnum].xpos += n;
	    MadeChanges = TRUE;
	 }
	 break;

      case 5:
	 val = InputIntegerValue( x0 + 42, y0 + 74, MapMinY, MapMaxY, Things[ obj->objnum].ypos);
	 if (val >= MapMinY)
	 {
	    n = val - Things[ obj->objnum].ypos;
	    for (cur = obj; cur; cur = cur->next)
	       Things[ cur->objnum].ypos += n;
	    MadeChanges = TRUE;
	 }
	 break;
      }
      break;

   case OBJ_VERTEXES:
        rsrc_gaddr(0,EDITVERTEX,&form);
        form_center ( form, &xdial, &ydial, &wdial, &hdial );
        form_dial ( 0, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
        objc_draw (form, 0, 2, xdial, ydial, wdial, hdial );
        seld=form_do ( form, 0 ); 
        form_dial ( 3, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
        objc_change (form,seld,-1,-1,-1,-1,-1,NORMAL,1);
                           
        val=atoi(objc_text(form,VERTEXXCO));
	    n = val - Vertexes[ obj->objnum].x;
	    for (cur = obj; cur; cur = cur->next)
	       Vertexes[ cur->objnum].x += n;
	    MadeChanges = TRUE;
	    MadeMapChanges = TRUE;

        val=atoi(objc_text(form,VERTEXYCO));
	    n = val - Vertexes[ obj->objnum].y;
	    for (cur = obj; cur; cur = cur->next)
	       Vertexes[ cur->objnum].y += n;
	    MadeChanges = TRUE;
	    MadeMapChanges = TRUE;
      break;

   case OBJ_LINEDEFS:
      switch (DisplayMenu( x0, y0, "Choose the object to edit:",
			   "Edit the LineDef",
			   (LineDefs[ obj->objnum].sidedef1 >= 0) ? "Edit the 1st SideDef" : "Add a 1st SideDef",
			   (LineDefs[ obj->objnum].sidedef2 >= 0) ? "Edit the 2nd SideDef" : "Add a 2nd SideDef",
			   NULL))
      {
      case 1:
	 for (n = 0; n < 8; n++)
	    menustr[ n] = GetMemory( 60);
	 sprintf( menustr[ 7], "Edit LineDef #%d", obj->objnum);
	 sprintf( menustr[ 0], "Change Flags            (Current: %d)", LineDefs[ obj->objnum].flags);
	 sprintf( menustr[ 1], "Change Type             (Current: %d)", LineDefs[ obj->objnum].type);
	 sprintf( menustr[ 2], "Change Sector tag       (Current: %d)", LineDefs[ obj->objnum].tag);
	 sprintf( menustr[ 3], "Change Starting Vertex  (Current: #%d)", LineDefs[ obj->objnum].start);
	 sprintf( menustr[ 4], "Change Ending Vertex    (Current: #%d)", LineDefs[ obj->objnum].end);
	 sprintf( menustr[ 5], "Change 1st SideDef ref. (Current: #%d)", LineDefs[ obj->objnum].sidedef1);
	 sprintf( menustr[ 6], "Change 2nd SideDef ref. (Current: #%d)", LineDefs[ obj->objnum].sidedef2);
	 val = DisplayMenuArray( x0 + 42, y0 + 34, menustr[ 7], 7, NULL, menustr, dummy);
	 for (n = 0; n < 8; n++)
	    FreeMemory( menustr[ n]);
	 switch (val)
	 {
	 case 1:
	    val = DisplayMenu( x0 + 84, y0 + 68, "Toggle the flags:",
			       GetTaggedLineDefFlag( obj->objnum, 1),
			       GetTaggedLineDefFlag( obj->objnum, 2),
			       GetTaggedLineDefFlag( obj->objnum, 3),
			       GetTaggedLineDefFlag( obj->objnum, 4),
			       GetTaggedLineDefFlag( obj->objnum, 5),
			       GetTaggedLineDefFlag( obj->objnum, 6),
			       GetTaggedLineDefFlag( obj->objnum, 7),
			       GetTaggedLineDefFlag( obj->objnum, 8),
			       GetTaggedLineDefFlag( obj->objnum, 9),
			       "(Enter a decimal value)",
			       NULL);
	    if (val >= 1 && val <= 9)
	    {
	       for (cur = obj; cur; cur = cur->next)
		  LineDefs[ cur->objnum].flags ^= 0x01 << (val - 1);
	       MadeChanges = TRUE;
	    }
	    else if (val == 10)
	    {
	       val = InputIntegerValue( x0 + 126, y0 + 182, 0, 511, LineDefs[ obj->objnum].flags);
	       if (val >= 0)
	       {
		  for (cur = obj; cur; cur = cur->next)
		     LineDefs[ cur->objnum].flags = val;
		  MadeChanges = TRUE;
	       }
	    }
	    break;
	 case 2:
	    switch (DisplayMenu( x0 + 84, y0 + 78, "Choose a LineDef type:",
				 "Normal",
				 "Doors...",
				 "Ceilings...",
				 "Floors (raise)...",
				 "Floors (lower)...",
				 "Lifts & Moving things...",
				 "Special...",
				 "(Enter a decimal value)",
				 NULL))
	    {
	    case 1:
	       val = 0;
	       break;
	    case 2:
	       val = DisplayLineDefTypeMenu( x0 + 126, y0 + 122, NULL, /* Doors */
					     1, 26, 27, 28, 63, 29, 90, 4, 31, 32, 34, 33, 61, 103, 50, 86, 2, 46, 42, 75, 3, 76, 16,
					     -1);
	       break;
	    case 3:
	       val = DisplayLineDefTypeMenu( x0 + 126, y0 + 132, NULL, /* Ceilings */
					     43, 41, 72, 44, 40,
					     -1);
	       break;
	    case 4:
	       val = DisplayLineDefTypeMenu( x0 + 126, y0 + 142, NULL, /* Floors (raise) */
					     69, 18, 20, 22, 95, 47, 5, 14, 30, 93, 59, 66, 67, 15, 92, 58, 96, 64, 101, 91, 24, 65, 94, 56,
					     -1);
	       break;
	    case 5:
	       val = DisplayLineDefTypeMenu( x0 + 126, y0 + 142, NULL, /* Floors (lower) */
					     45, 60, 102, 82, 83, 19, 38, 70, 71, 98, 36, 23, 84, 68, 37, 9, 21,
					     -1);
	       break;
	    case 6:
	       val = DisplayLineDefTypeMenu( x0 + 126, y0 + 152, NULL, /* Lifts & Moving things */
					     62, 88, 10, 77, 6, 73, 74, 57, 87, 53, 89, 54, 7, 8,
					     -1);
	       break;
	    case 7:
	       val = DisplayLineDefTypeMenu( x0 + 126, y0 + 162, NULL, /* Special */
					     48, 11, 52, 51, 97, 39, 81, 13, 79, 35, 80, 12, 104, 17,
					     -1);
	       break;
	    case 8:
	       val = InputIntegerValue( x0 + 126, y0 + 172, 0, 255, LineDefs[ obj->objnum].type);
	       break;
	    default:
	       val = -1;
	    }
	    if (val >= 0)
	    {
	       for (cur = obj; cur; cur = cur->next)
		  LineDefs[ cur->objnum].type = val;
	       MadeChanges = TRUE;
	    }
	    break;
	 case 3:
	    val = InputIntegerValue( x0 + 84, y0 + 88, 0, 255, LineDefs[ obj->objnum].tag);
	    if (val >= 0)
	    {
	       for (cur = obj; cur; cur = cur->next)
		  LineDefs[ cur->objnum].tag = val;
	       MadeChanges = TRUE;
	    }
	    break;
	 case 4:
	    val = InputObjectXRef( x0 + 84, y0 + 98, OBJ_VERTEXES, FALSE, LineDefs[ obj->objnum].start);
	    if (val >= 0)
	    {
	       for (cur = obj; cur; cur = cur->next)
		  LineDefs[ cur->objnum].start = val;
	       MadeChanges = TRUE;
	       MadeMapChanges = TRUE;
	    }
	    break;
	 case 5:
	    val = InputObjectXRef( x0 + 84, y0 + 108, OBJ_VERTEXES, FALSE, LineDefs[ obj->objnum].end);
	    if (val >= 0)
	    {
	       for (cur = obj; cur; cur = cur->next)
		  LineDefs[ cur->objnum].end = val;
	       MadeChanges = TRUE;
	       MadeMapChanges = TRUE;
	    }
	    break;
	 case 6:
	    val = InputObjectXRef( x0 + 84, y0 + 118, OBJ_SIDEDEFS, TRUE, LineDefs[ obj->objnum].sidedef1);
	    if (val >= -1)
	    {
	       for (cur = obj; cur; cur = cur->next)
		  LineDefs[ cur->objnum].sidedef1 = val;
	       MadeChanges = TRUE;
	       MadeMapChanges = TRUE;
	    }
	    break;
	 case 7:
	    val = InputObjectXRef( x0 + 84, y0 + 128, OBJ_SIDEDEFS, TRUE, LineDefs[ obj->objnum].sidedef2);
	    if (val >= -1)
	    {
	       for (cur = obj; cur; cur = cur->next)
		  LineDefs[ cur->objnum].sidedef2 = val;
	       MadeChanges = TRUE;
	       MadeMapChanges = TRUE;
	    }
	    break;
	 }
	 break;

      /* edit or add the first SideDef */
      case 2:
	 ObjectsNeeded( OBJ_LINEDEFS, OBJ_SIDEDEFS, 0);
	 if (LineDefs[ obj->objnum].sidedef1 >= 0)
	 {
	    /* build a new selection list with the first SideDefs */
	    objtype = OBJ_SIDEDEFS;
	    sdlist = NULL;
	    for (cur = obj; cur; cur = cur->next)
	       if (LineDefs[ cur->objnum].sidedef1 >= 0)
		  SelectObject( &sdlist, LineDefs[ cur->objnum].sidedef1);
	 }
	 else
	 {
	    /* add a new first SideDef */
	    for (cur = obj; cur; cur = cur->next)
	       if (LineDefs[ cur->objnum].sidedef1 == -1)
	       {
		  InsertObject( OBJ_SIDEDEFS, -1, 0, 0);
		  LineDefs[ cur->objnum].sidedef1 = NumSideDefs - 1;
	       }
	    break;
	 }
	 /* no break here */

      /* edit or add the second SideDef */
      case 3:
	 if (objtype != OBJ_SIDEDEFS)
	 {
	    if (LineDefs[ obj->objnum].sidedef2 >= 0)
	    {
	       /* build a new selection list with the second (or first) SideDefs */
	       objtype = OBJ_SIDEDEFS;
	       sdlist = NULL;
	       for (cur = obj; cur; cur = cur->next)
		  if (LineDefs[ cur->objnum].sidedef2 >= 0)
		     SelectObject( &sdlist, LineDefs[ cur->objnum].sidedef2);
		  else if (LineDefs[ cur->objnum].sidedef1 >= 0)
		     SelectObject( &sdlist, LineDefs[ cur->objnum].sidedef1);
	    }
	    else
	    {
	       /* add a new second (or first) SideDef */
	       for (cur = obj; cur; cur = cur->next)
		  if (LineDefs[ cur->objnum].sidedef1 == -1)
		  {
		     InsertObject( OBJ_SIDEDEFS, -1, 0, 0);
		     ObjectsNeeded( OBJ_LINEDEFS, 0);
		     LineDefs[ cur->objnum].sidedef1 = NumSideDefs - 1;
		  }
		  else if (LineDefs[ cur->objnum].sidedef2 == -1)
		  {
		     n = LineDefs[ cur->objnum].sidedef1;
		     InsertObject( OBJ_SIDEDEFS, -1, 0, 0);
		     strncpy( SideDefs[ NumSideDefs - 1].tex3, "-", 8);
		     strncpy( SideDefs[ n].tex3, "-", 8);
		     ObjectsNeeded( OBJ_LINEDEFS, 0);
		     LineDefs[ cur->objnum].sidedef2 = NumSideDefs - 1;
		     LineDefs[ cur->objnum].flags = 4;
		  }
	       break;
	    }
	 }
	 ObjectsNeeded( OBJ_SIDEDEFS, 0);
	 for (n = 0; n < 7; n++)
	    menustr[ n] = GetMemory( 60);
	 sprintf( menustr[ 6], "Edit SideDef #%d", sdlist->objnum);
	 texname[ 8] = '\0';
	 strncpy( texname, SideDefs[ sdlist->objnum].tex3, 8);
	 sprintf( menustr[ 0], "Change Normal Texture   (Current: %s)", texname);
	 strncpy( texname, SideDefs[ sdlist->objnum].tex1, 8);
	 sprintf( menustr[ 1], "Change Upper texture    (Current: %s)", texname);
	 strncpy( texname, SideDefs[ sdlist->objnum].tex2, 8);
	 sprintf( menustr[ 2], "Change Lower texture    (Current: %s)", texname);
	 sprintf( menustr[ 3], "Change Texture X offset (Current: %d)", SideDefs[ sdlist->objnum].xoff);
	 sprintf( menustr[ 4], "Change Texture Y offset (Current: %d)", SideDefs[ sdlist->objnum].yoff);
	 sprintf( menustr[ 5], "Change Sector ref.      (Current: #%d)", SideDefs[ sdlist->objnum].sector);
	 val = DisplayMenuArray( x0 + 42, y0 + 54, menustr[ 6], 6, NULL, menustr, dummy);
	 for (n = 0; n < 7; n++)
	    FreeMemory( menustr[ n]);
	 switch (val)
	 {
	 case 1:
	    strncpy( texname, SideDefs[ sdlist->objnum].tex3, 8);
	    ObjectsNeeded( 0);
	    ChooseWallTexture( x0 + 84, y0 + 88, "Choose a wall texture", NumWTexture, WTexture, texname);
	    ObjectsNeeded( OBJ_SIDEDEFS, 0);
	    if (strlen(texname) > 0)
	    {
	       for (cur = sdlist; cur; cur = cur->next)
		  if (cur->objnum >= 0)
		     strncpy( SideDefs[ cur->objnum].tex3, texname, 8);
	       MadeChanges = TRUE;
	    }
	    break;
	 case 2:
	    strncpy( texname, SideDefs[ sdlist->objnum].tex1, 8);
	    ObjectsNeeded( 0);
	    ChooseWallTexture( x0 + 84, y0 + 98, "Choose a wall texture", NumWTexture, WTexture, texname);
	    ObjectsNeeded( OBJ_SIDEDEFS, 0);
	    if (strlen(texname) > 0)
	    {
	       for (cur = sdlist; cur; cur = cur->next)
		  if (cur->objnum >= 0)
		     strncpy( SideDefs[ cur->objnum].tex1, texname, 8);
	       MadeChanges = TRUE;
	    }
	    break;
	 case 3:
	    strncpy( texname, SideDefs[ sdlist->objnum].tex2, 8);
	    ObjectsNeeded( 0);
	    ChooseWallTexture( x0 + 84, y0 + 108, "Choose a wall texture", NumWTexture, WTexture, texname);
	    ObjectsNeeded( OBJ_SIDEDEFS, 0);
	    if (strlen(texname) > 0)
	    {
	       for (cur = sdlist; cur; cur = cur->next)
		  if (cur->objnum >= 0)
		     strncpy( SideDefs[ cur->objnum].tex2, texname, 8);
	       MadeChanges = TRUE;
	    }
	    break;
	 case 4:
	    val = InputIntegerValue( x0 + 84, y0 + 118, -255, 255, SideDefs[ sdlist->objnum].xoff);
	    if (val >= -255)
	    {
	       for (cur = sdlist; cur; cur = cur->next)
		  if (cur->objnum >= 0)
		     SideDefs[ cur->objnum].xoff = val;
	       MadeChanges = TRUE;
	    }
	    break;
	 case 5:
	    val = InputIntegerValue( x0 + 84, y0 + 128, -255, 255, SideDefs[ sdlist->objnum].yoff);
	    if (val >= -255)
	    {
	       for (cur = sdlist; cur; cur = cur->next)
		  if (cur->objnum >= 0)
		     SideDefs[ cur->objnum].yoff = val;
	       MadeChanges = TRUE;
	    }
	    break;
	 case 6:
	    val = InputObjectXRef( x0 + 84, y0 + 138, OBJ_SECTORS, FALSE, SideDefs[ sdlist->objnum].sector);
	    if (val >= 0)
	    {
	       for (cur = sdlist; cur; cur = cur->next)
		  if (cur->objnum >= 0)
		     SideDefs[ cur->objnum].sector = val;
	       MadeChanges = TRUE;
	    }
	    break;
	 }
	 ForgetSelection( &sdlist);
	 break;

      }
      break;

   case OBJ_SECTORS:
      for (n = 0; n < 8; n++)
	 menustr[ n] = GetMemory( 60);
      sprintf( menustr[ 7], "Edit Sector #%d", obj->objnum);
      sprintf( menustr[ 0], "Change Floor height     (Current: %d)", Sectors[ obj->objnum].floorh);
      sprintf( menustr[ 1], "Change Ceiling height   (Current: %d)", Sectors[ obj->objnum].ceilh);
      texname[ 8] = '\0';
      strncpy( texname, Sectors[ obj->objnum].floort, 8);
      sprintf( menustr[ 2], "Change Floor texture    (Current: %s)", texname);
      strncpy( texname, Sectors[ obj->objnum].ceilt, 8);
      sprintf( menustr[ 3], "Change Ceiling texture  (Current: %s)", texname);
      sprintf( menustr[ 4], "Change Light level      (Current: %d)", Sectors[ obj->objnum].light);
      sprintf( menustr[ 5], "Change Type             (Current: %d)", Sectors[ obj->objnum].special);
      sprintf( menustr[ 6], "Change LineDef tag      (Current: %d)", Sectors[ obj->objnum].tag);
      val = DisplayMenuArray( x0, y0, menustr[ 7], 7, NULL, menustr, dummy);
      for (n = 0; n < 8; n++)
	 FreeMemory( menustr[ n]);
      switch (val)
      {
      case 1:
	 val = InputIntegerValue( x0 + 42, y0 + 34, -16384, 16383, Sectors[ obj->objnum].floorh);
	 if (val >= -16384)
	 {
	    for (cur = obj; cur; cur = cur->next)
	       Sectors[ cur->objnum].floorh = val;
	    MadeChanges = TRUE;
	 }
	 break;
      case 2:
	 val = InputIntegerValue( x0 + 42, y0 + 44, -16384, 16383, Sectors[ obj->objnum].ceilh);
	 if (val >= -16384)
	 {
	    for (cur = obj; cur; cur = cur->next)
	       Sectors[ cur->objnum].ceilh = val;
	    MadeChanges = TRUE;
	 }
	 break;
      case 3:
	 strncpy( texname, Sectors[ obj->objnum].floort, 8);
	 ObjectsNeeded( 0);
	 ChooseFloorTexture( x0 + 42, y0 + 54, "Choose a floor texture", NumFTexture, FTexture, texname);
	 ObjectsNeeded( OBJ_SECTORS, 0);
	 if (strlen(texname) > 0)
	 {
	    for (cur = obj; cur; cur = cur->next)
	       strncpy( Sectors[ cur->objnum].floort, texname, 8);
	    MadeChanges = TRUE;
	 }
	 break;
      case 4:
	 strncpy( texname, Sectors[ obj->objnum].ceilt, 8);
	 ObjectsNeeded( 0);
	 ChooseFloorTexture( x0 + 42, y0 + 64, "Choose a ceiling texture", NumFTexture, FTexture, texname);
	 ObjectsNeeded( OBJ_SECTORS, 0);
	 if (strlen(texname) > 0)
	 {
	    for (cur = obj; cur; cur = cur->next)
	       strncpy( Sectors[ cur->objnum].ceilt, texname, 8);
	    MadeChanges = TRUE;
	 }
	 break;
      case 5:
	 val = InputIntegerValue( x0 + 42, y0 + 74, 0, 255, Sectors[ obj->objnum].light);
	 if (val >= 0)
	 {
	    for (cur = obj; cur; cur = cur->next)
	       Sectors[ cur->objnum].light = val;
	    MadeChanges = TRUE;
	 }
	 break;
      case 6:
	 val = DisplayMenu( x0 + 42, y0 + 84, "Choose a special behaviour",
			    GetSectorTypeLongName( 0),
			    GetSectorTypeLongName( 1),
			    GetSectorTypeLongName( 2),
			    GetSectorTypeLongName( 3),
			    GetSectorTypeLongName( 4),
			    GetSectorTypeLongName( 5),
			    GetSectorTypeLongName( 7),
			    GetSectorTypeLongName( 8),
			    GetSectorTypeLongName( 9),
			    GetSectorTypeLongName( 10),
			    GetSectorTypeLongName( 11),
			    GetSectorTypeLongName( 12),
			    GetSectorTypeLongName( 13),
			    GetSectorTypeLongName( 14),
			    GetSectorTypeLongName( 16),
			    "(Enter a decimal value)",
			    NULL);
	 switch (val)
	 {
	 case 1:
	 case 2:
	 case 3:
	 case 4:
	 case 5:
	 case 6:
	    for (cur = obj; cur; cur = cur->next)
	       Sectors[ cur->objnum].special = val - 1;
	    MadeChanges = TRUE;
	    break;
	 case 7:
	 case 8:
	 case 9:
	 case 10:
	 case 11:
	 case 12:
	 case 13:
	 case 14:
	    for (cur = obj; cur; cur = cur->next)
	       Sectors[ cur->objnum].special = val;
	    MadeChanges = TRUE;
	    break;
	 case 15:
	    for (cur = obj; cur; cur = cur->next)
	       Sectors[ cur->objnum].special = 16;
	    MadeChanges = TRUE;
	    break;
	 case 16:
	    val = InputIntegerValue( x0 + 84, y0 + 208, 0, 255, Sectors[ obj->objnum].special);
	    if (val >= 0)
	    {
	       for (cur = obj; cur; cur = cur->next)
		  Sectors[ cur->objnum].special = val;
	       MadeChanges = TRUE;
	    }
	    break;
	 }
	 break;
      case 7:
	 val = InputIntegerValue( x0 + 42, y0 + 94, 0, 999, Sectors[ obj->objnum].tag);
	 if (val >= 0)
	 {
	    for (cur = obj; cur; cur = cur->next)
	       Sectors[ cur->objnum].tag = val;
	    MadeChanges = TRUE;
	 }
	 break;
      }
      break;
   }
}



/*
   Yuck!  Dirty piece of code...
*/

Bool Input2Numbers( short x0, short y0, char *name1, char *name2, short v1max, short v2max, short *v1, short *v2)
{
   short  key;
   short  maxlen, first;
   Bool ok;
   char prompt[ 80];

   if (UseMouse)
      HideMousePointer();
   sprintf( prompt, "Give the %s and %s for the object:", name1, name2);
   maxlen = strlen( prompt);
   if (x0 < 0)
      x0 = (ScrMaxX - 25 - 8 * maxlen) / 2;
   if (y0 < 0)
      y0 = (ScrMaxY - 75) / 2;
   DrawScreenBox3D( x0, y0, x0 + 25 + 8 * maxlen, y0 + 75);
   DrawScreenText( x0 + 10, y0 + 26, name1);
   DrawScreenText( x0 + 180, y0 + 26, name2);
   DrawScreenText( x0 + 10, y0 + 58, "(0-%d)", v1max);
   DrawScreenText( x0 + 180, y0 + 58, "(0-%d)", v2max);
   SetColor( WHITE);
   DrawScreenText( x0 + 10, y0 + 8, prompt);
   first = TRUE;
   key = 0;
   for (;;)
   {
      ok = TRUE;
      DrawScreenBox3D( x0 + 10, y0 + 38, x0 + 71, y0 + 51);
      if (*v1 < 0 || *v1 > v1max)
      {
	 SetColor( 8);
	 ok = FALSE;
      }
      DrawScreenText( x0 + 14, y0 + 41, "%d", *v1);
      DrawScreenBox3D( x0 + 180, y0 + 38, x0 + 241, y0 + 51);
      if (*v2 < 0 || *v2 > v2max)
      {
	 SetColor( 8);
	 ok = FALSE;
      }
      DrawScreenText( x0 + 184, y0 + 41, "%d", *v2);
      if (first)
	 key = InputInteger( x0 + 10, y0 + 38, v1, 0, v1max);
      else
	 key = InputInteger( x0 + 180, y0 + 38, v2, 0, v2max);
      if ((key & 0xFF00) == 0x4B00 || (key & 0xFF00) == 0x4D00 || (key & 0x00FF) == 0x0009 || (key & 0xFF00) == 0x0F00)
	 first = !first;
      else if ((key & 0x00FF) == 0x001B)
	 break;
      else if ((key & 0x00FF) == 0x000D)
      {
	 if (first)
	    first = FALSE;
	 else if (ok)
	    break;
	 else
	    Beep();
      }
      else
	 Beep();
   }
   if (UseMouse)
      ShowMousePointer();
   return ((key & 0x00FF) == 0x000D);
}



/*
   display number of objects, etc.
*/

void Statistics( short x0, short y0)
{
 OBJECT *form;
 char temp[5];
 short seld,xdial,ydial,wdial,hdial;
 
 rsrc_gaddr(0,STATISTICS,&form);

 sprintf(temp,"%d",NumThings);  /* Set the strings... */
 objc_newtext(form,NUMTHINGS,temp);
 sprintf(temp,"%d",NumVertexes);
 objc_newtext(form,NUMVERTICES,temp);
 sprintf(temp,"%d",NumLineDefs);
 objc_newtext(form,NUMLINEDEFS,temp);
 sprintf(temp,"%d",NumSideDefs);
 objc_newtext(form,NUMSIDEDEFS,temp);
 sprintf(temp,"%d",NumSectors);
 objc_newtext(form,NUMSECTORS,temp);

 form_center ( form, &xdial, &ydial, &wdial, &hdial );
 form_dial ( 0, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
 objc_draw (form, 0, 2, xdial, ydial, wdial, hdial );
 seld=form_do ( form, 0 ); 
 form_dial ( 3, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
 objc_change (form,seld,-1,-1,-1,-1,-1,NORMAL,1);
}



/*
   display a message while the user is waiting...
*/

void CheckingObjects( short x0, short y0)
{
   if (UseMouse)
      HideMousePointer();
   if (x0 < 0)
     x0 = (ScrMaxX - 172) / 2;
   if (y0 < 0)
     y0 = (ScrMaxY - 30) / 2;
   DrawScreenBox3D( x0, y0, x0 + 172, y0 + 30);
   DrawScreenText( x0 + 10, y0 + 5, "Checking objects...");
   DrawScreenText( x0 + 10, y0 + 15, "   Please wait");
   if (UseMouse)
      ShowMousePointer();
}




/*
   display a message, then ask if the check should continue (prompt2 may be NULL)
*/

Bool CheckFailed( short x0, short y0, char *prompt1, char *prompt2, Bool fatal)
{
 short key;
 char msg[100];  

 strcpy(msg,"[1][");
 strcat(msg,prompt1);
 if (prompt2!=NULL)
    {
     strcat(msg,"|");
     strcat(msg,prompt2);
    }
 strcat(msg,"][Oh]");

 form_alert(1,msg);
 LogMessage( "\t%s\n", prompt1);
 if (prompt2 != NULL)
   {
    LogMessage( "\t%s\n", prompt2);
   }
 if (fatal == TRUE)
    {
     form_alert(1,"[1][DOOM will crash if you|play with this level.|Jump to object...][Damn]");
    }
   else
    {
     key=form_alert(1,"[2][Continue searching, |or stop now?][Continue|Stop]") - 1;
    }
 if (!key)
    {
     DrawScreenBox3D( x0, y0, x0 + 22 + 8 * 44, y0 + (prompt2 ? 73 : 63));
     DrawScreenText( x0 + 10 + 4 * (44 - 26), y0 + 28, "Verifying other objects...");
    }
 return (key);
}




/*
   check if all sectors are closed
*/

void CheckSectors( void) /* SWAP! */
{
   short      s, n, sd;
   char huge *ends;
   char       msg1[ 80], msg2[80];

   CheckingObjects( -1, -1);
   LogMessage( "\nVerifying Sectors...\n");
   ObjectsNeeded( OBJ_LINEDEFS, OBJ_SIDEDEFS, 0);
   ends = GetFarMemory( NumVertexes * sizeof( char));
   for (s = 0; s < NumSectors; s++)
   {
      /* clear the "ends" array */
      for (n = 0; n < NumVertexes; n++)
	 ends[ n] = 0;
      /* for each SideDef bound to the Sector, store a "1" in the "ends" */
      /* array for its starting Vertex, and a "2" for its ending Vertex  */
      for (n = 0; n < NumLineDefs; n++)
      {
	 sd = LineDefs[ n].sidedef1;
	 if (sd >= 0 && SideDefs[ sd].sector == s)
	 {
	    ends[ LineDefs[ n].start] |= 1;
	    ends[ LineDefs[ n].end] |= 2;
	 }
	 sd = LineDefs[ n].sidedef2;
	 if (sd >= 0 && SideDefs[ sd].sector == s)
	 {
	    ends[ LineDefs[ n].end] |= 1;
	    ends[ LineDefs[ n].start] |= 2;
	 }
      }
      /* every entry in the "ends" array should be "0" or "3" */
      for (n = 0; n < NumVertexes; n++)
      {
	 if (ends[ n] == 1)
	 {
	    sprintf( msg1, "Sector #%d is not closed!", s);
	    sprintf( msg2, "There is no SideDef ending at Vertex #%d", n);
	    if (CheckFailed( -1, -1, msg1, msg2, FALSE))
	    {
	       GoToObject( OBJ_VERTEXES, n);
	       return;
	    }
	 }
	 if (ends[ n] == 2)
	 {
	    sprintf( msg1, "Sector #%d is not closed!", s);
	    sprintf( msg2, "There is no SideDef starting at Vertex #%d", n);
	    if (CheckFailed( -1, -1, msg1, msg2, FALSE))
	    {
	       GoToObject( OBJ_VERTEXES, n);
	       return;
	    }
	 }
      }
   }
   FreeFarMemory( ends);

   /*
      Note from RQ:
	 This is a very simple idea, but it works!  The first test (above)
	 checks that all Sectors are closed.  But if a closed set of LineDefs
	 is moved out of a Sector and has all its "external" SideDefs pointing
	 to that Sector instead of the new one, then we need a second test.
	 That's why I check if the SideDefs facing each other are bound to
	 the same Sector.

      Other note from RQ:
	 Nowadays, what makes the power of a good editor is its automatic tests.
	 So, if you are writing another Doom editor, you will probably want
	 to do the same kind of tests in your program.  Fine, but if you use
	 these ideas, don't forget to credit DEU...  Just a reminder... :-)
   */

   /* now check if all SideDefs are facing a SideDef with the same Sector number */
   for (n = 0; n < NumLineDefs; n++)
   {
      ObjectsNeeded( OBJ_LINEDEFS, 0);
      sd = LineDefs[ n].sidedef1;
      if (sd >= 0)
      {
	 s = GetOppositeSector( n, TRUE);
	 ObjectsNeeded( OBJ_SIDEDEFS, 0);
	 if (s < 0 || SideDefs[ sd].sector != s)
	 {
	    if (s < 0)
	    {
	       sprintf( msg1, "Sector #%d is not closed!", SideDefs[ sd].sector);
	       sprintf( msg2, "Check LineDef #%d (first SideDef: #%d)", n, sd);
	    }
	    else
	    {
	       sprintf( msg1, "Sectors #%d and #%d are not closed!", SideDefs[ sd].sector, s);
	       sprintf( msg2, "Check LineDef #%d (first SideDef: #%d) and the one facing it", n, sd);
	    }
	    if (CheckFailed( -1, -1, msg1, msg2, FALSE))
	    {
	       GoToObject( OBJ_LINEDEFS, n);
	       return;
	    }
	 }
      }
      ObjectsNeeded( OBJ_LINEDEFS, 0);
      sd = LineDefs[ n].sidedef2;
      if (sd >= 0)
      {
	 s = GetOppositeSector( n, FALSE);
	 ObjectsNeeded( OBJ_SIDEDEFS, 0);
	 if (s < 0 || SideDefs[ sd].sector != s)
	 {
	    if (s < 0)
	    {
	       sprintf( msg1, "Sector #%d is not closed!", SideDefs[ sd].sector);
	       sprintf( msg2, "Check LineDef #%d (second SideDef: #%d)", n, sd);
	    }
	    else
	    {
	       sprintf( msg1, "Sectors #%d and #%d are not closed!", SideDefs[ sd].sector, s);
	       sprintf( msg2, "Check LineDef #%d (second SideDef: #%d) and the one facing it", n, sd);
	    }
	    if (CheckFailed( -1, -1, msg1, msg2, FALSE))
	    {
	       GoToObject( OBJ_LINEDEFS, n);
	       return;
	    }
	 }
      }
   }
}



/*
   check cross-references and delete unused objects
*/

void CheckCrossReferences( void) /* SWAP! */
{
   char   msg[ 80];
   short  n, m;
   SelPtr cur;

   CheckingObjects( -1, -1);
   LogMessage( "\nVerifying cross-references...\n");
   ObjectsNeeded( OBJ_LINEDEFS, 0);
   for (n = 0; n < NumLineDefs; n++)
   {
      /* check for missing first SideDefs */
      if (LineDefs[ n].sidedef1 < 0)
      {
	 sprintf( msg, "ERROR: LineDef #%d has no first SideDef!", n);
	 CheckFailed( -1, -1, msg, NULL, TRUE);
	 GoToObject( OBJ_LINEDEFS, n);
	 return;
      }
      /* check for SideDefs used twice in the same LineDef */
      if (LineDefs[ n].sidedef1 == LineDefs[ n].sidedef2)
      {
	 sprintf( msg, "ERROR: LineDef #%d uses the same SideDef twice (#%d)", n, LineDefs[ n].sidedef1);
	 CheckFailed( -1, -1, msg, NULL, TRUE);
	 GoToObject( OBJ_LINEDEFS, n);
	 return;
      }
      /* check for Vertices used twice in the same LineDef */
      if (LineDefs[ n].start == LineDefs[ n].end)
      {
	 sprintf( msg, "ERROR: LineDef #%d uses the same Vertex twice (#%d)", n, LineDefs[ n].start);
	 CheckFailed( -1, -1, msg, NULL, TRUE);
	 GoToObject( OBJ_LINEDEFS, n);
	 return;
      }
   }

   /* check if there aren't two LineDefs between the same Vertices */
   cur = NULL;
   for (n = NumLineDefs - 1; n >= 1; n--)
   {
      for (m = n - 1; m >= 0; m--)
	 if ((LineDefs[ n].start == LineDefs[ m].start && LineDefs[ n].end == LineDefs[ m].end)
	  || (LineDefs[ n].start == LineDefs[ m].end && LineDefs[ n].end == LineDefs[ m].start))
	 {
	    SelectObject( &cur, n);
	    break;
	 }
   }
   if (cur && (Expert || Confirm(-1, -1, "There are multiple LineDefs between the same Vertices", "Do you want to delete the redundant LineDefs?")))
      DeleteObjects( OBJ_LINEDEFS, &cur);
   else
      ForgetSelection( &cur);

   CheckingObjects( -1, -1);
   /* check for invalid flags in the LineDefs */
   for (n = 0; n < NumLineDefs; n++)
      if ((LineDefs[ n].flags & 0x01) == 0 && LineDefs[ n].sidedef2 < 0)
	 SelectObject( &cur, n);
   if (cur && (Expert || Confirm(-1, -1, "Some LineDefs have only one side but their Im bit is not set", "Do you want to set the 'Impassible' flag?")))
   {
      while (cur)
      {
	 LineDefs[ cur->objnum].flags |= 0x01;
	 UnSelectObject( &cur, cur->objnum);
      }
   }
   else
      ForgetSelection( &cur);

   CheckingObjects( -1, -1);
   for (n = 0; n < NumLineDefs; n++)
      if ((LineDefs[ n].flags & 0x04) != 0 && LineDefs[ n].sidedef2 < 0)
	 SelectObject( &cur, n);
   if (cur && (Expert || Confirm(-1, -1, "Some LineDefs have only one side but their 2S bit is set", "Do you want to clear the 'two-sided' flag?")))
   {
      while (cur)
      {
	 LineDefs[ cur->objnum].flags &= ~0x04;
	 UnSelectObject( &cur, cur->objnum);
      }
   }
   else
      ForgetSelection( &cur);

   CheckingObjects( -1, -1);
   for (n = 0; n < NumLineDefs; n++)
      if ((LineDefs[ n].flags & 0x04) == 0 && LineDefs[ n].sidedef2 >= 0)
	 SelectObject( &cur, n);
   if (cur && (Expert || Confirm(-1, -1, "Some LineDefs have two sides but their 2S bit is not set", "Do you want to set the 'two-sided' flag?")))
   {
      while (cur)
      {
	 LineDefs[ cur->objnum].flags |= 0x04;
	 UnSelectObject( &cur, cur->objnum);
      }
   }
   else
      ForgetSelection( &cur);

   CheckingObjects( -1, -1);
   /* select all Vertices */
   for (n = 0; n < NumVertexes; n++)
      SelectObject( &cur, n);
   /* unselect Vertices used in a LineDef */
   for (n = 0; n < NumLineDefs; n++)
   {
      m = LineDefs[ n].start;
      if (cur && m >= 0)
	 UnSelectObject( &cur, m);
      m = LineDefs[ n].end;
      if (cur && m >= 0)
	 UnSelectObject( &cur, m);
      continue;
   }
   /* check if there are any Vertices left */
   if (cur && (Expert || Confirm(-1, -1, "Some Vertices are not bound to any LineDef", "Do you want to delete these unused Vertices?")))
   {
      DeleteObjects( OBJ_VERTEXES, &cur);
      ObjectsNeeded( OBJ_LINEDEFS, 0);
   }
   else
      ForgetSelection( &cur);

   CheckingObjects( -1, -1);
   /* select all SideDefs */
   for (n = 0; n < NumSideDefs; n++)
      SelectObject( &cur, n);
   /* unselect SideDefs bound to a LineDef */
   for (n = 0; n < NumLineDefs; n++)
   {
      m = LineDefs[ n].sidedef1;
      if (cur && m >= 0)
	 UnSelectObject( &cur, m);
      m = LineDefs[ n].sidedef2;
      if (cur && m >= 0)
	 UnSelectObject( &cur, m);
      continue;
   }
   /* check if there are any SideDefs left */
   if (cur && (Expert || Confirm(-1, -1, "Some SideDefs are not bound to any LineDef", "Do you want to delete these unused SideDefs?")))
      DeleteObjects( OBJ_SIDEDEFS, &cur);
   else
      ForgetSelection( &cur);

   CheckingObjects( -1, -1);
   /* select all Sectors */
   for (n = 0; n < NumSectors; n++)
      SelectObject( &cur, n);
   /* unselect Sectors bound to a SideDef */
   for (n = 0; n < NumLineDefs; n++)
   {
      ObjectsNeeded( OBJ_LINEDEFS, 0);
      m = LineDefs[ n].sidedef1;
      ObjectsNeeded( OBJ_SIDEDEFS, 0);
      if (cur && m >= 0 && SideDefs[ m].sector >= 0)
	 UnSelectObject( &cur, SideDefs[ m].sector);
      ObjectsNeeded( OBJ_LINEDEFS, 0);
      m = LineDefs[ n].sidedef2;
      ObjectsNeeded( OBJ_SIDEDEFS, 0);
      if (cur && m >= 0 && SideDefs[ m].sector >= 0)
	 UnSelectObject( &cur, SideDefs[ m].sector);
      continue;
   }
   /* check if there are any Sectors left */
   if (cur && (Expert || Confirm(-1, -1, "Some Sectors are not bound to any SideDef", "Do you want to delete these unused Sectors?")))
      DeleteObjects( OBJ_SECTORS, &cur);
   else
      ForgetSelection( &cur);
}



/*
   check for missing textures
*/

void CheckTextures( void) /* SWAP! */
{
   short n;
   short sd1, sd2;
   short s1, s2;
   char msg1[ 80], msg2[ 80];

   CheckingObjects( -1, -1);
   LogMessage( "\nVerifying textures...\n");
   ObjectsNeeded( OBJ_SECTORS, 0);
   for (n = 0; n < NumSectors; n++)
   {
      if (Sectors[ n].ceilt[ 0] == '-' && Sectors[ n].ceilt == '\0')
      {
	 sprintf( msg1, "Error: Sector #%d has no ceiling texture", n);
	 sprintf( msg2, "You probaly used a brain-damaged editor to do that...");
	 CheckFailed( -1, -1, msg1, msg2, TRUE);
	 GoToObject( OBJ_SECTORS, n);
	 return;
      }
      if (Sectors[ n].floort[ 0] == '-' && Sectors[ n].floort == '\0')
      {
	 sprintf( msg1, "Error: Sector #%d has no floor texture", n);
	 sprintf( msg2, "You probaly used a brain-damaged editor to do that...");
	 CheckFailed( -1, -1, msg1, msg2, TRUE);
	 GoToObject( OBJ_SECTORS, n);
	 return;
      }
      if (Sectors[ n].ceilh < Sectors[ n].floorh)
      {
	 sprintf( msg1, "Error: Sector #%d has its ceiling lower than its floor", n);
	 sprintf( msg2, "The textures will never be displayed if you cannot go there");
	 CheckFailed( -1, -1, msg1, msg2, TRUE);
	 GoToObject( OBJ_SECTORS, n);
	 return;
      }
      if (Sectors[ n].ceilh - Sectors[ n].floorh > 1023)
      {
	 sprintf( msg1, "Error: Sector #%d has its ceiling too high", n);
	 sprintf( msg2, "The maximum difference allowed is 1023 (ceiling - floor)");
	 CheckFailed( -1, -1, msg1, msg2, TRUE);
	 GoToObject( OBJ_SECTORS, n);
	 return;
      }
   }
   for (n = 0; n < NumLineDefs; n++)
   {
      ObjectsNeeded( OBJ_LINEDEFS, 0);
      sd1 = LineDefs[ n].sidedef1;
      sd2 = LineDefs[ n].sidedef2;
      ObjectsNeeded( OBJ_SIDEDEFS, OBJ_SECTORS, 0);
      if (sd1 >= 0)
	 s1 = SideDefs[ sd1].sector;
      else
	 s1 = -1;
      if (sd2 >= 0)
	 s2 = SideDefs[ sd2].sector;
      else
	 s2 = -1;
      if (s1 >= 0 && s2 < 0)
      {
	 if (SideDefs[ sd1].tex3[ 0] == '-' && SideDefs[ sd1].tex3[ 1] == '\0')
	 {
	    sprintf( msg1, "Error in one-sided Linedef #%d: SideDef #%d has no normal texture", n, sd1);
	    sprintf( msg2, "Do you want to set the texture to \"%s\" and continue?", DefaultWallTexture);
	    if (CheckFailed( -1, -1, msg1, msg2, FALSE))
	    {
	       GoToObject( OBJ_LINEDEFS, n);
	       return;
	    }
	    strncpy( SideDefs[ sd1].tex3, DefaultWallTexture, 8);
	    CheckingObjects( -1, -1);
	 }
      }
      if (s1 >= 0 && s2 >= 0 && Sectors[ s1].ceilh > Sectors[ s2].ceilh)
      {
	 if (SideDefs[ sd1].tex1[ 0] == '-' && SideDefs[ sd1].tex1[ 1] == '\0'
	     && (strncmp( Sectors[ s1].ceilt, "F_SKY1", 8) || strncmp( Sectors[ s2].ceilt, "F_SKY1", 8)))
	 {
	    sprintf( msg1, "Error in first SideDef of Linedef #%d: SideDef #%d has no upper texture", n, sd1);
	    sprintf( msg2, "Do you want to set the texture to \"%s\" and continue?", DefaultUpperTexture);
	    if (CheckFailed( -1, -1, msg1, msg2, FALSE))
	    {
	       GoToObject( OBJ_LINEDEFS, n);
	       return;
	    }
	    strncpy( SideDefs[ sd1].tex1, DefaultUpperTexture, 8);
	    CheckingObjects( -1, -1);
	 }
      }
      if (s1 >= 0 && s2 >= 0 && Sectors[ s1].floorh < Sectors[ s2].floorh)
      {
	 if (SideDefs[ sd1].tex2[ 0] == '-' && SideDefs[ sd1].tex2[ 1] == '\0')
	 {
	    sprintf( msg1, "Error in first SideDef of Linedef #%d: SideDef #%d has no lower texture", n, sd1);
	    sprintf( msg2, "Do you want to set the texture to \"%s\" and continue?", DefaultLowerTexture);
	    if (CheckFailed( -1, -1, msg1, msg2, FALSE))
	    {
	       GoToObject( OBJ_LINEDEFS, n);
	       return;
	    }
	    strncpy( SideDefs[ sd1].tex2, DefaultLowerTexture, 8);
	    CheckingObjects( -1, -1);
	 }
      }
      if (s1 >= 0 && s2 >= 0 && Sectors[ s2].ceilh > Sectors[ s1].ceilh)
      {
	 if (SideDefs[ sd2].tex1[ 0] == '-' && SideDefs[ sd2].tex1[ 1] == '\0'
	     && (strncmp( Sectors[ s1].ceilt, "F_SKY1", 8) || strncmp( Sectors[ s2].ceilt, "F_SKY1", 8)))
	 {
	    sprintf( msg1, "Error in second SideDef of Linedef #%d: SideDef #%d has no upper texture", n, sd2);
	    sprintf( msg2, "Do you want to set the texture to \"%s\" and continue?", DefaultUpperTexture);
	    if (CheckFailed( -1, -1, msg1, msg2, FALSE))
	    {
	       GoToObject( OBJ_LINEDEFS, n);
	       return;
	    }
	    strncpy( SideDefs[ sd2].tex1, DefaultUpperTexture, 8);
	    CheckingObjects( -1, -1);
	 }
      }
      if (s1 >= 0 && s2 >= 0 && Sectors[ s2].floorh < Sectors[ s1].floorh)
      {
	 if (SideDefs[ sd2].tex2[ 0] == '-' && SideDefs[ sd2].tex2[ 1] == '\0')
	 {
	    sprintf( msg1, "Error in second SideDef of Linedef #%d: SideDef #%d has no lower texture", n, sd2);
	    sprintf( msg2, "Do you want to set the texture to \"%s\" and continue?", DefaultLowerTexture);
	    if (CheckFailed( -1, -1, msg1, msg2, FALSE))
	    {
	       GoToObject( OBJ_LINEDEFS, n);
	       return;
	    }
	    strncpy( SideDefs[ sd2].tex2, DefaultLowerTexture, 8);
	    CheckingObjects( -1, -1);
	 }
      }
   }
}



/*
   check if a texture name matches one of the elements of a list
*/

Bool IsTextureNameInList( char *name, char **list, short numelems)
{
   short n;

   for (n = 0; n < numelems; n++)
      if (! strnicmp( name, list[ n], 8))
	 return TRUE;
   return FALSE;
}



/*
   check for invalid texture names
*/

void CheckTextureNames( void) /* SWAP! */
{
   short n;
   char msg1[ 80], msg2[ 80];

   LogMessage( "\nVerifying texture names...\n");
   if (FindMasterDir( MasterDir, "F2_START") == NULL)
      NumThings--;
   ObjectsNeeded( OBJ_SECTORS, 0);
   for (n = 0; n < NumSectors; n++)
   {
      if (! IsTextureNameInList( Sectors[ n].ceilt, FTexture, NumFTexture))
      {
	 sprintf( msg1, "Invalid ceiling texture in Sector #%d", n);
	 sprintf( msg2, "The name \"%s\" is not a floor/ceiling texture", Sectors[ n].ceilt);
	 if (CheckFailed( -1, -1, msg1, msg2, FALSE))
	 {
	    GoToObject( OBJ_SECTORS, n);
	    return;
	 }
	 CheckingObjects( -1, -1);
      }
      if (! IsTextureNameInList( Sectors[ n].floort, FTexture, NumFTexture))
      {
	 sprintf( msg1, "Invalid floor texture in Sector #%d", n);
	 sprintf( msg2, "The name \"%s\" is not a floor/ceiling texture", Sectors[ n].floort);
	 if (CheckFailed( -1, -1, msg1, msg2, FALSE))
	 {
	    GoToObject( OBJ_SECTORS, n);
	    return;
	 }
	 CheckingObjects( -1, -1);
      }
   }
   ObjectsNeeded( OBJ_SIDEDEFS, 0);
   for (n = 0; n < NumSideDefs; n++)
   {
      if (! IsTextureNameInList( SideDefs[ n].tex1, WTexture, NumWTexture))
      {
	 sprintf( msg1, "Invalid upper texture in SideDef #%d", n);
	 sprintf( msg2, "The name \"%s\" is not a wall texture", SideDefs[ n].tex1);
	 if (CheckFailed( -1, -1, msg1, msg2, FALSE))
	 {
	    GoToObject( OBJ_SIDEDEFS, n);
	    return;
	 }
	 CheckingObjects( -1, -1);
      }
      if (! IsTextureNameInList( SideDefs[ n].tex2, WTexture, NumWTexture))
      {
	 sprintf( msg1, "Invalid lower texture in SideDef #%d", n);
	 sprintf( msg2, "The name \"%s\" is not a wall texture", SideDefs[ n].tex2);
	 if (CheckFailed( -1, -1, msg1, msg2, FALSE))
	 {
	    GoToObject( OBJ_SIDEDEFS, n);
	    return;
	 }
	 CheckingObjects( -1, -1);
      }
      if (! IsTextureNameInList( SideDefs[ n].tex3, WTexture, NumWTexture))
      {
	 sprintf( msg1, "Invalid normal texture in SideDef #%d", n);
	 sprintf( msg2, "The name \"%s\" is not a wall texture", SideDefs[ n].tex3);
	 if (CheckFailed( -1, -1, msg1, msg2, FALSE))
	 {
	    GoToObject( OBJ_SIDEDEFS, n);
	    return;
	 }
	 CheckingObjects( -1, -1);
      }
   }
}



/*
   check the level consistency
*/

void CheckLevel( short x0, short y0) /* SWAP! */
{
   char *line5 = NULL;

   if (Registered)
   {
      if (FindMasterDir( MasterDir, "TEXTURE2") == NULL)
	 NumVertexes--;
      else
	 line5 = "Check texture names";
   }

 if (line5) CheckTextureNames();
}



/*
   check for players starting points
*/

Bool CheckStartingPos() /* SWAP! */
{
   char msg1[ 80], msg2[80];
   Bool p1 = FALSE;
   Bool p2 = FALSE;
   Bool p3 = FALSE;
   Bool p4 = FALSE;
   short dm = 0;
   short t;

   ObjectsNeeded( OBJ_THINGS, 0);
   for (t = 0; t < NumThings; t++)
   {
      if (Things[ t].type == THING_PLAYER1)
	 p1 = TRUE;
      if (Things[ t].type == THING_PLAYER2)
	 p2 = TRUE;
      if (Things[ t].type == THING_PLAYER3)
	 p3 = TRUE;
      if (Things[ t].type == THING_PLAYER4)
	 p4 = TRUE;
      if (Things[ t].type == THING_DEATHMATCH)
	 dm++;
   }
   if (p1 == FALSE)
   {
      Beep();
      sprintf( msg1, "Warning: there is no player 1 starting point!  DOOM will crash if");
      sprintf( msg2, "you play with this level.  Do you really want to save it?");
      return Confirm( -1, -1, msg1, msg2);
   }
   if (Expert)
      return TRUE;
   if (p2 == FALSE || p3 == FALSE || p4 == FALSE)
   {
      if (p4 == FALSE)
	t = 4;
      if (p3 == FALSE)
	t = 3;
      if (p2 == FALSE)
	t = 2;
      sprintf( msg1, "Warning: there is no player %d starting point.  You will not be able to", t);
      sprintf( msg2, "use this level for multi-player games.  Press Y to return to the editor.");
      return !Confirm( -1, -1, msg1, msg2);
   }
   if (dm < 4)
   {
      if (dm == 0)
	 sprintf( msg1, "Warning: there are no DeathMatch starting points.  You need at least four");
      else if (dm == 1)
	 sprintf( msg1, "Warning: there is only one DeathMatch starting point.  You need at least four");
      else
	 sprintf( msg1, "Warning: there are only %d DeathMatch starting points.  You need at least four", dm);
      sprintf( msg2, "starting points to play DeathMatch games.  Press Y to return to the editor.");
      return !Confirm( -1, -1, msg1, msg2);
   }
   return TRUE;
}



/*
   insert a standard object at given position
*/

void InsertStandardObject( short x0, short y0, short xpos, short ypos) /* SWAP! */
{
   short sector;
   short choice, n;
   short a, b;

   /* show where the object will be inserted */
   if (UseMouse)
      HideMousePointer();
   DrawPointer( TRUE);
   if (UseMouse)
      ShowMousePointer();
   /* are we inside a Sector? */
   sector = GetCurObject( OBJ_SECTORS, xpos, ypos, xpos, ypos);
   if (sector >= 0)
      choice = DisplayMenu( x0, y0, ((x0 == -1) ? "Insert a pre-defined object (inside a Sector)" : NULL),
			    "Rectangle",
			    "Polygon (N sides)",
			    "Stairs",
			    "Hidden stairs",
			    NULL);
   else
      choice = DisplayMenu( x0, y0, ((x0 == -1) ? "Insert a pre-defined object (outside)" : NULL),
			    "Rectangle",
			    "Polygon (N sides)",
			    NULL);
   /* !!!! Should also check for overlapping objects (sectors) !!!! */
   switch (choice)
   {
   case 1:
      a = 256;
      b = 128;
      if (Input2Numbers( -1, -1, "Width", "Height", 2000, 2000, &a, &b))
      {
	 if (a < 8)
	    a = 8;
	 if (b < 8)
	    b = 8;
	 xpos = xpos - a / 2;
	 ypos = ypos - b / 2;
	 InsertObject( OBJ_VERTEXES, -1, xpos, ypos);
	 InsertObject( OBJ_VERTEXES, -1, xpos + a, ypos);
	 InsertObject( OBJ_VERTEXES, -1, xpos + a, ypos + b);
	 InsertObject( OBJ_VERTEXES, -1, xpos, ypos + b);
	 if (sector < 0)
	    InsertObject( OBJ_SECTORS, -1, 0, 0);
	 for (n = 0; n < 4; n++)
	 {
	    InsertObject( OBJ_LINEDEFS, -1, 0, 0);
	    LineDefs[ NumLineDefs - 1].sidedef1 = NumSideDefs;
	    InsertObject( OBJ_SIDEDEFS, -1, 0, 0);
	    if (sector >= 0)
	       SideDefs[ NumSideDefs - 1].sector = sector;
	 }
	 ObjectsNeeded( OBJ_LINEDEFS, 0);
	 if (sector >= 0)
	 {
	    LineDefs[ NumLineDefs - 4].start = NumVertexes - 4;
	    LineDefs[ NumLineDefs - 4].end = NumVertexes - 3;
	    LineDefs[ NumLineDefs - 3].start = NumVertexes - 3;
	    LineDefs[ NumLineDefs - 3].end = NumVertexes - 2;
	    LineDefs[ NumLineDefs - 2].start = NumVertexes - 2;
	    LineDefs[ NumLineDefs - 2].end = NumVertexes - 1;
	    LineDefs[ NumLineDefs - 1].start = NumVertexes - 1;
	    LineDefs[ NumLineDefs - 1].end = NumVertexes - 4;
	 }
	 else
	 {
	    LineDefs[ NumLineDefs - 4].start = NumVertexes - 1;
	    LineDefs[ NumLineDefs - 4].end = NumVertexes - 2;
	    LineDefs[ NumLineDefs - 3].start = NumVertexes - 2;
	    LineDefs[ NumLineDefs - 3].end = NumVertexes - 3;
	    LineDefs[ NumLineDefs - 2].start = NumVertexes - 3;
	    LineDefs[ NumLineDefs - 2].end = NumVertexes - 4;
	    LineDefs[ NumLineDefs - 1].start = NumVertexes - 4;
	    LineDefs[ NumLineDefs - 1].end = NumVertexes - 1;
	 }
      }
      break;
   case 2:
      a = 8;
      b = 128;
      if (Input2Numbers( -1, -1, "Number of sides", "Radius", 32, 2000, &a, &b))
      {
	 if (a < 3)
	    a = 3;
	 if (b < 8)
	    b = 8;
	 InsertPolygonVertices( xpos, ypos, a, b);
	 if (sector < 0)
	    InsertObject( OBJ_SECTORS, -1, 0, 0);
	 for (n = 0; n < a; n++)
	 {
	    InsertObject( OBJ_LINEDEFS, -1, 0, 0);
	    LineDefs[ NumLineDefs - 1].sidedef1 = NumSideDefs;
	    InsertObject( OBJ_SIDEDEFS, -1, 0, 0);
	    if (sector >= 0)
	       SideDefs[ NumSideDefs - 1].sector = sector;
	 }
	 ObjectsNeeded( OBJ_LINEDEFS, 0);
	 if (sector >= 0)
	 {
	    LineDefs[ NumLineDefs - 1].start = NumVertexes - 1;
	    LineDefs[ NumLineDefs - 1].end = NumVertexes - a;
	    for (n = 2; n <= a; n++)
	    {
	       LineDefs[ NumLineDefs - n].start = NumVertexes - n;
	       LineDefs[ NumLineDefs - n].end = NumVertexes - n + 1;
	    }
	 }
	 else
	 {
	    LineDefs[ NumLineDefs - 1].start = NumVertexes - a;
	    LineDefs[ NumLineDefs - 1].end = NumVertexes - 1;
	    for (n = 2; n <= a; n++)
	    {
	       LineDefs[ NumLineDefs - n].start = NumVertexes - n + 1;
	       LineDefs[ NumLineDefs - n].end = NumVertexes - n;
	    }
	 }
      }
      break;
   case 3:
/*
      a = 6;
      b = 16;
      if (Input2Numbers( -1, -1, "Number of steps", "Step height", 32, 48, &a, &b))
      {
	 if (a < 2)
	    a = 2;
	 ObjectsNeeded( OBJ_SECTORS, 0);
	 n = Sectors[ sector].ceilh;
	 h = Sectors[ sector].floorh;
	 if (a * b < n - h)
	 {
	    Beep();
	    Notify( -1, -1, "The stairs are too high for this Sector", NULL);
	    return;
	 }
	 xpos = xpos - 32;
	 ypos = ypos - 32 * a;
	 for (n = 0; n < a; n++)
	 {
	    InsertObject( OBJ_VERTEXES, -1, xpos, ypos);
	    InsertObject( OBJ_VERTEXES, -1, xpos + 64, ypos);
	    InsertObject( OBJ_VERTEXES, -1, xpos + 64, ypos + 64);
	    InsertObject( OBJ_VERTEXES, -1, xpos, ypos + 64);
	    ypos += 64;
	    InsertObject( OBJ_SECTORS, sector, 0, 0);
	    h += b;
	    Sectors[ NumSectors - 1].floorh = h;

	    InsertObject( OBJ_LINEDEFS, -1, 0, 0);
	    LineDefs[ NumLineDefs - 1].sidedef1 = NumSideDefs;
	    LineDefs[ NumLineDefs - 1].sidedef2 = NumSideDefs + 1;
	    InsertObject( OBJ_SIDEDEFS, -1, 0, 0);
	    SideDefs[ NumSideDefs - 1].sector = sector;
	    InsertObject( OBJ_SIDEDEFS, -1, 0, 0);

	    ObjectsNeeded( OBJ_LINEDEFS, 0);
	    LineDefs[ NumLineDefs - 4].start = NumVertexes - 4;
	    LineDefs[ NumLineDefs - 4].end = NumVertexes - 3;
	    LineDefs[ NumLineDefs - 3].start = NumVertexes - 3;
	    LineDefs[ NumLineDefs - 3].end = NumVertexes - 2;
	    LineDefs[ NumLineDefs - 2].start = NumVertexes - 2;
	    LineDefs[ NumLineDefs - 2].end = NumVertexes - 1;
	    LineDefs[ NumLineDefs - 1].start = NumVertexes - 1;
	    LineDefs[ NumLineDefs - 1].end = NumVertexes - 4;
	}
      }
      break;
*/
   case 4:
     NotImplemented();
     break;
   }
}



/*
   menu of miscellaneous operations
*/

void MiscOperations( short x0, short y0, short objtype, SelPtr *list) /* SWAP! */
{
   char   msg[ 80];
   short  val;
   short  angle, scale;

   sprintf( msg, "Rotate and scale %s", GetEditModeName( objtype));
   if (objtype == OBJ_VERTEXES)
   {
      val = DisplayMenu( x0, y0, ((x0 == -1) ? "Misc. Operations" : NULL),
			 "Find first free tag number",
			 msg,
			 "Delete Vertex and join LineDefs",
			 "Merge several Vertices into one",
			 "Add a LineDef and split Sector",
			 NULL);
   }
   else if (objtype == OBJ_LINEDEFS)
   {
      val = DisplayMenu( x0, y0, ((x0 == -1) ? "Misc. Operations" : NULL),
			 "Find first free tag number",
			 msg,
			 "Split LineDef (add new Vertex)",
			 "Split LineDefs and Sector",
                         "Delete LineDefs and join Sectors",
			 "Flip LineDef",
			 "Swap SideDefs",
			 "Align textures (Y offset)",
			 "Align textures (X offset)",
			 NULL);
   }
   else if (objtype == OBJ_SECTORS)
   {
      val = DisplayMenu( x0, y0, ((x0 == -1) ? "Misc. Operations" : NULL),
			 "Find first free tag number",
			 msg,
			 "Make door from Sector",
			 "Make lift from Sector",
			 "Distribute Sector floor heights",
			 "Distribute Sector ceiling heights",
			 NULL);
   }
   else
   {
      val = DisplayMenu( x0, y0, ((x0 == -1) ? "Misc. Operations" : NULL),
			 "Find first free tag number",
			 msg,
			 NULL);
   }
   if (val > 1 && *list == NULL)
   {
      Beep();
      sprintf( msg, "You must select at least one %s", GetObjectTypeName( objtype));
      Notify( -1, -1, msg, NULL);
      return;
   }
   switch (val)
   {
   case 1:
      sprintf( msg, "First free tag number: %d", FindFreeTag());
      Notify( -1, -1, msg, NULL);
      break;
   case 2:
      if ((objtype == OBJ_THINGS || objtype == OBJ_VERTEXES) && (*list)->next == NULL)
      {
	 Beep();
	 sprintf( msg, "You must select more than one %s", GetObjectTypeName( objtype));
	 Notify( -1, -1, msg, NULL);
	 return;
      }
      angle = 0;
      scale = 100;
      if (Input2Numbers( -1, -1, "rotation angle (ø)", "scale (%)", 360, 1000, &angle, &scale))
	 RotateAndScaleObjects( objtype, *list, (double) angle * 0.0174533, (double) scale * 0.01);
      break;
   case 3:
      if (objtype == OBJ_VERTEXES)
      {
	 DeleteVerticesJoinLineDefs( *list);
	 ForgetSelection( list);
      }
      else if (objtype == OBJ_LINEDEFS)
      {
	 SplitLineDefs( *list);
      }
      else if (objtype == OBJ_SECTORS)
      {
	 if ((*list)->next != NULL)
	 {
	    Beep();
	    Notify( -1, -1, "You must select exactly one Sector", NULL);
	 }
	 else
	 {
	    MakeDoorFromSector( (*list)->objnum);
	 }
      }
      break;
   case 4:
      if (objtype == OBJ_VERTEXES)
      {
	 MergeVertices( list);
      }
      else if (objtype == OBJ_LINEDEFS)
      {
	 if ((*list)->next == NULL || (*list)->next->next != NULL)
	 {
	    Beep();
	    Notify( -1, -1, "You must select exactly two LineDefs", NULL);
	 }
	 else
	 {
	    SplitLineDefsAndSector( (*list)->objnum, (*list)->next->objnum);
	    ForgetSelection( list);
	 }
      }
      else if (objtype == OBJ_SECTORS)
      {
	 if ((*list)->next != NULL)
	 {
	    Beep();
	    Notify( -1, -1, "You must select exactly one Sector", NULL);
	 }
	 else
	 {
	    MakeLiftFromSector( (*list)->objnum);
	 }
      }
      break;
   case 5:
      if (objtype == OBJ_VERTEXES)
      {
	 if ((*list)->next == NULL || (*list)->next->next != NULL)
	 {
	    Beep();
	    Notify( -1, -1, "You must select exactly two Vertices", NULL);
	 }
	 else
	 {
	    SplitSector( (*list)->objnum, (*list)->next->objnum);
	    ForgetSelection( list);
	 }
      }
      else if (objtype == OBJ_LINEDEFS)
      {
         DeleteLineDefsJoinSectors( list);
      }
      else if (objtype == OBJ_SECTORS)
      {
	 if ((*list)->next == NULL || (*list)->next->next == NULL)
	 {
	    Beep();
	    Notify( -1, -1, "You must select three or more Sectors", NULL);
	 }
	 else
	 {
	    DistributeSectorFloors( *list);
	 }
      }
      break;
   case 6:
      if (objtype == OBJ_LINEDEFS)
      {
	 FlipLineDefs( *list, TRUE);
      }
      else if (objtype == OBJ_SECTORS)
      {
	 if ((*list)->next == NULL || (*list)->next->next == NULL)
	 {
	    Beep();
	    Notify( -1, -1, "You must select three or more Sectors", NULL);
	 }
	 else
	 {
	    DistributeSectorCeilings( *list);
	 }
      }
      break;
   case 7:
      if (objtype == OBJ_LINEDEFS)
      {
	 if (Expert || Confirm( -1, -1, "Warning: the Sector references are also swapped", "You may get strange results if you don't know what you are doing..."))
	    FlipLineDefs( *list, FALSE);
      }
      break;
   case 8:
      if (objtype == OBJ_LINEDEFS)
      {
	 SelPtr sdlist, cur;

	 /* select all SideDefs */
	 ObjectsNeeded( OBJ_LINEDEFS);
	 sdlist = NULL;
	 for (cur = *list; cur; cur = cur->next)
	 {
	    if (LineDefs[ cur->objnum].sidedef1 >= 0)
	       SelectObject( &sdlist, LineDefs[ cur->objnum].sidedef1);
	    if (LineDefs[ cur->objnum].sidedef2 >= 0)
	       SelectObject( &sdlist, LineDefs[ cur->objnum].sidedef2);
	 }
	 /* align the textures along the Y axis (height) */
	 AlignTexturesY( &sdlist);
      }
   case 9:
      if (objtype == OBJ_LINEDEFS)
      {
	 SelPtr sdlist, cur;

	 /* select all SideDefs */
	 ObjectsNeeded( OBJ_LINEDEFS,0);
	 sdlist = NULL;
	 for (cur = *list; cur; cur = cur->next)
	 {
	    if (LineDefs[ cur->objnum].sidedef1 >= 0)
	       SelectObject( &sdlist, LineDefs[ cur->objnum].sidedef1);
	    if (LineDefs[ cur->objnum].sidedef2 >= 0)
	       SelectObject( &sdlist, LineDefs[ cur->objnum].sidedef2);
	 }
	 /* align the textures along the X axis (width) */
	 AlignTexturesX( &sdlist);
      }
      break;
   }
}



/*
   display a "Preferences" menu (change default textures, etc.)
*/

void Preferences( short x0, short y0)
{
   char   *menustr[ 30];
   short   dummy[ 30];
   short   n, val;
   char    texname[ 9];

   if (x0 < 0)
      x0 = (ScrMaxX - 50 * 8 - 19) / 2;
   if (y0 < 0)
      y0 = (ScrMaxY - 5 * 10 - 28) / 2;
   for (n = 0; n < 8; n++)
      menustr[ n] = GetMemory( 80);
   sprintf( menustr[ 7], "Preferences");
   sprintf( menustr[ 0], "Change default wall texture    (Current: %s)", DefaultWallTexture);
   sprintf( menustr[ 1], "Change default \"upper\" texture (Current: %s)", DefaultUpperTexture);
   sprintf( menustr[ 2], "Change default \"lower\" texture (Current: %s)", DefaultLowerTexture);
   sprintf( menustr[ 3], "Change default floor texture   (Current: %s)", DefaultFloorTexture);
   sprintf( menustr[ 4], "Change default ceiling texture (Current: %s)", DefaultCeilingTexture);
   sprintf( menustr[ 5], "Change default floor height    (Current: %d)", DefaultFloorHeight);
   sprintf( menustr[ 6], "Change default ceiling height  (Current: %d)", DefaultCeilingHeight);
   val = DisplayMenuArray( x0, y0, menustr[ 7], 7, NULL, menustr, dummy);
   for (n = 0; n < 8; n++)
      FreeMemory( menustr[ n]);
   switch (val)
   {
   case 1:
      strcpy( texname, DefaultWallTexture);
      ChooseWallTexture( x0 + 42, y0 + 34, "Choose a wall texture", NumWTexture, WTexture, texname);
      if (strlen( texname) > 0)
	 strcpy( DefaultWallTexture, texname);
      break;
   case 2:
      strcpy( texname, DefaultUpperTexture);
      ChooseWallTexture( x0 + 42, y0 + 34, "Choose a wall texture", NumWTexture, WTexture, texname);
      if (strlen( texname) > 0)
	 strcpy( DefaultUpperTexture, texname);
      break;
   case 3:
      strcpy( texname, DefaultLowerTexture);
      ChooseWallTexture( x0 + 42, y0 + 34, "Choose a wall texture", NumWTexture, WTexture, texname);
      if (strlen( texname) > 0)
	 strcpy( DefaultLowerTexture, texname);
      break;
   case 4:
      strcpy( texname, DefaultFloorTexture);
      ChooseFloorTexture( x0 + 42, y0 + 44, "Choose a floor texture", NumFTexture, FTexture, texname);
      if (strlen( texname) > 0)
	 strcpy( DefaultFloorTexture, texname);
      break;
   case 5:
      strcpy( texname, DefaultCeilingTexture);
      ChooseFloorTexture( x0 + 42, y0 + 54, "Choose a ceiling texture", NumFTexture, FTexture, texname);
      if (strlen( texname) > 0)
	 strcpy( DefaultCeilingTexture, texname);
      break;
   case 6:
      val = InputIntegerValue( x0 + 42, y0 + 64, -512, 511, DefaultFloorHeight);
      if (val >= -512)
	 DefaultFloorHeight = val;
      break;
   case 7:
      val = InputIntegerValue( x0 + 42, y0 + 74, -512, 511, DefaultCeilingHeight);
      if (val >= -512)
	 DefaultCeilingHeight = val;
      break;
   }
}


/* end of file */
