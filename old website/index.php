<html><head><title>Kingly Games iOS Development</title></head>
<center>
<h2>Kingly Games presents Eden:</h2>
<img src="ui.png"></img><br>
Eden is a <a href="http://minecraft.net/">minecraft</a> style sandbox game coming this November to the iPhone, iPod Touch and iPad. <br>

<form action="" method="post">
<br>Enter your email to be notified when Eden is released:
<input name="email" size="30" type="text"><input value="Submit" type=submit>
</form>
<?
if($_SERVER['REQUEST_METHOD'] === 'POST'){
	$email=$_POST["email"];
	$email=strtolower($email);
	if(check_email($email)==1){
		echo "Thanks!<br>";
		 $cf = fopen("../private/alskdfjhalksdfhalksdfhkaljsdfh.txt", "a");
       		 fputs($cf, "\n<$email>");      
       		 fclose($cf);		
	}else{
		echo "That doesn't look like an email address.<br>";
	}
}
function check_email ($email){
        // check if email exists
           if ($email==""){return 0;}
        // check whether email is correct (basic checking)
           $test1=strpos($email, "@");                               
           $test2=strpos(substr($email,strpos($email,"@")), ".");   
           $test3=strlen($email);                                  
           $test4=substr_count ($email,"@");                        
           if ($test1<2 or $test2<2 or $test3<7 or $test4!=1){return 0;}
	   return 1;
}

?>
Contact: <a href="mailto:kinglygames@gmail.com">kinglygames@gmail.com</a>
</center>
</html>
