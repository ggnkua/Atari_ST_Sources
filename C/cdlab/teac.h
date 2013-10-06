/*
 * TEAC.H - Commandes spécifiques aux graveurs compatibles TEAC
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

int teac_read_cd_da( unsigned long adr, unsigned long length,
                     unsigned char subcode, void * buffer );
int teac_write( unsigned long begin, unsigned short len, void * buffer,
                int extwr );
int teac_set_limits( long adr, unsigned long count );
int teac_set_subcode( int isrc_tno, unsigned short length, void * buffer );
int teac_set_subcode_pma( int p, int control, int tno, int index );
int teac_write_pma( void );
int teac_freeze( int bp );
int teac_clear_subcode( void );
int teac_next_writable_address( long * adr, long slba, long elba );
int teac_opc_execution( int jd );
int teac_set_preview_write( int preview );
int teac_set_write_method( int method );
int teac_set_speed( unsigned int speed );
/* int teac_get_max_speed( unsigned int * speed ); */

