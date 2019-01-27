<? 
require('../includes/config.php'); 

$DBTable = "highscores_2048";

date_default_timezone_set("Europe/Paris");
 
$link = mysql_connect($DBHost, $DBUser, $DBPass);
mysql_select_db($DBName);
if ($link > 0)
{
	$avant = array (";", "\r\n", "\t");
	$apres = array (",", "\\r\\n", "\\t");

	$res = mysql_query("SELECT * FROM $DBTable ORDER BY score DESC LIMIT 100 ") or die (mysql_error());
	$rank = 1;
	while($col = mysql_fetch_array($res))
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
  	
	mysql_free_result($res);

	mysql_close($link); 
}
else 
{
	echo "no database connection";
}
?>
