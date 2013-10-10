
typedef struct
{
 U8 dta_reserved[21];
 U8 dta_attribute;
 U16 dta_time;
 U16 dta_date;
 U32 dta_length;
 U8 dta_filename[14];
} DTA_STRUCT;

typedef struct
{
U32 fat_offset;
U8 fat_filename[12];
} FAT_ENTRY_STRUCT;

typedef struct
{
FAT_ENTRY_STRUCT fat_entry[256];
} FAT_TABLE_STRUCT;

typedef struct
{
U8 link_filename[128];
U16 link_files;
FAT_TABLE_STRUCT * link_fat_ptr;
} LINKFILE_TABLE_STRUCT;

void load_file_at(char *, U32 *);
void * load_allocate_file(char *);
S32 disk_file_length(U8 *);
void disk_save_file(void * s_ptr, U32 f_length, U8 * filename);

void linkfile_init(U8 *, LINKFILE_TABLE_STRUCT *);
void linkfile_load_fat(LINKFILE_TABLE_STRUCT *);
S16 linkfile_find_entry(U8 *, LINKFILE_TABLE_STRUCT *);
void * linkfile_load_allocate_file(U8 *, LINKFILE_TABLE_STRUCT *);
void * linkfile_load_allocate_depack_file(U8 *, LINKFILE_TABLE_STRUCT *);
void linkfile_load_file_at(U8 *, void *, LINKFILE_TABLE_STRUCT *);
void linkfile_load_depack_file_at(U8 * filename, void * load_ptr, LINKFILE_TABLE_STRUCT * l_ptr);
U32 linkfile_return_filelength(U8 *, LINKFILE_TABLE_STRUCT *);
U32 linkfile_return_packed_filelength(U8 * filename, LINKFILE_TABLE_STRUCT * l_ptr);
U32 linkfile_return_unpacked_filelength(U8 * filename, LINKFILE_TABLE_STRUCT * l_ptr);
U32 linkfile_return_program_size(U8 * filename,  LINKFILE_TABLE_STRUCT * l_ptr);

S32 disk_file_length(U8 * filename)
{
	S32 file_handle;
	S32 file_length;

	file_handle=Fopen(filename,0);
	if (file_handle >= 0)
	{
		file_length=Fseek(0,file_handle,2);
		Fseek(0,file_handle,0);
		Fclose(file_handle);
	}
	else
	{
		file_length=(S32)-1;
	}
	Fclose(file_handle);
	return(file_length);
}


void load_file_at(char * filename, U32 * load_address)
{
	S32 file_handle;
	U32 file_length;
	file_handle=Fopen(filename,0);
	if (file_handle >= 0)
	{
		file_length=Fseek(0,file_handle,2);
		Fseek(0,file_handle,0);
		Fread(file_handle,file_length,load_address);
		Fclose(file_handle);
	}
	else
	{
		Fclose(file_handle);
		printf("\nFILE NOT FOUND: %s",filename);
		Cnecin();		
	}	
}

void * load_allocate_file(char* filename)
{
	S32 file_handle;
	U32 file_length;
	void * load_address;

	file_handle=Fopen(filename,0);
	if (file_handle >= 0)
	{
		file_length=Fseek(0,file_handle,2);
		Fseek(0,file_handle,0);
		load_address=(void *)Malloc(file_length);
		Fread(file_handle,file_length,load_address);
		Fclose(file_handle);
		return(load_address);
	}
	else
	{
		Fclose(file_handle);
		printf("\nFILE NOT FOUND: %s",filename);
		Cnecin();		
		return(0);
	}
}

void disk_save_file(void * s_ptr, U32 f_length, U8 * filename)
{
	S32 file_handle;
	file_handle=Fcreate(filename,0);
	if(file_handle>0)
	{
		Fwrite(file_handle,f_length,s_ptr);
	}
	Fclose(file_handle);
}

void linkfile_init(U8 * filename, LINKFILE_TABLE_STRUCT * l_ptr)
{
 U16 i;
 for(i=0;i<128;i++) l_ptr->link_filename[i]=0;
 i=0;
 while((filename[i]!=0) && (i<128))
 {
  l_ptr->link_filename[i]=filename[i];
  i++;
 }
 linkfile_load_fat(l_ptr);
}

void linkfile_load_fat(LINKFILE_TABLE_STRUCT * l_ptr)
{
 U32 length;
 S32 file_handle;
 U8 * fat_space;

 l_ptr->link_fat_ptr=0;
 file_handle=Fopen(l_ptr->link_filename,0);
 if (file_handle >= 0)
 {
  Fread(file_handle,2,&l_ptr->link_files);
  length=((l_ptr->link_files<<4)+4);
  fat_space=Malloc(length);
  l_ptr->link_fat_ptr=(FAT_TABLE_STRUCT *)fat_space;
  Fread(file_handle,length,fat_space); 
  Fclose(file_handle);
 }
}

S16 linkfile_find_entry(U8 * filename, LINKFILE_TABLE_STRUCT * l_ptr)
{
 S16 i,j;
 U8 * s_ptr;
 U8 * d_ptr;

 for(i=0;i<l_ptr->link_files;i++)
 {
  s_ptr=filename;
  d_ptr=(U8 *)&l_ptr->link_fat_ptr->fat_entry[i].fat_filename[0];
  j=0;
  
  while((j<12) && (s_ptr[j]!=0) && (s_ptr[j]==d_ptr[j])) j++;
  if ((j==12) || (s_ptr[j]==d_ptr[j])) return(i);
 }
 return(-1);
}

void * linkfile_load_allocate_file(U8 * filename, LINKFILE_TABLE_STRUCT * l_ptr)
{
 S32 file_handle;
 S16 ix;
 U32 offset, length;
 void * f_space;

 ix=linkfile_find_entry(filename,l_ptr);

 if(ix>=0)
 {
  offset=l_ptr->link_fat_ptr->fat_entry[ix].fat_offset;
/*  length=l_ptr->link_fat_ptr->fat_entry[ix+1].fat_offset-offset; */
  length=linkfile_return_filelength(filename,l_ptr);
  f_space=(void *)Malloc(length);
  file_handle=Fopen(l_ptr->link_filename,0);
  Fseek(offset,file_handle,0);  
  Fread(file_handle,length,f_space);
  Fclose(file_handle);
  return(f_space);
 }
 return(0);
}

void * linkfile_load_allocate_depack_file(U8 * filename, LINKFILE_TABLE_STRUCT * l_ptr)
{
 S32 file_handle;
 S16 ix;
 U32 offset, length, ulength;
 void * f_space;

 ix=linkfile_find_entry(filename,l_ptr);

 if(ix>=0)
 {
  offset=l_ptr->link_fat_ptr->fat_entry[ix].fat_offset;
/*  length=l_ptr->link_fat_ptr->fat_entry[ix+1].fat_offset-offset; */
  length=linkfile_return_filelength(filename,l_ptr);
  f_space=(void *)Malloc(length);
  file_handle=Fopen(l_ptr->link_filename,0);
  Fseek(offset,file_handle,0);  
  ulength=linkfile_return_unpacked_filelength(filename,l_ptr);
  Fread(file_handle,ulength,f_space);
  Fclose(file_handle);  
  rldp_decrunch(f_space);  
  return(f_space);
 }
 return(0);
}

void linkfile_load_file_at(U8 * filename, void * load_ptr, LINKFILE_TABLE_STRUCT * l_ptr)
{
 S32 file_handle;
 S16 ix;
 U32 offset, length;

 ix=linkfile_find_entry(filename,l_ptr);

 if(ix>=0)
 {
  offset=l_ptr->link_fat_ptr->fat_entry[ix].fat_offset;
  length=l_ptr->link_fat_ptr->fat_entry[ix+1].fat_offset-offset;
  file_handle=Fopen(l_ptr->link_filename,0);
  Fseek(offset,file_handle,0);  
  Fread(file_handle,length,load_ptr);
  Fclose(file_handle);
 }
}

void linkfile_load_depack_file_at(U8 * filename, void * load_ptr, LINKFILE_TABLE_STRUCT * l_ptr)
{
 S32 file_handle;
 S16 ix;
 U32 offset, length;

 ix=linkfile_find_entry(filename,l_ptr);

 if(ix>=0)
 {
  offset=l_ptr->link_fat_ptr->fat_entry[ix].fat_offset;
  length=l_ptr->link_fat_ptr->fat_entry[ix+1].fat_offset-offset;
  file_handle=Fopen(l_ptr->link_filename,0);
  Fseek(offset,file_handle,0);  
  Fread(file_handle,length,load_ptr);
  Fclose(file_handle);
  rldp_decrunch(load_ptr);  
 }
}

U32 linkfile_return_filelength(U8 * filename, LINKFILE_TABLE_STRUCT * l_ptr)
{
 S32 file_handle;
 S16 ix;
 U32 length,offset;
 U32 ice_head[3];

 ix=linkfile_find_entry(filename,l_ptr);
 if(ix>=0)
 {
  offset=l_ptr->link_fat_ptr->fat_entry[ix].fat_offset;
  file_handle=Fopen(l_ptr->link_filename,0);
  Fseek(offset,file_handle,0);  
  Fread(file_handle,12,&ice_head[0]);
  Fclose(file_handle);
  if (ice_head[0]==0x49434521)
  {
   return(ice_head[2]);
  }  
  else if(ice_head[0]==0x41544D35)
  {
   return(ice_head[1]);
  }
  else
  {
   length=l_ptr->link_fat_ptr->fat_entry[ix+1].fat_offset;
   length-=l_ptr->link_fat_ptr->fat_entry[ix].fat_offset;
   return(length); 
  }
 }
 return(0);
}


U32 linkfile_return_unpacked_filelength(U8 * filename, LINKFILE_TABLE_STRUCT * l_ptr)
{
 S16 ix;
 U32 length;

 ix=linkfile_find_entry(filename,l_ptr);
 if(ix>=0)
 {
  length=l_ptr->link_fat_ptr->fat_entry[ix+1].fat_offset;
  length-=l_ptr->link_fat_ptr->fat_entry[ix].fat_offset;
  return(length); 
 } 
 return(0);
}


U32 linkfile_return_packed_filelength(U8 * filename, LINKFILE_TABLE_STRUCT * l_ptr)
{
 S16 ix;
 U32 length,offset;
 U16 file_handle;

 ix=linkfile_find_entry(filename,l_ptr);
 if(ix>=0)
 {
  offset=l_ptr->link_fat_ptr->fat_entry[ix].fat_offset;
  file_handle=Fopen(l_ptr->link_filename,0);
  Fseek(offset+8,file_handle,0);  
  Fread(file_handle,4,&length);
  Fclose(file_handle);
  return(length); 
 }
 return(0);
}

U32 linkfile_return_program_size(U8 * filename,  LINKFILE_TABLE_STRUCT * l_ptr)
{
 S16 ix;
 U32 length,offset;
 U16 file_handle;
 U32 prg_head[4];

 ix=linkfile_find_entry(filename,l_ptr);
 if(ix>=0)
 {
  offset=l_ptr->link_fat_ptr->fat_entry[ix].fat_offset;
  file_handle=Fopen(l_ptr->link_filename,0);
  Fseek(offset+2,file_handle,0);  
  Fread(file_handle,4*4,&prg_head[0]);
  Fclose(file_handle);
  length=0;
  for(ix=0;ix<4;ix++) length+=prg_head[ix];
  return(length); 
 }
 return(0);
}
