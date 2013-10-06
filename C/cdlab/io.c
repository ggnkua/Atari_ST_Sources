/*
 * IO.C  -  Fonctions d'interfaçage avec SCSIDRV
 * Librairie de fonctions SCSI en C, s'appuyant sur la SCSI LIB.
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

#include <scsidrv/import.h>
#include <scsidrv/scsiio.h>
#include <scsidrv/export.h>

#include "prefs.h"
#include "misc.h"
#include "device.h"
#include "log.h"
#include "io.h"

void super_on( void );
void super_off( void );

scsi_cmd save_cmd;

/* Fonctions locales */
void set_cmd6( scsi_cmd6 *Cmd, unsigned short Opcode,
             unsigned long BlockAdr, unsigned short TransferLen )
{
  Cmd->Command = Opcode;
  Cmd->LunAdr  = current_device->Lun + (BlockAdr/0x10000L & 0x1F);
  Cmd->Adr     = BlockAdr % 0x10000L;
  Cmd->Len     = TransferLen;
  Cmd->Flags   = 0;
}

void set_cmd10( scsi_cmd10 *Cmd, unsigned short Opcode,
              unsigned long BlockAdr, unsigned short TransferLen )
{
  Cmd->Command   = Opcode;
  Cmd->Lun       = current_device->Lun;
  Cmd->Adr       = BlockAdr;
  Cmd->Reserved  = 0;
  Cmd->LenHigh   = TransferLen / 0x100;
  Cmd->LenLow    = TransferLen % 0x100;
  Cmd->Flags     = 0;
}

void set_cmd12( scsi_cmd12 *Cmd, unsigned short Opcode,
              unsigned long BlockAdr, unsigned long TransferLen)
{
  Cmd->Command = Opcode;
  Cmd->Lun     = current_device->Lun;
  Cmd->Adr     = BlockAdr;
  Cmd->Len     = TransferLen;
  Cmd->Reserved= 0;
  Cmd->Flags   = 0;
}

/* Fonctions globales */
scsi_cmd * set_cmd(
  short CmdLen,               /* Taille du bloc de commande (6,10,12) */
  unsigned short Opcode,      /* Opcode de la commande */
  unsigned long BlockAdr,     /* Champ d'adresse du bloc de comande */
  unsigned long TransferLen,  /* Champ de longueur du bloc de commande */
  void *Buffer,               /* Buffer d'entrée ou de sortie */
  unsigned long Len )         /* Longueur des infos à envoyer ou recevoir */
{
  static scsi_cmd scmd;
  static char cmd[12];

  switch( CmdLen )
  {
  case 6:
    set_cmd6( (scsi_cmd6*)cmd, Opcode, BlockAdr, TransferLen );
    break;
  case 10:
    set_cmd10( (scsi_cmd10*)cmd, Opcode, BlockAdr, TransferLen );
    break;
  case 12:
    set_cmd12( (scsi_cmd12*)cmd, Opcode, BlockAdr, TransferLen );
    break;
  };
  scmd.Handle = current_device->Handle;
  scmd.Cmd    = cmd;
  scmd.CmdLen = CmdLen;
  scmd.Buffer = Buffer;
  scmd.TransferLen = Len;
  scmd.SenseBuffer = ReqBuff;
  /* TimeOut en 1/200s. */
  scmd.Timeout  = preferences.scsi_timeout ? preferences.scsi_timeout : 2000;
  scmd.Flags    = 0;
  return &scmd;
}

int scsi_init( void )
{
  int ret;
  ret = init_scsiio();
  /* if( !ret ) die( "SCSIDRV Introuvable !" ); */
  return ret;
}

int scsi_in( scsi_cmd * Cmd )
{
  int ret;
  save_cmd = *Cmd;
  ReqBuff[2] = 0;
  super_on();
  ret = (int)In( (tpSCSICmd)Cmd );
  super_off();
  log_cmd( &save_cmd, ret, 1 );
  /* aff_sense( ); */
  return (ret)?ret:(ReqBuff[2]&0xf);
}

int scsi_out( scsi_cmd * Cmd )
{
  int ret;
  save_cmd = *Cmd;
  ReqBuff[2] = 0;
  super_on();
  ret = (int)Out( (tpSCSICmd)Cmd );
  super_off();
  log_cmd( &save_cmd, ret, 0 );
  /* aff_sense( ); */
  return (ret)?ret:(ReqBuff[2]&0xf);
}

int io_get_first_bus( struct bus_info * info )
{
  int ret;
  super_on();
  ret = (int)scsicall->InquireSCSI( cInqFirst, (tBusInfo*)info );
  super_off();
  return ret;
}

int io_get_next_bus( struct bus_info * info )
{
  int ret;
  super_on();
  ret = (int)scsicall->InquireSCSI(cInqNext, (tBusInfo*)info);
  super_off();
  return ret;
}

int io_get_first_device( short bus_no, struct dev_info * dev )
{
  int ret;
  super_on();
  ret = (int)scsicall->InquireBus( cInqFirst, bus_no, (tDevInfo*)dev );
  super_off();
  return ret;
}

int io_get_next_device( short bus_no, struct dev_info * dev )
{
  int ret;
  super_on();
  ret = (int)scsicall->InquireBus( cInqNext, bus_no, (tDevInfo*)dev );
  super_off();
  return ret;
}

io_check_device( short bus_no, int scsi_id, char * name,
                 unsigned short * features )
{
  int ret;
  struct dlong id;
  id.hi = 0;
  id.lo = scsi_id;
  super_on();
  ret = (int)scsicall->CheckDev( bus_no, (DLONG*)&id, name, (UWORD*)features );
  super_off();
  return ret;
}

short * io_open_device( short bus_no, const struct dlong * id,
                        unsigned long * max_len )
{
  short * ret;
  super_on();
  ret = (short*) scsicall->Open( bus_no, (DLONG *)id, max_len );
  super_off();
  return ret;
}

int io_close_device( short * handle )
{
  int ret;
  super_on();
  ret = (int)scsicall->Close( (tHandle)handle );
  super_off();
  return ret;
}

/* Gestion du mode superviseur et utilisateur */
void * save_ssp = 0;
void super_on( void )
{
  save_ssp = (void *)Super( 0 );
}
void super_off( void )
{
  Super( save_ssp );
}
