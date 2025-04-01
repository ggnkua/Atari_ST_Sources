/*****************************/
/* SETFLAGS                  */
/*                           */
/* Manipulation der neuen    */
/*                           */
/* Headerbits unter MultiTOS */
/*                           */
/* by Uwe Seimet             */
/* (c) MAXON Computer 1993   */
/*****************************/


#define NUM_OBS 14

#define EXTERN extern

#include <stdio.h>
#include <string.h>
#include <tos.h>
#include <ext.h>

#include "setflags.rsh"


#define TRUE 1
#define FALSE 0


typedef enum _bool boolean;


/* Aufbau des Programmheaders */

struct {
  int ph_branch;
  long ph_tlen;
  long ph_dlen;
  long ph_blen;
  long ph_slen;
  long ph_res;
  long ph_prgflags;
  int ph_absflag;
} header;


char path[256];

char filename[13];


void change_flags(void);
boolean get_name(void);
boolean get_flags(void);
boolean set_flags(void);
void rsrc_init(void);



int main()
{
  if ((appl_init()) == -1) return(-1);
  rsrc_init();
  change_flags();
  appl_exit();
  return(0);
}



void change_flags()
{
  int fo_cx, fo_cy, fo_cw, fo_ch;

  graf_mouse(BUSYBEE, NULL);
  if (!get_name()) return;
  if (get_flags() != -1l) {

    form_center(rs_trindex[DIALOG], &fo_cx, &fo_cy,
                &fo_cw, &fo_ch);
    form_dial(FMD_START, fo_cx, fo_cy, fo_cw, fo_ch,
              fo_cx, fo_cy, fo_cw, fo_ch);
    objc_draw(rs_trindex[DIALOG], 0, 2, fo_cx, fo_cy,
              fo_cw, fo_ch);
    graf_mouse(ARROW, NULL);
    if (form_do(rs_trindex[DIALOG], 0) == OK) {
      graf_mouse(BUSYBEE, NULL);
      set_flags();
    }
    form_dial(FMD_FINISH, fo_cx, fo_cy, fo_cw, fo_ch,
              fo_cx, fo_cy, fo_cw, fo_ch);
  }
  graf_mouse(ARROW, NULL);
}



/* Dateinamen holen */

boolean get_name()
{
  int button;
  char *dummy;

  strcpy(path, " :");
  path[0] = getdisk()+'A';
  getcurdir(getdisk()+1, path+2);
  strcat(path,"\\*.*");
  if (_GemParBlk.global[0] < 0x0140)
    fsel_input(path, filename, &button);
  else fsel_exinput(path, filename, &button,
    "Programm lokalisieren");
  if (!button) return(FALSE);

/* Zugriffspfad zusammensetzen */

  dummy = strrchr(path, '\\');
  if (dummy == NULL) return(FALSE);
  dummy[1] = 0;
  strcat(dummy+1, filename);

/* Namen in Dialog eintragen */

  strcpy(rs_trindex[DIALOG][FILENAME].ob_spec.free_string, filename);

  return(TRUE);
}



/* Alte Flags auswerten */

boolean get_flags()
{
  int handle;
  int index;

  handle = open(path, O_RDONLY);
  if (handle < 0) return(-1);
  if (read(handle, &header, (size_t)(sizeof(header))) <= 0) {
    close(handle);
    return(FALSE);
  }
  close(handle);
  if (header.ph_branch != 0x601a) {
    form_alert(1,"[3][Diese Datei ist|\
keine Programmdatei!][Abbruch]");
    return(FALSE);
  }

  if (header.ph_prgflags & 0x01)
    rs_trindex[DIALOG][FASTLOAD].ob_state |= SELECTED;
  if (header.ph_prgflags & 0x02)
    rs_trindex[DIALOG][TTMEM].ob_state |= SELECTED;
  if (header.ph_prgflags & 0x04)
    rs_trindex[DIALOG][TTRAM].ob_state |= SELECTED;

  switch ((int)(header.ph_prgflags>>4) & 0x03) {
    case 0: index = PRIVATE;
            break;
    case 1: index = GLOBAL;
            break;
    case 2: index = SUPER;
            break;
    case 3: index = READABLE;
            break;
  }
  rs_trindex[DIALOG][index].ob_state |= SELECTED;

  return(TRUE);
}



/* Neue Flags setzen */

boolean set_flags()
{
  int index = 0;
  int handle;

  header.ph_prgflags &= 0xffffff08l;
  if (rs_trindex[DIALOG][FASTLOAD].ob_state & SELECTED)
    header.ph_prgflags |= 0x01;
  if (rs_trindex[DIALOG][TTRAM].ob_state & SELECTED)
    header.ph_prgflags |= 0x02;
  if (rs_trindex[DIALOG][TTMEM].ob_state & SELECTED)
    header.ph_prgflags |= 0x04;

  while (!(rs_trindex[DIALOG][PRIVATE+index].ob_state & SELECTED))
    index++;
  header.ph_prgflags |= index<<4;

  handle = open(path, O_WRONLY);
  if (write(handle, &header, (size_t)(sizeof(header)))
    != sizeof(header)) {
    close(handle);
    return(FALSE);
   }
  close(handle);
  return(TRUE);
}



/* Objektkoordinaten umrechnen */

void rsrc_init()
{
  register int i;

  for(i=0; i<NUM_OBS; i++) rsrc_obfix(rs_trindex
      [DIALOG],i);
}
