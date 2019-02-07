/*
 * CARDDEFN.H
 *   Define File for cards.c
 *   (C) Copyright 1988 by Dynamic Software Design
 *
 */
 
#define WI_KIND NAME | CLOSER | INFO | LFARROW | RTARROW | HSLIDE

#define MEMS_WIND 0

#define	OPEN 1
#define CLOSED 2

#define DATA_SIZE	50000
#define MIN_WIDTH 100
#define MIN_HEIGHT 100

#define PAGE_UP 0
#define PAGE_DN 1
#define ARRW_UP 2
#define ARRW_DN 3
#define PAGE_LF 4
#define PAGE_RT 5
#define ARRW_LF 6
#define ARRW_RT 7

#define MAX_CARDS	500

#define UNUSED		0x00
#define	CARD_IN_USE	0x01
#define MARK_1		0x02
#define MARK_2		0x04
#define MARK_3		0x08
#define MARK_4		0x10
#define MARK_5		0x20
#define MARK_6		0x40

#define	NORMAL_MODE	0
#define MARK_MODE	1

#define	A_TO_Z	1
#define Z_TO_A	2

#define LOOK_LEFT 1
#define LOOK_RIGHT 2
#define LOOK_ABSOLUTE 3

#define LESS_THAN 		0x01
#define GREATER_THAN 	0x02
#define EQUAL			0x04

