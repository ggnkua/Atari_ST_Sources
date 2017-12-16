<?php

// Reduce entropy by injecting parts of the song
// into unused parts of the font and of the tileset

/*====================*/
/* Get file to inject */
/*====================*/

/*$main = file_get_contents(__DIR__ . '/../SCROLL4B.S');
if (preg_match('/^SONG\s*=\s*([0-9]+)/m', $main, $matches)) {
    $injectfile = ($matches[1] == 1) ? 'JESS.SND' : 'TAO.SND';
} else {
    die('SONG not found');
}*/
//$injectfile = __DIR__ . '/../SCROLL4B.REF';
//$injectfile = __DIR__ . '/../INC/' . 'MDTILE.RAW';
//$injectfile = __DIR__ . '/../INC/' . 'MDFONT.BIN';
$injectfile = __DIR__ . '/../INC/' . 'TAO.SND';
//echo 'Injecting file : ', $injectfile, PHP_EOL;

$filler = '';
$tmp = trim(file_get_contents($injectfile));
while (strlen($filler) < 60*16*16) {
    $filler .= $tmp;
}
$filler .= $filler;

/*====================*/
/* Function GetFiller */
/*====================*/

function getFiller($len) {
    global $filler;
    //return substr($filler, 0, $len);
    //return str_repeat(chr(0), $len);
    //return str_repeat(chr(1), $len);
    return str_repeat(chr(255), $len);
}

/*=======================*/
/* Inject file into FONT */
/*=======================*/

$font = file_get_contents(__DIR__ . '/../INC/MDFONT.BIN');
$holes = array();
for ($c = 0 ; $c < strlen($font) ; $c++) {
    $start = $c;
    if (ord($font[$c]) == 255) {
        while (@ord($font[$c++]) == 255);
        $end = $c - 1;
        $len = $end - $start;
        $holes[] = array('start' => $start, 'end' => $end, 'len' => $len);
    }
}
//print_r($holes);
foreach ($holes AS $hole) {
    $font = substr_replace($font, getFiller($hole['len']), $hole['start'], $hole['len']);
}
file_put_contents(__DIR__ . '/../INC/MDFONT.BIN', $font);

/*=======================*/
/* Inject file into TILE */
/*=======================*/

$tile = file_get_contents(__DIR__ . '/../INC/MDTILE.RAW');
//$tile = substr_replace($tile, getFiller(128),   34+128*0,  128*1);
$tile = substr_replace($tile, getFiller(128*2), 34+128*8,  128*2);
$tile = substr_replace($tile, getFiller(128*2), 34+128*12, 128*2);
file_put_contents(__DIR__ . '/../INC/MDTILE.RAW', $tile);

?>