#include <stdio.h>
#include <osbind.h>
#include <mintbind.h>
#include <dos.h>
#include <cookie.h>
#include <sersofst.h>

typedef struct RSVF_OBJECT
{
	char           *name;
    unsigned char	func,
                    niu0,
                    dev_num,
                    niu1;     
}RSVF_OBJECT;

typedef struct
{
  RSVF_OBJECT        *port[10];
  long               portfile;
}VARIABLES;

RSVF_OBJECT   *port[10];
VARIABLES     tempvar;

/********************************************************************/
/* Huvud-funktionen, dvs den funktion som startar upp allt          */
/********************************************************************/
int main(int argc, char *argv[]) /***********************************/
{
  if(!init_rsvf()) return -1;

  if(!init_port("Modem 2", 38400)) return -2;

  return 0;
}

/******************************************************************/
/* Initieringen av RSVF systemet, dvs h„mta port-namn, osv        */
/******************************************************************/
int init_rsvf(void)
{
  RSVF_OBJECT *object;
  int temp=0;
  if(getcookie(RSVF,(long *)&object))
  {
    while(object!=NULL)
    {
      port[temp]=object;
      object++,temp++;
      if(!(object->func&128))
      {
        object=(RSVF_OBJECT *)object->name;
      }
    }
    port[temp]=NULL;
    return(1);
  }
  else
  {
    printf("HSModem is not Installed\n");
    getch();
    return(0);
  }
}

/********************************************************************/
/********************************************************************/
int init_port(char *port_name, long port_speed)
{
  char    name[80];
  FILE    *test=NULL;
  long    portfile;

  strcpy(name,"u:\\dev\\");
  strcat(name,port_name);
  portfile=Fopen(name,FO_RW);
  if(portfile<=0)
  {
    printf("Porten gick inte att oppna: %s \n",port_name);
    getch();
    return(0);
  }
  if(Fcntl(portfile, (long)&port_speed, TIOCIBAUD))
  {
    printf("Could not set the speed %l\n",port_speed);
    getch();
    return(0);
  }    

  return(1);
}