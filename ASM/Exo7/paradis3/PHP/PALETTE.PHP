<?php
# +======================================================================+
# | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
# +----------------------------------------------------------------------+
# | Generate palette values for the background                           |
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

/*
**  Converts HSV to RGB values
** –––––––––––––––––––––––––––––––––––––––––––––––––––––
**  Reference: http://en.wikipedia.org/wiki/HSL_and_HSV
**  Original : https://gist.github.com/Jadzia626/2323023
**  Purpose:   Useful for generating colours with
**             same hue-value for web designs.
**  Input:     Hue        (H) Integer 0-360
**             Saturation (S) Integer 0-100
**             Lightness  (V) Integer 0-100
**  Output:    Array(R,G,B)
*/

function hsvToRgb($iH, $iS, $iV) {
    if($iH < 0)   $iH = 0;          // Hue:
    if($iH > 360) $iH = 360;        //   0-360
    if($iS < 0)   $iS = 0;          // Saturation:
    if($iS > 100) $iS = 100;        //   0-100
    if($iV < 0)   $iV = 0;          // Lightness:
    if($iV > 100) $iV = 100;        //   0-100
    $dS = $iS/100.0;                // Saturation: 0.0-1.0
    $dV = $iV/100.0;                // Lightness:  0.0-1.0
    $dC = $dV*$dS;                  // Chroma:     0.0-1.0
    $dH = $iH/60.0;                 // H-Prime:    0.0-6.0
    $dT = $dH;                      // Temp variable
    while($dT >= 2.0) $dT -= 2.0;   // php modulus does not work with float
    $dX = $dC*(1-abs($dT-1));       // as used in the Wikipedia link
    switch(floor($dH)) {
        case 0:  $dR = $dC; $dG = $dX; $dB = 0.0; break;
        case 1:  $dR = $dX; $dG = $dC; $dB = 0.0; break;
        case 2:  $dR = 0.0; $dG = $dC; $dB = $dX; break;
        case 3:  $dR = 0.0; $dG = $dX; $dB = $dC; break;
        case 4:  $dR = $dX; $dG = 0.0; $dB = $dC; break;
        case 5:  $dR = $dC; $dG = 0.0; $dB = $dX; break;
        default: $dR = 0.0; $dG = 0.0; $dB = 0.0; break;
    }
    $dM  = $dV - $dC;
    $dR += $dM; $dG += $dM; $dB += $dM;
    $dR *= 255; $dG *= 255; $dB *= 255;
    return array(round($dR),round($dG),round($dB));
}

//$image = imagecreatefrompng(__DIR__ . '/backgd.png');
$image = imagecreatefrompng(__DIR__ . '/agent-t.png');
$w = 8;
$h = 64;

$valueWire = array(50, 60, 40, 20, 40, 60, 80, 40);

$txt = $bin = '';

$j = 0;
for ($n = 0 ; $n < 300 ; $n++) {

    $hueBack = ((300 - $n) * 360 / 300) / 3;
    $hueWire = $hueBack + 360 / 32;

    $txt .= "\t" . 'dc.w ';
    $sep = '';
    for ($i2 = 0 ; $i2 < 2 ; $i2++) {
        for ($i = 0 ; $i < $w ; $i++) {
            $rgb = imagecolorsforindex($image, imagecolorat($image, $i, $j));
            $hex = strtoupper(
                substr('00' . dechex($rgb['red']),   -2) .
                substr('00' . dechex($rgb['green']), -2) .
                substr('00' . dechex($rgb['blue']),  -2)
            );
            $red   = $rgb['red'];
            $green = $rgb['green'];
            $blue  = $rgb['blue'];
            /*
            switch ($hex) {
                case '000000': list($red, $green, $blue) = array(0, 0, 0); break;
                case '00FF00': list($red, $green, $blue) = hsvToRgb($hueBack, 70, 100); break;
                case '00DD00': list($red, $green, $blue) = hsvToRgb($hueBack, 70,  85); break;
                case '00BB00': list($red, $green, $blue) = hsvToRgb($hueBack, 70,  70); break;
                case '009900': list($red, $green, $blue) = hsvToRgb($hueBack, 70,  55); break;
                case '007700': list($red, $green, $blue) = hsvToRgb($hueBack, 70,  40); break;
                case '005500': list($red, $green, $blue) = hsvToRgb($hueBack, 70,  25); break;
                case 'FFFFFF': list($red, $green, $blue) = hsvToRgb($hueWire, 50, $valueWire[$i]); break;
                default:       die('error unknown color : ' . $hex . PHP_EOL); break;
            }
            */
            $r = round($red * 7 / 255, 0);
            $g = round($green * 7 / 255, 0);
            $b = round($blue * 7 / 255, 0);
            $txt .= $sep . '$0' . $r . $g . $b;
            $bin .= pack('n',  hexdec($r . $g . $b));
            $sep = ',';
        }
    }
    $txt .= "\r\n";

    $j++;
    if ($j == $h) $j = 0;

}

file_put_contents(__DIR__ . '/../INC/PALETTE.S', $txt);
file_put_contents(__DIR__ . '/../INC/PALETTE.BIN', $bin);

?>