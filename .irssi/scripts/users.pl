# $Id: users.pl,v 1.17 2002/07/04 13:18:02 jylefort Exp $

use Irssi 20020121.2020 ();
$VERSION = "1.01";
%IRSSI = (
	  authors     => 'Jean-Yves Lefort',
	  contact     => 'jylefort\@brutele.be, decadix on IRCNet',
	  name        => 'users',
	  description => 'Adds a /users command similar to /names builtin, but displaying userhost too',
	  license     => 'BSD',
	  url         => 'http://void.adminz.be/irssi.shtml',
	  changed     => '$Date: 2002/07/04 13:18:02 $ ',
);

# usage:
#
#	as simple as typing /USERS in a channel window (the list will be
#	displayed in a new window)
#
# /format's:
#
#	users		list header
#			$0	channel name
#
#	users_nick	nick
#			$0	is ircop ?
#			$1	is channel op / halfop ?
#			$2	is voice ?
#			$3	nick
#			$4	userhost
#
#	endofusers	end of list
#			$0	channel name
#			$1	total nick count
#			$2	ircop count
#			$3	op count
#			$4	halfop count
#			$5	voice count
#			$6	normal count
#
# changes:
#
#	2002-07-04	release 1.01
#			* command_bind uses a reference instead of a string
#
#	2002-04-25	release 1.00
#			* uses '*' instead of 'S' for IRC operators
#
#	2002-04-12	release 0.13
#			* added support for ircops
#			* changed theme
#
#	2002-01-28	release 0.12
#			* added support for halfops
#
#	2002-01-28	release 0.11
#
#	2002-01-23	initial release

use strict;

sub nick_cmp {
  my $mode_cmp = ($_[1]->{op} << 2) + ($_[1]->{halfop} << 1) + $_[1]->{voice}
    cmp ($_[0]->{op} << 2) + ($_[0]->{halfop} << 1) + + $_[0]->{voice};
  return $mode_cmp ? $mode_cmp : lc $_[0]->{nick} cmp lc $_[1]->{nick};
}

sub users {
  my ($args, $server, $item) = @_;

  if ($item && $item->{type} eq "CHANNEL") {
    Irssi::command('/WINDOW NEW HIDDEN');
    my ($window, @nicks) = (Irssi::active_win(), $item->nicks());
    my ($serverops, $ops, $halfops, $voices, $normals) = (0, 0, 0, 0, 0);
    
    $window->set_name("U:$item->{name}");
    $window->printformat(MSGLEVEL_CRAP, "users", $item->{name});
    
    @nicks = sort { nick_cmp($a, $b) } @nicks;

    foreach my $nick (@nicks) {
      my ($serverop, $op, $voice, $is_normal) = ('.', '.', '.', 1);
      if ($nick->{serverop}) {
	$serverop = '*';
	$serverops++;
      }
      if ($nick->{op}) {
	$op = '@';
	$ops++;
	$is_normal = undef;
      } elsif ($nick->{halfop}) {
	$op = '%';
	$halfops++;
	$is_normal = undef;
      }
      if ($nick->{voice}) {
	$voice = '+';
	$voices++;
	$is_normal = undef;
      }
      $normals++ if ($is_normal);
      $window->printformat(MSGLEVEL_CRAP, "users_nick",
			   $serverop, $op, $voice,
			   $nick->{nick}, $nick->{host});
    }
    
    $window->printformat(MSGLEVEL_CRAP, "endofusers", $item->{name},
			 $ops + $halfops + $voices + $normals,
			 $serverops, $ops, $halfops, $voices, $normals);
  }
}

Irssi::theme_register([
		       'users', '{names_users Users {names_channel $0}}',
		       'users_nick', '{hilight $0$1$2} $[9]3 {nickhost $[50]4}',
		       'endofusers', '{channel $0}: Total of {hilight $1} nicks {comment {hilight $2} ircops, {hilight $3} ops, {hilight $4} halfops, {hilight $5} voices, {hilight $6} normal}',
		      ]);

Irssi::command_bind("users", \&users);
