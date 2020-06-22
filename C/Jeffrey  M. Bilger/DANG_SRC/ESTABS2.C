#include <globals2.h>
#define	Setpalette(a)	xbios(6,a)
#define	Kbrate(a,b)	(int)xbios(35,a,b)
#define	Bconstat(a)	(int)bios(1,a)
extern int  buffer[];        /* holds the char info for disk loading and saving */

char open1[] = "2 door1";/* creaky*/             /* that -q disables intro mssg on play.ttp */
char open2[] = "2 door2";/*AR door*/        /* but i call it 'player' */

char chant[] = "2 chant";
char heal0[] = "2 heal0";
char applause[] = "2 appla";
extern char CAST[];


temple(mf_src,mf_dest,pxyarray,scr6)
register MFDB *mf_src,*mf_dest;   /* the src and dest MFDBs!! */
char *scr6;  /* addr of misc 3.dat has temple pic */
int pxyarray[8];
    
{
 char com;
 int f;
 int s_ave[4];
  
v_gtext(handle,197,99,"    Temple    ");

for(f=0;f<4;f++) s_ave[f] = pxyarray[f]; /*save array */
 clear_it();
 /********* Load up a pix for the inside of the temple ***************/

            mf_src->fd_addr = (long) scr6; /* copy address */
   
           pxyarray[0] = 194;
      pxyarray[1] = 93;  /* get the src rectangle */
      pxyarray[2] = 316;
      pxyarray[3] = 181; 
      
       vro_cpyfm(handle,3,pxyarray,mf_src,mf_dest);



/*********************************/
invoke_tsr( chant );
do
{
 v_gtext(handle,6,19,"You're greeted at the");
 v_gtext(handle,6,27,"temple entrance by a ");
 v_gtext(handle,6,35,"monk. He asks , ");
 v_gtext(handle,6,43,"'How may I help thee");
 v_gtext(handle,6,51," Brother?'");
 v_gtext(handle,6,67," A)sk for Blessing");
 v_gtext(handle,6,75," E)xit Temple     ");

while (!(Bconstat(2)))
  {
    v_gtext(handle,6,67,"  "); 
    v_gtext(handle,6,75,"  "); 

     pauser();

    v_gtext(handle,6,67," A"); 
    v_gtext(handle,6,75," E"); 
   pauser();

   }
 

 com = Bconin(2);
}
 while ( com != 'A' && com !='a' && com != 'E' && com != 'e' );

if ( com == 'A' || com =='a' )
  {
   clear_it();
   v_gtext(handle,6,11,"All I ask of thou is ");
   v_gtext(handle,6,19,"for a small donation ");
   v_gtext(handle,6,27,"Accept? [y/n]");
   com =Bconin(2);
   if( com == 'Y' || com == 'y' )
   {
   v_gtext(handle,6,35,"May the gods praise you");
   v_gtext(handle,6,43,"my son....");
   pause();
   clear_it();
   user.gold = user.gold - (user.gold * 0.10); /* donate 10% */ 
   v_gtext(handle,6,11,"The monk leads you ");
   v_gtext(handle,6,19,"through a maze of ");
   v_gtext(handle,6,27,"corridors. After what");
   v_gtext(handle,6,35,"seems like an eternity");
   v_gtext(handle,6,43,"you come upon an altar");
   v_gtext(handle,6,51,"bathed in a pure white");
   v_gtext(handle,6,59,"glow. He tells you to");
   v_gtext(handle,6,67,"lay upon it. As you do");
   v_gtext(handle,6,75,"so your body jerks in");
   v_gtext(handle,6,83,"a series of spasms. ");
  invoke_tsr( heal0 );
      com = Bconin(2);
   clear_it();
    v_gtext(handle,6,11,"Finally the sensation");
   v_gtext(handle,6,19,"passes. The monk grins");
   v_gtext(handle,6,27,"and says, ");
   v_gtext(handle,6,35,"' That wasn't too bad ");
   v_gtext(handle,6,43,"  eh?' ");
             /* inc the hp */
             /* and sp */
   user.hp += user.con;
   user.sp += user.con;
   if( user.hp > user.max_hp) user.hp = user.max_hp;
   if( user.sp > user.max_sp) user.sp = user.max_sp;
  
   v_gtext(handle,6,51,"You give him a look of");
   v_gtext(handle,6,59,"disgust and quicky");
   v_gtext(handle,6,67,"exit the temple...");
   pause();
  } 
 }

    for(f=0;f<4;f++)  pxyarray[f]= s_ave[f]; /*restore array */
}  /* end of module TEMPLE */
 
/*********************************************************************/


 


/********************************************************************/
inn()
{
char com,com2;
int check_random,g,amount=0,delta=0,c_time,sleep_time=0,dummy,test=0;
/* dummy, holds value returned from events call. We dont care 
  what it is... */
clear_it();
 
v_gtext(handle,197,99,"     Inn      ");


invoke_tsr( open2 );
do       /* main do , do until select Exit! */
{


 
 display_user_stats();         /* update stats */
 clear_it();                   /* clear screen */

 v_justified(handle,6,19,"You see all types of people",184,0,1);
 v_justified(handle,6,27,"milling about the common room",184,0,1);
 v_gtext(handle,6,35,"You walk up to the ");
 v_gtext(handle,6,43,"counter and the chubby");
 v_gtext(handle,5,51,"inkeep looks at you ");
 v_gtext(handle,6,59,"and says...");
 v_justified(handle,6,67,"'How may I help thee Friend?'",184,0,1);
 v_gtext(handle,6,75," A)sk the time  W)ork");
 v_gtext(handle,6,83," R)ent a room   E)xit");

while (!(Bconstat(2)))
  {
    v_gtext(handle,6,75,"  "); v_gtext(handle,134,75," ");
    v_gtext(handle,6,83,"  "); v_gtext(handle,134,83," ");

     pauser();

    v_gtext(handle,6,75," A"); v_gtext(handle,134,75,"W");
    v_gtext(handle,6,83," R"); v_gtext(handle,134,83,"E");
   pauser();

   }
do
{
 com = Bconin(2);
}
 while ( com != 'A' && com !='a' && com != 'R' && com != 'r' &&
         com != 'W' && com !='w' && com != 'E' && com != 'e' );


clear_it();

if ( com == 'W' || com =='w' )
  {


   check_random = rnd(100);
   if ( check_random > 90 )
   {
   v_justified(handle,6,11,"The inkeeper says,",184,0,1);
   g = rnd(10);
   switch (g)
    {
      case 0:
      case 1:case 2:case3:
      case 4: v_gtext(handle,6,19,"I need a guard.");
              break;
      case 5: v_gtext(handle,6,19,"I need a courier.");
              break;
      case 6:case7:case 8:
      case 9: v_gtext(handle,6,19,"I need a handyman.");
    }

   sprintf(string,"It pays %d gp",g+user.con);
   v_gtext(handle,6,27,string);
   v_gtext(handle,6,35,"Do you want it [y/n]");
  do{ com2 = Bconin(2);
    }while (com2 != 'N' && com2 !='n' && com2 !='Y' && com2 != 'y');
   if ( com2 == 'Y' || com2 == 'y' )
   {
    clear_it();
    v_gtext(handle,6,11,"Working....");
    
    user.gold += g+user.con;
           /* update TIME! 3 HOURS!!! */
    
       /* mod 12, hours */
     for(g=0;g<3;g++)
      {
      time = HOUR_VALUE;   /* Dentoe an hour has passed */
     
      sleeppause();                /* working and update time at same time */
      check_random=events(); /* update events while working */
      
     }
   }  
  
} /* end of inkeep HAS A JOB FOR YOU to do */

else
  {
   v_gtext(handle,6,11,"Sorry Friend, ");
   v_gtext(handle,6,19,"I don't have any ");
   v_gtext(handle,6,27,"work for you.");
   pause();
  }


  }  /* end of WORKING */
   
if( com == 'A' || com == 'a')   /* ask the time */
check_time();
 
                          /* you want to rent a room */
if( com == 'R' || com == 'r' )
 {

 

  amount = 75 - user.con + user.lvl;
  v_gtext(handle,6,11,"Ah, yes! we have the");
  v_gtext(handle,6,19,"finest rooms in the ");
  v_gtext(handle,6,27,"city! And what a bar-");
  sprintf(string,"gain for only %d gp.",amount);
  v_gtext(handle,6,35,string);
  v_gtext(handle,6,51,"Still want it [y=n]");
  com2 = Bconin(2);
   if ( com2 == 'Y' || com2 == 'y' )
     {
      if (amount > user.gold) v_gtext(handle,6,59,"You dont have the funds");
      /* else you do have the $$ */
      else
      {
       user.gold -= amount;   /* debt the amount */
       clear_it();


       v_gtext(handle,6,11,"How long do you wish ");
       v_gtext(handle,6,19,"to sleep [Max of 12]");
       v_gtext(handle,6,35,"Up/Down arrow to change");
       v_gtext(handle,6,43,"Return to confirm.");
       sprintf(string,"Time:%d",sleep_time);
       v_gtext(handle,6,59,string);
       do
       {
        com2 = (char)(Bconin(2)>>16);
        if(com2 == 0x48) sleep_time +=1;
 if(com2 == 0x50) sleep_time -=1;
 if(sleep_time < 0) sleep_time =0;
 if(sleep_time > 12) sleep_time = 12;
 
 if( test > 9 && sleep_time == 9 )   /* if previous was > 9 and now its 9, clear */
 v_gtext(handle,6,59,"               ");  /* clear */

 sprintf(string,"Time:%d",sleep_time);
 v_gtext(handle,6,59,string);
test = sleep_time;
 }while( com2 != 0x1c); /* until return is pressed */


       amount = sleep_time;
       sleep_time = 0;
       v_gtext(handle,6,67,"I'll wake you up in");
       sprintf(string,"%d hours",amount);
       v_gtext(handle,6,75,string);
      
       
             /* update TIME! */
       
            /* mod 12, hours */
     for(g=0;g<amount;g++)
      {  
      
      time = HOUR_VALUE;   /* Dentoe an hour has passed */
       sleeppause();                /* sleeping and update time at same time */
       dummy=events();   /* update stuff... But SUPRESS encounter!
                           ie, dummy holds 1 if encounter 0 if not,
                           so just ignore it! */
 
      
     }
          
 
       clear_it();
       v_gtext(handle,6,11,"It's time for you to ");
       v_gtext(handle,6,19,"wake up, I hope you ");
       v_gtext(handle,6,27,"rested well..");
                                                /* update stats */
       user.hp = user.hp + (amount*user.lvl);
       if(user.hp > user.max_hp) user.hp = user.max_hp;
       user.sp = user.sp + (amount+(user.inte-10));
       if(user.sp > user.max_sp) user.sp = user.max_sp;
       pause();
       
      }/* end of else, you have $ to pay for it */
      
     } /* end of Yes i still want a room */   

 } /* end of rent a room */



 /* process other inputs here */
 } while( com != 'E' && com != 'e');   /* Stay in estab until Exit! */
} /* end of module */

/********************************************/
tavern()
{
char com,com2;
int check_random,g,amount=0,delta=0,c_time;

v_gtext(handle,197,99,"    Tavern    ");
 /* execute sound of opening door..*/
    invoke_tsr( open2 );
  
clear_it();

do       /* main do , do until select Exit! */
{


 display_user_stats();         /* update stats */
 clear_it();                   /* clear screen */

 v_justified(handle,6,11,"You walk into a dimly lit",184,0,1);
 v_justified(handle,6,19,"tavern. A healthy barmaid",184,0,1);
 v_gtext(handle,6,27,"seats you at the bar.");
 v_gtext(handle,6,35,"Finally the bartender");
 v_gtext(handle,5,43,"comes over to you and");
 v_gtext(handle,6,51,"says...");
 v_justified(handle,6,59,"'Greetings! what may I get",184,0,1);
 v_gtext(handle,6,67,"thee?'");
 v_gtext(handle,6,76,"Order a (D)rink  (T)alk");
 v_gtext(handle,6,84,"Order   (F)ood   (E)xit");

while (!(Bconstat(2)))
  {
    v_gtext(handle,78,76," "); v_gtext(handle,150,76," ");
    v_gtext(handle,78,84," "); v_gtext(handle,150,84," ");

     pauser();

    v_gtext(handle,78,76,"D"); v_gtext(handle,150,76,"T");
    v_gtext(handle,78,84,"F"); v_gtext(handle,150,84,"E");
   pauser();

   }
do
{
 com = Bconin(2);
}
 while ( com != 'D' && com !='d' && com != 'T' && com != 't' &&
         com != 'F' && com !='f' && com != 'E' && com != 'e' );

clear_it();
                             /* order a DRINK */
if ( com == 'D' || com =='d' )
  {
do       /* begin of do until Exit is chosen */
 {     
 clear_it();
   v_justified(handle,6,11,"The inkeeper says,",184,0,1);
   v_gtext(handle,6,19,"Thy choice?");
   v_gtext(handle,6,35,"A) Water    B) Tea");
   v_gtext(handle,6,43,"C) Ale      D) Wine");
   v_gtext(handle,6,51,"E) Spirits  F) Mead");
   v_gtext(handle,6,59,"G) Coffee   X) Exit");

while (!(Bconstat(2)))
  {
    v_gtext(handle,6,35," "); v_gtext(handle,102,35," ");
    v_gtext(handle,6,43," "); v_gtext(handle,102,43," ");
    v_gtext(handle,6,51," "); v_gtext(handle,102,51," ");
    v_gtext(handle,6,59," "); v_gtext(handle,102,59," ");

     pauser();
    v_gtext(handle,6,35,"A"); v_gtext(handle,102,35,"B");
    v_gtext(handle,6,43,"C"); v_gtext(handle,102,43,"D");
    v_gtext(handle,6,51,"E"); v_gtext(handle,102,51,"F");
    v_gtext(handle,6,59,"G"); v_gtext(handle,102,59,"X");

     pauser();

   }
   do
   {
    com2 = Bconin(2);
   }while( com2 !='A' && com2 != 'a' && com2 !='B' && com2 != 'b' &&
           com2 !='C' && com2 != 'c' && com2 !='D' && com2 != 'd' &&
           com2 !='E' && com2 != 'e' && com2 !='F' && com2 != 'f' &&
           com2 !='G' && com2 != 'g' && com2 !='X' && com2 != 'x' );
   g = abs(rnd(15)); /* the  base price of everything */
   g += 20; /* the price */
   clear_it();
  
 if( com2 != 'x' && com2 != 'X' )   /* if not exit.. */
    {
   sprintf(string,"It'll cost: %d gp",g);
   v_gtext(handle,6,11,string);
   v_gtext(handle,6,27,"Still want it [y/n]");
   com=Bconin(2);
   if(com == 'Y' || com == 'y')
   {
   if( user.gold < g ){
           v_gtext(handle,6,11,"You have not the funds");
           pause();
                      }
    else
     if( com2 != 'C' && com2 != 'c') /* if ale not chosen */
      {
        if(com2 =='A' || com2 =='a') user.user_items[1]++;    /* store your water */
        v_gtext(handle,6,11,"Enjoy your drink!");
        pause();
        user.gold -=g;       /* update gold */
       }
     
        else /* else you chose to buy Ale */
       {clear_it();
        v_gtext(handle,6,11,"We seem to be out of");
        v_gtext(handle,6,19,"Ale, do you want to go");
        v_gtext(handle,6,27,"down to the cellar and");
        v_gtext(handle,6,35,"get your own? [y/n]");
while (!(Bconstat(2)))
  {
    v_gtext(handle,126,35,"   ");
       pauser();
    v_gtext(handle,126,35,"y/n");
       pauser();
   }
  
        com2=Bconin(2);
        if( com2 == 'Y' || com2 == 'y' )
           {
            clear_it();
              v_gtext(handle,6,11,"As you make your way");
              v_gtext(handle,6,19,"down the creaky stairs");
              v_gtext(handle,6,27,"You get the feeling ");
              v_gtext(handle,6,35,"that this might not be");
              v_gtext(handle,6,43,"such a great idea. ");
              v_gtext(handle,6,51,"Finally you come upon");
              v_gtext(handle,6,59,"a mighty vallenwood ");
              v_gtext(handle,6,67,"door.");
              v_gtext(handle,6,75,"(U) to go back up or");
              v_gtext(handle,6,83,"(O) to open the door");
while (!(Bconstat(2)))
  {
    v_gtext(handle,14,75," "); v_gtext(handle,14,83," ");   
     pauser();
    v_gtext(handle,14,75,"U"); v_gtext(handle,14,83,"O");
     pauser();
   }

              com2=Bconin(2);
             clear_it();
             if(com2 == 'O' || com2 == 'o')
              {
              v_gtext(handle,6,11,"The door opens with");
              v_gtext(handle,6,19,"a mighty creak.....");
              invoke_tsr( open1 );
              if( user.user_items[3] == 0 )
              {
               v_gtext(handle,6,35,"You dont have any ");
               v_gtext(handle,6,43,"torches,so you return");
               v_gtext(handle,6,51,"back to the surface..");
               
              }
              else if( user.user_items[15] == 1) /* if you've already been here.. */
              {user.user_items[3]--; /* use a torch */
               v_gtext(handle,6,27,"You grap a mug of");
               v_gtext(handle,6,35,"ale and return up");
               v_gtext(handle,6,43,"to the surface...");
               
              }
              else
              {
              user.user_items[3]--;      /* use up a torch.. */
              v_gtext(handle,6,27,"The cellar reeks of");
              v_gtext(handle,6,35,"the musty odor of ");
              v_gtext(handle,6,43,"stale beer. You spot");
              v_gtext(handle,6,51,"the keg of ale and ");
              v_gtext(handle,6,59,"head towards it.... ");
              v_gtext(handle,6,67,"As you apporach the ");
              v_gtext(handle,6,83,"anykey to continue.");
              com2=Bconin(2);
              clear_it();
              v_gtext(handle,6,11,"keg, something moves!");
              v_gtext(handle,6,19,"You go over to invest");
              v_gtext(handle,6,27,"igate...As you near  ");
              v_gtext(handle,6,35,"the far corner of the");
              v_gtext(handle,6,43,"cellar, a deformed");
              v_gtext(handle,6,51,"looking person steps");
              v_gtext(handle,6,59,"out of the shadows.. ");
              v_gtext(handle,6,67,"It speaks,    ");
              v_gtext(handle,6,83,"anykey to continue");
              com2=Bconin(2);
              clear_it();
              v_gtext(handle,6,11,"'Hail stranger..  ");
              v_gtext(handle,6,19,"I must be quick and");
              v_gtext(handle,6,27,"brief for much is at");
              v_gtext(handle,6,35,"stake! My enemies are");
              v_gtext(handle,6,43,"many and spies are ");
              v_gtext(handle,6,51,"everywhere...");
              v_gtext(handle,6,59,"You must run the ");
              v_gtext(handle,6,67,"Guantlet brave one!");
              v_gtext(handle,6,83,"press anykey.");
              com2=Bconin(2);
              clear_it();
              v_gtext(handle,6,11,"For the time of ");
              v_gtext(handle,6,19,"reckoning is    ");
              v_gtext(handle,6,27,"finally at hand!");
              v_gtext(handle,6,35,"He hands you a ");
              v_gtext(handle,6,43,"potion and then ");
              v_gtext(handle,6,51,"disappears....");
              user.user_items[10]++;  /* add a protection potion */
              user.user_items[15] = 1; /* set flag to tell that you have met this man */
              v_gtext(handle,6,67,"press anykey");
              com2=Bconin(2);
              clear_it();  
              v_gtext(handle,6,11,"You pocket the ");
              v_gtext(handle,6,19,"potion and head");
              v_gtext(handle,6,27,"back up the stairs");
              
              }
             }
           
           }
        else {v_gtext(handle,6,51,"Sorry for the ");
              v_gtext(handle,6,59,"inconvience..");}
        pause();
       }
      clear_it();
     }
     display_user_stats();         /* update stats */
    
   } /* end of Yes I  want to buy */ 
 }while(com2 != 'x' && com2 != 'X');   /* end of do until Exit chosen */
 } /* end of order a drink */

                               /* ORDER FOOD */

if ( com == 'F' || com =='f' )
  {
do       /* begin of do until Exit is chosen */
 {     
clear_it();
   v_justified(handle,6,11,"The inkeeper says,",184,0,1);
   v_gtext(handle,6,19,"Thy choice?");
   v_gtext(handle,6,35,"A) Bread     B) Soup");
   v_gtext(handle,6,43,"C) Sandwich  D) Pasta");
   v_gtext(handle,6,51,"E) Chicken   F) Lamb");
   v_gtext(handle,6,59,"G) Quail     X) Exit");
while (!(Bconstat(2)))
  {
    v_gtext(handle,6,35," "); v_gtext(handle,110,35," ");
    v_gtext(handle,6,43," "); v_gtext(handle,110,43," ");
    v_gtext(handle,6,51," "); v_gtext(handle,110,51," ");
    v_gtext(handle,6,59," "); v_gtext(handle,110,59," ");

     pauser();
    v_gtext(handle,6,35,"A"); v_gtext(handle,110,35,"B");
    v_gtext(handle,6,43,"C"); v_gtext(handle,110,43,"D");
    v_gtext(handle,6,51,"E"); v_gtext(handle,110,51,"F");
    v_gtext(handle,6,59,"G"); v_gtext(handle,110,59,"X");

     pauser();

   }

   do
   {
    com2 = Bconin(2);
   }while( com2 !='A' && com2 != 'a' && com2 !='B' && com2 != 'b' &&
           com2 !='C' && com2 != 'c' && com2 !='D' && com2 != 'd' &&
           com2 !='E' && com2 != 'e' && com2 !='F' && com2 != 'f' &&
           com2 !='G' && com2 != 'g' && com2 !='X' && com2 != 'x' );
   g = abs(rnd(40)); /* the  base price of everything */
   g += 15;  /* the price */
   clear_it();
   
      if( com2 != 'x' && com2 != 'X' )
       {
   sprintf(string,"It'll cost: %d gp",g);
   v_gtext(handle,6,11,string);
   v_gtext(handle,6,27,"Still want it [y/n]");
   com=Bconin(2);
   if(com == 'Y' || com == 'y')
   {
  
     if( user.gold < g ) v_gtext(handle,6,11,"You dont have the funds");
      else
       {
        switch(com2)
          {
           case 'a':case 'A': user.user_items[0]++;break;
           case 'b':case 'B': 
           case 'c':case 'C': user.user_items[0]+=2;break;
           case 'd':case 'D': user.user_items[0]+=3;break;
           case 'e':case 'E': user.user_items[0]+=5;break;
           case 'g':case 'G': user.user_items[0]+=5;break;

          }
        v_gtext(handle,6,11,"Enjoy your food....");
        user.gold -=g;       /* update gold */
        pause();
       }
      clear_it();
      display_user_stats();
      }
     
   } /* end of yes i want to buy */
 }while(com2 != 'X' && com2 != 'x');   /* end of do until Exit chosen */
 } /* end of order FOOD */


                                     /* TALK */
if ( com == 'T' || com =='t' )
 {

long int deposit_amount=0,temper;
 char com;
 int test=0;   /* if previous was 10 or > and then you went to 9.. clear */

 clear_it();
 v_gtext(handle,6,11,"Your coins in copper:");
 sprintf(string,"<%ld>",user.gold);
 v_gtext(handle,6,19,string);
 sprintf(string,"Bribe:%ld",deposit_amount);
 v_gtext(handle,6,35,string);
 v_gtext(handle,6,51,"Up arrow to increase");
 v_gtext(handle,6,59,"Down arrow to decrease");
 v_gtext(handle,6,67,"<Return> to confirm");
 v_gtext(handle,6,75,"bribe."); 
do
 {
 com2 = (char)(Bconin(2)>>16);
 if(com2 == 0x48) deposit_amount +=1;
 if(com2 == 0x50) deposit_amount -=1;
 if(deposit_amount < 0) deposit_amount =0;
 if(deposit_amount > user.gold) deposit_amount = user.gold;
temper = user.gold - deposit_amount;
sprintf(string,"<%ld>",temper);
 v_gtext(handle,6,19,string); 
if( test > 9 && deposit_amount == 9 || 
     test > 99 && deposit_amount == 99)   /* if previous was > 9 and now its 9, clear */
 v_gtext(handle,6,35,"               ");  /* clear */
 sprintf(string,"Bribe:%ld",deposit_amount);
 v_gtext(handle,6,35,string);
test = deposit_amount;
 }while( com2 != 0x1c); /* until return is pressed */
user.gold -=deposit_amount;  /* update user gold */


clear_it();

  if(deposit_amount < 10) { v_gtext(handle,6,11,"I would't roam the City");
                       v_gtext(handle,6,19,"at night.");}
  else if(deposit_amount < 25) { v_gtext(handle,6,11,"Swords are worth their");
                       v_gtext(handle,6,19,"weight in gold.");}
   else if(deposit_amount < 55) { v_gtext(handle,6,11,"Sell Gems/Jewels at");
                       v_gtext(handle,6,19,"the Bank.");}
   else if(deposit_amount < 75) { v_gtext(handle,6,11,"Don't give up on the");
                       v_gtext(handle,6,19,"Guilds, you will be");
                       v_gtext(handle,6,27,"worthy of them some");
                       v_gtext(handle,6,35,"day....");
                        } 
    else if(deposit_amount < 100) { v_gtext(handle,6,11,"Go visit the Castle.");
                         }
     else if(deposit_amount < 155) { v_gtext(handle,6,11,"Behind the Gates lie");
                       v_gtext(handle,6,19,"wonderous mysteries to");
                        v_gtext(handle,6,27,"unravel...");
                         }
    else if(deposit_amount < 230) { v_gtext(handle,6,11,"Our Ale is the best");
                       v_gtext(handle,6,19,"in the Region!");}
    else if(deposit_amount < 300) { v_gtext(handle,6,11,"Timepieces are invaluable.");
                       }

          
        

pause();

 } /* end of TALK */

                              
 } while( com != 'E' && com != 'e');   /* Stay in estab until Exit! */

}



guild()
{
char com,com2;
int prev = 0;

v_gtext(handle,197,99,"    Guild     ");
 /* execute sound of opening door..*/
    invoke_tsr( open2 );
clear_it();


do       /* main do , do until select Exit! */
{


 display_user_stats();         /* update stats */
 clear_it();                   /* clear screen */

 v_justified(handle,6,11,"The Guildmaster greets",184,0,1);
 v_gtext(handle,6,19,"you....");
 
 v_gtext(handle,6,35,"Welcome Seeker! What");
 v_gtext(handle,5,43,"may I do for you?");
 v_gtext(handle,6,59,"(J)oin our Guild  ");
 v_gtext(handle,6,67,"(R)emove All Curses");
 v_gtext(handle,6,75,"(E)xit");
while (!(Bconstat(2)))
  {
    v_gtext(handle,14,59," "); v_gtext(handle,14,67," ");
    v_gtext(handle,14,75," ");
     pauser();
    v_gtext(handle,14,59,"J"); v_gtext(handle,14,67,"R");
    v_gtext(handle,14,75,"E");
     pauser();

   }

   com = Bconin(2); 

    clear_it();
     

                        /* Remove curses */
       if ( com == 'R' || com =='r' )
      {

      v_justified(handle,6,11,"The Guildmaster says,",184,0,1);
      v_gtext(handle,6,19,"My services cost 1000gp");
      v_gtext(handle,6,27,"to remove curses.");
      v_gtext(handle,6,43,"Accept?  [y/n]");
  while (!(Bconstat(2)))
  {
    v_gtext(handle,86,43,"   "); 
     pauser();
    v_gtext(handle,86,43,"y/n"); 
     pauser();
   }

       do
      {
       com2 = Bconin(2);
      }while( com2 !='N' && com2 != 'n' && com2 !='Y' && com2 != 'y');
      if( com2 == 'Y' || com2 == 'y')
       { 
         clear_it();
     if( user.user_items[16] == 0 )  /* if you are NOT cursed! */
       v_gtext(handle,6,11,"You are not cursed.");
      else
     {
      if( user.gold < 1000 ) v_gtext(handle,6,11,"You dont have the funds");
       else
       {
        user.gold -=1000;
        user.user_items[16] = 0; /* set so no more curses */
        v_gtext(handle,6,19,"I have cured you...");
       }
      } /* end of if Yes chosen */
     } /* end of else you are cursed.. */
    } /* end of Remove Curses */

                               /* Join Guild */

if ( com == 'J' || com =='j' )
  {
  v_justified(handle,6,11,"The Guildmaster says,",184,0,1);
 
   if( user.user_items[17] == 1 )   /* if your already a member */
    {                                      
      v_gtext(handle,6,19,"You are already a");
      v_gtext(handle,6,27,"member...");
    }
   else if( user.user_items[19] && user.user_items[17] != 1 )   /* if you have the ring... */
    {                                        /* and you're not already a member */
      v_gtext(handle,6,19,"Ah Seeker!    ");
      v_gtext(handle,6,27,"You have proved your");
      v_gtext(handle,6,35,"self and we welcome");
      v_gtext(handle,6,43,"you into our Order.");
      user.user_items[17] = 1; /* now your a member... */
    }
  else
   {
   v_gtext(handle,6,19,"Sorry, We are not ");
   v_gtext(handle,6,27,"accepting new members");
   v_gtext(handle,6,35,"at this time...");
   }
   pause();
 } /* end of join Guild */


}while(com != 'E' && com != 'e');

} /* end of Guild */




weapon()
{
 
v_gtext(handle,197,99,"   Weaponry   ");
 /* execute sound of opening door..*/
    invoke_tsr( open2 );
  
 }

armour()
{
 
v_gtext(handle,197,99,"    Armory    ");
 /* execute sound of opening door..*/
    invoke_tsr( open2 );
  
}

castle(mf_src,mf_dest,pxyarray,scr5)
register MFDB *mf_src,*mf_dest;   /* the src and dest MFDBs!! */
char *scr5; /* misc3.dat */
int pxyarray[8];

{
        /* you can be healed 20 times max! */
        int s_ave[4],f;

clear_it();
 
v_gtext(handle,197,99,"    Castle    ");
if(user.user_items[18] == 1)
 {
  v_gtext(handle,6,11,"The king will not see");
  v_gtext(handle,6,19,"you anymore.");
 }

if(user.user_items[18] == 0)
{ 

for(f=0;f<4;f++) s_ave[f] = pxyarray[f]; /*save array */

            mf_src->fd_addr = (long) scr5; /* copy address */
   
           pxyarray[0] = 70;
      pxyarray[1] = 93;  /* get the src rectangle */
      pxyarray[2] = 192;
      pxyarray[3] = 181; 
      
         





      
      

      if( user.user_items[20] == 0  )        /* do this ONLY ONCE! */
     {                
       user.user_items[20] = 1;
       v_gtext(handle,6,11,"As you enter the Castle");
       v_gtext(handle,6,19,"you can't help but ");
       v_gtext(handle,6,27,"notice the Honor Guard");
       v_gtext(handle,6,35,"that keeps watch over");
       v_gtext(handle,6,43,"everyone who enters..");
       v_gtext(handle,6,51,"You pass by statues of");
       v_gtext(handle,6,59,"great warriors, past ");
       v_gtext(handle,6,67,"kings and strange and ");
       v_gtext(handle,6,75,"mysterious monsters.");
       pause(); clear_it();
     
       v_gtext(handle,6,11,"Finally you come to the");
       v_gtext(handle,6,19,"entrance of the Throne");
       v_gtext(handle,6,27,"Room.");
       v_gtext(handle,6,35,"Guarding the entrance ");
       v_gtext(handle,6,43,"is the Captain of the ");
       v_gtext(handle,6,51,"Guard. He looks at you,");
       v_gtext(handle,6,59,"seems to begin to say ");
       v_gtext(handle,6,67,"something, but he just");
       v_gtext(handle,6,75,"nods his head to you ");
       v_gtext(handle,6,83,"and opens the door....");
       pause();
       invoke_tsr( open1 );
       clear_it();

       vro_cpyfm(handle,3,pxyarray,mf_src,mf_dest);

       v_gtext(handle,6,11,"As you enter the Throne");
       v_gtext(handle,6,19,"Room, you see pages and");
       v_gtext(handle,6,27,"couriers going about");
       v_gtext(handle,6,35,"their daily business.");
       v_gtext(handle,6,43,"Suddenly the king ");
       v_gtext(handle,6,51,"shouts   'SILENCE!!'");
       v_gtext(handle,6,59,"The room becomes very");
       v_gtext(handle,6,67,"quiet and all eyes turn");
       v_gtext(handle,6,75,"towards you......" );
       pause(); clear_it();
      
       v_gtext(handle,6,11,"The King speaks,");
       v_gtext(handle,6,19,"'Greetings");
       v_gtext(handle,6,27,user.name);
       v_gtext(handle,6,35,"'Come foreword...'");
       v_gtext(handle,6,43,"You cautiously approach");
       v_gtext(handle,6,51,"the throne.");
       v_gtext(handle,6,59,"As you approach the ");
       v_gtext(handle,6,67,"throne, he talks:");
       v_gtext(handle,6,75,"'I need a Champion, but");
       v_gtext(handle,6,84,"thou are not ready. Go");
          pause(); clear_it();
       v_gtext(handle,6,11,"and master your chosen");
       v_gtext(handle,6,19,"profession and become");
       v_gtext(handle,6,27,"wiser and stronger...");
       v_gtext(handle,6,35,"Then return to me.'");
      
       v_gtext(handle,6,43,"You bow to the King and");
       v_gtext(handle,6,51,"make a hasty retreat ");
       v_gtext(handle,6,59,"outside....");
        
   }
    
   else
      {
        if(user.user_items[17]  && user.user_items[18]==0) {
                            vro_cpyfm(handle,3,pxyarray,mf_src,mf_dest);

                            v_gtext(handle,6,11,"The King speaks...");
                            pause(); clear_it();
                           v_gtext(handle,6,11,"Thou hast show thy");
                           v_gtext(handle,6,19,"courage and valor.");
                           v_gtext(handle,6,27,"Thou are now ready..");
                           v_gtext(handle,6,35,"Take this talisman, It");
                           v_gtext(handle,6,43,"will allow you to pass");
                           v_gtext(handle,6,51,"through the entrance");
                           v_gtext(handle,6,59,"that leads to the");
                           v_gtext(handle,6,67,"Catacombs that lie");
                           v_gtext(handle,6,75,"beneath the City.");
                           pause(); clear_it();
                           v_gtext(handle,6,11,"There you may find");
                           v_gtext(handle,6,19,"your destiny......");
                           
                            v_gtext(handle,6,35,"As you take the rod,");
                           if( (strcmp(user.align,"Good")) == 0)
                           { 
                           v_gtext(handle,6,43,"you shudder at the ");
                           v_gtext(handle,6,51,"malignant evil that");
                           v_gtext(handle,6,59,"emits from the ancient");
                           v_gtext(handle,6,67,"artifact");
                           user.hp = user.hp - 5L;
                           }
                           else
                           {
                           v_gtext(handle,6,43,"a feeling of power");
                           v_gtext(handle,6,51,"courses through your");
                           v_gtext(handle,6,59,"body...");
                           }
                           v_gtext(handle,6,75,"You bow to the King");
                           v_gtext(handle,6,83,"and leave the castle.");
                           user.user_items[18] = 1; /* lets you pass
                                                        into the dungeon */

                     } /* end of you are worthy */
                           
                           
        else
          {
           if( user.hp == user.max_hp)
           {
           vro_cpyfm(handle,3,pxyarray,mf_src,mf_dest);

           v_gtext(handle,6,11,"You are not yet ");
           v_gtext(handle,6,19,"worthy...");
           }
           else if( user.way < 21)
                 { 
                   vro_cpyfm(handle,3,pxyarray,mf_src,mf_dest);
                   v_gtext(handle,6,11,"The King speaks..");
                   v_gtext(handle,6,19,"Let me heal thy wounds");
                   v_gtext(handle,6,27,user.name);
                   user.way++;  /* max 20 times to be healed */  
                   user.hp = user.max_hp;
                 }
          }

      }
    for(f=0;f<4;f++)  pxyarray[f]= s_ave[f]; /*restore array */
  pause();
 } /* end of if user.useritems[18] == 0 */

} /* end of castle */


supply()
{
                       
v_gtext(handle,197,99,"   Supply     ");
 /* execute sound of opening door..*/
     invoke_tsr( open2 );
  


}

tower(mf_src,mf_dest,pxyarray,scr6,scr4)
register MFDB *mf_src,*mf_dest;   /* the src and dest MFDBs!! */
char *scr6,*scr4; /* misc3.dat */
int pxyarray[8];

{
char com;
int run;  /* set this for encounter, to tell it to load up
                 the demon lord you'll fight */
static int been_here = 0;

v_gtext(handle,197,99,"    Tower     ");
clear_it();

 if( !been_here )
      {
       v_gtext(handle,6,11,"You open the gate ");
       v_gtext(handle,6,19,"that leads to the");
       v_gtext(handle,6,27,"courtyard. Finally");
       v_gtext(handle,6,35,"you spot the mighty");
       v_gtext(handle,6,43,"door that is the towers");
       v_gtext(handle,6,51,"only entrance....");
       v_gtext(handle,6,59,"You make haste and open");
       v_gtext(handle,6,67,"the door.");
       invoke_tsr( open1 );
       pause(); clear_it();
        mf_src->fd_addr = (long) scr4; /* copy address */
   
           pxyarray[0] = 70;
      pxyarray[1] = 93;  /* get the src rectangle */
      pxyarray[2] = 192;
      pxyarray[3] = 181; 
         
          vro_cpyfm(handle,3,pxyarray,mf_src,mf_dest);


       v_gtext(handle,6,11,"Once inside you find");
       v_gtext(handle,6,19,"yourself in the private");
       v_gtext(handle,6,27,"audience chamber of the");
       v_gtext(handle,6,35,"Wizard, Wall hangings ");
       v_gtext(handle,6,43,"depicting great battles");
       v_gtext(handle,6,51,"and arcane symols, hang");
       v_gtext(handle,6,59,"on walls made of dark"); 
       v_gtext(handle,6,67,"panneling. The floor ");
       v_gtext(handle,6,75,"seems to be made of ");
       v_gtext(handle,6,83,"smooth black marble. ");
        pause(); clear_it();
        v_gtext(handle,6,11,"As you continue to ");
       v_gtext(handle,6,19,"admire the surroundings");
       v_gtext(handle,6,27,"you notice a body ");
       v_gtext(handle,6,35,"lying in the middle of");
       v_gtext(handle,6,43,"The room. You go over");
       v_gtext(handle,6,51,"to investigate....");
       v_gtext(handle,6,59,"As you come up to the");
       v_gtext(handle,6,67,"body, you notice that");
       v_gtext(handle,6,75,"it lies a in circle ");
       v_gtext(handle,6,83,"with arcane symbols all");
      pause(); clear_it();
        v_gtext(handle,6,11,"along its perimiter.");
      
       v_gtext(handle,6,27,"Do you wish to enter?");
       v_gtext(handle,6,35,"[Y/N]");
       if ( (com=Bconin(2)) == 'Y' || (com == 'y' ))
       {       
       v_gtext(handle,6,43,"As you attempt to step");
       v_gtext(handle,6,51,"inside the circle, ");
       v_gtext(handle,6,59,"you get a mighty shock"); 
       v_gtext(handle,6,67,"as some unseen force ");
       v_gtext(handle,6,75,"prevents you from ");
       v_gtext(handle,6,83,"entering..");
       user.hp -=5; if(user.hp <= 0){ clear_it(); v_gtext(handle,6,11,"you died.."); exit(1);}
       pause(); clear_it();
       v_gtext(handle,6,11,"A high pitched wail");
       v_gtext(handle,6,19,"shudders your entire ");
       v_gtext(handle,6,27,"being..Mabey entering");
       v_gtext(handle,6,35,"the circle wasn't such ");
       v_gtext(handle,6,43,"a great idea...");
       v_gtext(handle,6,51,"The air begins to  ");
       v_gtext(handle,6,59,"shimmer in front of you"); 
       v_gtext(handle,6,67,"Suddenly, before your");
       v_gtext(handle,6,75,"eyes, a portal appears");
       v_gtext(handle,6,83,"and out of it stepps a");
       pause(); clear_it();
        v_gtext(handle,6,11,"mighty demon!");
       
       v_gtext(handle,6,27,"It speaks,");
       v_gtext(handle,6,35,"'Foolish mortal!! Do ");
       v_gtext(handle,6,43,"you dare free my ");
       v_gtext(handle,6,51,"prisoner? For you ");
       v_gtext(handle,6,59,"shall pay dearly ");
       v_gtext(handle,6,67,"indeed........      ");
       run = -999; /* set flag for encounter */
       encounter(mf_src,mf_dest,pxyarray,scr6,&run);
       /* if you get back to this point, you defeated him.. */
       clear_it();
       if( !run )   /* if you did not run */
       {            
       v_gtext(handle,6,11,"You slump to the ");
       v_gtext(handle,6,19,"floor, barely able to"); 
       v_gtext(handle,6,27,"breathe. The room ");
       v_gtext(handle,6,35,"begins to spin around ");
       v_gtext(handle,6,43,"you as slip into uncon-");
       v_gtext(handle,6,51,"ciousness...");
      
       pause(); clear_it();
       v_gtext(handle,6,11,"You have a deep, ");
       v_gtext(handle,6,19,"troubled sleep. You"); 
       v_gtext(handle,6,27,"dream of dragons and");
       v_gtext(handle,6,35,"worse. A figure in  ");
       v_gtext(handle,6,43,"white robes appears ");
       v_gtext(handle,6,51,"before you, he speaks");
      
       v_gtext(handle,6,67,"'Hail, Brave One!   ");
       v_gtext(handle,6,75,"I am Lomir,    "); 
       v_gtext(handle,6,83,"you have freed me from");
       
       pause(); clear_it();
       v_gtext(handle,6,11,"my tormentor, the  ");
       v_gtext(handle,6,19,"Great Demon Lord, "); 
       v_gtext(handle,6,27,"Ziarat. I owe you  ");
       v_gtext(handle,6,35,"my life, and more..");
       v_gtext(handle,6,43,"After your battle, ");
       v_gtext(handle,6,51,"you died from the ");
      v_gtext(handle,6,59,"wounds you recieved. ");   
       v_gtext(handle,6,67,"I have been working");
       v_gtext(handle,6,75,"for days, trying to ");
       
       pause();clear_it();
       v_gtext(handle,6,11,"create a spell that");
       v_gtext(handle,6,19,"will bring you back"); 
       v_gtext(handle,6,27,"to the world of the");
       v_gtext(handle,6,35,"living. At last I ");
       v_gtext(handle,6,43,"have succeded, I ");
       v_gtext(handle,6,51,"give you this ring,");
      v_gtext(handle,6,59,"Take it to one of the");   
       v_gtext(handle,6,67,"Guilds and you will");
       v_gtext(handle,6,75,"be rewarded..");
       
       pause();clear_it();
       v_gtext(handle,6,11,"Know that there are");
       v_gtext(handle,6,19,"catacombs below the"); 
       v_gtext(handle,6,27,"City. The only way ");
       v_gtext(handle,6,35,"below is near my ");
       v_gtext(handle,6,43,"tower but it is ");
       v_gtext(handle,6,51,"protected by an ");
      v_gtext(handle,6,59,"ancient spell that ");   
       v_gtext(handle,6,67,"blocks anyone from ");
       v_gtext(handle,6,75,"entering. Make haste");
       
       pause();clear_it();
       v_gtext(handle,6,11,"for we have little ");
       v_gtext(handle,6,19,"time left!");
       
       v_gtext(handle,6,35,"Lomir begins to ");
       v_gtext(handle,6,43,"chant and you are");
       v_gtext(handle,6,51,"teleported to....");
      pause();
      invoke_tsr( CAST );
       user.user_items[19] = 1; /* ring */
       x = 6;
       y = 11;    /* teleport you here */
       dir = 'E'; 
       been_here = 1; /* flag, so you will not see this ever again */
       } /* end of you defeated monster abnd didnt run */
       else
         {
         clear_it();
            v_gtext(handle,6,11,"As you attempt to run");
            v_gtext(handle,6,19,"for your life, you ");
            v_gtext(handle,6,27,"feel a talon impail");
            v_gtext(handle,6,35,"you...The last thing");
            v_gtext(handle,6,43,"you head before you die");
            v_gtext(handle,6,51,"is an evil laughter...");
            user.hp = 0;
            pause();
            exit(0);
         }
       }
       
   } /* end of ! been_here */
   
 else
    v_gtext(handle,6,11,"The Tower is empty.....");


  

}

outside()
{}

enter_room(mf_src,mf_dest,pxyarray,scr6)
register MFDB *mf_src,*mf_dest;   /* the src and dest MFDBs!! */
char *scr6;
int pxyarray[8];
{
  int anyone_home;
  char com;

  clear_it();
  v_justified(handle,6,19,"You open the door and.....",184,0,1);
   /* execute sound of opening door..*/
    invoke_tsr( open1 );
  

   /* load up inside house pic here! */
   anyone_home = pos_rnd(100);
  
    if (anyone_home > 90 )    /* someone is here */
     {
      v_gtext(handle,6,19,"As you charge through");
      v_gtext(handle,6,27,"the door, you feel an");
      v_gtext(handle,6,35,"evil presence.");
      v_gtext(handle,6,59," press any key");
     
       com =Bconin(2); 
       encounter(mf_src,mf_dest,pxyarray,scr6,&anyone_home);
      } 
    else 
       {
       v_justified(handle,6,27,"The house is empty.",184,0,1);
        v_gtext(handle,6,59," press any key");
     
        com =Bconin(2); 
      
       }
}

/** 
   arena()
**/


arena(mf_src,mf_dest,pxyarray,scr3,scr6)
register MFDB *mf_src,*mf_dest;   /* the src and dest MFDBs!! */
char *scr3,*scr6; /* addrs of gate.dat and misc3.dat */
int pxyarray[8];
{
 char com;
 int run = 0 ; /* if 1 then you ran from a monster in the gauntlet */

 v_gtext(handle,197,99,"     Arena     ");

do
{
 v_gtext(handle,6,11,"You boldly enter the ");
 v_gtext(handle,6,19,"Arena. There are many");
 v_gtext(handle,6,27,"Warriors milling about,");
 v_gtext(handle,6,35,"awaiting their turn.");
 v_gtext(handle,6,51,"The clerk that is ");
 v_gtext(handle,6,59,"sitting behind a desk");
 v_gtext(handle,6,67," says, 'Next!' and you");
 v_gtext(handle,6,75,"step up...");
 v_gtext(handle,6,83,"  <Hit any key..>");
 com = Bconin(2);
 clear_it();
 v_gtext(handle,6,11,"He looks you over and");
 v_gtext(handle,6,19,"says 'whatcha want?'");
 v_gtext(handle,6,35,"R)un the Guantlet");
 v_gtext(handle,6,43,"B)et on a Battle ");
 v_gtext(handle,6,51,"T)raining        ");
 v_gtext(handle,6,59,"E)xit            ");
while (!(Bconstat(2)))
  {
    v_gtext(handle,6,35," "); 
    v_gtext(handle,6,43," "); 
    v_gtext(handle,6,51," "); 
    v_gtext(handle,6,59," "); 

     pauser();
    v_gtext(handle,6,35,"R");
    v_gtext(handle,6,43,"B"); 
    v_gtext(handle,6,51,"T"); 
    v_gtext(handle,6,59,"E"); 

     pauser();

   }

do
{
 com = Bconin(2);
}
 while ( com != 'R' && com !='r' && com != 'B' && com != 'b' &&
         com != 'T' && com !='t' && com != 'E' && com != 'e'  );

if( com != 'E' && com != 'e' )    /* if exit not picked .. */
  {
   if(com == 'R' || com == 'r' )
   { run=gauntlet(mf_src,mf_dest,pxyarray,scr6);
       if( run == 1 ) com = 'E'; /* so you'l be thrown out! */
   }
   if(com == 'B' || com == 'b' )
    bet();
   if(com == 'T' || com == 't' )
    training();

   } /* end of exit not picked  */

}while (com != 'E' && com != 'e' );


}

/** Run gauntlet 

    You must fight 10 monsters in a row before you have an option
    to quit. Counter % 10 tests for this.
**/
gauntlet(mf_src,mf_dest,pxyarray,scr6)
register MFDB *mf_src,*mf_dest;   /* the src and dest MFDBs!! */
char *scr6;
int pxyarray[8];
{
 int counter=0;    /* the gauntlet count. If you kill 50 monsters.
                      you ran the gauntlet.. */
 char com;
 int exit = 0;    /* you must fight 10 monsters in a row before 
                  you have an option to quit! Thus Counter%10
                  tests for this...*/
 int run=0; /* if you Run from an encounter, then you will be labeled
             a coward and will loose half your gold! */
 int grab; /* random roll if you run, you'll loose this # of gold */
clear_it();

do
{ 
com = '0'; /* just a dummy value.. */

encounter(mf_src,mf_dest,pxyarray,scr6,&run);
if( run == 1) /* if you ran from an encounter while in the Gauntlet, then
             you'll be screwed!! */
 {
  clear_it();
  v_gtext(handle,6,11,"The crowd laughs at ");
  v_gtext(handle,6,19,"your cowardance! Two");
  v_gtext(handle,6,27,"burly guards grab you");
  v_gtext(handle,6,35,"and dump you outside.");
  v_gtext(handle,6,43,"As they turn to leave, ");
  v_gtext(handle,6,51,"one of the guards grabs");
  v_gtext(handle,6,59,"some of your gold.");
  grab = rnd(user.gold);
  user.gold -=grab;
  pause();
  return(1); /* tell calling module you ran */
 }

if( !run )
{
counter++;
 pause();
 if(counter < 50 && counter%10 == 0) /* if just didnt kill last monster
                                        and you've fought 10 monsters..*/
 {
   v_gtext(handle,6,11,"The crowd cheers your");
   v_gtext(handle,6,19,"victory!!");
   invoke_tsr( applause );
   v_gtext(handle,6,35,"(C)ontinue or (Q)uit");
   while (!(Bconstat(2)))
  {
    v_gtext(handle,14,35," "); v_gtext(handle,126,35," ");
   
     pauser();
    v_gtext(handle,14,35,"C"); v_gtext(handle,126,35,"Q");
   
     pauser();

   }

    do
    {
     com = Bconin(2);
    }while(com != 'C' && com != 'c' && com != 'Q' && com !='q');
 } /* end of counter < 50 */

    clear_it();  
   
    if( com == 'Q' || com == 'q' ) exit = 1;  /* exit. */
    if( exit == 1 && count < 50 ) /* if you exit and didnt finish
                                     the gauntlet... */
     {
      v_gtext(handle,6,11,"The crowd jeers you!!");
      pause();
     }

   if( counter == 50 )  /* you ran it !! */
    exit = 1;    

} /* end of ! run */
}while( !exit);
                       /* if you ran the guantlet and you 
                          havent done it before... */
  if( counter == 50 && user.user_items[14] != 1)
 {
  clear_it();
  v_gtext(handle,6,11,"The crowd goes wild!!");
  v_gtext(handle,6,19,"You ran the Gauntlet!");
  v_gtext(handle,6,35,"As you stagger out of ");
  v_gtext(handle,6,43,"the Arena towards the ");
  v_gtext(handle,6,51,"front gate,an apparat-");
  v_gtext(handle,6,59,"ion appears before you");
  v_gtext(handle,6,83,"<  press any key  >  ");
  com = Bconin(2);
   clear_it();
  v_gtext(handle,6,11,"It speaks...");
  v_gtext(handle,6,27,"You have proved your");
  v_gtext(handle,6,35,"valor to my master. ");
  v_gtext(handle,6,43,"He sends his greetings");
  v_gtext(handle,6,51,"..and this scroll. We ");
  v_gtext(handle,6,59,"shall meet again brave");
  v_gtext(handle,6,67,"One! ");
  v_gtext(handle,6,83,"<  press any key  >  ");
  com = Bconin(2);
   clear_it();        
  v_gtext(handle,6,11,"It disappears in a ");
  v_gtext(handle,6,19,"cloud of smoke. You");
  v_gtext(handle,6,27,"bend down to pick up");
  v_gtext(handle,6,35,"the scroll and wonder");
  v_gtext(handle,6,43,"what the hell that was");
  v_gtext(handle,6,51,"all about and slowly  ");
  v_gtext(handle,6,58,"unroll the scroll.....");
  v_gtext(handle,6,83,"<  press any key  >  ");
  com=Bconin(2);
   clear_it();        
  
  v_gtext(handle,6,19,"'You must come to me  ");
  v_gtext(handle,6,27,"at once. This key will");
  v_gtext(handle,6,35,"allow you to pass    ");
  v_gtext(handle,6,43,"through the gate that");
  v_gtext(handle,6,51,"guards my tower...   ");
  v_gtext(handle,6,58,"Be warned, my enemies");
  v_gtext(handle,6,83,"<  press any key  >  ");
  com=Bconin(2);
   clear_it();        
  v_gtext(handle,6,11,"will stop at nothing");
  v_gtext(handle,6,19,"to obtain this key! ");
  v_gtext(handle,6,27,"      -Lomir'  ");
  
  v_gtext(handle,6,51,"You grab the key    ");
  v_gtext(handle,6,59,"from the parchment  ");
  v_gtext(handle,6,67,"and make haste to-  ");
  v_gtext(handle,6,75,"wards the Arena gate");
  v_gtext(handle,6,83,"<  press any key >  ");
  com=Bconin(2);

  user.user_items[14] = 1;  /* give you the key */
  }

}

/** Bet()

    Bet on a fighter.

**/

bet()
{
 char com;
 int con_bonus,roll3;

  clear_it();
  v_gtext(handle,6,11,"Ah! the sporting type!");
  v_gtext(handle,6,19,"Just remember, anything");
  v_gtext(handle,6,27,"can happen in the arena");
  v_gtext(handle,6,43,"Who do you want to bet");
  v_gtext(handle,6,51,"on?");
  v_gtext(handle,6,59,"A) The Fighter  ");
  v_gtext(handle,6,67,"B) The Monster  ");
  v_gtext(handle,6,75,"E) Exit         ");
  v_gtext(handle,6,83,"Choice:");
  while (!(Bconstat(2)))
  {
    v_gtext(handle,6,59," "); 
    v_gtext(handle,6,67," ");
    v_gtext(handle,6,75," "); 

     pauser();
    v_gtext(handle,6,59,"A");
    v_gtext(handle,6,67,"B"); 
    v_gtext(handle,6,75,"E"); 
     pauser();

   }

 do
 {
  com = Bconin(2);
 }while( com !='A' && com !='a' && com !='B' && com!='b' && com !='E'
        && com !='e');
clear_it();
 if( user.gold < 20) v_gtext(handle,6,11,"Min. bet is 20gp!");
 if((com == 'B' || com == 'b' || com == 'A' || com == 'a') && user.gold >= 20)
  {
    roll3 = abs(rnd(100));  /* 100%. you have a 20% base chance! */
    con_bonus = user.con - 18; if(con_bonus < 0) con_bonus =0;
    roll3 +=con_bonus;
    if( roll3 > 80 )
     {
      v_gtext(handle,6,11,"You won 20 gp!");
      user.gold +=20;
     }
    else
     {
      v_gtext(handle,6,11,"Sorry, you lost..");
      user.gold -=20;
     }
    }/* end of not exit and gold > 20 */

pause();
}

/** 
    training()

**/
training()
{
char com;
int g,check_random;

clear_it();
do
{
  v_gtext(handle,6,11,"So yo wanna hone your");
  v_gtext(handle,6,19,"skills? Well we have ");
  v_gtext(handle,6,27,"the best instructors");
  v_gtext(handle,6,35,"around. (only 3000gp)");
  v_gtext(handle,6,51,"Practice what skill:");
  v_gtext(handle,6,59,"A) Strength");
  v_gtext(handle,6,67,"B) Dexterity");
  v_gtext(handle,6,75,"C) Intelligence");
  v_gtext(handle,6,83,"E) Exit");
while (!(Bconstat(2)))
  {
    v_gtext(handle,6,59," "); 
    v_gtext(handle,6,67," "); 
    v_gtext(handle,6,75," "); 
    v_gtext(handle,6,83," "); 

     pauser();
    v_gtext(handle,6,59,"A");
    v_gtext(handle,6,67,"B"); 
    v_gtext(handle,6,75,"C"); 
    v_gtext(handle,6,83,"E"); 

     pauser();

   }


 com = Bconin(2);
}
 while ( com != 'A' && com !='a' && com != 'B' && com != 'b' &&
         com != 'C' && com !='c' && com != 'E' && com != 'e'  );
clear_it();
if(user.gold < 3000){ v_gtext(handle,6,11,"You have not the");
                      v_gtext(handle,6,19,"funds...."); pause();}
else if( com != 'E' && com != 'e' )
 {
    v_gtext(handle,6,11,"Training..");
    user.gold -= 3000;
    for(g=0;g<3;g++)
      { 
        time = HOUR_VALUE; /* set so that an hour has passed */ 
      sleeppause();                /* train and update time at same time */
      check_random=events(); /* update events while working */
      
     }

   if(com == 'A' || com == 'a') user.str++;
   if(com == 'B' || com == 'b') user.dex++;
   if(com == 'C' || com == 'c') user.inte++;
   
 }
                     
 
}


/***/
dungeon()
{
char com;


v_gtext(handle,197,99,"   Dungeon    ");
clear_it();
  if( user.user_items[18] == 1 )                   /* lets you pass*/
    {                                              /*    into the dungeon */
      
       v_gtext(handle,6,11,"Enter the Dungeon?");
       v_gtext(handle,6,19,"[Y/N]             ");
       com = Bconin(2);
       if(com == 'Y' || com == 'y')
          {
           v_gtext(handle,6,35,"Insert the DUNGEON");
           v_gtext(handle,6,43,"into the drive and");
           v_gtext(handle,6,51,"press RETURN");
           com = Bconin(2);
          }
    }  
  else
    {
     v_gtext(handle,6,11,"An unseen force blocks");
     v_gtext(handle,6,19,"you from entering...");
    }
}



/** 
    Bank()

**/
bank()
{
 char com;
 
v_gtext(handle,197,99,"    Bank     ");

invoke_tsr( open2 );
if( count > 18 || count < 10 ) v_gtext(handle,6,19,"The Bank is closed.");
else
{
Kbrate(17,3);  

do
{
  clear_it();
  v_gtext(handle,6,11,"A stuffy looking clerk");
  v_gtext(handle,6,19,"approaches you and says");
  v_gtext(handle,6,27,"' How may I help you '");
  v_gtext(handle,6,43,"  (S)ell Gems/Jewels");
  v_gtext(handle,6,51,"  (D)eposit Gold    ");
  v_gtext(handle,6,59,"  (W)ithdraw Gold   ");
  v_gtext(handle,6,67,"  (E)xit            ");
  
  v_gtext(handle,6,83,"Choice:");
  while (!(Bconstat(2)))
  {
    v_gtext(handle,30,43," "); v_gtext(handle,30,51," ");
    v_gtext(handle,30,59," "); v_gtext(handle,30,67," ");
     pauser();
   v_gtext(handle,30,43,"S"); v_gtext(handle,30,51,"D");
    v_gtext(handle,30,59,"W"); v_gtext(handle,30,67,"E");    
  pauser();

   }

 do
 {
  com = Bconin(2);
 }while( com !='S' && com !='s' && com !='D' && com!='d' && com !='W'
        && com !='w' && com != 'e' && com !='E');
 
clear_it(); 
  if( com == 'S' || com == 's' ) sell_gem_jewel();
  if( com == 'W' || com == 'w' ) withdraw();
  if( com == 'D' || com == 'd' ) deposit();
  
display_user_stats();

 }while( com != 'E' && com !='e' );
Kbrate(255,255);  /* reset to no repeat.. */

} /* end of else */
} /* end of bank */
/**************************/
withdraw()
{
 long int withdraw_amount=0,bal;
 char com;
 int test=0;   /* if previous was 10 or > and then you went to 9.. clear */

 clear_it();

 bal = user.bank_balance; /* save balance as a cieling! */
 v_gtext(handle,6,11,"Your Balance is:");

 sprintf(string,"<%ld>",user.bank_balance);
 v_gtext(handle,6,19,string);
 sprintf(string,"Withdraw:%d",withdraw_amount);
 v_gtext(handle,6,27,string);

 v_gtext(handle,6,51,"Up arrow to increase");
 v_gtext(handle,6,59,"Down arrow to decrease");
 v_gtext(handle,6,67,"<Return> to confirm");
 v_gtext(handle,6,75," withdraw"); 
do
 {
 com = (char)(Bconin(2)>>16);
 if(com == 0x48) withdraw_amount +=1;
 if(com == 0x50) withdraw_amount -=1;
 if(withdraw_amount < 0) withdraw_amount =0;
 if(withdraw_amount > bal ) withdraw_amount = bal; /* upper bound */
 if(com == 0x48) user.bank_balance -=1;
 if(com == 0x50) user.bank_balance +=1; 
 if(user.bank_balance < 0) user.bank_balance = 0;
 if(user.bank_balance > bal) user.bank_balance = bal;
 sprintf(string,"<%ld>",user.bank_balance);
 v_gtext(handle,6,19,string);
 if( test > 9 && withdraw_amount == 9 || 
     test > 99 && withdraw_amount == 99)   /* if previous was > 9 and now its 9, clear */
 v_gtext(handle,6,27,"               ");  /* clear */
 sprintf(string,"Withdraw:%ld",withdraw_amount);
 v_gtext(handle,6,27,string);
 test = withdraw_amount;

 }while( com != 0x1c); /* until return is pressed */
user.gold +=withdraw_amount;  /* update user gold */
v_gtext(handle,6,75,"Thank You!");
pause();


 }


deposit()
{
 long int deposit_amount=0,temper;
 char com;
 int test=0;   /* if previous was 10 or > and then you went to 9.. clear */

 clear_it();
 v_gtext(handle,6,11,"Your coins in copper:");
 sprintf(string,"<%ld>",user.gold);
 v_gtext(handle,6,19,string);
 sprintf(string,"Deposit:%ld",deposit_amount);
 v_gtext(handle,6,35,string);
 v_gtext(handle,6,51,"Up arrow to increase");
 v_gtext(handle,6,59,"Down arrow to decrease");
 v_gtext(handle,6,67,"<Return> to confirm");
 v_gtext(handle,6,75," deposit");
temper = user.gold; 
do
 {
 com = (char)(Bconin(2)>>16);
 if(com == 0x48) deposit_amount +=1;
 if(com == 0x50) deposit_amount -=1;
 if(deposit_amount < 0) deposit_amount =0;
 if(deposit_amount > user.gold) deposit_amount = user.gold;
temper = user.gold - deposit_amount;
sprintf(string,"<%ld>",temper);
 v_gtext(handle,6,19,string); 
if( test > 9 && deposit_amount == 9 || 
     test > 99 && deposit_amount == 99)   /* if previous was > 9 and now its 9, clear */
 v_gtext(handle,6,35,"               ");  /* clear */
 sprintf(string,"Deposit:%ld",deposit_amount);
 v_gtext(handle,6,35,string);
test = deposit_amount;
 }while( com != 0x1c); /* until return is pressed */
user.gold -=deposit_amount;  /* update user gold */
user.bank_balance += deposit_amount; /* credit it to bank balance */
v_gtext(handle,6,75,"Thank You!");
pause();
}   


/***/
sell_gem_jewel()
{
 char com;
 int exit = 0;

 if ( user.user_items[4]==0 && user.user_items[5]==0 )
  {
  v_gtext(handle,6,11,"You dont seem to have");
  v_gtext(handle,6,19,"any gems/jewels to   ");
  v_gtext(handle,6,27,"sell....");
  v_gtext(handle,6,51,"  < press any key > ");
  com = Bconin(2);
  }
 else
  {
  v_gtext(handle,6,11,"Sell what:");
  sprintf(string,"(G)ems    :%d",user.user_items[4]);
  v_gtext(handle,6,19,string);
  sprintf(string,"(J)ewels  :%d",user.user_items[5]);
  v_gtext(handle,6,27,string);
  v_gtext(handle,6,35,"(E)xit ");
  v_gtext(handle,6,51,"Choice: ");
  do
  {
  com = Bconin(2);
  }while( com != 'G' && com !='g' && com !='J' && com !='j' && com !='E' && com !='e');
clear_it();   
  if( (com == 'G' || com == 'g') && user.user_items[4] == 0)
   { v_gtext(handle,6,11,"You dont have any Gems!");
     exit = 1;
   }
  if( (com == 'J' || com == 'j') && user.user_items[5] == 0)
   { v_gtext(handle,6,11,"You dont have any!");
     exit = 1;
   }
 
  if(exit == 0)  /* if you have some to sell.. */
   {
    if(com == 'J' || com == 'j')
    compute_sell(5);  /* 5 is index to jewels */
    if( com == 'G' || com == 'g')
    compute_sell(4);
   }
  
pause();
  } /* end of else. sell....*/
}/* end of sell gem/jewels */



/**************************/
/* index: 4 or 5.. 5 is index to jewels, 4 index to gems */
compute_sell(index)
int index;
{
 int good;

    good = abs(rnd(100)); /* you have a 75% chance its good... */
           if(good < 25)
          v_gtext(handle,6,11,"It's no good!!");
        else
         {
          good = abs(rnd(77));
          sprintf(string,"It's worth %d gp",good);
          v_gtext(handle,6,83,string);
                user.gold +=good;
         }
            user.user_items[index]--;
} /* end of if sell */ 


/**************************/

/**
    check_time()
   am_pm, count and way are globals...


**/
check_time()
{
 char com2;

 if(count > 12)
 {
  if(count == 24) sprintf(string,"The time is:12 am");
  else sprintf(string,"The time is:%d pm",count - 12);
 } 
 
if(count < 13)
{
  if(count == 12) sprintf(string,"The time is:12 pm");
  else sprintf(string,"The time is:%d am",count);
}
     v_gtext(handle,6,11,string);   /* display time */
   
   v_gtext(handle,6,67,"Press any key");
   com2 = Bconin(2);
 }
/*********/
pauser()
{
 char tsecs;
   for(tsecs=0;tsecs<60;tsecs++)
        Vsync();
  
}
/**********/
sleeppause()
{
  char tsecs;
  int realtime=0;

     
     for(tsecs=0;tsecs<60;tsecs++)
        {Vsync();
           if( realtime%5 == 0 )    /* stagger */
        {
        switch(realtime%4)
          {
           case 0: v_gtext(handle,276,110,"<");  
                   break;
           case 1: v_gtext(handle,276,110,"=");  break;
           case 2: v_gtext(handle,276,110,">");  break;
           case 3: v_gtext(handle,276,110,"?"); 
          }
        }       
       realtime++;
       if ( realtime > 32767 ) realtime = 0;

        }
}
