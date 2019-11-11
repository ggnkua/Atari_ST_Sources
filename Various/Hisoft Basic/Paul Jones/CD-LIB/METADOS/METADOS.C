/*
	Bindings for MetaDOS functions, requires PureC TOS library
    
    Copyright (c) Julian F. Reschke (jr@ms.maus.de), 16. Mai 1994
    Free distribution and usage allowed as long as the file remains 
    unchanged.
    
    See MetaDOS developer manuals for a description of the data structures.
*/

#include <metados.h>
#include <tos.h>

void
Metainit (META_INFO_1 *buffer)
{
	xbios (0x30, buffer);
}

long
Metaopen (short drive, META_DRVINFO *buffer)
{
	return xbios (0x31, drive, buffer);
}

long
Metaclose (short drive)
{
	return xbios (0x32, drive);
}

long
Metaread (short drive, void *buffer, long blockno, short blks)
{
	return xbios (0x33, drive, buffer, blockno, blks);
}

long
Metawrite (short drive, void *buffer, long blockno, short blks)
{
	return xbios (0x34, drive, buffer, blockno, blks);
}

long
Metastatus (short drive, void *buffer)
{
	return xbios (0x36, drive, buffer);
}

long
Metaioctl (short drive, long magic, short opcode, void *buffer)
{
	return xbios (0x37, drive, magic, opcode, buffer);
}

long
Metastartaudio (short drive, short flag, unsigned char *bytearray)
{
	return xbios (0x3b, drive, flag, bytearray);
}

long
Metastopaudio (short drive)
{
	return xbios (0x3c, drive);
}

long
Metasetsongtime (short drive, short repeat, long starttime, long endtime)
{
	return xbios (0x3d, drive, repeat, starttime, endtime);
}

long
Metagettoc (short drive, short flag, CD_TOC_ENTRY *buffer)
{
	return xbios (0x3e, drive, flag, buffer);
}

long
Metadiscinfo (short drive, CD_DISC_INFO *p)
{
	return xbios (0x3f, drive, p);
}

