
#include<globals2.h>
/* This module :        
                  - recieves the var dir
                  - and displays the users stats
                  - checks for experience and will 
                    award a new lvl plus unc stats etc.
                                                         */
  display_user_stats()  
  {
   static int str,dex,inte,wis,con;
   static long int hp,sp;

   

   
if(user.exp > (user.lvl*100))
 {
   v_gtext(handle,6,19,"You gained a level!");
   user.lvl++;
   user.str++;
   user.dex++;
   user.inte++;
   user.wis++;
   user.con++;
   user.max_hp+=(abs(user.con-18));
   user.max_sp+=(abs(user.wis-18));
   user.hp = user.max_hp;
   user.sp = user.max_sp;
 }
  
/* put this const shit in the main module! */
   
    v_gtext(handle,74,104,user.name);   
    v_gtext(handle,74,112,user.align);
   v_gtext(handle,74,120,user.class);
    sprintf(string,"%d",user.ac);


    v_gtext(handle,80,128,string);


   
    sprintf(string,"%d",user.lvl);
    v_gtext(handle,80,136,string);



  


  if( user.str < 10 && str == 10 || 
      user.str < 100 && str == 100)   /* if previous was > 9 and now its 9, clear */
    v_gtext(handle,24,144,"           "); /* clear it. */
   
    sprintf(string,"%d",user.str);
    v_gtext(handle,80,144,string);

 if( user.inte < 10 &&   inte == 10 || 
      user.inte < 100 && inte == 100)   /* if previous was > 9 and now its 9, clear */
      v_gtext(handle,24,152,"           "); /* clear it. */
  
  sprintf(string,"%d",user.inte);
    v_gtext(handle,80,152,string);

 if( user.dex < 10 &&   dex == 10 || 
      user.dex < 100 && dex == 100)   /* if previous was > 9 and now its 9, clear */
      v_gtext(handle,24,160,"           "); /* clear it. */
 
  sprintf(string,"%d",user.dex);
    v_gtext(handle,80,160,string);  


 sprintf(string,"Direction:%c",dir);
v_gtext(handle,204,118,string);



 if( user.hp < 10 &&   hp == 10 || 
      user.hp < 100 && hp == 100)   /* if previous was > 9 and now its 9, clear */
      v_gtext(handle,204,148,"           "); /* clear it. */

     sprintf(string,"%ld",user.hp);
    v_gtext(handle,259,148,string); 
 if( user.sp < 10 &&   sp == 10 || 
      user.sp < 100 && sp == 100)   /* if previous was > 9 and now its 9, clear */
      v_gtext(handle,204,156,"           "); /* clear it. */

	 sprintf(string,"%ld",user.sp);
    v_gtext(handle,259,156,string); 

                                        /* display hunger/thurst stat */
  switch(user.hunger_thurst_status[0])
  {
   case 0:
   case 1:
   case 2:
   case 3: v_gtext(handle,204,126,"         "); break;
   case 4: v_gtext(handle,204,126,"Hungry   "); break;
   case 5: case 6: case 7: v_gtext(handle,204,126,"Starving!"); break;
   case 8: case 9: case 10:v_gtext(handle,204,126,"Famished!"); break;
  }
   switch(user.hunger_thurst_status[1])
  {
   case 0:
   case 1:
   case 2:
   case 3: v_gtext(handle,204,134,"       "); break;
   case 4: v_gtext(handle,204,134,"Thirsty"); break;
   case 5: case 6: case 7:
   case 8: case 9: case 10:v_gtext(handle,204,134,"Parched"); break;
  }
  
                        /* get new previous values */
str = user.str;  dex = user.dex;  con = user.con; inte= user.inte;
hp = user.hp; sp = user.sp; 

    

   }       

