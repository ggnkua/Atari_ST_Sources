/*
 * fdstat.c
 *
 * maintain, compute and print out statistics on duplicate files.
 *
 * Roy Bixler
 * March 29, 1991
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 1, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */



#include <osbind.h>
#include <stdio.h>
#include <stdlib.h>

#include "fdfcomm.h"
#include "fdfstat.h"



static unsigned long total_bytes = 0UL, total_dup_bytes = 0UL;
static unsigned long total_del_bytes = 0UL;
static unsigned int num_files = 0U, num_which_dupd = 0U, num_dups = 0U;



/*
 * update_total_bytes
 *
 * called to update the total number of bytes in duplicate files
 */
void update_total_bytes(long f_size)

{
	total_bytes += f_size;
}



/*
 * update_total_del_bytes
 *
 * called to update the total number of bytes in duplicate files
 */
void update_total_del_bytes(long f_size)

{
	total_del_bytes += f_size;
}



/*
 * update_num_files
 *
 * called to update the total number of files
 */
void update_num_files()

{
	num_files++;
}



/*
 * update_num_which_dupd
 *
 * called to update the total number of files which have duplicates
 */
void update_num_which_dupd()

{
	num_which_dupd++;
}



/*
 * update_num_dups
 *
 * called to update the total number of duplicate files and total bytes in same
 */
void update_num_dups(unsigned n_dups, long bytes)

{
	num_dups += n_dups;
	total_dup_bytes += bytes;
}



/*
 * print_stats
 *
 * tabulate the statistics for this run of 'find duplicates'
 */
void print_stats()

{
	printf("Total # of files = %u\n", num_files);
	printf("Total bytes in files = %lu\n\n", total_bytes);

	printf("Total # of duplicate file names = %u\n", num_which_dupd);
	printf("Total # of duplicate files = %u\n", num_dups);
	printf("Total bytes in duplicate files = %lu\n", total_dup_bytes);
	if (i_flag)
		printf("Total bytes deleted = %lu\n", total_del_bytes);
	if (num_dups > 0)
		printf("\nAverage duplicate file size = %ld", total_dup_bytes/num_dups);
	if ((num_files > 0) && (num_dups > 0))
		printf("\nAverage # of duplicates per file = %f",
			   (float) num_dups/num_files);
	if ((num_which_dupd > 0) && (num_dups > 0))
		printf("\nAverage # of duplicates per duplicate name = %f",
			   (float) num_dups/num_which_dupd);
	if (num_dups)
		printf("\n");
}
