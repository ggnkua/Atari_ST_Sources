#include <globals2.h>
#include <osbind.h>
#include <stdio.h>
extern int  buffer[];        /* holds the char info for disk loading and saving */
#define max_items 50          /* max weapons */



/** misc routines needed 

  switch_weapon()
  scroller()
  list_user_items()
  special_display()


**/

/**************************************************/
switch_weapon()
{
  char s;
  int var_,hold_num;


  view_backpack();
  v_justified(handle,6,83,"# to equip [X] to exit",184,0,1);
  do
  {
    s = Bconin(2);
  if( s == 'x' || s== 'X' ) return(1);
 }while( (s-'0' < 0 || s-'0' >6) || (user.backpack[s - '0'] == -1));        /* if you dont own it, can sell it! */
  
  var_ = user.backpack[s-'0'];

  hold_num = calc_num();   /* calc. current weapons hit damage and id */ 
                                   /* clear it */
    v_gtext(handle,78,174,"             ");
  strcpy(user.weapon,unique_item[var_].name);  /* copy new weapon */
 
  user.weapon_num = unique_item[var_].points;  /* set weapon hit damage */
  user.backpack[s-'0'] = hold_num; /* place old weapon here */
   
}

calc_num()
{
 int p = -1, found = 0;

  while( p < max_items && !found)  
   {
    p++;
    if( (strcmp(unique_item[p].name,user.weapon)) == 0) /* if found*/
         found = 1;
   
   }

   if( found) return(unique_item[p].points);
   else return(-1);  /* else return 'Empty' */

}

/********************************/
/** list_user_items()
   
    Lists the items the user has.

**/

list_user_items()
{
 char com;
 int picked;
 int offset=6; /* so we can process potions, 1st one is 6..*/

clear_it();

sprintf(string,"0) Food   :%d",user.user_items[0]);
v_gtext(handle,6,11,string);

sprintf(string,"1) Water  :%d",user.user_items[1]);
v_gtext(handle,6,19,string);

sprintf(string,"2) Keys   :%d",user.user_items[2]);
v_gtext(handle,6,27,string);

sprintf(string,"3) Torches:%d",user.user_items[3]);
v_gtext(handle,6,35,string);

sprintf(string,"4) Gems   :%d",user.user_items[4]);
v_gtext(handle,6,43,string);

sprintf(string,"5) Jewels :%d",user.user_items[5]);
v_gtext(handle,6,51,string);
v_gtext(handle,6,67,"# to use or C to ");
v_gtext(handle,6,75,"Continue...      ");
com = Bconin(2);
picked = com-'0';

if( com == 'C' || com == 'c' )
{
v_gtext(handle,6,11,"       POTIONS   ");
v_gtext(handle,6,19,"                 ");
sprintf(string,"0) Healing          :%d",user.user_items[6]);
v_gtext(handle,6,27,string);

sprintf(string,"1) Cure Poison      :%d",user.user_items[7]);
v_gtext(handle,6,35,string);

sprintf(string,"2) Treasure Finding :%d",user.user_items[8]);
v_gtext(handle,6,43,string);

sprintf(string,"3) Fleetness        :%d",user.user_items[9]);
v_gtext(handle,6,51,string);

sprintf(string,"4) Protection       :%d",user.user_items[10]);
v_gtext(handle,6,59,string);

sprintf(string,"5) Strength         :%d",user.user_items[11]);
v_gtext(handle,6,67,string);

sprintf(string,"6) Charm            :%d",user.user_items[12]);
v_gtext(handle,6,75,string);

v_gtext(handle,6,83,"# to use or (E)xit");
com = Bconin(2);
picked = com-'0' + offset;  /* will give a # from 6 to 12..(or above) */
}

clear_it();
if( com != 'E' && com != 'e' )
{
 if(user.user_items[picked] > 0 )
    {
    clear_it();
    if(picked !=4 && picked !=5 && picked != 13 && picked !=14) /* dont use these items up!!! they are not perishable!! */
    user.user_items[picked]--;   /* use it up! */
    /* 4 = gem, 5 = jewel, 13 = timepiece,14=key to gate */
    switch(picked)
     {
      case  0:  if(user.user_items[0]>0) user.hunger_thurst_status[0]--;/*food */
                if(user.hunger_thurst_status[0] < 0) user.hunger_thurst_status[0]=0; 
                v_gtext(handle,204,126,"         ");
                break;   /* food */
      case  1:  if(user.user_items[1]>0) user.hunger_thurst_status[1]--;
                if(user.hunger_thurst_status[1] < 0) user.hunger_thurst_status[1]=0; 
                v_gtext(handle,204,134,"       ");
                break; /* h20 */
      case  2:unlock_door();  break;
      case  3:light_torch();  break;
      case  4:       /* gem */
      case  5:v_gtext(handle,6,11,"You can use that!"); break; /* jewel */
      case  6:    /* potions */
      case  7:
      case  8:
      case  9:
      case  10:
      case  11:
      case  12: open_potion(picked); 
                v_gtext(handle,6,11,"You quaff the potion");break;
      case  13: break;  /* timepiece.. */
      case  14: break;  /* key to wizards gate.. */
     }
    } /* end of use item */
   else v_gtext(handle,6,11,"You dont have any...");
 }  

}
/****************************************************/
/** routines that are called from use user_item
    unlock_door, light_torch,use food,h20,
    open_potion(picked) & check_time
**/
unlock_door()
{}
light_torch()
{}
open_potion( potion )
int potion;
{
 int amount;
 
  
 /* the potions sent range from 6 to 12. 
    potion 6 is heal..etc */
  if(potion == 6) /* if heal.. */
   {
    amount = user.con;
    if (user.hp + amount > user.max_hp) user.hp = user.max_hp;
    else user.hp+=amount;
   }
  if( potion == 7 )
   {   /* not inplememted yet!! cure!! */
   }
  else   /* we get here. we're at potions 8-12 !! */
   {
     potion -=8;  /* get it into range 0 to 4 */
     user.current_spells_active[potion] = 1; /* set it active!! */
   }   

}


/***/
check_for_sound_change()
{
 /* re-play sound if there was sound playing before encounter */
          if(CURRENT_SOUND == 1) Dosound( wind_sound );

          if(CURRENT_SOUND == 4) Dosound( rain_sound );

}

/******/
special_display()
{
 int vert = 27;
 char com;

 clear_it();
 
  v_gtext(handle,6,11,"   ~Special Stats~ ");
  sprintf(string,"Gold:%ld",user.gold);
  v_gtext(handle,6,27,string);
  sprintf(string,"Exp:%ld",user.exp);
  v_gtext(handle,6,35,string);
  v_gtext(handle,6,83,"Press any key");
  com = Bconin(2);
  clear_it();
  v_gtext(handle,6,11," ~Active Spells/Magic~");
  if(user.user_items[17]) {v_gtext(handle,6,vert,"CURSED!!"); vert+=8;}
  if(user.current_spells_active[0]){v_gtext(handle,6,vert,"TREASURE FINDING"); vert+=8;}
  if(user.current_spells_active[1]){v_gtext(handle,6,vert,"FLEETNESS"); vert+=8;}
  if(user.current_spells_active[2]){v_gtext(handle,6,vert,"PROTECTION"); vert+=8;}
  if(user.current_spells_active[3]){v_gtext(handle,6,vert,"STRENGTH"); vert+=8;}
  if(user.current_spells_active[4]){v_gtext(handle,6,vert,"CHARM"); vert+=8;}
  v_gtext(handle,6,83,"Press anykey");
  com = Bconin(2);
  clear_it();
  vert = 27;
  v_gtext(handle,6,11,"   ~Special Items~ ");
  if(user.user_items[13]){v_gtext(handle,6,vert,"Timepiece"); vert +=8;}
  if(user.user_items[14]){v_gtext(handle,6,vert,"Mithril Key"); vert +=8;}
  vert+=8;
  v_gtext(handle,6,vert,"Occupation");
  vert+=8;
  if(user.user_items[17]) v_gtext(handle,6,vert,"Guild Member");
  else v_gtext(handle,6,vert,"Adventurer");
 
 v_gtext(handle,6,83,"Press any key");
 com = Bconin(2);
}


/*****************************/
game_options(temp,scr1,scr2,scr3,scr4,scr5,scr6)
char *temp,*scr1,*scr2,*scr3,*scr4,*scr5,*scr6;
{
 long cli;
 char ddd,disk;
 int mask = 1,catch;

 clear_it();
 
do
{
 v_gtext(handle,6,11,"     Game Options  ");
 v_gtext(handle,6,27,"  1. Save Game ");
 v_gtext(handle,6,35,"  2. Quit Game ");
 v_gtext(handle,6,43,"  3. Sound on/off ");
 v_gtext(handle,6,51,"  4. Credits");
 v_gtext(handle,6,59,"  5. Exit");

 cli = Bconin(2);
 if(cli == 0x20031)  {
do
{
if( (catch=Fopen("char.dat",0)) < 0 )
  {
      v_gtext(handle,6,11,"Please insert Disk 1");
      v_gtext(handle,6,19,"into the current drive");
      v_gtext(handle,6,27,"and press any key.");
      disk = Bconin(2);
       clear_it();
  }
    Fclose(catch);
} while(catch < 0 );


      save_character();
      
      disk = Bconin(2);
do
{
if( (catch=Fopen("appla",0)) < 0 )
  {
      v_gtext(handle,6,27,"Please insert Disk 2");
      v_gtext(handle,6,35,"into the current drive");
      v_gtext(handle,6,43,"and press any key.");
      disk = Bconin(2);
       clear_it();
  }
    Fclose(catch);
} while(catch < 0 );

  }
                                      /* save */ 
   
  if(cli == 0x30032) quit_game(temp,scr1,scr2,scr3,scr4,scr5,scr6);     /* quit */
   
  if(cli == 0x40033)    /* sound on-off */
   {
    if(sound == 1) v_gtext(handle,6,75,"Sound is now OFF");
    else v_gtext(handle,6,75,"Sound is now ON");
    sound ^= mask;   /* xor with mask */ 
  }
  if(cli == 0x50034)
   {
    clear_it();
    v_gtext(handle,6,11,"Concept and Programming");
    v_gtext(handle,6,19," by Jeffrey  M. Bilger ");
    v_gtext(handle,6,27,"  jmb8302@cs.tamu.edu ");
    v_gtext(handle,6,43," Texas A&M University. ");
    v_gtext(handle,6,51,"   12 December 1993    ");
    v_gtext(handle,6,67,"     Hit any key      ");
    ddd = Bconin(2);  
   }
clear_it();
}while(cli != 0x60035);  /* do until exit chosen */

 



}

/**
          **/
save_character()
{
FILE *ofp;
char out,ddd;
int x;

clear_it();
v_gtext(handle,6,11,"  Save a Character");

    v_gtext(handle,6,27,"Are you sure? [y/n]");
  
   do
    {
    ddd = Bconin(2);  
    }while( (ddd !='Y' && ddd !='y') && (ddd !='N' && ddd !='n') );

  if( ddd == 'Y' || ddd == 'y')
  {
     savechar(buffer);
     v_gtext(handle,6,67,"Character saved");
   }
}
/******************************/


quit_game(temp,scr1,scr2,scr3,scr4,scr5,scr6)
char *temp,*scr1,*scr2,*scr3,*scr4,*scr5,*scr6;
{
char ddd;
int on();
int qr;

clear_it();
    	  v_gtext(handle,6,19,"Quit......");
    v_gtext(handle,6,27,"Did you SAVE yet?");
    v_gtext(handle,6,35,"Really want to quit? ");
    v_gtext(handle,6,43,"       [y/n]");
  
   do
    {
    ddd = Bconin(2);  
    }while( (ddd !='Y' && ddd !='y') && (ddd !='N' && ddd !='n') );

   if( ddd == 'Y' || ddd == 'y' ) 
     {
     free(temp); free(scr1); free(scr2); free(scr3); free(scr4);
     free(scr5); free(scr6);
    cool_effect();
    }
}

cool_effect()
{
     do
     {
     v_gtext(handle,6,75,"    ~ Press Reset ~   ");  
     pauser();
     v_gtext(handle,6,75,"                      ");
     pauser();
     }while(1);
     
}


/****************/
on()
{
 char *conterm;

conterm = (char *) 0x484L;
*conterm |=0x01; /*turn keyclick on */

}
