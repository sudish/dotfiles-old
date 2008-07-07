#!/usr/bin/perl
#
# Set up the all dotfiles in the current directory in the user's home
# directory using symlinks ("ln -s .* ~").
#
# Sudish Joseph, 2007-06-15
#

sub main();
sub get_dotfiles($);
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

  opendir THISDIR, "." or die "couldn't opendir(.): $!\n";
  # all entries but ., .. and .svn
  my @dotfiles = grep { /^\./ and !/^\.(\.|svn)?$/ } readdir THISDIR;
  closedir THISDIR;

  print "Going to symlink the following entries to $homedir: @dotfiles\n";
  unless (prompt_y_or_n("OK?")) {
    print "Quitting\n";
    exit 0;
  }
  
  foreach my $entry (@dotfiles) {
    if (-e "$homedir/$entry") {
      if (!prompt_y_or_n("$homedir/$entry already exists, OK to overwrite?")) {
        print "Skipping $entry\n";
        next;
      }
      unlink "$homedir/$entry" or die "couldn't unlink $homedir/$entry: $!";
    }
    
    print "Linking $entry to $homedir\n";
    symlink "$pwd/$entry", "$homedir/$entry" 
      or die "couldn't symlink $pwd/$entry -> $homedir/$entry: $!";
  }
}

sub get_dotfiles($) {
  my $dir = shift @_;
  my @dotfiles;
  my $dir_prefix = $dir eq "." ? "" : "$dir/";
  
  opendir $h, $dir or die "couldn't opendir $dir: $!\n";
  foreach my $ent (readdir $h) {
    if ($ent =~ /^\./ and $ent !~ /^\.(\.|svn)?$/) {
      push @dotfiles, $dir_prefix . $ent;
    }
    elsif (-d $dir_prefix . $ent and $ent !~ /^\.(\.|svn)?$/) {
      push @dotfiles, get_dotfiles($dir_prefix . $ent);
    }
  }
  closedir $h;
  
  return @dotfiles;
}

sub prompt_y_or_n($) {
  my $prompt = shift @_;
  
  print $prompt, " (y/n): ";
  my $response = <>;
  return ($response =~ /^[yY]/) ? 1 : 0;
}