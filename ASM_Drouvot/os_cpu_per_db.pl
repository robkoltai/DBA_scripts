#!/usr/bin/env perl
#
# Bertrand Drouvot
# Visit my blog : http://bdrouvot.wordpress.com/
# os_cpu_per_db.pl : V1.0 (2012/05)
# V1.1 (2012/12): Add Avg, min, max per db and sort_field
# V1.2 (2013/02): Working now on AIX: Thanks to Fuad Arshad and Christophe Reveillere (orachrome)
# V1.3 (2014/10): Changed interval and count order
# Utility used to display top database, os user, commands cpu usage
# Chek for new version : http://bdrouvot.wordpress.com/perl-scripts-2/
#
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

use Time::Local;

#utility function
#
sub convToSecs {
 local($time) = @_;
 $secs = 0;
 @t_array = split(":", $time);
 if(@t_array == 3) {
 ($h,$m,$s) = @t_array;
 $secs = ($h*3600);
 } else {
 ($m, $s) = @t_array;
 }
 $secs += ($m*60)+$s;
 return $secs;
}

@processList = ();
my $key;
my $help=0;
my %ProchashList;
my %diffstats;
my %previousdbmax = ();
my %previousdbmin = ();
my %previousavg = ();
my $interval=1;
my $count=999999;
my $pscomm;
my $dsplayuser="N";
my $dsplaycmd="N";
my $topn=10;
my $nbmatch=-1;
my $sortfield_pattern=0;
my $trsh;
my $comm;
my $tim;

#
# check the parameters line
#
if ($ARGV[0] =~ /^\d+/ ) {
$interval=$ARGV[0];
$nbmatch++;
}

if ($ARGV[1] =~ /^\d+/ ) {
$count=$ARGV[1];
$nbmatch++;
}

foreach my $para (@ARGV) {

if ( $para =~ m/^help.*/i ) {
 $nbmatch++;
 $help=1;
 }

if ( $para =~ m/^displayuser=(Y|N)/i ) {
 $nbmatch++;
 $dsplayuser=$1;
 }

if ( $para =~ m/^displaycmd=(Y|N)/i ) {
 $nbmatch++;
 $dsplaycmd=$1;
 }

if ( $para =~ m/^sort_field=(.*)$/i ) {
$sortfield_pattern=$1;
if ($sortfield_pattern =~ m/^CPU_SEC$/i) {$sortfield_pattern=0;$nbmatch++;}
if ($sortfield_pattern =~ m/^AVG_NB_CPU$/i) {$sortfield_pattern=1;$nbmatch++;}
if ($sortfield_pattern =~ m/^MAX_NB_CPU$/i) {$sortfield_pattern=2;$nbmatch++;}
if ($sortfield_pattern =~ m/^MIN_NB_CPU$/i) {$sortfield_pattern=3;$nbmatch++;}
}


if ( $para =~ m/^top=(.*)$/i ) {
 $nbmatch++;
 $topn=$1;
 }
}

$ENV{PATH} = "/usr/bin:/usr/sbin:/bin:/usr/local/bin";

#
## Print usage if a difference exists between parameters checked
##
if ($nbmatch != $#ARGV | $help) {
print "\n Error while processing parameters \n\n" unless ($help);
print " \nUsage: $0 [Interval [Count]] [top=] [sort_field=] [displayuser=[Y|N]] [displaycmd=[Y|N]] \n\n";
print " Default Interval : 1 second.\n";
print " Default Count : Unlimited\n\n";
printf ("%-12s %10s %-60s %10s %-10s \n",'Parameter','','Comment','','Default');
printf ("%-12s %10s %-60s %10s %-10s \n",'---------','','-------','','-------');
printf ("%-12s %10s %-60s %10s %-10s \n",'TOP=','','Number of rows to display','','10');
printf ("%-12s %10s %-60s %10s %-10s \n",'SORT_FIELD=','','CPU_SEC|AVG_NB_CPU|MAX_NB_CPU|MIN_NB_CPU','','CPU_SEC');
printf ("%-12s %10s %-60s %10s %-10s \n",'DISPLAYUSER=','','REPORT ON USER TOO','','N');
printf ("%-12s %10s %-60s %10s %-10s \n",'DISPLAYCMD=','','REPORT ON COMMAND TOO','','N');
print "\n\n";
print "WARNING : AVG_NB_CPU,MAX_NB_CPU & MIN_NB_CPU are computed from all the snaps\n";
print "WARNING : while CPU_SEC and NB_CPU are computed per snap\n";
print "WARNING : Supported OS are Solaris and Linux. Contact me if you need another OS\n";
print "WARNING : You need to put oraenv on one DB\n";
print "\n\n";
exit 0;
}

################################################## Initialise ####################################################

#build the ps command based on os type
#

my $os = $^O;
my $pidkey;
my $cmdkey;
my $timkey;
my $usrkey;
my $splitnumber;

SWITCH: {
 $os eq "solaris" && do {
 $pscomm = "/bin/ps -efo \"pmem, pcpu, time, vsz, rss, user, pid, args\"";
 $pidkey=6;
 $cmdkey=7;
 $timkey=2;
 $splitnumber=8;
 $usrkey=5;
 last SWITCH;
 };
 $os eq "linux" && do {
 $pscomm = "/bin/ps -www -eo \"pmem pcpu time vsz rss user pid args\"";
 $pidkey=6;
 $cmdkey=7;
 $timkey=2;
 $splitnumber=8;
 $usrkey=5;
 last SWITCH;
 };
 $os eq "aix" && do {
 $pscomm = "/usr/bin/ps -eo pmem,pcpu,time,vsz,user,pid,args" or die "Failed to run ps\n";
 $pidkey=5;
 $cmdkey=6;
 $timkey=2;
 $splitnumber=7;
 $usrkey=4;
 last SWITCH;
 };
 die "Unupported Operating System, Contact me if you need it\n";
}

# Go
#
#
@processList = `$pscomm` or die "Failed to run ps\n";
shift @processList;

foreach $process (@processList) {
my @splitproc = split (" ",$process,$splitnumber);

# Build the key based on PID and ARGS
$key = sprintf("%30s.%30s",$splitproc[$pidkey],$splitproc[$cmdkey]);

$splitproc[$timkey]=convToSecs($splitproc[$timkey]);

# Keep only oracle processes mapped to an oracle database

my $db = $splitproc[$cmdkey];

# Now extract db name from commands
$db =~ s/\n//;
$db =~ s/ora_...._//;
$db =~ s/ \(DESCRIPTION=.*//;
$db =~ s/ \(LOCAL=.*//;
$db =~ s/oracle//;
$db =~ s/_.*//;
$db =~ s/.* .*//;
$db =~ s/\+asm/+ASM/;
$db =~ s/asm/+ASM/;
$db =~ s/\+ASM[1-9]*/+ASM/;

my $dbsize = length($db);

# db empty ??

if ($dbsize <= 10 && $dbsize > 1 && ($splitproc[$cmdkey] =~ m/.*ora.*/i || $splitproc[$cmdkey] =~ m/.*asm_.*/i) && $db !~ m/\//) {
# Here is the DB
$splitproc[$splitnumber]=$db;
}

@{$ProchashList{$key}}=@splitproc;
@{$diffstats{$key}}=@splitproc;

}

################################################## Main Loop ####################################################

my ($seconds, $minuts, $hours,$day,$month,$year) = localtime(time);
my $epoch_start=timegm($seconds, $minuts, $hours,$day,$month,$year);

for (my $nb=0;$nb < $count;$nb++) {

# Keep old values to calculate metrics

%diffstats = ();

print "Collecting during $interval seconds......\n";
sleep $interval;

my %dbcputime = ();
my %usercputime = ();
my $previous_epoch_start=$epoch_start;
@processList = `$pscomm` or die "Failed to run ps\n";
shift @processList;
my ($seconds, $minuts, $hours,$day,$month,$year) = localtime(time);
$epoch_start=timegm($seconds, $minuts, $hours,$day,$month,$year);
my $real_interval=$epoch_start-$previous_epoch_start;
#DEBUG print "REAL INTERVAL : $real_interval\n";

foreach $process (@processList) {

#DEBUG print "proc=$process\n";
my @splitproc = split (" ",$process,$splitnumber);

# Build the key based on PID and ARGS
$key = sprintf("%30s.%30s",$splitproc[$pidkey],$splitproc[$cmdkey]);

# Compute cpu diff in seconds

$splitproc[$timkey]=convToSecs($splitproc[$timkey]);

$diffstats{$key}->[$timkey] = $splitproc[$timkey] - $ProchashList{$key}->[$timkey];

# Keep only oracle processes mapped to an oracle database

my $db = $splitproc[$cmdkey];

# Now extract db name from commands
$db =~ s/\n//;
$db =~ s/ora_...._//;
$db =~ s/ \(DESCRIPTION=.*//;
$db =~ s/ \(LOCAL=.*//;
$db =~ s/oracle//;
$db =~ s/_.*//;
$db =~ s/.* .*//;
$db =~ s/\+asm/+ASM/;
$db =~ s/asm/+ASM/;
$db =~ s/\+ASM[1-9]*/+ASM/;



my $dbsize = length($db);

# db empty ??

if ($dbsize <= 10 && $dbsize > 1 && ($splitproc[$cmdkey] =~ m/.*ora.*/i || $splitproc[$cmdkey] =~ m/.*asm_.*/i) && $db !~ m/\//) {

# Here is the DB
$splitproc[$splitnumber]=$db;

# Sum cpu for all processes related to a database
my $dbname = $db;

$dbcputime{$dbname}->[0]=$diffstats{$key}->[$timkey] + $dbcputime{$dbname}->[0];
}

# Sum cpu for all processes related to a user
#
$usercputime{$splitproc[$usrkey]}->[0]=$diffstats{$key}->[$timkey] + $usercputime{$splitproc[$usrkey]}->[0];

# New hashlist is the current list
#
@{$ProchashList{$key}}=@splitproc;

}

# Search avg,max and min cpu per db

for my $dbname (keys %dbcputime)
{
# THE MAX
if ($dbcputime{$dbname}->[0]/$real_interval > $previousdbmax{$dbname}->[0]) {$previousdbmax{$dbname}->[0]=$dbcputime{$dbname}->[0]/$real_interval};
# THE MIN
if ($nb < 1) {$previousdbmin{$dbname}->[0]=$dbcputime{$dbname}->[0]/$real_interval};
if ($previousdbmin{$dbname}->[0] > $dbcputime{$dbname}->[0]/$real_interval) {$previousdbmin{$dbname}->[0]=$dbcputime{$dbname}->[0]/$real_interval};
# THE AVG
if ($nb < 1) {$previousdbavg{$dbname}->[0]=$dbcputime{$dbname}->[0]/$real_interval};
if ($nb >= 1) {$previousdbavg{$dbname}->[0]=(($previousdbavg{$dbname}->[0] * ($nb)) + $dbcputime{$dbname}->[0]/$real_interval)/($nb+1)};

# Set avg in field [1]
$dbcputime{$dbname}->[1]=$previousdbavg{$dbname}->[0];
# Set max in field [2]
$dbcputime{$dbname}->[2]=$previousdbmax{$dbname}->[0];
# Set min in field [3]
$dbcputime{$dbname}->[3]=$previousdbmin{$dbname}->[0];
}



# Display Cpu usage in second per db

print "\n";
printf ("%30s %-14s\n",'','SUMMARY PER DB');
print "\n";

printf ("%02d:%02d:%02d %2s %-10s %4s %-10s %4s %-6s %5s %-11s %5s %-11s %5s %-11s\n",$hours,$minuts,$seconds,'','DB_NAME','','CPU_SEC','','NB_CPU','','AVG_NB_CPU','','MAX_NB_CPU','','MIN_NB_CPU');

my %resultset = ();
my $nb =1;

#Sort descending to build result set
foreach my $key (sort {$dbcputime{$b}[$sortfield_pattern] <=> $dbcputime{$a}[$sortfield_pattern] } (keys(%dbcputime))) {

@{$resultset{$key}}=@{$dbcputime{$key}};
$nb=$nb+1;
# Break the foreach
last if ($nb > $topn);
}

# Display rows ascending order
foreach my $key (sort {$resultset{$a}[$sortfield_pattern] <=> $resultset{$b}[$sortfield_pattern] } (keys(%resultset))) {

my $dbname=$key;

# no_carriage_return
$dbname =~ s/\r|\n//g;

printf ("%02d:%02d:%02d %2s %-10s %4s %-10s %4s %-6.1f %5s %-11.1f %5s %-11.1f %5s %-11.1f\n",$hours,$minuts,$seconds,'',$dbname,'',$resultset{$key}[0],'',$resultset{$key}[0]/$real_interval,'',$resultset{$key}[1],'',$resultset{$key}[2],'',$resultset{$key}[3]);

}

if ( $dsplayuser =~ m/Y/i ) {

# Display Cpu usage in second per user

print "\n";
printf ("%30s %-18s\n",'','SUMMARY PER USER');
print "\n";

printf ("%02d:%02d:%02d %5s %-10s %10s %-10s %10s %-10s\n",$hours,$minuts,$seconds,'','USER_NAME','','CPU_SEC','','NB_CPU');

%resultset = ();
$nb=1;

#Sort descending to build result set
foreach my $key (sort {$usercputime{$b}[0] <=> $usercputime{$a}[0] } (keys(%usercputime))) {

@{$resultset{$key}}=@{$usercputime{$key}};
$nb=$nb+1;
# Break the foreach
last if ($nb > $topn);
}

# Display rows ascending order
foreach my $key (sort {$resultset{$a}[0] <=> $resultset{$b}[0] } (keys(%resultset))) {

my $username=$key;

# no_carriage_return
$username =~ s/\r|\n//g;

if ($resultset{$key}[0] > 0) {

printf ("%02d:%02d:%02d %5s %-10s %10s %-10s %10s %-.1f\n",$hours,$minuts,$seconds,'',$username,'',$resultset{$key}[0],'',$resultset{$key}[0]/$real_interval);
}
}
}

# Display Cpu usage in second per processes

if ( $dsplaycmd =~ m/Y/i ) {

print "\n";
printf ("%30s %-18s\n",'','SUMMARY PER CMD');
print "\n";

printf ("%02d:%02d:%02d %5s %-10s %5s %-10s %10s %-10s %10s %-10s %3s %-10s\n",$hours,$minuts,$seconds,'','USER_NAME','','PID','','CPU_SEC','','NB_CPU','','OS_COMMAND');

%resultset = ();
$nb=1;

#Sort descending to build result set
foreach my $key (sort {$diffstats{$b}[$timkey] <=> $diffstats{$a}[$timkey] } (keys(%diffstats))) {

@{$resultset{$key}}=@{$diffstats{$key}};
$nb=$nb+1;
# Break the foreach
last if ($nb > $topn);
}

# Display rows ascending order
foreach my $key (sort {$resultset{$a}[$timkey] <=> $resultset{$b}[$timkey] } (keys(%resultset))) {

if ($resultset{$key}[$timkey] > 0) {
# Suppress carriage return
$ProchashList{$key}[7] =~ s/\r|\n//g;
printf ("%02d:%02d:%02d %5s %-10s %5s %-10s %10s %-10s %10s %-.1f %10s %-10s\n",$hours,$minuts,$seconds,'',$ProchashList{$key}[$usrkey],'',,$ProchashList{$key}[$pidkey],'',$resultset{$key}[$timkey],'',$resultset{$key}[$timkey]/$real_interval,'',$ProchashList{$key}[$cmdkey]);
}
}
}
}

