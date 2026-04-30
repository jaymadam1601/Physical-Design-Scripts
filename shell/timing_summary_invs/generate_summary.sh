BEGIN {
    # --- Summary vars ---
    startpoint="something"; endpoint="something"; flag=0; count=0
	print "Startpoint(1) Endpoint(2) Startpoint_Clock(3) Endpoint_Clock(4) Status(5) PathGroup(6) CheckType(7) AnalysisView(8) Period(9) Capture_Latency(10) Setup/Hold/Recovery/Removal(11) Uncertainty(12) Required_Time(13) Arrival_Time(14) IncrDelay(15) LogicDepth(16) Slack(17)"
}
# ------------------- PART 1: formatting like arrenge_invs_timing_report -------------------
/^Path [0-9]+:/ {
    startpoint="NA"; endpoint="NA"; startpoint_clock="NA"; endpoint_clock="NA"
    stat="NA"; pathgroup="NA"; checktype="NA"; analsview="NA"
    capturelatency="NA"; setuporhold="NA"; period="NA"; uncertainty="NA"; reqtime="NA"; arrtime="NA"; slacktime="NA"
    stat=$3; checktype=$4; incrdelay="NA"
    next
}
/^Beginpoint:/ { startpoint=$2; gsub("[']","",$NF); startpoint_clock=$NF; next }
/^Endpoint:/   { endpoint=$2; gsub("[']","",$NF); endpoint_clock=$NF; next }
/^Path Groups:/ { gsub("[{}]","",$3); pathgroup=$3; next }
/^Analysis View:/ { analsview=$3; next }
/^Other End Arrival Time/ { capturelatency=$5; next }
/^..Setup/ || /^..Hold/ || /^..Recovery/ || /^..Removal/ { setuporhold=$3; next }
/^..Phase Shift/ { period=$4; next }
/^..Uncertainty/ { uncertainty=$3; next }
/^..Required Time/ { reqtime=$4; next }
/^..Arrival Time/ { for (i=1;i<NF;i++){ if ($i=="Time"){arrtime=$(i+1)} } ; next }
/^..Slack Time/ { for (i=1;i<NF;i++){ if ($i=="Time"){slacktime=$(i+1)} } ; next }

$1==startpoint {
	newline=$0
	if (NF == 1) {getline; newline=newline" "$0 ; if (NF==1) {getline;newline=newline" "$0;} }
	split(newline, incrd, " ");
	if (incrd[5] < 0 ) {
		incrdelay=incrd[5] * -1
	} else {
		incrdelay=incrd[5]
	}
    flag=1; count=0; next
}
flag && $1!=endpoint {
	newline=$0
	if (NF == 1) {getline; newline=newline" "$0 ; if (NF==1) {getline;newline=newline" "$0;} }
    if (newline !~ /\(net\)/) {
		count++
		split(newline, incrd, " ");
		if (incrd[5] < 0 ) {
			incrdelay=(incrd[5] * -1) + incrdelay
    	} else {
			incrdelay=incrd[5] + incrdelay
    	}
	}
    next
}
$1==endpoint {
	newline=$0
	if (NF == 1 ) {getline; newline=newline" "$0 ; if (NF==1) {getline;newline=newline" "$0;} }
    count=count/2
    split(newline, incrd, " ");
    if (incrd[5] < 0 ) { 
		incrdelay=(incrd[5] * -1) + incrdelay
    } else {
        incrdelay=incrd[5] + incrdelay
    }   
	print startpoint,endpoint,startpoint_clock,endpoint_clock,stat,pathgroup,checktype,analsview,period,capturelatency,setuporhold,uncertainty,reqtime,arrtime,incrdelay,count,slacktime
    flag=0
}

