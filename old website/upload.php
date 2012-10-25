<?php 


// make a note of the current working directory, relative to root. 
$directory_self = str_replace(basename($_SERVER['PHP_SELF']), '', $_SERVER['PHP_SELF']); 

// make a note of the directory that will recieve the uploaded file 
$uploadsDirectory = $_SERVER['DOCUMENT_ROOT'] . $directory_self . 'eden_maps/'; 
 




// fieldname used within the file <input> of the HTML form 
$fieldname = 'uploaded'; 

// Now let's deal with the upload 

// possible PHP upload errors 
$errors = array(1 => 'php.ini max file size exceeded', 
                2 => 'html form max file size exceeded', 
                3 => 'file upload was only partial', 
                4 => 'no file was attached'); 
 
// check for PHP's built-in uploading errors 
($_FILES[$fieldname]['error'] == 0) 
    or error($errors[$_FILES[$fieldname]['error']], $uploadForm); 
     
// check that the file we are working on really was the subject of an HTTP upload 
@is_uploaded_file($_FILES[$fieldname]['tmp_name']) 
    or error('not an HTTP upload', $uploadForm); 
     
// validation here...   

// make a unique filename for the uploaded file and check it is not already 
// taken... if it is already taken keep trying until we find a vacant one 
// sample filename: 1140732936-filename.jpg 
$now = time(); 
while(file_exists($uploadFilename = $uploadsDirectory.$now.".eden")) 
{ 
    $now++; 
} 

// now let's move the file to its final location and allocate the new filename to it 
@move_uploaded_file($_FILES[$fieldname]['tmp_name'], $uploadFilename) 
    or error('receiving directory insufficient permission', $uploadForm); 

$string =file_get_contents($uploadFilename);

$string =gzinflate(substr($string,10));


$string=substr($string,40,50);
$name="";

for($i=0;$i<50;$i++){
if(ord(substr($string,$i,1))==0){
	break;
}
$name=$name.substr($string,$i,1);
}

$fh=fopen("file_list.txt",'a');
fwrite($fh,$now.".eden"." ".$name."\n");
fclose($fh);


  

echo "YES";

// The following function is an error handler which is used 
// to output an HTML error page if the file upload fails 
function error($error, $location) 
{ 
   echo "Error: $error, $location"; 
   exit;
} // end error handler 

?>