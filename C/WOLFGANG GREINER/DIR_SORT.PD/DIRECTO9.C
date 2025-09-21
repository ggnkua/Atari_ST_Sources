/* COPYRIGHT 1986 BY WOLFGANG GREINER
                     STADTWALDSTR. 9
                     7554 KUPPENHEIM
                     07222/41216
*/

#include "osbind.h"

int contrl[12],intin[128],ptsin[128],intout[128],ptsout[128];
int handle;
int workout[57],workin[12];
int filehandle,vdihandle;
char diskname[50];
main()

{
 appl_init();
 v_opnvwk(workin,&vdihandle,workout);

 clearscreen();

 form_alert(1,
              "[1][Another fine product from|the Sirius Cybernetics|Corporation][weiter]");

 form_alert(1,"[1][Copyright by|Wolfgang Greiner][weiter]");

 filehandle=(int)Fcreate("D:DIR_PRG",0);


 while(2==form_alert(2,"[3][Bitte Disk einlegen!][Ende|weiter]"))

  { hc();
    printf("Bitte Diskname eingeben:\n\r");
    diskname[0]=(char)47;
    Cconrs(diskname);
    diskname[(int)(diskname[1]+2)]=(char)0;
    dir();
    printf("\n\r");
    sc();
  }
  Fwrite(filehandle,1l,"\0");
  Fclose(filehandle);

  form_alert(1,"[1][Vielen Dank!|Sie haben einem einfachen|Programm das schîne GefÅhl|gegeben, gute Arbeit geleistet|zu haben.][Auf Wiedersehen]");
  v_clsvwk(vdihandle);
  appl_exit();
}


clearscreen()
{ Cconout(27); Cconout((int)'E');}

savedta()
{ int i;
  char *adr,path[100];
  long *l;

  i=30;                        /* prgname*/
  adr= (char *)Fgetdta();
  while (adr[i]!=0)
   { Fwrite(filehandle,1l,&adr[i]);
     i++; }
  Fwrite(filehandle,1l,"\t");
  l=(long *)(&adr[26]);              /*laenge */
  savelong(*l);
  Fwrite(filehandle,1l,"\t");
  i=2;                                /* diskname */
  while(diskname[i]!=0)
   {Fwrite(filehandle,1l,&diskname[i]);
    i++;
   }
  Fwrite(filehandle,1l,"\t");        /* ordnername */
  i=0;
  Dgetpath(path,0);
  while(path[i]!=0)
   {Fwrite(filehandle,1l,&path[i]);
    i++;}

  Fwrite(filehandle,2l,"\n\r");
  printf("   ");
  printf((adr+30));printf("\n\r");
}


dir()
{ char DTA[44];
  long ret;

  Fsetdta(DTA);         /* neues DTA setzen */


  ret=Fsfirst("*.PRG",6);           /* prg-files ausgeben */
  if (ret==(0l))
   {
     savedta();
     while (Fsnext()==(0l))
      {
       savedta();
      }
   }



  ret=Fsfirst("*.TOS",6);           /* tos-files ausgeben */
  if (ret==(0l))
   {
     savedta();
     while (Fsnext()==(0l))
      {
       savedta();
      }
   }


  ret=Fsfirst("*.TTP",6);           /* TTP-files ausgeben */
  if (ret==(0l))
   {
     savedta();
     while (Fsnext()==(0l))
      {
       savedta();
      }
   }


  ret=Fsfirst("*.ACC",6);           /* ACC-files ausgeben */
  if (ret==(0l))
   {
     savedta();
     while (Fsnext()==(0l))
      {
       savedta();
      }
   }


  ret=Fsfirst("*.*",16);

  if (ret==(0l))
   {
      if ((DTA[30]!='.')&(DTA[21]&&16))
       {if (Dsetpath(&DTA[30])==(0l))
        { dir();
          Fsetdta(DTA);     }
       }
    while (Fsnext()==(0l))
      {if ((DTA[30]!='.')&(DTA[21]&&16))
         {if (Dsetpath(&DTA[30])==(0l))
          {dir();
           Fsetdta(DTA);   }
         } 
      }
   }
  Dsetpath("..");
}


savelong(l)
 long l;
{ long d;
  int q,i;
  char c;

  d=10000000;
 
  for(i=0;i<8;i++)
   {q=l/d;
    l=l-d*q;
    d/=10;
    c=(char)(q+'0');
    Fwrite(filehandle,1l,&c);
   }
}


sc()
{v_show_c(handle,0);
}

hc()
{v_hide_c(handle);
}

