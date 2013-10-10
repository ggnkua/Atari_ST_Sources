INDICATOR fltopt_i[] = {{FLTOVON1, &flt_ovsm},
												{FLTBAD1,  &flt_bad},
												{FLTPIT1,  &flt_pitch}, 
												{FLTSLC1,  &flt_slice}};

DIALOG fltopt_dia = {FILTOPT, "Filter-Optionen", 4, 0, fltopt_i, NULL, 0, 0, -1, ""};
