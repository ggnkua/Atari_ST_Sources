/*---------------------------------------------*/
/* GEMDOS-Patch-Accessory zur Manipulation     */
/* von Mxalloc-Aufrufen.                       */
/*                                             */
/*                  Autor: Klaus Heyne         */
/*                  (c) 1996 by MAXON-Computer */
/*---------------------------------------------*/
#include <tos.h>
#include <aes.h>                                 

void mainfunc(void);            
extern long install(void);    /* Assembler-    */
extern long kill(void);       /* Funktionen    */

int instflag=0;
int ap_id,menu_id;
char acc_name[16] = "  Mxalloc Patch";
/*---------------------------------------------*/
                                                 
int main()                   
   {                 
   int msg[16];
        
   ap_id=appl_init();                                  
   if (!_app)         /* Start als Accessory ? */
      {
      menu_id = menu_register(ap_id,acc_name);
      if (menu_id >= 0)         /* Meneintrag */
         {                      /* anmelden    */
         do      
            {                   /* Acc-Endlos- */
            evnt_mesag(msg);    /* schleife    */
            if (msg[0] == AC_OPEN)
               mainfunc();     
            }
         while(1);                                                               
         }
      else
         {
         appl_exit();
         return(-1);
         }
      }       
   else
      {                  /* Als PRG in dieser  */
      appl_exit();       /* Sparversion nicht  */                          
      return(0);         /* lauff„hig!         */                         
      }                  
  }     
                         
void mainfunc(void)
  {
  if (!instflag)
     {
     if (form_alert(1,"[2][Mxalloc Patch |"
                      "ST-RAM -> TT-RAM |"
                      "installieren ? ]"
                      "[ OK | CANCEL ]")==1)
        Supexec(install);  /* Installation im  */
        instflag = 1;      /* Supervisor-Modus */
     }                                    
  else
     {
     if (form_alert(1,"[2][Mxalloc Patch |"
                      "entfernen ? ]"
                      "[ OK | CANCEL ]")==1)
        Supexec(kill);
        instflag = 0;
     }                                     
  }

