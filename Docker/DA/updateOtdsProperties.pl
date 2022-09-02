#!/usr/bin/perl

use Log::Log4perl;
use Log::Log4perl::Level;

Log::Log4perl->init("./log4perl.properties");

my $log = Log::Log4perl->get_logger();
$log->level(loglevel());

$log->debug("Invoking updateOtdsProperties.pl Script");

my $totalarg = $#ARGV + 1;

my $applocation = "$ENV{'CATALINA_HOME'}/webapps/da";
if(defined $ENV{'CP_WEB_APP'}) {
   $log->info("CP_WEB_APP is set to ".$ENV{'CP_WEB_APP'});
   $applocation = $ENV{'CP_WEB_APP'};
} 

$log->info("Application location: $applocation");
my $otdsconfigproperties = "$applocation/external-configurations/otdsoauth.properties";
my $otdsproperties = "$applocation/WEB-INF/classes/com/documentum/web/formext/session/otdsoauth.properties";
my %properties;

if( -f $otdsconfigproperties) {
   $log->info("fetching properties from otds.properties file $otdsconfigproperties");
   if(open OTDSPROPERTIES, "<$otdsconfigproperties") { 
      while(<OTDSPROPERTIES>) {
         if($_ !~ /^#/ && $_ =~ m/(\S+)=(\S+)/g) {
            $log->debug("$1=$2");
	    $properties{$1}=$2;
	 }
         if($_ !~ /^#/ && $_ =~ m/(\S+):(\S+)/g) {
            $log->debug("$1:$2");
            $properties{$1}=$2;
         }
      }
      close OTDSPROPERTIES;
   } else {
      $log->error("Cannot read $otdsconfigproperties File: $!");
      die $!;
   }
}

if(defined $ENV{'OTDS_PROPERTIES'}) {
   $log->info("fetching properties from environment otdsproperties variable");
   my @envconfig = split /\:\:/, $ENV{'OTDS_PROPERTIES'};
   foreach(@envconfig) {
      if($_ !~ /^#/ && $_ =~ m/(\S+)=(\S+)/g) {
	 $log->debug("$1=$2");
         $properties{$1}=$2;
      }
   }
} 

if(defined $properties{'otds_url'} && $properties{'otds_url'} ne "") {
   $log->debug($properties{'otds_url'}." is configured");
   chomp($properties{'otds_url'});
   if($properties{'otds_url'} =~ /\/$/) {
      chop($properties{'otds_url'});
   }
   my $url = $properties{'otds_url'}."/rest/systemconfig/certificate_content";
   $log->debug("OTDS Certificate url: $url");
   if(defined $ENV{'KUBERNETES'}) {
      $url =~ s/https:/http:/g;
      $url =~ s/otdsauth/otdsapi/g;
      if(!defined $ENV{'OTDS_REDIRECT_PROTOCOL'}) {
         $properties{'scheme'} = "https";
      }
   }
   my $certbuf = `curl  --insecure --silent $url`;
   $log->debug("OTDS Certificate : $certbuf");
   if($certbuf =~ /^\W+\w+\s+\w+\W+\s(.*)\s+\W+.*$/s) {
      my $certificate = join '', split ' ', $1;
      $properties{'certificate'}=$certificate;
      if(-f "$otdsproperties" && -r "$otdsproperties") {
         system("dos2unix $otdsproperties");
      } else {
         $log->error("$otdsproperties doesn't exists or not readable");
         die "$otdsproperties doesn't exists or not readable";
      }

      open(OTDSPROPERTIES, "<", "$otdsproperties");
      my @otdsproperties = <OTDSPROPERTIES>;
      close(OTDSPROPERTIES);

      if(open(OTDSPROPERTIES, ">", "$otdsproperties")) {
         foreach my $line(@otdsproperties) {
            foreach $property (keys %properties) {
               if($line =~ /($property)=(.*)(\s*)$/) {
                  $line = "$property=$properties{$property}$3"; 
               }     
            }
            print OTDSPROPERTIES "$line";
         }
         close(OTDSPROPERTIES); 
      } else {
         $log->error("Cannot write to $otdsproperties File: $!");
         die $!;
      }
   }
}


sub logfile {
   return "./documentum/logs/volmon-otdsoauth.log";
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

