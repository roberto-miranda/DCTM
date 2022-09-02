#!/usr/bin/perl

use XML::LibXML;
use Log::Log4perl;
use Log::Log4perl::Level;

Log::Log4perl->init("./log4perl.properties");

my $log = Log::Log4perl->get_logger();
$log->level(loglevel());

$log->debug("Invoking encryptPasswordUpdate.pl Script");

##PREFERENCES PASSWORD###
my $preferpass;
my $presetpass;

my $applocation = "$ENV{'CATALINA_HOME'}webapps/da";
if(defined $ENV{'CP_WEB_APP'}) {
   $log->debug("CP_WEB_APP is defined ".$ENV{'CP_WEB_APP'});
   $applocation = $ENV{'CP_WEB_APP'};
} 

$log->info("applocation : $applocation");
my $file = "$applocation/wdk/app.xml";
if( ! -f $file) {
   $log->error("$file doesn't exists");
   die "$file doesn't exists";
}

if(defined $ENV{'PREFERPASS'}) {
   $log->debug("PREFERPASS is defined ".$ENV{'PREFERPASS'});
   $preferpass = $ENV{'PREFERPASS'};
   $preferpass =~ s/^\s+|\s+$//g;
} else {
   
   ##default to webtop
   $preferpass = "webtop";
   $log->debug("PREFERPASS is not set, default webtop is set");
}

if(defined $ENV{'PRESETPASS'}) {
   $log->debug("PRESETPASS is defined ".$ENV{'PRESETPASS'});
   $presetpass = $ENV{'PRESETPASS'};
   $presetpass =~ s/^\s+|\s+$//g;
} else {
   #default to webtop
   $presetpass = "webtop";
   $log->debug("PRESETPASS is not set, default webtop is set");
}

$log->info("Generating Password for Preferences/Presets");
my $java_cmd=`which java`;
my $class_dir="$applocation/WEB-INF/classes";
my $lib_dir="$applocation/WEB-INF/lib";
my @commons_io = `find $lib_dir -iname "commons-io-*.jar"`;
my $java_arg="-cp $class_dir:$lib_dir/dfc.jar:$commons_io[0]";
chomp($java_arg);
$java_cmd =~ s/^\s+|\s+$//g;
$log->info("java command: $java_cmd $java_arg TrustedAuthenticatorTool $presetpass");

my $presetpassword=`$java_cmd $java_arg TrustedAuthenticatorTool $presetpass`;
if (my ($match) = $presetpassword =~ /Encrypted: \[(.*)\], Decrypted: \[.*\]/i) {
   $log->debug("Preset Password generated: $match");
   $presetpassword = $match;
}

my $preferpassword;

if($preferpass eq $presetpass) {
   $log->debug("Using Same preset password for preferences as well");
   $preferpassword = $presetpassword;
} else {
    $log->debug("java command: $java_cmd $java_arg TrustedAuthenticatorTool $preferpass");
    $preferpassword=`$java_cmd $java_arg TrustedAuthenticatorTool $preferpass`;
    if (my ($match) = $preferpassword =~ /Encrypted: \[(.*)\], Decrypted: \[.*\]/i)
    {
	   $log->debug("Preferences Password generated: $match");
       $preferpassword = $match;
    }
}

my $nodes = XML::LibXML->load_xml(location => $file);

my ($prefernode) = $nodes->findnodes("/config/scope/application/preferencesrepository/password");
if(defined $prefernode) {
    $log->info("Updating Preferences Password: $preferpassword");
    $prefernode->removeChildNodes();
    $prefernode->appendText("$preferpassword");
}
my ($presetnode) = $nodes->findnodes("/config/scope/application/presets/password");
if(defined $presetnode) {
    $log->info("Updating Preset Password: $presetpassword");
    $presetnode->removeChildNodes();
    $presetnode->appendText("$presetpassword");
}

if(open FILE, ">$file") { 
   $log->debug("Updating the XML in-memory content to $file");
   print FILE $nodes->toString;
   close(FILE);
} else {
   $log->error("Cannot create XML File: $!");
   die $1;
}

$log->debug("Updated encrypted password into $file");

sub logfile {
   return "./documentum/logs/volmon-password-update.log";
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
