BEGIN {
	start="something"
	end="something"
	flag=0
	count=0
}
/^Path [0-9]+:/ {print "";print}
/^Beginpoint:/ {
	start=$2
	print
	next
}
/^Endpoint:/ {
	end=$2
	print
	next
}
/^Path Groups:/ {print}
/^Analysis View:/ {print}
/^Other End Arrival Time/ {print}
/^..Setup/ || /^..Hold/ || /^..Recovery/ || /^..Removal/ {print}
/^..Phase Shift/ {print}
/^..Uncertainty/ {print}
/^..Required Time/ {print}
/^..Arrival Time/ {print}
/^..Slack Time/ {print}
$1==start {
	flag=1 
	print
	next
}
flag&&$1!=end{ 
	if ($1 ~ /^.*P6[SLU]8B_/) {
		print ", "$0
	} 
	else if ($1 ~ /\(net\)/) {
		print "? "$0
	}
	else if ($1 ~ /^[0-9]+\.[0-9]+/) {
		print "! "$0	
	}
	else {
		print
	}
}
$1==end {
	print
	if (NF==1) {
		getline
		print ", "$0
		if (NF==1) {
			getline
			print "! "$0
		}
	}
	flag=0
}
