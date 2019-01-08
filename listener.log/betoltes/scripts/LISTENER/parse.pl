#!/usr/bin/perl

$filename=$ARGV[0];
@test = split('__',$ARGV[0]);
$source_hostname = $test[0];
$instance_name = $test[1];
$listening_port = $test[2];

open (LISTENERLOG,"<$ARGV[0]");
open(MYOUTFILE, ">$filename.dat");
open(MYOUTFILE2, ">$filename.not");

$counter=0;

while ($line = <LISTENERLOG>)
{

   $counter++;

   if ($line =~ m/(^\d\d-.{2}\w{1,3}.? *-\d{4} \d\d:\d\d:\d\d)(.*)/)
   {
   # logdate found so we need this line, let's begin detailed parse:

        $logdate="$1";
        $remaining="$2"; # store remaining part of the line to parse it later

             # clear all variables
             
             $cd_sid="";
             $cd_cid_program="";
             $cd_cid_host="";
             $client_host_short="";
             $cd_cid_user="";
             $cd_server="";
             $cd_service_name="";
             $cd_command="";
             $cd_srv_protocol="";
             $cd_srv_host="";
             $cd_srv_port="";
             $cd_fm_type="";
             $cd_fm_method="";
             $cd_fm_retries="";
             $cd_fm_delay="";
             $pi_protocol="";
             $pi_host="";
             $pi_port="";
             $action="";
             $service_name="";
             $return_code="";

        if ($remaining =~ m/[^\*]* \* [^\*]*\(CONNECT_DATA=([^\*]*)(.*)/i)
        {
        # we have connect_data

             $cd="$1";
             $remaining="$2";

             if ($cd =~ m/.*SID=([^)]*).*/i)
             {
             # found SID
                 $cd_sid="$1";
             }
             if ($cd =~ m/.*CID=(.*?\)\)).*/i)
             {
             # found CID
                 $cd_cid="$1";
                 # parse CID's details:
                 if ($cd_cid =~ m/.*PROGRAM=([^)]*).*/i)
                 {
                     $cd_cid_program="$1";
                 }
                 if ($cd_cid =~ m/.*HOST=([^)]*).*/i)
                 {
                     $cd_cid_host="$1";
                     # cut short host name to group data based on this:
                     $client_host_short=$cd_cid_host;
                     $client_host_short =~ s/([^\.]*)\..*/\1/;
                 }
                 if ($cd_cid =~ m/.*USER=([^)]*).*/i)
                 {
                     $cd_cid_user="$1";
                 }
             } # end of CID's parse section
             if ($cd =~ m/.*SERVER=([^)]*).*/i)
             {
             # found SERVER connect mode (dedicated or shared)
                 $cd_server="$1";
             }
             if ($cd =~ m/.*SERVICE_NAME=([^)]*).*/i)
             {
             # found SERVCE_NAME
                 $cd_service_name="$1";
             }
             if ($cd =~ m/.*COMMAND=([^)]*).*/i)
             {
             # found COMMAND
                 $cd_command="$1";
             }
             if ($cd =~ m/.*SERVICE=(.*?\)\)).*/i)
             {
             # found SERVICE description section
                 $cd_srv="$1";
                 # parse SERVICE's details:
                 if ($cd_srv =~ m/.*PROTOCOL=([^)]*).*/i)
                 {
                     $cd_srv_protocol="$1";
                 }
                 if ($cd_srv =~ m/.*HOST=([^)]*).*/i)
                 {
                     $cd_srv_host="$1";
                 }
                 if ($cd_srv =~ m/.*PORT=([^)]*).*/i)
                 {
                     $cd_srv_port="$1";
                 }
             } # end of SERVICE's parse section
             if ($cd =~ m/.*FAILOVER_MODE=(.*?\)\)).*/i)
             {
             # found TAF description section
                 $cd_fm="$1";
                 # parse TAF details:
                 if ($cd_fm =~ m/.*TYPE=([^)]*).*/i)
                 {
                     $cd_fm_type="$1";
                 }
                 if ($cd_fm =~ m/.*METHOD=([^)]*).*/i)
                 {
                     $cd_fm_method="$1";
                 }
                 if ($cd_fm =~ m/.*RETRIES=([^)]*).*/i)
                 {
                     $cd_fm_retries="$1";
                 }
                 if ($cd_fm =~ m/.*DELAY=([^)]*).*/i)
                 {
                     $cd_fm_delay="$1";
                 }
             } # end of FAILOVER_MODE's parse section
        } # end of CONNECT_DATA section

        if ($remaining =~ m/[^\*]*\* [^\*]*\(ADDRESS=([^\*]*PROTOCOL=[^\*]*HOST=[^\*]*PORT=[^\*]*)(.*)/i)
        {
        # we have protocol_info

             $pi="$1";
             $remaining="$2";

             if ($pi =~ m/.*PROTOCOL=([^)]*).*/i)
             {
                 $pi_protocol="$1";
             }
             if ($pi =~ m/.*HOST=([^)]*).*/i)
             {
                 $pi_host="$1";
             }
             if ($pi =~ m/.*PORT=([^)]*).*/i)
             {
                 $pi_port="$1";
             }

        } # end of PROTOCOL_INFO section

        if ($remaining =~ m/[^\*]*\* (\w*) (.*)/i) 
        {
        # ACTION section
             $action="$1";
             $remaining="$2";
        } # end of ACTION section        

        if ($remaining =~ m/[^\*]*\* (\S*) (.*)/i)
        {
        # SERVICE_NAME section
             $service_name="$1";
             $remaining="$2";
        } # end of SERVICE_NAME section

        if ($remaining =~ m/[^\*]*\* (\d*).*/i)
        {
        # RETURN_CODE section
             $return_code="$1";
        } # end of RETURN_CODE section

print MYOUTFILE "$source_hostname|$instance_name|$listening_port|$counter|$logdate|$cd_sid|$cd_cid_program|$cd_cid_host|$client_host_short|$cd_cid_user|$cd_server|$cd_service_name|$cd_command|$cd_srv_protocol|$cd_srv_host|$cd_srv_port|$cd_fm_type|$cd_fm_method|$cd_fm_retries|$cd_fm_delay|$pi_protocol|$pi_host|$pi_port|$action|$service_name|$return_code\n";

   }
   else
   {
        $logdate="";
        print MYOUTFILE2 $line;
   }
}

close(MYOUTFILE);
close(MYOUTFILE2);

