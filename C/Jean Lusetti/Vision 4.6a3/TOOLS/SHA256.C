/* Freely adapted from Amiga version available at: */
/* https://github.com/Leffmann/SHA256              */
/* This library will use about 1300 bytes of stack */
/* This can be controlled by BUFSIZE               */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "sha256.h"

/* Must be a multiple of 64 */
#define BUFSIZE 1024 /* Seems to be best compromize between stack usage/speed */

extern void cdecl SHA256Acc(void* buffer, uint32* hash, uint32 count) ; /* in SHA256.S */

static uint32 iSHA256[] = {
                            0x6a09e667UL, 0xbb67ae85UL, 0x3c6ef372UL, 0xa54ff53aUL,
                            0x510e527fUL, 0x9b05688cUL, 0x1f83d9abUL, 0x5be0cd19UL
                          } ;

#define sha256_init(sha256) memcpy( sha256, iSHA256, sizeof(iSHA256) ) ;

static void sha256_end(unsigned char* buffer, size_t remaining, size_t len, uint32 sha256[8])
{
  uint32* pmsglen  ;
  size_t  padlen ;
  size_t  lastlen ;

  /*  Append terminating 1-bit, padding, and message size */
  lastlen         = BUFSIZE-remaining ;
  buffer[lastlen] = 0x80 ;
  padlen          = (64-9+BUFSIZE-lastlen) % 64 ;
  pmsglen         = (uint32*) (buffer+lastlen+padlen+1) ;
  memset( buffer+lastlen+1, 0, padlen ) ;
  pmsglen[0] = len >> 29 ;
  pmsglen[1] = len << 3 ;

  SHA256Acc( buffer, sha256, (lastlen+padlen+9)/64) ;
}

long fSHA256(char* name, uint32 sha256[8])
{
  FILE*         stream = fopen( name, "rb" ) ;
  unsigned char buffer[BUFSIZE] ;
  size_t        lastlen, filelen = 0 ;
  size_t        remaining = BUFSIZE ;

  if ( stream == NULL ) return -1 ;

  sha256_init( sha256 ) ;
  do
  {
    lastlen    = fread( buffer, 1, remaining, stream ) ;
    remaining -= lastlen ;
    filelen   += lastlen ;

    if ( remaining == 0 )
    {
      SHA256Acc( buffer, sha256, BUFSIZE/64 ) ;
      remaining = BUFSIZE ;
    }
  }
  while ( !feof( stream ) ) ;

  fclose( stream ) ;

  sha256_end( buffer, remaining, filelen, sha256 ) ;

  return 0 ;
}

void mSHA256(void* raw_data, uint32 size, uint32 sha256[8])
{
  unsigned char  buffer[BUFSIZE] ;
  unsigned char* data = (unsigned char*) raw_data ;
  size_t         lastlen, memlen = 0 ;
  size_t         remaining = BUFSIZE ;

  sha256_init( sha256 ) ;
  do
  {
    if ( memlen+BUFSIZE < size ) lastlen = BUFSIZE ;
    else                         lastlen = size-memlen ;
    if ( lastlen ) memcpy( buffer, &data[memlen], lastlen ) ;
    remaining -= lastlen ;
    memlen    += lastlen ;

    if ( remaining == 0 )
    {
      SHA256Acc( buffer, sha256, BUFSIZE/64 ) ;
      remaining = BUFSIZE ;
    }
  }
  while ( lastlen ) ;

  sha256_end( buffer, remaining, memlen, sha256 ) ;
}
