#!/usr/bin/perl
#
# $Rev: 16 $									     
# ls339@njit.edu

use XML::Simple;
use Data::Dumper;

# fetch performance data
$perfmonurl = "<CONFIGURE THIS>";
print "Fetching performance data . . .\n";
system ("curl '$perfmonurl' -o jvm_perfmon_WP1.xml");

# create the object
$xml = new XML::Simple;

# read the xml file
$data = $xml->XMLin("jvm_perfmon_WP1.xml");

# print data
#print Dumper($data);

$maxheapsize = $data->{Node}->{Server}->{Stat}->{BoundedRangeStatistic}->{upperBound};
$initialheapsize = $data->{Node}->{Server}->{Stat}->{BoundedRangeStatistic}->{lowerBound};
$usedmem = $data->{Node}->{Server}->{Stat}->{CountStatistic}->{UsedMemory}->{count};
$peakmem = $data->{Node}->{Server}->{Stat}->{BoundedRangeStatistic}->{highWaterMark};
$lowmem = $data->{Node}->{Server}->{Stat}->{BoundedRangeStatistic}->{lowWaterMark};
$usedheapsizepercent = (($usedmem / 1024) / ($maxheapsize / 1024)) * (100);

#debug
#$usedmem = $maxheapsize;
#debug

print "----------------------------------------------\n";
print "WebSphere Version : $data->{version} \n";
print "Server : $data->{Node}->{Server}->{name} \n";
print "----------------------------------------------\n";
print "JVM Runtime Statistics \n";
print "Used Memory : ".($usedmem / 1024)." MB \n";
print "High Water Mark Memory Usage : ".($peakmem / 1024)." MB \n";
print "Low Water Mark Memory Usage : ".($lowmem / 1024). " MB \n";
print "Maximum Heap Size : ".($maxheapsize / 1024)."  MB \n";
print "Initial Heap Size : ".($initialheapsize / 1024)." MB \n";
#print "$usedheapsizepercent % Memory Used \n";

# Determine if more than X amount of memory used
$memthresh = 90;
$heartbeatfile = "jvm_perfmon_websphere_portal.error";
print "----------------------------------------------\n";
if ($usedheapsizepercent <= $memthresh) {
	print "Memory Usage : OK \n";
	print "$usedheapsizepercent % of the total heap size is in use. \n";
	print "$memthresh % is the memory threshhold. \n";
	unlink($heartbeatfile);
	
}else{
	print "Memory Usage : CRITICAL \n";
	print "$usedheapsizepercent % of the total heap size is in use. \n";
        print "$memthresh % is the memory threshhold. \n";

	open (heartbeatfile, ">$heartbeatfile");
	print heartbeatfile "Memory Usage : CRITICAL | $usedheapsizepercent % of the total heap size is in use.";
	close (heartbeatfile);
}
