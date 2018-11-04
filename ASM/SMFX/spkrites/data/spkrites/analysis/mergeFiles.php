<?php
	$mixed = file("../../wave268allnew.s");
	$clear = file("newClear.s");

	$result = array();

	foreach($mixed as $line){
		if(!strpos($line,'dc.w') !== true ){
			$result[$curLine][] = trim($line);
		}
		else{
			$curLine = trim($line);
			$result[$curLine] = array();
		}
	}


	foreach($clear as $line){
		if(!strpos($line,'dc.w') !== true ){
			$result[$curLine][] = trim($line);
		}
		else{
			$curLine = trim($line);
			$result[$curLine] = array();
		}
	}

	$first = "clearframe_";
	$second = "moveframe";
	$third = "orframe";

	for($f=0;$f<360;$f++){
		$key = $first . $f;
		echo $key . "\n";
		$firstArray = $result[$key];
		foreach($firstArray as $line){
			echo "\t" . $line . "\n";
		}	
		$key = $second . $f;
		echo $key . "\n";
		$firstArray = $result[$key];
		foreach($firstArray as $line){
			echo "\t" . $line . "\n";
		}	
		$key = $third . $f;
		echo $key . "\n";
		$firstArray = $result[$key];
		foreach($firstArray as $line){
			echo "\t" . $line . "\n";
		}	

	}

?>