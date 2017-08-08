<?
    $width = 320;
    $height = 200;


	$filename = $argv[1];
	$handle = fopen($filename, "rb"); 
	$fsize = filesize($filename); 
	$contents = fread($handle, $fsize); 
	$byteArray = unpack("C*",$contents); 

    $data[][] = array();
    $counter = 1079;							// this is to skip header

    for($y=0; $y<$height; $y++){
    	for($x=0; $x<$width; $x++){
    		$data[$y][$x] = $byteArray[$counter++];
    	}
	}

	// revert stuff
	$pic[] = array();
	$c = $height-1;
	for($y=0;$y<$height;$y++){
		$pic[$y] = $data[$c--];
	}

//	echo $data[0][0];

	// print stuff
	$output = array();
	$ylist = array();
	$linestring = "";
	for($y=0; $y<$height;$y++){
		$xlist = array();
		$linestring .= "\tdc.b\t";
		for($x=0; $x<$width;$x++){
			if(!in_array($pic[$y][$x],$xlist)){
				$xlist[] = $pic[$y][$x];
			}
			$index = array_search($pic[$y][$x], $xlist);
			if($x < $width-1){
				$linestring .= $index . ",";
			}
			else{
				$linestring .= $index . "\n";
			}

		}
		$ylist[$y] = $xlist;
	}

	echo $linestring;
	foreach($ylist as $yentry){
			$colors = "\tdc.w\t";
		for($i=0;$i<16;$i++){
			if($i != 15){
				if(isset($yentry[$i])){
					$colors .= $yentry[$i] . ",";
				}
				else{
					$colors .= "$0,";
				}
			}
			else{
				if(isset($yentry[$i])){
					$colors .= $yentry[$i] . "\n";
				}
				else{
					$colors .= "0\n";
				}
			}
		}
//		echo $colors;
	}

?>