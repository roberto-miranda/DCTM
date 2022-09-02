#!/usr/bin/perl

use Log::Log4perl;
use Log::Log4perl::Level;

Log::Log4perl->init("./log4perl.properties");

my $log = Log::Log4perl->get_logger();
$log->level(loglevel());

$log->debug("Invoking updateDfcProperties.pl Script");

my $totalarg = $#ARGV + 1;

my $applocation = "$ENV{'CATALINA_HOME'}/webapps/da";
if(defined $ENV{'CP_WEB_APP'}) {
   $log->info("CP_WEB_APP is set to ".$ENV{'CP_WEB_APP'});
   $applocation = $ENV{'CP_WEB_APP'};
} 

$log->info("Application location: $applocation");


my $dfcproperties = "$applocation/WEB-INF/classes/dfc.properties";
my $dfcconfigproperties = "$applocation/external-configurations/dfc.properties";

if(-f $dfcproperties) {
   $log->debug("Converting $dfcproperties to unix compatible using dos2unix");
   system("dos2unix $dfcproperties");
}

my %properties;

if( -f $dfcconfigproperties) {
   $log->info("fetching properties from dfc.properties file");
   if(open DFCPROPERTIES, "<$dfcconfigproperties") {
      while(<DFCPROPERTIES>) {
         if($_ !~ /^#/ && $_ =~ m/(.*)=(.*)/g) {
            $log->debug("$1=$2");
            $properties{$1}=$2;
         }
         if($_ !~ /^#/ && $_ =~ m/(.*):(.*)/g) {
            $log->debug("$1:$2");
            $properties{$1}=$2;
         }
      }
      close DFCPROPERTIES;
   } else {
      $log->error("Cannot read $dfcconfigproperties File: $!");
      die $!;
   }
}

if( defined $ENV{'DFC_PROPERTIES'}) {
   $log->info("fetching properties from environment dfcproperties variable");
   my @envconfig = split /\:\:/, $ENV{'DFC_PROPERTIES'};
   foreach(@envconfig) {
      if($_ !~ /^#/ && $_ =~ m/(.*)=(.*)/g) {
         $log->debug("$1=$2");
         $properties{$1}=$2;
      }
   }
} 

if(defined $ENV{'DFC_GLOBALREGISTRY_PASSWORD'}) {
   $log->debug("Getting docbase password from env");
   $log->debug("dfc.globalregistry.password=".$ENV{'DFC_GLOBALREGISTRY_PASSWORD'});
   $properties{'dfc.globalregistry.password'} = $ENV{'DFC_GLOBALREGISTRY_PASSWORD'};
}

if(defined $ENV{'ALLOW_TRUSTED_LOGIN'}){
   $log->debug("Getting allow_trusted_login value from env");
   $log->debug("dfc.session.allow_trusted_login=".$ENV{'ALLOW_TRUSTED_LOGIN'});
   $properties{'dfc.session.allow_trusted_login'} = $ENV{'ALLOW_TRUSTED_LOGIN'};
}else{
   $properties{'dfc.session.allow_trusted_login'} = 'false';
}

if(defined $ENV{'USE_CERTIFICATE'}){
   $log->debug("Certificate based authentication enabled.");   
   $log->debug("dfc.security.ssl.truststore_password=".$ENV{'TRUST_STORE_PASSWORD'});
   $properties{'dfc.security.ssl.truststore_password'} = $ENV{'TRUST_STORE_PASSWORD'};
}

if(open DFCPROPERTIES, ">$dfcproperties") {
   $log->info("Updating $dfcproperties with the below values");
   foreach $property (keys %properties) {
      $log->info("$property=$properties{$property}");
      print DFCPROPERTIES "$property=$properties{$property}\n";
   }
   close(DFCPROPERTIES);
} else {
   $log->error("Cannot create $dfcproperties File: $!");
   die  $!;
}

sub logfile {
   return "./documentum/logs/volmon-dfc.log";
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

