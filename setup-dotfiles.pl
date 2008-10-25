#!/usr/bin/perl
#
# Set up the all dotfiles in the current directory in the user's home
# directory using symlinks ("ln -s .* ~").
#
# Sudish Joseph, 2007-06-15
#

use strict;

sub main();
sub make_relative_path($$);
sub prompt_y_or_n($);

main();
exit 0;

sub main() {
  my $homedir = $ENV{HOME};
  die "Home directory $homedir is not a directory or can't be accessed!"
    unless -d $homedir;

  my $pwd = `pwd`;
  chomp $pwd;
  die "couldn't determine pwd (got $pwd)!" unless -d $pwd;

  # Always scan current directory
  my @dirs = (".");

  # Platform-specific files
  my $osname = lc `uname`;
  chomp $osname;
  push @dirs, "_uname/$osname"
              if length $osname > 0 and -d "_uname/$osname";

  # Host-specific files, using just the first part of the hostname
  my $hostname = lc `hostname`;
  chomp $hostname;
  $hostname =~ s/\..*$//;
  push @dirs, "_hostname/$hostname"
              if length $hostname > 0 and -d "_hostname/$hostname";

  my @dotfiles;
  foreach my $dir (@dirs) {
    opendir DIR, $dir or die "couldn't opendir(.): $!\n";
    # all entries but ., .. and .svn
    my @entries = grep { /^\./ and !/^\.(\.|svn|.*~)?$/ } readdir DIR;
    push @dotfiles, map { $dir eq "." ? $_ : "$dir/$_" } @entries;
    closedir DIR;
  }

  print "Creating symlinks for:\n";
  foreach my $dotfile (@dotfiles) { print "\t$dotfile\n"; }
  unless (prompt_y_or_n("OK?")) {
    print "Quitting\n";
    exit 0;
  }

  foreach my $entry (@dotfiles) {
    my ($file) = ($entry =~ m{([^/]+)$});
    my $target = "$homedir/$file";

    if (-e $target or -l $target) {
      if (not -l $target) {
        if (!prompt_y_or_n("$target is not a symlink, OK to overwrite?")) {
          print "Skipping $file\n";
          next;
        }
      }
      unlink $target or die "couldn't unlink $target: $!\n";
    }

    my $link_path = make_relative_path($homedir, "$pwd/$entry");
    print "Linking ~/$file -> $link_path\n";
    symlink $link_path, $target 
      or die "couldn't symlink $link_path -> $target: $!";
  }
}

sub make_relative_path($$) {
  my ($prefix, $path) = @_;
  
  return ($path =~ m{^$prefix/?(.*)}) ? $1 : $path;
}

sub prompt_y_or_n($) {
  my $prompt = shift @_;
  
  print $prompt, " (y/n): ";
  my $response = <>;
  return ($response =~ /^[yY]/) ? 1 : 0;
}
