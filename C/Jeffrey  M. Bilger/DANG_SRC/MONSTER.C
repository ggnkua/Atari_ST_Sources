/* Mon june 29,1992 
   This module sets up the monster array   */

#include<globals2.h>


assign_monsters()
{
   strcpy(monsters[0].name, "Troll(s)");
   monsters[0].ac   = 10;
   monsters[0].hd   = 1;
   monsters[0].hp   = 5;
   monsters[0].weapon = 1;
   monsters[0].spell  = 0;
   monsters[0].lvl    = 1;

  strcpy(monsters[1].name, "Bandit(s)");
   monsters[1].ac   = 10;
   monsters[1].hd   = 1;
   monsters[1].hp   = 7;
   monsters[1].weapon = 1;
   monsters[1].spell  = 0;
   monsters[1].lvl    = 1;

  strcpy(monsters[2].name, "Ghoul(s)");
   monsters[2].ac   = 10;
   monsters[2].hd   = 1;
   monsters[2].hp   = 7;
   monsters[2].weapon = 1;
   monsters[2].spell  = 0;
   monsters[2].lvl    = 1;

  strcpy(monsters[3].name, "Goblin(s)");
   monsters[3].ac   = 10;
   monsters[3].hd   = 1;
   monsters[3].hp   = 8;
   monsters[3].weapon = 1;
   monsters[3].spell  = 0;
   monsters[3].lvl    = 1;

   strcpy(monsters[4].name, "Zombie(s)");
   monsters[4].ac   = 10;
   monsters[4].hd   = 1;
   monsters[4].hp   = 5;
   monsters[4].weapon = 1;
   monsters[4].spell  = 0;
   monsters[4].lvl    = 1;

 strcpy(monsters[5].name, "Hobgoblin(s)");
   monsters[5].ac   = 10;
   monsters[5].hd   = 1;
   monsters[5].hp   = 7;
   monsters[5].weapon = 2;
   monsters[5].spell  = 0;
   monsters[5].lvl    = 1;

  strcpy(monsters[6].name, "Orc(s)");
   monsters[6].ac   = 10;
   monsters[6].hd   = 2;
   monsters[6].hp   = 8;
   monsters[6].weapon = 2;
   monsters[6].spell  = 0;
   monsters[6].lvl    = 1;

  strcpy(monsters[7].name, "Merchant(s)");
   monsters[7].ac   = 10;
   monsters[7].hd   = 1;
   monsters[7].hp   = 10;
   monsters[7].weapon = 1;
   monsters[7].spell  = 0;
   monsters[7].lvl    = 2;
 

   strcpy(monsters[8].name, "Courier(s)");
   monsters[8].ac   = 9;
   monsters[8].hd   = 1;
   monsters[8].hp   = 11;
   monsters[8].weapon = 2;
   monsters[8].spell  = 0;
   monsters[8].lvl    = 2;

  strcpy(monsters[9].name, "Alcolytye(s)");
   monsters[9].ac   = 8;
   monsters[9].hd   = 1;
   monsters[9].hp   = 12;
   monsters[9].weapon = 2;
   monsters[9].spell  = 1;
   monsters[9].lvl    = 2;

  strcpy(monsters[10].name, "Apprentice(s)");
   monsters[10].ac   = 9;
   monsters[10].hd   = 2;
   monsters[10].hp   = 10;
   monsters[10].weapon = 2;
   monsters[10].spell  = 0;
   monsters[10].lvl    = 2;

  strcpy(monsters[11].name, "Kobold(s)");
   monsters[11].ac   = 10;
   monsters[11].hd   = 2;
   monsters[11].hp   = 14;
   monsters[11].weapon = 2;
   monsters[11].spell  = 0;
   monsters[11].lvl    = 2;

   strcpy(monsters[12].name, "Doppleganger(s)");
   monsters[12].ac   = 8;
   monsters[12].hd   = 2;
   monsters[12].hp   = 11;
   monsters[12].weapon = 2;
   monsters[12].spell  = 1;
   monsters[12].lvl    = 2;

  strcpy(monsters[13].name, "Thief(s)");
   monsters[13].ac   = 8;
   monsters[13].hd   = 2;
   monsters[13].hp   = 8;
   monsters[13].weapon = 2;
   monsters[13].spell  = 0;
   monsters[13].lvl    = 2;

  strcpy(monsters[14].name, "Wight(s)");
   monsters[14].ac   = 8;
   monsters[14].hd   = 3;
   monsters[14].hp   = 6;
   monsters[14].weapon = 3;
   monsters[14].spell  = 3;
   monsters[14].lvl    = 2;

  strcpy(monsters[15].name, "Dwarf(s)");
   monsters[15].ac   = 9;
   monsters[15].hd   = 2;
   monsters[15].hp   = 15;
   monsters[15].weapon = 1;
   monsters[15].spell  = 0;
   monsters[15].lvl    = 2;


   strcpy(monsters[16].name, "Commoner(s)");
   monsters[16].ac   = 10;
   monsters[16].hd   = 1;
   monsters[16].hp   = 10;
   monsters[16].weapon = 1;
   monsters[16].spell  = 0;
   monsters[16].lvl    = 2;

  strcpy(monsters[17].name, "Shadow(s)");
   monsters[17].ac   = 7;
   monsters[17].hd   = 3;
   monsters[17].hp   = 7;
   monsters[17].weapon = 2;
   monsters[17].spell  = 1;
   monsters[17].lvl    = 2;

  strcpy(monsters[18].name, "Gelatinous Cube(s)");
   monsters[18].ac   = 9;
   monsters[18].hd   = 1;
   monsters[18].hp   = 6;
   monsters[18].weapon = 3;
   monsters[18].spell  = 0;
   monsters[18].lvl    = 2;

  strcpy(monsters[19].name, "Wererat(s)");
   monsters[19].ac   = 9;
   monsters[19].hd   = 3;
   monsters[19].hp   = 15;
   monsters[19].weapon = 1;
   monsters[19].spell  = 0;
   monsters[19].lvl    = 2;

   strcpy(monsters[20].name, "Ettin(s)");
   monsters[20].ac   = 8;
   monsters[20].hd   = 2;
   monsters[20].hp   = 19;
   monsters[20].weapon = 3;
   monsters[20].spell  = 0;
   monsters[20].lvl    = 2;

  strcpy(monsters[21].name, "Gazer(s)");
   monsters[21].ac   = 8;
   monsters[21].hd   = 3;
   monsters[21].hp   = 21;
   monsters[21].weapon = 3;
   monsters[21].spell  = 2;
   monsters[21].lvl    = 3;

  strcpy(monsters[22].name, "Headless(s)");
   monsters[22].ac   = 8;
   monsters[22].hd   = 3;
   monsters[22].hp   = 22;
   monsters[22].weapon = 2;
   monsters[22].spell  = 0;
   monsters[22].lvl    = 3;

  strcpy(monsters[23].name, "Reaper(s)");
   monsters[23].ac   = 8;
   monsters[23].hd   = 3;
   monsters[23].hp   = 25;
   monsters[23].weapon = 4;
   monsters[23].spell  = 3;
   monsters[23].lvl    = 3;


   strcpy(monsters[24].name, "Ghost(s)");
   monsters[24].ac   = 6;
   monsters[24].hd   = 3;
   monsters[24].hp   = 9;
   monsters[24].weapon = 2;
   monsters[24].spell  = 3;
   monsters[24].lvl    = 3;

  strcpy(monsters[25].name, "City Guard(s)");
   monsters[25].ac   = 9;
   monsters[25].hd   = 3;
   monsters[25].hp   = 27;
   monsters[25].weapon = 4;
   monsters[25].spell  = 0;
   monsters[25].lvl    = 3;

  strcpy(monsters[26].name, "Gargoyle(s)");
   monsters[26].ac   = 8;
   monsters[26].hd   = 3;
   monsters[26].hp   = 26;
   monsters[26].weapon = 5;
   monsters[26].spell  = 1;
   monsters[26].lvl    = 3;

  strcpy(monsters[27].name, "Fighter(s)");
   monsters[27].ac   = 7;
   monsters[27].hd   = 2;
   monsters[27].hp   = 28;
   monsters[27].weapon = 6;
   monsters[27].spell  = 0;
   monsters[27].lvl    = 3;

  strcpy(monsters[28].name, "Wizard(s)");
   monsters[28].ac   = 9;
   monsters[28].hd   = 2;
   monsters[28].hp   = 29;
   monsters[28].weapon = 1;
   monsters[28].spell  = 8;
   monsters[28].lvl    = 4;

  strcpy(monsters[29].name, "Master Thief(s)");
   monsters[29].ac   = 6;
   monsters[29].hd   = 2;
   monsters[29].hp   = 26;
   monsters[29].weapon = 5;
   monsters[29].spell  = 0;
   monsters[29].lvl    = 4;

  strcpy(monsters[30].name, "Thoul(s)");
   monsters[30].ac   = 6;
   monsters[30].hd   = 2;
   monsters[30].hp   = 28;
   monsters[30].weapon = 6;
   monsters[30].spell  = 2;
   monsters[30].lvl    = 4;

  strcpy(monsters[31].name, "Palace Guard(s)");
   monsters[31].ac   = 7;
   monsters[31].hd   = 3;
   monsters[31].hp   = 31;
   monsters[31].weapon = 7;
   monsters[31].spell  = 0;
   monsters[31].lvl    = 4;
 

   strcpy(monsters[32].name, "Master Wizard(s)");
   monsters[32].ac   = 7;
   monsters[32].hd   = 3;
   monsters[32].hp   = 31;
   monsters[32].weapon = 1;
   monsters[32].spell  = 12;
   monsters[32].lvl    = 4;

  strcpy(monsters[33].name, "Guild Master(s)");
   monsters[33].ac   = 7;
   monsters[33].hd   = 4;
   monsters[33].hp   = 32;
   monsters[33].weapon = 7;
   monsters[33].spell  = 6;
   monsters[33].lvl    = 4;

  strcpy(monsters[34].name, "Lesser Demon(s)");
   monsters[34].ac   = 6;
   monsters[34].hd   = 4;
   monsters[34].hp   = 37;
   monsters[34].weapon = 9;
   monsters[34].spell  = 9;
   monsters[34].lvl    = 5;

  strcpy(monsters[35].name, "Armoured Worm(s)");
   monsters[35].ac   = 7;
   monsters[35].hd   = 4;
   monsters[35].hp   = 34;
   monsters[35].weapon = 10;
   monsters[35].spell  = 0;
   monsters[35].lvl    = 5;

   strcpy(monsters[36].name, "Wyern(s)");
   monsters[36].ac   = 7;
   monsters[36].hd   = 4;
   monsters[36].hp   = 37;
   monsters[36].weapon = 11;
   monsters[36].spell  = 2;
   monsters[36].lvl    = 5;

  strcpy(monsters[37].name, "White Dragon(s)");
   monsters[37].ac   = 7;
   monsters[37].hd   = 4;
   monsters[37].hp   = 40;
   monsters[37].weapon = 13;
   monsters[37].spell  = 0;
   monsters[37].lvl    = 5;

  strcpy(monsters[38].name, "Green Dragon(s)");
   monsters[38].ac   = 7;
   monsters[38].hd   = 4;
   monsters[38].hp   = 40;
   monsters[38].weapon = 13;
   monsters[38].spell  = 2;
   monsters[38].lvl    = 5;

  strcpy(monsters[39].name, "Red Dragon(s)");
   monsters[39].ac   = 7;
   monsters[39].hd   = 4;
   monsters[39].hp   = 41;
   monsters[39].weapon = 10;
   monsters[39].spell  = 8;
   monsters[39].lvl    = 5;


   strcpy(monsters[40].name, "Hell Fiend(s)");
   monsters[40].ac   = 5;
   monsters[40].hd   = 4;
   monsters[40].hp   = 49;
   monsters[40].weapon = 15;
   monsters[40].spell  = 10;
   monsters[40].lvl    = 6;

  strcpy(monsters[41].name, "Minds Eye(s)");
   monsters[41].ac   = 5;
   monsters[41].hd   = 4;
   monsters[41].hp   = 50;
   monsters[41].weapon = 2;
   monsters[41].spell  = 20;
   monsters[41].lvl    = 6;

  strcpy(monsters[42].name, "Dragon Lord(s)");
   monsters[42].ac   = 5;
   monsters[42].hd   = 5;
   monsters[42].hp   = 60;
   monsters[42].weapon = 20;
   monsters[42].spell  = 10;
   monsters[42].lvl    = 6;

  strcpy(monsters[43].name, "Damemon King(s)");
   monsters[43].ac   = 4;
   monsters[43].hd   = 5;
   monsters[43].hp   = 55;
   monsters[43].weapon = 20;
   monsters[43].spell  = 9;
   monsters[43].lvl    = 6;

   strcpy(monsters[44].name, "Everman(s)");
   monsters[44].ac   = 6;
   monsters[44].hd   = 5;
   monsters[44].hp   = 100;
   monsters[44].weapon = 6;
   monsters[44].spell  = 0;
   monsters[44].lvl    = 7;

  strcpy(monsters[45].name, "Spark(s)");
   monsters[45].ac   = 5;
   monsters[45].hd   = 5;
   monsters[45].hp   = 69;
   monsters[45].weapon = 10;
   monsters[45].spell  = 2;
   monsters[45].lvl    = 7;

  strcpy(monsters[46].name, "Fighter Lord(s)");
   monsters[46].ac   = 6;
   monsters[46].hd   = 6;
   monsters[46].hp   = 80;
   monsters[46].weapon = 25;
   monsters[46].spell  = 0;
   monsters[46].lvl    = 7;

  strcpy(monsters[47].name, "Demon Lord(s)");
   monsters[47].ac   = 5;
   monsters[47].hd   = 6;
   monsters[47].hp   = 99;
   monsters[47].weapon = 19;
   monsters[47].spell  = 19;
   monsters[47].lvl    = 8;


  strcpy(monsters[48].name, "Elemental(s)");
   monsters[48].ac   = 4;
   monsters[48].hd   = 7;
   monsters[48].hp   = 110;
   monsters[48].weapon = 20;
   monsters[48].spell  = 10;
   monsters[48].lvl    = 9;


  strcpy(monsters[49].name, "Spirit-Walker(s)");
   monsters[49].ac   = 2;
   monsters[49].hd   = 8;
   monsters[49].hp   = 125;
   monsters[49].weapon = 22;
   monsters[49].spell  = 29;
   monsters[49].lvl    = 9;


  strcpy(monsters[50].name, "Mordrin");
   monsters[50].ac   = 1;
   monsters[50].hd   = 10;
   monsters[50].hp   = 250;
   monsters[50].weapon = 30;
   monsters[50].spell  = 250;
   monsters[50].lvl    = 10;
}
