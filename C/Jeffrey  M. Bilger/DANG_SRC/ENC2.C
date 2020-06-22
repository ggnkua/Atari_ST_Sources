#include<osbind.h>

#include<globals2.h>
#define	Setpalette(a)	xbios(6,a)

char parry[] = "2 klang";                 /* that -q disables intro mssg on play.ttp */
                                         /* but i call it 'player' */
char miss[]  = "2 swish";   
char CRY[]   = "2 cry11";
char CAST[]  = "2 cast1";
char enc_intro[] = "2 encou";
char engarde[]="2 engar";
char explode[]="2 explo";
char hit_em[] = "2 hit00";

/*This module has all the fight routines, it will call:
 
                       a hell-of-a lot of subroutines, all
                       of which are inside this module....
                                                            */
encounter(mf_src,mf_dest,pxyarray,scr6,run)
register MFDB *mf_src,*mf_dest;   /* the src and dest MFDBs!! */
char *scr6;  /* addr of misc3.dat has monster/chest pic */
int pxyarray[8],*run;
          
{
 int f;
 char command;
 int s_ave[8];
 char clkj; 

 /* quickly reset pxyarray dest coords */
    pxyarray[4] = 194; /* just reset the x1 and x2 values */
    pxyarray[6] = 316; /* new pic code may have reset dest values.. */


  /* load up pic for monster */
   for(f=0;f<8;f++) s_ave[f] = pxyarray[f]; /*save array */
            mf_src->fd_addr = (long) scr6; /* copy address */
   
                 /* set up dest for mask */
      pxyarray[4] = 224;  
      pxyarray[5] = 4;         /* dest */
      pxyarray[6] = 289;  
      pxyarray[7] = 90;  /* was 94 */ 

      pxyarray[0] = 2;
      pxyarray[1] = 94;      /* source */
      pxyarray[2] = 67;
      pxyarray[3] = 180; 
              /* lets replace color (0x330) in pen # 10 to black */
       Setcolor(10,0x000);      
       vro_cpyfm(handle,4,pxyarray,mf_src,mf_dest); /* !S & D */
       /* mask uses color register 16 or 1111 binary 
          NOT 1111 = 0000 ,  AND this with the DEST leaves a black 
          siluette */

                        /* coords of the actual image to copy after we masked */
      pxyarray[0] = 105;      /* x's 106,180 */
      pxyarray[1] = 94;  /* get the src rectangle */
      pxyarray[2] = 170;     /* was 171 */
      pxyarray[3] = 180; 
      
           vro_cpyfm(handle,7,pxyarray,mf_src,mf_dest);


       invoke_tsr( enc_intro );

    /* restore the dest coords */
      for(f=4;f<8;f++) pxyarray[f] = s_ave[f]; /* restore dest */

command = Bconin(2);


 runner = 1;
 mon_num = 1; 
 mon_alive = 1;   /* set tjis = to 1 */
 char_alive = 1;  /* you're alive */
 lvl_monsters(run);            /* gets monster type */


v_gtext(handle,197,99,"              ");  /* clear mssg area */
v_gtext(handle,197,99,mon.name);
 clear_it();
 amount();                  /* gets amount*/
  surprise();                /* who goes first?*/
  if(who_goes == 0)
   {                                                 
     v_gtext(handle,6,19,"You are surprised!!");
     
     pause();
     mon_attack();
   }
   if(who_goes ==1)
   {
     
     sprintf(string,"You surprise %d",mon_num);
     v_gtext(handle,6,19,string);
     v_gtext(handle,6,35,mon.name);
     pause();
     char_attack();
     
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
     if(mon_alive ==0 && mon_num !=0) next_monster();  /* inits next monster
                                        and sets mon_alive == 1 */
    
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
   if(char_alive ==0) cool_effect();  /* you died */
                                     /* for mon_alive to be 0, ALL*/
 
    
  f=0;
   if(mon_alive ==0) f=treasure();       /* monsters must have been killed*/
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


/* re-play sound if there was sound playing before encounter */
if(CURRENT_SOUND == 1) Dosound( wind_sound );

if(CURRENT_SOUND == 4) Dosound( rain_sound );

if (runner ==0) *run =1;  
 else *run=0;    /* say you ran! */

for(f=0;f<8;f++)  pxyarray[f] = s_ave[f]; /*restore array */
display_user_stats();


while ( (Bconstat(2)) == -1) clkj = Bconin(2);  /* clear out keyboard buf */

  /* lets replace color (0x000) in pen # 10 to color 0x330 */
       Setcolor(10,0x330);      

}      /* end of encounter! */



/***********************************/


/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */

char_attack()

{
  int good,ret;
  char comm;
  
good =0;                    /* good is set to 1, if user input is valid*/

clear_it();
v_gtext(handle,6,11,"    ~ Fight Options ~  ");
v_gtext(handle,6,27,"(F)ight             ");
v_gtext(handle,6,35,"(C)ast a spell      ");
v_gtext(handle,6,43,"C(h)arm Monster     ");
v_gtext(handle,6,51,"(B)attle Cry        ");
v_gtext(handle,6,59,"(R)un               ");
v_gtext(handle,6,67,"(S)ound On/Off      ");
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
     case 'c': ret=cast();
               good=1;
               pause();
               break;
     case 'S': 
     case 's': sound_turnage();
               good=0;   /* since just a game option, dont count it as a move */
                break;
     case 'R': 
     case 'r': run();
               good=1;
               break;
     case 'B':
     case 'b': battle_cry();
               good=0;  /* game option, no move */
               break;
         }     /* end of switch*/
 }            /* end of do*/
 while(good==0) ;          /*good is set to 0 before case, if =0*/
                           /* then users choice wasnt valid */
clear_it();

} /* end of char attack */


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
   
        hld_exp = (mon_lvl+1*4)+(mon.hd*4)+ mon.spell+mon.weapon;
        
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

  hit =abs(rnd(19));                     /* roll a dice*/
  hit++;                      /* add 1 to it, makes it a 1d20*/
  hit +=temp_dex;              /*add bonus*/
   

 

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
  damage = abs(rnd(range));         /* get damage*/
  damage++;
  damage = damage+temp_str +1;             /* add bonus and +1*/
  damage +=user.current_spells_active[3]*5; /* add 5 point bouns if you 
                                          have magical strength! */

  mon.hp = mon.hp - damage;         /* subt. from monster hp*/
   invoke_tsr( hit_em );
   v_gtext(handle,6,13,"You hit the");
    sprintf(string,"%s and..",mon.name);
  v_gtext(handle,6,21,string);
  if(mon.hp<1)           /* if no more hp, then he must be dead!*/
    {                
        v_gtext(handle,6,29,"it lets out a piercing");
        v_gtext(handle,6,37,"shreak as it slumps to");
        v_gtext(handle,6,45,"the ground.");
        pause();
        
       
   hld_exp = (mon_lvl+1*4)+(mon.hd*4)+ mon.spell+mon.weapon;
     
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
         v_justified(handle,6,29,string,184,0,1);
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
  int hld_exp;

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
  
if(commandc == 'X' || commandc == 'x') 
 return;

 else       /*if command = 999 the dont execute! */
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
  
 }
  if (hit ==1)                      /* well, looks like we hit em eh?*/
 {     /*begin of hit 1*/
  range = user.spell_num;
  range = range + user.lvl; /*add lvl bonus to range*/
  damage = rnd(range);         /* get damage*/
  damage = user.inte +1;             /* add bonus and +1*/
  damage = abs(damage);
  mon.hp = mon.hp - damage;         /* subt. from monster hp*/
  v_gtext(handle,6,27,"it strikes the fiend!");
  invoke_tsr( explode );  /* boom!! */
  if(mon.hp<1)           /* if no more hp, then he must be dead!*/
    {                
        v_gtext(handle,6,35,"The monster falls to ");
        v_gtext(handle,6,43,"the ground, blood gush-");
        v_gtext(handle,6,51,"ing from its wounds!!!");
      
    hld_exp = (mon_lvl+1*4)+(mon.hd*4)+ mon.spell+mon.weapon;
    user.exp +=hld_exp;  
        mon_num--;            /* subt 1 from 3 of monsters!*/
        if(mon_num !=0)
          {
           sprintf(string,"You still face %d more ",mon_num);
           v_gtext(handle,6,67,string);
           v_gtext(handle,6,75,"monsters(s)");
           for(hit=0;hit<999;hit++)
           {
     }
    }  /* end of if hit == 1 */
    }
  if(mon.hp>0)
         {
         sprintf(string,"it takes %d pts ",damage);
         v_gtext(handle,6,35,string);
         v_gtext(handle,6,43,"damage!!");
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



} /*end of cast */


/********/
sound_turnage()
{
int mask = 1;



   /* sound on-off */
  
    if(sound == 1) v_gtext(handle,6,83,"   Sound is now OFF   ");
    else v_gtext(handle,6,83,"   Sound is now ON    ");
    sound ^= mask;   /* xor with mask */ 
   
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
lvl_monsters(run)
int *run;
{
char command;

 if(user.lvl ==1)
   mon_lvl =1;
 if(user.lvl >1)
   {
    mon_lvl = rnd(user.lvl);
    if(mon_lvl ==0)
      mon_lvl++;
   }
  if( *run == -999) mon_lvl = 47;  /* if *run = -999 set monster to Demon lord */
  
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
char command;
  

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
   

if(runner == 1)   /* if you have not run away */
 {   
  v_gtext(handle,197,99,"   Treasure   ");
   clear_it();
   roll_gold(user.lvl,user.con,mon.lvl);
   roller = rnd(600);
   if(user.current_spells_active[0]) roller +=550; /* gives you an 86% chance
                                                 to find a chest.. if you have treasure finding!!!*/
   if(roller > 590)
     return 1;   /* chest!! */
    else return 0;
  } 
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
                     v_gtext(handle,6,27,"You trigger a trap");
                     roll = rnd(user.lvl+5);
                     sprintf(string,"and take %d pts damage",roll);
                     v_gtext(handle,6,35,string);
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
             
              break;
      case 'c':
      case 'C':good =0;        /* just checking..dont wanna exit yet! */
               if( user.sp >= 3) user.sp = user.sp -3;
               v_gtext(handle,6,19,"You cast a spell...");
               if (user.sp < 3) 
                 {
                  v_gtext(handle,6,27,"Not enough sp");
                  break;
                 }
               user.sp -= 3;       /*subt sp */ 
               user_roll = rnd(35+user.lvl);
               user_roll +=(user.wis-12);
               if (user_roll > 27){ v_gtext(handle,6,27,"you found a trap!");examine=1;}
              else v_gtext(handle,6,19,"You found nothing");
               
               break;
      case 'l':
      case 'L': good =1;
      
  } /* end of switch */
 pause();
 clear_it();
  } /* end of do while */
   while(good == 0);


  
 }     /* end of module*/






/**********************************************************/
   /* monster attack */
 
 mon_attack()
  {
   
    /* use A.I. to decide if the monster will attack, talk or run */
    /* if attacking, decide if it will fight or cast. */
    int mstr;
    int mhit,mdamage;
    int mop; /* miss or parry.. */
clear_it();


  mhit = rnd(20);                     /* roll a 1d20*/
  mhit++;                      /* add 1 to it, makes it a 1d20*/
 mhit = mhit + mon.hd; /* add monsters hit dice to it */
 if(mhit >= mhrt[user.ac]) /* if roll is good, then set hit to 1*/
   {
    mhit =1;
   }
 
   else mhit = 0;

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
  mdamage = abs(rnd(mon.weapon));         /* get damage*/
  mdamage +=mon.spell;
  
  mdamage -=(user.lvl*user.current_spells_active[2]); /* subtract 1 from danage if you 
                                         have Protection.. */
  if(mdamage < 1) mdamage = 1;
  user.hp = user.hp - mdamage;         /* subt. from user hp*/
 
  invoke_tsr( hit_em );
  v_gtext(handle,6,19,"The monster hits you");
  if(user.hp<1)           /* if no more hp, then he must be dead!*/
    {                
     v_gtext(handle,6,27,"and you choke on your");
     v_gtext(handle,6,35,"own blood and sink to");
     v_gtext(handle,6,43,"the floor...");
     pause();  
    }
  if(user.hp>0)
      {
         sprintf(string,"You take %d points",mdamage);
         v_gtext(handle,6,27,string);
         v_gtext(handle,6,35,"damage!!");
         pause();
       }
  } /*end of hit 1 */
  }     /* end of mon attack*/


/*********************************************************/
/* the infamous PAUSE() function */

pause()
{
  char ts;

    ts = Bconin(2);
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
               troll = rnd(5+con);
               troll = abs(troll + lvl + mon_lvl);
               sprintf(string,"You find %d gold!",troll);
               v_gtext(handle,6,19,string);
               user.gold = user.gold+troll;

               troll = abs(rnd(300));   
                /* usually you have a 10% chance of finding 
                   gems/jewels/potions
                   add your (CON-18) to it
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
                  case 0: v_gtext(handle,6,27,"You found a Jewel!!");
                          user.user_items[5]++; break;
                  case 1: v_gtext(handle,6,27,"You found a Gem!!");
                          user.user_items[4]++; break;
                  case 2: v_gtext(handle,6,27,"You found a potion!");
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
  strcpy(sp,"Wall of fire and..");
if(s== 3)
  strcpy(sp,"Fireball! and..");
     
if (s== 4)
   strcpy(sp,"Lightning bolt and..");
           
if (s == 5)
    strcpy(sp,"Magic darts and..");
      
if (s == 6)
    strcpy(sp,"Greater Havoc and..");
  
    
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


/***/
next_monster()
{
/*actually get the monster*/
 
strcpy(mon.name,monsters[mon_lvl].name);             /*monsters[mon_lvl].name;*/
mon.ac    = monsters[mon_lvl].ac;       /*monsters[mon_lvl].ac;*/
mon.hd    = monsters[mon_lvl].hd;          /*monsters[mon_lvl].hd;*/
mon.hp    = monsters[mon_lvl].hp;         /*monsters[mon_lvl].hp;*/
mon.weapon= monsters[mon_lvl].weapon;        /*monsters[mon_lvl].weapon;*/
mon.spell = monsters[mon_lvl].spell;       /*monsters[mon_lvl].spell;*/
mon.lvl   = monsters[mon_lvl].lvl;
mon_alive = 1;

}
