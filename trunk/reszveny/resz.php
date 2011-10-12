<?php

	class ContentWithCURL {

		var $content;
		var $header;

		/**
		 * Ez az fuggveny kepes kinyerni mind http mind https oldalakrol a tartalmat
		 */
		function ContentWithCURL( $url, $postvars=null ){
			$ch = curl_init();

			curl_setopt( $ch, CURLOPT_URL, $url );
			curl_setopt( $ch, CURLOPT_FOLLOWLOCATION  ,1); 
			curl_setopt( $ch, CURLOPT_HEADER, 0 ); 
			curl_setopt( $ch, CURLOPT_RETURNTRANSFER, 1 ); 
			curl_setopt( $ch, CURLOPT_USERAGENT, 'Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)' );
			curl_setopt( $ch, CURLOPT_SSL_VERIFYPEER, FALSE);

			if( $postvars != null ){
				curl_setopt( $ch, CURLOPT_POST, 1 );

				curl_setopt( $ch, CURLOPT_POSTFIELDS, $postvars );
			}

			// grab URL and pass it to the browser
			$this->content = curl_exec( $ch );

			$this->header  = curl_getinfo( $ch );

			// close cURL resource, and free up system resources
			curl_close( $ch );

		}

		function getContent(){
			return $this->content;
		}

		function getHeader(){
			return $this->header;
		}

	}

	$url = $argv[1];
	$stock = $argv[2];
//http://www.ebroker.hu/pls/ebrk/new_arfolyam_html_p.startup
	$ContentObject = new ContentWithCURL( $url );

	$content = $ContentObject->getContent();

	//Lecserelem a szukseges karaktereket
	$replace_array = array(
		'|\s+|'		=> ' ',		//egy sorba rendezi a teljes tartalmat
		'|&nbsp;|'	=> ' ',		//Nobreakspace atalakitasa space-ve
		'|[ ]+<|'	=> '<',		//kezdo tag jel elotti space torlese
		'|>[\s]+<|iU'	=> '><',	//egymast koveto tagok kozotti space-ek torlese
	);

	foreach( $replace_array as $what => $with ){
		$content = preg_replace( $what, $with, $content );
	}

	//Az adott papirok adatainak kinyerese
//	$match = '|<tr><td class="tablazat-cella" align="left"><A[^>]*><b>'.$stock.'</b></A></td>(.+)</tr>|Ui';
	$match = '|<tr><td class="tablazat-cella2" align="left"><A[^>]*><b>'.$stock.'</b></A></td>(.+)</tr>|Ui';	
	$result = preg_match( $match, $content, $found );	

	//Ha nem talalta meg az adott papirt, akkor hibauzenet
	if( $result != 1 ){
		echo "-1\n";
		exit;
	}

//<td class="t-emel" align="right">2 405</td><td class="t-emel" align="right">13</td><td class="t-emel" align="right">2 395</td><td class="t-emel" align="right">100</td><td class="t-emel" align="right">2 405</td><td class="t-emel" align="right">1 352</td><td class="tablazat-cella" align="right">2 320</td><td class="t-emel" align="right">85 (366%)</td><td class="tablazat-cella" align="right">3 908 176 000</td></tr>

	//Kivalogatja az osszes ertekeket
	//Az eredmény:
	//[1][0]	utolso kotes
	//[1][1]	kotesek szama
	//[1][2]	legjobb veteli ajanlat
	//[1][3]	legjobb veteli ajanlat szama
	//[1][4]	legjobb eladasi ajanlat
	//[1][5]	legjobb eladasi ajanlat szama
	//[1][6]	előzőnapi zárókötés értéke
	//[1][7]	-10 (0.43%) formában az utolsó kötés az előzőnapihoz képest
	//[1][8]	forgalom
	$content = $found[0];
	$match = '|<td class=[^>]+>([0-9 ()%-.]+)</td>|Ui';
	preg_match_all( $match, $content, $found );	

	//Kinyerni az utolso kotes erteket
	$match = '|([0-9 ]+)[.]?|i';	
	$result = preg_match( $match, $found[ 1 ][ 0 ], $f );
	if( $result != 1 ){
		echo "-1\n";
		exit;
	}
	$out_lastvalue = $f[ 1 ];

	//Kinyerni az elozonapi zaro kotes erteket
	$match = '|([0-9 ]+)[.]?|i';	
	$result = preg_match( $match, $found[ 1 ][ 6 ], $f );
	if( $result != 1 ){
		echo "-1\n";
		exit;
	}
	$out_beforevalue = $f[ 1 ];

	//Kinyerni a valtozas merteket
	$match = '|\(([0-9 .-]+%)\)|i';	
	$result = preg_match( $match, $found[ 1 ][ 7 ], $f );
	if( $result != 1 ){
		echo "-1\n";
		exit;
	}
	$out_change = $f[ 1 ];



	echo $out_lastvalue."\n";
	echo $out_beforevalue."\n";
	echo $out_change."\n";



	//Ki kell nyerni meg a 
/*
	<tr>
		<td class="tablazat-cella" align="left"><A class="tablazat-cella" href="javascript:grafikon(56920803);"><b>OTP</b></A>
		</td>
		
		<td class="t-emel" align="right">2 410. &nbsp;
		</td>

		<td class="t-emel" align="right">30&nbsp;
		</td>

		<td class="t-emel" align="right">2 408. &nbsp;
		</td>

		<td class="t-emel" align="right">250&nbsp;
		</td>

		<td class="t-emel" align="right">2 410 &nbsp;
		</td>

		<td class="t-emel" align="right">2 010&nbsp;
		</td>

		<td class="tablazat-cella" align="right">2 320 &nbsp;
		</td>

		<td class="t-emel" align="right">90 (3.88%)&nbsp;
		</td>

		<td class="tablazat-cella" align="right">3 512 929 750 &nbsp;
		</td>
	</tr>
*/
?>

