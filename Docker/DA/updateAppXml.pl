#!/usr/bin/perl

use XML::LibXML;

use Log::Log4perl;
use Log::Log4perl::Level;

Log::Log4perl->init("./log4perl.properties");

my $log = Log::Log4perl->get_logger();
$log->level(loglevel());

$log->debug("Invoking updateAppXml.pl Script");

my $totalarg = $#ARGV + 1;
my $restart = 'false';

my $applocation = "$ENV{'CATALINA_HOME'}/webapps/da";
if(defined $ENV{'CP_WEB_APP'}) {
   $log->debug("CP_WEB_APP is configured in env: ". $ENV{'CP_WEB_APP'});
   $applocation = $ENV{'CP_WEB_APP'};
}
my $appname = "da";
if($applocation =~ m#([^/]+)$#) {
    $appname = $1;
}

$log->info("Application location: $applocation");
$log->info("Application name    : $appname");

my $appxml = "$applocation/wdk/app.xml";
my $tempappxml = "$applocation/wdk/tempapp.xml";
my $app_properties = "$applocation/external-configurations/app.properties";
if(! -f $appxml) {
   $log->error("$appxml file doesn't exist");
   die "$appxml file doesn't exist";
}
my $nodes = XML::LibXML->load_xml(location => $appxml);

$log->debug("app.xml is location at $appxml");
$log->debug("app_properties is location at $$app_properties");

my %properties;
   
if( -f $app_properties) {
   $log->info("setting properties from $app_properties");
   if(open APPPROPERTIES, "<$app_properties") {
      while(<APPPROPERTIES>) {
         if($_ !~ /^#/ && $_ =~ m/(\S+)=(.*)/g) {
			$log->debug("$1=$2");
            $properties{$1}=$2;
         }
      }
      close APPPROPERTIES;
   } else {
      $log->error("Cannot read $app_properties File: $!");
      die $!;
   }
}


if($totalarg >= 1 && defined $ENV{'APP_PROPERTIES'}) {
   $log->info("setting properties from environment variables appproperties");
   my @envconfig = split /\:\:/, $ENV{'APP_PROPERTIES'};
   foreach(@envconfig) {
      if($_ !~ /^#/ && $_ =~ m/(\S+)=(.*)/g) {
		$log->debug("$1=$2");
        $properties{$1}=$2;
      }
   }
}

foreach my $property (keys %properties)
{
  # do whatever you want with $key and $value here ...
  $value = $properties{$property};
  $property =~ s/\./\//g;
  if($property =~ /locale$/i) {
    $restart = 'true';
    if($value =~ /^\[/) {
      my $child = $1 if $property =~ /([^\/]+)$/;
      my $parent = $property ;
      $parent =~ s/.$child$//;
      $value =~ s/\[|\]//g;
      my @valuearr = split(',', $value);
      my ($node) = $nodes->findnodes("/config/scope/"."$parent");
      if(defined $node) {
        my $childnode;
        $node->removeChildNodes();
        if(scalar(@valuearr) > 0) {
          foreach $val(@valuearr) {
            if($val =~ /;/) {
              my @values = split(';', $val);
              $val = shift(@values);
              $childnode =  $node->addNewChild(undef, "$child");
              $childnode->appendTextNode($val);
              foreach $arg(@values) {
				if($arg =~ /(.*)\|(.*)/) {
					$childnode->setAttribute($1, $2); 
                }
              }
            } else {
              $childnode =  $node->addNewChild(undef, "$child");
              $childnode->appendTextNode($val);
			}
          }
        }
      }
    } else {
      my ($node) = $nodes->findnodes("/config/scope/"."$property");
      if(defined $node) {
        $log->debug("$property = $value");
        $node->removeChildNodes();
        $node->appendText("$value");
      }
    }
  } else {
    if($value =~ /^\[/) {
      my $child = $1 if $property =~ /([^\/]+)$/;
      my $parent = $property ;
      $parent =~ s/.$child$//;
      $value =~ s/\[|\]//g;
      my @valuearr = split(',', $value);
      my ($node) = $nodes->findnodes("/config/scope/"."$parent");
      if(defined $node) {
        my $childnode;
        if(scalar(@valuearr) > 0) {
          foreach $val(@valuearr) {
            if($node->hasChildNodes()) {
              foreach $chnode($node->childNodes()) {
                my $content = $node->textContent;
                if($content !~ /$val/) {
                  $childnode =  $node->addNewChild(undef, "$child");
                  $childnode->appendTextNode($val);
                }
              }
            }
          }
        }
      }
    } else {
      my ($node) = $nodes->findnodes("/config/scope/"."$property");
      if(defined $node) {
        $log->debug("$property = $value");
        $node->removeChildNodes();
        $node->appendText("$value");
      }
    }
  }
}

if(open APPXML, ">$tempappxml") {
   print APPXML $nodes->toString;
   close(APPXML);
} else {
   $log->error("Cannot create XML $appxml File: $!");
   die $!;
}

system("xmllint --format $tempappxml > $appxml");
system("rm -rf $tempappxml");
if($totalarg < 1 && $restart =~ /true/) {
  $log->info("Restart required");
  my $cmd = "$ENV{'CATALINA_HOME'}/bin/shutdown.sh";
  $log->debug("Shutdown command: $cmd");
  system($cmd);
  sleep(20);
  $cmd = "$ENV{'CATALINA_HOME'}/bin/startup.sh";
  $log->debug("Startup command: $cmd");
  system($cmd);
} else {
  if($totalarg == 0) {
    $log->info("Invoking refresh.jsp curl --silent http://localhost:8080/$appname/wdk/refresh.jsp");
    my $curl_output = `curl --silent http://localhost:8080/$appname/wdk/refresh.jsp`;
    $log->debug("refresh output $curl_output");
    if ($curl_output !~ /Configuration files reloaded.../i) {
        $log->info("Restart required");
		my $cmd = "$ENV{'CATALINA_HOME'}/bin/shutdown.sh";
        $log->debug("Shutdown command: $cmd");
		system($cmd);
		sleep(20);
		$cmd = "$ENV{'CATALINA_HOME'}/bin/startup.sh";
        $log->debug("Startup command: $cmd");
		system($cmd);
    }
  }
}

$log->info("Updated app.xml file $appxml successfully");

sub logfile {
   return "./documentum/logs/volmon-app-xml.log";
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
