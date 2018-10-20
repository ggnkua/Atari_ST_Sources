/* copies a VFAT system to current dir */

/* WARNING: this small utility contains some
            very inefficient code that I'm
            not proud of. I can do better than
            this... sven 970825 */

#include <mintbind.h>
#include <tos.h>
#include <stdio.h>

#define TRUE 1
#define FALSE 0

/* typedefs */

typedef struct
{
 short drive;
 BPB   *bpb;
 char  *fat;
 char  *root_dir;
} drive_struct;

typedef struct
{
 unsigned char  name[11];    /* "tos" name */
 unsigned char  attr;
 unsigned char  dummy[14];   /* "unimportant stuff" like dates */
 unsigned char  first_cluster[2];
 unsigned char  size[4];     /* in bytes */
} DIR;

typedef struct
{
 unsigned char  id;
 unsigned char  name0_4[10]; 
 unsigned char  attr;
 unsigned char  reserved;
 unsigned char  alias_checksum;
 unsigned char  name5_10[12];  
 unsigned char  first_cluster[2];
 unsigned char  name11_12[4];    
} VDIR;

/* (global) variables */

#define TOS_PATH_LENGTH 512
char tos_path[TOS_PATH_LENGTH];   /* holds tos domain name */
#define LONG_FILE_LENGTH 256
char long_file_name[LONG_FILE_LENGTH+1]; /* holds long file name */
#define LONG_PATH_LENGTH 1024
char long_path[LONG_PATH_LENGTH]; /* holds long file name */

int Init_drive(int drive,drive_struct *str)
{
 /* read BPB,FAT and init drive struct */

 str->drive=drive;
 if ((!(str->bpb=Getbpb(drive)))||(str->bpb->bflags&1))
 /* cannot currently handle FAT16 */ 
 {
  return(FALSE);
 }

 if (!(str->fat=(char *) malloc(str->bpb->recsiz*str->bpb->fsiz)))
 {
  return(FALSE);
 }

 /* now read FAT */

 if (Rwabs(0,str->fat,str->bpb->fsiz,str->bpb->fatrec-str->bpb->fsiz,
           drive))
 {
  /* hmm error */
  free(str->fat);
  return(FALSE);
 }
 /* now alloc root dir */

 if (!(str->root_dir=(char *) malloc(str->bpb->recsiz*str->bpb->rdlen)))
 {
  free(str->fat);
  return(FALSE);
 }

 if (Rwabs(0,str->root_dir,str->bpb->rdlen,str->bpb->fatrec+str->bpb->fsiz,
           drive))
 {
  /* hmm error */
  free(str->root_dir);
  free(str->fat);
  return(FALSE);
 }

 return(TRUE);
}

void Deinit_drive(drive_struct *str)
{
 free(str->root_dir);
 free(str->fat);
}

long Next_cluster(drive_struct *str,long cluster)
{
 /* returns next cluster or zero if end of cluster chain */
 /* currently only handles FAT12 */

 register long bit_adr=cluster*3;
 register long adr=bit_adr/2;
 register unsigned char byte0=(unsigned char) *(str->fat+adr);
 register unsigned char byte1=(unsigned char) *(str->fat+adr+1);

 register long value=((byte1<<8)|byte0);
                           
 value=((bit_adr&1)?(value>>4):value)&0xfff;

 if ((value<2)||(value>=0xff0))
  value=0; /* 2->$fef are valid clusters */

 printf("curr cluster:%d next custer:%d\n",cluster,value);

 return (value);
}

#define FILE_BUFF_SIZE 4096
char file_buff[4096];

int Copy_file(char *tos_name,char *long_name,int attributes)
{
 short in_file,out_file;
 long size;
 int error;

 if ((in_file=Fopen(tos_name,0))<0)
  return(FALSE);

 if ((out_file=Fcreate(long_name,attributes))<0)
 {
  Fclose(in_file);
  return(FALSE);
 }

 do
 {
  size=Fread(in_file,FILE_BUFF_SIZE,file_buff);
  error=(size!=Fwrite(out_file,size,file_buff));
 } while((size==FILE_BUFF_SIZE)&&(!error));

 Fclose(out_file);
 Fclose(in_file);
 return(!error);
}


int Run_through_dir(DIR *entry, int nbr_of_entries, 
                    drive_struct *str, int *seq_in,
                    int *ch_sum_in, int *is_v_in,
                    char *my_path_end,
                    char *long_path_end)
{
 /* run through the dir copy files as it goes */

 /* my_dir_end points to end of current path */ 
 int expected_seq=*seq_in;  /* 0 means tos name slot */
 int last_check_sum=*ch_sum_in;
 int is_vfat_slot=*is_v_in;


 for(;nbr_of_entries>0;nbr_of_entries--,entry++,expected_seq--)
 {
  VDIR *vfat_slot=entry;
  /* is this an extended slot?? */
  
  if((vfat_slot->attr==0xf)&&
     (!vfat_slot->reserved)&&
     (!vfat_slot->first_cluster[0])&&
     (!vfat_slot->first_cluster[1]))
  {
   /* if last bumb expected seq and checksum */
   if (vfat_slot->id&0x40)
   {
    expected_seq=vfat_slot->id&0x3f;
    if (expected_seq<(LONG_FILE_LENGTH/13))
     long_file_name[expected_seq*13]=0; /* always terminate filename */

    last_check_sum=vfat_slot->alias_checksum;
    is_vfat_slot=TRUE;
   }
   /* check if checksum and sequence are
      correct */
   
   if (((vfat_slot->id&0x3f)==expected_seq)&&
       (vfat_slot->alias_checksum==last_check_sum)&&
       (expected_seq<(LONG_FILE_LENGTH/13)))
   {
    /* slot ok! copy filename */
    /* use the sequence number to index into the
       file name */
    char *name=long_file_name+(expected_seq-1)*13;

    /* so a simple conversion from unicode */
    /* will work on all ASCII characters */

    *name++=vfat_slot->name0_4[0];
    *name++=vfat_slot->name0_4[2];
    *name++=vfat_slot->name0_4[4];
    *name++=vfat_slot->name0_4[6];
    *name++=vfat_slot->name0_4[8]; 

    *name++=vfat_slot->name5_10[0]; 
    *name++=vfat_slot->name5_10[2]; 
    *name++=vfat_slot->name5_10[4]; 
    *name++=vfat_slot->name5_10[6]; 
    *name++=vfat_slot->name5_10[8]; 
    *name++=vfat_slot->name5_10[10]; 

    *name++=vfat_slot->name11_12[0]; 
    *name++=vfat_slot->name11_12[2]; /* that's it! 13 characters.. */ 
   }
   else
   {
    /* vfat corrupt */
    is_vfat_slot=FALSE;
   }
  }
  else
  {
   /* should it be the "tos" slot?? */
   if (expected_seq!=0)
    is_vfat_slot=FALSE;

   /* check if valid "tos" slot */

   /* DEBUG print! */
   if (is_vfat_slot)
    printf("file name found: %s\n",long_file_name);

   /* if valid copy file or create dir and descend */
   
   if((entry->attr!=0xf)&&
     (entry->first_cluster[0]|
      entry->first_cluster[1])&&
     (is_vfat_slot))
   {
    long cluster=(entry->first_cluster[1]<<8)|entry->first_cluster[0];
    unsigned char sum;
    int  i;
    char *ptr=entry->name;
    char *curr_tos_end=my_path_end;
 
    /* calc filename checksum */

    sum=i=0;
    for(;i<8;)
    {
     unsigned char ch=entry->name[i];
     sum=((((sum&1)<<7)|((sum&0xfe)>>1))+ch);

     if ((ch!=0)&&(ch!=' '))
     {
      *curr_tos_end++=ch;
     }
     i++;
    }

    *curr_tos_end++='.';

	i=0;
    for(;i<3;)
    {
     unsigned char ch=entry->name[8+i];
     sum=((((sum&1)<<7)|((sum&0xfe)>>1))+ch);

     if ((ch!=0)&&(ch!=' '))
     {
      *curr_tos_end++=ch;
     }
     i++;
    }

    if (*(curr_tos_end-1)=='.')
    {
     curr_tos_end--;
    }
    
    *curr_tos_end=0;
 
    
    if ((cluster>=2)&&(cluster<=0xfef)&&(last_check_sum==sum))
    {
     char *l_p;

     strcpy(long_path_end,long_file_name);

     printf("VFAT file path: %s\n",long_path);
     printf("tos file path: %s\n",tos_path);



     /* file is ok */
     if (entry->attr&0x10)
     {
      int seq=-1;
      int cs=0;
      int flag=FALSE;

      int  cluster_size=str->bpb->clsiz;
      char *cluster_buff=malloc(str->bpb->recsiz*str->bpb->clsiz);
      unsigned long cluster;

      if (!cluster_buff)
       return(FALSE);


      *curr_tos_end++='\\';
      l_p=long_path_end+strlen(long_path_end);

      /* directory.. create and descend! */
      printf("descending!\n");
      
      /* create dir on target */
      Dcreate(long_path);
      /* descend */

      *l_p++='\\';
      *l_p=0;

      cluster=(entry->first_cluster[1]<<8)|entry->first_cluster[0];

      do
      {
       Rwabs(0,cluster_buff,cluster_size,
             cluster_size*(cluster-2)+str->bpb->datrec,
             str->drive);              


       Run_through_dir(cluster_buff,str->bpb->recsiz*
                       cluster_size/sizeof(DIR),str,&seq,
                       &cs,&flag,curr_tos_end,l_p);

       cluster=Next_cluster(str,cluster);
      } while(cluster);
   
      free(cluster_buff);

	  printf("ascending\n");

      /* return */
      
     }
     else
     {
      /* normal file.. copy! */
      printf("normal file!\n");

      /* make dos name */

      if (!Copy_file(tos_path,long_path,entry->attr))
      {
       return(FALSE);
      }
     }
    }
   }
   /* if not ignore */
  }
 }

 *seq_in=expected_seq;      /* 0 means tos name slot */
 *ch_sum_in=last_check_sum;
 *is_v_in=is_vfat_slot;
 *my_path_end=0;
}

int Convert_drive(int drive)
{
 /* convert all of the drive */
 drive_struct str;

 if (!Init_drive(drive,&str))
  return(FALSE)

 /* go through root dir */
 
 /* set root path */
 tos_path[0]='A'+drive;
 tos_path[1]=':';
 tos_path[2]='\\';
 tos_path[3]=0;


#if 0
 /* DEBUG: get into temp dir.. */
 strcpy(long_path,"u:\\h\\tmp");
 Dsetpath(long_path);
#else
 Dgetpath(long_path,0);
#endif

 strcat(long_path,"\\");


 {
  int seq=-1;
  int cs=0;
  int flag=FALSE;
  char *l_p=long_path+strlen(long_path);
  Run_through_dir(str.root_dir,str.bpb->recsiz*str.bpb->rdlen/sizeof(DIR),
                 &str,&seq,&cs,&flag,&tos_path[3],l_p);
 }
 
 Deinit_drive(&str);
 return(TRUE);
}

int main(int argc, char *argv[])
{
 int drive=0; /* default is a: */

 if (argc>1)
 {
  drive=toupper(*argv[1])-'A';
 }
 if ((drive<0)||(drive>32))
 {
  printf("Faulty drive number %d\n",drive);
 }

 /* kick me into MiNT domain so I use proper filenames */

 Pdomain(1);

 /* convert the drive */
 Convert_drive(drive);
}