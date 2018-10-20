/* VFAT ls - something like DIR in Windows95 */

#include <mintbind.h>
#include <osbind.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TRUE 1
#define FALSE 0

#define MAXPATH	260

/* typedefs */

typedef struct {
	unsigned char name[11];		/* "tos" name */
	unsigned char attr;
	unsigned char dummy[10];	/* unimportant stuff */
	unsigned char time[2];
	unsigned char date[2];
	unsigned char first_cluster[2];
	unsigned char size[4];		/* in bytes */
} DIR;

typedef struct {
	unsigned char id;
	unsigned char name0_4[10];
	unsigned char attr;
	unsigned char reserved;
	unsigned char alias_checksum;
	unsigned char name5_10[12];
	unsigned char first_cluster[2];
	unsigned char name11_12[4];
} VDIR;

typedef struct {
	short drive;
	_BPB *bpb;
	unsigned char *fat;
	DIR *root_dir;
} drive_struct;

/* (global) variables */

#define TOS_PATH_LENGTH 512
unsigned char tos_path[TOS_PATH_LENGTH];	/* holds tos domain name */
#define LONG_FILE_LENGTH 256
unsigned char long_file_name[LONG_FILE_LENGTH + 1];		/* holds long file name */

int slash;
int FAT16 = FALSE;
int debug = FALSE;

int Init_drive(int drive, drive_struct * str)
{
	/* read BPB,FAT and init drive struct */

	str->drive = drive;
	if (!(str->bpb = Getbpb(drive))) {
		printf("Error getbpb()\n");
		return (FALSE);
	}

	FAT16 = (str->bpb->bflags & 1) ? TRUE : FALSE;

	if (!(str->fat = (unsigned char *) malloc(str->bpb->recsiz * str->bpb->fsiz))) {
		printf("Error malloc(FAT)\n");
		return (FALSE);
	}

	/* now read FAT */

	if (Rwabs(0, str->fat, str->bpb->fsiz, str->bpb->fatrec - str->bpb->fsiz,
			  drive)) {
		/* hmm error */
		printf("Error Rwabs(FAT)\n");
		free(str->fat);
		return (FALSE);
	}
	/* now alloc root dir */

	if (!(str->root_dir = (DIR *) malloc(str->bpb->recsiz * str->bpb->rdlen))) {
		printf("Error malloc(root)\n");
		free(str->root_dir);
		return (FALSE);
	}

	if (Rwabs(0, str->root_dir, str->bpb->rdlen, str->bpb->fatrec + str->bpb->fsiz,
			  drive)) {
		/* hmm error */
		printf("Error Rwabs(root)\n");
		free(str->root_dir);
		free(str->fat);
		return (FALSE);
	}

	return (TRUE);
}

void Deinit_drive(drive_struct * str)
{
	free(str->root_dir);
	free(str->fat);
}

long Next_cluster(drive_struct * str, long cluster)
{
	/* returns next cluster or zero if end of cluster chain */
	/* currently only handles FAT12 */

	register long bit_adr = cluster * (FAT16 ? 4 : 3);
	register long adr = bit_adr / 2;
	register unsigned char byte0 = (unsigned char) *(str->fat + adr);
	register unsigned char byte1 = (unsigned char) *(str->fat + adr + 1);

	register long value = ((byte1 << 8) | byte0);

	if (!FAT16)
		value = ((bit_adr & 1) ? (value >> 4) : value) & 0xfff;

	if ((value < 2) || (value >= str->bpb->numcl))
		value = 0;				/* 2->$fef are valid clusters */

	if (debug)
		printf("curr cluster:%ld next custer:%ld\n", cluster, value);

	return (value);
}

int Run_through_dir(DIR * entry, int nbr_of_entries, drive_struct * str, int *seq_in,
					int *ch_sum_in, int *is_v_in, unsigned char *path)
{
	/* run through the dir search for path */
	unsigned char *fname;

	/* my_dir_end points to end of current path */
	int expected_seq = *seq_in;	/* 0 means tos name slot */
	int last_check_sum = *ch_sum_in;
	int is_vfat_slot = *is_v_in;

	if (debug)
		printf("path = %s\t", path);

	fname = strchr(path, slash);
	if (fname == NULL) {
		fname = alloca(strlen(path) + 1);
		strcpy(fname, path);
		*path = 0;
	}
	else {
		int fname_len = fname - path;
		fname = alloca(fname_len + 1);
		strncpy(fname, path, fname_len);
		fname[fname_len] = 0;
		path += fname_len+1;
	}
	if (debug)
		printf("fname = %s\tnew_path = %s\n", fname, path);

	for (; nbr_of_entries > 0; nbr_of_entries--, entry++, expected_seq--) {
		VDIR *vfat_slot = (VDIR *) entry;
		DIR *fat_slot = (DIR *) entry;

		/* is this an extended slot?? */

		if ((vfat_slot->attr == 0xf) &&
			(!vfat_slot->reserved) &&
			(!vfat_slot->first_cluster[0]) &&
			(!vfat_slot->first_cluster[1])) {
			/* if last bumb expected seq and checksum */
			if (vfat_slot->id & 0x40) {
				expected_seq = vfat_slot->id & 0x3f;
				if (expected_seq < (LONG_FILE_LENGTH / 13))
					long_file_name[expected_seq * 13] = 0;	/* always terminate filename */

				last_check_sum = vfat_slot->alias_checksum;
				is_vfat_slot = TRUE;
			}
			/* check if checksum and sequence are
			   correct */

			if (((vfat_slot->id & 0x3f) == expected_seq) &&
				(vfat_slot->alias_checksum == last_check_sum) &&
				(expected_seq < (LONG_FILE_LENGTH / 13))) {
				/* slot ok! copy filename */
				/* use the sequence number to index into the
				   file name */
				unsigned char *name = long_file_name + (expected_seq - 1) * 13;

				/* so a simple conversion from unicode */
				/* will work on all ASCII characters */

				*name++ = vfat_slot->name0_4[0];
				*name++ = vfat_slot->name0_4[2];
				*name++ = vfat_slot->name0_4[4];
				*name++ = vfat_slot->name0_4[6];
				*name++ = vfat_slot->name0_4[8];

				*name++ = vfat_slot->name5_10[0];
				*name++ = vfat_slot->name5_10[2];
				*name++ = vfat_slot->name5_10[4];
				*name++ = vfat_slot->name5_10[6];
				*name++ = vfat_slot->name5_10[8];
				*name++ = vfat_slot->name5_10[10];

				*name++ = vfat_slot->name11_12[0];
				*name++ = vfat_slot->name11_12[2];	/* that's it! 13 characters.. */
			}
			else {
				/* vfat corrupt */
				is_vfat_slot = FALSE;
			}
		}
		else {
			/* should it be the "tos" slot?? */
			if (expected_seq != 0)
				is_vfat_slot = FALSE;

			/* check if valid "tos" slot */

			/* DEBUG print! */
			if (is_vfat_slot && debug)
				printf("VFAT name found: %s\n", long_file_name);

			/* if valid copy file or create dir and descend */

			if ((entry->attr != 0xf) && (entry->first_cluster[0] | entry->first_cluster[1])) {
				long cluster = (entry->first_cluster[1] << 8) | entry->first_cluster[0];
				unsigned char sum;
				int i;
				unsigned char tos_name[13];
				unsigned char *curr_tos_end = tos_name;

				if (is_vfat_slot) {
					/* calc filename checksum */

					sum = i = 0;
					for (; i < 8;) {
						unsigned char ch = entry->name[i];
						sum = ((((sum & 1) << 7) | ((sum & 0xfe) >> 1)) + ch);

						if ((ch != 0) && (ch != ' ')) {
							*curr_tos_end++ = ch;
						}
						i++;
					}

					*curr_tos_end++ = '.';

					i = 0;
					for (; i < 3;) {
						unsigned char ch = entry->name[8 + i];
						sum = ((((sum & 1) << 7) | ((sum & 0xfe) >> 1)) + ch);

						if ((ch != 0) && (ch != ' ')) {
							*curr_tos_end++ = ch;
						}
						i++;
					}

					if (*(curr_tos_end - 1) == '.') {
						curr_tos_end--;
					}

					*curr_tos_end = 0;
				}
				else {	/* create TOS file name */
					unsigned char tosext[4];

					strncpy(tos_name, fat_slot->name, 8);
					tos_name[8] = 0;
					strncpy(tosext, fat_slot->name + 8, 3);
					tosext[3] = 0;
					for (i = 7; i >= 0; i--)
						if (tos_name[i] == ' ')
							tos_name[i] = 0;
					for (i = 2; i >= 0; i--)
						if (tosext[i] == ' ')
							tosext[i] = 0;
					if (strlen(tosext)) {
						strcat(tos_name, ".");
						strcat(tos_name, tosext);
					}
					if (tos_name[0] > 0 && tos_name[0] != 0xe5 && strcmp(tos_name, ".") && strcmp(tos_name, "..")) {
						if (debug)
							printf("TOS name found: %s\n", tos_name);
						sum = last_check_sum;	/* simuluj OK situaci */
						*long_file_name = 0;	/* no VFAT alias */
					}
					else {
						*tos_name = 0;
						sum = last_check_sum - 1;
					}
				}


				if ((cluster >= 2) && (cluster <= str->bpb->numcl) && (last_check_sum == sum)) {
					int is_dir = (entry->attr & FA_DIR) ? TRUE : FALSE;

					if (!*fname) {
						unsigned char line[MAXPATH], *ptr;
						unsigned long f_size;
						unsigned short f_date, f_time, year, month, day,
						 hour, minute;

						ptr = entry->size;
						f_size = ptr[3] << 24 | ptr[2] << 16 | ptr[1] << 8 | ptr[0];
						ptr = entry->date;
						f_date = ptr[1] << 8 | ptr[0];
						ptr = entry->time;
						f_time = ptr[1] << 8 | ptr[0];
						ptr = line;
						ptr += sprintf(ptr, "%-13s", tos_name);
						if (is_dir)
							ptr += sprintf(ptr, "     <DIR>");
						else {
							ptr += sprintf(ptr, "%10ld", f_size);
						}
						year = (f_date >> 9) + 1980;
						month = (f_date >> 5) & 15;
						day = f_date & 31;
						hour = f_time >> 10;
						minute = (f_time >> 5) & 63;

						ptr += sprintf(ptr, " %4d/%02d/%02d %02d:%02d", year, month, day, hour, minute);
						sprintf(ptr, "  %s\n", long_file_name);
						printf(line);

					}
					else {
						if (is_dir && (strcasecmp(tos_name, fname) == 0 || strcasecmp(long_file_name, fname) == 0)) {
							int seq = -1;
							int cs = 0;
							int flag = FALSE;

							int cluster_size = str->bpb->clsiz;
							unsigned char *cluster_buff = (unsigned char *) malloc(str->bpb->recsiz * str->bpb->clsiz);
							unsigned long cluster;

							if (!cluster_buff)
								return (FALSE);

							/* directory.. create and descend! */
							if (debug)
								printf("descending!\n");

							/* descend */

							cluster = (entry->first_cluster[1] << 8) | entry->first_cluster[0];
							if (debug)
								printf("Cluster %ld\n", cluster);
							do {
								Rwabs(0, cluster_buff, cluster_size,
									  cluster_size * (cluster - 2) + str->bpb->datrec,
									  str->drive);

								if (debug)
									getchar();
								Run_through_dir((DIR *) cluster_buff, str->bpb->recsiz *
								   cluster_size / sizeof(DIR), str, &seq,
												&cs, &flag, path);

								cluster = Next_cluster(str, cluster);
							} while (cluster);

							free(cluster_buff);

							if (debug)
								printf("ascending\n");

							/* return */
						}
					}
				}
			}
			/* if not ignore */
		}
	}

	*seq_in = expected_seq;		/* 0 means tos name slot */
	*ch_sum_in = last_check_sum;
	*is_v_in = is_vfat_slot;

	return TRUE;
}

int main(int argc, char *argv[])
{
	char path[MAXPATH]="-v";
	int drive;
	drive_struct str;
	int seq = -1;
	int cs = 0;
	int flag = FALSE;

	if (argc > 1) {
		strcpy(path, argv[1]);
	}
	if (!strcmp(path, "-v") || !strcmp(path, "--version") || !strcmp(path, "-h") || !strcmp(path, "--help")) {
		printf("VFAT ls ver 0.1\n\
Written by Petr Stehlik in one sunny Sunday afternoon in February 1998.\n\
Actually 80%% of this code was written by Sven Karlsson in his utility\n\
for copying files from VFAT diskettes to minix-fs.\n\
This vls code will be included in ParShell and will allow us to\n\
copy files from VFAT disks until there will be real VFAT.XFS\n\n\
Usage: vls <drive>:[/path]\n");
		return 0;
	}
	drive = toupper(*path) - 'A';
	if ((drive < 0) || (drive > 32)) {
		printf("Faulty drive number %d\n", drive);
		return -1;
	}
	if (path[1] != ':') {
		printf("Faulty path. Use X:/PATH form\n");
		return -1;
	}
	if (strlen(path) == 2)
		strcat(path, "/");
	if (path[2] != '\\' && path[2] != '/') {
		putchar(path[2]);
		printf("Use absolute path. X:/something/anything\n");
		return -1;
	}
	slash = path[2];
	if (path[strlen(path) - 1] == slash)
		path[strlen(path) - 1] = 0;		/* strip last separator */

	if (!Init_drive(drive, &str))
		return -1;

	Run_through_dir(str.root_dir, str.bpb->recsiz * str.bpb->rdlen / sizeof(DIR), &str, &seq, &cs, &flag, path + 3);

	Deinit_drive(&str);
	return 0;
}
