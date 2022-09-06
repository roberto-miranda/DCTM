#!/usr/bin/perl
use File::Copy;
use Log::Log4perl;
use Log::Log4perl::Level;

Log::Log4perl->init("./log4perl.properties");

my $log = Log::Log4perl->get_logger();
$log->level(loglevel());

$log->debug("Invoking updateLog4j2Properties.pl Script");

my $applocation = "$ENV{'CATALINA_HOME'}/webapps/da";
$log->info("Application location: $applocation");

my $source = "$applocation/external-configurations/log4j2.properties";
$log->debug("The source file : $source");

if( ! -f $source) {
   $log->error("$source doesn't exists");
   die "$source doesn't exists";
}

my $dest = "$applocation/WEB-INF/classes/log4j2.properties";
$log->debug("The dest file : $dest");

$log->debug("Copying the log4j2 properties from $source to $dest");
copy($source, $dest) or die "Copying from $source to $dest failed: $!.";

sub logfile {
   return "./documentum/logs/volmon-log4j2.log";
}

sub loglevel {
   if(defined $ENV{'LOGLEVEL'}) {
      if($ENV{'LOGLEVEL'} =~ /DEBUG/i) {
        return $DEBUG;
      } elsif($ENV{'LOGLEVEL'} =~ /ERROR/i) {
        return $ERROR;
      } else {
        return $INFO;
      }
   } else {
      return $INFO;
   }
}
