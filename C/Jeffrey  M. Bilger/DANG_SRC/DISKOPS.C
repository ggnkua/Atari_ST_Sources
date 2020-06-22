#include <globals2.h>
#include <osbind.h>
extern int  buffer[];        /* holds the char info for disk loading and saving */


/* 
  the load and save character routines.

*/





/*********************/
loadchar(i)
int i[];
{
long int hold;
int k,fd;

 if( (fd = Fopen("char.dat",2)) < 0) printf("Error cant open file\n"); 
 
 Fread(fd,(long)400,i); /* read 400 bytes*/
 

  strcpy(user.name,i); 
  strcpy(user.align,&i[15]);
  strcpy(user.class,&(i[30]));
  user.lvl= i[45];
  
 
  create_LW_from_two_words( &user.exp, i[46], i[48] );
 
 
  user.ac = i[51];
 
  create_LW_from_two_words( &user.hp, i[52], i[54] );
 
  user.str =i[56];
  user.inte=i[57];
  user.wis=i[58];
  user.dex=i[59];
  user.con=i[60];
  user.weapon_num=i[61];
  user.armor_num=i[62];
  for(k=0;k<10;k++)
   user.backpack[k]=i[63+k];
  
  strcpy(user.weapon,&(i[73]));
  strcpy(user.armor,&(i[88]));
  strcpy(user.spell,&(i[103]));
 
  create_LW_from_two_words( &user.max_hp, i[118], i[120] );
 
  create_LW_from_two_words( &user.max_sp, i[122], i[124] );
 
 
  user.spell_num=i[126];
 
create_LW_from_two_words( &user.sp, i[127], i[129] );
 
create_LW_from_two_words( &user.gold, i[131], i[133] );
 
  for(k=0;k<25;k++)
   user.user_items[k]=i[135+k];
  for(k=0;k<5;k++)
   user.current_spells_active[k]=i[160+k];
  for(k=0;k<2;k++)
   user.hunger_thurst_status[k]=i[165+k];



 create_LW_from_two_words( &user.bank_balance, i[168], i[170] );
   

  user.x_loc=i[173];
  user.y_loc=i[174];
  user.weather=i[175];
 user.count=i[176];
  user.way=i[177];
  user.time=i[178];
  user.loc=i[179];
  user.current_sky=i[180];
  user.current_sound=i[181];
  user.clock=i[182];
  user.am_pm=i[183];
  user.sound=i[184];
  user.count=i[185];
  user.dir=i[186];

 Fclose(fd);

}



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

 
  b[173]=x;   /* global x&y coords _ OTHERS*/
  b[174]=y;
  b[175]=weather;
  b[176]=count;
  b[177]=way;
  b[178]=time;
  b[179]=loc;
  b[180]=CURRENT_SKY;
  b[181]=CURRENT_SOUND;
  b[182]=clock;
  b[183]=am_pm;
  b[184]=sound;
  b[185]=count;
  b[186]=dir;
 
 if( (fd = Fopen("char.dat",2)) < 0) printf("Error cant open file\n"); 
 
 Fwrite(fd,(long)400,b); /*write 9 bytes to file */

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
