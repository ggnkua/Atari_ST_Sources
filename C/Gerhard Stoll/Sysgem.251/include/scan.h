/************************************************************************/
/* nkcc-scancodes                                                       */
/************************************************************************/

#define CNTRL_A                     0xc441
#define CNTRL_B                     0xc442
#define CNTRL_C                     0xc443
#define CNTRL_D                     0xc444
#define CNTRL_E                     0xc445
#define CNTRL_F                     0xc446
#define CNTRL_G                     0xc447
#define CNTRL_H                     0xc448
#define CNTRL_I                     0xc449
#define CNTRL_J                     0xc44a
#define CNTRL_K                     0xc44b
#define CNTRL_L                     0xc44c
#define CNTRL_M                     0xc44d
#define CNTRL_N                     0xc44e
#define CNTRL_O                     0xc44f
#define CNTRL_P                     0xc450
#define CNTRL_Q                     0xc451
#define CNTRL_R                     0xc452
#define CNTRL_S                     0xc453
#define CNTRL_T                     0xc454
#define CNTRL_U                     0xc455
#define CNTRL_V                     0xc456
#define CNTRL_W                     0xc457
#define CNTRL_X                     0xc458
#define CNTRL_Y                     0xc459
#define CNTRL_Z                     0xc45a
#define CNTRL_AE                    0xc48e
#define CNTRL_OE                    0xc499
#define CNTRL_UE                    0xc49a
#define CNTRL_1                     0x8431
#define CNTRL_2                     0x8432
#define CNTRL_3                     0x8433
#define CNTRL_4                     0x8434
#define CNTRL_5                     0x8435
#define CNTRL_6                     0x8436
#define CNTRL_7                     0x8437
#define CNTRL_8                     0x8438
#define CNTRL_9                     0x8439
#define CNTRL_0                     0x8430
#define LSHFT_DEL                   0xc21f  /* dh */
#define RSHFT_DEL                   0xc11f  /* dh */
#define CNTRL_DEL                   0xc41f  /* dh */
#define RSHFT_INS                   0x810b  /* dh */
#define CNTRL_INS                   0x840b  /* dh */
#define LSHFT_TAB                   0xc209  /* dh */
#define RSHFT_TAB                   0xc109  /* dh */
#define CNTRL_TAB                   0xc409  /* dh */
#define LSHFT_HELP                  0xc20e  /* dh */
#define RSHFT_HELP                  0xc10e  /* dh */
#define CNTRL_HELP                  0xc40e  /* dh */

#define ALT_A                       0xc841
#define ALT_B                       0xc842
#define ALT_C                       0xc843
#define ALT_D                       0xc844
#define ALT_E                       0xc845
#define ALT_F                       0xc846
#define ALT_G                       0xc847
#define ALT_H                       0xc848
#define ALT_I                       0xc849
#define ALT_J                       0xc84a
#define ALT_K                       0xc84b
#define ALT_L                       0xc84c
#define ALT_M                       0xc84d
#define ALT_N                       0xc84e
#define ALT_O                       0xc84f
#define ALT_P                       0xc850
#define ALT_Q                       0xc851
#define ALT_R                       0xc852
#define ALT_S                       0xc853
#define ALT_T                       0xc854
#define ALT_U                       0xc855
#define ALT_V                       0xc856
#define ALT_W                       0xc857
#define ALT_X                       0xc858
#define ALT_Y                       0xc859
#define ALT_Z                       0xc85a

#define ALT_AE                      0x005b
#define ALT_OE                      0x005d
#define ALT_UE                      0x0040

#define ALT_1                       0x8831
#define ALT_2                       0x8832
#define ALT_3                       0x8833
#define ALT_4                       0x8834
#define ALT_5                       0x8835
#define ALT_6                       0x8836
#define ALT_7                       0x8837
#define ALT_8                       0x8838
#define ALT_9                       0x8839
#define ALT_0                       0x8830

#define ESC                         0xc01b
#define BACKSPACE                   0xc008
#define DELETE                      0xc01f
#define INSERT                      0x800b
#define LSHFT_INS                   0x820b
#define RETURN                      0xc00d
#define ENTER                       0xe00a
#define CUR_UP                      0x8001
#define LSHFT_UP                    0x8201
#define RSHFT_UP                    0x8101
#define CNTRL_UP										0x8401		/* [GS] 2.51] */
#define CUR_LEFT                    0x8004
#define LSHFT_CL                    0x8204
#define RSHFT_CL                    0x8104
#define CNTRL_CL										0xc404		/* [GS] 2.51] */
#define CUR_RIGHT                   0x8003
#define LSHFT_CR                    0x8203
#define RSHFT_CR                    0x8103
#define CNTRL_CR										0xc403		/* [GS] 2.51] */
#define CUR_DOWN                    0x8002
#define LSHFT_CD                    0x8202
#define RSHFT_CD                    0x8102
#define CNTRL_CD										0x8402		/* [GS] 2.51] */
#define HOME                        0x800c
#define LSHFT_HOME                  0x820c
#define RSHFT_HOME                  0x810c
#define UNDO                        0xc00f
#define TAB                         0xc009
#define LSHFT_TAB		    						0xc209
#define RSHFT_TAB		    						0xc109
#define HELP                        0xc00e
#define F1                          0xc010
#define F2                          0xc011
#define F3                          0xc012
#define F4                          0xc013
#define F5                          0xc014
#define F6                          0xc015
#define F7                          0xc016
#define F8                          0xc017
#define F9                          0xc018
#define F10                         0xc019
#define F11													0xc313		/* [GS] 2.51] */
#define F12													0xc314		/* [GS] 2.51] */
#define SHFT_F1                     0xc210
#define SHFT_F2                     0xc211
#define SHFT_F3                     0xc212
#define SHFT_F4                     0xc213
#define SHFT_F5                     0xc214
#define SHFT_F6                     0xc215
#define SHFT_F7                     0xc216
#define SHFT_F8                     0xc217
#define SHFT_F9                     0xc218
#define SHFT_F10                    0xc219

#define CTLALTSPACE                 0xcc20

/************************************************************************/
