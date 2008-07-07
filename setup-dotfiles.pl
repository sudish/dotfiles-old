#!/usr/bin/perl
#
# Set up the all dotfiles in the current directory in the user's home
# directory using symlinks ("ln -s .* ~").
#
# Sudish Joseph, 2007-06-15
#

sub main();
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

  if (0) {
    my @dotfiles = get_dotfiles('.');
    print "@dotfiles\n";
    exit 0;
  }

  # Always scan current directory
  my @dirs = (".");

  # Get any platform-specific files as well:
  my $osname = lc `uname`;
  chomp $osname;
  push @dirs, $osname if -d $osname;

  foreach my $dir (@dirs) {
    opendir DIR, $dir or die "couldn't opendir(.): $!\n";
    # all entries but ., .. and .svn
    my @entries = grep { /^\./ and !/^\.(\.|svn)?$/ } readdir DIR;
    push @dotfiles, map { $dir eq "." ? $_ : "$dir/$_" } @entries;
    closedir DIR;    
  }
  
  print "Going to symlink the following entries to $homedir: @dotfiles\n";
  unless (prompt_y_or_n("OK?")) {
    print "Quitting\n";
    exit 0;
  }
  
  foreach my $entry (@dotfiles) {
    my ($file) = ($entry =~ m{([^/]+)$});
    my $target = "$homedir/$file";
    
    if (-e $target) {
      if (!prompt_y_or_n("$target already exists, OK to overwrite?")) {
        print "Skipping $file\n";
        next;
      }
      unlink $target or die "couldn't unlink $target: $!";
    }
    
    print "Linking $file to $homedir\n";
    symlink "$pwd/$entry", $target 
      or die "couldn't symlink $pwd/$entry -> $target: $!";
  }
}

sub prompt_y_or_n($) {
  my $prompt = shift @_;
  
  print $prompt, " (y/n): ";
  my $response = <>;
  return ($response =~ /^[yY]/) ? 1 : 0;
}