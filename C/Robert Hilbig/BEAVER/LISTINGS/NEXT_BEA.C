int Next_Beaver()
{  register int index,zustand,ueber,next,mode,halt_anz;
   register struct Zustand *aktB;

 do         /* konstruiere Folgekandidaten      */
 { index=1; /* vgl. mit Zaehlen im Dezimalsystem */
   halt_anz = 0;
   zustand=Zustand_Max;
   do
   {  aktB=&(Beaver[index][zustand]);
      ueber=0;
      if(((aktB->zu_schreiben=((aktB->zu_schreiben-47)%2)+48)=='0')&&
         ((aktB->nae_zustand=((aktB->nae_zustand)%Zustand_Max)+1)==1)&&
         ((aktB->nae_position=((aktB->nae_position+2)%3)-1)==-1))
         {  ueber=1;
            if((index=(index+1)%2)==1) zustand--;
         }
      if(!aktB->nae_position) aktB->nae_zustand=Zustand_Max;
/* Haltezustand, also nae_zustan unerheblich; waehle daher den 
   Hoechstwertigen -> ZUSTAND_MAX                                */
   } while(ueber);  

   index=1;
   while(index<Zustand_Max-2)
   {  if(Beaver[1][index].nae_zustand==2)
         Beaver[1][index].nae_zustand=Zustand_Max-index;
      if((index>1)&&(Beaver[0][index].nae_zustand==2))
         Beaver[0][index].nae_zustand=Zustand_Max-index;
      index++;
   }
                                  /* ueberpruefe, ob Automat sinnvoll */
/* alle Zustaende erreicht und genau ein Haltezustand ?              */
   if(Beaver[0][Zustand_Max].nae_position)
   {  mode=index=1;

      do
      {  if(Beaver[0][index].nae_position)
            ueber|=exp2[Beaver[0][index].nae_zustand];/* erreichter Zustand */
         else halt_anz++;                             /* Haltezustand       */

         if(Beaver[1][index].nae_position)
            ueber|=exp2[Beaver[1][index].nae_zustand];/* erreichter Zustand */
         else halt_anz++;                             /* Haltezustand       */

         mode|=exp2[index];
         ueber^=(ueber & mode); /* Ausschluž der schon erreichten Zustaende  */
   
         if ((ueber) && (halt_anz < 2))
         {  next=1;                 /* suche naechsten erreichbaren Zustand, */
            index=0;                /* wenn es einen gibt                   */
            do
            {  if(exp2[next] & ueber)index=next;
               next++;
            }while(!index);
         }
      }while ((ueber) && (halt_anz < 2));

      if ((halt_anz == 1) && (mode==exp2[Zustand_Max+1]-1)) return(1);
             /* alle erreicht und genau ein HALT -> return(1), Kandidat ok*/
   }
 } while(Beaver[0][1].nae_position); /* Symmetrie ausgenutzt  */

 return(0);                          /* kein weiterer Automat */
}



