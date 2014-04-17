/*	CRYSBIND.H	05/05/84 - 02/02/85	Lee Lorenzen		*/

				/* Submenu Manager */
#define MN_POPUP     36
#define MN_ATTACH    37
#define MN_ISTART    38
#define MN_SETTING   39

#define M_MENU		addr_in[0]
#define M_XPOS		int_in[0]
#define M_YPOS		int_in[1]
#define M_MDATA		addr_in[1]
#define M_FLAG		int_in[0]
#define M_TREE		addr_in[0]
#define M_ITEM		int_in[1]
#define M_MENU2		int_in[1]
#define M_ITEM2		int_in[2]

					/* max sizes for arrays		*/
#define C_SIZE 4
#define G_SIZE 15
#define I_SIZE 16
#define O_SIZE 7
#define AI_SIZE 2
#define AO_SIZE 1
					/* Crystal funtion op code	*/
#define OP_CODE control[0]
#define IN_LEN control[1]
#define OUT_LEN control[2]
#define AIN_LEN control[3]
#define MM_ITREE	addr_in[0]		/* ienable,icheck,tnorm	*/
			
#define RET_CODE int_out[0]

