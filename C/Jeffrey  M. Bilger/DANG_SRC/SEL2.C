/*  loads up main selection screen

    user can select 

       1 -enter city
       2 -load char
       3 -save char
       4 -roll a char     
   */

struct character
        {
         char name[15]; /* NO! Set these to char *name and then */
         char align[15]; /* name = "blahh.." OR do char name[]="blah!" */
         char class[15];  /* you're defining an array of one element */
         int lvl;         /* thats a ptr to a char! too redundant! */
         long int exp;
         long int hp;
         int ac,str,inte,wis,dex,con;
         int weapon_num,armor_num;
         int backpack[10];       /* holds unique #. I'll have 1 
                                    main array that will hold number,
                                    name so we can look it up. Set to -1, means EMPTY */
         char weapon[15];
         char armor[15];
         char spell[15];
         long int max_hp,max_sp;
         int spell_num;
         long int sp;
         long int gold;
         int user_items[25];  /* holds food,h2o,keys,etc.. */
         int current_spells_active[5]; /*0=treasure Finding, 1=Fleetness, 2=Protection
                                         3=Strength 4=Charm */
         int hunger_thurst_status[2];  /*0 not hungry/thirsty.. 10 FAMISHED */
                                       /* 0 is hunger 1 is thirst */
         long int bank_balance;  
         int x_loc,y_loc,        /* current x,y location */
             weather,count,way,time,loc,current_sky,
             current_sound,clock,am_pm,sound;
         char dir; 
         };


 struct character user;
 char name[20],align,class;


int  buffer[200];        /* holds the char info for disk loading and saving */
int pointer[37];



#define rnd(t) abs(Random()%(t))   /*returns a number from 0 to (t-1) */

char	 temp_[32000],		             /* Temp buffer where file is read in	*/
         *hld,
		 *iff_in, *iff_out;	              /* Pointers for DEGAS unpack() routine	*/

#include <stdio.h>
#include <gemdefs.h>
#include <osbind.h>

int contrl[12];
int intin[256],  ptsin[256];
int intout[256], ptsout[256];


int savepal[16],newpal[16],junkbuff[46];
int filehandle;
char input[] = "select.dat";
int handle;
int button,x,y;
int stats[10];
int choice;           /* if == 1 then you rolled and accepted a character */
 char pix1[]  ="START0.DAT";
 char pix2[]  ="START1.DAT";


main()

{
    char command[20];
    char *scr1,*scr2,*scr3,*screen;
    char in;
    int type;
   
    MFDB    theMFDB;    /*  Screen definition structure  */
    char string[30];

	appl_init();
	handle = open_workstation(&theMFDB);
    
v_hide_c(handle);   /*hide the mouse */

pt_set(pointer,4,2);
pointer[2]=1;
pointer[3]=3;
pointer[4]=2;
stuffbits(&pointer[5],"0000000000000000");
stuffbits(&pointer[6],"0001111100000000");
stuffbits(&pointer[7],"0001111000000000");
stuffbits(&pointer[8],"0001000110000000");
stuffbits(&pointer[9],"0000000001100000");
for(type=10;type<21;type++)
stuffbits(&pointer[type],"0000000000000000");

stuffbits(&pointer[5],"0000000000000000");
stuffbits(&pointer[6],"0011111000000000");
stuffbits(&pointer[7],"0011110000000000");
stuffbits(&pointer[8],"0011001110000000");
stuffbits(&pointer[9],"0000000011100000");
for(type=10;type<21;type++)
stuffbits(&pointer[type],"0000000000000000");

 
   scr1 = malloc(32768+256);  /*allocate memory for 2nd screen */
    if ((long) scr1 & 0xff)
      scr1 = scr1 + (0x100 - (long)scr1 & 0xff);

screen = (char *)Physbase();          /* get ptr to physbase */
type = 2; /* *.pc1 pic */

read_stuff(pix1,scr1,type);   /* intro screen */
Setscreen(scr1,scr1,-1);    /* display the pic */
Setpalette(newpal);        /* tel sys to use these colors! */
in=Bconin(2);
fade_to_black();

Setscreen(screen,screen,-1);
read_stuff(pix2,scr1,type);   /* title screen */
Setscreen(scr1,scr1,-1);    /* display the pic */
Setpalette(newpal);        /* tel sys to use these colors! */
in=Bconin(2);
fade_to_black();

Setscreen(screen,screen,-1);
read_stuff(input,scr1,type);  /* Selection screen onto the temp scr*/
Setscreen(scr1,scr1,-1);    /* display the pic */
Setpalette(newpal);        /* tel sys to use these colors! */

vsc_form(handle,pointer);  /* make our new mouse ptr active */
v_show_c(handle,0);
 do                              /* loop until keypress */
     {
     
  vq_mouse(handle,&button,&x,&y);
 
 
  if(button == 1 && (x>14 && x<42))         /* if left button pressed... */
      {
       if( y>35 && y<61) enter_city(scr1);
       if( y>67 && y<93) {Setscreen(screen,screen,-1);
                          intro(); 
                          Setscreen(scr1,scr1,-1);
                          Setpalette(newpal); }
       if( y>100 && y<127) save_character();
       if( y>134 && y<161) roll();
      }
     } while ( 1 );      /* while no input */
Setscreen(screen,screen,-1);  
Setpalette(savepal);      /* restore palette */
	v_clsvwk(handle);
	appl_exit();
}



/*************************/
intro()
{
 FILE *ofp;
 char c,com;
 int y=0;

 for(y=0;y<27;y++) printf("                                         \n");
 y=0;
 ofp = fopen("intro.txt","r");
  
   while( (c=getc(ofp)) != EOF)
   { printf("%c",c);
     if(c == '\n') y++;
    if(y == 23) { printf("\n -- MORE --"); com = Bconin(2); y=0; 
          vs_curaddress(handle,50,0);printf("                     \n");}
      }
  if(c == EOF){ printf("\n -- DONE --"); com = Bconin(2);}

 
}
 

/************************************/
save_character()
{
FILE *ofp;
char out;
int x;

clear();
v_gtext(handle,188,37,"Save a Character");
savechar(buffer);
v_gtext(handle,188,53,"Character saved");


}


/******************************8/
stats[] 
*/         
roll()

{
int x;
char c;

clear();
v_gtext(handle,188,37,"Roll a Character");

do
{
choice = 0;          /* reset choice to 0 */

user.lvl = 1;
user.exp = 0L;
user.ac  = 15;
user.weapon_num = 0;
user.armor_num = 0;
user.spell_num = 0;
user.bank_balance = 0L;
user.x_loc = 19;               /* x,y location */
user.y_loc = 16;
user.weather = 0;
user.time = 0;
user.count = 1;
user.way = 1;
user.loc = 206;       /* initial room # */
user.current_sky = 0;
user.current_sound = 0;
user.sound = 1;
user.clock = 1;
user.am_pm = 1;
user.dir = 'N';       /* face north! */

for(x=0;x<10;x++) user.backpack[x] = -1;
for(x=0;x<25;x++) user.user_items[x] = 0;
for(x=0;x<2;x++) user.hunger_thurst_status[x] = 0;

user.str = user.inte = user.wis = user.dex = user.con = 10; /* base */
user.str  += rnd(8);
user.inte += rnd(8);
user.wis  += rnd(8);
user.dex  += rnd(8);
user.con  += rnd(8);

user.hp = user.sp = user.gold = 5L; /* base */
user.hp += (long int) rnd(20);
user.sp += (long int) rnd(20);
user.gold += (long int) rnd(20);

user.max_hp = user.hp;
user.max_sp = user.sp;

strcpy(user.weapon,"None");
strcpy(user.armor,"None");
strcpy(user.spell,"None");

display();

v_gtext(handle,188,141,"Accept");
v_gtext(handle,248,141,"Reroll");

 do               /* loop until mouse press */
     {
     
      vq_mouse(handle,&button,&x,&y);
      if( button == 1 && (y>133 && y<150))  /* if left button pressed and in y range */ 
         {
         
          if(x > 187 && x<230) choice = 1;  /* accept!! */
          if(x >247 && x < 320) choice = -1; /* reroll */
         }
     }while(choice == 0);

}while(choice == -1);     /* reroll */

v_hide_c(handle);   /*hide the mouse */


if( choice == 1 )
  {
    clear();
    vs_curaddress(handle,7,30);
    v_gtext(handle,188,54,"Name:");
    while ( (Bconstat(2)) == -1) c =Bconin(2);
    scanf("%s",name);
    clear();
    v_gtext(handle,188,53,"Alignment:");
    v_gtext(handle,188,61,"G)ood");
    v_gtext(handle,188,69,"N)eutral");
    v_gtext(handle,188,77,"E)vil");
    do
    {
    align = Bconin(2);
    } while( (align != 'G' && align != 'g')  && (align != 'N' && align != 'n') 
             && (align != 'E' && align != 'e') );
    clear();
    v_gtext(handle,188,53,"Class:");
    v_gtext(handle,188,61,"F)ighter");
    v_gtext(handle,188,69,"M)age");
    v_gtext(handle,188,77,"T)hief");
   
   do
    {
    class = Bconin(2);
    } while( (class != 'F' && class != 'f')  && (class != 'M' && class != 'm') 
             && (class != 'T' && class != 't') );



    strcpy(user.name,name);
    if(align == 'G' || align == 'g') strcpy(user.align,"Good");
    if(align == 'N' || align == 'n') strcpy(user.align,"Neutral");
    if(align == 'E' || align == 'e') strcpy(user.align,"Evil");
    if(class == 'F' || class == 'f') strcpy(user.class,"Fighter");
    if(class == 'M' || class == 'm') strcpy(user.class,"Mage");
    if(class == 'T' || class == 't') strcpy(user.class,"Thief");
    clear();
    v_gtext(handle,188,53,"Be sure to SAVE");
    v_gtext(handle,188,61,"your character..");
    
  }
 v_show_c(handle,0);
}
/****************************/
display()
{
 char string[30];


clear();
v_gtext(handle,188,53,user.name);
v_gtext(handle,188,61,user.align);
v_gtext(handle,188,69,user.class);
if(user.str < 10)
sprintf(string,"     STR: %d",user.str);
else
sprintf(string,"     STR:%d",user.str);
v_gtext(handle,188,77,string);

if(user.dex < 10)
sprintf(string,"     DEX: %d",user.dex);
else
sprintf(string,"     DEX:%d",user.dex);
v_gtext(handle,188,85,string);

if(user.inte < 10)
sprintf(string,"     INT: %d",user.inte);
else
sprintf(string,"     INT:%d",user.inte);
v_gtext(handle,188,93,string);

if(user.wis < 10)
sprintf(string,"     WIS: %d",user.wis);
else
sprintf(string,"     WIS:%d",user.wis);
v_gtext(handle,188,101,string);

if(user.con < 10)
sprintf(string,"     CON: %d",user.con);
else
sprintf(string,"     CON:%d",user.con);
v_gtext(handle,188,109,string);


if(user.hp < 10L)
sprintf(string,"     HP : %ld",user.hp);
else
sprintf(string,"     HP :%ld",user.hp);
v_gtext(handle,188,117,string);

if(user.sp < 10L)
sprintf(string,"     SP : %ld",user.sp);
else
sprintf(string,"     SP :%ld",user.sp);
v_gtext(handle,188,125,string);

}
/****************************/
clear()
{
 int h,y=37;


     
for(h=0;h<14;h++)
{
v_gtext(handle,188,y,"                ");
y +=8;
}

}
/***************************/
enter_city(scr1)
char *scr1;
{

clear();
v_hide_c(handle);   /*hide the mouse */
free(scr1);
clear();
v_gtext(handle,188,45,"Loading....");
Pexec(0,"CITY","","");
exit(1);                        /* and quit when exit city */
   
 }



/* load degas compressed pics */

/************************/
read_stuff(hold,adrr,type)
char hold[];
register char *adrr;
int type;

{
 char buf[130];
 int lines,i;
 
 
filehandle = Fopen(hold,0); 

for(i=0; i<16;i++)
 savepal[i]=Setcolor(i,-1);

/* read header data */
i=Fread(filehandle,2L,buf);


/* read 16 words(32 bytes) of palette data into newpal array */
i =Fread(filehandle,32L,newpal);
 

if(type == 1)                       /* if .pi1 pic */
 {
   i =Fread(filehandle,32000L,adrr);/* read pic image in */ 
   /* Close file */
   Fclose(filehandle);
   return(1);                       /* and quit */
 } 

                                   /* else it's compressed.. */
i=Fread(filehandle,32000L,temp_);  /* read image onto back screen*/
/* Close file */
Fclose(filehandle);

                                  

	 lines = 200;		             /* Low, med-res	*/
				 iff_in  = temp_;                /* iff_in pts to temp_buf*/
			     iff_out = adrr;      /* iff_out pts to pic_buffer*/
			      do		
         unpack(0);			                          /* Unpack a line at a time */
			      while (--lines); 

    
}
/************************/

/***********************/

/*---------------------------------------------------------------------------*/
/*					         |--------- DEGAS ---------|			*/
/*					          UNCOMPRESSED   COMPRESSED			*/
/*			     NEO  low med mono   low med mono	 TINY	*/
/*	typ...		0     1   2   3     4   5   6     7		*/

/* Unpacks a single scan line & updates iff_in & iff_out global pointers

                     /	byt ==  0 to  127  copy next [byt+1] bytes
Unpack routine --if-<	byt == -1 to -127  copy next byte [-byt+1] times
                     \	byt == 128         NO-OP							*/

unpack(rez)
int	 rez;

{
	register char	 *src_ptr, *dst_ptr,           /* ptrs to source/dest */
              byt, cnt;                     /* byt holds the ACTUAL compressed data code(control byte ) */
	register int	  minus128 = -128, 
              len;                          
	char			     linbuf[320];		                    /* Oversize just in case! */
	int				      llen;


	if (rez < 2)	 len = 160;
	else			 len = 80;
	llen = len;
	src_ptr = iff_in;           /* iff_in is ptr to compressed data */
	dst_ptr = &linbuf[0];       /* linbuf WILL hold an ENTIRE Uncompressed scan line. 4 bitplanes * 80 = 320 max! */ 

	while (len > 0)
   {
		    byt = *src_ptr++;       /* get byte value at address scr_ptr, THEN inc scr_ptr+1 */
		    if (byt >= 0)           /* If ctrl code >= 0 then use the next x+1 bytes*/
    {
			     ++byt;                 /* inc byt +1 */
			      do 
       {
				        *dst_ptr++ = *src_ptr++;  /* get byte value from address source, and inc the 2 ptrs */
				        --len;                    /* one byte down.. */
			       }
         while (--byt);           /* do this byt TIMES (remember byt here = byt+1 */
		     }
		     else 
       if (byt != minus128)       /* else if ctrl code NOT = -128*/
         {                        /*Then use the next byte -x+1 times, (-x) cause x will be negative and - - = + */
			          cnt = -byt + 1;         /* cnt = -x + 1 */
			          byt = *src_ptr++;       /* byt = THE very next byte past the ctrl code(or ctrl byte! */
			           do {
				               *dst_ptr++ = byt;  /* store that byte */
				               --len;         
			              }
               while (--cnt);    /* keep doing it cnt times */
		          }
	    }

	ilbm_st(linbuf, iff_out, rez);   /* convert the format line */
	iff_in = src_ptr;					                /* Update global pointers */
	iff_out += llen;

}                                /* end of module uncompress() */

/*---------------------------------------------------------------------------*/

ilbm_st(src_ptr, dst_ptr, rez)		   /* Convert ILBM format line to ST format */
int		 *src_ptr, *dst_ptr, rez;
{
	int		 x, *p0_ptr, *p1_ptr, *p2_ptr, *p3_ptr;

	if (rez==0) 
 {				                                     /* Low-res */
  
		p0_ptr = src_ptr;
		p1_ptr = src_ptr + 20;
		p2_ptr = src_ptr + 40;
		p3_ptr = src_ptr + 60;
		for (x=0; x<20; ++x)
  {
			   *dst_ptr++ = *p0_ptr++;
			   *dst_ptr++ = *p1_ptr++;
			   *dst_ptr++ = *p2_ptr++;
			   *dst_ptr++ = *p3_ptr++;
		  }
	} 
 else if (rez==1) 
  {		                                    /* Med-res */
		   p0_ptr = src_ptr;
		   p1_ptr = src_ptr + 40;
		   for (x=0; x<40; ++x)
    {
			     *dst_ptr++ = *p0_ptr++;
			     *dst_ptr++ = *p1_ptr++;
		    }
	}
    else 
     {					                               /* Monochrome */
		      for (x=0; x<40; ++x)
			      *dst_ptr++ = *src_ptr++;
	     }
 
 }
/*---------------------------------------------------------------------------*/


fade_to_black()
{
 int h;

  for(h=0;h<16;h++)
    Setcolor(h,0x000);

   }
/**********************/


/* 
  the load and save character routines.

*/







/*********************/
/* ints are 2 bytes
   chars are 1 byte 
   longs are 4 bytes 

   ALL strings must be terminated with \0 or NULL!!!

*/

savechar(b)
int b[];
{
int pp,k,fd;
 


  strcpy(b,user.name);
  strcpy(&b[15],user.align);
  strcpy(&(b[30]),user.class);
  b[45] = user.lvl;

  
  extract_LW_into_two_words( user.exp,&(b[46])  , &(b[48]));
    
 
  b[51] = user.ac;
  extract_LW_into_two_words( user.hp , &(b[52]) , &(b[54]) );
 
  b[56]=user.str;
  b[57]=user.inte;
  b[58]=user.wis;
  b[59]=user.dex;
  b[60]=user.con;
  b[61]=user.weapon_num;
  b[62]=user.armor_num;
  for(k=0;k<10;k++)
   b[63+k]=user.backpack[k];
  
  strcpy(&(b[73]),user.weapon);
  strcpy(&(b[88]),user.armor);
  strcpy(&(b[103]),user.spell);
 
  extract_LW_into_two_words( user.max_hp , &(b[118]) , &(b[120]) );
  extract_LW_into_two_words( user.max_sp , &(b[122]) , &(b[124]) );
 
  b[126]=user.spell_num;

  
  extract_LW_into_two_words( user.sp , &(b[127]) , &(b[129]) );

  extract_LW_into_two_words( user.gold , &(b[131]) , &(b[133]) );

 
  for(k=0;k<25;k++)
   b[135+k]=user.user_items[k];
  for(k=0;k<5;k++)
   b[160+k]=user.current_spells_active[k];
  for(k=0;k<2;k++)
   b[165+k]=user.hunger_thurst_status[k];
   
extract_LW_into_two_words( user.bank_balance , &(b[168]) , &(b[170]) );

 
  b[173]=user.x_loc;   /* global x&y coords _ OTHERS*/
  b[174]=user.y_loc;
  b[175]=user.weather;
  b[176]=user.count;
  b[177]=user.way;
  b[178]=user.time;
  b[179]=user.loc;
  b[180]=user.current_sky;
  b[181]=user.current_sound;
  b[182]=user.clock;
  b[183]=user.am_pm;
  b[184]=user.sound;
  b[185]=user.count;
  b[186]=user.dir;

 if( (fd = Fopen("char.dat",1)) < 0) printf("\nError cant open file\n"); 
 
 Fwrite(fd,(long)400,b); /*write 400 bytes to file */

 Fclose(fd);


}

/*************************************************************/

 
extract_LW_into_two_words( data , MSW , LSW )
long int data;
     int *MSW,*LSW;

/* This procedure will take a longword(data) and break
   it up into 2 words

   Input: data --> the long word
  Output: MSW  --> the Most Signifigant Word
          LSw  --> the Least Sig. Word


*/
{
 long int result; 
 
                                   /* Extract MSW */
  result = data & 0xffff0000;
  result = result >> 16;
   *MSW = result;                        /* store it in an int */
 
 result = data & 0x0000ffff;          /* extract LSW */
 *LSW = result;                          /*store it */
  

 }

/**********************************************************/

create_LW_from_two_words( result, MSW, LSW )
/* Creates a long word from two words */
long int *result;
     int MSW,LSW;
{
 long int lower_word;
                                 /* This code will form a long int
                                   from 2 ints */
 *result = MSW;                        /* get MSW */
 *result = *result << 16;                 /* put into upper word */
 lower_word = LSW;                          /* get LSW */
 lower_word = lower_word & 0x0000ffff;          /* it gets sign extended, so mask
                                       out upper word */
 
 *result +=lower_word;                       /* add to get final result */


 
}
