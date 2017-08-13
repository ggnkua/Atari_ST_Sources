#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <process.h>
#include <math.h>
#include <conio.h>

#include "main.h"
#include "datatypes.h"
#include "filestuff.h"



//RSSET 0
/*
#define	header_id_					// RS.B 2
#define	basic_header_size_			// RS.B 2
#define	first_header_size_			// RS.B 1
#define	version_					// RS.B 1
#define	min_version_				// RS.B 1
#define	host_OS_					// RS.B 1
#define	arj_flags_					// RS.B 1
#define	method_						// RS.B 1
#define	file_type_					// RS.B 1
#define	garble_password_mod_		// RS.B 1
#define	date_time_stamp_			// RS.B 4
#define	compressed_size_			// RS.B 4
#define	original_size_				// RS.B 4
#define	original_CRC_				// RS.B 4
#define	entryname_					// RS.B 2
#define	file_access_mode_			// RS.B 2
#define	host_data_					// RS.B 2
*/

#define	compressed_size_ 16			// RS.B 4
#define	original_size_	 20 		// RS.B 4

u32 read_16_le(u8 *p)
{
	u32 v = 0;
	v = (p[1]<<8)|p[0];
	return v;
}

u32 read_32_le(u8 *p)
{
	u32 v = 0;
	v = (p[3]<<24)|(p[2]<<16)|(p[1]<<8)|(p[0]);
	return v;
}

//-----------------------------------------------------
void write16(u8 *p,u16 v)
{
	p[0] = (v>>8)&255;
	p[1] = (v)&255;
}

void write32(u8 *p,u32 v)
{
	p[0] = (v>>24)&255;
	p[1] = (v>>16)&255;
	p[2] = (v>>8)&255;
	p[3] = (v)&255;
}
//------------------------
u16 read16(u8 *p)
{
	u16 v;
	v = (p[0]<<8)|p[1];
	return v;
}

u32 read32(u8 *p)
{
	u32 v;
	v = (p[0]<<24)|(p[1]<<16)|(p[2]<<8)|p[3];
	return v;
}
//-----------------------------------------------------


int convert_arj_file()
{
	int in_length;
	u8 *inS;
	u8 *outS;
	u8 *arj_start_ptr;
	u8 *arj_archive_ptr;
	u8 *packed_data_ptr;
	u8 *ptr;
	u32 v;
	u32 packed_size,orig_size;

	in_length = get_filesize( archive_name );
	if(in_length==-1) return -1;


	inS  = (u8*)(calloc(in_length+4096,1));
	outS = (u8*)(calloc(in_length+4096,1));

	load_file( archive_name , inS);

	arj_start_ptr	= inS;
	ptr				= inS;

	v = read_16_le(ptr); ptr+=2;	// header id   60 EA
	v = read_16_le(ptr); ptr+=2;	// basic header size
	ptr+=v;

	v = read_32_le(ptr); ptr+=4;	// crc 32 bit

	v = read_16_le(ptr); ptr+=2;	// 1st extended header size
	ptr+=v;


	// archive file header
	arj_archive_ptr = ptr;

	packed_size = read_32_le(compressed_size_+ptr);	// 
	orig_size   = read_32_le(original_size_+ptr);	// 

	v = read_16_le(ptr); ptr+=2;	// header id   60 EA

	v = read_16_le(ptr); ptr+=2;	// basic header size
	ptr+=v;

	v = read_32_le(ptr); ptr+=4;	// crc 32 bit

	v = read_16_le(ptr); ptr+=2;	// 1st extended header size
	ptr+=v;

	packed_data_ptr = ptr;

	//----------------- write output
	ptr = outS;
	write32(ptr,'ARJ!');		ptr+=4;
	write32(ptr,orig_size);		ptr+=4;
	write32(ptr,packed_size);	ptr+=4;

	memcpy(ptr,packed_data_ptr,packed_size);

	save_file(archive_name, outS, packed_size+3*4);

	free(inS);
	free(outS);

	return 0;
}