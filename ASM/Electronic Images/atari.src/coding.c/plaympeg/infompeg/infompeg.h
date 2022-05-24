/*
 * Header file for InfoMPEG
 * Copyright (C) 1993 Dennis Lee
 */

#define MAX_FILES         256
#define MAX_CYCLE_LEN     1000
#define ULONG             unsigned long
typedef enum {NO, YES}     yes_or_no;
typedef enum {FALSE, TRUE} boolean;

typedef struct {
    long sum_frames;       /* number of frames of one type */
    long sum_frame_len;    /* number of bytes for all frames of one type */
    } frame_type_sums;
typedef struct {
    enum {I=1,P,B} frame_type;
    long frame_len;
    } frame_info;
typedef struct {
    char name[40];
    long size;
    char resolution[15];
    short frames;
    char frame_types_found[5];
    short compression;
    } file_info;

static long file_offset;
static long total_frames;
static long height, width;
static short report_info_type;
static short previous_frame;
static char frame_types[5]={' ','I','P','B'};
static char frame_cycle[MAX_CYCLE_LEN];
static short cycle_len;
static boolean cycle_exists;
static frame_type_sums frame_sums[3];
static ULONG tot_len=0;          /* total uncompressed length of all MPEG streams */
static short num_files;
static file_info files[MAX_FILES];

void usage(void);
void get_name(char *);
void get_stream_res(FILE *);
void get_frame_info(yes_or_no, FILE *);
void next_start_code(FILE *);
void init_vars(void);
void report_info(char *, FILE *);
void sort_files(short, short);
void report_comparison(void);
