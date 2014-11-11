/*
 * CDLABREG.C - Programme d'enregistrement à CDLAB
 *
 * Copyright 2004 Francois Galea
 *
 * This file is part of CDLab.
 *
 * CDLab is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * CDLab is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Foobar; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <windom.h>

#include "rsc/cdlabreg.h"
#include "prefs.h"

#define MAX_PRG_SIZE 250000L
#define REG_FILE "reg.txt"

OBJECT *reg_tree;
char pathname[256];
char yo_string[] = "¥û 5ù¢›";
unsigned char crpt_key[8] = { 0x45, 0x6a, 0x04, 0x07, 0x23, 0xbc, 0x99, 0x1d };

/* Sélection de fichier
 * pathname : nom du fichier par défaut, et nouveau nom si OK
 * ext : extension par défaut (genre "*.INF")
 * title : titre du sélecteur de fichier
 */
int fileselect( char * pathname, char * ext, const char * title )
{
  char fspath[256];
  char name[80];
  char * pnt;
  int ret;

  strcpy( fspath, pathname );
  if( strlen( pathname ) == 0 )
    name[0] = 0;
  else
  {
    pnt = strrchr( fspath, '\\' ) + 1;
    strcpy( name, pnt );
    *pnt = 0;
  }

  ret = FselInput( fspath, name, ext, (char*)title, NULL, NULL );
  if( ret )
  {
    strcpy( pathname, fspath );
    strcat( pathname, name );
  }
  return ret;
}

void reg_valid( void )
{
  char buf[128];
  char key_string[17];
  unsigned char key[8];
  unsigned char * name;
  char * pos;
  FILE * fd;
  int i, trouve;
  signed short checksum, x;

  name = (unsigned char*)reg_tree[RB_NAME].ob_spec.tedinfo->te_ptext;
  checksum = 0;
  for( i=(int)strlen((char*)name); i<24; i++ )
    name[i] = 0;
  for( i=0; i<8; i++ )
    key[i] = crpt_key[i] + name[i];
  for( i=0; i<4; i++ )
    checksum -= ((unsigned short*)key)[i];
  for( i=0; i<12; i++ )
    checksum -= ((unsigned short*)name)[i];

  for( i=0; i<4; i++ )
  {
    x = ((unsigned short*)key)[i];
    key_string[ i*4 ] = ((x>>12)&0x0f)+((checksum<0)?0x51:0x41);
    checksum <<= 1;
    key_string[ i*4 + 1 ] = ((x>>8)&0x0f)+((checksum<0)?0x51:0x41);
    checksum <<= 1;
    key_string[ i*4 + 2 ] = ((x>>4)&0x0f)+((checksum<0)?0x51:0x41);
    checksum <<= 1;
    key_string[ i*4 + 3 ] = (x&0x0f)+((checksum<0)?0x51:0x41);
    checksum <<= 1;
  }
  for( i=0; i<16; i++ )
    if( key_string[i] > 'Z' ) key_string[i] -= 'Z' - '0';
  key_string[ 16 ] = 0;

  fd = fopen( REG_FILE, "r+" );
  if( fd )
  {
    trouve = 0;
    fgets( buf, 128, fd );
    while( !trouve && !feof( fd ) )
    {
      pos = strchr( buf, '\t' );
      if( pos )
      {
        *pos = '\0';
        if( !strcmp( buf, (char*)name ) )
          trouve = 1;
      }
      fgets( buf, 128, fd );
    }
    if( !trouve )
    {
      fseek( fd, 0, SEEK_END );
      fprintf( fd, "%s\t%s\n", name, key_string );
    }
    fclose( fd );
  }
  else
    form_alert( 1, "[1][Erreur fichier reg][ Argh ]" );

  sprintf( buf, "[1][Nom : %s|Clé : %s][ Ok ]", name, key_string );
  form_alert( 1, buf );
}

void form_mgr( WINDOW * win )
{
  OBJECT * form;
  int obj;

  form = FORM( win );
  obj = evnt.buff[4];
  if( form[obj].ob_flags & SELECTABLE )
  {
    if( form[obj].ob_flags & EXIT )
      ObjcChange( OC_FORM, win, obj, form[obj].ob_state&~SELECTED, 1 );
  }
  else if( (form[obj].ob_type >> 8) == 24 )  /* Raccourci */
    obj += 1;

  if( form == reg_tree )
  {
    switch( obj )
    {
    case RB_CALC:
      reg_valid();
      break;
    case RB_CANCEL:
      ApplWrite( app.id, WM_DESTROY, win->handle );
      break;
    }
  }
}

void reg_open( void )
{
  reg_tree[RB_NAME].ob_spec.tedinfo->te_ptext[0] = 0;
  FormCreate( reg_tree, MOVER|NAME|SMALLER,
              form_mgr, "Création d'une clé CDLAB", NULL, 0, 0);
}

void crypt_open( void )
{
  int handle, ok;
  size_t taille;
  short i, crypt_size;
  char * buffer, * pnt;
  if( fileselect( pathname, "*.PRG", "Où est CDLAB.PRG ?" ) )
  {
    handle = open( pathname, O_RDWR );
    if( handle )
    {
      buffer = malloc( MAX_PRG_SIZE );
      if( buffer )
      {
        taille = read( handle, buffer, MAX_PRG_SIZE );
        pnt = buffer;
        ok = 0;
        while( pnt < buffer + taille && !ok )
        {
          if( !memcmp( pnt, yo_string, 8 ) )
            ok = 1;
          else
            pnt += 2;
        }
        if( ok )
        {
          crypt_size = *(short*)(pnt+8);
          pnt -= crypt_size - 8;
          for( i=0; i<crypt_size; i++ )
            pnt[i] = pnt[i] ^ crpt_key[i&0x07];
          lseek( handle, 0, SEEK_SET );
          write( handle, buffer, taille );
          form_alert( 1, "[1][Modification effectuée.][Ok]" );
        }
        else
          form_alert( 1, "[1][Fichier incorrect|ou déjà crypté.][Ok]" );
        free( buffer );
      }
      close( handle );
    }
  }
}

/*
 * Attention je règle le look 
 * que pour le TOS standard, je suppose
 * que c'est ok pour MagiC. C'est pas
 * très rigoureux mal bon en attendant ...
 */


struct objcolor {
		unsigned borderc:4;
		unsigned textc  :4;
		unsigned opaque :1;
		unsigned pattern:3;
		unsigned fillc  :4;
};

void editable3d( OBJECT *tree )
{
  struct objcolor *color;
  int res;
		
  if( !get_cookie( 'MagX', NULL))
  {
    res = 0;
    while( !(tree[res].ob_flags & LASTOB))
    {
      if( tree[res].ob_type == G_FTEXT)
      {
        tree[res].ob_state |= SELECTED;
        tree[res].ob_flags |= (1<<9);
        tree[res].ob_flags |= (1<<10);
        color = (struct objcolor*)&tree[res].ob_spec.tedinfo->te_color;
        color -> fillc = 8;
      }
      res ++;
    }
  }
}

int main( void )
{
  int ap_id, evnt_ret;
  int quit;
  OBJECT * tree;

  ap_id = ApplInit();
  if( ap_id > 6 ) menu_register( ap_id, "  CDLab Registration" );
  RsrcLoad( "rsc\\cdlabreg.rsc" );
  RsrcXtype( 1, NULL, 0 );

  rsrc_gaddr( 0, REG_BOX, &reg_tree );
  editable3d( reg_tree );

  rsrc_gaddr( 0, MENU1, &tree );
  MenuBar( tree, 1 );

  quit = 0;
  while( !quit )
  {
    evnt.bclick   = 258;
    evnt.bmask    = 3;
    evnt.bstate   = 0;
    evnt_ret = EvntWindom( MU_MESAG );
    if( evnt_ret & MU_MESAG )
    {
      switch( evnt.buff[0] )
      {
      case AP_TERM:
        quit = 1;
        break;
      case MN_SELECTED:
        switch( evnt.buff[4] )
        {
        case M_REG:
          reg_open();
          break;
        case M_CRY:
          crypt_open();
          break;
        case M_QUIT:
          quit = 1;
          break;
        }
        MenuTnormal( NULL, evnt.buff[3], 1 );
        break;
      }
    }
  }

  /* On ferme proprement toutes les fenêtres */
  while( wglb.first )
  {
    ApplWrite( app.id, WM_DESTROY, wglb.first->handle );
    EvntWindom( MU_MESAG );
  }

  RsrcXtype( 0, NULL, 0 );
  RsrcFree();
  ApplExit();
  return 0;
}

