/* Created with RSM2CS V1.00beta by Armin Diedering from "A:\CODE\C\CMANSHIP\DATE.RSC" */
/* From sources  by Holger Weets */

#include <AES.H>

static char rs_s0[] = "";

#define FLAGS11 0x0800
#define FLAGS12 0x1000
#define FLAGS13 0x2000
#define FLAGS14 0x4000
#define FLAGS15 0x8000
#define STATE8  0x0100
#define STATE9  0x0200
#define STATE10 0x0400
#define STATE11 0x0800
#define STATE12 0x1000
#define STATE13 0x2000
#define STATE14 0x4000
#define STATE15 0x8000
#define FL3DBAK 0
#define FL3DIND 0

#define RS_NTED 2

static TEDINFO rs_tedinfo[] = {
	"000000AM",
	"Time: __:__:__ __",
	"999999A",
	IBM, 0, TE_LEFT, 4480, 0, -2, 9, 18,

	"00000000",
	"Date: __/__/____",
	"9",
	IBM, 0, TE_LEFT, 4480, 0, -2, 9, 17
};

#define RS_NOBS 6

static OBJECT rs_obj[] = {
#define TR0 0
/* TREE 0 */
	-1, 1, 5, G_BOX,			/*** 0 ***/
	FL3DBAK,
	OUTLINED,
	(long) 135424L,
	1, 1, 52, 9,

	2, -1, -1, G_FTEXT,			/*** 1 ***/
	EDITABLE|FL3DBAK,
	NORMAL,
	(long) &rs_tedinfo[0],
	17, 3, 17, 1,

	3, -1, -1, G_FTEXT,			/*** 2 ***/
	EDITABLE|FL3DBAK,
	NORMAL,
	(long) &rs_tedinfo[1],
	17, 4, 16, 2,

	4, -1, -1, G_BUTTON,			/*** 3 ***/
	SELECTABLE|EXIT|FL3DIND|FL3DBAK,
	NORMAL,
	(long) "OK",
	9, 7, 8, 1,

	5, -1, -1, G_BUTTON,			/*** 4 ***/
	SELECTABLE|EXIT|FL3DIND|FL3DBAK,
	NORMAL,
	(long) "CANCEL",
	29, 7, 8, 1,

	0, -1, -1, G_STRING,			/*** 5 ***/
	LASTOB,
	NORMAL,
	(long) "Date / Time",
	21, 1, 11, 1
};

OBJECT *DATEDIAL		= &rs_obj[TR0];


void rs_init();
void rs_exit();

void rs_init()
{
	register OBJECT	*obj=rs_obj;
	register int	i=0;

	do
	{
		rsrc_obfix(obj, i);
	} while (++i<RS_NOBS);
}
void rs_exit()
{
}
