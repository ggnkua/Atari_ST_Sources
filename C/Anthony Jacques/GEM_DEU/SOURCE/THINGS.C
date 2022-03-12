/*
   Doom Editor Utility, by Brendon Wyber and Rapha‰l Quinet.

   You are allowed to use any parts of this code in another program, as
   long as you give credits to the authors in the documentation and in
   the program itself.  Read the file README.1ST for more information.

   This program comes with absolutely no warranty.

   THINGS.C - Thing name and type routines.
*/

/* the includes */
#include "deu.h"
#include "things.h"


/*
   get the colour of a thing
*/

short GetThingColour( short type)
{
   if (Colour2)
   {
      switch( type)
      {
      case THING_PLAYER1:
      case THING_PLAYER2:
      case THING_PLAYER3:
      case THING_PLAYER4:
	 return GREEN;
      case THING_DEATHMATCH:
	 return 10;

      case THING_SARGEANT:
      case THING_TROOPER:
      case THING_IMP:
      case THING_DEMON:
      case THING_SPECTOR:
      case THING_LOSTSOUL:
	 return RED;
      case THING_BARON:
      case THING_CACODEMON:
      case THING_SPIDERBOSS:
      case THING_CYBERDEMON:
	 return 12;

      /* Things you can always pick up */
      case THING_BLUECARD:
      case THING_YELLOWCARD:
      case THING_REDCARD:
      case THING_ARMBONUS1:
      case THING_HLTBONUS1:
	 return MAGENTA;
      case THING_BLUESKULLKEY:
      case THING_YELLOWSKULLKEY:
      case THING_REDSKULLKEY:
      case THING_SOULSPHERE:
      case THING_RADSUIT:
      case THING_MAP:
      case THING_BLURSPHERE:
      case THING_BESERK:
      case THING_INVULN:
      case THING_LITEAMP:
      case THING_BACKPACK:
	 return 13;

      /* Guns */
      case THING_SHOTGUN:
      case THING_CHAINSAW:
      case THING_CHAINGUN:
	 return BLUE;
      case THING_LAUNCHER:
      case THING_PLASMAGUN:
      case THING_BFG9000:
	 return BLUE;

      /* Things you can't always pick up */
      case THING_AMMOCLIP:
      case THING_SHELLS:
      case THING_ROCKET:
      case THING_ENERGYCELL:
      case THING_GREENARMOR:
      case THING_STIMPACK:
	 return CYAN;
      case THING_AMMOBOX:
      case THING_SHELLBOX:
      case THING_ROCKETBOX:
      case THING_ENERGYPACK:
      case THING_BLUEARMOR:
      case THING_MEDKIT:
	 return 11;

      /* Decorations, et al */
      case THING_TECHCOLUMN:
      case THING_TGREENPILLAR:
      case THING_TREDPILLAR:
      case THING_SGREENPILLAR:
      case THING_SREDPILLAR:
      case THING_PILLARHEART:
      case THING_PILLARSKULL:
      case THING_EYEINSYMBOL:
      case THING_GREYTREE:
      case THING_BROWNSTUB:
      case THING_BROWNTREE:
      case THING_LAMP:
      case THING_CANDLE:
      case THING_CANDELABRA:
      case THING_TBLUETORCH:
      case THING_TGREENTORCH:
      case THING_TREDTORCH:
      case THING_SBLUETORCH:
      case THING_SGREENTORCH:
      case THING_SREDTORCH:
      case THING_DEADPLAYER:
      case THING_DEADTROOPER:
      case THING_DEADSARGEANT:
      case THING_DEADIMP:
      case THING_DEADDEMON:
      case THING_DEADCACODEMON:
      case THING_DEADLOSTSOUL:
      case THING_BONES:
      case THING_BONES2:
      case THING_POOLOFBLOOD:
      case THING_SKULLTOPPOLE:
      case THING_HEADSKEWER:
      case THING_PILEOFSKULLS:
      case THING_IMPALEDBODY:
      case THING_IMPALEDBODY2:
      case THING_SKULLSINFLAMES:
      case THING_HANGINGSWAYING:
      case THING_HANGINGARMSOUT:
      case THING_HANGINGONELEG:
      case THING_HANGINGTORSO:
      case THING_HANGINGLEG:
      case THING_HANGINGSWAYING2:
      case THING_HANGINGARMSOUT2:
      case THING_HANGINGONELEG2:
      case THING_HANGINGTORSO2:
      case THING_HANGINGLEG2:
	return 6;
      case THING_BARREL:
      case THING_TELEPORT:
	 return YELLOW;
      }
   }
   else
   {
      switch( type)
      {
      case THING_PLAYER1:
      case THING_PLAYER2:
      case THING_PLAYER3:
      case THING_PLAYER4:
      case THING_DEATHMATCH:
	 return GREEN;
      case THING_SARGEANT:
      case THING_TROOPER:
      case THING_IMP:
      case THING_DEMON:
      case THING_SPECTOR:
      case THING_BARON:
      case THING_LOSTSOUL:
      case THING_CACODEMON:
      case THING_SPIDERBOSS:
      case THING_CYBERDEMON:
	 return 12;
      case THING_BLUECARD:
      case THING_YELLOWCARD:
      case THING_REDCARD:
      case THING_BLUESKULLKEY:
      case THING_YELLOWSKULLKEY:
      case THING_REDSKULLKEY:
      case THING_ARMBONUS1:
      case THING_HLTBONUS1:
      case THING_GREENARMOR:
      case THING_BLUEARMOR:
      case THING_SOULSPHERE:
      case THING_MEDKIT:
      case THING_STIMPACK:
      case THING_RADSUIT:
      case THING_MAP:
      case THING_BLURSPHERE:
      case THING_BESERK:
      case THING_INVULN:
      case THING_LITEAMP:
	 return 10;
      case THING_SHOTGUN:
      case THING_CHAINSAW:
      case THING_CHAINGUN:
      case THING_LAUNCHER:
      case THING_PLASMAGUN:
      case THING_BFG9000:
      case THING_AMMOCLIP:
      case THING_AMMOBOX:
      case THING_SHELLS:
      case THING_SHELLBOX:
      case THING_ROCKET:
      case THING_ROCKETBOX:
      case THING_ENERGYCELL:
      case THING_ENERGYPACK:
      case THING_BACKPACK:
	 return 6;
      }
   }
   return WHITE;
}



/*
   get the name of a thing
*/

char *GetThingName( short type)
{
   static char temp[ 20];

   switch( type)
   {
   /* the players */
   case THING_PLAYER1:
      return "Player 1 Start";
   case THING_PLAYER2:
      return "Player 2 Start";
   case THING_PLAYER3:
      return "Player 3 Start";
   case THING_PLAYER4:
      return "Player 4 Start";
   case THING_DEATHMATCH:
      return "DEATHMATCH Start";

   /* enemies */
   case THING_SARGEANT:
      return "Sargeant";
   case THING_TROOPER:
      return "Trooper";
   case THING_IMP:
      return "Imp";
   case THING_DEMON:
      return "Demon";
   case THING_BARON:
      return "Baron";
   case THING_SPECTOR:
      return "Spector";
   case THING_LOSTSOUL:
      return "Lost Soul";
   case THING_CACODEMON:
      return "Cacodemon";
   case THING_SPIDERBOSS:
      return "Spider Boss";
   case THING_CYBERDEMON:
      return "Cyber Demon";

   /* enhancements */
   case THING_BLUECARD:
      return "Blue KeyCard";
   case THING_YELLOWCARD:
      return "Yellow KeyCard";
   case THING_REDCARD:
      return "Red KeyCard";
   case THING_BLUESKULLKEY:
      return "Blue Skull Key";
   case THING_YELLOWSKULLKEY:
      return "Yellow Skull Key";
   case THING_REDSKULLKEY:
      return "Red Skull Key";
   case THING_ARMBONUS1:
      return "Armour Helmet";
   case THING_HLTBONUS1:
      return "Health Potion";
   case THING_GREENARMOR:
      return "Green Armour";
   case THING_BLUEARMOR:
      return "Blue Armour";
   case THING_SOULSPHERE:
      return "Soul Sphere";
   case THING_MEDKIT:
      return "Medical Kit";
   case THING_STIMPACK:
      return "Stim Pack";
   case THING_RADSUIT:
      return "Radiation Suit";
   case THING_MAP:
      return "Computer Map";
   case THING_BLURSPHERE:
      return "Blur Sphere";
   case THING_BESERK:
      return "Beserk Sphere";
   case THING_INVULN:
      return "Invulnerability";
   case THING_LITEAMP:
      return "Lite Amp. Goggles";

   /* weapons */
   case THING_SHOTGUN:
      return "Shotgun";
   case THING_CHAINSAW:
      return "Chainsaw";
   case THING_CHAINGUN:
      return "Chaingun";
   case THING_LAUNCHER:
      return "Rocket Launcher";
   case THING_PLASMAGUN:
      return "Plasma Gun";
   case THING_BFG9000:
      return "BFG9000";
   case THING_AMMOCLIP:
      return "Ammo Clip";
   case THING_AMMOBOX:
      return "Box of Ammo";
   case THING_SHELLS:
      return "Shells";
   case THING_SHELLBOX:
      return "Box of Shells";
   case THING_ROCKET:
      return "Rocket";
   case THING_ROCKETBOX:
      return "Box of Rockets";
   case THING_ENERGYCELL:
      return "Energy Cell";
   case THING_ENERGYPACK:
      return "Energy Pack";
   case THING_BACKPACK:
      return "Backpack";

   /* decorations */
   case THING_BARREL:
      return "Barrel";
   case THING_TECHCOLUMN:
      return "Technical Column";
   case THING_TGREENPILLAR:
      return "Tall Green Pillar";
   case THING_TREDPILLAR:
      return "Tall Red Pillar";
   case THING_SGREENPILLAR:
      return "Short Green Pillar";
   case THING_SREDPILLAR:
      return "Short Red Pillar";
   case THING_PILLARHEART:
      return "Pillar w/Heart";
   case THING_PILLARSKULL:
      return "Red Pillar w/Skull";
   case THING_EYEINSYMBOL:
      return "Eye in Symbol";
   case THING_GREYTREE:
      return "Grey Tree";
   case THING_BROWNSTUB:
      return "Brown Stub";
   case THING_BROWNTREE:
      return "Tall Brown Tree";

   case THING_LAMP:
      return "Lamp";
   case THING_CANDLE:
      return "Candle";
   case THING_CANDELABRA:
      return "Candelabra";
   case THING_TBLUETORCH:
      return "Tall Blue Torch";
   case THING_TGREENTORCH:
      return "Tall Green Torch";
   case THING_TREDTORCH:
      return "Tall Red Torch";
   case THING_SBLUETORCH:
      return "Short Blue Torch";
   case THING_SGREENTORCH:
      return "Short Green Torch";
   case THING_SREDTORCH:
      return "Short Red Torch";

   case THING_DEADPLAYER:
      return "Dead Player (Green)";
   case THING_DEADTROOPER:
      return "Dead Trooper";
   case THING_DEADSARGEANT:
      return "Dead Sargeant";
   case THING_DEADIMP:
      return "Dead Imp";
   case THING_DEADDEMON:
      return "Dead Demon";
   case THING_DEADCACODEMON:
      return "Dead CacoDemon";
   case THING_DEADLOSTSOUL:
      return "Dead Lost Soul";
   case THING_BONES:
      return "Guts and Bones";
   case THING_BONES2:
      return "Guts and Bones 2";
   case THING_POOLOFBLOOD:
      return "Pool of Blood";
   case THING_SKULLTOPPOLE:
      return "Pole with Skull";
   case THING_HEADSKEWER:
      return "Skewer with Heads";
   case THING_PILEOFSKULLS:
      return "Pile of Skulls";
   case THING_IMPALEDBODY:
      return "Impaled body";
   case THING_IMPALEDBODY2:
      return "Twitching Impaled Body";
   case THING_SKULLSINFLAMES:
      return "Skulls in Flames";

   case THING_HANGINGSWAYING:
      return "Swaying Body";
   case THING_HANGINGARMSOUT:
      return "Hanging Arms Out";
   case THING_HANGINGONELEG:
      return "One-legged Body";
   case THING_HANGINGTORSO:
      return "Hanging Torso";
   case THING_HANGINGLEG:
      return "Hanging Leg";
   case THING_HANGINGSWAYING2:
      return "Swaying Body 2";
   case THING_HANGINGARMSOUT2:
      return "Hanging Arms Out 2";
   case THING_HANGINGONELEG2:
      return "One-legged Body 2";
   case THING_HANGINGTORSO2:
      return "Hanging Torso 2";
   case THING_HANGINGLEG2:
      return "Hanging Leg 2";

   /* teleport */
   case THING_TELEPORT:
      return "Teleport exit";
   }

   /* unknown */
   sprintf( temp, "<UNKNOWN %04d>", type);
   return temp;
}



/*
   get the size of a thing
*/

short GetThingRadius( short type)
{
   switch (type)
   {
   case THING_SPIDERBOSS:
      return 128;
   case THING_CYBERDEMON:
      return 40;
   case THING_BROWNTREE:
      return 32;
   case THING_CACODEMON:
      return 31;
   case THING_DEMON:
   case THING_SPECTOR:
      return 30;
   case THING_BARON:
      return 24;
   case THING_SARGEANT:
   case THING_TROOPER:
   case THING_IMP:
   case THING_BLUECARD:
   case THING_YELLOWCARD:
   case THING_REDCARD:
   case THING_BLUESKULLKEY:
   case THING_YELLOWSKULLKEY:
   case THING_REDSKULLKEY:
   case THING_ARMBONUS1:
   case THING_HLTBONUS1:
   case THING_GREENARMOR:
   case THING_BLUEARMOR:
   case THING_SOULSPHERE:
   case THING_MEDKIT:
   case THING_STIMPACK:
   case THING_RADSUIT:
   case THING_MAP:
   case THING_BLURSPHERE:
   case THING_BESERK:
   case THING_INVULN:
   case THING_LITEAMP:
   case THING_SHOTGUN:
   case THING_CHAINSAW:
   case THING_CHAINGUN:
   case THING_LAUNCHER:
   case THING_PLASMAGUN:
   case THING_BFG9000:
   case THING_AMMOCLIP:
   case THING_AMMOBOX:
   case THING_SHELLS:
   case THING_SHELLBOX:
   case THING_ROCKET:
   case THING_ROCKETBOX:
   case THING_ENERGYCELL:
   case THING_ENERGYPACK:
   case THING_BACKPACK:
      return 20;
   case THING_BARREL:
      return 10;
   default:
      return 16;
   }
}


/*
   get the name of the angle
*/

char *GetAngleName( short angle)
{
   switch (angle)
   {
   case 0:
      return "East";
   case 45:
      return "NorthEast";
   case 90:
      return "North";
   case 135:
      return "NorthWest";
   case 180:
      return "West";
   case 225:
      return "SouthWest";
   case 270:
      return "South";
   case 315:
      return "SouthEast";
   }
   return "<ILLEGAL ANGLE>";
}



/*
   get string of when something will appear
*/

char *GetWhenName( short when)
{
   static char temp[ 40];

   temp[ 0] = '\0';
   if (when & 0x01)
      strcat( temp, "D12 ");
   if (when & 0x02)
      strcat( temp, "D3 ");
   if (when & 0x04)
      strcat( temp, "D45 ");
   if (when & 0x08)
      strcat( temp, "Deaf ");
   if (when & 0x10)
      strcat( temp, "Multi ");
   return temp;
}



/* end of file */
