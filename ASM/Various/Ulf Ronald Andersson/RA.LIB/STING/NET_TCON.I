;----------------------------------------------------------------------------
;File name:	NET_TCON.I			Revision date:	1998.09.09
;Creator:	Ulf Ronald Andersson		Creation date:	1997.07.31
;(c)1997 by:	Ulf Ronald Andersson		All rights reserved
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	IFND	STinG_NET_TCON_defined
STinG_NET_TCON_defined	set	1
;----------------------------------------------------------------------------
	include	RA_TOS.I
	include	sting\TRANSPRT.I
	include	sting\DOMAIN.I
;----------------------------------------------------------------------------
;Purpose:
;
;The macros declared here will handle the translation of time and date values
;between three formats:  The internal 2*16 bit code of TOS, the normal 32 bit
;network time format of internet, and the normal human format where each time
;unit is separate from the others.  The conversions to/from network time also
;compensate for daylight savings offsets of the local time.
;
;The realtime clock of the system (whether hardware or software) is always
;assumed to use local time, including adjustment for daylight savings period
;as defined for the local area. Daylight savings intervals are assumed to be
;specified relative to the units valid before an impending change.  Thus the
;tests for daylight savings can always compare the specified values directly
;with time values derived from the realtime clock.
;----------------------------------------------------------------------------
;NB: Having used any of these macros, you have to include a call like this:
;
;		make	TCON_links
;
;    This must be somewhere in the executable code, after all 'tcon_' macros
;    that are to be used in the program have been called at least once.
;    Thus the end of the program segment is usually the best place for it.
;----------------------------------------------------------------------------
;Available macros and their usage:
;
;tcon_real2tos	The TOS time of a tcon struct is loaded from TOS realtime
;tcon_tos2real	TOS realtime is loaded from the TOS time of a tcon struct
;
;NB: Both of the above access the realtime clock, if available in your system
;
;tcon_man2tos	Human time of a tcon struct is converted into its TOS time
;tcon_tos2man	TOS time of a tcon struct is converted into its human time
;tcon_man2net	Human time of a tcon struct is converted into network time
;tcon_net2man	Network time of a tcon struct is converted into human time
;tcon_is_summer	Flags summer with -1 and non-summer with 0
;tcon_rd_tz	Converts data from sting variables to init all zone info
;
;The two macros below are replaced by tcon_rd_tz, which also adds improved
;capabilities.  They can still be used, for compatibility, but new programs
;should not use them, since they lack some of the improvements (TZ etc).
;
;tcon_rd_zone	Converts data from sting variable TIME_ZONE to zoneseconds
;tcon_rd_summer	Converts data from sting variable TIME_SUMMER to tcon_summer
;
;All of these macros expect a pointer to a 'tcon' structure in a0 and they
;restore all CPU address and data registers to original values on exit,
;except for tcon_is_summer, which uses d0 to return the flag.
;
; NB:	use "ds.b    sizeof_tcon" to reserve storage for a tcon structure.
;
;+NB:	TIME_ZONE has a range of "-1440" to "+1440" in minutes ahead of GMT
;		  so for Germany or Sweden (for example) "+60" is correct.
;	tcon_zoneseconds has a range of -86400 to +86400 in seconds, which
;		  corresponds to TIME_ZONE multiplied by 60
;----------------------------------------------------------------------------
;The tm structure:
;
	struct	tm
	uint16	tm_sec		;second of minute [0..59]
	uint16	tm_min		;minute of hour   [0..59]
	uint16	tm_hour		;hour of day      [0..23]
	uint16	tm_mday		;day of month     [1..31]
	uint16	tm_mon		;month of year    [1..12]  (  Jan == 1)
	int16	tm_year		;year relative to year 0 AD
	uint16	tm_wday		;day of week      [0..6]   (  Sun == 0)
	uint16	tm_yday		;day of year      [0..365] (Jan 1 == 0)
	int16	tm_isdst	;Daylight saving, pos=on, 0=off, neg=NA
	int32	tm_gmtoff	;(localtime-GMT)  [-43200..+43200] seconds
	char_p	tm_zone		;->string name for time zone (or NULL)
	d_end	tm
;
;Note that some of these elements differ slightly from those implemented in
;similar structures of various C compilers.  The main differences from some
;implementations are that they often use the opposite sign for tm_gmtoff, and
;months numbered 0-11, and a year relative to 1900 AD or other late year.
;C programmers using this lib may need to adjust parameters and results that
;are passed between it and various functions and structures used in C code.
;Note that only simple addition/subtraction is needed for such adjustments.
;----------------------------------------------------------------------------
;The tcon structure:
;
	struct	tcon
	uint32	tcon_net_time		;network time from 00:00 Jan 1 1900 GMT
	uint16	tcon_tos_date		;bitpacked date of Atari TOS
	uint16	tcon_tos_time		;bitpacked time of Atari TOS
	d_alias	tcon_tm			;start of 'tm' substructure
	d_alias	tcon_tm_sec
	uint16	tcon_man_second		;human second
	d_alias	tcon_tm_min
	uint16	tcon_man_minute		;human minute
	d_alias	tcon_tm_hour
	uint16	tcon_man_hour		;human hour
	d_alias	tcon_tm_mday
	uint16	tcon_man_date		;human date in month
	d_alias	tcon_tm_mon
	uint16	tcon_man_month		;human month
	d_alias	tcon_tm_year
	uint16	tcon_man_year		;human year
	d_alias	tcon_tm_wday
	uint16	tcon_man_weekday	;human weekday
	uint16	tcon_tm_yday		;day of year      [0..365] (Jan 1 == 0)
	int16	tcon_tm_isdst		;Daylight saving, pos=on, 0=off, neg=NA
	d_alias	tcon_tm_gmtoff		;(localtime-GMT)  [-43200..+43200] seconds
	int32	tcon_zoneseconds	;max +/- 45000  (== 12.5 hours)
	char_p	tcon_tm_zone		;->string name for time zone (or NULL)
	d_alias	tcon_dst		;sub_struct for all DST stuff
	d_alias	tcon_dst_modes		;mode word for DST, 0 = TIME_SUMMER
	uint8	tcon_dst_smode		;mode byte for DST start
	uint8	tcon_dst_emode		;mode byte for DST end
	d_alias	tcon_summer		;sub_struct for TIME_SUMMER data
	d_alias	tcon_dst_sdate		;to use dst_smon & dst_sday as a word
	d_alias	tcon_dst_smon
	uint8	tcon_summer_start_month
	d_alias	tcon_dst_sday
	uint8	tcon_summer_start_date
	d_alias	tcon_dst_edate		;to use dst_emon & dst_eday as a word
	d_alias	tcon_dst_emon
	uint8	tcon_summer_end_month
	d_alias	tcon_dst_eday
	uint8	tcon_summer_end_date
;NB: the four bytes above must remain consecutive, for TIME_SUMMER compatibility
	uint32	tcon_dst_ssec		;start second_in_day of DST
	uint32	tcon_dst_esec		;start second_in_day of DST
	int32	tcon_dst_offs		;offset in seconds for DST (norm: 3600)
	char_p	tcon_dst_name		;->string name for DST zone (or NULL)
	d_end	tcon
;
;NB:	Weekday support is limited to the conversion tcon_net2man.
;	For tos and human formats that need weekday updated, you must
;	first convert to network format, and then to the wanted format.
;	This is not needed unless weekday is necessary.
;
;	examples of conversions making tcon_man_weekday valid:
;
;	network	format	=> tcon_net2man
;	human format	=> tcon_man2net + tcon_net2man
;	tos format	=> tcon_tos2man + tcon_man2net + tcon_net2man
;
;
;NB:	DST calculations are made differently depending on the values of
;	tcon_dst_smode/tcon_dst_emode, which have the following meaning:
;
;  0 =	TZ not valid, xday = day in month xmon  (from TIME_SUMMER)
;  1 =	TZ valid, xday = weekday of 1st week in month xmon containing it
;  2 =	TZ valid, xday = weekday of 2nd week in month xmon containing it
;  3 =	TZ valid, xday = weekday of 3rd week in month xmon containing it
;  4 =	TZ valid, xday = weekday of 4th week in month xmon containing it
;  5 =	TZ valid, xday = weekday of last week in month xmon containing it
;  6 =	TZ valid, (xmon * 256 + xday) = Julian day [1..365] excluding leap day
;  7 =	TZ valid, (xmon * 256 + xday) = Julian day [0..365] including leap day
;  All other values are undefined, and will be treated as the value 0.
;
;	The symbols 'xday' and 'xmon' above are used as abbreviations for
;	tcon_dst_sday/tcon_dst_eday and tcon_dst_smon/tcon_dst_emon, so as
;	to keep the description more concise.
;
;	If the element tcon_tm_isdst is negative, then none of the methods
;	above apply, since that means that no valid DST information has been
;	loaded (tcon_rd_tz/tcon_rd_summer forgotten or variables invalid).
;	That implies that *all* DST related info is then invalid.
;----------------------------------------------------------------------------
NET_JAN_1980	equ	2524521600	;1980.01.01 was a tuesday :-)
NET_MINUTE	equ	60
NET_HOUR	equ	60*NET_MINUTE
NET_DAY		equ	24*NET_HOUR
NET_WEEK	equ	7*NET_DAY
NET_NORMYEAR	equ	365*NET_DAY
NET_LEAPYEAR	equ	NET_NORMYEAR+NET_DAY
NET_OLYMPIC	equ	3*NET_NORMYEAR+NET_LEAPYEAR
;----------------------------------------------------------------------------
TCON_links	MACRO
	_unidef	tcon_real2tos
	_unidef	tcon_tos2real
	_unidef	tcon_man2tos
	_unidef	tcon_tos2man
	_unidef	tcon_man2net
	_unidef	tcon_net2man
	_unidef	tcon_rd_tz
	_unidef	tcon_rd_zone
	_unidef	tcon_rd_summer
	_unidef	tcon_is_summer
	ENDM	;TCON_links
;----------------------------------------------------------------------------
tcon_real2tos	MACRO
	_uniref	tcon_real2tos
	jsr	tcon_real2tos_code
	ENDM	;tcon_real2tos
;------------------------------------
tcon_real2tos_code	MACRO
	movem.l	d0-d4/a0-a3,-(sp)
	move.l	a0,a3		;a3 -> tcon structure
	gemdos	Tgetdate
	move	d0,d3
	gemdos	Tgettime
	move	d0,d4
	gemdos	Tgetdate
	cmp	d0,d3
	beq.s	.have_time
	move	d0,d3
	gemdos	Tgettime
	move	d0,d4
.have_time:
	move	d3,tcon_tos_date(a3)
	move	d4,tcon_tos_time(a3)
	movem.l	(sp)+,d0-d4/a0-a3
	rts
	ENDM	;tcon_real2tos_code
;----------------------------------------------------------------------------
tcon_tos2real	MACRO
	_uniref	tcon_tos2real
	jsr	tcon_tos2real_code
	ENDM	;tcon_tos2real
;------------------------------------
tcon_tos2real_code	MACRO
	movem.l	d0-d2/a0-a3,-(sp)
	move.l	a0,a3		;a3 -> tcon structure
	gemdos	Tsettime,tcon_tos_time(a3)
	gemdos	Tsetdate,tcon_tos_date(a3)
	movem.l	(sp)+,d0-d2/a0-a3
	rts
	ENDM	;tcon_tos2real_code
;----------------------------------------------------------------------------
tcon_tos2man	MACRO
	_uniref	tcon_tos2man
	jsr	tcon_tos2man_code
	ENDM	tcon_tos2man
;------------------------------------
tcon_tos2man_code	MACRO
;Sub converts TOS time to human time
	movem.l	d0/d1,-(sp)
	move	tcon_tos_date(a0),d0
	move	d0,d1
	and	#1<<5-1,d1
	move	d1,tcon_man_date(a0)
	lsr	#5,d0
	move	d0,d1
	and	#1<<4-1,d1
	move	d1,tcon_man_month(a0)
	lsr	#4,d0
	add	#1980,d0
	move	d0,tcon_man_year(a0)
;
	move	tcon_tos_time(a0),d0
	move	d0,d1
	and	#1<<5-1,d1
	add	d1,d1
	move	d1,tcon_man_second(a0)
	lsr	#5,d0
	move	d0,d1
	and	#1<<6-1,d1
	move	d1,tcon_man_minute(a0)
	lsr	#6,d0
	move	d0,tcon_man_hour(a0)
	movem.l	(sp)+,d0/d1
	rts
	ENDM	;tcon_tos2man_code
;----------------------------------------------------------------------------
tcon_man2tos	MACRO
	_uniref	tcon_man2tos
	jsr	tcon_man2tos_code
	ENDM	;tcon_man2tos
;------------------------------------
tcon_man2tos_code	MACRO
;Sub converts human time to TOS time
	movem.l	d0/d1,-(sp)
	move	tcon_man_year(a0),d1
	sub	#1980,d1
	asl	#4,d1
	move	tcon_man_month(a0),d0
	and	#1<<4-1,d0
	or	d0,d1
	asl	#5,d1
	move	tcon_man_date(a0),d0
	and	#1<<5-1,d0
	or	d0,d1
	move	d1,tcon_tos_date(a0)
;
	move	tcon_man_hour(a0),d1
	asl	#6,d1
	move	tcon_man_minute(a0),d0
	and	#1<<6-1,d0
	or	d0,d1
	asl	#5,d1
	move	tcon_man_second(a0),d0
	lsr	#1,d0
	and	#1<<5-1,d0
	or	d0,d1
	move	d1,tcon_tos_time(a0)
	movem.l	(sp)+,d0/d1
	rts
	ENDM	;tcon_man2tos_code
;----------------------------------------------------------------------------
tcon_net2man	MACRO
	_uniref		tcon_rd_tz
	_uniref		tcon_net2man
	jsr		tcon_net2man_code
	ENDM	;tcon_net2man
;------------------------------------
tcon_net2man_code	MACRO
;Sub converts network time to local human time
	movem.l		d0-d3/a1,-(sp)
	clr.l		d3		;zero summer adjustment for first lap
.adjust_loop:
	move.l		tcon_net_time(a0),d0
	add.l		tcon_zoneseconds(a0),d0
	add.l		d3,d0		;add summer adjustment (on second lap when used)
	sub.l		#NET_JAN_1980,d0
	clr		d1		;prep for seconds mixing
	lsr.l		#1,d0		;prescale to avoid overflow in remainder
	roxr		d1		;d1 bit 15 = odd seconds bit
	divu		#NET_DAY/2,d0
	clr.l		d2		;preclear high word of d2 (for later divu)
	move		d0,d2		;d2 = whole days from 00:00 tuesday Jan 1st 1980
	clr		d0		;prep to separate remainder
	swap		d0
	divu		#60/2,d0	;d0.lo = minutes from midnight
	swap		d0
	move.b		d0,d1		;d1 = all seconds bits rotated 1 step right
	clr		d0		;prep to separate hours & minutes
	swap		d0
	divu		#60,d0
	move		d0,tcon_man_hour(a0)
	swap		d0
	move		d0,tcon_man_minute(a0)
	rol		#1,d1
	move		d1,tcon_man_second(a0)	;this completes time_of_day conversion
;
	clr.l		d0
	move		d2,d0		;d0 = d2 = days from Jan 1st 1980
	divu		#4*365+1,d0	;olympic periods since 1980
	asl		#2,d0		;are precisely 4 years each (until 2100)
	move		d0,d1		;d1 = years that formed olympics
	clr		d0		;prep to separate leap year
	swap		d0		;d0 = remaining days in last olympic
	cmp		#366,d0		;first year in olympic is leap year
	bhs.s		.more_years
	subq		#1,d0		;adjust index for post-leap_day (most common)
	cmp		#58,d0		;beyond February ?
	bgt.s		.done_years	;then it is now normalized
	beq.s		.leap_day	;leap day is treated separately
	addq		#1,d0		;restore original index for Jan 1..Feb 28
	bra.s		.done_years	;then treat it as any other year
;
.leap_day:
	move		#365,d0		;beyond the table for days in normal years
	bra.s		.done_years
	
;
.more_years:
	subq		#1,d0		;remove leap day from days in d0
	divu		#365,d0		;d0.lo = full years in last olympic
	add		d0,d1		;d1 = total years since 1980
	swap		d0		;d0 = day_in_year (Julian Day)
.done_years:
	add		#1980,d1	;d1 = real year
	move		d1,tcon_man_year(a0)
	add		d0,d0			;prep to index 16 bit words
	lea		tcon_JD2MD_t(pc),a1
	move		(a1,d0.w),d0		;d0 = month<<8 + date
	clr		d1
	move.b		d0,d1
	lsr		#8,d0
	move		d0,tcon_man_month(a0)
	move		d1,tcon_man_date(a0)
	tst		d3			;summer adjustment already done ?
	bne.s		.finish_net2man
	move.l		#3600,d3		;prep to adjust by adding one hour
	tcon_is_summer
	bne		.adjust_loop
.finish_net2man:
	addq		#2,d2		;adjust weekday offset, so we get sunday=0
	divu		#7,d2
	swap		d2		;d2 = weekday offset 0=sunday .. 6= saturday
	move		d2,tcon_man_weekday(a0)
	movem.l		(sp)+,d0-d3/a1
	rts
	ENDM	;tcon_net2man_code
;----------------------------------------------------------------------------
tcon_man2net	MACRO
	_uniref	tcon_man2net
	jsr	tcon_man2net_code
	ENDM	;tcon_man2net
;------------------------------------
tcon_man2net_code	MACRO
;Sub converts local human time to network time
	movem.l	d0-d3,-(sp)
	tcon_is_summer
	move.l	#3600,d3
	and	d0,d3
	move	tcon_man_year(a0),d0
	sub	#1980,d0	;make year relative to 1980
	move	d0,d1
	lsr	#2,d0		;d0 = olympics
	mulu	#365*4+1,d0	;d0 = days of full olympics
	and	#1<<2-1,d1	;d1 = years of current olympic
	seq	d2		;d2.b=$FF if current year is leaping, else $00
	beq.s	.done_years
	mulu	#365,d1		;d1 = normal days of full years of current olympic
	addq	#1,d1		;add a leap day for the first of them
	add	d1,d0		;d0 = days of all full years  (NB: <65536 !!!)
;	
.done_years:
	and	#12,d2		;d2 = table offset for leap year, or zero
	add	tcon_man_month(a0),d2	;d2 = month index (1-24, with 13-24 for leap years)
	subq	#1,d2		;adjust index for 0-23, with 12-23 for leap years
	add	d2,d2				;prep to index 16 bit words
	add	.month_table(pc,d2.w),d0	;add days before current month to d0
	add	tcon_man_date(a0),d0			;add date in current month to d0
	subq	#1,d0		;subtract one, since dates don't use zero
	mulu	#NET_DAY/2,d0
	add.l	d0,d0		;d0 = date in seconds relative to Jan 1 1980
	add.l	#NET_JAN_1980,d0	;d0.l = local date (but not yet time) in seconds
	move	tcon_man_hour(a0),d1
	mulu	#60,d1
	add	tcon_man_minute(a0),d1
	mulu	#60/2,d1	;NB: the "/2" is needed to avoid overflow
	add.l	d1,d1		;This doubling compensates for the above "/2"
	clr.l	d2
	move	tcon_man_second(a0),d2
	add.l	d2,d1		;d1.l = local time_of_day in seconds
	add.l	d1,d0		;d0.l = local time in network format
	sub.l	d3,d0		;adjust for daylight savings
	sub.l	tcon_zoneseconds(a0),d0	;d0.l = true network time
	move.l	d0,tcon_net_time(a0)
	movem.l	(sp)+,d0-d3
	rts
;
.month_table:
	dc.w	0,31,59,90,120,151,181,212,243,273,304,334
	dc.w	0,31,60,91,121,152,182,213,244,274,305,335
	ENDM	tcon_man2net_code
;----------------------------------------------------------------------------
;
tcon_is_summer	MACRO
	_uniref	tcon_is_summer
	jsr	tcon_is_summer_code
	ENDM	;tcon_is_summer
;------------------------------------
tcon_is_summer_code	MACRO
	move.l	d1,-(sp)
	tst.l	tcon_summer(a0)
	beq.s	.exit_false
	clr.l	d0
	move	tcon_man_month(a0),d0
	add	#12,d0
	sub.b	tcon_summer_start_month(a0),d0
	divu	#12,d0
	swap	d0
	tst	d0	;start month now ?
	bne.s	.not_start_month
;start month is now
	move	tcon_man_date(a0),d0
	cmp.b	tcon_summer_start_date(a0),d0
	blo.s	.exit_false
.exit_true:
	move.l	(sp)+,d1
	moveq	#-1,d0
	rts
;
.not_start_month:
	clr.l	d1
	move.b	tcon_summer_end_month(a0),d1
	add	#12,d1
	sub.b	tcon_summer_start_month(a0),d1
	divu	#12,d1
	swap	d1
	cmp	d1,d0
	bhi.s	.exit_false
	blo.s	.exit_true
;end month is now
	move	tcon_man_date(a0),d0
	cmp.b	tcon_summer_end_date(a0),d0
	blo.s	.exit_true
.exit_false:
	move.l	(sp)+,d1
	clr.l	d0
	rts
	ENDM	;tcon_is_summer_code
;----------------------------------------------------------------------------
tcon_rd_tz	MACRO
	_uniref	tcon_rd_tz
	jsr	tcon_rd_tz_code
	ENDM	;tcon_rd_tz
;------------------------------------
tcon_rd_tz_code	MACRO
;Sub converts config variable TIME_ZONE to tcon_zoneseconds
	movem.l		d0-d5/a0-a5,-(sp)
	move.l		a0,a5
	moveq		#sizeof_tcon-1,d0
.clear_loop:
	clr.b		(a0)+
	dbra		d0,.clear_loop
;
	lea		zone_name_s(pc),a1
	clr.b		(a1)
	move.l		a1,tcon_tm_zone(a5)
	lea		dst_name_s(pc),a1
	clr.b		(a1)
	move.l		a1,tcon_dst_name(a5)
	move		#-1,tcon_tm_isdst(a5)
;
	getvstr		TZ_vn_s(pc)
	is_unblank.i	d0
	move.l		a0,d0
	beq		.bad_tz
;
	lea		zone_name_s(pc),a1
	bsr		get_tcon_zone_id
	lea		tcon_tm_gmtoff(a5),a1
	bsr		get_tcon_offset
	lea		dst_name_s(pc),a1
	bsr		get_tcon_zone_id
	lea		tcon_dst_offs(a5),a1
	bsr		get_tcon_offset
	bpl.s		.dst_offs_ok
	move.l		#NET_HOUR,(a1)
.dst_offs_ok:
	cmp.b		#',',(a0)+
	bne.s		.done_tz
	lea		tcon_dst_sdate(a5),a1
	lea		tcon_dst_smode(a5),a2
	bsr		get_tcon_date
	move.l		#2*NET_HOUR,tcon_dst_ssec(a5)
	cmp.b		#'/',(a0)
	bne.s		.done_dst_start
	addq		#1,a0
	lea		tcon_dst_ssec(a5),a1
	bsr		get_tcon_offset
	bpl.s		.done_dst_start
	move.l		#2*NET_HOUR,(a1)
.done_dst_start:
	cmp.b		#',',(a0)+
	bne.s		.done_tz
	lea		tcon_dst_edate(a5),a1
	lea		tcon_dst_emode(a5),a2
	bsr		get_tcon_date
	move.l		#2*NET_HOUR,tcon_dst_esec(a5)
	cmp.b		#'/',(a0)
	bne.s		.done_dst_end
	addq		#1,a0
	bmi.s		.done_dst_end
	lea		tcon_dst_esec(a5),a1
	bsr		get_tcon_offset
	bpl.s		.done_dst_end
	move.l		#2*NET_HOUR,(a1)
.done_dst_end:
	clr		tcon_tm_isdst(a5)	;flag DST info valid
.done_tz:
	movem.l		(sp)+,d0-d5/a0-a5
	rts
;
.bad_tz:
	tcon_rd_zone
	tcon_rd_summer
	bra		.done_tz
;
;-----
;
get_tcon_zone_id:
	clr		d1
.loop:
	clr.b		(a1)
	move.b		(a0)+,d0
	beq.s		.exit
	cmp.b		#'z',d0
	bhi.s		.exit
	cmp.b		#'a',d0
	bhs.s		.alpha
	cmp.b		#'Z',d0
	bhi.s		.exit
	cmp.b		#'A',d0
	blo.s		.exit
.alpha:
	addq		#1,d1
	cmp		#4,d1
	bhi.s		.loop
	move.b		d0,(a1)+
	bra.s		.loop
;
.exit:
	subq		#1,a0
	rts
;
;-----
;
get_tcon_offset:
	moveq		#-1,d3
	clr.l		d1
	move.b		(a0)+,d3
	beq.s		.exit
	cmp.b		#'+',d3
	beq.s		.have_sign
	cmp.b		#'-',d3
	beq.s		.have_sign
	subq		#1,a0
.have_sign:
	moveq		#3-1,d2
	bra.s		.loop_start
;
.loop_1:
	move.b		(a0)+,d0
	cmp.b		#':',d0
	bne.s		.loop_2
	mulu		#60,d1
.loop_start:
	clr		d0
	move.b		(a0)+,d0
	sub.b		#'0',d0
	blo.s		.loop_2_start
	cmp.b		#9,d0
	bhi.s		.loop_2_start
	mulu		#10,d0
	add		d0,d1
	clr.l		d0
	move.b		(a0)+,d0
	sub.b		#'0',d0
	blo.s		.loop_2_start
	cmp.b		#9,d0
	bhi.s		.loop_2_start
	add		d0,d1
	dbra		d2,.loop_1
	bra.s		.exit
;
.loop_2:
	mulu		#60,d1
.loop_2_start:
	dbra		d2,.loop_2	
.exit:
	subq		#1,a0
	cmp.b		#'-',d3
	bne.s		.sign_fixed
	neg.l		d1
.sign_fixed:
	move.l		d1,(a1)
	move.l		d3,d0
	rts
;
;-----
;
get_tcon_date:
;;;patch
	rts
;
;-----
;
TZ_vn_s:
	dc.b	'TZ',NUL
	even
zone_name_s:
	dcb.b	8,0
dst_name_s:
	dcb.b	8,0
;
tcon_JD2MD_t:
	dc.w	$101,$102,$103,$104,$105,$106,$107,$108,$109,$10A	;January
	dc.w	$10B,$10C,$10D,$10E,$10F,$110,$111,$112,$113,$114
	dc.w	$115,$116,$117,$118,$119,$11A,$11B,$11C,$11D,$11E,$11F
;
	dc.w	$201,$202,$203,$204,$205,$206,$207,$208,$209,$20A	;February
	dc.w	$20B,$20C,$20D,$20E,$20F,$210,$211,$212,$213,$214
	dc.w	$215,$216,$217,$218,$219,$21A,$21B,$21C
;
	dc.w	$301,$302,$303,$304,$305,$306,$307,$308,$309,$30A	;March
	dc.w	$30B,$30C,$30D,$30E,$30F,$310,$311,$312,$313,$314
	dc.w	$315,$316,$317,$318,$319,$31A,$31B,$31C,$31D,$31E,$31F
;
	dc.w	$401,$402,$403,$404,$405,$406,$407,$408,$409,$40A	;April
	dc.w	$40B,$40C,$40D,$40E,$40F,$410,$411,$412,$413,$414
	dc.w	$415,$416,$417,$418,$419,$41A,$41B,$41C,$41D,$41E
;
	dc.w	$501,$502,$503,$504,$505,$506,$507,$508,$509,$50A	;May
	dc.w	$50B,$50C,$50D,$50E,$50F,$510,$511,$512,$513,$514
	dc.w	$515,$516,$517,$518,$519,$51A,$51B,$51C,$51D,$51E,$51F
;
	dc.w	$601,$602,$603,$604,$605,$606,$607,$608,$609,$60A	;June
	dc.w	$60B,$60C,$60D,$60E,$60F,$610,$611,$612,$613,$614
	dc.w	$615,$616,$617,$618,$619,$61A,$61B,$61C,$61D,$61E
;
	dc.w	$701,$702,$703,$704,$705,$706,$707,$708,$709,$70A	;July
	dc.w	$70B,$70C,$70D,$70E,$70F,$710,$711,$712,$713,$714
	dc.w	$715,$716,$717,$718,$719,$71A,$71B,$71C,$71D,$71E,$71F
;
	dc.w	$801,$802,$803,$804,$805,$806,$807,$808,$809,$80A	;August
	dc.w	$80B,$80C,$80D,$80E,$80F,$810,$811,$812,$813,$814
	dc.w	$815,$816,$817,$818,$819,$81A,$81B,$81C,$81D,$81E,$81F
;
	dc.w	$901,$902,$903,$904,$905,$906,$907,$908,$909,$90A	;September
	dc.w	$90B,$90C,$90D,$90E,$90F,$910,$911,$912,$913,$914
	dc.w	$915,$916,$917,$918,$919,$91A,$91B,$91C,$91D,$91E
;
	dc.w	$A01,$A02,$A03,$A04,$A05,$A06,$A07,$A08,$A09,$A0A	;October
	dc.w	$A0B,$A0C,$A0D,$A0E,$A0F,$A10,$A11,$A12,$A13,$A14
	dc.w	$A15,$A16,$A17,$A18,$A19,$A1A,$A1B,$A1C,$A1D,$A1E,$A1F
;
	dc.w	$B01,$B02,$B03,$B04,$B05,$B06,$B07,$B08,$B09,$B0A	;November
	dc.w	$B0B,$B0C,$B0D,$B0E,$B0F,$B10,$B11,$B12,$B13,$B14
	dc.w	$B15,$B16,$B17,$B18,$B19,$B1A,$B1B,$B1C,$B1D,$B1E
;
	dc.w	$C01,$C02,$C03,$C04,$C05,$C06,$C07,$C08,$C09,$C0A	;December
	dc.w	$C0B,$C0C,$C0D,$C0E,$C0F,$C10,$C11,$C12,$C13,$C14
	dc.w	$C15,$C16,$C17,$C18,$C19,$C1A,$C1B,$C1C,$C1D,$C1E,$C1F
;
	dc.w	$21D	;special entry for leap day
	ENDM	;tcon_rd_tz_code
;----------------------------------------------------------------------------
tcon_rd_zone	MACRO
	_uniref	tcon_rd_zone
	jsr	tcon_rd_zone_code
	ENDM	;tcon_rd_zone
;------------------------------------
tcon_rd_zone_code	MACRO
;Sub converts config variable TIME_ZONE to tcon_zoneseconds
	movem.l		d0-d2/a0-a2,-(sp)
	move.l		a0,-(sp)
	lea		zone_nul_s(pc),a1
	move.l		a1,tcon_tm_zone(a0)
	getvstr		TIME_ZONE_vn_s(pc)
	is_unblank.i	d0
	clr		d1
	clr.l		d2
	move.l		a0,d0
	beq.s		.have_zone
	move.b		(a0)+,d1
	cmp.b		#'+',d1
	beq.s		.use_sign
	cmp.b		#'-',d1
	beq.s		.use_sign
	subq		#1,a0
.use_sign:
	clr		d0
.loop:
	move.b		(a0)+,d0
	sub.b		#'0',d0
	blt.s		.have_zone
	cmp.b		#9,d0
	bhi.s		.have_zone
	mulu		#10,d2
	add		d0,d2
	cmp		#1440,d2	;too high ?
	bls.s		.loop		;loop for legal values
	clr.l		d2		;force illegal value to zero
.have_zone:
	mulu		#60,d2		;convert to seconds
	cmp.b		#'-',d1
	bne.s		.keep_sign
	neg.l		d2		;adjust to negative sign
.keep_sign:
	move.l		(sp)+,a0
	move.l		d2,tcon_zoneseconds(a0)
	movem.l		(sp)+,d0-d2/a0-a2
	rts
;
TIME_ZONE_vn_s:
	dc.b	'TIME_ZONE'
zone_nul_s:
	dc.b	NUL
	even
	ENDM	;tcon_rd_zone_code
;----------------------------------------------------------------------------
tcon_rd_summer	MACRO
	_uniref	tcon_rd_summer
	jsr	tcon_rd_summer_code
	ENDM	;tcon_rd_summer
;------------------------------------
tcon_rd_summer_code	MACRO
;Sub converts config variable TIME_ZONE to tcon_zoneseconds
	movem.l		d0-d2/a0-a2,-(sp)
	move.l		a0,-(sp)
	lea		summer_nul_s(pc),a1
	move.l		a1,tcon_dst_name(a0)
	move		#-1,tcon_tm_isdst(a0)
	clr.l		tcon_summer(a0)
	getvstr		TIME_SUMMER_vn_s(pc)
	is_unblank.i	d0
	move.l		a0,d0
	beq.s		.done_summer
	diptobip	(a0)
	move.l		(sp)+,a0
	move.l		d0,tcon_summer(a0)
	move.l		#NET_HOUR,d0
	move.l		d0,tcon_dst_offs(a0)
	add.l		d0,d0
	move.l		d0,tcon_dst_ssec(a0)
	move.l		d0,tcon_dst_esec(a0)
	clr		tcon_tm_isdst(a0)	;flag DST info valid
.done_summer
	movem.l		(sp)+,d0-d2/a0-a2
	rts
;
TIME_SUMMER_vn_s:
	dc.b		'TIME_SUMMER'
summer_nul_s:
	dc.b		NUL
	even
	ENDM	;tcon_rd_summer_code
;----------------------------------------------------------------------------
	ENDC	;STinG_NET_TCON_defined
;----------------------------------------------------------------------------
;End of file:	NET_TCON.I
;----------------------------------------------------------------------------
