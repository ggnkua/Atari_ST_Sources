/* general estab. routine */

char *lookup_backpack();
#include <globals2.h> 
#include <stdio.h>
#include <strings.h>
#define	Bconstat(a)	(int)bios(1,a)
extern char *screen,*temp;
extern char parry[];                 /* that -q disables intro mssg on play.ttp */

char welcome[]="2 welco"; /* Welcome to my shoppe! */
   
/* loads up items,prices from a datafile. All estabs will use
   this, but they will user diff data files. The form of the datafile 
   is:
       item_name
       price

   where item_name and price must be < 14 chars in length! 

  max_number controls which items are displayed. ie if you only want 
  the character to be able to buy items 1-5 set max_number =5  

  ** also loads up a picture of a smithy and animates it.
     
*/

#define max_number 45          /* max number of items avail to buy*/
/* read in price list and item names */
  /* place them in an array of structures */
     struct item_list
      {
       char name[30];
       int  price;
      }items[max_number]; 
   


/**********************/
/* name: gen_estab(mfs,mfd,a,b,c)
 
   mfs= MFDB source.
   mfd= MFDB dest.
   a = filename to read from disk( file holds text info/prices )
   b = name of establishment eq: Tail of the Dog Tavern
   c = if 1 then it's an armory!
          2 its the supply shoppe
*/
gen_estab(mf_src,mf_dest,input_file,name,type_of_estab)    /* replace w/ gen_estab */
register MFDB *mf_src,*mf_dest;   /* the src and dest MFDBs!! */
char *input_file,*name,type_of_estab;
{

  FILE *ifp;
  char array[20]; /* holds input data. max of 14 chars + null */
  int number;     /* holds converted number */
  int count=0; /*counts actually how many items are avail to buy */
  int result_returned;
  char com2;
  int type=0;   /* if 0 store item name */
                /* if 1 store price */
  int max_weapons_avail=43;       /* a random number */
  int rectangle_[8];  /* 0-3 is source. 4-7 is the dest */
  int count22=1,dir_of_ani=1;
  int first = 1;


  /** set up dest rectangle */
  rectangle_[4] = 204; rectangle_[5] = 32;
  rectangle_[6] = 233; rectangle_[7] = 62;
  /* set first source rectangle */
  rectangle_[0] = 9;  rectangle_[1] = 12;
  rectangle_[2] = 39; rectangle_[3] = 42;
 

   ifp = fopen(input_file,"r");
    if( ifp == NULL) {printf("\nError opening %s--\n",input_file); scanf("%c",&com2);exit(1);}
     while(  ((fgets(array,15,ifp)) != NULL) && count < max_weapons_avail) 
      /* while not reached eof or reached max # of items you can buy..
         the code : count < max_weapons_avail makes sure you dont go out 
         of bounds in the array items[..] */
      { 
        if (type == 0)  /* process Name of item */ 
            strcpy(items[count].name,array);    
            items[count].name[13] = '\0';      /* kill \n */ 
        if(type == 1)  /* process the Price of the item */
            items[count].price = atoi(array);  /*conv to integer */ 

         type++;
         if(type >1){    /*if name and price read in, reset counter
                            and goto next cell in array to process
                            next item */ 
                      type = 0;
                      count++;          /* number of items loaded */
                    }
    
   }  /*end of while*/
 fclose(ifp);

 max_weapons_avail = rnd(count);  /* randomly have some items there at any time */

max_weapons_avail++;  
  clear_it();
 
    v_gtext(handle,6,11,"Welcome Friend to my");
    v_gtext(handle,6,19,"humble shoppe...");
    v_gtext(handle,6,35,"What may I do for");
    v_gtext(handle,6,43,"you?");
    v_gtext(handle,6,59,"B)uy ");
    v_gtext(handle,6,67,"S)ell");
    v_gtext(handle,6,75,"E)xit");

invoke_tsr( welcome );

if(type_of_estab != 2 )  /* if not supply....animate! */
  {
   while( !(Bconstat(2)) )
    {
     Vsync();
     vro_cpyfm(handle,3,rectangle_,mf_src,mf_dest);

      
     rectangle_[1] +=(33*dir_of_ani);    /* update new source rects. only need to
                              update the y values. */
     rectangle_[3] +=(33*dir_of_ani);  
     if( count22 == 4 )               /* then change the direction of animation */
      {dir_of_ani = dir_of_ani * -1; count22=1; 
      }  /* change dir and reset counter */ 
      if(dir_of_ani == 1 && count22 == 2 ) 
            { if(first ==0) invoke_tsr( parry );
              first = 0;
            } 
      count22++;
     short_wait();
  }/* end of while */
} /* end of animate... */

 com2 = Bconin(2);  /* get the input */

clear_it();

if ( com2 == 'B' || com2 =='b' )
 buy(max_weapons_avail,type_of_estab);

if(type_of_estab == 2 && (com2 == 'S' || com2 == 's'))
{
v_gtext(handle,6,11,"Sorry..I dont buy used");
v_gtext(handle,6,19,"Armour...             ");
}

if(type_of_estab != 2)
{
 if ( com2 == 'S' || com2 == 's')
 sell(type_of_estab);
}

}


/*********************************************************/
sell(type_of_estab)
int type_of_estab;
{
 int price;
 char s,t;
 

if ( type_of_estab == 1  )
      /* if armory AND you have some armor, can only buy current armour*/
{
 if (strcmp(user.armor,"None") !=0)
  {
    v_gtext(handle,6,11,"I'll give you");
    price = user.armor_num * 20 + user.con;
    sprintf(string,"%d gp for it",price);
    v_gtext(handle,6,19,string,184,0,1);
    v_gtext(handle,6,27,"Accept [y/n]");
    t = Bconin(2);
  if( t == 'y' || t == 'Y')
  {
   user.gold +=price;
   user.ac = 18;      /* set ac to easiest to hit! */
   user.armor_num = 0;  /* set armor_num to 0, ts gone now.. */
   strcpy(user.armor,"None         ");
  }
 }/*end of if you have some armor */
}/* end of if in armory */
else
{
view_backpack();

do
 { 
 v_justified(handle,6,83,"# to sell? [X] to exit",184,0,1);
 s = Bconin(2);
 if( s == 'x' || s== 'X' ) return(1);
 }while( (s-'0' < 0 || s-'0' >6) || (user.backpack[s - '0'] == -1));        /* if you dont own it, can sell it! */
  
   price =abs( unique_item[user.backpack[s-'0']].points);
   price = price * user.lvl;
   price += user.con; /* if your good looking add some gp */
   clear_it();
 v_gtext(handle,6,11,"I'll give you");
 sprintf(string,"%d gp for it",price);
 v_gtext(handle,6,19,string,184,0,1);
 v_gtext(handle,6,27,"Accept [y/n]");
 t = Bconin(2);
 if( t == 'y' || t == 'Y')
 {
  user.gold = user.gold + price;
  user.backpack[s-'0'] = -1;  /* set it to -1, its gone now.. */
 }
}

}/* fin */
 
 
/******************************************/

buy(max_weapons_avail,type_of_estab)
int max_weapons_avail,type_of_estab;  
{
   
  int zz=11;
  char com1;
  int full=-1; /* for each increment to this var, we know the offset
                 to the weapon numbers is full * 7
                 we need to start at -1!! */
  int type=0;   /* if 0 store item name */
                /* if 1 store price */
  int not_complete = 1; 

   

   clear_it();
   for(type=0;type<max_weapons_avail;type++)
{
   not_complete =1;
   display_wares(type%7,type,&zz);
   if( zz == 67 || type == max_weapons_avail-1 ) /* if output window full
                                             or reached end of list..then*/
    { 

      full++; /* increment this */
     if( (type - max_weapons_avail+1) == 0 ) /* if at last item to buy, then
                                         use different text */
        v_justified(handle,6,zz,"# to buy or E to exit",184,0,1);
     else
      {
      v_justified(handle,6,zz,"# to buy,C to continue",184,0,1);
      v_justified(handle,6,zz+8,"or E to exit:",184,0,1);
      }
       zz =11; /*reset y position */
       
    do
     {
     com1 = Bconin(2);          /* get input */
       if(   (com1-'0') < 7  && (com1 -'0') > -1  ) 
          { clear_it(); 
            process_the_buy(com1-'0',full*7,type_of_estab);  /* send offset */
            not_complete = 0;       /* set flag false */
            type = max_weapons_avail;  /* set this so we will exit loop */ 
          }

         if( com1 == 'E'|| com1 == 'e')     return(1);
         if( com1 == 'C'|| com1 == 'c'){ clear_it(); 
          not_complete = 0;}
    
      } while(not_complete);

    }/* end of if. */
    /* end of module TEMPLE */
   
}
} 

/******************************************/
 display_wares(type,off,zz)
   int type,off;
   int *zz;  
   {   
      sprintf(string,"[%d] %s:%d",type,items[off].name,items[off].price);
      /*v_justified(handle,6,*zz,string,184,0,1);*/
    v_gtext(handle,6,*zz,string);
      *zz+=8;
     }

/*******************************************/
process_the_buy(number,offset1,type_of_estab)
int offset1,type_of_estab;
int number;
{
  char com2;
  int offset,really_wants_to_buy = 1;  /* initally TRUE, but if
                                          in Armory, and you already
                                          have some armour, its set
                                          to False, and only way to
                                          set back to True is if you
                                          explicitly say Y or y! */

  offset = offset1 + number;
  clear_it();
    
    if (type_of_estab == 1)      /* if in armory */
    {
       if ( (strcmp(user.armor,"None")) != 0 ) /* if you have armor already.. */
        {
         really_wants_to_buy = 0;      /* set to negative! */
         v_gtext(handle,6,11,"You seem to already ");
         v_gtext(handle,6,19,"have some armor. Are");
         v_gtext(handle,6,27,"you sure you want to");
         v_gtext(handle,6,35,"buy?   [y=n]        ");
         com2 = Bconin(2);   
         if ( com2 == 'Y' || com2 == 'y' ) really_wants_to_buy=1;
        }
    } 

if( really_wants_to_buy == 1)
  {
     v_justified(handle,6,11,"So you want to buy a ",184,0,1);
     sprintf(string,"%s",items[offset].name);
     v_gtext(handle,6,19,string);
     sprintf(string,"It'll cost %d gp",items[offset].price);
     v_justified(handle,6,27,string,184,0,1);
     v_gtext(handle,6,35,"You still want it [y=n]");
      com2 = Bconin(2);
     if( com2 == 'Y' || com2 =='y')
     {
      if( ( user.gold - items[offset].price) < 0) 
         v_justified(handle,6,43,"Not enough gold!!",184,0,1);
      else
       {

      if(type_of_estab == 0)
      {
        v_justified(handle,6,43,"Where do you want to",184,0,1);
         v_gtext(handle,6,51,"place it [0-6]:");
          do
          {   
           com2 = Bconin(2);
          }while (  (com2 - '0') < 0 || (com2 - '0') > 6);
          
          if( user.backpack[com2 - '0'] != -1 )
           {
            clear_it();
            v_gtext(handle,6,11,"You already have an ");
            v_gtext(handle,6,19,"item in that space."); 
           }         
          else
           {
            user.backpack[com2 - '0'] = offset;
            user.gold =user.gold -  items[offset].price;
            v_gtext(handle,6,59,"Enjoy your");
            sprintf(string,"%s!",items[offset].name);
           v_gtext(handle,6,67,string);
          }
      } /* end of if_type of estab == 0 */
    


     if(type_of_estab == 2)  /* if supply */
      {clear_it();
       if(items[offset].price < user.gold)
       {
        switch(offset)
         {
           case 0: user.user_items[2]++;    break;  /* keys */
           case 1: user.user_items[3]++;     break;  /* torches */
           case 2: user.user_items[13]++;   break;  /* watch */
         }
         user.gold -=items[offset].price;
        } 
       else {
            v_gtext(handle,6,11,"Sorry...you dont");
            v_gtext(handle,6,19,"have the funds..");
            }
   }    /* end of supply buy.. */


      if(type_of_estab == 1)                 /* yuor in an armory */
       {
         /* use another lookup item table for armor */
         user.gold = user.gold - items[offset].price;
         user.armor_num = offset;
         user.ac = 18 - user.armor_num;   /* compute new ac */
         strcpy(user.armor,items[offset].name);
          v_gtext(handle,6,59,"Enjoy your");
           sprintf(string,"%s!",items[offset].name);
           v_gtext(handle,6,67,string);
       }  
          
     }  /* end of else...*/



      }
  } /* end of really_wants_to buy == 1 */
}



/**********************************/

char *lookup_backpack(d)
int d;
  
 {
  int number;
  
   number = user.backpack[d];
   if (number == -1) return ("Nothing");
   return(unique_item[number].name);
 
 } 
  
/******************************/
view_backpack()
{
 int zz = 27,d;

 clear_it();
 v_gtext(handle,6,11,"Items in backpack");
 v_gtext(handle,6,19,"*****************");
  for(d=0;d<7;d++)
  {
   sprintf(string,"[%d] %s",d,lookup_backpack(d));
      v_gtext(handle,6,zz,string);
      zz+=8;
  }
}
/***************************************************/
