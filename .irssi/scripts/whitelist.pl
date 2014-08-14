##
# /toggle whitelist_notify [default ON]
# Print a message in the status window if someone not on the whitelist messages us
#
# /toggle whitelist_log_ignored_msgs [default ON]
# if this is on, ignored messages will be logged to ~/.irssi/whitelist.log
#
# /set whitelist_nicks phyber etc
# nicks that are allowed to msg us (whitelist checks for a valid nick before a valid host)
#
# /toggle whitelist_nicks_case_sensitive [default OFF]
# do we care which case nicknames are in?
#
# /set whitelist_hosts *!*@*isp.com *!ident@somewhere.org
# Hosts that are allowed to message us, space delimited
#
# Thanks to Geert for help/suggestions on this script
#
# Karl "Sique" Siegemund's addition:
# Managing the whitelists with the /whitelist command:
#
# /whitelist add nick <list of nicks>
# puts new nicks into the whitelist_nicks list
#
# /whitelist add host <list of hosts>
# puts new hosts into the whitelist_hosts list
#
# /whitelist add chan[nel] <list of channels>
# puts new channels into the whitelist_channels list
#
# /whitelist add net[work] <list of chatnets/servers>
# puts new chatnets or irc servers into the whitelist_networks list
#
# /whitelist del nick <list of nicks>
# removes the nicks from whitelist_nicks
#
# /whitelist del host <list of hosts>
# removes the hosts from whitelist_hosts
#
# /whitelist del chan[nel] <list of channels>
# removes the channels from whitelist_channels
#
# /whitelist del net[work] <list of chatnets/servers>
# removes the chatnets or irc servers from whitelist_networks
#
# Instead of the 'del' modifier you can also use 'remove':
# /whitelist remove [...]
#
# /whitelist nick
# shows the current whitelist_nicks
#
# /whitelist host
# shows the current whitelist_hosts
#
# /whitelist chan[nel]
# shows the current whitelist_channels
#
# /whitelist net[work]
# shows the current whitelist_networks
#
# Additional feature for nicks, channels and hosts:
# You may use <nick>@<network>/<ircserver>, <host>@<network>/<ircserver>
# and <channel>@<network>/<ircserver> to restrict the whitelisting to the
# specified network or ircserver.
#
# The new commands are quite verbose. They are so for a reason: The commands
# should be easy to remember and self explaining. If someone wants shorter
# commands, feel free to use 'alias'.
##

use strict;
use Irssi;
use Irssi::Irc;

use vars qw($VERSION %IRSSI);
$VERSION = "0.9c";
%IRSSI = (
	  authors	=> "David O\'Rourke, Karl Siegemund",
	  contact	=> "irssi \[at\] null-routed.com, q \[at\] spuk.de",
	  name		=> "whitelist",
	  description	=> "Whitelist specific nicks or hosts and ignore messages from anyone else.",
	  licence	=> "GPLv2",
	  changed	=> "21.03.2005 2:20GMT"
);

my $whitenick;
my $whitehost;
my $tstamp;

# A mapping to convert simple regexp (* and ?) into Perl regexp
my %htr = ( );
foreach my $i (0..255) {
    my $ch = chr($i);
    $htr{$ch} = "\Q$ch\E";
}
$htr{'?'} = '.';
$htr{'*'} = '.*';

# A list of settings we can use and change
my %types = ( 'nick'    => 'whitelist_nicks',
	      'host'    => 'whitelist_hosts',
	      'chan'    => 'whitelist_channels',
	      'channel' => 'whitelist_channels',
              'net'     => 'whitelist_networks',
	      'network' => 'whitelist_networks' );

sub host_to_regexp($) {
    my ($mask) = @_;
    $mask = lc_host($mask);
    $mask =~ s/(.)/$htr{$1}/g;
    return $mask;
}

sub lc_host($) {
    my ($host) = @_;
    $host =~ s/(.+)\@(.+)/sprintf("%s@%s", $1, lc($2));/eg;
    return $host;
}

sub timestamp {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my @timestamp = ($year+1900,$mon+1,$mday,$hour,$min,$sec);
    $tstamp = "$timestamp[0]-$timestamp[1]-$timestamp[2] $timestamp[3]:$timestamp[4]:$timestamp[5] :";
}

# This one gets called from IRSSI if we get a private message (PRIVMSG)
sub whitelist_check {
    my ($server, $msg, $nick, $address) = @_;
    my $nicks         = Irssi::settings_get_str('whitelist_nicks');
    my $hosts         = Irssi::settings_get_str('whitelist_hosts');
    my $channels      = Irssi::settings_get_str('whitelist_channels');
    my $networks      = Irssi::settings_get_str('whitelist_networks');
    my $warning       = Irssi::settings_get_bool('whitelist_notify');
    my $casesensitive = Irssi::settings_get_bool('whitelist_nicks_case_sensitive');
    my $logging       = Irssi::settings_get_bool('whitelist_log_ignored_msgs');
    my $logfile       = Irssi::get_irssi_dir."/whitelist.log";

    my $hostmask      = "$nick!$address";

    my $tag           = $server->{chatnet};
    $tag              = $server->{tag} unless defined $tag;
    $tag              = lc($tag);

    # Handle servers first, because they are the most significant,
    # Nicks, Channels and Hostmasks are always local to a network
    foreach my $network (split /\s+/, "$networks") {
	# Kludge. Sometimes you get superfluous '', you have to ignore
	next if ($network eq '');
	# Rewrite simplified regexp (* and ?) to Perl regexp
	$network =~ s/(.)/$htr{$1}/g;
	# Either the server tag matches
	return if ($tag =~ /$network/);
	# Or its address
	return if ($server->{address} =~ /$network/);
    }

    # Nicks are the easiest to handle with the least computational effort.
    # So do them before hosts and networks.
    foreach my $whitenick (split(/\s+/, "$nicks")) {
	if ($casesensitive == 0) {
	    $nick = lc($nick);
	    $whitenick = lc($whitenick);
	}
	# Simple check first: Is the nick itself whitelisted?
	return if ($nick eq $whitenick);
	# Second check: We have to look if the nick was localized to a network
	# or irc server. So we have to look at <nick>@<network> too.
        ($whitenick, my $network) = split /@/, $whitenick, 2;
	# Ignore nicks without @<network>
	next if !defined $network;
	# Convert simple regexp to Perl regexp
	$network =~ s/(.)/$htr{$1}/g;
	# If the nick matches...
	if ($nick eq $whitenick) {
	    # ...allow if the server tag is right...
	    return if ($tag =~ /$network/);
	    # ...or the server address matches
	    return if ($server->{address} =~ /$network/);
	}
    }
    
    # Hostmasks are somewhat more sophisticated, because they allow wildcards
    foreach my $whitehost (split(/\s+/, "$hosts")) {
	# First reconvert simple regexp to Perl regexp
	$whitehost = host_to_regexp($whitehost);
	# Allow if the hostmask matches
	return if ($hostmask =~ /$whitehost/);
	# Check if hostmask is localized to a network
        (my $whitename, $whitehost, my $network) = split /@/, $whitehost, 3;
	# Ignore hostmasks without attached network
	next if !defined $network;
	# We don't need to convert the network address again
	# $network =~ s/(.)/$htr{$1}/g;
	# But we have to reassemble the hostmask
	$whitehost = "$whitename@$whitehost";
	# If the hostmask matches...
	if ($hostmask eq $whitehost) {
	    # ...allow if the server tag is ok...
	    return if ($tag =~ /$network/);
	    # ... or the server address
	    return if ($server->{address} =~ /$network/);
	}
    }

    # Channels require some interaction with the server, so we do them last,
    # hoping that some ACCEPT cases are already done, thus saving computation
    # time and effort
    foreach (split(/\s+/, "$channels")) {
	# Check if we are on the specified channel
        my $chan = $server->channel_find($_);
	# If yes...
	if (defined $chan) {
	    # Check if the nick in question is also on that channel
	    my $chk = $chan->nick_find($nick);
	    # Allow the message
	    return if defined $chk;
	}
	# Check if we are talking about a localized channel
	($chan, my $network) = split /@/, $_, 2;
	# Ignore not localized channels
	next if !defined $network;
	# Convert simple regexp to Perl regexp
	$network =~ s/(.)/$htr{$1}/g;
	# Ignore channels from a differently tagged server or from a different
	# address
	next if (!($tag =~ /$network/ || $server->{address} =~ /$network/));
	# Check if we are on the channel
	$chan = $server->channel_find($chan);
	# Ignore if not
	next unless defined $chan;
	# Check if $nick is on that channel too
	my $chk = $chan->nick_find($nick);
	# Allow if yes
	return if defined $chk;
    }

    # stop if the message isn't from a whitelisted address
    # print a notice if that setting is enabled
    # this could flood your status window if someone is flooding you with messages
    if ($warning == 1) {
	Irssi::print "\[$tag\] $nick \[$address\] attempted to send private message.";
      }
    
    if ($logging == 1) {
	timestamp();
	open(WLLOG, ">>$logfile") or return;
	print WLLOG "$tstamp"." \[$tag\] $nick \[$address\]: $msg\n";
	close(WLLOG);
    }
    $server->command("/NOTICE $nick Your query got blocked.");
    Irssi::signal_stop();
    return;
}

sub usage {
    print("Usage: whitelist (add|del|remove) (nick|host|chan[nel]|net[work]) <list>\
       whitelist (nick|host|chan[nel]|net[work])");
}

# This is bound to the /whitelist command
sub whitelist_cmd {
    my ($args, $server, $winit) = @_;
    my $str = '';
    my $pat = '';
    my @list = ( );
    my ($cmd, $type, $rest) = split /\s+/, $args, 3;

    # What type of settings we want to change?
    my $settings = $types{$type};

    # If we didn't get a syntactically correct command, put out an error
    if(!defined $settings && defined $type) {
	usage;
	return;
    } 
    # Get the current value of the setting we want to change
    my $str = Irssi::settings_get_str($settings) if defined $settings;
    # What are we doing?
    if ($cmd eq 'add') {
	# Add the list to the end
	$str .= " $rest";
	# Convert into an array
	@list = split /\s+/, $str;
	# Make the array unique (see Perl FAQ)
	undef my %saw;
	@list = grep(!$saw{$_}++, @list);
	# Put the array together
	$str = join ' ', @list;
    } elsif ($cmd eq 'del' || $cmd eq 'remove') {
	# Convert the list into an array
	@list = split /\s+/, $str;
	# Escape all letters to protect the Perl Regexp special characters
	$rest =~ s/(.)/$htr{$1}/g;
	# Convert the removal list into a Perl regexp
	$rest =~ s/\s+/$|^/g;
	# Use grep() to filter out all occurences of the removal list
	$str = join(' ', grep {!/^$rest$/} @list);
    } elsif(!defined $type) {
	# Look if we just want to see the current values
	$settings = $types{$cmd};
	if (defined $settings) {
	    # Print them
	    print "Whitelist ${cmd}s: ".Irssi::settings_get_str($settings);
	} else {
	    # Or give error message
	    usage;
	}
	return;
    } else {
	# If we felt through until here, something went wrong
	usage;
	return;
    }
    # Display the changed value and store it in the settings
    print "Whitelist ${type}s: $str";
    Irssi::settings_set_str($settings, $str);
}

Irssi::settings_add_bool('whitelist', 'whitelist_notify' => 1);
Irssi::settings_add_bool('whitelist', 'whitelist_log_ignored_msgs' => 1);
Irssi::settings_add_bool('whitelist', 'whitelist_nicks_case_sensitive' => 0);

foreach (keys(%types)) {
    Irssi::settings_add_str('whitelist', $types{$_}, '');
}

Irssi::signal_add_first('message private', \&whitelist_check);

Irssi::command_bind('whitelist',\&whitelist_cmd);
