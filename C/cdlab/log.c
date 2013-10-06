/*
 * log.c - gestion du fichier log
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
#include <time.h>
#include <string.h>
#include <tos.h>
#include <stdarg.h>

#include "prefs.h"
#include "device.h"
#include "misc.h"
#include "io.h"
#include "log.h"

char log_filename[256];
FILE * log_file_id = NULL;
int log_file_ok = 0;
int log_rw_flags = 0;
#define RWF_R 0x0001
#define RWF_W 0x0002
int enable_log = 0;
long read_min;
long read_max;
long write_min;
long write_max;

#define NOSCSIERROR     0 /* Kein Fehler                                   */
#define SELECTERROR     1 /* Fehler beim Selektieren                       */
#define STATUSERROR     2 /* Default-Fehler                                */
#define PHASEERROR      3 /* ungültige Phase                               */
#define BSYERROR        4 /* BSY verloren                                  */
#define BUSERROR        5 /* Busfehler bei DMA-Übertragung                 */
#define TRANSERROR      6 /* Fehler beim DMA-Transfer (nichts übertragen)  */
#define FREEERROR       7 /* Bus wird nicht mehr freigegeben               */
#define TIMEOUTERROR    8 /* Timeout                                       */
#define DATATOOLONG     9 /* Daten für ACSI-Softtransfer zu lang           */
#define LINKERROR      10 /* Fehler beim Senden des Linked-Command (ACSI)  */
#define TIMEOUTARBIT   11 /* Timeout bei der Arbitrierung                  */
#define PENDINGERROR   12 /* auf diesem handle ist ein Fehler vermerkt     */
#define PARITIYERROR   13 /* Transfer verursachte Parity-Fehler            */

struct cmd_return { int code; char * text; } command_errors[] =
{
  NOSCSIERROR, "Success",
  SELECTERROR, "Selection error",
  STATUSERROR, "Status error",
  PHASEERROR, "Phase error",
  BSYERROR, "BSY error",
  BUSERROR, "BUS error",
  TRANSERROR, "DMA transfer error",
  FREEERROR, "BUS free error",
  TIMEOUTERROR, "Timeout",
  DATATOOLONG, "Data too long",
  LINKERROR, "Linked command error",
  TIMEOUTARBIT, "Timeout while arbitrating",
  PENDINGERROR, "Pending error",
  PARITIYERROR, "Parity error",
  9999, "Undocumented error"
};

char * sense_keys[] =
{
  "No Sense",
  "Recovered error",
  "Not Ready",
  "Medium Error",
  "Hardware Error",
  "Illegal Request",
  "Unit Attention",
  "?",
  "Blank Check",
  "Vendor Specific",
  "?",
  "Aborted Command",
  "?",
  "Volume Overflow",
  "Miscompare",
  "?"
};

struct scsi_sense { int asc; int ascq; char * text; } sense_codes[] =
{
  0x13, 0x00, "ADDRESS MARK NOT FOUND FOR DATA FIELD",
  0x12, 0x00, "ADDRESS MARK NOT FOUND FOR ID FIELD",
  0x00, 0x11, "AUDIO PLAY OPERATION IN PROGRESS",
  0x00, 0x12, "AUDIO PLAY OPERATION PAUSED",
  0x00, 0x14, "AUDIO PLAY OPERATION STOPPED DUE TO ERROR",
  0x00, 0x13, "AUDIO PLAY OPERATION SUCCESSFULLY COMPLETED",
  0x00, 0x04, "BEGINNING-OF-PARTITION/MEDIUM DETECTED",
  0x14, 0x04, "BLOCK SEQUENCE ERROR",
  0x30, 0x02, "CANNOT READ MEDIUM - INCOMPATIBLE FORMAT",
  0x30, 0x01, "CANNOT READ MEDIUM - UNKNOWN FORMAT",
  0x52, 0x00, "CARTRIDGE FAULT",
  0x3F, 0x02, "CHANGED OPERATING DEFINITION",
  0x11, 0x06, "CIRC UNRECOVERED ERROR",
  0x30, 0x03, "CLEANING CARTRIDGE INSTALLED",
  0x4A, 0x00, "COMMAND PHASE ERROR",
  0x2C, 0x00, "COMMAND SEQUENCE ERROR",
  0x2F, 0x00, "COMMANDS CLEARED BY ANOTHER INITIATOR",
  0x2B, 0x00, "COPY CANNOT EXECUTE SINCE HOST CANNOT DISCONNECT",
  0x41, 0x00, "DATA PATH FAILURE (SHOULD USE 40 NN)",
  0x4B, 0x00, "DATA PHASE ERROR",
  0x11, 0x07, "DATA RESYCHRONIZATION ERROR",
  0x16, 0x00, "DATA SYNCHRONIZATION MARK ERROR",
  0x19, 0x00, "DEFECT LIST ERROR",
  0x19, 0x03, "DEFECT LIST ERROR IN GROWN LIST",
  0x19, 0x02, "DEFECT LIST ERROR IN PRIMARY LIST",
  0x19, 0x01, "DEFECT LIST NOT AVAILABLE",
  0x1C, 0x00, "DEFECT LIST NOT FOUND",
  0x32, 0x01, "DEFECT LIST UPDATE FAILURE",
  0x40, -1,   "DIAGNOSTIC FAILURE ON COMPONENT NN (80H-FFH)",
  0x63, 0x00, "END OF USER AREA ENCOUNTERED ON THIS TRACK",
  0x00, 0x05, "END-OF-DATA DETECTED",
  0x14, 0x03, "END-OF-DATA NOT FOUND",
  0x00, 0x02, "END-OF-PARTITION/MEDIUM DETECTED",
  0x51, 0x00, "ERASE FAILURE",
  0x0A, 0x00, "ERROR LOG OVERFLOW",
  0x11, 0x02, "ERROR TOO LONG TO CORRECT",
  0x03, 0x02, "EXCESSIVE WRITE ERRORS",
  0x3B, 0x07, "FAILED TO SENSE BOTTOM-OF-FORM",
  0x3B, 0x06, "FAILED TO SENSE TOP-OF-FORM",
  0x00, 0x01, "FILEMARK DETECTED",
  0x14, 0x02, "FILEMARK OR SETMARK NOT FOUND",
  0x09, 0x02, "FOCUS SERVO FAILURE",
  0x31, 0x01, "FORMAT COMMAND FAILED",
  0x58, 0x00, "GENERATION DOES NOT EXIST",
  0x1C, 0x02, "GROWN DEFECT LIST NOT FOUND",
  0x00, 0x06, "I/O PROCESS TERMINATED",
  0x10, 0x00, "ID CRC OR ECC ERROR",
  0x22, 0x00, "ILLEGAL FUNCTION (SHOULD USE 20 00, 24 00, OR 26 00)",
  0x64, 0x00, "ILLEGAL MODE FOR THIS TRACK",
  0x28, 0x01, "IMPORT OR EXPORT ELEMENT ACCESSED",
  0x30, 0x00, "INCOMPATIBLE MEDIUM INSTALLED",
  0x11, 0x08, "INCOMPLETE BLOCK READ",
  0x48, 0x00, "INITIATOR DETECTED ERROR MESSAGE RECEIVED",
  0x3F, 0x03, "INQUIRY DATA HAS CHANGED",
  0x44, 0x00, "INTERNAL TARGET FAILURE",
  0x3D, 0x00, "INVALID BITS IN IDENTIFY MESSAGE",
  0x2C, 0x02, "INVALID COMBINATION OF WINDOWS SPECIFIED",
  0x20, 0x00, "INVALID COMMAND OPERATION CODE",
  0x21, 0x01, "INVALID ELEMENT ADDRESS",
  0x24, 0x00, "INVALID FIELD IN CDB",
  0x26, 0x00, "INVALID FIELD IN PARAMETER LIST",
  0x49, 0x00, "INVALID MESSAGE ERROR",
  0x11, 0x05, "L-EC UNCORRECTABLE ERROR",
  0x60, 0x00, "LAMP FAILURE",
  0x5B, 0x02, "LOG COUNTER AT MAXIMUM",
  0x5B, 0x00, "LOG EXCEPTION",
  0x5B, 0x03, "LOG LIST CODES EXHAUSTED",
  0x2A, 0x02, "LOG PARAMETERS CHANGED",
  0x21, 0x00, "LOGICAL BLOCK ADDRESS OUT OF RANGE",
  0x08, 0x00, "LOGICAL UNIT COMMUNICATION FAILURE",
  0x08, 0x02, "LOGICAL UNIT COMMUNICATION PARITY ERROR",
  0x08, 0x01, "LOGICAL UNIT COMMUNICATION TIME-OUT",
  0x4C, 0x00, "LOGICAL UNIT FAILED SELF-CONFIGURATION",
  0x3E, 0x00, "LOGICAL UNIT HAS NOT SELF-CONFIGURED YET",
  0x04, 0x01, "LOGICAL UNIT IS IN PROCESS OF BECOMING READY",
  0x04, 0x00, "LOGICAL UNIT NOT READY, CAUSE NOT REPORTABLE",
  0x04, 0x04, "LOGICAL UNIT NOT READY, FORMAT IN PROGRESS",
  0x04, 0x02, "LOGICAL UNIT NOT READY, INITIALIZING COMMAND REQUIRED",
  0x04, 0x03, "LOGICAL UNIT NOT READY, MANUAL INTERVENTION REQUIRED",
  0x25, 0x00, "LOGICAL UNIT NOT SUPPORTED",
  0x15, 0x01, "MECHANICAL POSITIONING ERROR",
  0x53, 0x00, "MEDIA LOAD OR EJECT FAILED",
  0x3B, 0x0D, "MEDIUM DESTINATION ELEMENT FULL",
  0x31, 0x00, "MEDIUM FORMAT CORRUPTED",
  0x3A, 0x00, "MEDIUM NOT PRESENT",
  0x53, 0x02, "MEDIUM REMOVAL PREVENTED",
  0x3B, 0x0E, "MEDIUM SOURCE ELEMENT EMPTY",
  0x43, 0x00, "MESSAGE ERROR",
  0x3F, 0x01, "MICROCODE HAS BEEN CHANGED",
  0x1D, 0x00, "MISCOMPARE DURING VERIFY OPERATION",
  0x11, 0x0A, "MISCORRECTED ERROR",
  0x2A, 0x01, "MODE PARAMETERS CHANGED",
  0x07, 0x00, "MULTIPLE PERIPHERAL DEVICES SELECTED",
  0x11, 0x03, "MULTIPLE READ ERRORS",
  0x00, 0x00, "NO ADDITIONAL SENSE INFORMATION",
  0x00, 0x15, "NO CURRENT AUDIO STATUS TO RETURN",
  0x32, 0x00, "NO DEFECT SPARE LOCATION AVAILABLE",
  0x11, 0x09, "NO GAP FOUND",
  0x01, 0x00, "NO INDEX/SECTOR SIGNAL",
  0x06, 0x00, "NO REFERENCE POSITION FOUND",
  0x02, 0x00, "NO SEEK COMPLETE",
  0x03, 0x01, "NO WRITE CURRENT",
  0x28, 0x00, "NOT READY TO READY TRANSITION, MEDIUM MAY HAVE CHANGED",
  0x5A, 0x01, "OPERATOR MEDIUM REMOVAL REQUEST",
  0x5A, 0x00, "OPERATOR REQUEST OR STATE CHANGE INPUT (UNSPECIFIED)",
  0x5A, 0x03, "OPERATOR SELECTED WRITE PERMIT",
  0x5A, 0x02, "OPERATOR SELECTED WRITE PROTECT",
  0x61, 0x02, "OUT OF FOCUS",
  0x4E, 0x00, "OVERLAPPED COMMANDS ATTEMPTED",
  0x2D, 0x00, "OVERWRITE ERROR ON UPDATE IN PLACE",
  0x3B, 0x05, "PAPER JAM",
  0x1A, 0x00, "PARAMETER LIST LENGTH ERROR",
  0x26, 0x01, "PARAMETER NOT SUPPORTED",
  0x26, 0x02, "PARAMETER VALUE INVALID",
  0x2A, 0x00, "PARAMETERS CHANGED",
  0x03, 0x00, "PERIPHERAL DEVICE WRITE FAULT",
  0x50, 0x02, "POSITION ERROR RELATED TO TIMING",
  0x3B, 0x0C, "POSITION PAST BEGINNING OF MEDIUM",
  0x3B, 0x0B, "POSITION PAST END OF MEDIUM",
  0x15, 0x02, "POSITIONING ERROR DETECTED BY READ OF MEDIUM",
  0x29, 0x00, "POWER ON, RESET, OR BUS DEVICE RESET OCCURRED",
  0x42, 0x00, "POWER-ON OR SELF-TEST FAILURE (SHOULD USE 40 NN)",
  0x1C, 0x01, "PRIMARY DEFECT LIST NOT FOUND",
  0x40, 0x00, "RAM FAILURE (SHOULD USE 40 NN)",
  0x15, 0x00, "RANDOM POSITIONING ERROR",
  0x3B, 0x0A, "READ PAST BEGINNING OF MEDIUM",
  0x3B, 0x09, "READ PAST END OF MEDIUM",
  0x11, 0x01, "READ RETRIES EXHAUSTED",
  0x14, 0x01, "RECORD NOT FOUND",
  0x14, 0x00, "RECORDED ENTITY NOT FOUND",
  0x18, 0x02, "RECOVERED DATA - DATA AUTO-REALLOCATED",
  0x18, 0x05, "RECOVERED DATA - RECOMMEND REASSIGNMENT",
  0x18, 0x06, "RECOVERED DATA - RECOMMEND REWRITE",
  0x17, 0x05, "RECOVERED DATA USING PREVIOUS SECTOR ID",
  0x18, 0x03, "RECOVERED DATA WITH CIRC",
  0x18, 0x01, "RECOVERED DATA WITH ERROR CORRECTION & RETRIES APPLIED",
  0x18, 0x00, "RECOVERED DATA WITH ERROR CORRECTION APPLIED",
  0x18, 0x04, "RECOVERED DATA WITH L-EC",
  0x17, 0x03, "RECOVERED DATA WITH NEGATIVE HEAD OFFSET",
  0x17, 0x00, "RECOVERED DATA WITH NO ERROR CORRECTION APPLIED",
  0x17, 0x02, "RECOVERED DATA WITH POSITIVE HEAD OFFSET",
  0x17, 0x01, "RECOVERED DATA WITH RETRIES",
  0x17, 0x04, "RECOVERED DATA WITH RETRIES AND/OR CIRC APPLIED",
  0x17, 0x06, "RECOVERED DATA WITHOUT ECC - DATA AUTO-REALLOCATED",
  0x17, 0x07, "RECOVERED DATA WITHOUT ECC - RECOMMEND REASSIGNMENT",
  0x17, 0x08, "RECOVERED DATA WITHOUT ECC - RECOMMEND REWRITE",
  0x1E, 0x00, "RECOVERED ID WITH ECC CORRECTION",
  0x3B, 0x08, "REPOSITION ERROR",
  0x36, 0x00, "RIBBON, INK, OR TONER FAILURE",
  0x37, 0x00, "ROUNDED PARAMETER",
  0x5C, 0x00, "RPL STATUS CHANGE",
  0x39, 0x00, "SAVING PARAMETERS NOT SUPPORTED",
  0x62, 0x00, "SCAN HEAD POSITIONING ERROR",
  0x47, 0x00, "SCSI PARITY ERROR",
  0x54, 0x00, "SCSI TO HOST SYSTEM INTERFACE FAILURE",
  0x45, 0x00, "SELECT OR RESELECT FAILURE",
  0x3B, 0x00, "SEQUENTIAL POSITIONING ERROR",
  0x00, 0x03, "SETMARK DETECTED",
  0x3B, 0x04, "SLEW FAILURE",
  0x09, 0x03, "SPINDLE SERVO FAILURE",
  0x5C, 0x02, "SPINDLES NOT SYNCHRONIZED",
  0x5C, 0x01, "SPINDLES SYNCHRONIZED",
  0x1B, 0x00, "SYNCHRONOUS DATA TRANSFER ERROR",
  0x55, 0x00, "SYSTEM RESOURCE FAILURE",
  0x33, 0x00, "TAPE LENGTH ERROR",
  0x3B, 0x03, "TAPE OR ELECTRONIC VERTICAL FORMS UNIT NOT READY",
  0x3B, 0x01, "TAPE POSITION ERROR AT BEGINNING-OF-MEDIUM",
  0x3B, 0x02, "TAPE POSITION ERROR AT END-OF-MEDIUM",
  0x3F, 0x00, "TARGET OPERATING CONDITIONS HAVE CHANGED",
  0x5B, 0x01, "THRESHOLD CONDITION MET",
  0x26, 0x03, "THRESHOLD PARAMETERS NOT SUPPORTED",
  0x2C, 0x01, "TOO MANY WINDOWS SPECIFIED",
  0x09, 0x00, "TRACK FOLLOWING ERROR",
  0x09, 0x01, "TRACKING SERVO FAILURE",
  0x61, 0x01, "UNABLE TO ACQUIRE VIDEO",
  0x57, 0x00, "UNABLE TO RECOVER TABLE-OF-CONTENTS",
  0x53, 0x01, "UNLOAD TAPE FAILURE",
  0x11, 0x00, "UNRECOVERED READ ERROR",
  0x11, 0x04, "UNRECOVERED READ ERROR - AUTO REALLOCATE FAILED",
  0x11, 0x0B, "UNRECOVERED READ ERROR - RECOMMEND REASSIGNMENT",
  0x11, 0x0C, "UNRECOVERED READ ERROR - RECOMMEND REWRITE THE DATA",
  0x46, 0x00, "UNSUCCESSFUL SOFT RESET",
  0x59, 0x00, "UPDATED BLOCK READ",
  0x61, 0x00, "VIDEO ACQUISITION ERROR",
  0x50, 0x00, "WRITE APPEND ERROR",
  0x50, 0x01, "WRITE APPEND POSITION ERROR",
  0x0C, 0x00, "WRITE ERROR",
  0x0C, 0x02, "WRITE ERROR - AUTO REALLOCATION FAILED",
  0x0C, 0x01, "WRITE ERROR RECOVERED WITH AUTO REALLOCATION",
  0x27, 0x00, "WRITE PROTECTED",
  -1, -1, ""
};

struct scsi_command { int code; char * text; } command_names[] = 
{
  0x00, "TEST UNIT READY",
  0x01, "REZERO UNIT",
  0x03, "REQUEST SENSE",
  0x04, "FORMAT UNIT",
  0x07, "REASSIGN BLOCKS",
  0x08, "READ(6)",
  0x0A, "WRITE(6)",
  0x0B, "SEEK(6)",
  0x12, "INQUIRY",
  0x15, "MODE SELECT(6)",
  0x16, "RESERVE",
  0x17, "RELEASE",
  0x18, "COPY",
  0x1A, "MODE SENSE(6)",
  0x1B, "START STOP UNIT",
  0x1C, "RECEIVE DIAGNOSTIC RESULTS",
  0x1D, "SEND DIAGNOSTIC",
  0x1E, "PREVENT/ALLOW MEDIUM REMOVAL",
  0x25, "READ CAPACITY",
  0x25, "READ CD-ROM CAPACITY",
  0x28, "READ(10)",
  0x2A, "WRITE(10)",
  0x2B, "SEEK(10)",
  0x2E, "WRITE AND VERIFY",
  0x2F, "VERIFY(10)",
  0x30, "SEARCH DATA HIGH(10)",
  0x31, "SEARCH DATA EQUAL(10)",
  0x32, "SEARCH DATA LOW(10)",
  0x33, "SET LIMITS(10)",
  0x34, "PRE-FETCH",
  0x35, "SYNCHRONIZE CACHE",
  0x36, "LOCK/UNLOCK CACHE",
  0x37, "READ DEFECT DATA",
  0x39, "COMPARE",
  0x3A, "COPY AND VERIFY",
  0x3B, "WRITE BUFFER",
  0x3C, "READ BUFFER",
  0x3E, "READ LONG",
  0x3F, "WRITE LONG",
  0x40, "CHANGE DEFINITION",
  0x41, "WRITE SAME",
  0x42, "READ SUB-CHANNEL",
  0x43, "READ TOC",
  0x44, "READ HEADER",
  0x45, "PLAY AUDIO(10)",
  0x47, "PLAY AUDIO MSF",
  0x48, "PLAY AUDIO TRACK/INDEX",
  0x49, "PLAY TRACK RELATIVE(10)",
  0x4B, "PAUSE/RESUME",
  0x4C, "LOG SELECT",
  0x4D, "LOG SENSE",
  0x55, "MODE SELECT(10)",
  0x5A, "MODE SENSE(10)",
  0xA5, "PLAY AUDIO(12)",
  0xA8, "READ(12)",
  0xA9, "PLAY TRACK RELATIVE(12)",
  0xAF, "VERIFY(12)",
  0xB0, "SEARCH DATA HIGH(12)",
  0xB1, "SEARCH DATA EQUAL(12)",
  0xB2, "SEARCH DATA LOW(12)",
  0xB3, "SET LIMITS(12)",
  -1, ""
};

/* Fonctions locales */
char * command_name( scsi_cmd * Cmd )
{
  static char buf[40];
  char * ret;
  int index;
  index = 0;
  while( command_names[index].code >= 0
         && command_names[index].code != Cmd->Cmd[0] ) index++;
  if( command_names[index].code < 0 )
  {
    sprintf( buf, "Vendor specific (0x%02x)", (unsigned char)Cmd->Cmd[0] );
    ret = buf;
  }
  else
    ret = command_names[index].text;
  return ret;
}

void dump_bytes( char * dest, void * bytes, int count )
{
  int index;
  dest[0] = 0;
  for( index = 0; index < count; index++ )
  {
    if( index > 0 && (index % 24) == 0 ) strcat( dest, "\n" );
    sprintf( dest + strlen( dest ), " %02x", ((unsigned char *)bytes)[ index ] );
  }
}

char * return_code_text( int return_code )
{
  int index;
  index = 0;
  if( return_code < 0 ) return_code = -return_code;
  while( command_errors[index].code != 9999 && command_errors[index].code != return_code )
    index ++;
  return command_errors[index].text;
}

void dump_sense_info( char * buf, scsi_cmd * Cmd )
{
  int index;
  unsigned char asc, ascq;

  sprintf( buf, "Sense key : %s\n", sense_keys[Cmd->SenseBuffer[2]&0x0f] );

  asc = Cmd->SenseBuffer[ 12 ];
  ascq = Cmd->SenseBuffer[ 13 ];
  index = 0;
  while( sense_codes[ index ].asc >= 0 )
  {
    if( sense_codes[ index ].asc == asc &&
        ( sense_codes[ index ].ascq == ascq ||
          sense_codes[ index ].ascq == -1 ) )
    {
      sprintf( buf + strlen(buf), "Sense code : %s\n", sense_codes[ index ].text );
      break;
    }
    index++;
  }

  strcat( buf, "Sense buffer :" );
  dump_bytes( buf + strlen( buf ), Cmd->SenseBuffer, 18 );
  strcat( buf, "\n" );
}

void log_device_name( void )
{
  if( log_rw_flags & RWF_R )
    log_printf( "Unmentioned successful READ sequence from %ld to %ld\n\n",
             read_min, read_max );
  if( log_rw_flags & RWF_W )
    log_printf( "Unmentioned successful WRITE sequence from %ld to %ld\n\n",
                write_min, write_max );
  log_rw_flags = 0;
  if( current_device->sets )
    log_printf( "Device : %s %s\n", current_device->sets->dev_id.vend_id,
                 current_device->sets->dev_id.prod_id );
}

/* Ecriture du résultat d'une commane dans le fichier log, en fonction du code de retour */
/* in_out = 1 si c'est une demande de données, 0 si c'est une sortie */
void log_cmd( scsi_cmd * Cmd, int ret, int in )
{
  char buf[8000];
  unsigned char cmd_no;
  int rw_command; /* type de commande 0:divers, 1:lecture, 2:écriture */
  long address, size;

  if( !enable_log ) return;

  cmd_no = Cmd->Cmd[0];
  switch( cmd_no )
  {
  case 0x08: /* read(6) */
  case 0x28: /* read(10) */
  case 0xa8: /* read(12) */
  case 0xbe: /* read cd */
  case 0xd8: /* read cd-da */
    rw_command = 1;
    break;
  case 0x0a: /* write(6) */
  case 0x2a: /* write(10) */
  case 0xaa: /* write(12) */
    rw_command = 2;
    break;
  default:
    rw_command = 0;
    break;
  }

  if( ret == NOSCSIERROR )
  {
    switch( Cmd->CmdLen )
    {
      case 6:
        address = ((((scsi_cmd6*)(Cmd->Cmd))->LunAdr & 0x1f)<<16)
                  | ((scsi_cmd6*)(Cmd->Cmd))->Adr;
        size = ((scsi_cmd6*)(Cmd->Cmd))->Len;
        break;
      case 10:
        address = ((scsi_cmd10*)(Cmd->Cmd))->Adr;
        size = (((scsi_cmd10*)(Cmd->Cmd))->LenHigh << 8)
               | ((scsi_cmd10*)(Cmd->Cmd))->LenLow;
        break;
      case 12:
        address = ((scsi_cmd12*)(Cmd->Cmd))->Adr;
        size = ((scsi_cmd12*)(Cmd->Cmd))->Len;
        /* Cas du Read CD où la taille est sur 24 bits */
        if( cmd_no == 0xbe ) size >>= 8;
    }
    cmd_no = Cmd->Cmd[0];
    if( rw_command == 1 ) /* Lecture */
    {
      if( !(log_rw_flags&RWF_R) )
      {
        read_min = address;
        read_max = address + size;
        log_rw_flags |= RWF_R;
      } else
      {
        if( address < read_min ) read_min = address;
        address += size;
        if( address > read_max ) read_max = address;
      }
      return;
    }
    else if( rw_command == 2 )
    {
      if( !(log_rw_flags&RWF_W) )
      {
        write_min = address;
        write_max = address + size;
        log_rw_flags |= RWF_W;
      } else
      {
        if( address < write_min ) write_min = address;
        address += size;
        if( address > write_max ) write_max = address;
      }
      return;
    }
  }

  log_device_name();

  log_printf( "Command : %s\n", command_name( Cmd ) );

  strcpy( buf, "Command block :" );
  dump_bytes( buf + strlen( buf ), Cmd->Cmd, Cmd->CmdLen );
  strcat( buf, "\n" );
  log_write( buf );

  if( (!rw_command) && ((!in) || ret == NOSCSIERROR) && Cmd->TransferLen > 0 )
  {
    strcpy( buf, in?"Returned block :\n":"Parameter block :\n" );
    dump_bytes( buf + strlen( buf ), Cmd->Buffer, (int)Cmd->TransferLen );
    strcat( buf, "\n" );
    log_write( buf );
  }

  if( ret == STATUSERROR )
  {
    dump_sense_info( buf, Cmd );
    log_write( buf );
  }
  sprintf( buf, " -> %s\n\n", return_code_text( ret ) );

  log_write( buf );
}

int log_begin( void )
{
  enable_log = 1;
  return 0;
}

int log_end( void )
{
  enable_log = 0;
  return 0;
}

int set_logfile( const char * filename )
{
  if( log_file_id )
  {
    fclose( log_file_id );
    log_file_id = NULL;
  }
  if( filename == NULL )
    log_file_ok = 0;
  else
  {
    strcpy( log_filename, filename );
    log_file_ok = 1;
  }
  return 0;
}

void log_write( const char * msg )
{
  time_t t;
  if( log_file_ok )
  {
    if( !log_file_id )
    {
      t = time( NULL );
      log_file_id = fopen( log_filename, "a" );
      if( !log_file_id )
        return ;
      fprintf( log_file_id, "\n\n*****************************************\n%s\nNew session on %s\n",
               version_string, ctime( &t ) );
    }
    fprintf( log_file_id, "%s", msg );
    if( preferences.pref_flags.flushlog )
    {
      fclose( log_file_id );
      log_file_id = fopen( log_filename, "a" );
    }
  }
}

void log_printf( const char * format, ... )
{
  va_list arg;
  char buffer[512];
  
  va_start( arg, 0 );
  vsprintf( buffer, format, arg );
  log_write( buffer );
  va_end( arg );
}
