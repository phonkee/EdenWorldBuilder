<?php


$list=file_get_contents("file_list.txt");



$lines=explode("\n",$list);
$max=count($lines);
if($max>1000){
	$max=1000;
}

if($_GET["sort"]=="0"){ //name
	
	for($i=0;$i<$max;$i++){
		$split=strpos($lines[$i]," ");
		$file_name=substr($lines[$i],0,$split);
		$display_name=substr($lines[$i],$split+1);
		$temp=strtoupper($display_name)."|" . $display_name . "|" . $file_name;
		$lines[$i]=$temp;
	//	echo "$lines[$i]\n";
	}
//	echo "-------\n";
	sort($lines,SORT_STRING);

	for($i=0;$i<$max;$i++){
		$split=strpos($lines[$i],"|");
		$temp=substr($lines[$i],$split+1);		
		$split=strpos($temp,"|");
		$file_name=substr($temp,0,$split);
		$display_name=substr($temp,$split+1);
		$temp=$display_name . " " . $file_name;
		$lines[$i]=$temp;
	//	echo "$lines[$i]\n";
	}
}else if($_GET["sort"]=="1"){ //best
	$lines=$lines;
}else if($_GET["sort"]=="2"){ //date
	$lines=array_reverse($lines);
}
					


for($i=0;$i<$max;$i++){
	$split=strpos($lines[$i]," ");
	$file_name=substr($lines[$i],0,$split);
	$display_name=substr($lines[$i],$split+1);
	echo "$file_name\n$display_name.name\n";
}
/*if ($handle = opendir('eden_maps/')) {
   
    
    
    while (false !== ($file = readdir($handle))) {
        echo "$file\nName $i.name\n$i.rating\n";
    	$i++;
    }
    closedir($handle);
}*/
?>