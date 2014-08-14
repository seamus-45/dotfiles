#
# sysinfo irssi perl script
# displays various system information (similar to moo.dll in windows) on
# netbsd, freebsd, openbsd, linux, and mac os x on multiple architectures
#
# this script is for irssi only and has only been tested on irssi 0.8.4
# for the console version of this script, go to
# http://www.obstinate.org/slaktaren/PERL/
#
# valid settings for sysinfo_display_order are:
#   hostname  - displays your hostname
#   uname     - displays your operating system/architecture
#   processor - displays your cpu type/speed (varies between diff archs)
#   procs     - displays how many processes are running on system
#   utime     - displays your uptime
#   load      - displays your 1 minute load average
#   mem       - displays your active memory usage (used/total)
#   disk      - displays your hdd usage (used/total)
#   net1      - displays network traffic (if sysinfo_network_device_1 is set)
#   net2      - displays network traffic (if sysinfo_network_device_2 is set)
#


$VERSION = '2.65';
%IRSSI = (
 authors     => 'DJ Rudie',
 contact     => 'djr@chq.com',
 name        => 'SysInfo',
 description => 'System information display script.',
 license     => 'BSD', # <-- IMPORTANT ;)
 url         => 'http://www.obstinate.org/slaktaren/PERL/',
 changed     => 'Tue Jun 04 15:58 PST 2002',
 bugs        => 'None?'
);


use Irssi;
use POSIX qw(floor);


sub cmd_sysinfo {
 $nic1 = Irssi::settings_get_str('sysinfo_network_device_1');
 $nic2 = Irssi::settings_get_str('sysinfo_network_device_2');

 $s_order    = Irssi::settings_get_str('sysinfo_display_order');

 $os = `uname -s`;
 $osn = `uname -n`;
 $osv = `uname -r`;
 $osm = `uname -m`;
 chop($os);
 chop($osn);
 chop($osv);
 chop($osm);

 if($s_order =~ /hostname/) {
  $hostname = 'Hostname: '.$osn.' - ';
 } else {
  $hostname = '';
 }

 if($s_order =~ /uname/) {
  $uname = 'OS: '.$os.' '.$osv.'/'.$osm.' - ';
 } else {
  $uname = '';
 }

 if($os =~ /^Linux$/) {
  $cpuinfo = '/proc/cpuinfo';
  $meminfo = '/proc/meminfo';
  $netdev = '/proc/net/dev';
  $procuptime = '/proc/uptime';
 } else {
  $dmesgboot = '/var/run/dmesg.boot';
 }

 if($s_order =~ /processor/) {
  if($os =~ /^FreeBSD$/) {
   $cpu = `cat $dmesgboot | grep MHz | grep CPU`;
   $smp = `cat $dmesgboot | grep cpu | wc -l | tr -d ' '`;
   @cpu = split(/: /, $cpu, 2);
   $cpu = $cpu[1];
  } elsif($os =~ /^NetBSD$/) {
   $cpu = `cat $dmesgboot | grep MHz | grep cpu0 | grep -v apic`;
   $smp = `cat $dmesgboot | grep MHz | grep cpu | grep -v apic | wc -l | tr -d ' '`;
   @cpu = split(/: /, $cpu, 2);
   $cpu = $cpu[1];
  } elsif($os =~ /^OpenBSD$/) {
   $cpu = `cat $dmesgboot | grep Hz | grep cpu0 | head -1`;
   $smp = '';
   @cpu = split(/: /, $cpu, 2);
   $cpu = $cpu[1];
  } elsif($os =~ /^Linux$/) {
   if(`cat $cpuinfo` =~ /pmac-generation/) {
    $cpu = `cat $cpuinfo | grep 'machine' | head -1 | cut -f2 -d ':' | tr -d '\\n'`;
    $cpu = $cpu.`cat $cpuinfo | grep 'cpu' | head -1 | cut -f2 -d ':' | tr -d '\\n'`;
    $cpu = $cpu.','.`cat $cpuinfo | grep 'clock' | head -1 | cut -f2 -d ':' | tr -d '\\n'`.' ';
    $smp = `cat $cpuinfo | grep processor | wc -l | tr -d ' '`;
   } elsif(`cat $cpuinfo` =~ /flags/) {
    $cpu = `cat $cpuinfo | grep 'model name' | head -1 | cut -f2 -d ':' | tr -d '\\n'`;
    $cpu = $cpu.','.`cat $cpuinfo | grep 'cpu MHz' | head -1 | cut -f2 -d ':' | tr -d '\\n'`.'MHz ';
    $smp = `cat $cpuinfo | grep processor | grep -v 'model name' | wc -l | tr -d ' '`;
   } elsif(`cat $cpuinfo` =~ /IA-64/) {
    $cpu = `cat $cpuinfo | grep 'family' | head -1 | cut -f2 -d ':' | tr -d '\\n'`;
    $cpu = $cpu.', '.sprintf('%.3f', `cat $cpuinfo | grep 'cpu MHz' | head -1 | cut -f2 -d ':' | tr -d '\\n'`).'MHz ';
    $smp = `cat $cpuinfo | grep processor | wc -l | tr -d ' '`;
   } elsif(`cat $cpuinfo` =~ /ITLB/) {
    $cpu = `cat $cpuinfo | grep 'cpu family' | head -1 | cut -f2 -d ':' | tr -d '\\n'`;
    $cpu = $cpu.' '.`cat $cpuinfo | grep 'cpu' | head -2 | tail -1 | cut -f2 -d ':' | tr -d '\\n'`;
    $cpu = $cpu.', '.sprintf('%.3f', `cat $cpuinfo | grep 'cpu MHz' | head -1 | cut -f2 -d ':' | tr -d '\\n'`).'MHz ';
    $smp = `cat $cpuinfo | grep processor | wc -l | tr -d ' '`;
   } elsif(`cat $cpuinfo` =~ /Processor/) {
    $cpu = `cat $cpuinfo | grep Processor | head -1 | cut -f2 -d ':'`;
    $smp = `cat $cpuinfo | grep Processor | wc -l | tr -d ' '`;
   } elsif(`cat $cpuinfo` =~ /State/) {
    $cpu = `cat $cpuinfo | grep 'cpu' | head -1 | cut -f2 -d ':'`;
    $smp = `cat $cpuinfo | grep CPU | wc -l | tr -d ' '`;
   } elsif(`cat $cpuinfo` =~ /page\ssize/) {
    $cpu = `cat $cpuinfo | grep cpu | head -1 | cut -f2 -d ':' | tr -d '\\n'`;
    $cpu = $cpu.`cat $cpuinfo | grep 'cpu model' | cut -f2 -d ':'`;
    $smp = `cat $cpuinfo | grep 'cpus detected' | cut -f2 -d ':' | tr -d ' '`;
   }
  } elsif($os =~ /^Darwin$/) {
   $cpu = `hostinfo | grep 'Processor type' | cut -f2 -d':'`;
   chop($cpu);
   $cpu = $cpu.','.`AppleSystemProfiler | grep 'Machine speed' | cut -f2 -d'='`;
   $smp = '';
  }
  chop($cpu);
  chop($smp);
  if($os =~ /^FreeBSD$/) {
   if($smp gt 1) {
    $processor = 'CPU: '.$smp.' x '.$cpu.' - ';
   } else {
    $processor = 'CPU: '.$cpu.' - ';
   }
  } elsif($os =~ /^NetBSD$/) {
   if($smp gt 1) {
    $processor = 'CPU: '.$smp.' x '.$cpu.' - ';
   } else {
    $processor = 'CPU: '.$cpu.' - ';
   }
  } elsif($os =~ /^OpenBSD$/) {
   $processor = 'CPU: '.$cpu.' - ';
  } elsif($os =~ /^Linux$/) {
   if($smp gt 1) {
    $processor = 'CPU: '.$smp.' x'.$cpu.' - ';
   } else {
    $processor = 'CPU:'.$cpu.' - ';
   }
  } elsif($os =~ /^Darwin$/) {
   $processor = 'CPU:'.$cpu.' - ';
  }
 } else {
  $processor = '';
 }

 if($s_order =~ /procs/) {
  $procs = `ps ax | grep -v PID | wc -l`;
  chop($procs);
  $procs = $procs;
  $procs =~ s/^\s+//;
  $procs =~ s/\s+$//;
  $procs = 'Processes: '.$procs.' - ';
 } else {
  $procs = '';
 }

 if($s_order =~ /utime/) {
  if($os =~ /^FreeBSD$/) {
   $boottime = `/sbin/sysctl -n kern.boottime | awk '{print \$4}'`;
  } elsif($os =~ /^NetBSD$/) {
   $boottime = `/sbin/sysctl -n kern.boottime`;
  } elsif($os =~ /^OpenBSD$/) {
   $boottime = `/sbin/sysctl -n kern.boottime`;
  } elsif($os =~ /^Darwin$/) {
   $boottime = `/usr/sbin/sysctl -n kern.boottime`;
  }
  if($os =~ /^Linux$/) {
   @uptimesec = split(/ /, `cat $procuptime | tr -d '\\n'`);
   $ticks = $uptimesec[0];
   $ticks = sprintf('%2d', $ticks);
   $days = floor($ticks / 86400);
   $ticks %= 86400;
   $hours = floor($ticks / 3600);
   $ticks %= 3600;
   $mins = floor($ticks / 60);
   if($days eq 0) {
    $days = 0;
   } elsif($days eq 1) {
    $days = $days.' Day';
   } else {
    $days = $days.' Days';
   }
   if($hours eq 0) {
    $hours = 0;
   } elsif($hours eq 1) {
    $hours = $hours.' Hour';
   } else {
    $hours = $hours.' Hours';
   }
   if($mins eq 0) {
    $mins = 0;
   } elsif($mins eq 1) {
    $mins = $mins.' Minute';
   } else {
    $mins = $mins.' Minutes';
   }
  } else {
   chop($boottime);
   $boottime =~ s/,//g;
   $currenttime = `date +%s`;
   chop($currenttime);
   $ticks = $currenttime - $boottime;
   $days = floor($ticks / 86400);
   $ticks %= 86400;
   $hours = floor($ticks / 3600);
   $ticks %= 3600;
   $mins = floor($ticks / 60);
   if($days eq 0) {
    $days = 0;
   } elsif($days eq 1) {
    $days = $days.' Day';
   } else {
    $days = $days.' Days';
   }
   if($hours eq 0) {
    $hours = 0;
   } elsif($hours eq 1) {
    $hours = $hours.' Hour';
   } else {
    $hours = $hours.' Hours';
   }
   if($mins eq 0) {
    $mins = 0;
   } elsif($mins eq 1) {
    $mins = $mins.' Minute';
   } else {
    $mins = $mins.' Minutes';
   }
  }
  if($days eq 0 && $hours eq 0 && $mins ne 0) {
   $utime = $mins;
  } elsif($days eq 0 && $hours ne 0 && $mins ne 0) {
   $utime = $hours.', '.$mins;
  } elsif($days ne 0 && $hours ne 0 && $mins ne 0) {
   $utime = $days.', '.$hours.', '.$mins;
  } elsif($days ne 0 && $hours ne 0 && $mins eq 0) {
   $utime = $days.', '.$hours;
  } elsif($days ne 0 && $hours eq 0 && $mins ne 0) {
   $utime = $days.', '.$mins;
  } elsif($days ne 0 && $hours eq 0 && $mins eq 0) {
   $utime = $days;
  }
  $utime = 'Uptime: '.$utime.' - ';
 }

 if($s_order =~ /load/) {
  $load = `uptime`;
  chop($load);
  if($os =~ /^Linux$/) {
   @load = split(/average: /, $load, 2);
  } else {
   @load = split(/averages: /, $load, 2);
  }
  @load = split(/, /, $load[1], 2);
  $load = $load[0];
  $load = 'Load Average: '.$load.' - ';
 }

 if($s_order =~ /mem/) {
  if($os =~ /^Linux$/ && $osv =~ /^2.2.*$/) {
   $mem = '';
  } else {
   if($os =~ /^Linux$/) {
    $memusage = `cat $meminfo | grep Active | awk '{print \$2}'` * 1024;
    chop($memusage);
    $memusage = $memusage / (1024 * 100);
    $totalmem = `cat $meminfo | grep MemTotal | awk '{print \$2}'` * 1024;
    chop($totalmem);
    $totalmem = $totalmem / (1024 * 100);
    $totalmem = sprintf('%.2f', $totalmem);
    $memusage = sprintf('%.2f', $memusage);
   } elsif($os =~ /^Darwin$/) {
    $memusage = `vm_stat | grep 'Pages active' | awk '{print \$3}'` * 4096;
    chop($memusage);
    $memusage = $memusage / (1024 * 100);
    $totalmem = `/usr/sbin/sysctl -n hw.physmem`;
    chop($totalmem);
    $totalmem = $totalmem / (1024 * 1024);
    $totalmem = sprintf('%.2f', $totalmem);
    $memusage = sprintf('%.2f', $memusage);
   } else {
    $memusage = `vmstat -s | grep 'pages active' | awk '{print \$1}'` * `vmstat -s | grep 'per page' | awk '{print \$1}'`;
    chop($memusage);
    $memusage = $memusage / (1024 * 100);
    $totalmem = `/sbin/sysctl -n hw.physmem`;
    chop($totalmem);
    $totalmem = $totalmem / (1024 * 1024);
    $totalmem = sprintf('%.2f', $totalmem);
    $memusage = sprintf('%.2f', $memusage);
   }
   $mempusage = sprintf('%.2f', $memusage / $totalmem * 100);
   $mem = 'Memory Usage: '.$memusage.'mb/'.$totalmem.'mb ('.$mempusage.'%) - ';
  }
 } else {
  $mem = '';
 }

 if($s_order =~ /disk/) {
  if($os =~ /^Linux$/) {
   $totalhdd = `df -Pk | grep -v Filesystem | awk '{ sum+=\$2 / 1024 / 1024}; END { print sum }'`;
   $hddusage = `df -Pk | grep -v Filesystem | awk '{ sum+=\$3 / 1024 / 1024}; END { print sum }'`;
  } else {
   $totalhdd = `df -k | grep -v Filesystem | awk '{ sum+=\$2 / 1024 / 1024}; END { print sum }'`;
   $hddusage = `df -k | grep -v Filesystem | awk '{ sum+=\$3 / 1024 / 1024}; END { print sum }'`;
  }
  chop($totalhdd);
  chop($hddusage);
  $totalhdd = sprintf('%.2f', $totalhdd);
  $hddusage = sprintf('%.2f', $hddusage);
  $hddpusage = sprintf('%.2f', $hddusage / $totalhdd * 100);
  $disk = 'Disk Usage: '.$hddusage.'gb/'.$totalhdd.'gb ('.$hddpusage.'%) - ';
 } else {
  $disk = '';
 }

 if($nic1) {
  if($os =~ /^FreeBSD$/) {
   $lan_in1 = `netstat -ibn | grep $nic1 | awk '{print \$7}' | head -1` / 1024 / 1024;
  } elsif($os =~ /^NetBSD$/) {
   $lan_in1 = `netstat -ibn | grep $nic1 | awk '{print \$5}' | head -1` / 1024 / 1024;
  } elsif($os =~ /^OpenBSD$/) {
   $lan_in1 = `netstat -ibn | grep $nic1 | awk '{print \$5}' | head -1` / 1024 / 1024;
  } elsif($os =~ /^Linux$/) {
   $lan_in1 = `cat $netdev | grep $nic1 | cut -f2 -d ':' | awk '{print \$1}'` / 1024 / 1024;
  } elsif($os =~ /^Darwin$/) {
   $lan_in1 = `netstat -ibn | grep $nic1 | awk '{print \$7}' | head -1` / 1024 / 1024;
  }
  $lan_in1 = sprintf('%.2f', $lan_in1);
  chop($lan_in1);
  if($os =~ /^FreeBSD$/) {
   $lan_out1 = `netstat -ibn | grep $nic1 | awk '{print \$10}' | head -1` / 1024 / 1024;
  } elsif($os =~ /^NetBSD$/) {
   $lan_out1 = `netstat -ibn | grep $nic1 | awk '{print \$6}' | head -1` / 1024 / 1024;
  } elsif($os =~ /^OpenBSD$/) {
   $lan_out1 = `netstat -ibn | grep $nic1 | awk '{print \$6}' | head -1` / 1024 / 1024;
  } elsif($os =~ /^Linux$/) {
   $lan_out1 = `cat $netdev | grep $nic1 | cut -f2 -d ':' | awk '{print \$9}'` / 1024 / 1024;
  } elsif($os =~ /^Darwin$/) {
   $lan_out1 = `netstat -ibn | grep $nic1 | awk '{print \$10}' | head -1` / 1024 / 1024;
  }
  $lan_out1 = sprintf('%.2f', $lan_out1);
  chop($lan_out1);
  $net1 = 'Network Traffic ('.$nic1.'): In/Out '.$lan_in1.'mb/'.$lan_out1.'mb - ';
 } else {
  $net1 = '';
 }

 if($nic2) {
  if($os =~ /^FreeBSD$/) {
   $lan_in2 = `netstat -ibn | grep $nic2 | awk '{print \$7}' | head -1` / 1024 / 1024;
  } elsif($os =~ /^NetBSD$/) {
   $lan_in2 = `netstat -ibn | grep $nic2 | awk '{print \$5}' | head -1` / 1024 / 1024;
  } elsif($os =~ /^OpenBSD$/) {
   $lan_in2 = `netstat -ibn | grep $nic2 | awk '{print \$5}' | head -1` / 1024 / 1024;
  } elsif($os =~ /^Linux$/) {
   $lan_in2 = `cat $netdev | grep $nic2 | cut -f2 -d ':' | awk '{print \$1}'` / 1024 / 1024;
  } elsif($os =~ /^Darwin$/) {
   $lan_in2 = `netstat -ibn | grep $nic2 | awk '{print \$10}' | head -1` / 1024 / 1024;
  }
  $lan_in2 = sprintf('%.2f', $lan_in2);
  chop($lan_in2);
  if($os =~ /^FreeBSD$/) {
   $lan_out2 = `netstat -ibn | grep $nic2 | awk '{print \$10}' | head -1` / 1024 / 1024;
  } elsif($os =~ /^NetBSD$/) {
   $lan_out2 = `netstat -ibn | grep $nic2 | awk '{print \$6}' | head -1` / 1024 / 1024;
  } elsif($os =~ /^OpenBSD$/) {
   $lan_out2 = `netstat -ibn | grep $nic2 | awk '{print \$6}' | head -1` / 1024 / 1024;
  } elsif($os =~ /^Linux$/) {
   $lan_out2 = `cat $netdev | grep $nic2 | cut -f2 -d ':' | awk '{print \$9}'` / 1024 / 1024;
  } elsif($os =~ /^Darwin$/) {
   $lan_out2 = `netstat -ibn | grep $nic2 | awk '{print \$10}' | head -1` / 1024 / 1024;
  }
  $lan_out2 = sprintf('%.2f', $lan_out2);
  chop($lan_out2);
  $net2 = 'Network Traffic ('.$nic2.'): In/Out '.$lan_in2.'mb/'.$lan_out2.'mb';
 } else {
  $net2 = '';
 }

 $output = $s_order;
 $output =~ s/\s*//g;
 $output =~ s/hostname/$hostname/g;
 $output =~ s/uname/$uname/g;
 $output =~ s/processor/$processor/g;
 $output =~ s/procs/$procs/g;
 $output =~ s/utime/$utime/g;
 $output =~ s/load/$load/g;
 $output =~ s/mem/$mem/g;
 $output =~ s/disk/$disk/g;
 $output =~ s/net1/$net1/g;
 $output =~ s/net2/$net2/g;
 $output =~ s/ - $//;

 Irssi::active_win()->command('/ '.$output);
}

Irssi::settings_add_str('sysinfo', 'sysinfo_network_device_1', '');
Irssi::settings_add_str('sysinfo', 'sysinfo_network_device_2', '');
Irssi::settings_add_str('sysinfo', 'sysinfo_display_order',    'hostname uname processor procs utime load mem disk net1 net2');

Irssi::command_bind('sysinfo', 'cmd_sysinfo');
