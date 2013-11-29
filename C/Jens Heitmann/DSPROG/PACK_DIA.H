INDICATOR packopt_i[] = {{PCKFILT, &pck_filt},
												 {PK4PLUS, &pck_4plus},
												 {PK4BIT,  &pck_4bit}, 
												 {PKALTER, &pck_alter}};

ACTIVATOR packopt_a[] = {{CVALUP, pkor_up},
												 {CVALDWN, pkor_dwn}};

DIALOG packopt_dia = {PACKOPT, "Pack-Optionen", 4, 2, packopt_i, packopt_a, 0, 0, -1, ""};


