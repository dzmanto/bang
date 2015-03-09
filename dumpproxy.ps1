Function dumpproxy {
	$proxy = [System.Net.WebRequest]::GetSystemWebProxy()
	$dump = $proxy.GetProxy("http://www.bing.com")
	Write-Verbose -Message "Your proxy URI is: $dump " -Verbose
	# $dump | out-file ".\dumpproxy.txt"
	$stream = [System.IO.StreamWriter] "dumpproxy.txt"
	$stream.WriteLine($dump)
	$stream.close()
}

dumpproxy
