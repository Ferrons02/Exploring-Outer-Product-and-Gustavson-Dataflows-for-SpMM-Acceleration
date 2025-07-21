#! /usr/bin/perl -w
use strict; 

# test program to figure out how to add per directory gitignores
# read from ignores
# go into each directory and generate a .gitignore file 
# do not overwrite existing ignores


#BEGIN{
#  $general_root = '/usr/pack/designkits-1.0-ma/startup';
#}

#use lib "$::general_root/lib";
use lib '/usr/pack/designkits-1.0-ma/startup/lib';  # this adds the cool dump_file command
use DZgeneral;                                      # from teh cockpit setup

# location of ignore file 
my $IGNOREFILE='/usr/pack/gf-22-kgf/dz/dz_tools/ignore.list';                       

#open file 
open (I, "< $IGNOREFILE") or die "Can not open ignore.file [$IGNOREFILE] for reading\n";
my @ignore;  # ignore list

# read in the list from 
while (<I>){
 next if (/^\s*#/);  # ignore the comments
 chomp;              # get rid of the newline
 push (@ignore,$_);  # add to the ignore list
}
close(I);


my %dir=();                       # hash for the directories
foreach my $i (@ignore){
  $i="./".$i unless ($i=~m|/|);   # add a ./ if there is no directory
  $i=~m|^(.*)/([^/]+)\s*$|;       # match to separate directory and the content
  my $d=$1;                       # copy to two variables
  my $p=$2;
  if (exists $dir{$d}){           # does the hash exist? 
    push (@{$dir{$d}},"$p\n");    # if yes push to it 
  }
  else{
    my @tmp=();                   # if not make a new anonymous one
    push (@tmp,"$p\n");           # push to array (add newline here)
    $dir{$d}=\@tmp;               # store the reference
  }
}

open_log('/dev/null');                        # the commands want to write to a log, open a fake one 
foreach my $d (sort keys %dir){               # go through the hash 
  print "Generating: $d/.gitignore\n";        # print information 
  dump_file("$d/.gitignore",$dir{$d},'date'); # from the cockpit setup, $dir is an array pointer..  
}                                             # use 'none' or 'tilde' to generate other backup files
close_log();                                  # close the fake log 
