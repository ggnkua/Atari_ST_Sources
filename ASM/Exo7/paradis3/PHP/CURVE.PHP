<?php
# +======================================================================+
# | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
# +----------------------------------------------------------------------+
# | Generate curves values                                               |
# +======================================================================+
# | Copyright (c) 2015 Frederic Poeydomenge <dyno@aldabase.com>          |
# +----------------------------------------------------------------------+
# | This program is free software: you can redistribute it and/or modify |
# | it under the terms of the GNU General Public License as published by |
# | the Free Software Foundation, either version 3 of the License, or    |
# | (at your option) any later version.                                  |
# |                                                                      |
# | This program is distributed in the hope that it will be useful,      |
# | but WITHOUT ANY WARRANTY; without even the implied warranty of       |
# | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the         |
# | GNU General Public License for more details.                         |
# |                                                                      |
# | You should have received a copy of the GNU General Public License    |
# | along with this program. If not, see <http://www.gnu.org/licenses/>. |
# +======================================================================+

function disp($title, $curve, $progress) {
    $txt = $bin = '';
    $decal = 0;
    $previous = 0;
    $diff = array();
    foreach ($curve AS $item) {
        $nitem = - floor($item - $decal);
        $diff[] = $nitem - $previous;
        $previous = $nitem;
        $decal += $progress / count($curve);
    }
    foreach ($diff AS $value) {
        $txt .= "\t" . 'dc.b ' . $value . "\r\n";
        $bin .= pack('c',  $value);
    }
    $txt .= "\t" . 'dc.b 127' . "\r\n";    
    $bin .= pack('c',  127);
    file_put_contents(__DIR__ . '/../INC/CURVE/' . strtoupper($title) . '.S', $txt);
    file_put_contents(__DIR__ . '/../INC/CURVE/' . strtoupper($title) . '.BIN', $bin);
}

/*===================*/
/* Simple sine curve */
/*===================*/

/* Slow sine */
$step = 0.2;
$curve = array();
for ($i = 0 ; $i < 360 - $step ; $i += $step) {
    $angle = deg2rad($i);
    $curve[] = 100 * sin($angle);
}
disp('slowsin', $curve, 140);

/* Medium sine */
$step = 0.25;
$curve = array();
for ($i = 0 ; $i < 360 - $step ; $i += $step) {
    $angle = deg2rad($i);
    $curve[] = 110 * sin($angle);
}
disp('medsin', $curve, 175);

/* Fast sine */
$step = 0.3;
$curve = array();
for ($i = 0 ; $i < 360 - $step ; $i += $step) {
    $angle = deg2rad($i);
    $curve[] = 120 * sin($angle);
}
disp('fastsin', $curve, 210);

/*===================*/
/* Double sine curve */
/*===================*/

/* Slow Dist */
$step = 0.12;
$curve = array();
for ($i = 0 ; $i < 360 - $step ; $i += $step) {
    $angle1 = deg2rad($i);
    $angle2 = deg2rad($i * 10);
    $curve[] = 100 * sin($angle1) + 25 * sin($angle2);
}
disp('slowdist', $curve, 175);

/* Medium Dist */
$step = 0.16;
$curve = array();
for ($i = 0 ; $i < 360 - $step ; $i += $step) {
    $angle1 = deg2rad($i);
    $angle2 = deg2rad($i * 9);
    $curve[] = 110 * sin($angle1) + 27.5 * sin($angle2);
}
disp('meddist', $curve, 210);

/* Fast Dist */
$step = 0.2;
$curve = array();
for ($i = 0 ; $i < 360 - $step ; $i += $step) {
    $angle1 = deg2rad($i);
    $angle2 = deg2rad($i * 8);
    $curve[] = 120 * sin($angle1) + 30 * sin($angle2);
}
disp('fastdist', $curve, 245);

/*================*/
/* Splitted curve */
/*================*/

$step = 0.18;
$curve = array();
$j = 0;
for ($i = 0 ; $i < 720 - $step ; $i += $step) {
    $dir = ($j % 2 == 0) ? +1 : -1;
    $amp = 12;
    if ($i < 160) {
        $amp *= $i / 160;
    } elseif ((720-160) < $i) {
        $amp *= (720-$i) / 160;
    }
    $angle1 = deg2rad($i);
    $angle2 = deg2rad($i * 3);
    $curve[] = 90 * sin($angle1) + $dir * $amp * sin($angle2);
    $j++;
}
disp('splitted', $curve, 0);

/*============*/
/* Background */
/*============*/

$step = 0.5;
$curve = array();
for ($i = 0 ; $i < 360 - $step ; $i += $step) {
    $angle = deg2rad($i);
    $curve[] = - 60 * sin($angle);
}
disp('bg_sin1', $curve, 0);

$step = 0.8;
$curve = array();
for ($i = 0 ; $i < 360 - $step ; $i += $step) {
    $angle = deg2rad($i);
    $curve[] = - 60 * sin($angle);
}
disp('bg_sin2', $curve, 0);

$step = 0.5;
$curve = array();
for ($i = 0 ; $i < 360 - $step ; $i += $step) {
    $angle1 = deg2rad($i);
    $angle2 = deg2rad($i * 4);
    $curve[] = - 60 * sin($angle1) - 15 * sin($angle2);
}
disp('bg_sin3', $curve, 0);

?>