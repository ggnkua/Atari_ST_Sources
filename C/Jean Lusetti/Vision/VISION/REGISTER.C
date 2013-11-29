/**************************/
/* ----- REGISTER.C ----- */
/* Module de "protection" */
/**************************/
#include  <stdio.h>
#include <stdlib.h>
#include <string.h>

#include     "..\tools\stdprog.h"
#include     "..\tools\stdinput.h"
#include     "..\tools\xgem.h"
#include     "..\tools\gwindows.h"
#include   "..\tools\dither.h"
#include "..\tools\image_io.h"

#include     "defs.h"
#include "forms\fbaratin.h"
#include "register.h"
#include "protect.h"


IDENTIFICATION ident = {
                         {
                           0x4E, 0x4E, 0x20, 0x78, 0x00, 0x04, 0x4E, 0xD0
                         }, /* Meme code que le reset */
                         "", 0, 0
                       } ;
char          cle[] = { 3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5, 8, 9, 7, 9, 3, 2, 3, 8, 4, 6, 2, 6 } ;
char          IsRegistered = 0 ;
long          second_key ;

#define MAGIC_DIVIDER(user, version) ( ( user[0] + version[0] + version[2] ) & 0xFFUL )

void crypte_ident(OBJECT *adr_baratin)
{
  static char crypt_done = 0 ;
  long i ;

  if ( !crypt_done )
  {
    crypt_done  = 1 ;
    if ( ( ident.user[0] != 0 ) && ( ident.user[0] != '_' ) )
    {
      for ( i = 0; i < strlen(ident.user); i++ )
        ident.user[i] = cle[i] ^ ident.user[i] ;
    }
    ident.user[15] = 0 ;
  }

  write_text( adr_baratin, REGISTER, ident.user ) ;
  write_text( adr_baratin, KEY, "" ) ;
}

int cherche_ident(char *buffer)
{
  int l, pos, i ;

  l = (int) strlen(ident.user) ;
  for ( i = 0; i < 4096-9; i++ )
  {
    pos = memcmp( &buffer[i], ident.magic, sizeof(ident.magic) ) ;
    if ( pos == 0 )
    {
      memcpy( &buffer[i+10], ident.user, l ) ; /* ident.magic fait 10 octets */
      buffer[i+10+l] = 0 ;
      memcpy( &buffer[i+10+20], &ident.crypted_key, sizeof(ident.crypted_key) );
      ident.second_key  = KeyEncrypt( second_key ) ;
      memcpy( &buffer[i+10+20+4], &ident.second_key, sizeof(ident.second_key) );

      return(1) ;
    }
  }

  return( 0 ) ;
}

void write_register(void)
{
  FILE   *stream = NULL ;
  size_t nb ;
  int    fini = 0 ;
/*  int    i ;*/
  char   buffer[4096] ;

  sprintf( buffer, vision_prg_access, init_path ) ;
  stream = fopen( buffer, "r+b" ) ;

  if (stream == NULL) return ;
  fseek(stream, 0x20000L, SEEK_SET) ; /* Localis‚ vers la fin du PRG */
  while ( !fini )
  {
    nb = fread( buffer, 4096, 1, stream ) ;
    if ( nb != 1 ) break ;
    fini = cherche_ident(buffer) ;
  }
  if ( fini )
  {
    fseek(stream, -4096, SEEK_CUR) ;
    fwrite(buffer, 4096, 1, stream) ;
    form_exclamation( 1, msg[MSG_REGSUCCES] ) ;
  }
  fclose(stream) ;
}

int key_ok(char *key, char *user)
{
  unsigned long magic_divider ;
  unsigned long code      = 0L ;
  unsigned long original_key ;
  int           succes    = 0 ;
  unsigned char version[] = NO_VERSION ;

/* Cl‚ : la cl‚ entr‚e est interpr‚t‚e en un chiffre hexad‚cimal   */
/*       ce chiffre doit etre multiple du premier caractere du nom */
/*       interprete en code ASCII                                  */
/*       Depuis la version 3.5a, ce chiffre doit etre multiple de: */
  magic_divider = MAGIC_DIVIDER(user, version) ;
  sscanf( key, "%lx", &code ) ;

  second_key   = code >> SKEY_LSHIFT ;
  original_key = code & ~( SKEY_MASK << SKEY_LSHIFT ) ;
  ident.crypted_key = KeyEncrypt( original_key ) ;

  if ( ( original_key != 0 ) && ( original_key % magic_divider ) == 0 ) succes = 1 ;

  return( succes ) ;
}

int check_user(void)
{
  OBJECT *adr_baratin ;
  int    fini = 0 ;
  char   buffer[40] ;

  Xrsrc_gaddr(R_TREE, FORM_BARATIN, &adr_baratin) ;

  sprintf( buffer, "VISION %s", NO_VERSION ) ;
  write_text(adr_baratin, REGISTER, "") ;
  write_text(adr_baratin, KEY, "") ;
  write_text(adr_baratin, VERSION, buffer) ;

  if ( ident.user[0] && (ident.user[0] != '_') && memcmp(ident.user, "              ", 14) )
  {
    crypte_ident( adr_baratin ) ;
    adr_baratin[REGISTER].ob_flags &= ~EDITABLE ;
    adr_baratin[KEY].ob_flags      |= HIDETREE ;
    IsRegistered = 1 ;
    return( 1 ) ;
  }

  adr_baratin[KEY].ob_flags      &= ~HIDETREE ;
  adr_baratin[REGISTER].ob_flags |= EDITABLE ;
  
  while ( !fini )
  {
    FGetBaratin( ident.user, buffer ) ;
    if ( ( ident.user[0] != 0 ) && key_ok( buffer, ident.user ) )
    {
      int i ;

      crypte_ident( adr_baratin ) ;
      write_register() ;
      for (i = 0; i < (int) strlen(ident.user); i++) ident.user[i] = cle[i] ^ ident.user[i] ;
      ident.user[15] = 0 ;
      IsRegistered = 1 ;
      fini         = 1 ;
    }
    else
    {
      int rep ;

      rep = form_stop(1, msg[MSG_REGISTER]) ;
      if (rep == 2)
      {
        fini = 1 ;
        write_text( adr_baratin, REGISTER, "" ) ;
      }
    }
  }

  adr_baratin[REGISTER].ob_flags   |= EDITABLE ;
  adr_baratin[BARATIN_OK].ob_flags |= DEFAULT ;

  return( IsRegistered ) ;
}
