<?php

$colorz = array(
    0 => array(1, 7, 1, 5, 2), // North
    1 => array(7, 7, 4, 5, 2), // East
    2 => array(7, 7, 4, 5, 2), // South
    3 => array(1, 7, 1, 5, 2), // West
);

/*===================*/
/* Utility functions */
/*===================*/

function matrixRotate90($src) {
    $tmp = array();
    for ($y = 0 ; $y < 16 ; $y++) {
        for ($x = 0 ; $x < 16 ; $x++) {
            $tmp[$y][$x] = $src[15 - $x][$y];
        }
    }
    return $tmp;
}
function matrixRotate($src, $angle) {
    $tmp = $src;
    for ($a = 90 ; $a <= $angle ; $a += 90) {
        $tmp = matrixRotate90($tmp);
    }
    return $tmp;
}

function matrixReset(&$dst) {
    for ($y = 0 ; $y < 16 ; $y++) {
        for ($x = 0 ; $x < 16 ; $x++) {
            $dst[$y][$x] = NULL;
        }
    }
}

function matrixSet(&$dst, $value) {
    for ($y = 0 ; $y < 16 ; $y++) {
        for ($x = 0 ; $x < 16 ; $x++) {
            $dst[$y][$x] = $value[$y][$x];
        }
    }
}

function matrixAdd(&$dst, $value) {
    for ($y = 0 ; $y < 16 ; $y++) {
        for ($x = 0 ; $x < 16 ; $x++) {
            $dst[$y][$x] += $value[$y][$x];
        }
    }
}

function matrixNeg($dst) {
    for ($y = 0 ; $y < 16 ; $y++) {
        for ($x = 0 ; $x < 16 ; $x++) {
            $dst[$y][$x] = -$dst[$y][$x];
        }
    }
    return $dst;
}

function matrixMerge(&$dst, $value, $orientation, $colors) {
    switch ($orientation) {
        case 'north': $basecolor = 0; break;
        case 'east':  $basecolor = 1; break;
        case 'south': $basecolor = 2; break;
        case 'west':  $basecolor = 3; break;
    }
    for ($y = 0 ; $y < 16 ; $y++) {
        for ($x = 0 ; $x < 16 ; $x++) {
            if (! is_null($value[$y][$x])) {
                $o = substr($value[$y][$x], 0, 1);
                switch ($o) {
                    case 'n': $c = 0; break;
                    case 'e': $c = 1; break;
                    case 's': $c = 2; break;
                    case 'w': $c = 3; break;
                }
                $n = substr($value[$y][$x], 1, 1);
                $dst[$y][$x] = $colors[($basecolor + $c) % 4][$n - 1];
            }
        }
    }    
}

function matrixAnd(&$dst, $value) {
    for ($y = 0 ; $y < 16 ; $y++) {
        for ($x = 0 ; $x < 16 ; $x++) {
            if (is_null($value[$y][$x])) {
                $dst[$y][$x] = NULL;
            } elseif ($value[$y][$x] == 1) {
                $dst[$y][$x] &= $value[$y][$x];
            }
        }
    }    
}

/*================*/
/* Generate tiles */
/*================*/

function getHorizontal($orientation) {
    global $matrix, $colorz;
    $current = array();
    if (($orientation == 'north') or ($orientation == 'west')) {
        matrixSet($current, $matrix['bg_light']);
    } else {
        matrixSet($current, $matrix['bg_dark']);
    }
    matrixAdd($current, $matrix['horizontal_darken']);
    matrixMerge($current, $matrix['horizontal'], $orientation, $colorz);
    switch ($orientation) {
        case 'north':   return $current;
        case 'east':    return matrixRotate($current,  90);
        case 'south':   return matrixRotate($current, 180);
        case 'west':    return matrixRotate($current, 270);
    }
}

function getAngle($orientation) {
    global $matrix, $colorz;
    $current = array();
    if (($orientation == 'east') or ($orientation == 'west')) {
        matrixSet($current, $matrix['bg_medium']);
        if ($orientation == 'east') {
            matrixAdd($current, matrixNeg($matrix['double_triangle']));
        } else {
            matrixAdd($current, $matrix['double_triangle']);
        }
    } elseif ($orientation == 'south') {
        matrixSet($current, $matrix['bg_light']);
        matrixAdd($current, $matrix['double_triangle_2']);
    } elseif ($orientation == 'north') {
        matrixSet($current, $matrix['bg_dark']);
        matrixAdd($current, matrixNeg($matrix['double_triangle_2']));
    }
    matrixAdd($current, $matrix['angle_darken']);
    matrixMerge($current, $matrix['angle'], $orientation, $colorz);
    switch ($orientation) {
        case 'north':   return $current;
        case 'east':    return matrixRotate($current,  90);
        case 'south':   return matrixRotate($current, 180);
        case 'west':    return matrixRotate($current, 270);
    }
}

function getOblique($orientation) {
    global $matrix, $colorz;
    $current = array();
    if ($orientation == 'north') {
        matrixSet($current, $matrix['bg_light']);
    } elseif (($orientation == 'east') or ($orientation == 'west')) {
        matrixSet($current, $matrix['bg_medium']);
    } elseif ($orientation == 'south') {
        matrixSet($current, $matrix['bg_dark']);
    }
    matrixAnd($current, $matrix['cut_triangle']);
    matrixAdd($current, $matrix['oblique_darken']);
    matrixMerge($current, $matrix['oblique'], $orientation, $colorz);
    switch ($orientation) {
        case 'north':   return $current;
        case 'east':    return matrixRotate($current,  90);
        case 'south':   return matrixRotate($current, 180);
        case 'west':    return matrixRotate($current, 270);
    }
}

function getOblique2($orientation) {
    global $matrix, $colorz;
    $current = array();
    if ($orientation == 'north') {
        matrixSet($current, $matrix['bg_light']);
        matrixAdd($current, $matrix['darken_triangle_n']);
    } elseif (($orientation == 'east') or ($orientation == 'west')) {
        matrixSet($current, $matrix['bg_medium']);
    } elseif ($orientation == 'south') {
        matrixSet($current, $matrix['bg_medium']);
        matrixAdd($current, $matrix['darken_triangle_s']);
    }
    matrixAdd($current, $matrix['oblique2_darken']);
    matrixMerge($current, $matrix['oblique2'], $orientation, $colorz);
    switch ($orientation) {
        case 'north':   return $current;
        case 'east':    return matrixRotate($current,  90);
        case 'south':   return matrixRotate($current, 180);
        case 'west':    return matrixRotate($current, 270);
    }
}

?>