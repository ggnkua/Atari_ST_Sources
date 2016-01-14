<?php
# +======================================================================+
# | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
# +----------------------------------------------------------------------+
# | Pack/Unpack samples with delta-compression algorithm                 |
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

$deltaValue = array(0, 1, 2, 4, 8, 16, 32, 64, 127, -64, -32, -16, -8, -4, -2, -1);

$deltaTable = array();
for ($i = 0, $j = -128 ; $i < 256 ; $i++, $j++) {
  if ($j ==    0)               $deltaTable[$i] =  0;
  if ($j ==    1)               $deltaTable[$i] =  1;
  if ($j >=    2 and $j <=   3) $deltaTable[$i] =  2;
  if ($j >=    4 and $j <=   6) $deltaTable[$i] =  3;
  if ($j >=    7 and $j <=  12) $deltaTable[$i] =  4;
  if ($j >=   13 and $j <=  24) $deltaTable[$i] =  5;
  if ($j >=   25 and $j <=  48) $deltaTable[$i] =  6;
  if ($j >=   49 and $j <=  96) $deltaTable[$i] =  7;
  if ($j >=   97 and $j <= 127) $deltaTable[$i] =  8;
  if ($j >= -128 and $j <= -97) $deltaTable[$i] =  8;
  if ($j >=  -96 and $j <= -49) $deltaTable[$i] =  9;
  if ($j >=  -48 and $j <= -25) $deltaTable[$i] = 10;
  if ($j >=  -24 and $j <= -13) $deltaTable[$i] = 11;
  if ($j >=  -12 and $j <=  -7) $deltaTable[$i] = 12;
  if ($j >=   -6 and $j <=  -4) $deltaTable[$i] = 13;
  if ($j >=   -3 and $j <=  -2) $deltaTable[$i] = 14;
  if ($j ==   -1)               $deltaTable[$i] = 15;
}

function byte($value) {
    return $value & 255;
}

function compress($buffer) {
    global $deltaValue, $deltaTable;
    $delta_buffer = array();
    $previous = 0;
    for ($i = 0 ; $i < count($buffer) ; $i++) {
        $c = $buffer[$i];
        $delta = $c - $previous;
        $delta_buffer[$i] = $deltaTable[byte($delta + 128)];
        $previous += $deltaValue[$delta_buffer[$i]];
    }
    return $delta_buffer;
}

function decompress($delta_buffer) {
    global $deltaValue, $deltaTable;
    $buffer = array();
    $old_value = 0;
    for ($i = 0 ; $i < count($delta_buffer) ; $i++) {
        $index = $delta_buffer[$i];
        $value = $deltaValue[$index];
        $sample = byte($old_value + $value);
        $old_value = $sample;
        $buffer[$i] = $sample;
   }
   return $buffer;
}

for ($sample = 1 ; $sample <= 8 ; $sample++) {

    $f = file_get_contents(__DIR__ . '/../SOUND/SAMPLE' . $sample . '.WAV');

    $data = array();
    for ($c = 44; $c < strlen($f) ; $c++) {
        $data[] = ord($f[$c]);
    }
    $compressed = compress($data);
    $uncompressed = decompress($compressed);

    $str = '';
    for ($c = 0 ; $c < 44 ; $c++) {
        $str .= $f[$c];
    }
    for ($c = 44 ; $c < strlen($f) ; $c++) {
        $str .= chr($uncompressed[$c - 44]);
    }

    file_put_contents(__DIR__ . '/../SOUND/SAMPLE' . $sample . '.WAV', $str);

}

?>