/*
 * CONFIG.C
 * Portkonfiguration fÅr TT44TT
 * Copyright (c) 1991 by MAXON
 * Autoren: Oliver Scholz & Uwe Hax
 */

#include <tos.h>
#include <aes.h>
#include <stdio.h>
#include <string.h>
#include <portab.h>

#include "TT44TT.h"
#include "termdefs.h"
#include "proto.h"

#define GLOBAL extern
#include "variable.h"

/*
 * Dialogbox zur Portkonfiguration
 */

WORD  conf_port(CONF_RS *port)
{ 
  WORD cx,cy,cw,ch;
  WORD exitobj,ret;
  OLDSET old;
  CONF_RS oldport;

  /* Die alten Werte merken */
  oldport.baudrate=port->baudrate;
  oldport.flowctrl=port->flowctrl;
  oldport.ucr=port->ucr;

  into_dial(port,&old);
  form_center(port_dial,&cx,&cy,&cw,&ch);
  form_dial(FMD_START,cx,cy,cw,ch,cx,cy,cw,ch);
  objc_draw(port_dial,ROOT,MAX_DEPTH,
            cx,cy,cw,ch);

  show_mouse();

  do 
  {
    exitobj=(form_do(port_dial,0) & 0x7FFF);

    switch(exitobj)
    {
      case BITS8:   port->ucr &= ~0x60;
                    break;

      case BITS7:   port->ucr &= ~0x60;
                    port->ucr |= 0x20;
                    break;
                    
      case STOP1:   port->ucr &= ~0x18;
                    port->ucr |= 0x08;
                    break;
                    
      case STOP2:   port->ucr &= ~0x18;
                    port->ucr |= 0x18;
                    break;

      case PARN:    port->ucr &= ~0x06;
                    break;

      case PARE:    port->ucr |= 0x06;
                    break;
  
      case PARO:    port->ucr &= ~0x06;
                    port->ucr |= 0x04;
                    break;

      case NOPROT:  port->flowctrl=P_NONE;
                    break;
                    
      case XONXOFF: port->flowctrl=P_XON;
                    break;
                    
      case RTSCTS:  port->flowctrl=P_RTS;
                    break;
                    
      case BAUDDWN: if (port->baudrate < 15)
                    {
                      port->baudrate++;
                      into_dial(port,&old);
                      objc_draw(port_dial,
                        BAUDRATE,MAX_DEPTH,
                        cx,cy,cw,ch);
                    }
                    break;
                    
      case BAUDUP:  if (port->baudrate > 0)
                    {
                      port->baudrate--;
                      into_dial(port,&old);
                      objc_draw(port_dial,
                        BAUDRATE,MAX_DEPTH,
                        cx,cy,cw,ch);
                    }
                    break;
                    
    } /* switch */
  } 
  while (exitobj!=PORTOK && exitobj!=PORTABRT);

  port_dial[exitobj].ob_state &= ~SELECTED;

  if (exitobj==PORTOK)
    ret=1; /* OK, neue Einstellung gÅltig */
  else
  {
    ret=0; /* alte Parameter wiederherstellen */
    port->baudrate=oldport.baudrate;
    port->flowctrl=oldport.flowctrl;
    port->ucr=oldport.ucr;
  }

  hide_mouse();
  form_dial(FMD_FINISH,cx,cy,cw,ch,cx,cy,cw,ch);

  return(ret);
}

/*
 * zur Baudrate passenden String holen
 */

VOID get_baud_string(WORD rate_index, CHAR *buf)
{
  CHAR text[16][6]={ "19200","9600","4800",
    "3600","2400","2000","1800","1200","600",
    "300","200","150","134","110","75","50" };

  strcpy(buf,text[rate_index]);
}

/*
 * akt. Parameter in Dialog eintragen
 */

VOID into_dial(CONF_RS *port, OLDSET *indices)
{ 
  CHAR *baud;

  init_dial();

  baud=port_dial[BAUDRATE].ob_spec.tedinfo->
    te_ptext;

  get_baud_string(port->baudrate,baud);
  
  switch(port->flowctrl)
  {
    case P_NONE:    indices->iflow=NOPROT;
                    break;
                    
    case P_XON:     indices->iflow=XONXOFF;
                    break;
                    
    case P_RTS:     indices->iflow=RTSCTS;
  }
  
  switch ((port->ucr) & 0x06)
  { 
    case 0x00:
    case 0x02:      indices->ipar=PARN;
                    break;
                    
    case 0x04:      indices->ipar=PARO;
                    break;

    case 0x06:      indices->ipar=PARE;
  }
  
  if ( ((port->ucr) & 0x18) == 0x18 )
    indices->istop=STOP2;
  else
    indices->istop=STOP1;
                    
  if ( ((port->ucr) & 0x60) == 0x20 )
    indices->idata=BITS7;
  else
    indices->idata=BITS8;

  port_dial[indices->iflow].ob_state|= SELECTED;
  port_dial[indices->idata].ob_state|= SELECTED;
  port_dial[indices->istop].ob_state|= SELECTED;
  port_dial[indices->ipar].ob_state |= SELECTED;
}

/* 
 * alle Objekte im Dialog deselektieren
 */

VOID init_dial(VOID)
{
  WORD objects[10]={BITS7, BITS8, STOP1, STOP2,
     PARN, PARO, PARE,NOPROT, RTSCTS, XONXOFF};
  WORD i;

  for (i=0; i<10; i++)
    port_dial[objects[i]].ob_state &= ~SELECTED;
}

/*
 * alle 4 Ports initialisieren
 */

VOID init_ports(CONF_RS *port)
{
  WORD i;

  for (i=0; i<4; i++)
  {
    port[i].baudrate=1;
    port[i].flowctrl=P_RTS;
    port[i].ucr=DEFUCR;
  }
}

/*
 * Einstellung aus Port lesen
 */

VOID read_port(WORD device)
{
  LONG reg;
  WORD aux;
  
  aux=(WORD)_bconmap(-1);
  _bconmap(device+aux_offset);
  
  port[device].baudrate=
    (WORD)Rsconf(-2,-1,-1,-1,-1,-1);
  reg=Rsconf(-1,-1,-1,-1,-1,-1);
  port[device].ucr=(WORD)(reg >> 24) & 0xFF;

  /* Flowcontrol kann leider auf 'saubere'
     Weise nicht gelesen werden */    
  
  _bconmap(aux);
}

/*
 * Einstellung in Port schreiben
 */

VOID write_port(WORD device)
{
  WORD aux;
  
  aux=(WORD)_bconmap(-1);
  _bconmap(device+aux_offset);
  Rsconf(port[device].baudrate,
         port[device].flowctrl,
         port[device].ucr,-1,-1,-1); 
  _bconmap(aux);
}



