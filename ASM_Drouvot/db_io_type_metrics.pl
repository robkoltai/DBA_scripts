#!/usr/bin/env perl
#
# Author: Bertrand Drouvot
# Visit my blog : http://bdrouvot.wordpress.com/
# V1.0 (2014/05)
#
# Description:
# Utility used to display database IO type metrics (small,large,writes,reads and synchronous) in real time per snap or per average since the collection began.
# It basically takes a snapshot each second (default interval) of the gv$iostat_file cumulative view and computes the delta
# with the previous snapshot.
# The utility is RAC and Multitenant aware.
# You have to set oraenv on one DB instance
# You can choose the number of snapshots to display and the time to wait between snapshots.
#
# Usage:
# ./db_io_type_metrics.pl -help
#
# Chek for new version : http://bdrouvot.wordpress.com/db_io_type_metrics_script/
#
#----------------------------------------------------------------#

BEGIN {
    die "ORACLE_HOME not set\n" unless $ENV{ORACLE_HOME};
    unless ($ENV{OrAcLePeRl}) {
       $ENV{OrAcLePeRl} = "$ENV{ORACLE_HOME}/perl";
       $ENV{PERL5LIB} = "$ENV{PERL5LIB}:$ENV{OrAcLePeRl}/lib:$ENV{OrAcLePeRl}/lib/site_perl";
       $ENV{LD_LIBRARY_PATH} = "$ENV{LD_LIBRARY_PATH}:$ENV{ORACLE_HOME}/lib32:$ENV{ORACLE_HOME}/lib";
       exec "$ENV{OrAcLePeRl}/bin/perl", $0, @ARGV;
    }
}

use strict;
use DBI;
use DBD::Oracle qw(:ora_session_modes);

use Getopt::Long; 

our %options; 
our $debug=0;
our $version;
our $nb_pdbs=0;
our $interval=1; 
our $count=999999;
our $showinst=0;
our $rac=0;
our $inst_type='RDBMS';
our $dbh;
our $instpattern='all';
our $cont_pattern='';
our $file_type_tbs_pattern='file_type';
our $file_type_pattern='';
our $tbs_pattern='';
our $io_type_pattern='reads';
our $show_pattern='inst';
our $display_pattern='snap';
our $dg_suffixe='';
our $instid_pattern='f.inst_id';
our $sqlsuffixe;
our $sql1;
our $main_sql='';
our %instances;
our %showinstances=();
our %sql_patterns;
our %diffsnaps;
our %avgdiffsnaps=();
our %rtvalues;
our %pkeys;
our $bkey;
our @ekey;
our %ckeys=();
our @array_of_ckeys_description=();
our @array_of_display_keys=();
our @array_of_ckey=();
our @delta_fields;
our $global_sql_pattern='';
our @array_of_report_header;
our $report_format_values;
our @report_fields_values;
our $seconds;
our $minuts;
our $hours;
our @since_timing;
our %sort_fields;
our $sort_field_pattern='';

sub main {
&get_the_options(@ARGV);

	my $ckey_cpt=0;	
	&connect_db;
	$version=check_version();
	if ($version < 11) {&minimum_version()};
	if ($version >= 12) {$nb_pdbs=check_pdbs()};
	
	if ($nb_pdbs == 0) {
	$sort_fields{7}='LARGE_READS';
	$sort_fields{13}='LARGE_WRITES';
	$sort_fields{15}='NONE';
	$sort_fields{3}='SMALL_READS';
	$sort_fields{10}='SMALL_WRITES';
	%sort_fields = reverse %sort_fields;
	if (!$sort_field_pattern) {$sort_field_pattern='NONE'};
        if ($file_type_tbs_pattern =~ m/^file_type$/i ){
	# show file_type instead of tbs
	$instid_pattern="inst_id";
	$sql_patterns{'FILETYPE_NAME'}=$file_type_pattern;
        $main_sql="
	select inst_id,FILETYPE_NAME,SMALL_READ_MEGABYTES,SMALL_READ_REQS,SMALL_READ_SERVICETIME,SMALL_SYNC_READ_LATENCY,LARGE_READ_MEGABYTES,LARGE_READ_REQS,LARGE_READ_SERVICETIME,SMALL_WRITE_MEGABYTES,SMALL_WRITE_REQS,SMALL_WRITE_SERVICETIME,LARGE_WRITE_MEGABYTES,LARGE_WRITE_REQS,LARGE_WRITE_SERVICETIME,$interval,file_no,SMALL_SYNC_READ_REQS from GV\$IOSTAT_FILE
	where 1=1
	";
	}
        if ($file_type_tbs_pattern =~ m/^tbs$/i ){
	# show tbs instead of file_type
	$instid_pattern="inst_id";
	$sql_patterns{'tbs'}=$tbs_pattern;
	$main_sql="
	select inst_id,tbs,SMALL_READ_MEGABYTES,SMALL_READ_REQS,SMALL_READ_SERVICETIME,
        SMALL_SYNC_READ_LATENCY,LARGE_READ_MEGABYTES,LARGE_READ_REQS,LARGE_READ_SERVICETIME,
        SMALL_WRITE_MEGABYTES,SMALL_WRITE_REQS,SMALL_WRITE_SERVICETIME,LARGE_WRITE_MEGABYTES,LARGE_WRITE_REQS,LARGE_WRITE_SERVICETIME,interval,file_no,SMALL_SYNC_READ_REQS
	from
	(
	select f.inst_id as inst_id,t.name as tbs,SMALL_READ_MEGABYTES,SMALL_READ_REQS,SMALL_READ_SERVICETIME,
	SMALL_SYNC_READ_LATENCY,LARGE_READ_MEGABYTES,LARGE_READ_REQS,LARGE_READ_SERVICETIME,
	SMALL_WRITE_MEGABYTES,SMALL_WRITE_REQS,SMALL_WRITE_SERVICETIME,LARGE_WRITE_MEGABYTES,LARGE_WRITE_REQS,LARGE_WRITE_SERVICETIME,$interval as interval,file_no,SMALL_SYNC_READ_REQS 
	from GV\$IOSTAT_FILE f,gv\$tablespace t, gv\$datafile d 
	where f.inst_id=t.inst_id
	and d.inst_id=f.inst_id
	and d.file#=f.file_no
	and d.ts#=t.ts#
	and f.filetype_name='Data File'
	union all
        select f.inst_id,t.name as tbs,SMALL_READ_MEGABYTES,SMALL_READ_REQS,SMALL_READ_SERVICETIME,
        SMALL_SYNC_READ_LATENCY,LARGE_READ_MEGABYTES,LARGE_READ_REQS,LARGE_READ_SERVICETIME,
        SMALL_WRITE_MEGABYTES,SMALL_WRITE_REQS,SMALL_WRITE_SERVICETIME,LARGE_WRITE_MEGABYTES,LARGE_WRITE_REQS,LARGE_WRITE_SERVICETIME,$interval as interval,file_no,SMALL_SYNC_READ_REQS
        from GV\$IOSTAT_FILE f,gv\$tablespace t, gv\$tempfile d
        where f.inst_id=t.inst_id
        and d.inst_id=f.inst_id
        and d.file#=f.file_no
        and d.ts#=t.ts#
	and f.filetype_name='Temp File'
	) where 1=1 
        ";
	}
        $pkeys{0}='%30s';
        $pkeys{1}='%100s';
        $pkeys{16}='%100s';
	# What need to be show
        my @show_fields = split (/,/,$show_pattern);
        foreach my $show (@show_fields) {
	if ($show =~ m/^inst$/i ){ 
	# group by instance
	$array_of_ckeys_description[$ckey_cpt]{0}='%30s'; 	
	$array_of_ckeys_description[$ckey_cpt]{15}='%10s';
	$array_of_display_keys[$ckey_cpt]{0}='y'; 
	$array_of_display_keys[$ckey_cpt]{15}='y';
	$ckey_cpt=$ckey_cpt+1; 
	}
        if ($show =~ m/^file_type_tbs$/i ){
	# group by filetype or tbs
	$array_of_ckeys_description[$ckey_cpt]{15}='%10s';
	$array_of_display_keys[$ckey_cpt]{15}='y';
	if (grep (/^inst$/i,@show_fields)) {
	$array_of_ckeys_description[$ckey_cpt]{0}='%30s';
	$array_of_display_keys[$ckey_cpt]{0}='y';
	}
        $array_of_ckeys_description[$ckey_cpt]{1}='%100s';
        $array_of_display_keys[$ckey_cpt]{1}='y';
	$ckey_cpt=$ckey_cpt+1; 
        }
	}
        @delta_fields=(2,3,4,5,6,7,8,9,10,11,12,13,14,17);
	if ($io_type_pattern =~ m/^reads$/i ){
	$report_format_values="%02d:%02d:%02d %1s %-10s %1s %-28s %1s %-7.0f %1s %-7.0f %1s %-7.0f %1s %-7.0f %1s %-7.3f %1s %-7.2f %1s %-7.2f %1s %-7.2f\n";
	@report_fields_values=(1,"2/15","3/15","6/15","7/15","2/3","6/7","4/3","8/7");
	@array_of_report_header=(["%02d:%02d:%02d %43s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','','SMALL R','','SMALL R','','LARGE R','','LARGE R','','Avg MB/','','Avg MB/','','Avg ms/','','Avg ms/'],["%02d:%02d:%02d %1s %-10s %1s %-28s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','INST','','FILE_TYPE_TBS','','MB/s','','RQ/s','','MB/s','','RQ/s','','SMALL R','','LARGE R','','SMALL R','','LARGE R'],["%02d:%02d:%02d %1s %-10s %1s %-28s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','----------','','----------------------------','','-------','','-------','','-------','','-------','','-------','','-------','','-------','','-------']);
	}
	if ($io_type_pattern =~ m/^writes$/i ){
	$report_format_values="%02d:%02d:%02d %1s %-10s %1s %-28s %1s %-7.0f %1s %-7.0f %1s %-7.0f %1s %-7.0f %1s %-7.3f %1s %-7.2f %1s %-7.2f %1s %-7.2f\n";
	@report_fields_values=(1,"9/15","10/15","12/15","13/15","9/10","12/13","11/10","14/13");
	@array_of_report_header=(["%02d:%02d:%02d %43s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','','SMALL W','','SMALL W','','LARGE W','','LARGE W','','Avg MB/','','Avg MB/','','Avg ms/','','Avg ms/'],["%02d:%02d:%02d %1s %-10s %1s %-28s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','INST','','FILE_TYPE_TBS','','MB/s','','RQ/s','','MB/s','','RQ/s','','SMALL W','','LARGE W','','SMALL W','','LARGE W'],["%02d:%02d:%02d %1s %-10s %1s %-28s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','----------','','----------------------------','','-------','','-------','','-------','','-------','','-------','','-------','','-------','','-------']);
	}
	if ($io_type_pattern =~ m/^small$/i ){
	$report_format_values="%02d:%02d:%02d %1s %-10s %1s %-28s %1s %-7.0f %1s %-7.0f %1s %-7.0f %1s %-7.0f %1s %-7.3f %1s %-7.3f %1s %-7.2f %1s %-7.2f\n";
	@report_fields_values=(1,"2/15","3/15","9/15","10/15","2/3","9/10","4/3","11/10");
	@array_of_report_header=(["%02d:%02d:%02d %43s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','','SMALL R','','SMALL R','','SMALL W','','SMALL W','','Avg MB/','','Avg MB/','','Avg ms/','','Avg ms/'],["%02d:%02d:%02d %1s %-10s %1s %-28s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','INST','','FILE_TYPE_TBS','','MB/s','','RQ/s','','MB/s','','RQ/s','','SMALL R','','SMALL W','','SMALL R','','SMALL W'],["%02d:%02d:%02d %1s %-10s %1s %-28s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','----------','','----------------------------','','-------','','-------','','-------','','-------','','-------','','-------','','-------','','-------']);
	}
	if ($io_type_pattern =~ m/^large$/i ){
	$report_format_values="%02d:%02d:%02d %1s %-10s %1s %-28s %1s %-7.0f %1s %-7.0f %1s %-7.0f %1s %-7.0f %1s %-7.2f %1s %-7.2f %1s %-7.2f %1s %-7.2f\n";
	@report_fields_values=(1,"6/15","7/15","12/15","13/15","6/7","12/13","8/7","14/13");
	@array_of_report_header=(["%02d:%02d:%02d %43s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','','LARGE R','','LARGE R','','LARGE W','','LARGE W','','Avg MB/','','Avg MB/','','Avg ms/','','Avg ms/'],["%02d:%02d:%02d %1s %-10s %1s %-28s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','INST','','FILE_TYPE_TBS','','MB/s','','RQ/s','','MB/s','','RQ/s','','LARGE R','','LARGE W','','LARGE R','','LARGE W'],["%02d:%02d:%02d %1s %-10s %1s %-28s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','----------','','----------------------------','','-------','','-------','','-------','','-------','','-------','','-------','','-------','','-------']);
	}
        if ($io_type_pattern =~ m/^synch$/i ){
        $report_format_values="%02d:%02d:%02d %1s %-10s %1s %-28s %1s %-7.0f %6s %-7.2f\n";
        @report_fields_values=(1,"17/15","5/17");
        @array_of_report_header=(["%02d:%02d:%02d %43s %1s %-12s %1s %-12s\n",'','','Sync SMALL R','','Avg ms/'],["%02d:%02d:%02d %1s %-10s %1s %-28s %1s %-12s %1s %-12s\n",'','INST','','FILE_TYPE_TBS','','RQ/s','','Sync SMALL R'],["%02d:%02d:%02d %1s %-10s %1s %-28s %1s %-12s %1s %-12s\n",'','----------','','----------------------------','','------------','','------------']);
        }
	} else {
	#There is pdbs
	$sort_fields{8}='LARGE_READS';
	$sort_fields{14}='LARGE_WRITES';
	$sort_fields{16}='NONE';
	$sort_fields{4}='SMALL_READS';
	$sort_fields{11}='SMALL_WRITES';
	%sort_fields = reverse %sort_fields;
	if (!$sort_field_pattern) {$sort_field_pattern='NONE'};
        if ($file_type_tbs_pattern =~ m/^file_type$/i ){
	# show file_type instead of tbs
	$sql_patterns{'c.name'}=$cont_pattern;
	$sql_patterns{'FILETYPE_NAME'}=$file_type_pattern;
	$instid_pattern="f.inst_id";
        $main_sql="
	select f.inst_id,c.name,FILETYPE_NAME,SMALL_READ_MEGABYTES,SMALL_READ_REQS,SMALL_READ_SERVICETIME,SMALL_SYNC_READ_LATENCY,LARGE_READ_MEGABYTES,LARGE_READ_REQS,LARGE_READ_SERVICETIME,SMALL_WRITE_MEGABYTES,SMALL_WRITE_REQS,SMALL_WRITE_SERVICETIME,LARGE_WRITE_MEGABYTES,LARGE_WRITE_REQS,LARGE_WRITE_SERVICETIME,$interval,file_no,SMALL_SYNC_READ_REQS 
	from GV\$IOSTAT_FILE f, gv\$containers c
	where f.inst_id=c.inst_id and f.con_id=c.con_id
	and c.OPEN_MODE like 'READ%'
	";
	}
        if ($file_type_tbs_pattern =~ m/^tbs$/i ){
	# show tbs instead of file_type
	$sql_patterns{'cont'}=$cont_pattern;
	$sql_patterns{'tbs'}=$tbs_pattern;
	$instid_pattern="inst_id";
        $main_sql="
	select inst_id,cont,TBS,SMALL_READ_MEGABYTES,SMALL_READ_REQS,SMALL_READ_SERVICETIME,SMALL_SYNC_READ_LATENCY,
        LARGE_READ_MEGABYTES,LARGE_READ_REQS,LARGE_READ_SERVICETIME,SMALL_WRITE_MEGABYTES,SMALL_WRITE_REQS,
        SMALL_WRITE_SERVICETIME,LARGE_WRITE_MEGABYTES,LARGE_WRITE_REQS,LARGE_WRITE_SERVICETIME,interval,file_no,SMALL_SYNC_READ_REQS 
	from
	(
	select f.inst_id as inst_id,c.name as cont,t.name as TBS,SMALL_READ_MEGABYTES,SMALL_READ_REQS,SMALL_READ_SERVICETIME,SMALL_SYNC_READ_LATENCY,
	LARGE_READ_MEGABYTES,LARGE_READ_REQS,LARGE_READ_SERVICETIME,SMALL_WRITE_MEGABYTES,SMALL_WRITE_REQS,
	SMALL_WRITE_SERVICETIME,LARGE_WRITE_MEGABYTES,LARGE_WRITE_REQS,LARGE_WRITE_SERVICETIME,$interval as interval,file_no,SMALL_SYNC_READ_REQS
        from 
	GV\$IOSTAT_FILE f, gv\$containers c, gv\$tablespace t, gv\$datafile d
	where
	f.inst_id=c.inst_id
	and c.con_id=f.con_id
	and d.inst_id=c.inst_id
	and t.inst_id=c.inst_id
	and t.con_id=c.con_id
	and d.con_id=c.con_id
	and d.file#=f.file_no
	and d.ts#=t.ts#
	and f.filetype_name='Data File'
	and c.OPEN_MODE like 'READ%'
	union all
	select f.inst_id as inst_id,c.name as cont,t.name as TBS,SMALL_READ_MEGABYTES,SMALL_READ_REQS,SMALL_READ_SERVICETIME,SMALL_SYNC_READ_LATENCY,
	LARGE_READ_MEGABYTES,LARGE_READ_REQS,LARGE_READ_SERVICETIME,SMALL_WRITE_MEGABYTES,SMALL_WRITE_REQS,
	SMALL_WRITE_SERVICETIME,LARGE_WRITE_MEGABYTES,LARGE_WRITE_REQS,LARGE_WRITE_SERVICETIME,$interval as interval,file_no,SMALL_SYNC_READ_REQS
        from
        GV\$IOSTAT_FILE f, gv\$containers c, gv\$tablespace t, gv\$tempfile d
        where
        f.inst_id=c.inst_id
        and c.con_id=f.con_id
        and d.inst_id=c.inst_id
        and t.inst_id=c.inst_id
        and t.con_id=c.con_id
        and d.con_id=c.con_id
        and d.file#=f.file_no
        and d.ts#=t.ts#
	and f.filetype_name='Temp File'
	and c.OPEN_MODE like 'READ%'
	) where 1=1 
	";
	}
        $pkeys{0}='%30s';
        $pkeys{1}='%80s';
        $pkeys{2}='%100s';
        $pkeys{17}='%100s';
	# What need to be show
        my @show_fields = split (/,/,$show_pattern);
        foreach my $show (@show_fields) {
	if ($show =~ m/^inst$/i ){ 
	# group by instance
	$array_of_ckeys_description[$ckey_cpt]{0}='%30s'; 	
	$array_of_ckeys_description[$ckey_cpt]{16}='%10s';
	$array_of_display_keys[$ckey_cpt]{0}='y'; 
	$array_of_display_keys[$ckey_cpt]{16}='y';
	$ckey_cpt=$ckey_cpt+1; 
	}
        if ($show =~ m/^cont$/i ){
	# group by container
	$array_of_ckeys_description[$ckey_cpt]{16}='%10s';
	$array_of_display_keys[$ckey_cpt]{16}='y';
	if (grep (/^inst$/i,@show_fields)) {
	$array_of_ckeys_description[$ckey_cpt]{0}='%30s';
	$array_of_display_keys[$ckey_cpt]{0}='y';
	}
        $array_of_ckeys_description[$ckey_cpt]{1}='%100s';
        $array_of_display_keys[$ckey_cpt]{1}='y';
	$ckey_cpt=$ckey_cpt+1; 
        }
	if ($show =~ m/^file_type_tbs/i ){
	# group by file_type or tbs
	$array_of_ckeys_description[$ckey_cpt]{16}='%10s';
        $array_of_display_keys[$ckey_cpt]{16}='y';
        if (grep (/^inst$/i,@show_fields)) {
        $array_of_ckeys_description[$ckey_cpt]{0}='%30s';
        $array_of_display_keys[$ckey_cpt]{0}='y';
        }
	if (grep (/^cont/i,@show_fields)) {
        $array_of_ckeys_description[$ckey_cpt]{1}='%100s';
        $array_of_display_keys[$ckey_cpt]{1}='y';
        }
        $array_of_ckeys_description[$ckey_cpt]{2}='%100s';
        $array_of_display_keys[$ckey_cpt]{2}='y';
        $ckey_cpt=$ckey_cpt+1;
        }
	}
        @delta_fields=(3,4,5,6,7,8,9,10,11,12,13,14,15,18);
	if ($io_type_pattern =~ m/^reads$/i ){
	$report_format_values="%02d:%02d:%02d %1s %-10s %1s %-15s %1s %-28s %1s %-7.0f %1s %-7.0f %1s %-7.0f %1s %-7.0f %1s %-7.3f %1s %-7.2f %1s %-7.2f %1s %-7.2f\n";
	@report_fields_values=(1,2,"3/16","4/16","7/16","8/16","3/4","7/8","5/4","9/8");
	@array_of_report_header=(["%02d:%02d:%02d %61s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','','SMALL R','','SMALL R','','LARGE R','','LARGE R','','Avg MB/','','Avg MB/','','Avg ms/','','Avg ms/'],["%02d:%02d:%02d %1s %-10s %1s %-15s %1s %-28s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','INST','','CONT','','FILE_TYPE_TBS','','MB/s','','RQ/s','','MB/s','','RQ/s','','SMALL R','','LARGE R','','SMALL R','','LARGE R'],["%02d:%02d:%02d %1s %-10s %1s %-15s %1s %-28s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','----------','','---------------','','----------------------------','','-------','','-------','','-------','','-------','','-------','','-------','','-------','','-------']);
	}
	if ($io_type_pattern =~ m/^writes$/i ){
        $report_format_values="%02d:%02d:%02d %1s %-10s %1s %-15s %1s %-28s %1s %-7.0f %1s %-7.0f %1s %-7.0f %1s %-7.0f %1s %-7.3f %1s %-7.2f %1s %-7.2f %1s %-7.2f\n";
        @report_fields_values=(1,2,"10/16","11/16","13/16","14/16","10/11","13/14","12/11","15/14");
        @array_of_report_header=(["%02d:%02d:%02d %61s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','','SMALL W','','SMALL W','','LARGE W','','LARGE W','','Avg MB/','','Avg MB/','','Avg ms/','','Avg ms/'],["%02d:%02d:%02d %1s %-10s %1s %-15s %1s %-28s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','INST','','CONT','','FILE_TYPE_TBS','','MB/s','','RQ/s','','MB/s','','RQ/s','','SMALL W','','LARGE W','','SMALL W','','LARGE W'],["%02d:%02d:%02d %1s %-10s %1s %-15s %1s %-28s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','----------','','---------------','','----------------------------','','-------','','-------','','-------','','-------','','-------','','-------','','-------','','-------']);
	}
	if ($io_type_pattern =~ m/^small$/i ){
	$report_format_values="%02d:%02d:%02d %1s %-10s %1s %-15s %1s %-28s %1s %-7.0f %1s %-7.0f %1s %-7.0f %1s %-7.0f %1s %-7.3f %1s %-7.3f %1s %-7.2f %1s %-7.2f\n";
	@report_fields_values=(1,2,"3/16","4/16","10/16","11/16","3/4","10/11","5/4","12/11");
	@array_of_report_header=(["%02d:%02d:%02d %61s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','','SMALL R','','SMALL R','','SMALL W','','SMALL W','','Avg MB/','','Avg MB/','','Avg ms/','','Avg ms/'],["%02d:%02d:%02d %1s %-10s %1s %-15s %1s %-28s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','INST','','CONT','','FILE_TYPE_TBS','','MB/s','','RQ/s','','MB/s','','RQ/s','','SMALL R','','SMALL W','','SMALL R','','SMALL W'],["%02d:%02d:%02d %1s %-10s %1s %-15s %1s %-28s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','----------','','---------------','','----------------------------','','-------','','-------','','-------','','-------','','-------','','-------','','-------','','-------']);
	}
	if ($io_type_pattern =~ m/^large$/i ){
	$report_format_values="%02d:%02d:%02d %1s %-10s %1s %-15s %1s %-28s %1s %-7.0f %1s %-7.0f %1s %-7.0f %1s %-7.0f %1s %-7.2f %1s %-7.2f %1s %-7.2f %1s %-7.2f\n";
	@report_fields_values=(1,2,"7/16","8/16","13/16","14/16","7/8","13/14","9/8","15/14");
	@array_of_report_header=(["%02d:%02d:%02d %61s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','','LARGE R','','LARGE R','','LARGE W','','LARGE W','','Avg MB/','','Avg MB/','','Avg ms/','','Avg ms/'],["%02d:%02d:%02d %1s %-10s %1s %-15s %1s %-28s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','INST','','CONT','','FILE_TYPE_TBS','','MB/s','','RQ/s','','MB/s','','RQ/s','','LARGE R','','LARGE W','','LARGE R','','LARGE W'],["%02d:%02d:%02d %1s %-10s %1s %-15s %1s %-28s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s %1s %-7s\n",'','----------','','---------------','','----------------------------','','-------','','-------','','-------','','-------','','-------','','-------','','-------','','-------']);
	}
	if ($io_type_pattern =~ m/^synch$/i ){
        $report_format_values="%02d:%02d:%02d %1s %-10s %1s %-15s %1s %-28s %1s %-7.0f %6s %-7.2f\n";
        @report_fields_values=(1,2,"18/16","6/18");
        @array_of_report_header=(["%02d:%02d:%02d %61s %1s %-12s %1s %-12s\n",'','','Sync SMALL R','','Avg ms/'],["%02d:%02d:%02d %1s %-10s %1s %-15s %1s %-28s %1s %-12s %1s %-12s\n",'','INST','','CONT','','FILE_TYPE_TBS','','RQ/s','','Sync SMALL R'],["%02d:%02d:%02d %1s %-10s %1s %-15s %1s %-28s %1s %-12s %1s %-12s\n",'','----------','','---------------','','----------------------------','','------------','','------------']);
        }
	}
        &go_sql_real_time;
}

#
# Ctrl+C signal
#
$SIG{INT}= \&close;

sub close {
        print "Disconnecting from RDBMS...\n";
        $sql1->finish;
        $dbh->disconnect();
        exit 0;
}

sub minimum_version {
        print "RDBMS version < 11.1\n";
        print "Disconnecting from RDBMS...\n";
        $dbh->disconnect();
        exit 0;
}

sub get_the_options {
    my $help; 
    GetOptions('help|h' => \$help,
		'interval=i'=>\$interval,
		'count=i'=>\$count,
		'inst:s' => \$instpattern,
		'sort_field:s' => \$sort_field_pattern,
		'file_type_tbs:s' => \$file_type_tbs_pattern,
		'file_type:s' => \$file_type_pattern,
		'tbs:s' => \$tbs_pattern,
		'io_type:s' => \$io_type_pattern,
		'cont:s' => \$cont_pattern,
		'display:s' => \$display_pattern,
		'show:s' => \$show_pattern) or &usage();

    &usage() if ($help); 
}

sub go_sql_real_time {
&connect_db;
&check_instance_type($inst_type);
&check_rac;
&build_instances;
&build_rac_pattern;
&build_glob_sql_pattern;
&build_glob_sql;
&initialise_arrays;
&launch_loop;
}

sub connect_db {
$dbh = DBI->connect('dbi:Oracle:',"", "", { ora_session_mode => ORA_SYSDBA });
}
 
sub check_instance_type {
my $inst_type=$_[0];
debug("Instance Type: ".$inst_type);
my $sql1 = $dbh->prepare('select value from v$parameter where name=\'instance_type\' ');
$sql1->execute;

if ( $sql1->fetchrow_array =~ /$inst_type/i) {
        $sql1->finish;
}
else {
        print "\n\n ERROR : You must connect to a ".$inst_type." instance \n\n";
        $sql1->finish;
        $dbh->disconnect();
        exit 1;
}
}

sub check_rac {
my $sql1 = $dbh->prepare('select value  from v$parameter where name = \'cluster_database\'');
$sql1->execute;
if ( $sql1->fetchrow_array =~ /true/i) {
   $rac=1;
}
$sql1->finish;
}

sub check_version {
my $sql1 = $dbh->prepare('select regexp_replace(version,\'\..*\') from v$instance');
$sql1->execute;
return ($sql1->fetchrow_array);
$sql1->finish;
}

sub check_pdbs {
my $sql1 = $dbh->prepare('select count(*) from v$pdbs');
$sql1->execute;
return ($sql1->fetchrow_array);
$sql1->finish;
}

sub build_instances {
my $sql1 = $dbh->prepare('select inst_id,instance_name, host_name from gv$instance');
$sql1->execute;
while ( my ($instid, $instname,$host) = $sql1->fetchrow_array) {
        $instances{$instname} = $instid;
}
$sql1->finish;
}

sub build_in_pattern {
 my $pattern=shift;
 my $column=shift;
 my %list_of_field=@_; 
 my %reverse_list_of_field = reverse %list_of_field;
 my @fields = split (/,/,$pattern);
 my $output_in_pattern=''; 	
 foreach my $field (@fields) {
        if (!exists  $reverse_list_of_field{uc($field)}) {
         print "\n\n ERROR : $field $column is not found !! \n";
         exit 1;
	} else {
	if (!$output_in_pattern) {
	$output_in_pattern=" and $column in ('"."$reverse_list_of_field{uc($field)}'";
	} else {
	$output_in_pattern=$output_in_pattern.",'$reverse_list_of_field{uc($field)}'";
	}
	}
 }
	($output_in_pattern)?$output_in_pattern=$output_in_pattern.")":"";
	return $output_in_pattern;
}

sub build_rac_pattern
{
if ($rac & ! ($instpattern =~ /all|current/i)) {
        my @fields = split (/,/,$instpattern);

        foreach my $instname (@fields) {

        if (!exists  $instances{uc($instname)}) {
              print "\n\n ERROR : The instance $instname is not found !! \n";
              $dbh->disconnect();
              exit 1;
        } else {
           $showinstances{$instname}=$instances{$instname};;
        }
        }
}

# If not rac put pattern as current

if (! $rac) {
$instpattern = 'current';
}

if ($instpattern =~ /current/i) {

my $sql1_sql = "select inst_id,instance_name, host_name from gv\$instance where inst_id = userenv('instance')";

my $sql1 = $dbh->prepare($sql1_sql);
$sql1->execute;
while ( my ($instid, $instname,$host) = $sql1->fetchrow_array) {
        $instances{$instname} = $instid;
}
$sql1->finish;
}

if (($rac & ($instpattern =~ /all|current/i)) | (! $rac & ($instpattern =~ /current/i))) {
        %showinstances = %instances;
}

# RAC : Create the SQL suffixe based on the instances to request on

# Case 1 : The current instance or list of instances
$sqlsuffixe = ((! $rac)  | ($rac & $instpattern =~ /current/i) ? " and ".$instid_pattern. " = userenv('instance')" : "");

# Case 2 : All the instances
# Nothing to do

if ($rac & ! ($instpattern =~ /all|current/i)) {

        foreach my $inst (keys %showinstances) {

        my $inst_id = $showinstances{$inst};

        if ($sqlsuffixe) {
        $sqlsuffixe = $sqlsuffixe." or ".$instid_pattern. " = $inst_id";
                }
        else
                {
        $sqlsuffixe = $sqlsuffixe." and (".$instid_pattern. " = $inst_id";
                }
        }
        $sqlsuffixe = $sqlsuffixe.")";

}
debug("sqlsuffixe: ".$sqlsuffixe);
# Reverse the hash for display usage (Report Section)
%showinstances = reverse %showinstances;
}

sub build_glob_sql_pattern {

	foreach my $column (keys %sql_patterns) {
	debug("column: ".$column);
	debug("pattern: ".$sql_patterns{$column});
	if ($sql_patterns{$column}) {$global_sql_pattern = $global_sql_pattern." and ".$column." like '".$sql_patterns{$column}."' "}
	}
	debug("global_sql_pattern: ".$global_sql_pattern);
}

sub build_glob_sql {
	$main_sql = $main_sql.$global_sql_pattern.$sqlsuffixe; 
	debug("Main sql: ".$main_sql);
}

sub build_the_key {
	my @tab1 = @_;
	$bkey='';
	@ekey=();
	foreach my $id (sort { $a <=> $b }(keys %pkeys)) {
	if ($bkey) {$bkey = $bkey.".".$pkeys{$id}};
	if (!$bkey) {$bkey = $pkeys{$id}};
	push(@ekey,$tab1[$id]);
	}
}

sub build_compute_key {
        my @tab1 = @_;
 	for my $i ( 0 .. $#array_of_ckeys_description ) {
        	my $bckey='';
        	my @eckey=();
    		for my $j ( sort { $a <=> $b } (keys %{ $array_of_ckeys_description[$i] }) ) {
		($bckey)?($bckey = $bckey.".".$array_of_ckeys_description[$i]{$j}):($bckey = $array_of_ckeys_description[$i]{$j});
		push(@eckey,$tab1[$j]);
    		}
	my $ckey = sprintf($bckey,@eckey);
	$array_of_ckey[$i]=$ckey;
	}	
}

sub initialise_arrays { 
	$sql1 = $dbh->prepare($main_sql);
	my $key;
	$sql1->execute;
	while ( my @tab1 = $sql1->fetchrow_array) {
	&build_the_key(@tab1); 
	$key = sprintf($bkey,@ekey);
	@{$rtvalues{$key}}=@tab1;
	@{$diffsnaps{$key}}=@tab1;
	debug("key is : ".$key);
	}
}

sub launch_loop {
	my $key;
	my $ckey;
	my $cpt=0;
	for (my $nb=0;$nb < $count;$nb++) {
	print "............................\n";
	print "Collecting $interval sec....\n";
	print "............................\n";
	sleep $interval;
	$sql1->execute;
	($seconds, $minuts, $hours) = localtime(time);

	# Keep the first timing for the average section
        ($cpt==0)?(@since_timing=($hours,$minuts,$seconds)):"";

	# Empty diffsnaps
	%diffsnaps = ();
	while ( my @tab1 = $sql1->fetchrow_array) {
	&build_the_key(@tab1);
	$key = sprintf($bkey,@ekey);

	# Build the compute key

	&build_compute_key(@tab1);

	# Initialise non delta fields
	for (my $tabid=0;$tabid < scalar(@tab1);$tabid++) {
 	for my $i ( 0 .. $#array_of_ckeys_description ) {
	my $ckey=$array_of_ckey[$i];
	$diffsnaps{$ckey}->[$tabid]=($array_of_display_keys[$i]{$tabid}?"$tab1[$tabid]":"") unless (grep (/^$tabid$/,@delta_fields));
	$avgdiffsnaps{$ckey}->[$tabid]=($array_of_display_keys[$i]{$tabid}?"$tab1[$tabid]":"") unless (grep (/^$tabid$/,@delta_fields));
	debug("Non delta fields: for display_keys $array_of_display_keys[$i]{$tabid} and tabid $tabid ".$diffsnaps{$ckey}->[$tabid]);
	}
	}
 
	# get the list of delta fields
        foreach my $deltaid (@delta_fields) {
 	for my $i ( 0 .. $#array_of_ckeys_description ) {
	my $ckey=$array_of_ckey[$i];
        debug("deltaid : ".$deltaid);
        debug("key is : ".$key);
        debug("ckey during diff is : ".$ckey);
        $diffsnaps{$ckey}->[$deltaid] = $diffsnaps{$ckey}->[$deltaid] + $tab1[$deltaid] - $rtvalues{$key}->[$deltaid];
        debug("Previous : ".$rtvalues{$key}->[$deltaid]);
        debug("Current : ".$tab1[$deltaid]);
        debug("Diff is : ".$diffsnaps{$ckey}->[$deltaid]);
	}
        }
        @{$rtvalues{$key}} = @tab1;
        debug("key is : ".$key);
        debug("ckey is : ".$ckey);
        }	

        # compute the average since the collection began
       
	foreach my $deltaid (@delta_fields) {
	foreach my $diffkey  (keys %diffsnaps){
	$avgdiffsnaps{$diffkey}->[$deltaid] = (($avgdiffsnaps{$diffkey}->[$deltaid] * $cpt) + $diffsnaps{$diffkey}->[$deltaid]) / ($cpt+1); 
	} 
	}
	$cpt=$cpt+1;
	# Report now for snaps
	(grep (/snap/i,$display_pattern))?(print "\n"):"";
	(grep (/snap/i,$display_pattern))?(print "......... SNAP TAKEN AT ...................\n"):"";
	(grep (/snap/i,$display_pattern))?(print "\n"):"";
	(grep (/snap/i,$display_pattern))?(&report_header("snap",@array_of_report_header)):"";
	(grep (/snap/i,$display_pattern))?(&report_values("snap",%diffsnaps)):"";
	# Report now for average
	(grep (/avg/i,$display_pattern))?(print "\n"):"";
	(grep (/avg/i,$display_pattern))?(print "......... AVERAGE SINCE ...................\n"):"";
	(grep (/avg/i,$display_pattern))?(print "\n"):"";
	(grep (/avg/i,$display_pattern))?(&report_header("avg",@array_of_report_header)):"";
	(grep (/avg/i,$display_pattern))?(&report_values("avg",%avgdiffsnaps)):"";
	}
}

sub report_header {
	my $display_date = shift;
	my @array_of_report_header = @_;
	foreach my $report_ligne (0..@array_of_report_header-1) {
		my @header;
		@header = ($display_date eq "avg")?(@since_timing):($hours,$minuts,$seconds);
		foreach my $report_column (1..@{$array_of_report_header[$report_ligne]}) {
	        push(@header,$array_of_report_header[$report_ligne][$report_column]);
		}
		printf ($array_of_report_header[$report_ligne][0],@header);
	}
}

sub report_resultset {

	my $display_date = shift;
	my $pk=shift;
	my %resultset=@_;
	my $backup_mult;

	my @values; 
	@values = ($display_date eq "avg")?(@since_timing):($hours,$minuts,$seconds);

	if (%showinstances) {push(@values,'',$showinstances{$resultset{$pk}->[0]})};

	foreach my $id (@report_fields_values) {

	push(@values,'');

	my @need_div=split(/\//,$id);
	my @need_mult=split(/\*/,$id);

	if (@need_mult > 1) {
	$need_mult[1] =~ s/\/.*//;
	$backup_mult = $resultset{$pk}->[$need_mult[0]];
	$resultset{$pk}->[$need_mult[0]] = ($resultset{$pk}->[$need_mult[0]]) * $need_mult[1];
	debug("Mult is needed for id : ".$id);
	debug("Mult[0] is : ".$need_mult[0]);
	debug("Mult[1] is : ".$need_mult[1]);
	} 

	if (@need_div > 1) {
	$need_div[0] =~ s/\*.*//;
	debug("Div is needed for id : ".$id);
	debug("needed_div is : ".@need_div);
	debug("div[0] is : ".$need_div[0]);
	debug("div[1] is : ".$need_div[1]);
	if ($resultset{$pk}->[$need_div[1]] > 0) {push(@values,$resultset{$pk}->[$need_div[0]]/$resultset{$pk}->[$need_div[1]])};
	if ($resultset{$pk}->[$need_div[1]] == 0) {push(@values,0)};
	}
	else
	{
	push(@values,$resultset{$pk}->[$id]);
	}
	# In case the resultset has been changed, then put the value back (For the average..)
	if (@need_mult > 1) {
        $resultset{$pk}->[$need_mult[0]] = $backup_mult;
	}	
	}
	printf ($report_format_values,@values);
}

sub report_values {
	my $nb =1;
	my %resultset = ();
	my $display_date = shift;
	my %display_what = @_;
	my $rank = 1;
	my %ranked_instances = ();
	# rank the instance based on the sort field

	foreach my $pk (sort {$display_what{$b}[$sort_fields{uc($sort_field_pattern)}] <=> $display_what{$a}[$sort_fields{uc($sort_field_pattern)}] || $display_what{$a}[0] <=> $display_what{$b}[0]} (keys(%display_what))) {
	if (!(exists $ranked_instances{$display_what{$pk}[0]})) {
	$ranked_instances{$display_what{$pk}[0]}=$rank;
	$display_what{$pk}->[99] = $rank;
	$rank++;
	} else {
	$display_what{$pk}->[99] = $ranked_instances{$display_what{$pk}[0]};
	}
	debug("Rank is ".$display_what{$pk}->[99]." for instance ".$display_what{$pk}[0]);
	}


	if ($nb_pdbs == 0) {

	foreach my $pk (sort {$display_what{$a}[99] <=> $display_what{$b}[99] || $display_what{$b}[$sort_fields{uc($sort_field_pattern)}] <=> $display_what{$a}[$sort_fields{uc($sort_field_pattern)}] || $display_what{$a}[1] cmp $display_what{$b}[1]} (keys(%display_what))) {
	&report_resultset($display_date,$pk,%display_what);
	debug("Sorted value is : ".$display_what{$pk}[$sort_fields{uc($sort_field_pattern)}]);
	}
	} else {
	foreach my $pk (sort {$display_what{$a}[99] <=> $display_what{$b}[99] || $display_what{$b}[$sort_fields{uc($sort_field_pattern)}] <=> $display_what{$a}[$sort_fields{uc($sort_field_pattern)}] || $display_what{$a}[1] cmp $display_what{$b}[1] || $display_what{$a}[2] cmp $display_what{$b}[2]} (keys(%display_what))) {
	&report_resultset($display_date,$pk,%display_what);
	debug("Sorted value is : ".$display_what{$pk}[$sort_fields{uc($sort_field_pattern)}]);
	}
	}
}


sub usage {
&usage_db_io_type_metrics();
}


sub usage_db_io_type_metrics {

&connect_db;
$version=check_version();
if ($version >= 12) {$nb_pdbs=check_pdbs()};
	
if ($nb_pdbs == 0) {
print " \nUsage: $0 [-interval] [-count] [-inst] [-file_type_tbs] [-io_type] [-file_type] [-tbs] [-show] [-display] [-sort_field] [-help]\n";
} else {
print " \nUsage: $0 [-interval] [-count] [-inst] [-cont] [-file_type_tbs] [-io_type] [-file_type] [-tbs] [-show] [-display] [-sort_field] [-help]\n";
}
print "\n";
print " Default Interval : 1 second.\n";
print " Default Count    : Unlimited\n\n";
printf ("  %-15s   %-75s %-10s \n",'Parameter','Comment','Default');
printf ("  %-15s   %-75s %-10s \n",'---------','-------','-------');
printf ("  %-15s   %-75s %-10s \n",'-INST=','ALL - Show all Instance(s) ','ALL');
printf ("  %-15s   %-75s %-10s \n",'','CURRENT - Show Current Instance ','');
if ($nb_pdbs > 0) {
printf ("  %-15s   %-75s %-10s \n",'-CONT=','Container to collect (wildcard allowed)','ALL');
}
printf ("  %-15s   %-75s %-10s \n",'-FILE_TYPE_TBS=','Collect on File Type or on Tablespace: file_type,tbs','FILE_TYPE');
printf ("  %-15s   %-75s %-10s \n",'-IO_TYPE=','IO Type to collect: reads,writes,small,large,synch','READS');
printf ("  %-15s   %-75s %-10s \n",'-FILE_TYPE=','File Type to collect (in case FILE_TYPE_TBS=file_type) (wildcard allowed)','NONE');
printf ("  %-15s   %-75s %-10s \n",'-TBS=','Tablespace to collect (in case FILE_TYPE_TBS=tbs) (wildcard allowed)','NONE');
if ($nb_pdbs == 0) {
printf ("  %-15s   %-75s %-10s \n",'-SHOW=','What to show: inst,file_type (comma separated list)','INST');
} else {
printf ("  %-15s   %-75s %-10s \n",'-SHOW=','What to show: inst,cont,file_type_tbs (comma separated list)','INST');
}
printf ("  %-15s   %-75s %-10s \n",'-DISPLAY=','What to display: snap,avg (comma separated list)','SNAP');
printf ("  %-15s   %-75s %-10s \n",'-SORT_FIELD=','small_reads,small_writes,large_reads,large_writes','NONE');
print ("\n");
print ("Example: $0 \n");
print ("Example: $0  -inst=CBDT1\n");
print ("Example: $0  -show=inst,file_type_tbs\n");
print ("Example: $0  -show=inst,file_type_tbs -file_type=%Data%\n");
print ("Example: $0  -show=inst -io_type=large\n");
print ("Example: $0  -show=inst -io_type=small -sort_field=small_reads\n");
print ("Example: $0  -show=inst,file_type_tbs -file_type_tbs=tbs -tbs=%USE%\n");
if ($nb_pdbs > 0) {
print ("Example: $0  -show=inst,cont\n");
print ("Example: $0  -show=inst,cont -cont=%P%\n");
print ("Example: $0  -show=inst,cont,file_type_tbs -io_type=small -sort_field=small_reads\n");
}
print "\n\n";
exit 1;
}

sub debug {
    if ($debug==1) {
        print $_[0]."\n";
    }
}


&main(@ARGV);
