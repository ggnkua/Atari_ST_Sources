/*
   Doom Editor Utility, by Brendon Wyber and Rapha‰l Quinet.

   If you use any part of this code in one of your programs,
   please make it clear that you borrowed it from here...

   NAMES.C - Object name and type routines.
*/

/* the includes */
#include "deu.h"


/*
   get the name of an object type
*/
char *GetObjectTypeName( short objtype)
{
   switch (objtype)
   {
   case OBJ_THINGS:
      return "Thing";
   case OBJ_LINEDEFS:
      return "LineDef";
   case OBJ_SIDEDEFS:
      return "SideDef";
   case OBJ_VERTEXES:
      return "Vertex";
   case OBJ_SEGS:
      return "Segment";
   case OBJ_SSECTORS:
      return "SSector";
   case OBJ_NODES:
      return "Node";
   case OBJ_SECTORS:
      return "Sector";
   case OBJ_REJECT:
      return "Reject";
   case OBJ_BLOCKMAP:
      return "Blockmap";
   }
   return "< Bug! >";
}



/*
   what are we editing?
*/
char *GetEditModeName( short objtype)
{
   switch (objtype)
   {
   case OBJ_THINGS:
      return "Things";
   case OBJ_LINEDEFS:
   case OBJ_SIDEDEFS:
      return "LineDefs & SideDefs";
   case OBJ_VERTEXES:
      return "Vertices";
   case OBJ_SEGS:
      return "Segments";
   case OBJ_SSECTORS:
      return "Seg-Sectors";
   case OBJ_NODES:
      return "Nodes";
   case OBJ_SECTORS:
      return "Sectors";
   }
   return "< Bug! >";
}



/*
   get a short (2 + 13 char.) description of the type of a linedef
*/

char *GetLineDefTypeName( short type)
{
   switch (type)
   {
   case 0:
      return "-- Normal";
   case 1:
      return "DR Door";
   case 2:
      return "W1 Open door (O)";
   case 3:
      return "W1 Close door";
   case 4:
      return "W1 Open door";
   case 5:
      return "W1 Raise floor?C"; /* highest floor ? */
   case 6:
      return "W1 Fast crushing";
   case 7:
      return "S1 Raise stairs";
   case 8:
      return "W1 Raise stairs";
   case 9:
      return "S1 Lower+neigh.T";
   case 10:
      return "W1 Lower lift";
   case 11:
      return "S- End level";
   case 12:
      return "W1 Lights max. N";
   case 13:
      return "W1 Lights on!";
   case 14:
      return "S1 Raise floor>N";
   case 15:
      return "S1 Raise flr32 T";
   case 16:
      return "W1 Close door 30";
   case 17:
      return "W? Blink light";
   case 18:
      return "S1 Raise floor N";
   case 19:
      return "W1 Lower floor N";
   case 20:
      return "S1 Raise floor T";
   case 21:
      return "S1 Lower floor<C";
   case 22:
      return "W1 Raise floor T";
   case 23:
      return "S1 Lower floor<?";
   case 24:
      return "G1 Raise floor C";
   case 25:
      return "W1 Crushing ceil";
   case 26:
      return "DR Blue door";
   case 27:
      return "DR Yellow door";
   case 28:
      return "DR Red door";
   case 29:
      return "S1 Open door";
   case 30:
      return "W1 Raise floor>?";
   case 31:
      return "D1 Door (stay O)";
   case 32:
      return "D1 Blue door O";
   case 33:
      return "D1 Red door O";
   case 34:
      return "D1 Yellow door O";
   case 35:
      return "W1 Lights out!";
   case 36:
      return "W1 Lower floor>N";
   case 37:
      return "W1 Lower floor T";
   case 38:
      return "W1 Lower floor";
   case 39:
      return "W1 Teleport";
   case 40:
      return "W1 Raise ceiling";
   case 41:
      return "S1 Lower ceiling";
   case 42:
      return "SR Close door";
   case 43:
      return "SR Lower ceiling";
   case 44:
      return "W1 Lower ceil. >";
   case 45:
      return "SR Raise floor N";
   case 46:
      return "G1 Shoot to open";
   case 47:
      return "G1 Raise floor T";
   case 48:
      return "-- Animated wall";
   case 49:
      return "S1 Lower ceil. >";
   case 50:
      return "S1 Open door (O)";
   case 51:
      return "S- Secret level";
   case 52:
      return "W- End level";
   case 53:
      return "W1 Moving floor";
   case 54:
      return "W1 Stop Moving f";
   case 55:
      return "S1 Raise floor<C";
   case 56:
      return "W1 Raise floor<C";
   case 57:
      return "W1 Stop crushing";
   case 58:
      return "W1 Raise floor32";
   case 59:
      return "W1 Raise floor>T";
   case 60:
      return "SR Lower floor N";
   case 61:
      return "SR Open door (O)";
   case 62:
      return "SR Lower lift";
   case 63:
      return "SR Open door";
   case 64:
      return "SR Raise floor C";
   case 65:
      return "SR Raise floor<C";
   case 66:
      return "SR Raise flr16 T";
   case 67:
      return "SR Raise flr32 T";
   case 68:
      return "S? Lower floor T";
   case 69:
      return "SR Raise floor N";
   case 70:
      return "SR Lower floor>N";
   case 71:
      return "S1 Lower floor>N";
   case 73:
      return "WR Crushing ceil";
   case 74:
      return "WR Stop crushing";
   case 75:
      return "WR Close door";
   case 76:
      return "WR Close door 30";
   case 77:
      return "WR Fast crushing";
   /* 78 */
   case 79:
      return "WR Lights out!";
   case 80:
      return "WR Lights max. N";
   case 81:
      return "WR Lights on!";
   case 82:
      return "WR Lower floor N";
   case 83:
      return "WR Lower fl.maxN";
   case 84:
      return "WR Lower fl.minN";
   /* 85 */
   case 86:
      return "WR Open door (O)";
   case 87:
      return "WR Moving floor";
   case 88:
      return "WR Lower lift";
   case 89:
      return "WR Stop moving f";
   case 90:
      return "WR Open door";
   case 91:
      return "WR Raise floor C";
   case 92:
      return "WR Raise floor24";
   case 93:
      return "WR Raise flr.24T";
   case 94:
      return "WR Raise floor<C";
   case 95:
      return "W1 Raise floor T";
   case 96:
      return "WR Raise floor72";
   case 97:
      return "WR Teleport";
   case 98:
      return "WR Lower floor >";
   /* 99 100 */
   case 101:
      return "S1 Raise floor C";
   case 102:
      return "S? Lower floor";
   case 103:
      return "S1 Open Door (O)";
   case 104:
      return "W1 Lights down N";
   }
   return "?? UNKNOWN";
}



/*
   get a long description of the type of a linedef
*/

char *GetLineDefTypeLongName( short type)
{
   switch (type)
   {
   case 0:
      return "-- Normal";
   case 1:
      return "DR Open door (closes after 6 seconds)";
   case 2:
      return "W1 Open door (stays open)";
   case 3:
      return "W1 Close door";
   case 4:
      return "W1 Open door (closes after 6 seconds)";
   case 5:
      return "W1 Raise floor to match Ne. ceiling/highest floor ?";
   case 6:
      return "W1 Start crushing ceiling (Fast)";
   case 7:
      return "S1 Raise stairs (several sectors 0/999)";
   case 8:
      return "W1 Raise stairs (several sectors 0/999)";
   case 9:
      return "S1 Lower floor, raise Ne. floor & match outer texture";
   case 10:
      return "W1 Lower lift (rises after 3 seconds)";
   case 11:
      return "S- End level, go to next level";
   case 12:
      return "W1 Light level goes to maximum Ne. light level";
   case 13:
      return "W1 Light level goes to 255";
   case 14:
      return "S1 Raise floor to 64 above Ne. floor";
   case 15:
      return "S1 Raise floor up 32 and match Ne. texture and type";
   case 16:
      return "W1 Close door for 30 seconds";
   case 17:
      return "W? Start blinking lights";
   case 18:
      return "S1 Raise floor to match Ne. floor";
   case 19:
      return "W1 Lower floor to match Ne. floor";
   case 20:
      return "S1 Raise floor to match Ne. floor, texture and type";
   case 21:
      return "S1 Lower floor for 3 seconds, then raise up to Ne. ceiling";
   case 22:
      return "W1 Raise floor to match Ne. floor, texture and type";
   case 23:
      return "S1 Lower floor to match lowest Ne. floor ?";
   case 24:
      return "G1 Raise floor to match Ne. ceiling";
   case 25:
      return "W1 Start crushing ceiling (Slow)";
   case 26:
      return "DR Open door (closes after 6 seconds), Blue key";
   case 27:
      return "DR Open door (closes after 6 seconds), Yellow key";
   case 28:
      return "DR Open door (closes after 6 seconds), Red key";
   case 29:
      return "S1 Open door (closes after 6 seconds)";
   case 30:
      return "W1 Raise floor to 100-128 above Ne. floor ?";
   case 31:
      return "D1 Open door (stays open)";
   case 32:
      return "D1 Open door (stays open), Blue key";
   case 33:
      return "D1 Open door (stays open), Red key";
   case 34:
      return "D1 Open door (stays open), Yellow key";
   case 35:
      return "W1 Light level goes to 0";
   case 36:
      return "W1 Lower floor to 8 above Ne. floor";
   case 37:
      return "W1 Lower floor to match Ne. floor, texture and type";
   case 38:
      return "W1 Lower floor to match Ne. floor ?";
   case 39:
      return "W1 Teleport to another sector";
   case 40:
      return "W1 Raise ceiling to match Ne. ceiling";
   case 41:
      return "S1 Lower ceiling to floor";
   case 42:
      return "SR Close door";
   case 43:
      return "SR Lower ceiling to floor";
   case 44:
      return "W1 Lower ceiling to 8 above floor";
   case 45:
      return "SR Lower floor to match Ne. floor";
   case 46:
      return "G1 Open door (stays open), when shot";
   case 47:
      return "G1 Raise floor to match Ne. floor, texture and type ?";
   case 48:
      return "-- Animated wall (scrolls horizontally)";
   case 49:
      return "S1 Lower ceiling to 8 above floor";
   case 50:
      return "S1 Open door (stays open) ?";
   case 51:
      return "S- End level, go to secret level";
   case 52:
      return "W- End level, go to next level";
   case 53:
      return "W1 Start moving floor (up/down every 5 seconds)";
   case 54:
      return "W1 Stop moving floor";
   case 55:
      return "S1 Raise floor to 8 below Ne. ceiling";
   case 56:
      return "W1 Raise floor to 8 below Ne. ceiling";
   case 57:
      return "W1 Stop crushing ceiling";
   case 58:
      return "W1 Raise floor up 32";
   case 59:
      return "W1 Raise floor up 8 and match Ne. texture and type";
   case 60:
      return "SR Lower floor to match Ne. floor ?";
   case 61:
      return "SR Open door (stays open)";
   case 62:
      return "SR Lower lift (rises after 3 seconds)";
   case 63:
      return "SR Open door (closes after 6 seconds)";
   case 64:
      return "SR Raise floor to match Ne. ceiling";
   case 65:
      return "SR Raise floor to 8 below Ne. ceiling";
   case 66:
      return "SR Raise floor up 16 and match Ne. texture and type";
   case 67:
      return "SR Raise floor up 32 and match Ne. texture and type";
   case 68:
      return "S? Lower floor to match Ne. floor, texture and type";
   case 69:
      return "SR Raise floor to match Ne. floor";
   case 70:
      return "SR Lower floor to 8 above Ne. floor";
   case 71:
      return "S1 Lower floor to 8 above Ne. floor";
   case 72:
      return "WR Lower ceiling to 8 above floor";
   case 73:
      return "WR Start crushing ceiling (Slow)";
   case 74:
      return "WR Stop crushing ceiling";
   case 75:
      return "WR Close door";
   case 76:
      return "WR Close door for 30 seconds";
   case 77:
      return "WR Start crushing ceiling (Fast)";
   /* 78 */
   case 79:
      return "WR Light level goes to 0";
   case 80:
      return "WR Light level goes to maximum Ne. light level";
   case 81:
      return "WR Light level goes to 255";
   case 82:
      return "WR Lower floor to match Ne. floor";
   case 83:
      return "WR Lower floor to match Ne. floor ?";
   case 84:
      return "WR Lower floor to match lowest Ne. floor ?";
   /* 85 */
   case 86:
      return "WR Open door (stays open)";
   case 87:
      return "WR Start moving floor (up/down every 5 seconds)";
   case 88:
      return "WR Lower lift (rises after 3 seconds)";
   case 89:
      return "WR Stop moving floor";
   case 90:
      return "WR Open door (closes after 6 seconds)";
   case 91:
      return "WR Raise floor to match Ne. ceiling";
   case 92:
      return "WR Raise floor up 24";
   case 93:
      return "WR Raise floor up 24 and match Ne. texture and type";
   case 94:
      return "WR Raise floor to 8 below Ne. ceiling";
   case 95:
      return "W1 Raise floor to match Ne. floor, texture and type ?";
   case 96:
      return "WR Raise floor up 72";
   case 97:
      return "WR Teleport to another sector";
   case 98:
      return "WR Lower floor to 8 above Ne. floor";
   /* 99 100 */
   case 101:
      return "S1 Raise floor to match Ne. ceiling";
   case 102:
      return "S? Lower floor to match Ne. floor";
   case 103:
      return "S1 Open door (stays open) ?";
   case 104:
      return "W1 Light level goes to minimum Ne. light level";
   }
   return "?? UNKNOWN ?";
}



/*
   get a short description of the flags of a linedef
*/

char *GetLineDefFlagsName( short flags)
{
   static char temp[ 20];

   if (flags & 0x0100)
      strcpy( temp, "Ma"); /* Already on the map */
   else
      strcpy( temp, "-");
   if (flags & 0x80)
      strcat( temp, "In"); /* Invisible on the map */
   else
      strcat( temp, "-");
   if (flags & 0x40)
      strcat( temp, "So"); /* Blocks sound */
   else
      strcat( temp, "-");
   if (flags & 0x20)
      strcat( temp, "Se"); /* Secret (normal on the map) */
   else
      strcat( temp, "-");
   if (flags & 0x10)
      strcat( temp, "Lo"); /* Lower texture offset changed */
   else
      strcat( temp, "-");
   if (flags & 0x08)
      strcat( temp, "Up"); /* Upper texture offset changed */
   else
      strcat( temp, "-");
   if (flags & 0x04)
      strcat( temp, "2S"); /* Two-sided */
   else
      strcat( temp, "-");
   if (flags & 0x02)
      strcat( temp, "Mo"); /* Monsters can't cross this line */
   else
      strcat( temp, "-");
   if (flags & 0x01)
      strcat( temp, "Im"); /* Impassible */
   else
      strcat( temp, "-");
   if (strlen( temp) > 13)
   {
      temp[13] = '|';
      temp[14] = '\0';
   }
   return temp;
}



/*
   get a long description of one linedef flag
*/

char *GetLineDefFlagsLongName( short flags)
{
   if (flags & 0x0100)
      return "Already on the map at startup";
   if (flags & 0x80)
      return "Invisible on the map";
   if (flags & 0x40)
      return "Blocks sound";
   if (flags & 0x20)
      return "Secret (shown as normal on the map)";
   if (flags & 0x10)
      return "Lower texture is \"unpegged\"";
   if (flags & 0x08)
      return "Upper texture is \"unpegged\"";
   if (flags & 0x04)
      return "Two-sided (may be transparent)";
   if (flags & 0x02)
      return "Monsters cannot cross this line";
   if (flags & 0x01)
      return "Impassible";
   return "UNKNOWN";
}



/*
   get a short (13 char.) description of the type of a sector
*/

char *GetSectorTypeName( short type)
{
   switch (type)
   {
   case 0:
      return "Normal";
   case 1:
      return "Blinks random.";
   case 2:
      return "Blinks 0.5 sec";
   case 3:
      return "Blinks 1.0 sec";
   case 4:
      return "-20% & blinks";
   case 5:
      return "-10% health";
   case 7:
      return "-5% health";
   case 8:
      return "Pulsates 2 sec";
   case 9:
      return "Secret";
   case 10:
      return "Unknown ???";
   case 11:
      return "-20% & end lev";
   case 12:
      return "Pulsates";
   case 13:
      return "Blinks .25 sec";
   case 14:
      return "Unknown ???";
   case 16:
      return "-20% health";
   }
   return "DO NOT USE!";
}



/*
   get a long description of the type of a sector
*/

char *GetSectorTypeLongName( short type)
{
   switch (type)
   {
   case 0:
      return "Normal";
   case 1:
      return "Light blinks randomly";
   case 2:
      return "Light blinks every 0.5 second";
   case 3:
      return "Light blinks every second";
   case 4:
      return "-10/20% health and light blinks every 0.5 second";
   case 5:
      return "-5/10% health";
   case 7:
      return "-2/5% health (acid floor)";
   case 8:
      return "Light pulsates every 2 seconds";
   case 9:
      return "Secret (credit if discovered)";
   case 10:
      return "Unknown ??? (ceiling goes down)";
   case 11:
      return "-10/20% health and end level when health <= 10%";
   case 12:
      return "Light smoothly pulsates";
   case 13:
      return "Blinks every 0.25 seconds";
   case 14:
      return "Unknown ???";
   case 16:
      return "-10/20% health";
   }
   return "DO NOT USE!";
}

/* end of file */
