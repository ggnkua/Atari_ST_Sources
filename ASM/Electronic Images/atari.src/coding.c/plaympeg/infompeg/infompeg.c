/*
 * InfoMPEG version 1.0
 * Copyright (C) 1993 Dennis Lee
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "infompeg.h"

/*
 * Usage of the program.
 */
void
usage() {
    fprintf(stderr,"\nUsage: InfoMPEG [-123] filename.mpg [filename.mpg ...]\n\n");
    fprintf(stderr,"       1 - Reports resolution and frame types(IPB) present(very fast)\n");
    fprintf(stderr,"       2 - More detail than 1, including # of each frame type\n");
    fprintf(stderr,"           present and overall compression\n");
    fprintf(stderr,"       3 - (Default) Reports the most information\n\n");
    fprintf(stderr,"InfoMPEG by Dennis Lee\n");
    exit(0);
    }

/*
 * Strips the full path of the file specified leaving only the filename.
 */
void
get_name (char *name) {
    int i, j, pos=0;
    for (i=strlen(name)-1;i>=0;i--)
	if (name[i]=='\\' || name[i]=='/' || name[i]==':')
	    break;
    if (i==0) i--;
    for (j=i+1; j <= strlen(name); j++)
	name[pos++]=toupper(name[j]);
    }

/*
 * Reads the next 24 bits in the stream for the pixel resolution
 * of the MPEG file. 12 bits each for height and width, respectively.
 */
void
get_stream_res(FILE *stream) {
    long byte1, byte2, byte3;
    byte1 = getc(stream);
    byte2 = getc(stream);
    byte3 = getc(stream);
    width = (byte1 << 4) | (byte2 >> 4);
    height = ((byte2 & 0x0f) << 8) | byte3;
    }

/*
 * This procedure is called after a picture start code has just been
 * read, and it proceeds to read info on the current frame, such as frame
 * type(IPB), and length.  The procedure also has code to find a recursive
 * frame sequence if one exists.
 */
void
get_frame_info (yes_or_no get_all_data, FILE *stream) {
    frame_info cur_frame;
    short cur_byte;

    cur_frame.frame_len = ftell(stream) - file_offset;
    file_offset = ftell(stream);

    if (previous_frame != 0) {      /* if a previous frame exists */
	switch (previous_frame) {
	    case I: frame_sums[0].sum_frame_len += cur_frame.frame_len;  break;
	    case P: frame_sums[1].sum_frame_len += cur_frame.frame_len;  break;
	    case B: frame_sums[2].sum_frame_len += cur_frame.frame_len;
	    }
	}

    if (get_all_data) {
	cur_byte=getc(stream);
	cur_byte=getc(stream);
	cur_frame.frame_type = (cur_byte >> 3) & 7;
	previous_frame = cur_frame.frame_type;
	switch (cur_frame.frame_type) {
	    case I: frame_sums[0].sum_frames++;  break;
	    case P: frame_sums[1].sum_frames++;  break;
	    case B: frame_sums[2].sum_frames++;
	    }
	if (cur_frame.frame_type==I && frame_sums[0].sum_frames==3) {
	    frame_cycle[cycle_len]=0;
	    cycle_len=0;
	    }
	if (frame_sums[0].sum_frames==2)
	    frame_cycle[cycle_len++] = cur_frame.frame_type;
	else if (frame_sums[0].sum_frames==3) {
	    if (frame_cycle[cycle_len++] != cur_frame.frame_type)
		cycle_exists=FALSE;
	    }
	total_frames++;
	if (report_info_type != 1) {
	    printf("%c", frame_types[cur_frame.frame_type]);
	    if ((total_frames % 64) == 0)
		printf("\n");
	    fflush(stdout);
	    }
	}
    }

/*
 * Parses the stream sequentially until a start code is found.
 * (a start code begins with 0x000001)
 * The last byte of the start code is left in the stream for an external
 * procedure to use (it specifies the type of start code).
 */
void
next_start_code (FILE *stream) {
    long counter=0;
    while(1) {
	switch(getc(stream)) {
	    case EOF:  return;
	    case 0x00: counter++; break;
	    case 0x01: if (counter >= 2) return;
	    default:   counter=0;
	    }
	}
    }

/*
 * Initializes all global variables for every new MPEG stream to be parsed.
 */
void
init_vars() {
    int i;
    file_offset=0;
    total_frames=0;
    previous_frame=0;
    cycle_exists=TRUE;
    cycle_len=0;
    for(i=0; i < 3; i++) {
	frame_sums[i].sum_frames=0;
	frame_sums[i].sum_frame_len=0;
	}
    }

/*
 * Collects info on the MPEG stream specified and presents them.
 */
void
report_info (char *filename, FILE *stream) {
    boolean error_exit=FALSE, finish=FALSE;
    static first_call=TRUE;
    char tmp_string[15];

    init_vars();
    get_name(filename);
    get_stream_res(stream);
    if (report_info_type==1) {
	if (first_call) {
	    first_call=FALSE;
	    printf("\nInfoMPEG version 1.0\n");
	    printf("--------------------\n");
	    printf("Filename                  Frame Resolution     Frame Types Present\n");
	    printf("--------                  ----------------     -------------------\n");
	    }
	while(!finish) {
	    next_start_code(stream);
	  /*
	   *  The last byte of a start code is read.  If the byte is
	   *  0x00 - data to reconstruct a frame follows
	   *  0xB7 - the MPEG stream ends (0x000001B7 is the sequence end code)
	   *  EOF  - a premature EOF has been encountered indicating the
	   *         bitstream is missing a sequence end code
	   */
	    switch (getc(stream)) {
		case 0x00: get_frame_info(YES, stream);     break;
		case 0xB7: error_exit=FALSE;  finish=TRUE;  break;
		case EOF:  error_exit=TRUE;   finish=TRUE;
		}
	    /* 
	     *  Finishes when at least 1 of each frame type is found or 3
	     *  I frames have been encountered.  It is assumed that some sort
	     *  of recursive frame sequence exists, in which case all frame
	     *  types in the stream have already been found.
	     */
	    if (frame_sums[0].sum_frames==3 || (frame_sums[1].sum_frames != 0
					    && frame_sums[2].sum_frames != 0))
		finish=TRUE;
	    }
	sprintf(tmp_string,"(%ldx%ld)", width, height);
	printf("%-29s%-26s",filename,tmp_string);
	/* Assumes an I frame is always present */
	printf("I");
	if (frame_sums[1].sum_frames != 0)
	    printf("P");
	if (frame_sums[2].sum_frames != 0)
	    printf("B");
	printf("\n");
	}
    else {
	short tmp_compression;
	long filesize, uncomp_len, i;
	printf("\nInfoMPEG version 1.0\n");
	printf("--------------------\n");
	printf("%s is (%ldx%ld)\n\n", filename, width, height);
	printf("Sequence of Frames (Decoder's Viewpoint)\n");
	printf("----------------------------------------\n");
	while(!finish) {
	    next_start_code(stream);
	    switch (getc(stream)) {
		case 0x00: get_frame_info(YES, stream);     break;
		case 0xB7: error_exit=FALSE;  finish=TRUE;  break;
		case EOF:  error_exit=TRUE;   finish=TRUE;
		}
	    }
	get_frame_info(NO, stream);

	printf("\n\nRecursive frame type sequence : ");
	if (cycle_exists && (frame_sums[0].sum_frames > 3)) {
	    short i;
	    for(i=0; i < cycle_len; i++)
		printf("%c", frame_types[frame_cycle[i]]);
	    printf("\n                       Length : %d\n\n",cycle_len);
	    }
	else
	    printf("None found.\n\n");

	filesize = ftell(stream);
	uncomp_len = width*height*3*total_frames;
	if (report_info_type==3) {
	    for(i=0; i < 3; i++) {
	    if (frame_sums[i].sum_frames != 0) {
		printf("# of %c Frames : %d\n", frame_types[i+1], frame_sums[i].sum_frames);
		printf("Average Size  : %ld Bytes\n", frame_sums[i].sum_frame_len/
						      frame_sums[i].sum_frames);
		printf("Compression   : %ld:%ld  or\n", width*height*3*frame_sums[i].sum_frames,
							frame_sums[i].sum_frame_len);
		printf("                %d to 1\n\n", width*height*3*frame_sums[i].sum_frames/
						      frame_sums[i].sum_frame_len);
		}
	    }
	    printf("Total Frames        : %d\n", total_frames);
	    printf("Overall Avg Size    : %ld Bytes\n", filesize/total_frames);
	    printf("Overall Compression : %ld:%ld  or\n", uncomp_len, filesize);
	    tmp_compression = uncomp_len/filesize;
	    printf("                      %d to 1\n\n", tmp_compression);
	    }
	else {
	    for(i=0; i < 3; i++) {
		if (frame_sums[i].sum_frames != 0)
		    printf("# of %c Frames : %d\n", frame_types[i+1], frame_sums[i].sum_frames);
		}
	    printf("Total Frames  : %d\n", total_frames);
	    printf("Overall Compression : %ld:%ld  or\n", uncomp_len, filesize);
	    tmp_compression = uncomp_len/filesize;
	    printf("                      %d to 1\n\n", tmp_compression);
	    }
	if (num_files < MAX_FILES) {
	    strcpy(files[num_files].name, filename);
	    files[num_files].size = filesize;
	    tot_len += uncomp_len;
	    sprintf(tmp_string,"(%ldx%ld)", width, height);
	    strcpy(files[num_files].resolution, tmp_string);
	    files[num_files].frames = total_frames;
	    strcpy(tmp_string,"I");
	    if (frame_sums[1].sum_frames != 0)
		strcat(tmp_string,"P");
	    if (frame_sums[2].sum_frames != 0)
		strcat(tmp_string,"B");
	    strcpy(files[num_files].frame_types_found, tmp_string);
	    files[num_files++].compression = tmp_compression;
	    }
	}
    if (error_exit)
	fprintf(stderr,"Error: Premature EOF in %s.\n",filename);
    }

/*
 * Sorts the MPEG streams in order of compression(greatest to least).
 */
void
sort_files(short start, short end) {
    file_info tmp;
    int i, j, largest_left;
    for(i = start; i < end; i++) {
	tmp = files[i];
	largest_left=i;
	for(j = i+1; j <= end; j++) {
	    if (files[j].compression > tmp.compression) {
		tmp = files[j];
		largest_left = j;
		}
	    }
	tmp = files[i];
	files[i] = files[largest_left];
	files[largest_left] = tmp;
	}
    }

/*
 * If more than one MPEG stream is specified on the command line, with
 * 'report_info_type' not equal to 1, a chart listing the streams in order
 * of compression(greatest to least) is displayed allowing comparisons
 * between the streams.
 */
void
report_comparison() {
    ULONG i, tot_file_len=0;
    printf("\n*********************************************************\n\n");
    printf("MPEG Files (Ordered by Compression)\n");
    printf("-----------------------------------\n");
    printf("Filename        Filesize   Resolution  #Frames  Types  Compression\n");
    printf("--------        --------   ----------  -------  -----  -----------\n");
    sort_files(0, num_files-1);
    for(i=0; i < num_files; i++) {
	printf("%-17s%-10ld%-14s%-8d%-10s%d\n", files[i].name,
						files[i].size,
						files[i].resolution,
						files[i].frames,
						files[i].frame_types_found,
						files[i].compression);
	tot_file_len += files[i].size;
	}
    printf("------------------------------------------------------------------\n");
    printf("Total Filesizes: %-10ldTotal Compression: %ld:%ld  or\n", tot_file_len,
								      tot_len,
								      tot_file_len);
    printf("                                              %d to 1\n", tot_len/
								      tot_file_len);
    }

main(short argc, char *argv[]) {
    FILE *mpeg_stream;
    char filename[100];
    short file_start=1;

    #ifdef BORLAND
     expand_cmd_line(&argc, &argv);
    #endif

    if (argc < 2)
	usage();
    else {
	report_info_type = 3;
	if (argv[1][0] == '-') {
	    file_start++;
	    switch (argv[1][1]) {
		case '1': report_info_type = 1; break;
		case '2': report_info_type = 2; break;
		case '3': report_info_type = 3; break;
		default : usage();
		}
	    }
	num_files=0;
	for(;file_start < argc; file_start++) {
	    strcpy(filename,argv[file_start]);
	    if ((mpeg_stream = fopen(filename,"rb")) == NULL) {
		fprintf(stderr,"Error: Cannot open file %s.\n",filename);
		continue;
		}
	    next_start_code(mpeg_stream);
	    if (getc(mpeg_stream) != 0xB3) {  /* 0xB3 is the last byte of the sequence start code */
		fprintf(stderr,"Error: %s is not a valid MPEG video stream.\n",filename);
		fclose(mpeg_stream);
		continue;
		}
	    report_info(filename, mpeg_stream);
	    fclose(mpeg_stream);
	    }
	if (num_files > 1)
	    report_comparison();
	}
    return(0);
    }
