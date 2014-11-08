/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* -1 t/m -1023 TOS fout codes */

#define ERROR               -1
#define DRIVE_NOT_READY     -2
#define UNKNOWN_CMD         -3
#define CRC_ERROR           -4
#define BAD_REQUEST         -5
#define SEEK_ERROR          -6
#define UNKNOWN_MEDIA       -7
#define SECTOR_NOT_FOUND    -8
#define NO_PAPER            -9
#define WRITE_FAULT         -10
#define READ_FAULT          -11
#define GENERAL_MISHAP      -12
#define WRITE_PROTECT       -13
#define MEDIA_CHANGE        -14
#define UNKNOWN_DEVICE      -15
#define BAD_SECTORS         -16
#define INSERT_DISK         -17

#define EINVFN  -32     /* Onbekend funktienummer */
#define EFILNF  -33     /* File niet gevonden */
#define EPTHNF  -34     /* Pad niet gevonden */
#define ENHNDL  -35     /* Geen file-handles meer */
#define EACCDN  -36
#define EIHNDL  -37     /* Handle-nummer van file niet geldig */
#define ENSMEM  -39     /* Niet genoeg geheugen */
#define EIMBA   -40     /* Adres van geheugenblok niet geldig */
#define EDRIVE  -46
#define ENSAME  -48     /* Files niet op hetzelfde logische loopwerk */
#define ENMFIL  -49     /* Er kunnen geen files meer geopend worden */
#define ELOCKED	-58		/* File is gelocked */
#define ENSLOCK	-59		/* Lock niet gevonden */
#define GERANGE -64     /* Filepointer in ongeldig bereik */
#define EINTRN  -65     /* Interne fout */
#define EPLFMT  -66     /* Programma heeft niet het korrekte formaat om geladen te worden */
#define EGSBF   -67     /* Fout bij Mshrink of Mfree */

/* -1024 t/m -2047 gereserveerd voor gebruiker */

/* -2048 t/m -2063 file fouten */

#define EWRITE		-2048		/* Write error on file */
#define EREAD		-2049		/* Read error on file */
#define EDSKFULL	-2050		/* Disk full */
#define EEOF		-2051		/* End of file */

/* -2064 t/m -2079 lengte fouten */

#define ECOMTL		-2064		/* command line too long */
#define EPTHTL		-2065		/* path too long */
#define EFNTL		-2066		/* filename too long. */

/* -2096 t/m -2112 algemene fouten */

#define XUNKNOWN	-2096		/* Onbekende GEMDOS fout */

/* -4096 t/m 6120 fouten in Xdialog bibliotheek */

#define _XDVDI		-4096		/* Geen vdi handle meer beschikbaar */

int xerror( int toserror );
