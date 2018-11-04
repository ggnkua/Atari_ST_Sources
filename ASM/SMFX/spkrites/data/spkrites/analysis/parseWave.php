<?php
	// this opens a file and splits it into 360 times 16 different lists, orders the list by offsets, for starters
//	$lines = file("wavetab.txt");
	$nr_sprites = 268+1;			//250+1

	$lines = file("wave268.txt");
	$linecount=0;
	$framecount = 0;
	$resultframes = array();
	$moveframes = array();
	$fileIndex = 0;
	foreach($lines as $line){
		if($linecount == $nr_sprites){
			$linecount = 0;
			$framecount++;
		}
		if($linecount == 0){
			// if new linecount; init the structure
			$resultframes[$framecount] = array();
			$moveframes[$framecount] = array();
			for($t=0;$t<16;$t++){
				$resultframes[$framecount][$t] = array();
				$moveframes[$framecount][$t] = array();
			}
			$spriteIndex = 0;
			// open file handle
			$frameNumber = str_pad(($fileIndex%360), 3, '0', STR_PAD_LEFT);
			$fileName= "results_". $frameNumber . ".json";
			$curFile = json_decode(file_get_contents($fileName),true);
//			print_r($curFile);
			$moveSprites = $curFile['sol'];
			$spritesList = $curFIle['masks'];
			$fileIndex++;

		}
		else{
			// if not new linecount; parse data and put shit into structure
			$tmpresult = explode(";",$line);
//			print_r($tmpresult);
			$offset = $tmpresult[0];
			$sprite = $tmpresult[1];
	//		echo $offset . " " . $sprite ."\n";
			if(in_array($spriteIndex,array_values($moveSprites))){
				$moveframes[$framecount][$sprite][] = $offset;
			}
			else{
				$resultframes[$framecount][$sprite][] = $offset;
			}
			$spriteIndex++;
		}
		$linecount++;
	}

//	array_multisort($resultframes);
	foreach($resultframes as $framekey => $frame){				// frame
		foreach($frame as $bucketkey => $bucket){				// sprite
			sort($resultframes[$framekey][$bucketkey]);			
			sort($moveframes[$framekey][$bucketkey]);
		}
	}


	foreach($resultframes as $framekey => $frame){
		foreach($frame as $bucketkey => $bucket){
			$offset = 0;
			foreach($bucket as $key => $value){
				$tmp = $value;
				$resultframes[$framekey][$bucketkey][$key] = $value - $offset;
				$offset = $tmp;
			}
		}
	}

	foreach($moveframes as $framekey => $frame){
		foreach($frame as $bucketkey => $bucket){
			$offset = 0;
			foreach($bucket as $key => $value){
				$tmp = $value;
				$moveframes[$framekey][$bucketkey][$key] = $value - $offset;
				$offset = $tmp;
			}
		}
	}	


	$orBucketSizes = array(-64,-88,-104,-112,-120,-120,-128,-136,-136,-136,-134,-128,-128,-118,-110,-90);
	$moveBucketSizes = array(-64,-88,-104,-112,-120,-120,-128,-128,-128,-128,-128,-122,-122,-114,-106,-90);




	$maxList = array();
	$maxListMove = array();
//	print_r($resultframes);
/*
	$count = 0;
	foreach($resultframes as $framekey => $frame){
		echo "frame" . $count ."\n";
		$bucketNr = 0;
		foreach($frame as $bucketkey => $bucket){
			$size = $orBucketSizes[$bucketkey];
			echo "\tdc.w\t" . $size * count($bucket) . "\t; " . count($bucket) . "\n";		// this is the offset for the jump	
			if(count($bucket) > $maxList[$bucketkey]){
				$maxList[$bucketkey] = count($bucket);
			}
			foreach($bucket as $offset){
				echo "\tdc.w\t" . $offset ."\n";
			}
			$bucketNr++;
		}
		$count++;
	}
	
*/
	for($f=0;$f<360;$f++){
		echo "frame" . $f . "\n";

		for($b=0; $b<16; $b++){
			// size for single sprite move
			$moveSize = $moveBucketSizes[$b];		// move
			$orSize = $orBucketSizes[$b];			// or
			// number of sprites move
			$nr_EntriesMove = count($moveframes[$f][$b]);
				echo "; moves: " . $b . "\n";
				echo "\tdc.w\t" . $moveSize * $nr_EntriesMove . "\t; " . $nr_EntriesMove  . "\t; offset for jump\n";		// this is the offset for the jump	
				// print the list of offsets for this bucket
				foreach($moveframes[$f][$b] as $offset){
					echo "\tdc.w\t" . $offset ."\n";				
				}

			// keep track of max entries for this sprite; over multiple frames
			if($nr_EntriesMove > $maxListMove[$b]){
				$maxListMove[$b] = $nr_EntriesMove;
			}
		}	

/*
		for($b=0; $b<16; $b++){
			// size for single sprite or
			$orSize = $orBucketSizes[$b];			// or
			// number of sprites
			$nr_EntriesOr = count($resultframes[$f][$b]);
				echo "; ors:" . $b . "\n";
				echo "\tdc.w\t" . $orSize * $nr_EntriesOr . "\t; " . $nr_EntriesOr  . "\t; offset for jump\n";		// this is the offset for the jump	
				// print the list of offsets for this bucket
				foreach($resultframes[$f][$b] as $offset){
					echo "\tdc.w\t" . $offset ."\n";				
				}
			if($nr_EntriesOr > $maxList[$b]){
				$maxList[$b] = $nr_EntriesOr;
			}
		}	
*/

	}


	echo "; max entries per bucket move \n";
	foreach($maxListMove as $key => $value){
		echo "; " . $key . " " . $value . "\n";
	}

	echo "; max entries per bucket or \n";
	foreach($maxList as $key => $value){
		echo "; " . $key . " " . $value . "\n";
	}

?>