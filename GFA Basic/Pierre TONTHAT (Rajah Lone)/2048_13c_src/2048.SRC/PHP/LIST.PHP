<?php 
require('../includes/config.php'); 

$DBTable = "game_2048";

date_default_timezone_set("Europe/Paris");
 
$link = mysqli_connect($DBHost, $DBUser, $DBPass, $DBName); mysqli_set_charset($link, "utf8");

if ($link > 0)
{
	$avant = array (";", "\r\n", "\t");
	$apres = array (",", "\\r\\n", "\\t");

	$res = mysqli_query($link, "SELECT * FROM $DBTable ORDER BY score DESC LIMIT 100 ") or die (mysqli_error($link));
	
	$rank = 1;
	
	while($col = mysqli_fetch_array($res))
	{    
		echo $rank;
		echo ";";
		echo str_replace($avant, $apres, $col["score"]);
		echo ";";
		echo str_replace($avant, $apres, $col["nickname"]);
		echo ";";
		echo str_replace($avant, $apres, $col["location"]);
		echo ";";
		echo $col["version"];
		echo ";";
		echo date("m-d-Y H:i", strtotime($col["moment"]));
		echo "\r\n";
		
		$rank += 1;
  	}
  	
	mysqli_free_result($res);

	mysqli_close($link); 
}
else 
{
	echo "no database connection";
}
?>
