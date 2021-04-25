/**************************************************/
/*ONCE A KING BY DARRYN LAVERY AND MARK GRIFFITHS */
/**************************************************/

#include "stdio.h"
#include "string.h"
#include "stdlib.h"
#include "osbind.h"

#define    OPEN      1
#define    CLOSED    0
#define    LOCKED    0
#define    UNLOCKED  1
#define    TRUE      1
#define    FALSE     0
#define    GOT       1000

int    stack;
short  rez,pos,loop,describe,dead=0,map_data[32][6];
char   input[80],word[2][20],descript[32][250];
short  flag[20],command_num[2],door_open[5],door_locked[5],object_location[45];

char command[32][20]={
 "north","east","south","west","up","down","n","e","s","w","u","d",
 "inventory","help","look","quit","perform","shower","open","close",
 "unlock","lock","take","get","drop","use","give","wear","eat","drink",
 "examine"
 };
     
char object[45][15]={
   "","hamlet","cd","magazine","potato","wombat","crown","walkman","binbag",
   "soap","pass","key","crayon","clive","jeffrey","patient","warden",
   "commisionaire","servant","jacko","policeman","producer","cameraman",
   "director","imbecile","loony","knife","fork","table","lp","fireplace",
   "poster","door","hole","throne","metro","rat","shower","computer",
   "bench","pond","pa","ladder","door","vomit"
  };

char object_description[13][80]={
    "","A copy of the Shakespearian Play hamlet","A Compact Disc",
    "A copy of the magazine Gerbil Fanciers Fortnightly","A potato","A wombat",
    "A crown","A red Sony Walkman","A remarkably unimpressive black binbag",
    "A cake of soap","A security pass","A small silver key","A blue crayon"
};

short door_data[9]={
    0,3,4,20,21,24,27,25,26
   };

short spare_map[32][6]={
    { 0,0,0,0,0,0 },{ 0,0,2,0,0,0 },{ 1,0,3,0,0,0 },{ 2,0,0,7,0,0 },
    { 0,0,0,0,0,10 },{ 6,0,0,9,0,0 },{ 0,0,5,0,7,0 },{ 0,3,0,0,8,6 },
    { 0,0,0,0,0,7 },{ 0,5,0,0,0,0 },{ 0,11,0,0,0,0 },{ 0,12,0,10,0,0 },
    { 0,0,0,11,0,0 },{ 0,0,0,0,0,0 },{ 0,0,16,0,0,0 },{ 0,16,0,0,0,0 },
    { 14,0,0,15,0,17 },{ 0,18,0,0,16,0 },{ 19,0,0,17,0,20 },{ 0,0,18,0,0,0 },
    { 0,23,22,0,0,0 }, { 0,0,0,0,0,0 },{ 20,0,0,0,0,0 },{ 0,0,0,20,24,0 },
    { 25,0,0,0,0,23 },{ 28,0,24,0,0,0 },{ 0,0,0,0,0,0 },{ 0,0,0,0,0,0 },
    { 0,0,25,29,0,0 },{ 0,28,30,0,0,0 },{ 29,0,0,0,0,0 },{ 0,0,29,0,0,0 }
      };

short obloc_copy[45]={
     0,8,50,50,1,7,2,50,50,30,50,50,50,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     };

/***************/
/* DATA SETTER */
/***************/
void read_data()
{

short again;

for (loop=0;loop<5;loop++)
    {
   door_open[loop]=CLOSED;
   door_locked[loop]=UNLOCKED;
    }

door_locked[1]=LOCKED;

pos=2;
for (loop=0;loop<=9;flag[loop++]=FALSE);
for (loop=0;loop<=44;object_location[loop]=obloc_copy[loop++]);

for (loop=0;loop<=31;loop++)
     {
      for (again=0;again<=5;again++)  map_data[loop][again]=spare_map[loop][again];
     }


Strcpy(descript[0],"");

Strcpy(descript[1],"Banquet hall.Liberally daubing every item of furniture is hair-gel.What a \n mess:so unbelievably run-down you can`t help but be ");
Strcat(descript[1],"reminded of a fast food\nrestaurant.");

Strcpy(descript[2],"The throne room.Posters of Edwina Currie adorn the wall above the fireplace \n (health reasons).The throne is constructed from genuine ");
Strcat(descript[2],"MFI hardboard.");

Strcpy(descript[3],"The bedroom.A small pool of vomit lies next to a Nick Berry LP.You spy in a\nsoutherly direction (with intermittant snow showers,");
Strcat(descript[3],"clearing by 6 pm) a door,\nrealising it to be of importance.");

Strcpy(descript[4],"OK.You find yourself in the bathroom.There is a gaping abyss in one corner\njust crying out to have some modern appliance ");
Strcat(descript[4],"in it.");

Strcpy(descript[5],"You are in the castle laundry.There are a few servant jumping in and out of\nthe washing machines (a new sport for the ");
Strcat(descript[5],"working class so I believe.)");

Strcpy(descript[6],"Voici chez domestiques.Dodging high-kicking chorus-line girls you spot Sir\nClive Sinclair chatting aimlessly to ");
Strcat(descript[6],"Jeffrey Archer about corruption and the\nweather.");

Strcpy(descript[7],"Etonnement!You didn`t think you could play this game without meeting a boring\ncorridor of some description,did ");
Strcat(descript[7],"you ? Take a powder cos it drags the game\ndown.");

Strcpy(descript[8],"Ho!You`re on the castle ramparts! An extremely interesting location.So much\n so in fact that I am not going to tell ");
Strcat(descript[8],"you what is here.");

Strcpy(descript[9],"You`re at the castle portcullis that has been most generously been provided by\nAncient Architects Ltd- the modern ");
Strcat(descript[9],"choice in facades etc.");

Strcpy(descript[10],"You find it hard to maintain your sang-froid cos,as you will have gathered you\nare a medieval King in modern day ");
Strcat(descript[10],"Birmingham.You are the victim of a timewarp.\nWierd huh?");

Strcpy(descript[11],"You are in British Home Stores.Bad luck.You are genuinely moved by the\nsuffering you see around you.");

Strcpy(descript[12],"You find yourself in a blind alley.You turn to leave but suddenly .... quelle\nhorreur you are roadblocked ");
Strcat(descript[12],"by the Birmingham Constabulary(bless their hearts)");

Strcpy(descript[13],"Yoohoo !!!! Hey fruitcake!You`re in a padded cell.");

Strcpy(descript[14],"This is the hospitals main day ward.There are assorted loonies,nutcases,\nimbeciles and PE teachers all wandering haphazardly in ");
Strcat(descript[14],"a state of general \nbewilderent.");

Strcpy(descript[15],"The games room.A patient is playing a computer game called Once A King,\nevidently having a thoroughly enjoyable time,he hopes to ");
Strcat(descript[15],"be released soon.");

Strcpy(descript[16],"Sorry to have to tell you this but you are in another corridor,but I am sure\nthat if you stick around it is bound to get very ");
Strcat(descript[16],"interesting indeed.");

Strcpy(descript[17],"You are in the hospital`s grounds.I think there are guard dogs around so be\ncareful where you tread.");

Strcpy(descript[18],"You are in the car park.There are many and varied Mini Metros in it.Pity you\nhaven`t got your Spotter`s Guide to Metros.Life is cruel.");








Strcat(descript[18],"Also of interest is an\nopen man-hole leading downwards.");

Strcpy(descript[19],"In the patient`s garden.It all looks idyllic with park-bench and duck pond.\nQuite what the bench is doing in the duck pond is not ");
Strcat(descript[19],"quite apparent.A warden\nis present.");

Strcpy(descript[20],"An awful stench enters your Kingly nostrils.Pourquoi? You`re in a totally rank,\nfoul sewer.To the west is a large imposing door ");
Strcat(descript[20],"covered in slime,filth and\nrat graffitti.");

Strcpy(descript[21],"A different but equally niffy part of the sewer.So niffy in fact,that even the\nrats scurry about with little pegs on their ");
Strcat(descript[21],"noses!");

Strcpy(descript[22],"Amongst the sewage sits a disconsolate figure humming an old refrain.It is\nJonathan Queen and something of importance will ");
Strcat(descript[22],"shortly occur.");

Strcpy(descript[23],"An aged ladder reaches for a shining glimmer of light like a dying man reaches\nfor a loved one (Ughhhh-pass the sick bag!)");

Strcpy(descript[24],"Boring dull corridor - sorry! Incidentally hardy voyager,there is a door to\nthe east.");

Strcpy(descript[25],"Yet another(don`t switch off!) groan corridor.Door to east...skipper.");

Strcpy(descript[26],"By some unfathomable freak of fate you find yourself in an Open University\nDegree Course Planning Office.Talk about bizarre!");

Strcpy(descript[27],"The canteen. Many and varied famous personalities sit at tables and appear\ndistraught, for, today is custard and prunes day");

Strcpy(descript[28],"Fortuitously,the corridor in which you now find yourself is exceptionally\ninteresting. Oh yes,nothing borring about this one.");

Strcpy(descript[29],"Reception. Producers, directors, PA`s and cameramen all clamour around as\nif seeking gainful employment. Nice wallpaper.");

Strcpy(descript[30],"A shower. Probably the greatest invention known to mankind. Seemingly \ngifted with the almost heavenly power of rejuvenation.");

Strcpy(descript[31],"The set of WOGAN. You have emerged 3 feet to the left of Status Quo who are\ncurrently miming an old hit. You`re not a Quo fan");

}

/************************/
/* USER ACTION ROUTINES */
/************************/

void examine(x)
short x;
{
if (object_location[x]==GOT) printf("Yep it`s a %s\n",object[x]);
else printf("But you don`t have the %s\n",object[x]);
}

void help()
{
printf("I suppose we ought to expect this.If you were stupid enough to actually want\n");
printf("to play this game,we can`t expect you to be bright enough to solve it.\n");
}

void quit()
{
short key;
dead=1;
describe=1;
printf("Regrettably you have come to the end of this thoroughly interesting and\n");
printf("enjoyable entertainment computer program.However since the authors have nothing\n");
printf("better to do they have decided to give you another go...\n"); 
printf("If you really want to.......\n");
printf("If not press ESCAPE we won`t hold it against you..\n");
key=(short)Cnecin();
if ((key%256)==27)
   {
   if (!rez) xbios(5,-1,-1,0);
   printf("%cf",27);
   if (rez!=2)
      {
      *((unsigned short *)0xff8240)=0x777;
      *((unsigned short *)0xff8246)=0x000;
      Super(stack);
      }
      exit(0);
   }

printf("\n\n\n\n");
}

void get(x)
short x;
{
if (x <=12)
   {
   if (object_location[x]==pos)
      {
      object_location[x]=GOT;
      printf("OK.You take the %s\n",object[x]);
       }
   else printf("You don`t see the %s\n",object[x]);
   }
   else
      {
      if (x <=25 ) printf("Leave him alone!\n");
      else printf("Leave it alone.It`s not that important!\n");
       }
}

void drop(x)
short x;
{
if (object_location[x]==GOT)
   {
   object_location[x]=pos;
   printf("OK.You drop the %s\n",object[x]);
   }
else printf("You don`t have the %s\n",object[x]);
}

void use(x)
short x;
{
short ok=0;
if (object_location[x]==GOT)
    {
    if (x==3)
         {
         ok=1;
         if (pos==3 && flag[5]==FALSE)
              {
              printf("You slide the magazine under the door.\n");
              flag[2]=TRUE;
              }
          else printf("Nothing happens.\n");
         }
     
   if (x==4)
      {
       ok=1;
       if (pos==3 && flag[5]==FALSE && flag[2]==TRUE)
              {
              flag[2]=FALSE;
              flag[5]=TRUE;
              object_location[3]=GOT;
              object_location[11]=GOT;
              printf("You move the potato around the key-hole and hear a clink at the other side\n");
              printf("Pulling the magazine from under the door reveals a key on the magazine.\n");
              }
        else printf("Things fail to happen.\n");
     }
 if (!ok) printf("Nothing happens.\n");
    }
else printf("But you haven`t got the %s\n",object[x]);
}

void give(x)
short x;
{
short ok=0;
if (object_location[x]==GOT)
   {
    if (x==2 && pos==5 && flag[7]==FALSE)
        {
         flag[7]=FALSE;
         printf("OK.You give the CD away to your trusty servant and in return he gives you a \n");
         printf("copy of the magazine Gerbil Fanciers Fortnightly.\n");
         object_location[2]=50;
         object_location[3]=GOT;
         ok=1;
         }

   if (x==7 && pos==19 && flag[8]==FALSE)
      {
      flag[8]=TRUE;
      object_location[7]=50;
      object_location[8]=GOT;
      ok=1;
      printf("The Warden kindly relieves you of your Walkman.He gives you a black binbag in \n");
      printf("return.Seems to me like you got the worst part of the deal!\n");
       }

     if (x==6 && pos==14 && flag[9]==FALSE)
        {
        flag[9]=TRUE;
        object_location[6]=50;
        object_location[7]=GOT;
        ok=1;
        printf("You give the crown away but in return you get a red sony walkman\n");
         }
     if (!ok) printf("Don`t give it away-you may need it later on !\n");
     }
else printf("But you don`t have the %s\n",object[x]);
}

void move_direction(x)
short x;
{
if (x>=6 && x<=11) x-=6;
if (map_data[pos][x])
   {
   printf("You go %s\n",command[x]);
   pos=map_data[pos][x];
   describe=1;
   }
else printf("Stop behaving like a retarded potato.You can`t go %s\n",command[x]);
}

void wear(x)
short x;
{
short ok=0;
if (object_location[x]==GOT)
   {
   if (x==8)
      {
      printf("Ok.You are now wearing the binbag and very nice it looks on you too!\n");
      flag[4]=TRUE;
      ok=1;
      }
   if (x==6) 
      {
      printf("Now wearing crown your Majesty.\n");
      flag[3]=TRUE;
      ok=1;
      if (pos==12) describe=1;   
      }
   if (!ok) printf("It does not suit you.");
   }
else printf("But you don`t have the %s\n",object[x]);
}

void drink(x)
short x;
{
if (object_location[x]==GOT)
   {
   printf("It`s not a beverage and believe me Sonny Jim if it was it wouldn`t taste\n");
   printf("very nice.\n");
   }
else printf("But you don`t have the %s\n",object[x]);
}

void eat(x)
short x;
{
if (object_location[x]==GOT)
   {
   if (x==12)
      {
      printf("You take a large mouthful out of the crayon.As you chomp happily away you \n");
      printf("are taken violently ill.The day-nurse enters to see what`s causing the noise\n");
      printf("and slips farcically on the sick dropping her thermometer and loosing her \n");
      printf("temper.\n");
      printf("You are transferred to the day ward.\n\n"); 
      describe=1;
      pos=14;
      object_location[12]=50;
      }
    else
      {
      printf("Unfortunately,since the last time you ate one,you have gone off the taste\n");
      printf("of %s\n",object[x]);
       }
   }
else 
   {
   printf("But you don`t have the %s",object[x]);
   printf(" and probably wouldn`t want to even if you had it.\n");
   }
}

void inventory()
{
short ok=0;
printf("You are carrying the following items of interest:-\n");
for(loop=1;loop<=12;loop++)
   if (object_location[loop]==GOT)
     {
     printf("%s\n",object_description[loop]);
     ok=1;
     }
if (!ok) printf("Nothing...\n");
}

void shower()
{
if (pos==30)
   {
   if (object_location[9]==GOT) 
      {
      printf("You shower and soon feel invigorated and your normal Majestic-self\n");
      flag[1]=TRUE;
      }
    else printf("But you don`t have any soap!\n");
   }
else printf("There`s nowhere to shower!\n");
}

void perform()
{
if (pos==29)
   {
   if (flag[1]==TRUE)
     {
     map_data[29][0]=31;
     object_location[10]=GOT;
     printf("Immediately the Commmisionaire notices your amazing abilities and gives you a\n");
     printf("pass to go to the TV Studio (which is to the north)\n");
     describe=1;
     }
   else
    {
    printf("What do you want smelly? It suddenly dawns on you that after your recent \n");
    printf("escapades down the local sewerage system that you are quite niffy.....(you do\n");
    printf("realise that I am not helping you but merely giving a hint.)\n");
     }
  }
else printf("Frankly no-one seems interested.\n");
}

short door_there()
{
for (loop=0;loop<=8;loop++) if (door_data[loop]==pos) return (short) TRUE;
return (short) FALSE;
}

void op_door()
{
if (door_there())
   {
   if (pos==3 || pos==4)
       {
       if (door_locked[1]==UNLOCKED)
          {
           door_open[1]=OPEN;
           describe=1;
           printf("OK.Door is open!\n");
           }
        else printf("But the door is locked!\n");
         }

   if (pos==20 || pos==21)
      {
       door_open[2]=OPEN;
       printf("OK door is open!\n");
       describe=1;
       }
   if (pos==24 || pos==27)
      {
       door_open[3]=OPEN;
       printf("OK.Door is open!\n");
       describe=1;
       }
   if (pos==25 || pos==26)
       {
        door_open[4]=OPEN;
        printf("OK.Door is open\n");
        describe=1;
        }
    }
else printf("Where`s the door Wiseguy?\n");
}

void close_door()
{
if (door_there())
    {
    if (pos==3 || pos==4)
        {
        if (door_locked[1]==UNLOCKED)
             {
              describe=1;
              door_open[1]=CLOSED;
              printf("Door now closed.\n");
              }
         else printf("But the door is already closed.\n");
         }

       if (pos==20 || pos==21)
           {
           describe=1;
           door_open[2]=CLOSED;
           printf("Door now closed.\n");
            }
        
       if (pos==24 || pos==27)
          {
          describe=1;
          door_open[3]=CLOSED;
          printf("Door now closed.\n");
          }
         
       if (pos==25 || pos==26)
           {
           describe=1;
           door_open[4]=CLOSED;
           printf("Door now closed.\n");
           }
     }
else printf("Where`s the door Wiseguy?\n");
}

void lock_door()
{
if (door_there())
    {
    if (pos==3 || pos==4)
        {
         if (door_open[1]==CLOSED)
            {
            if (object_location[11]==GOT)
                 {
                 printf("Door is now locked.\n");
                 door_locked[1]=LOCKED;
                  }
             else printf("But you don`t have the key.\n");
             }
             else printf("But you can`t lock an open door.\n");
            }
        else printf("Sorry you can`t lock the door.\n");
       }
else printf("Where`s the door Wiseguy?\n");
}

void unlock_door()
{
if (door_there())
    {
    if (pos==3 || pos==4)
       {
       if (object_location[11]==GOT)
           {
            if (door_locked[1]==LOCKED)
               {
                printf("Door is now unlocked.\n");
                door_locked[1]=UNLOCKED;
                }
            else printf("But the door is already unlocked.\n");
            }
        else printf("But you don`t have the key.\n");
      }
 else printf("The door is already unlocked.\n");
 }
else printf("Where`s the door Wiseguy?\n");
}

/*********************/
/* DESCRIBE LOCATION */
/*********************/

void desc_location()
{
short ok=0;

if (pos==3 || pos==4)
   {
   if (door_open[1]==OPEN)
      {
      map_data[3][2]=4;
      map_data[4][0]=3;
       }
     else map_data[3][2]=map_data[4][0]=0;
   }

if (pos==20 || pos==21)
    {
    if (door_open[2]==OPEN)
         {
          map_data[20][3]=21;
          map_data[21][1]=20;
          }
   else map_data[20][3]=map_data[21][1]=0; 
   }   
    
if (pos==24 || pos==27)
    {
    if (door_open[3]==OPEN)
       {
       map_data[24][1]=27;
       map_data[27][3]=24;
        }
    else map_data[24][1]=map_data[27][3]=0;
     }

if (pos==25 || pos==26)
      {
      if (door_open[4]==OPEN)
         {
         map_data[25][1]=26;
         map_data[26][3]=25;
         }
      else map_data[25][1]=map_data[26][3]=0;
        }

if (object_location[10]==GOT)
      {
       map_data[29][0]=31;
       map_data[31][2]=29;
      }
     else map_data[29][0]=map_data[31][2]=0;

printf("%s\n",descript[pos]);
printf("Exits:-\n");
for (loop=0;loop<=5;loop++)
    if (map_data[pos][loop]) 
       {
       printf("  %s\n",command[loop]);
       ok=1;
       }

if (!ok) printf("Oh dear.There don`t be appear to be any exits.\n");

ok=0;
for (loop=1;loop<=12;loop++) if (object_location[loop]==pos) ok=1;
if (ok)
    {
     printf("You can see:-\n");
     for (loop=1;loop<=12;loop++)
       if (object_location[loop]==pos) printf("%s\n",object_description[loop]);
     }

if (pos==26)
   {
   printf("You drop dead due to acute confusion..\n");
   printf("Press a key for another Blockbusting attempt at Once A King.\n");
   dead=1;
   }

if (pos==27)
   {
    printf("Killed by custard and prunes.\n");
    printf("Press a key for another half-hearted go at Once A King.\n");
    dead=1;
    }

if (pos==21)
    {
    printf("After a long debate D.Lavery(Programmer) has got his own way(hooray!) and\n");
    printf("unleashed his creation the LOCKED cess Monster(Yes-corny I know-and definitely\n");
    printf("nothing to do with Mark Griffiths(Writer)).And how about this for a cliche - \n");
    printf("you are extremely killed until dead.Serious retribution indeed!\n");
    dead=1;    
    }

if (pos==22)
   {
   printf("You are bored to death by Jonathan Queen and will never enjoy the song \n");
   printf("`Everyone`s gone to the moon` again.\n");
   dead=1;
   }

if (flag[4]==FALSE && pos==20)
   {
    printf("Some highly acidic cess has dribbled into your boot and is currently forming\n");
    printf("an insoluble precipitate of your foot.As you struggle weakly to remove the\n");
    printf("item of clothing you slip and become submerged.Cess enters your ears,turning\n");
    printf("your brain into a sort of marmalade.\n");
    dead=1;
  }

if (pos==12 && flag[3]==TRUE)
   {
   printf("You are arrested and immediately taken to the loony bin despite your \n");
   printf("impassioned pleas that you are in fact King Wayne and not merely any \n");
   printf("nutter in a funny suit.\n\n");
   object_location[12]=GOT;
   pos=13;
   desc_location();
   }

if (pos==31)
   {
   printf("\n\n");
   printf("You are currently 3 foot to the left of Status Quo who are currently miming \n");
   printf("their latest hit `Be-bam,be-bam`(remix) to an enraptured audience during \n");
   printf(" Wednesday`s installment of Wogan.\n");
   printf("Ronald Reagan,an avid Wogan viewer and closet Quo fan is so perturbed by your \n");
   printf("entrance,that he has very little option other than to start World War 3.A large\n");
   printf("and unfriendly intercontinental ballistic missile hits you squarely thus \n");
   printf("oblitterating you and effectively blasting you into the past.(Cop out ? Who me\n");
   printf("You land heavily on the banquetting table much to your servants surprise.You \n");
   printf("discover much to your surprise that there is a Sony Walkman in your pocket.It\n");
   printf("completely cures your paranoia and neurosis...until you realise that you are \n");
   printf("eight hundred years before the invention of the cassette.YOU GO UTTERLY \n");
   printf("INSANE.\n");
   printf("                              THE END.\n");
   dead=1;
  }

if (pos==6 && flag[6]==FALSE)
   {
   flag[6]=TRUE;
   object_location[2]=GOT;
   printf("Your trusty servant Jacko gives you a CD.\n");
   }
if (dead) Cnecin();
}

/************/
/* DO INPUT */
/************/
void do_input()
{
short x=command_num[1];
if (command_num[0]<12) move_direction(command_num[0]);
if (command_num[0]==23) command_num[0]=22;
switch (command_num[0]) {
        
     case 12:  inventory();
               break;
     
     case 13:  help();
               break;
     
     case 14:  desc_location();
               break;
     
     case 15:  quit();
               break;
     
     case 16:  perform();
               break;
     
     case 17:  shower();
               break;
    
     case 18:  op_door();
               break;
    
     case 19:  close_door();
               break;
    
     case 20:  unlock_door();
               break;
   
     case 21:  lock_door();
               break;
    
     case 22:  get(x);
               break;
    
     case 24:  drop(x);
               break;
  
     case 25:  use(x);
               break;

     case 26:  give(x);
               break;

     case 27:  wear(x);
               break;
    
     case 28:  eat(x);
               break;
   
     case 29:  drink(x);
               break;
 
     case 30:  examine(x);
               break;
      }
}

/*******************************************/
/* GET INPUT & SEPARATE INTO VERBS & NOUNS */
/*******************************************/
short get_verb()
{
command_num[0]=200;
for (loop=0;loop<31;loop++)
    if (!Strcmp(word[0],command[loop]))
        {
        command_num[0]=loop;
        return (short)TRUE;
       }

printf("Sorry if this sounds annoying but I don`t know how to %s\n",word[0]);
return (short) FALSE;
}

short get_noun()
{
for(loop=1;loop<45;loop++)
   if (!Strcmp(word[1],object[loop]))
       {
       command_num[1]=loop;
       return (short)TRUE;
       }

printf("Eh? What`s a %s",word[1]);
printf(" supposed to be ?\n");
return (short) FALSE;
}

void get_input()
{
input[0]=0;
printf("\nHurry up.Tell me what to do.Someone wants to use the TV >");
gets(input);
for (loop=0;loop<strlen(input);loop++) 
            if (input[loop] >=65 && input[loop] <=90) input[loop]+=32;
describe=0;
}

void check_input()
{
word[0][0]=word[1][0]=0;
sscanf(input,"%s%*c%s",&word[0],&word[1]);
if (get_verb())
   {
   if (command_num[0] <22 ) do_input();
   else if (get_noun()) do_input();
   }
}

/***************/
/* PLAY A GAME */
/***************/
void play_game()
{
printf("%cE\n\n",27);
printf("                                 Once A king V2\n\n");
printf("                          Programming by Darryn Lavery\n\n");
printf("                          Game Text by Mark Griffiths\n\n");
printf("You-the neurotic and paranoid King are having a jacuzzi installed to\n");
printf("uplift your flagging spirits.Blissfully unaware of this dreadful \n");
printf("anachronism you inadvertently stumle across a (yawn!) gateway to the\n");
printf("future.Sword in hand(Shakespeare fans may giggle smuttily at this point)\n");
printf("you venture into the unknown(this last cliche was owned by Sir Clive)-so\n");
printf("watch out!!!!\n\n\n\n");


dead=0;describe=1;
while (!dead)         
      {
      if (describe) desc_location();
      if (!dead)
         {
         get_input();
         check_input();
         }
       }
}

/************/
/* START UP */
/************/
void main()
{
printf("%ce",27);
stack=Super(0);

rez=(short)xbios(4);
if (!rez) xbios(5,-1,-1,1);

if (rez!=2)
   {
   *((unsigned short *)0xff8240)=0x007;
   *((unsigned short *)0xff8246)=0x777;
   }
printf("%cE\n\n",27);

printf("               Once A King By Darryn Lavery and Mark Griffiths\n");
printf("\n\nThis program is public domain (free!!!!).Feel free to give copies to your\n");
printf("friends.Also feel free to use the C source code supplied.If you find the prog\n");
printf("amusing or interesting,or have found the C source code useful then the authors\n");
printf("would be grateful for a small donation.Any suggestions or help needed with the\n");
printf("construction of C adventures (and donations!!) can be sent to :- \n\n");
printf("                    D.Lavery & M.Griffiths\n");
printf("                    3 Ffordd Hengoed,\n");
printf("                    Upper Bryn Coch,\n");
printf("                    Mold,\n");
printf("                    Clwyd,\n");
printf("                    North Wales\n\n\n\n");
printf("                 This program was last altered on 24/3/88\n");
Cnecin();

while(1)
     {
     read_data();
     play_game();
     }
}
 
     
