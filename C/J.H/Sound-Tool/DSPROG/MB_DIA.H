INDICATOR mboard_i[] = {{MB06250, &ply_speed},	/* 0 */
											  {MB12500, &ply_speed},	/* 1 */
												{MB25000, &ply_speed},	/* 2 */
												{MB50000, &ply_speed},	/* 3 */
												{MBMANU,  &ply_speed},	/* 4 */
												{-1,  		&play_dummy},	/* 5 */	
												{-1, 			&play_dummy},	/* 6 */
												{MBPSG, 	&play_dev},		/* 7 */
												{MBDMA, 	&play_dev},		/* 8 */
												{MBCODEC, &play_dev},		/* 9 */
												{MBOVSM,	&play_ovsm},
												
                        {MB_OVSM2,&ovsm_typ},		
												{MB_OVSM3,&ovsm_typ},		
												{MB_OSHFT,&ovsm_typ},		
												
												{MB_OVSMF,&flt_ovsm},
												{MB_FBAD, &flt_bad},
												{MB_FPEAK,&flt_pitch},
												{MBFFLAT, &flt_slice},
												
												{MB_PFILT,&pck_filt},
												{MB_P4PLS,&pck_4plus},
												{MB_P4,   &pck_4bit}, 
												{MB_PALT, &pck_alter}
												};


ACTIVATOR mboard_a[] = {{MBMINUS, spd_down},
												{MBPLUS, 	spd_up},
												{MBPSG, 	popt_psg},
												{MBDMA,		popt_dma},
												{MBCODEC, popt_codec},
												
												{MB_CVMNS, pkor_dwn},
												{MB_SVPLS, pkor_up}
												};

DIALOG mboard_dia = {ALLINONE, "Multi-Board", 22, 7, mboard_i, 
										 mboard_a, 0, 0, -1, ""};

