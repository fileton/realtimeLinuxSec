#!/usr/bin/perl

use Linux::Inotify2;




$email='YOUR EMAIL HERE';

# create a new object
my $inotify = new Linux::Inotify2 or 
die "unable to create new inotify object: $!";
 
my $inotifyTCP =new Linux::Inotify2 or 
die "unable to create new inotify object: $!";

$inotifyTCP->watch ("/proc/net/tcp", IN_MODIFY, sub {  
    my $e = shift;
    my $name = $e->fullname;
    print "hola";    
    my $lastline=`tail -n 1  /proc/net/tcp`;   
    print $lastline;

    });



$inotify->watch ("/var/log/auth.log", IN_MODIFY, sub {  
    my $e = shift;
    my $name = $e->fullname;
    my $lastline=`tail -n 1  /var/log/auth.log`;   
    CheckAlert($lastline);

    });



sub CheckAlert{
my ($line)=@_;
###TODO:put rules as a hash, then iterate over them###
if($line=~/session opened for user root/)
{
print $line;
SendEmail('root login alert',$line);

}

if($line=~/authentication failures/)
{
print $line;
SendEmail('authentication failures',$line);


}




}

sub SendEmail{

my($subject,$message)=@_;
open( my $mailh, '|-', "mail -s '$subject' $email" )
    or die( "Could not open pipe!" )
    ;
print $mailh $message;
close $mailh;

}

 # manual event loop
 1 while $inotify->poll;
