INDICATOR playopt_i[] = {{PLY06250, &ply_speed},	/* 0 */
												 {PLY12500, &ply_speed},	/* 1 */
												 {PLY25000, &ply_speed},	/* 2 */
												 {PLY50000, &ply_speed},	/* 3 */
												 {MANUSPD, &ply_speed},	 	/* 4 */
												 {OVSM_OFF, &play_ovsm},	/* 5 */
												 {OVSM_ON, &play_ovsm},		/* 6 */
												 {ONPSG, &play_dev},			/* 7 */
												 {ONDMA, &play_dev},			/* 8 */
												 {ONCODEC, &play_dev}			/* 9 */
												 };

ACTIVATOR playopt_a[] = {{SPDMINUS, spd_down},
												 {SPDPLUS, spd_up},
												 {ONPSG, popt_psg},
												 {ONDMA, popt_dma},
												 {ONCODEC, popt_codec},
												 {OVSM_ON, popt_ovon},
												 {OVSM_OFF, popt_ovoff}
												 };

DIALOG playopt_dia = {PLAYOPT, "Abspiel-Optionen", 10, 7, playopt_i, playopt_a, 0, 0, -1, ""};

