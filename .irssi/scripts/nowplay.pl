#!/usr/bin/perl

use strict;
use Irssi qw(command_bind);
use vars qw($VERSION %IRSSI);

$VERSION = "1.00";
%IRSSI = (
    authors	=> 'mrFido',
    contact	=> 'highhope@rambler.ru',
    name	=> 'nowplay',
    description	=> 'Get info from a pipe about playing song \
					using xmms & infopipe plugin. (InfoPipe can be get \
		  			from http://www.iki.fi/wwwwolf).',
    license	=> 'Public Domain',
);

sub _getplay{
    my ($data, $server, $witem) = @_;
    
    my ($title,$time,$pos) = '','','','','','';
    my $pipe = '/tmp/xmms-info';

    open (FILE, "<$pipe");
    while (<FILE>) {
  	  $title = $1 if ($_ =~ /^Title:\s(.+)/);
  	  $time = $1 if ($_ =~ /^Time:\s(\d+:\d+)/);
  	  $pos = $1 if ($_ =~ /^Position:\s(\d+:\d+)/);
    };
    close FILE;

    if ($witem && ($witem->{type} eq "CHANNEL" || $witem->{type} eq "QUERY"))
	{
  	  $witem->command("MSG ".$witem->{name}." nowplay: 015$title ($pos/$time)0") if $title;
	} else {
  	  Irssi::print("This is not a channel/query window :b");
    }
}

Irssi::command_bind np => \&_getplay;
