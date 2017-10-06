

#include<globals.h>
#define	Setpalette(a)	xbios(6,a)

char parry[] = "2 klang";                 /* that -q disables intro mssg on play.ttp */
                                               /* but i call it 'player' */
char miss[]  = "2 swish";   
char CRY[]   = "2 cry11";
char CAST[]  = "2 cast1";
char enc_intro[] = "2 encou";
char engarde[]="2 engar";
char explode[]="2 explo";


/*This module has all the fight routines, it will call:
 
                       a hell-of-a lot of subroutines, all
                       of which are inside this module....
                                                            */
encounter(mf_src,mf_dest,pxyarray,scr6,run)
register MFDB *mf_src,*mf_dest;   /* the src and dest MFDBs!! */
char *scr6;
int pxyarray[8],*run;
          
{
 int f;
 char command;
 int s_ave[4];

  mf_src->fd_addr =(long)scr6; /* copy address */
   
      
      pxyarray[0] = 70;
      pxyarray[1] = 93;  /* get the src rectangle */
      pxyarray[2] = 192;
      pxyarray[3] = 181; 
      
       Setpalette( pal4 );
       vro_cpyfm(handle,3,pxyarray,mf_src,mf_dest);

 
 invoke_tsr( enc_intro );




 runner = 1;
 mon_num = 1; 
 mon_alive = 1;   /* set tjis = to 1 */
 lvl_monsters();            /* gets monster type */
v_gtext(handle,197,99,"             ");     /* clear out existing text*/
v_gtext(handle,197,99,mon.name);
printf("\n%s\n",mon.name);
 clear_it();
 amount();                  /* gets amount*/
  surprise();                /* who goes first?*/
  if(who_goes == 0)
   {                                                 
     v_justified(handle,6,19,"Denzins of this evil place",184,0,1);
     v_gtext(handle,6,27,"surprise you!"); 
     pause();
     mon_attack();
   }
   if(who_goes ==1)
   {
     
     v_justified(handle,6,19,"You surprise death itself",184,0,1);
     sprintf(string,"in the form of %d ",mon_num);
     v_justified(handle,6,27,string,184,0,1);
     v_gtext(handle,6,35,mon.name);
     v_gtext(handle,6,43,"Will you:");
     v_gtext(handle,6,51,"(R)un or");
     v_gtext(handle,6,59,"(F)ight");
     command = Bconin(2);
    if(command == 'F' || command == 'f' )
    {
     invoke_tsr( engarde );
     char_attack();
    }
    else runner = 0;   /* set the RUN variable! and lets book it otta here! */
     
   }
 alive();                         /* check to see if anyone's alive*/
 
  while(char_alive ==1 && runner ==1 && mon_num !=0)
  /* ok, this says that IT WILL execute if:
               
               the character is still alive
               the character hasnt not run away 
        and... if there are still monsters to fight  */
    {
       display_user_stats();

     if(char_alive ==1)           /* well, user always goes 1st here*/
     {
      char_attack();
       alive();
     }
     if(mon_alive ==1 && mon_num !=0) 
                        /* last but not least, the monster. This 
                           will exec. if the moster is still alive,
                           AND you didnt just kill a monster */
     {
      mon_attack();
     alive();
      }
    }               /* You will only get treasure if ALL monsters
                       have been killed */ 
   clear_it();
   if(char_alive ==0) game_over();      /* for mon_alive to be 0, ALL*/
 
    
  f=0;
   if(mon_alive ==0 && runner !=0) f=treasure();       /* monsters must have been killed*/
      if (f)
        {
         /* load up chest pic!, since mf_src already points to MISC3.DAT
       (because it loaded up the monster pic) the chest pic is also
       in MISC3.DAT, so just set new source coords and copy!  */
      pxyarray[0] = 194;
      pxyarray[1] = 3;  /* get the src rectangle */
      pxyarray[2] = 316;
      pxyarray[3] = 91; 
      
       vro_cpyfm(handle,3,pxyarray,mf_src,mf_dest);

     v_gtext(handle,6,27,"You found a chest.     ");
     
  /* ask if you will open/pick it, etc. It will contain potions, */
  /* jewels, weapons, maps, etc.!! */
     
    
v_gtext(handle,197,99,"     Chest    ");

    
    v_gtext(handle,6,41," Will you :          ");
    
    v_gtext(handle,6,49,"   O - Open it. ");
    v_gtext(handle,6,57,"   L - Leave it alone");
    v_gtext(handle,6,65,"                     ");
    v_gtext(handle,6,81,"   Thy choice : ");
   do
     { command = Bconin(2);
     }while(command != 'o' && command!= 'O' && command !='l' && command!= 'L');
   
  switch(command)
      {
         case 'O':
         case 'o':
                  open_chest();
                  break;
      }
clear_it();

    
    

        }
for(f=0;f<4;f++)  pxyarray[f] = s_ave[f]; /*restore array */

v_gtext(handle,259,164,"     ");      /*( erase previous gold amt*/

/* re-play sound if there was sound playing before encounter */
if(CURRENT_SOUND == 1) Dosound( wind_sound );

if(CURRENT_SOUND == 4) Dosound( rain_sound );

if (runner ==0) *run =1;  
 else *run=0;    /* say you ran! */
}      /* end of encounter! */



/***********************************/


/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */

char_attack()

{
  int good;
  char comm;
  
good =0;                    /* good is set to 1, if user input is valid*/

clear_it();
v_gtext(handle,6,19,"    ~ Fight Options ~  ");
v_gtext(handle,6,43,"(F)ight             ");
v_gtext(handle,6,51,"(C)ast a spell      ");
v_gtext(handle,6,59,"(T)alk to monster   ");
v_gtext(handle,6,67,"C(h)arm Monster     ");
v_gtext(handle,6,75,"(R)un               ");
v_gtext(handle,6,83,"(Y)ell a Battle Cry ");
do
{
 comm=Bconin(2);       /* get input from keyboard*/
 
 switch(comm)
    {
     case 'H':
     case 'h': Charm_monster();good=1;      break;
     case 'F':
     case 'f': fight();
               good = 1;
               break;
     case 'C': 
     case 'c': cast();
               good=1;
               break;
     case 'T': 
     case 't': talk();
               good=1;
               break;
     case 'R': 
     case 'r': run();
               good=1;
               break;
     case 'Y':             /* yell... */
     case 'y':battle_cry();
              good=1;
              break;
         }     /* end of switch*/
 }            /* end of do*/
 while(good==0) ;          /*good is set to 0 before case, if =0*/
                           /* then users choice wasnt valid */
clear_it();

} /* end of char attack */




/****************************************************/

/****************************************/
battle_cry()
{

  invoke_tsr( CRY );

}
/****************************************************/
/***********/
 Charm_monster()
{
 int hit,hld_exp;

 clear_it();
 hit = rnd(100); hit+=18;  /* lower limit will be 18 */
 if( (user.con + (user.current_spells_active[4]*5)) >= hit)
 {
  v_gtext(handle,6,11,"You charmed it!!");
   
        hld_exp = pos_rnd((mon_lvl+1) * mon.hd);
        hld_exp = abs(hld_exp);
        user.exp +=hld_exp;
        mon_num--;            /* subt 1 from # of monsters!*/
        if(mon_num !=0)
          {
           sprintf(string,"You face %d more monsters  ",mon_num);
           v_justified(handle,6,27,string,184,0,1);
           pause();
          }
       if(mon_num == 0){v_gtext(handle,6,27,"You've defeated all the");
                        v_gtext(handle,6,35,"monsters...");
                         pause();
                         mon_alive=0;  /* all monsters dead.. */
                       }
     }
   else 
    v_gtext(handle,6,11,"The monster growls..");
    pause();
}
/***********/
fight()
{
  
  int temp_dex,temp_str,temp_mon,hit,damage,range,hld_exp;
  int m_o_p; /*missed or blow parried a random number */ 

  clear_it();
  temp_dex = user.dex -18;                /* if dex >18, difference is */
  if(temp_dex < 0) temp_dex =0;      /* a bonus, same with STR*/
  temp_str = user.str -18;
  if(temp_str < 0) temp_str =0;
  temp_mon = mon_num;

  hit = rnd(19);                     /* roll a 1d19*/
  hit = hit +1;                      /* add 1 to it, makes it a 1d20*/
  hit = hit + temp_dex;              /*add bonus*/


 

 if(hit < hrt[mon.ac])  /* else check for miss */
   {
    hit=0;
   }
else hit = 1;
  if (hit ==0)                  /* hit is set by the HRT(above code) */
 {
 m_o_p = rnd(2);
 switch (m_o_p)
   {
   case 0:
          invoke_tsr( parry );
          v_gtext(handle,6,13,"your blow is parried  ");
          break;
   case 1:
          invoke_tsr( miss );
          v_gtext(handle,6,13,"you missed            ");
          break;
   }
 pause();
 }
  if (hit ==1)                      /* well, looks like we hit em eh?*/
 {     /*begin of hit 1*/
  range = user.weapon_num;
  damage = rnd(range);         /* get damage*/
  damage = damage+temp_str +1;             /* add bonus and +1*/
  damage +=user.current_spells_active[3]*5; /* add 5 point bouns if you 
                                          have magical strength! */

  mon.hp = mon.hp - damage;         /* subt. from monster hp*/
  sprintf(string,"You hit the %s and..",mon.name);
  v_justified(handle,6,13,string,184,0,1);
  if(mon.hp<1)           /* if no more hp, then he must be dead!*/
    {                
        v_gtext(handle,6,21,"it lets out a piercing");
        v_gtext(handle,6,29,"shreak as it slumps to");
        v_gtext(handle,6,37,"the ground.");
        pause();
        
        hld_exp = pos_rnd((mon_lvl+1) * mon.hd);
        hld_exp = abs(hld_exp);
        user.exp +=hld_exp;
        mon_num--;            /* subt 1 from # of monsters!*/
        if(mon_num !=0)
          {
           sprintf(string,"You face %d more monsters  ",mon_num);
           v_justified(handle,6,69,string,184,0,1);
           pause();
          }
    }
  if(mon.hp>0)
         {
         sprintf(string,"it takes %d points damage! ",damage);
         v_justified(handle,6,21,string,184,0,1);
         pause();
         }  
  if(mon_num ==0)
         {
         v_gtext(handle,6,61,"You have defeated all ");
         v_gtext(handle,6,69,"the monsters. ");
         pause();
         mon_alive =0;      /* if all are dead, set mon_alive to 0 */
         }
  
  } /*end of hit 1 */
  }     /* end of fight*/





/*********/
cast()             /* oooh spellcasters...my favorite */

{
  char commandc; 
  int temp_inte,temp_wis,temp_mon,hit,damage,range,dummy;
  int max_spell_num,x,commandi;
  char sp[26];  

 clear_it();
  max_spell_num = 2*user.lvl;
  
  /* max_spell num to cast = users lvl! */
  dummy =0;
   /* calculate lvl to cast spells. Formula:  */
   /* user.lvl*2 = max spell number you can cast*/ 
  v_gtext(handle,6,11,"Cast what spell? ");
  sprintf(string,"[1-%d] or e(X)it ",max_spell_num); 
  v_gtext(handle,6,19,string);
  do
  {
  commandc=Bconin(2);       /*get input*/
  commandi = commandc - '0'; /* get int value, only 0-9 right now */
  if (commandi == 0 ) commandi =999;
  }while((( commandi > max_spell_num) || (commandi > user.sp)) && (commandc !='x' && commandc !='X')); 
  
 if(commandc !='X')       /*if command = 999 the dont execute! */
  { 
   
  user.sp = user.sp - commandi; /*subtract sp*/
  user.spell_num = commandi; /*set spell number into user stats*/
  /* call module to convert spell 1 to a spell name and print the name */
  conv_spell( commandi,sp );
  clear_it();
  v_gtext(handle,6,11,"You cast a");
  v_gtext(handle,6,19,sp); 

 invoke_tsr( CAST );

temp_inte = user.inte -18;                /* if dex >18, difference is */
  if(temp_inte < 0) temp_inte =0;      /* a bonus, same with STR*/
  temp_wis = user.wis -18;
  if(temp_wis < 0) temp_wis =0;
  temp_mon = mon_num;

  hit = rnd(19);                     /* roll a 1d19*/
  hit = hit +1;                      /* add 1 to it, makes it a 1d20*/
  hit = hit + temp_wis;              /*add bonus*/

 if(hit >= hrt[mon.ac]) /* if roll is good, then set hit to 1*/
    hit =1;

 else  /* else  miss */
    hit=0;

  if (hit ==0)                  /* hit is set by the HRT(above code) */
 {
  v_gtext(handle,6,27,"it fizzes at your");
  v_gtext(handle,6,35,"fingertips! ");
  pause();
 }
  if (hit ==1)                      /* well, looks like we hit em eh?*/
 {     /*begin of hit 1*/
  range = user.spell_num;
  range = range + user.lvl; /*add lvl bonus to range*/
  damage = rnd(range);         /* get damage*/
  damage = user.inte +1;             /* add bonus and +1*/
  damage = abs(damage);
  mon.hp = mon.hp - damage;         /* subt. from monster hp*/

  invoke_tsr( explode );   /* strike monster */

  v_gtext(handle,6,27,"it strikes the monster!");
  if(mon.hp<1)           /* if no more hp, then he must be dead!*/
    {                
        v_gtext(handle,6,35,"The monster falls to ");
        v_gtext(handle,6,43,"the ground, blood gush-");
        v_gtext(handle,6,51,"ing from its wounds!!!");
        pause();pause();
        mon_num--;            /* subt 1 from 3 of monsters!*/
        if(mon_num !=0)
          {
           sprintf(string,"You still face %d more ",mon_num);
           v_gtext(handle,6,67,string);
           v_gtext(handle,6,75,"monsters(s)");
           for(hit=0;hit<999;hit++)
           {
            }
          }
    }
  if(mon.hp>0)
         {
         sprintf(string,"it takes %d pts damage   ",damage);
         v_gtext(handle,6,35,string);
         }
  if(mon_num ==0)
         {
         v_gtext(handle,6,67,"You've defeated all the");
         v_gtext(handle,6,75,"monsters.");
         mon_alive =0;      /* if all are dead, set mon_alive to 0 */
         for(hit=0;hit<999;hit++)
          {
           }
         }
   
  } /*end of hit 1 */
  
} /*end of if command != 999*/

pause();

} /*end of cast */


/********/
talk()
{
clear_it();
sprintf(string,"The %s ",mon.name);
v_gtext(handle,20,50,string);
v_gtext(handle,20,58,"wont talk...");
pause();
}

/******/
run()
{
  int run_ok;

  clear_it();
 run_ok= rnd(50);
 if(user.current_spells_active[1]) run_ok =1; /* if you have fleetness. you always get away..*/
  if(run_ok <=24)
   {
     v_gtext(handle,6,19,"You got away!!!       ");
    
     runner=0;
    
    } 
 if (run_ok >24)
     v_gtext(handle,6,19,"You didn't get away.  ");


      pause();

}




/******************************************************/






/******************/
lvl_monsters()
{
 if(user.lvl ==1)
   mon_lvl =1;
 if(user.lvl >1)
   {
    mon_lvl = rnd(user.lvl);
    if(mon_lvl ==0)
      mon_lvl ++;
   }
    
/*actually get the monster*/
 
strcpy(mon.name,monsters[mon_lvl].name);             /*monsters[mon_lvl].name;*/
mon.ac    = monsters[mon_lvl].ac;       /*monsters[mon_lvl].ac;*/
mon.hd    = monsters[mon_lvl].hd;          /*monsters[mon_lvl].hd;*/
mon.hp    = monsters[mon_lvl].hp;         /*monsters[mon_lvl].hp;*/
mon.weapon= monsters[mon_lvl].weapon;        /*monsters[mon_lvl].weapon;*/
mon.spell = monsters[mon_lvl].spell;       /*monsters[mon_lvl].spell;*/
mon.lvl   = monsters[mon_lvl].lvl;



}












/***********/

amount()
{
   int range;

  

  range = user.lvl;
  mon_num = rnd(range);
 
  if(mon_num ==0) 
       mon_num++;

   mon_num = abs(mon_num);
 }


/*************/

surprise()
{
   int char_roll;
   int mon_roll;



 char_roll = rnd(6);
 mon_roll  = rnd(6);
 
 if (char_roll >= mon_roll)
    who_goes =1;         /* means character goes first */
 if( char_roll < mon_roll)
    who_goes =0;
}

/*********************/
alive()
{

 if(mon.hp <=0)
    
      mon_alive =0;
     
 if (user.hp <=0)
     
      char_alive =0;
     
 }



/*******************************/

treasure()

  /* allocates exp and gld and items */
 {
   int  temp_gld;
   int  roller;   
   char command;
   

   
  v_gtext(handle,197,99,"   Treasure   ");
   clear_it();
   roll_gold(user.lvl,user.con,mon.lvl);
   roller = rnd(300);
   if(user.current_spells_active[0]) roller +=250; /* gives you an 86% chance
                                                 to find a chest.. if you have treasure finding!!!*/
   if(roller > 290)
     return 1;   /* chest!! */
    else return 0;
   
}       

/*******************************/
 open_chest()
 {
  char comm;
  int k,roll,temp_dex,user_roll,troll,examine;
  int good;
   
   clear_it();
   good = 0; /* if 0, invalid option chosen */
   examine =0;  /* if set to 1, then a trap was found */   
 do
 {
   v_gtext(handle,6,19,"Will you :        ");
   v_gtext(handle,6,27,"  O - Open it   ");
   v_gtext(handle,6,35,"  E - Examine it");
   v_gtext(handle,6,43,"  C - Cast spell");
   v_gtext(handle,6,51,"  L - Leave it  ");
   v_gtext(handle,6,59,"                ");
   v_gtext(handle,6,67,"                ");
   v_gtext(handle,6,74,"                ");
  
   comm = Bconin(2);    
  
   clear_it();
   switch(comm)
    {
      case 'o':
      case 'O':good =1;
             if(examine == 1)
              {
               roll_gold(user.lvl*100,user.con,mon.lvl);
              }
             else
             {          
                 
               roll = rnd(18);
               user_roll = rnd(15);
               temp_dex = user.dex - 18;
               if(temp_dex <0) temp_dex =0;
               user_roll = user_roll + temp_dex;
                 if(user_roll >= roll)
                     {
                         roll_gold(user.lvl*100,user.con,mon.lvl);
                     }
                 if(user_roll < roll)
                     {
                      roll = rnd(3);
                 if(roll ==1) v_gtext(handle,6,19,"Nothing happens");
                 if(roll ==2)
                     {
                     v_gtext(handle,6,19,"You trigger a trap");
                     roll = rnd(user.lvl+5);
                     sprintf(string,"and take %d pts damage",roll);
                     v_gtext(handle,6,25,string);
                     } 
                    }
               }  /* end of else*/
              break;
            
            
      case 'e':
      case 'E': /* dont set good =1 here */ 
              good = 0;
              roll = rnd(18);
              user_roll = rnd(18);
              temp_dex = user.dex -18;
              if(temp_dex > 0)
              {
              user_roll = user_roll + temp_dex;
              }
              if(user_roll>=roll)
              {
               v_gtext(handle,6,19,"You found a trap!");
               examine =1;   /* set flag to denote trap was found */
              }
              else 
              v_gtext(handle,6,19,"You found nothing");
              pause();
              break;
      case 'c':
      case 'C':good =0;        /* just checking..dont wanna exit yet! */
               if( user.sp > 5) user.sp = user.sp -5;
               v_gtext(handle,6,19,"You cast a spell...");
               if (user.sp < 5) 
                 {
                  v_gtext(handle,6,27,"Not enough sp");
                  break;
                 }
               user.sp -= 5;       /*subt sp */ 
               user_roll = rnd(30);
               user_roll +=(user.wis-12);
               if (user_roll > 27){ v_gtext(handle,6,27,"you found a trap!");examine=1;}
              else v_gtext(handle,6,19,"You found nothing");
               pause();
               break;
      case 'l':
      case 'L': good =1;
      
  } /* end of switch */
 pause();
  } /* end of do while */
   while(good == 0);


  for(k=0;k<100;k++)
       {}
 }     /* end of module*/






/**********************************************************/
   /* monster attack */
 
 mon_attack()
  {
   
    /* use A.I. to decide if the monster will attack, talk or run */
    /* if attacking, decide if it will fight or cast. */

    int mhit,mdamage;
    int mop; /* miss or parry.. */
clear_it();


  mhit = rnd(19);                     /* roll a 1d19*/
  mhit = mhit +1;                      /* add 1 to it, makes it a 1d20*/
 
 mhit = mhit + mon.hd; /* add monsters hit dice to it */
 if(mhit >= mhrt[user.ac]) /* if roll is good, then set hit to 1*/
   {
    mhit =1;
   }
 if(mhit < mhrt[user.ac])  /* else check for miss */
   {
    mhit=0;
   }

  if (mhit ==0)                  /* hit is set by the HRT(above code) */
 {
  mop = rnd(2);
  if ( mop == 0 )
  {
  v_gtext(handle,6,19,"The monster missed!    ");
  invoke_tsr( miss );                         
  }
 else 
   { 
     v_gtext(handle,6,19,"You parry the blow!    ");
     invoke_tsr( parry );
   }
  pause();
 } 
 if (mhit ==1)                      /* well, looks like we hit em eh?*/
 {     /*begin of hit 1*/
  mdamage = rnd(mon.weapon);         /* get damage*/
  mdamage = abs(mdamage);
  mdamage -=user.current_spells_active[2]; /* subtract 1 from danage if you 
                                         have Protection.. */
 
  user.hp = user.hp - mdamage;         /* subt. from monster hp*/
  v_gtext(handle,6,19,"The monster hits you and....");
  if(user.hp<1)           /* if no more hp, then he must be dead!*/
    {                
     v_gtext(handle,6,27,"You choke on your own");
     v_gtext(handle,6,35,"blood and sink to the floor!!!");
     pause();  
    }
  if(user.hp>0)
      {
         sprintf(string,"You take %d points damage!",mdamage);
         v_gtext(handle,6,27,string);
         pause();
       }
  } /*end of hit 1 */
  }     /* end of mon attack*/


/*********************************************************/
/* the infamous PAUSE() function */

pause()
{
  char tsecs;

     
     for(tsecs=0;tsecs<60;tsecs++)
        Vsync();
}

/*****/

clear_it()
{
v_gtext(handle,6,8,"                       ");
v_gtext(handle,6,13,"                       ");
v_gtext(handle,6,19,"                       ");
v_gtext(handle,6,25,"                       ");
v_gtext(handle,6,31,"                       ");
v_gtext(handle,6,37,"                       ");
v_gtext(handle,6,43,"                       ");
v_gtext(handle,6,49,"                       ");
v_gtext(handle,6,55,"                       ");
v_gtext(handle,6,61,"                       ");
v_gtext(handle,6,67,"                       ");
v_gtext(handle,6,73,"                       ");
v_gtext(handle,6,79,"                       ");
v_gtext(handle,6,85,"                       ");
}
/**********************************/
/* Rolls gold, the users level is sent, and so is his con
   also mon lvl is sent 


   Also:
    o    Rolls for Gems/Jewels
    o    Potions!

*/

roll_gold(lvl,con,mon_lvl)
int lvl,con,mon_lvl;
{
 int troll,
     extra=20,
     conextra;
               clear_it();
               troll = rnd(18+con);
               troll = abs(troll + lvl + mon_lvl);
               sprintf(string,"You find %d gold!",troll);
               v_gtext(handle,6,8,string);
               user.gold = user.gold+troll;

               troll = abs(rnd(100));   
                /* usually you have a 10% chance of finding 
                   gems/jewels/potions
                   add you (CON-18) to it
                */
             if(user.current_spells_active[0]) troll -=user.con; /* big bonus. */ 
             conextra = user.con - 18;
             if(conextra < 0 ) conextra =0;
             troll -=conextra; /* bonus */      

                if( troll < 10 )   /* extra special items found!! */
                 {
                 troll = abs(rnd(3));
                 switch(troll) 
                  {
                  case 0: v_gtext(handle,6,19,"You found a Jewel!!");
                          user.user_items[5]++; break;
                  case 1: v_gtext(handle,6,19,"You found a Gem!!");
                          user.user_items[4]++; break;
                  case 2: v_gtext(handle,6,19,"You found a potion!");
                          roll_for_potion(); break;
                  }
 
                 } 
}

/************************************************/
/* returns a string of the form, "you cast a 'spellname' and.." 
*/
conv_spell( s,sp )
int s;
char sp[];

{
 
if ( s == 1 )
  strcpy(sp,"Magic Missle and..");
if (s == 2)
  strcpy(sp,"Sleep spell and..");
if(s== 3)
  strcpy(sp,"Fireball! and..");
     
if (s== 4)
   strcpy(sp,"Lightning bolt and..");
           
if (s == 5)
    strcpy(sp,"Banishment and..");
      
if (s == 6)
    strcpy(sp,"Hold Monster and..");
  
    
}
/************************************************/

/**
   Roll for potion
**/

roll_for_potion()
{
  int troll;
  
  troll = abs(rnd(8));
  troll +=6;   /* offset to get in range of potions. Ie if roll 0
                  the add 6 to it, so you get potion1 which is 
                  at cell 6 of user_items[] */
  user.user_items[troll]++;
}
