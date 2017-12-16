<?php

/*=============*/
/* BACKGROUNDS */
/*=============*/

for ($y = 0 ; $y < 16 ; $y++) {
    for ($x = 0 ; $x < 16 ; $x++) {
        $rand = mt_rand(0,99);
        $color = ($rand < 50) ? 3 : (($rand < 80) ? 4 : 5);
        $matrix['bg_light'][$y][$x]  = $color + 0; // 3..6
        $matrix['bg_medium'][$y][$x] = $color + 1; // 4..7
        $matrix['bg_dark'][$y][$x]   = $color + 2; // 5..8
    }
}

/*===============*/
/* TRIANGLE CUTS */
/*===============*/

$matrix['cut_triangle'] = array(
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0xFF),
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0xFF,0xFF),
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0xFF,0xFF,0xFF),
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0xFF,0xFF,0xFF,0xFF),
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0xFF,0xFF,0xFF,0xFF,0xFF),
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF),
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF),
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF),
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF),
    array(NULL,NULL,NULL,NULL,NULL,NULL,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF),
    array(NULL,NULL,NULL,NULL,NULL,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF),
    array(NULL,NULL,NULL,NULL,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF),
    array(NULL,NULL,NULL,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF),
    array(NULL,NULL,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF),
    array(NULL,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF),
    array(0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF),
);

$matrix['double_triangle'] = array(
    array( 0,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1),
    array(-1, 0,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1),
    array(-1,-1, 0,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1),
    array(-1,-1,-1, 0,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1),
    array(-1,-1,-1,-1, 0,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1),
    array(-1,-1,-1,-1,-1, 0,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1),
    array(-1,-1,-1,-1,-1,-1, 0,+1,+1,+1,+1,+1,+1,+1,+1,+1),
    array(-1,-1,-1,-1,-1,-1,-1, 0,+1,+1,+1,+1,+1,+1,+1,+1),
    array(-1,-1,-1,-1,-1,-1,-1,-1, 0,+1,+1,+1,+1,+1,+1,+1),
    array(-1,-1,-1,-1,-1,-1,-1,-1,-1, 0,+1,+1,+1,+1,+1,+1),
    array(-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0,+1,+1,+1,+1,+1),
    array(-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0,+1,+1,+1,+1),
    array(-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0,+1,+1,+1),
    array(-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0,+1,+1),
    array(-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0,+1),
    array(-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0),
);
$matrix['double_triangle_2'] = array(
    array(+1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0,+1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0,+1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0,+1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0,+1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0,+1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0,+1, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0,+1, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0,+1, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0,+1, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+1, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+1, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+1, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+1, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+1, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+1),
);

$matrix['darken_triangle_s'] = array(
    array(+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1, 0),
    array(+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1, 0, 0),
    array(+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1, 0, 0, 0),
    array(+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1, 0, 0, 0, 0),
    array(+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1, 0, 0, 0, 0, 0),
    array(+1,+1,+1,+1,+1,+1,+1,+1,+1,+1, 0, 0, 0, 0, 0, 0),
    array(+1,+1,+1,+1,+1,+1,+1,+1,+1, 0, 0, 0, 0, 0, 0, 0),
    array(+1,+1,+1,+1,+1,+1,+1,+1, 0, 0, 0, 0, 0, 0, 0, 0),
    array(+1,+1,+1,+1,+1,+1,+1, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array(+1,+1,+1,+1,+1,+1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array(+1,+1,+1,+1,+1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array(+1,+1,+1,+1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array(+1,+1,+1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array(+1,+1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array(+1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
);
$matrix['darken_triangle_n'] = array(
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+1),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+1,+1),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+1,+1,+1),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+1,+1,+1,+1),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+1,+1,+1,+1,+1),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+1,+1,+1,+1,+1,+1),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0,+1,+1,+1,+1,+1,+1,+1),
    array( 0, 0, 0, 0, 0, 0, 0, 0,+1,+1,+1,+1,+1,+1,+1,+1),
    array( 0, 0, 0, 0, 0, 0, 0,+1,+1,+1,+1,+1,+1,+1,+1,+1),
    array( 0, 0, 0, 0, 0, 0,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1),
    array( 0, 0, 0, 0, 0,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1),
    array( 0, 0, 0, 0,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1),
    array( 0, 0, 0,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1),
    array( 0, 0,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1),
    array( 0,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1),
    array(+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1,+1),
);

/*==========================*/
/* HORIZONTAL/VERTICAL BAND */
/*==========================*/

$matrix['horizontal_darken'] = array(
    array_fill(0, 16, 0),
    array_fill(0, 16, 0),
    array_fill(0, 16, 0),
    array_fill(0, 16, 0),
    array_fill(0, 16, +2),
    array_fill(0, 16, +2),
    array_fill(0, 16, +2),
    array_fill(0, 16, 0),
    array_fill(0, 16, 0),
    array_fill(0, 16, 0),
    array_fill(0, 16, 0),
    array_fill(0, 16, 0),
    array_fill(0, 16, 0),
    array_fill(0, 16, 0),
    array_fill(0, 16, 0),
    array_fill(0, 16, 0),
);

$matrix['horizontal'] = array(
    array_fill(0, 16, 'n1'),
    array_fill(0, 16, NULL),
    array_fill(0, 16, NULL),
    array_fill(0, 16, 'n2'),
    array_fill(0, 16, NULL),
    array_fill(0, 16, NULL),
    array_fill(0, 16, NULL),
    array_fill(0, 16, 'n3'),
    array_fill(0, 16, NULL),
    array_fill(0, 16, NULL),
    array_fill(0, 16, NULL),
    array_fill(0, 16, NULL),
    array_fill(0, 16, NULL),
    array_fill(0, 16, NULL),
    array_fill(0, 16, 'n4'),
    array_fill(0, 16, 'n5'),
);

/*===========*/
/* 90° ANGLE */
/*===========*/

$matrix['angle_darken'] = array(
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0,+2,+2,+2,+2,+2,+2,+2),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0,+2,+2,+2,+2,+2,+2,+2),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0,+2,+2,+2,+2,+2,+2,+2),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0,+2,+2,+2, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0,+2,+2,+2, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0,+2,+2,+2, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0,+2,+2,+2, 0, 0, 0, 0),
);

$matrix['angle'] = array(
    array(NULL,'s5','s5','s5','s5','s5','s5','s5','s5','s5','s5','s5','s5','s5','s5','s5'),
    array('e5',NULL,'s4','s4','s4','s4','s4','s4','s4','s4','s4','s4','s4','s4','s4','s4'),
    array('e5','e4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array('e5','e4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array('e5','e4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array('e5','e4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array('e5','e4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array('e5','e4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array('e5','e4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'s3','s3','s3','s3','s3','s3','s3'),
    array('e5','e4',NULL,NULL,NULL,NULL,NULL,NULL,'e3',NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array('e5','e4',NULL,NULL,NULL,NULL,NULL,NULL,'e3',NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array('e5','e4',NULL,NULL,NULL,NULL,NULL,NULL,'e3',NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array('e5','e4',NULL,NULL,NULL,NULL,NULL,NULL,'e3',NULL,NULL,NULL,NULL,'s2','s2','s2'),
    array('e5','e4',NULL,NULL,NULL,NULL,NULL,NULL,'e3',NULL,NULL,NULL,'e2',NULL,NULL,NULL),
    array('e5','e4',NULL,NULL,NULL,NULL,NULL,NULL,'e3',NULL,NULL,NULL,'e2',NULL,NULL,NULL),
    array('e5','e4',NULL,NULL,NULL,NULL,NULL,NULL,'e3',NULL,NULL,NULL,'e2',NULL,NULL,NULL),
);

/*=========*/
/* OBLIQUE */
/*=========*/

$matrix['oblique_darken'] = array(
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+2),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+2,+2),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+2,+2,+2),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+2,+2,+2, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+2,+2,+2, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,+2,+2,+2, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0,+2,+2,+2, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0,+2,+2,+2, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0,+2,+2,+2, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0,+2,+2,+2, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0,+2,+2,+2, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0,+2,+2,+2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
);

$matrix['oblique'] = array(
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n1'),
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n1',NULL),
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n1',NULL,NULL),
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n1',NULL,NULL,'n2'),
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n1',NULL,NULL,'n2',NULL),
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n1',NULL,NULL,'n2',NULL,NULL),
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n1',NULL,NULL,'n2',NULL,NULL,NULL),
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n1',NULL,NULL,'n2',NULL,NULL,NULL,'n3'),
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n1',NULL,NULL,'n2',NULL,NULL,NULL,'n3',NULL),
    array(NULL,NULL,NULL,NULL,NULL,NULL,'n1',NULL,NULL,'n2',NULL,NULL,NULL,'n3',NULL,NULL),
    array(NULL,NULL,NULL,NULL,NULL,'n1',NULL,NULL,'n2',NULL,NULL,NULL,'n3',NULL,NULL,NULL),
    array(NULL,NULL,NULL,NULL,'n1',NULL,NULL,'n2',NULL,NULL,NULL,'n3',NULL,NULL,NULL,NULL),
    array(NULL,NULL,NULL,'n1',NULL,NULL,'n2',NULL,NULL,NULL,'n3',NULL,NULL,NULL,NULL,NULL),
    array(NULL,NULL,'n1',NULL,NULL,'n2',NULL,NULL,NULL,'n3',NULL,NULL,NULL,NULL,NULL,NULL),
    array(NULL,'n1',NULL,NULL,'n2',NULL,NULL,NULL,'n3',NULL,NULL,NULL,NULL,NULL,NULL,'n4'),
    array('n1',NULL,NULL,'n2',NULL,NULL,NULL,'n3',NULL,NULL,NULL,NULL,NULL,NULL,'n4','n5'),
);

/*==========*/
/* OBLIQUE2 */
/*==========*/

$matrix['oblique2_darken'] = array(
    array( 0, 0, 0,+2,+2,+2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0,+2,+2,+2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0,+2,+2,+2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array(+2,+2,+2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array(+2,+2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array(+2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    array( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
);

$matrix['oblique2'] = array(
    array(NULL,NULL,'n2',NULL,NULL,NULL,'n3',NULL,NULL,NULL,NULL,NULL,NULL,'n4','n5',NULL),
    array(NULL,'n2',NULL,NULL,NULL,'n3',NULL,NULL,NULL,NULL,NULL,NULL,'n4','n5',NULL,NULL),
    array('n2',NULL,NULL,NULL,'n3',NULL,NULL,NULL,NULL,NULL,NULL,'n4','n5',NULL,NULL,NULL),
    array(NULL,NULL,NULL,'n3',NULL,NULL,NULL,NULL,NULL,NULL,'n4','n5',NULL,NULL,NULL,NULL),
    array(NULL,NULL,'n3',NULL,NULL,NULL,NULL,NULL,NULL,'n4','n5',NULL,NULL,NULL,NULL,NULL),
    array(NULL,'n3',NULL,NULL,NULL,NULL,NULL,NULL,'n4','n5',NULL,NULL,NULL,NULL,NULL,NULL),
    array('n3',NULL,NULL,NULL,NULL,NULL,NULL,'n4','n5',NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array(NULL,NULL,NULL,NULL,NULL,NULL,'n4','n5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array(NULL,NULL,NULL,NULL,NULL,'n4','n5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array(NULL,NULL,NULL,NULL,'n4','n5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array(NULL,NULL,NULL,'n4','n5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array(NULL,NULL,'n4','n5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array(NULL,'n4','n5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array('n4','n5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array('n5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
    array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
);

?>