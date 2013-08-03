/********************************************\
* 					     *
* flip: Unprotected disk copier		     *
* By Colas NAHABOO (INRIA sophia-antipolis)  *
* 					     *
* Compile with MEGAMAX C v1.1 (in-line asm)  *
*					     *
\********************************************/

#define VERSION "2.7"
#define DATE	"Jun 25 88"

char           *header =
"\33E\33e\33v\033p\
FLIP: disk copier by Colas Nahaboo     v%-5s %-9s           Free Ram:%4ldK\
\033q\n\n";

#include <osbind.h>
#include <stdio.h>

#define BLANK (0xE5E5)		/* std sector format value */
#define MAGIC (0x87654321L)	/* magic number value */
unsigned char *ROMS_YEAR = 0x00fc0018L + 3L; /* year of the roms */
#define MEMORY_LEFT 0		/* bytes not eaten by main buffer */
#define TRACK_RETRY 4		/* number of full track retrys */
#define NO_DISK		0	/* no disk in drive */
#define SOURCE_DISK	1	/* source disk in drive */
#define DEST_DISK	2	/* destination disk in drive */

				/* list of fatal errors */
#define NORMAL		10
#define USER_ABORT	1
#define SYNTAX_ERROR	2
#define NO_DISK_IN_MEMORY 3
#define NO_OVERRIDE	4
#define NO_DRIVE_B	5
#define DOUBLE_ON_BACK	6
#define NO_FLIP_ON_DOUBLE 7
#define BAD_OPTION	8
#define NO_MEMORY	9

int bad_option	=	' ';

/* twister interface */
extern          twister();	/* adress of formatter */
char            buffer_data[0x3FFF];	/* 16k of buffer */
extern long     buffer;		/* format track buffer */
extern int      thedisk,	/* A=0, B=1 */
                dblsided,	/* SS=0, DS= -1 */
                sectoroffset,	/* 0 = sectors 0 to 10, 1= 11 to 20 */
                flipped,	/* normal=0, back side=1 */
		keypress,	/* 1 if key aborted format */
                starttrack,	/* 0 or more */
                endtrack;	/* 80 or more */
extern int      badflag;	/* return code */
extern int	new_roms;	/* are we running with the new roms? */

/* flip's globals */
long            buffer_size = 0L;	/* max size of buffer */
jmp_buf         start_dest;	/* insert dest */
int		drives_content[2];/* what is there in the drives ? */

int				/* disk parameters read from boot sect */
                drive,		/* drive: 0=A, 1=B */
                sides,		/* 0=SS, 1=DS */
                tracks,		/* 80 normally */
                st,		/* sectors per track (9 or 10) */
                bps;		/* bytes per sector (512) */

int				/* options */
		verify_source, 	/* just verify the source */
		read_source,	/* read source */
		zero_disk,	/* prepares blank image in memory */
		write_dest,	/* write dest */
                format,		/* do format */
                Verify,		/* do verify formatting */
                verify,		/* do verify writing */
		override,	/* do not read boot sector */
		single,		/* Single Sided */
		nine_sectors,	/* 9 sect/track */
                interactive,	/* interactive */
		play_it_again_sam, /* user hit "return" */
                use_track_map;	/* to use built-in track map */

int             d1=0, d2=0, s1=0, s2=0; /* drive/side source/dest */

#define TRACK_MAP_SIZE	99
char            track_map[TRACK_MAP_SIZE + 1];
char            full_track_map[TRACK_MAP_SIZE + 1]; /* for multipasses */

int             one_valid_copy_done = 0;	/* used to allow "r" */
int             multipass;	/* when not enough mem */
int		first_pass,
		last_pass;

jmp_buf         start;
char           *buf = NULL;
char           *malloc(), *index(), *get_drive();
unsigned	is_non_executable();
extern char    *help_text[];
int             errno;

char            rep[40], default_rep[40]; /* input buffer */

/*
 * parse the command line and set options
 * return 1 if error, 0 if OK
 */

int
parse_command()
{
	printf("Command (? for help) (CR= %s ): ", default_rep);
	fflush(stdout);
	gets(rep);
 	/* parse main options */
	verify_source = read_source = zero_disk = write_dest = format =
	verify = Verify = use_track_map = override = nine_sectors = single =
	interactive = d1 = d2 = s1 = s2 = play_it_again_sam = 0;
	if (!rep[0]) {		/* void rep ==> default */
	    strcpy(rep, default_rep);
	    play_it_again_sam = 1;
	}
	switch(rep[0]){
	case '?':		/* need help */
	    more(help_text);
	    longjmp(start, NORMAL);
	case 'q':		/* quit */
	    exit(0);
	case 'v':
	    verify_source = 1;
	    get_options(get_drive(SOURCE_DISK, rep+1, 1), "os9ti");
	    return 0;
	case 'r':
	    if (!one_valid_copy_done) 
		longjmp(start, NO_DISK_IN_MEMORY);
	    get_options(get_drive(DEST_DISK, rep+1,1), "fvVi");
	    write_dest = 1;
	    return 0;
	case 'f':
	    override = 1;
	    get_options(get_drive(DEST_DISK, rep+1,1), "s9tvVfi");
	    zero_disk = 1;
	    write_dest = 1;
	    return 0;
	case 'a': case 'b':
	    get_options(
		get_drive(DEST_DISK,
			  get_drive(SOURCE_DISK, rep, 0),
			  1),
		"os9tvVfi");
	    read_source = write_dest = 1;
	    return 0;
	default :
	    longjmp(start, SYNTAX_ERROR);
	}
}

char *
get_drive(drive, string, is_optional)
int drive;
char * string;
int is_optional;
{
    char *ptr =string;
    int side = 0, default_drive = 0;

    if(!index("abAB", string[0])) 
    	if(is_optional)
	    default_drive = 1;		/* drive A is default */
	else
	    longjmp(start, SYNTAX_ERROR);
    if(!default_drive && (index("12", string[1]))) {
	ptr ++;
	side = (toupper(*ptr) == '2' ? 1 : 0);
    }
    if(drive == DEST_DISK){
	d2 = (default_drive ? 0 : (toupper(*string) == 'B' ? 1 : 0));
	s2 = side;
    }else{
	d1 = (default_drive ? 0 : (toupper(*string) == 'B' ? 1 : 0));
	s1 = side;
    }
    return (default_drive ? string : ptr +1);
}

get_options(string, options)
char *string, *options;
{
    while(*string){
	if(!index(options, *string)) {
	    bad_option = *string;
	    longjmp(start, BAD_OPTION);
	}
	switch(*string){
	case 'o': override = 1; break;
	case 's': single = 1; break;
	case '9': nine_sectors = 1; break;
	case 't': use_track_map = 1; break;
	case 'v': verify = 1; break;
	case 'V': Verify = 1; break;
	case 'f': format = 1; break;
	case 'i': interactive = 1; break;
	}
    string++;
    }
    if(!override && (single || nine_sector)) 
	longjmp(start, NO_OVERRIDE);
}

main()
{

    buffer = (long) buffer_data;/* init twister */
    sectoroffset = 0;		/* mem alloc */
    buffer_size = (long) Malloc(-1L) - MEMORY_LEFT;
    buf = (char *) Malloc(buffer_size);
    if(((unsigned) *ROMS_YEAR) > (unsigned) 0x86)
	new_roms = 1;
    else
	new_roms = 0;
    if(is_drive_B())		/* default command */
    	strcpy(default_rep, "bfv");
    else
    	strcpy(default_rep, "afv");
    printf(header, VERSION, DATE, buffer_size / 1024);	/* resets screen */
    switch(setjmp(start)){
    case 0:case NORMAL:			/* initial */
	break;
    case USER_ABORT:			/* user abort */
	printf("\007Ok, aborted...\n");
	break;
    case SYNTAX_ERROR:			/* syntax error */
	printf("\007SYNTAX ERROR!\n");
	break;
    case NO_DISK_IN_MEMORY:
	printf("\007No disk in memory!\n");
	break;
    case NO_OVERRIDE:
    	printf("\007Options d and 9 requires option o\n");
	break;
    case NO_DRIVE_B:
	printf("\007Sorry, no drive B present...\n");
	break;
    case DOUBLE_ON_BACK:
	printf("\007A double sided disk on back? use override!\n");
	break;
    case NO_FLIP_ON_DOUBLE:
	printf("\007You cannot flip double-sided disks!\n");
	break;
    case BAD_OPTION:
	printf("\007bad option: %c\n", bad_option);
	break;
    case NO_MEMORY:
	printf("\007Sorry, not enough memory...\n");
	break;
    }
    while (1) {
	/* we dont know what's in the drives */
	drives_content[0] = drives_content[1] = NO_DISK;
	/* prompts and parse command and options */
	parse_command();
	/* check for drive B */
	if ((d1 || d2) && (!is_drive_B()))
	    longjmp(start, NO_DRIVE_B);
	/* prompts for track_map */
	if (use_track_map)
	    input_track_map();
	/* examine source disk */
	if(read_source || verify_source || zero_disk)
    	    examine_disk(d1, s1);
	/* check run time consistency */
	if (sides == 2) {
	    if (s1 == 1) 
	        longjmp(start, DOUBLE_ON_BACK);
	    if (s1 != s2) 
		longjmp(start, NO_FLIP_ON_DOUBLE);
	}
	strcpy(default_rep, rep);	/* seems ok then take it as default */

   	/* copy disk */
	if((d1 != d2) && 	/* suppose user had time to put dest */
		(read_source || verify_source))
	    drives_content[d2] = DEST_DISK;
	do_copy_disk();
	printf("\007OK, done.\n");
    }
}

/*
 * do_copy_disk:
 * do a one-pass or multipass copy 
 */

do_copy_disk()
{
	int             track_number = 0, i, j, to_do;

	multipass = 0;
	if (read_source) {
	    for (i = 0; i < TRACK_MAP_SIZE; i++)
		track_number += (int) track_map[i];
	    if(buffer_size < (sides * bps * st * (long) track_number))
	        multipass = 1;
	    one_valid_copy_done = !multipass; /* let previous value of
			multipass inchanged if no read_source */
	}
	if(zero_disk) one_valid_copy_done = 0;
	bcopy(track_map, full_track_map, TRACK_MAP_SIZE);
	if(!multipass){
	    copy_disk();
	}else{
	    for(j=0; j<TRACK_MAP_SIZE; j++)
		track_map[j] = '\0';
	    track_number = buffer_size / (sides*bps*st);
	    i = to_do = 0;
	    first_pass = 1;
	    last_pass  = 0;
	    while(i < TRACK_MAP_SIZE){
		if(full_track_map[i]){
		    to_do++;
		    track_map[i] = '\001';
		}
		if(to_do == track_number){
		    copy_disk();
		    to_do = first_pass = 0;
		    for(j=0; j<TRACK_MAP_SIZE; j++)
			track_map[j] = '\0';
		}
		i++;
	    }
	    first_pass = 0;
	    last_pass = 1;
	    copy_disk();
	}
}


/*
 * examine_disk: reads boot sector to determine type of disk.
 */

/* describe the BOOT sector by offsets in the boot sector */
#define b_bootbranch 0
#define b_oem 0x02
#define b_serial 0x08
#define b_bps 0x0B
#define b_spc 0x0D
#define b_res 0x0E
#define b_nfats 0x10
#define b_ndirs 0x11
#define b_nsects 0x13
#define b_media 0x15
#define b_spf 0x16
#define b_spt 0x18
#define b_nsides 0x1A
#define b_nhide 0x1C
#define b_boot 0x1E
#define b_checksum 0x01FE

/* 2 chars ==> 1 int */
#define canshort(x,y) (((unsigned)(x))|(((unsigned)(y))<<8))

unsigned char   bb[512];

randomize_boot()
{
    long serial;
    unsigned non_exec = is_non_executable(buf);

    if((!multipass || first_pass) && track_map[0]) {
	serial = Random();
	buf[b_serial] = (char) ((serial >> 16) & 255L);
	buf[b_serial+1] = (char) ((serial >> 8) & 255L);
	buf[b_serial+2] = (char) (serial & 255L);
	update_checksum(buf, non_exec);
    }
}

/*
 * prepares a blank image:
 * boot sector, & zero tracks 0&1 (if enough memory)
 */

do_zero_disk()
{
    unsigned nsects;

    if(buffer_size < (sides * bps * st * 2L)) longjmp(start, NO_MEMORY);
    bfill(buf, '\0', (long) (sides * bps * st * 2L));
    Protobt(buf, 0x02000000L, ((sides == 2) ? 3 : 2), 0);
    buf[b_spt] = (char) (st & 0xFF);
    nsects = (unsigned) (sides * st * (1 + max_track()));
    buf[b_nsects] = (char) (nsects & 255);
    buf[b_nsects+1] = (char) ((nsects >> 8) & 255);
    update_checksum(buf, (unsigned) 1);
    printf("Formatting %s sided disk, %d tracks and %d sectors.\n",
	((sides == 1) ? "single" : "double"), 1+max_track(), st);
}

int
max_track()
{
    int i;

    for (i= TRACK_MAP_SIZE -1; i>=0; i--)
	if(full_track_map[i]) return i;
    return 0;
}

examine_disk(drive, side)
int             drive, side;
{
    int             i;

    if (override) {
	sides = (single ? 1 : 2);
	bps = 512;
	st = (nine_sectors ? 9 : 10);
	tracks = 80;
    } else {
    	if (drives_content[drive] != SOURCE_DISK) {
	    prompt_for_disk(SOURCE_DISK, drive, side);
    	}
	while (Floprd(&bb, 0L, drive, 1, 0, side, 1)) {
	    printf("\007Cannot read boot block! CR/SP=retry, other=abort: ");
	    fflush(stdout);
	    if (!index("\r\n ", (char) Cnecin()))
		longjmp(start, USER_ABORT);
	}
	if(!is_non_executable(bb)) {
    printf("\007EXECUTABLE BOOT! at $3A, %2x %2x %2x -- check for virus\n",
	    (int) bb[58], (int) bb[59], (int) bb[60]);
	}
	printf("Disk in drive %c:", 'A' + drive);
	printf(" %d side", sides = (int) bb[b_nsides]);
	printf("%s, %d tracks,", (sides == 2 ? "s" : ""),
	       tracks = ((canshort(bb[b_nsects], bb[b_nsects + 1]) /
			  (int) bb[b_spt]) /
			 (int) bb[b_nsides]));
	printf(" %d sectors of", st = (int) bb[b_spt]);
	printf(" %d bytes\n", bps =
	       canshort(bb[b_bps], bb[b_bps + 1]));
	if ((bps != 512) || ((st != 10) && (st != 9)) || (tracks != 80)) {
	    printf("\007WARNING -- this is not a normal disk!\n");
	}
	if (sides < 1 || sides > 2 ||
	    bps != 512 ||
	    st > 11 || st < 9 ||
	    tracks < 1 || tracks > TRACK_MAP_SIZE) {
	    printf("***** Strange disk! ... copying normally ");
	    printf("(1 side, 80 tracks of 9 sectors)\n");
	    override = 1;
	    sides = 1;
	    bps = 512;
	    st = 9;
	    tracks = 80;
	}
    }
    if (!use_track_map) {
	for (i = 0; i < tracks; i++)
	    track_map[i] = '\001';
	for (i = tracks; i < TRACK_MAP_SIZE; i++)
	    track_map[i] = '\0';
    }
}

/*
 * format disk using TWISTER
 * returns 0 if OK, aborts and returns 1 on error.
 */

int
format_disk(f_drive, f_double, f_side)
int             f_drive, f_double, f_side;
{
    int             i;
    char 	    *map;

    if(multipass)
        map = full_track_map;
    else
	map = track_map;
    thedisk = f_drive;
    dblsided = (f_double ? -1 : 0);
    flipped = f_side;
redo:
    i = 0;
    while (i < TRACK_MAP_SIZE) {
	if (map[i]) {
	    starttrack = i;
	    while (map[i++]);
	    endtrack = i - 1;
	    keypress = 0;
	    Supexec(twister);
	    if(keypress) {
		longjmp(start, USER_ABORT);
	    }
	    if (badflag){
		printf("\n\007FORMAT Error! CR/SP = retry whole formatting,");
		printf(" other=abort\n");
		printf("(disk might be WRITE_PROTECTED?)\n");
		if (!index("\r\n ", (char) Cnecin()))
		    longjmp(start, USER_ABORT);
		else
		    goto redo;
	    }
	} else {
	    i++;
	}
    }
}

/*
 * copy_disk: where the copy is really done
 */

copy_disk()
{
    if((read_source || verify_source)
        && (drives_content[d1] != SOURCE_DISK))
        prompt_for_disk(SOURCE_DISK, d1, s1);
    if (read_source) {		/* source */
	read_disk(d1, s1);	/* read */
	next_line();
    }
    if (verify_source && (!multipass || first_pass)) {
	verify_disk(d1, s1);
	next_line();
    }

    setjmp(start_dest);		/* destination */
    if(zero_disk) do_zero_disk();			/* blank image */
    if(!override) randomize_boot();			/* change serial */
    if((format || Verify || write_dest || verify))
	prompt_for_disk(DEST_DISK, d2, s2);
    if (format && (!multipass || first_pass)) {		/* format */
	format_disk(d2, sides - 1, s2);
	next_line();
    }
    if (Verify && (!multipass || first_pass)) {		/* Verify */
	verify_disk(d2, s2);
	next_line();
    }
    if (write_dest) {		/* write */
	write_disk(d2, s2);
	next_line();
    }
    if (verify && (!multipass || last_pass)) {		/* verify */
	verify_disk(d2, s2);
	next_line();
    }
}

/*
 * return 1 if skip, 0 if no key, longjmps to start if abort
 */

abort_on_key(track,side)
int             track,side;
{
    if (Cconis()) {
	if ((int) Cnecin() == 0x1b)
	    longjmp(start, USER_ABORT);
	printf("\n\007KEY PRESSED! CR/SP = continue, ");
	printf("i=interactive, %s other abort:\n",
	       (track == -1 ? "" : " S = skip,"));
	switch ((int) Cnecin()) {
	case ' ':
	case '\n':
	case '\r':
	    return 0;
	case 'i':
	case 'I':
	    interactive = 1;
	    return 0;
	case 's':
	case 'S':
	    if (track != -1) {
		printf("Ok, skipping track %d, side %d (sects #%d - #%d)\n",
		       track + 1, side +1,
		       ((track * sides) + side)* st,
		       ((track * sides) + side + 1) * st);
		return 1;
	    }
	}
	longjmp(start, USER_ABORT);
    }
}

int
retry(s, t, side, restart)
char           *s;
int             t, side;
long           *restart;
{
    printf("\n\007** %s ERROR track %d ,side %d (s. #%d - #%d) ",
	   s, t + 1, side + 1,
	   (t * sides + side) * st,
	   (t * sides + side + 1) * st);
    printf("CR/SP retry, S skip, %sother abort",
	   (restart ? "BS=OTHER disk " : ""));
    fflush(stdout);
    switch ((int) Cnecin()) {
    case ' ':
    case '\r':
    case '\n':
	return 1;
    case 's':
    case 'S':
	printf("\n OK, skipping track %d, side %d\n", t + 1, side + 1);
	return 0;
    case '\010':
	if (restart)
	    longjmp(restart, 1);
    default:
	longjmp(start, USER_ABORT);
    }
}

/*
 * sector_read
 * reads one track into ptr, reading sector by sector
 * returns: 0=ok, 1=bad, 2= skip.
 */

int
sector_read(ptr, foo, drive, sect1, track, side, n)
char           *ptr, *foo;
int             drive, sect1, track, side, n;
{
    int             i, result = 0, pass;
    int             pass_ok[4];

    for (pass = 0; pass < 4; pass++) {
	pass_ok[pass] = 1;
	for (i = 0; i < n; i++) {
	    if (abort_on_key(track,i))
		return 2;
	    switch (one_sector_read(
		 (pass ? buffer_data + (pass - 1) * 5120 : ptr) + (i * bps),
				    foo, drive, i + sect1, track, side)) {
	    case 1:
		if (!result)
		    printf("\nTrack %d, side %d: sectors ",
		    track + 1, side + 1);
		result = 1;
		printf("%d (#%d) ", i + 1, (track * sides + side) * st + i);
		fflush(stdout);
		bfill(ptr + i * bps, '\0', (long) bps); /* fills bad sector with */
						 /* 0's */
	    case 2:
		pass_ok[pass] = 0;
	    }
	}
	if (result) {
	    printf("are bad!\n");
	    fflush(stdout);
	    return result;
	}
    }
    if (pass_ok[0])
	return 0;		/* if any pass is good, use it */
    {
	int             i;

	for (i = 1; i < 4; i++) {
	    if (pass_ok[i]) {
		bcopy(buffer_data + 512 * (i - 1), ptr, 512 * n);
		return 0;
	    }
	}
    }
    if (check_random(track, side, n, ptr, buffer_data)) {
	return 1;		/* random read */
    } else {
	printf("\nTrack %d, side %d, (sects #%d - #%d) read sect by sect\n"
	       ,track + 1, side + 1,
	       (track * sides + side) * st,
	       (track * sides + side + 1) * st);
	return 1;		/* no but don't trust! */
    }
}

/*
 * check_random:
 * check tracks buffer to see if equal, return 1 if error
 */

int
check_random(track, side, n, buf0, buf1)
int             track, side, n;
char           *buf0, *buf1;
{
    int             sect, i, bad = 0;
    char           *p0, *p1, *p2, *p3;

    for (sect = 1; sect <= n; sect++) {
	p0 = buf0 + (sect - 1) * 512;
	p1 = buf1 + (sect - 1) * 512;
	p2 = buf1 + (sect - 1) * 512 + 5120;
	p3 = buf1 + (sect - 1) * 512 + 10240;
	for (i = 0; i < 512; i++, p0++, p1++, p2++, p3++) {
	    if ((*p0 != *p1) || (*p0 != *p2) || (*p0 != *p3)) {
		if (!bad) {
		    printf("\n\007DIFFERENT READS ");
		    printf("on track %d, side %d, sects ",
			   track + 1, side + 1);
		    bad = 1;
		}
		printf("%d (#%d) ", sect,
		(track * sides + side) * st + sect - 1);
		break;
	    }
	}
    }
    if(bad) {
        printf("\n");
	fflush(stdout);
    }
    return bad;
}


/*
 * one_sector_read:
 * reads a sector and the 2 outside it
 * return 0 if ok, 1 if bad, 2 if forced to copy sector alone
 */

char           *private_buffer[512 * 3];

int
one_sector_read(buf, foo, drive, sect, track, side)
char           *buf, *foo;
int             drive, sect, track, side;
{
    if (Floprd(private_buffer + (sect == 1 ? 512 : 0), foo, drive,
	       (sect == 1 ? 1 : sect - 1), track, side,
	       ((sect == 1) || (sect == st) ? 2 : 3))) {
	if (Floprd(private_buffer + 512, foo, drive, sect, track, side, 1)){
	    return 1;
	} else {
	    bcopy(private_buffer + 512, buf, 512);
	    return 2;
	}
    }
    bcopy(private_buffer + 512, buf, 512);
    return 0;
}

next_line()
{
    Crawio((int) '\r');
    Crawio((int) '\n');
}

bcopy(from, to, count)
register char  *from, *to;
int             count;
{
    register char  *last = from + count;

    while (from != last)
	*to++ = *from++;
}

bfill(from, octet, count)
register char  *from, octet;
long             count;
{
    register char  *last = from + count;

    while (from != last)
	*from++ = octet;
}

/*
 * is_drive_B
 * return 1 if drive B is there
 */

int 
is_drive_B()
{
    long            usermode = Super(0L);
    int             result = *(int *) 0x4a6;	/* _nflops */

    Super(usermode);
    return (result - 1);
}

/*
 * retry_track
 * retries plain track
 */

int 
retry_track(track, side)
int             track, side;
{
    printf("\n\007** Track-read error track %d ,side %d \n", track + 1, side + 1);
    printf("CR/SP retry, ESC aborts, other go to sector_read: ");
    fflush(stdout);
    switch ((char) Cnecin()) {
    case ' ':
    case '\r':
	return 1;
    case 0x1b:
	longjmp(start, USER_ABORT);
    default:
	return 0;
    }
}

verify_disk(drive, side)
int             drive, side;
{
    char           *ptr, *map;
    int             t, n;

    if(multipass)
        map = full_track_map;
    else
	map = track_map;
    ptr = buffer_data;
    for (t = 0; t < TRACK_MAP_SIZE; t++) {
	if (map[t]) {
	    for (n = side; n < (side + sides); n++) {
		if (Floprd(ptr, 0L, drive, 1, t, n, st))
		    while (retry("Verify", t, n, start_dest) &&
			   Floprd(ptr, 0L, drive, 1, t, n, st));
		abort_on_key(t,n);
	    }
	    Crawio((int) 'v');
	}
    }
}

write_disk(drive, side)
int             drive, side;
{
    char           *ptr;
    int             t, n, last_track;

    ptr = buf;	
    if(zero_disk){			/* formatting is a special case */
	last_track = 2;
    }else{
	last_track = TRACK_MAP_SIZE;
    }
    for (t = 0; t < last_track; t++) {
	if (track_map[t]) {
	    for (n = side; n < (side + sides); n++) {
		if (Flopwr(ptr, 0L, drive, 1, t, n, st))
		    while (retry("Write", t, n, start_dest) &&
			   Flopwr(ptr, 0L, drive, 1, t, n, st));
		ptr += (long) bps *st;

		abort_on_key(-1,n);
	    }
	    Crawio((int) '.');
	}
    }
}

read_disk(drive, side)
int             drive, side;
{
    char           *ptr = buf, c;
    int             t, n;
    int             full_track_retry;

    /* we need at least room for 1 track! */
    if(buffer_size < (sides * bps * st * 1L)) longjmp(start, NO_MEMORY);
    for (t = 0; t < TRACK_MAP_SIZE; t++) {
	if (track_map[t]) {
	    c = ',';
	    for (n = side; n < (side + sides); n++) {
		if (Floprd(ptr, 0L, drive, 1, t, n, st)) {
		    c = ';';
		    full_track_retry = 1;
		    while(1) {
			abort_on_key(-1,n);
			if (!Floprd(ptr, 0L, drive, 1, t, n, st))
			    goto good_retry;
			full_track_retry++;
			if (full_track_retry >= TRACK_RETRY) {
			    if (interactive && retry_track(t, n)) {
			        full_track_retry = 1;
			    }else{
			        break;
			    }
			}
		    }
		    /* 4 retries done */
		    if (1 == sector_read(ptr, 0L, drive, 1, t, n, st)) {
			if (interactive) {
			    while (retry("Read", t, n, 0L) &&
			    (1 == sector_read(ptr, 0L, drive, 1, t, n, st)));
			}
		    }
		}
	good_retry:
		ptr += (long) (bps * st);
		abort_on_key(-1,n);
	    }
	    Crawio((int) c);
	}
    }
}

input_track_map()
{
    char            text[10];
    int             i, strack, etrack;

    if(play_it_again_sam) {
	bcopy(full_track_map, track_map, TRACK_MAP_SIZE);
	return;
    }
    for (i = 0; i < TRACK_MAP_SIZE; i++)
	track_map[i] = '\0';
    while ((printf("Enter start track (CR = done): "),
	    gets(text), (int) text[0])) {
	strack = atoi(text) - 1;
	printf("Enter end track (CR = %d): ", strack + 1);
	gets(text);
	if (!text[0])
	    etrack = strack;
	else
	    etrack = atoi(text) - 1;
	if ((etrack > TRACK_MAP_SIZE) ||
	    (strack > etrack) ||
	    (strack < 0)) {
	    printf("Sorry, not a valid entry: %d...%d\n",
	        strack + 1, etrack + 1);
	} else {
	    for (i = strack; i <= etrack; i++)
		track_map[i] = '\001';
	    printf("Ok, range %d...%d will be done\n",
	        strack + 1, etrack + 1);
	}
    }
}

/*
 * prompt_for_disk:
 * ask user to insert disk if we think it is not in drive
 */

prompt_for_disk(disk, drive, side)
int disk, drive,side;
{
    if(drives_content[drive] != disk){
	printf("\nInsert %s disk in drive %c (side %d),",
	    (disk == SOURCE_DISK ? "SOURCE" : "DESTINATION"),
	    (char)(drive + 'A'), side + 1);
	printf("CR/SP = ok, other = abort\n");
	if (!index("\r\n ", (char) Cnecin())){
	    if(disk == SOURCE_DISK)
		one_valid_copy_done = 0;
	    longjmp(start, USER_ABORT);
	}else{
	    drives_content[drive] = disk;
	}
    }
}

/*
 * update_checksum:
 * compute checksum of boot buffer and set it (last int of 256 ints)
 */

update_checksum(block, is_boot_non_executable)
unsigned block[];
unsigned is_boot_non_executable;
{
    int i; unsigned sum = 0;
    for(i=0; i<255; i++)
    	sum += block[i];
    block[255] = (unsigned) 0x1234 - sum + is_boot_non_executable;
}

unsigned
is_non_executable(block)
unsigned block[];
{
    int i; unsigned sum = 0;
    for(i=0; i<=255; i++)
    	sum += block[i];
    return (sum == (unsigned) 0x1234 ? (unsigned) 0 : (unsigned) 1);
}

