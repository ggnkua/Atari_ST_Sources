<?php
# +======================================================================+
# | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
# +----------------------------------------------------------------------+
# | Generate sound volume table                                          |
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

require_once __DIR__ . '/include.php';

$mvol = 223;
$deviation = 0;
$sampleValues = array();
for ($v = 0 ; $v < 256 ; $v++) {
    $combi = array();
    $volume = $mvol + $mvol * tanh(($v - 128) / 64);
    for ($c = 0 ; $c < 3 ; $c++) {
        foreach ($soundTable AS $key => $val) {
            if ($key <= $volume) {
                $combi[] = $val;
                $volume -= $key;
                break;
            }
        }
    }
    for($z = count($combi) ; $z < 3 ; $z++) {
        $combi[] = 0;
    }
    $sampleValues[$v] = $combi;
    $deviation += $volume;
}

echo 'Total deviation : ', $deviation, PHP_EOL;
$bin = '';
foreach ($sampleValues AS $combi) {
    $chan = 8;
    foreach ($combi AS $volume) {
        if ($chan == 8 or $chan == 9) {
            // 16 bits
            $bin .= pack('n', hexdec(substr(dechex($chan), -2) . substr('00' . dechex($volume), -2)));
        } else {
            // 32 bits
            $bin .= pack('N', hexdec(substr('00' . dechex($chan), -2) . '00' . substr('00' . dechex($volume), -2) . '00'));
        }
        $chan++;
    }
}
file_put_contents(__DIR__ . '/../INC/SOUND.BIN', $bin);

?>