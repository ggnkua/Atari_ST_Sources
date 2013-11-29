#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

#include "..\protect.h"

unsigned char version[] = "4.0" ;
#define MAGIC_DIVIDER(user, version) ( ( user[0] + version[0] + version[2] ) & 0xFFUL )


int key_ok(char *key, char *user)
{
  unsigned long magic_divider ;
  unsigned long code      = 0L ;
  unsigned long first_key = 0L ;
  int           succes    = 0 ;

/* Cl‚ : la cl‚ entr‚e est interpr‚t‚e en un chiffre hexad‚cimal   */
/*       ce chiffre doit etre multiple du premier caractere du nom */
/*       interprete en code ASCII                                  */
/*       Depuis la version 3.5a, ce chiffre doit etre multiple de: */
  magic_divider = MAGIC_DIVIDER(user, version) ;
  sscanf( key, "%lx", &code ) ;
  first_key = code & ~(SKEY_MASK << SKEY_LSHIFT) ;

  if ( ( first_key < KEY_MIN ) || ( first_key > KEY_MAX ) ) return( 0 ) ;

  if ( ( first_key != 0 ) && ( first_key % magic_divider ) == 0 ) succes = 1 ;

  if ( first_key % (10+CountNbBits( user[2], 1 )) ) succes = 0 ;

  if ( IsSKeyOK( code ) == 0 ) succes = 0 ;

  return( succes ) ;
}

void main(void)
{
  unsigned long magic_divider ;
  unsigned long k = 0L, nb_bits, skey ;
  char          user[32] ;
  char          key[32] ;

  srand( (unsigned int ) clock() ) ;
  printf( "\r\nEntrez le nom d'utilisateur : " ) ;
  gets( user ) ;
  magic_divider = MAGIC_DIVIDER(user, version) ;
  nb_bits       = 10+CountNbBits( user[2], 1 ) ;

  while ( ( k < KEY_MIN ) || ( k > KEY_MAX ) )
    k = magic_divider * (unsigned long)rand() * nb_bits ;

  skey = s_key( k ) ;
  k   |= ( skey << SKEY_LSHIFT ) ;

  sprintf( key, "%lx", k ) ;
  printf( "\r\nCl‚ = %s", key ) ;
  if ( key_ok( key, user ) )
  {
    FILE *stream ;
    int  n ;
    char fname[50] ;
    char *fnames[2] ;

    sprintf( fname, "USERS\\%s", user + 2 ) ;
    fname[14] = 0 ;
    strcat( fname, ".TXT" ) ;
    fnames[0] = "KEY.TXT" ;
    fnames[1] = fname ;
    for ( n = 0; n < 2; n++ )
    {
      printf( "\r\nV‚rification OK\r\nCreation du fichier %s ... ", fnames[n] ) ;
      stream = fopen( fnames[n], "wb" ) ;
      if ( stream )
      {
        fprintf( stream, "<English translation follows.>\r\n" ) ;
        fprintf( stream, "Merci de votre participation aux sharewares.\r\n" ) ;
        fprintf( stream, "Voici vos parametres d'enregistrement pour VISION %s:\r\n", version ) ;
        fprintf( stream, "Utilisateur : %s\r\n", user ) ;
        fprintf( stream, "Cle         : %s\r\n", key ) ;
        fprintf( stream, "Instructions : \r\n" ) ;
        fprintf( stream, "Copiez le fichier VISION.TOS ou decompactez VISION.ZIP sur votre disque dur.\r\n" ) ;
        fprintf( stream, "Le sous-dossier VISION sera cree et contiendra tout ce qu'il faut !\r\n" ) ;
        fprintf( stream, "N'oubliez pas de copier LDG.PRG dans le dossier AUTO !\r\n" ) ;
        fprintf( stream, "Au premier lancement, saisissez l'utilisateur et la cle.\r\n" ) ;
        fprintf( stream, "Cliquez sur 'OK'. Bienvenue dans le monde de VISION !\r\n\r\n" ) ;
        fprintf( stream, "Thank you for supporting sharewares.\r\n" ) ;
        fprintf( stream, "Here are your register parameters for VISION %s:\r\n", version ) ;
        fprintf( stream, "User : %s\r\n", user ) ;
        fprintf( stream, "Key  : %s\r\n", key ) ;
        fprintf( stream, "Instructions : \r\n" ) ;
        fprintf( stream, "Copy the archive VISION.TOS or unzip VISION.ZIP to your hard-drive.\r\n" ) ;
        fprintf( stream, "The VISION sub-folder will be created and will contain all what you need !\r\n" ) ;
        fprintf( stream, "Don't forget to copy LDG.PRG into AUTO folder !\r\n" ) ;
        fprintf( stream, "At first startup, type in the user and the key.\r\n" ) ;
        fprintf( stream, "Click on 'OK'. Welcome into the world of VISION !\r\n\r\n" ) ;
        fprintf( stream, "Have fun, Jean.\r\n" ) ;
        fprintf( stream, "Contact me at vision.support@free.fr for any question.\r\n" ) ;
        fclose (stream ) ;
        printf( "OK !\r\n" ) ;
      }
      else printf( "ECHEC !!!\r\n" ) ;
    }
  }
  else
    printf( "\r\nLA VERIFICATION A ECHOUE" ) ;

  printf( "\r\nAppuyez sur une touche." ) ;
  getchar() ;
}