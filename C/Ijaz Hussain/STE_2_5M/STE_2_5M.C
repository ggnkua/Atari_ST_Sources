# include<stdio.h>
# include<dos.h>

main()
{
        long * phystop;
        long megs_2_5;
        long * m_config;
          
     megs_2_5 = 2.5 * 1024 *1024;

     phystop = 1070;           /* address of physical top of memory */
     SUPER(0);                 /* change to supervisor mode to      */
                               /* gain access to restricted memory  */
                               

     m_config = 1060;          /* configuration storage destination */
   
     /* check memory config and set to 2.5 megs if possible */
      
     if((*phystop<=megs_2_5) && (* m_config!=9))
     {
        *phystop = megs_2_5;
        printf("\033\105 JAZZBOX INC 2.5 MEGABYTE DRIVER INSTALLED");
     } 
     else printf("\033\105 DRIVER NOT INSTALLED");  

     C_CONIN();             
}
     
                               

      
     
        
        
        


