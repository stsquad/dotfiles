#!/usr/bin/perl -w
#
# linkbin
#
# Create symbolic links to ~/bin for a given directory. This is handy
# for keeping stuff in version control but without having mega complex
# PATH statements
#

use strict;

(my $me = $0) =~ s|.*/(.*)|$1|;

use Getopt::Long;
use Data::Dumper;
use Cwd 'abs_path';
use File::Spec;		# for relPath
use File::Basename;

use Data::Dumper;

# The actual script
my $real_me = abs_path($0);

# Options
my ($help,$verbose,$quiet);
my ($force,$binpath,$install);

my @files;

GetOptions (
	    'h|?|help' 	   => \$help,
	    'v|verbose'    => \$verbose,
	    'q|quiet'      => \$quiet,
	    'b|binpath=s'  => \$binpath,
	    'f|force'	   => \$force,
            'i|install'    => \$install,
);

# Lets setup defaults if we haven't overidden
if (!defined $binpath)
{
    $binpath = $ENV{"HOME"};

    $binpath = $binpath."/.emacs.d" if $me eq "linklisp.pl";
    $binpath = $binpath."/bin/" if $me eq "linkbin.pl";

    # Otherwise
    if ($me eq "linkdot.pl")
    {
	$binpath = $binpath."/";
	# XXX: do something about renaming
    }

    print "binpath set to $binpath\n" if $verbose;
}

# trim trailing slashes
$binpath =~ s#/$##;

# help?
if (defined $help) {
    &usage;
}

die "$binpath isn't a directory" if ! -d $binpath;

# Ensure binpath is abolute
if (!File::Spec->file_name_is_absolute($binpath))
{
    print "Munging binpath from $binpath";
    $binpath = File::Spec->rel2abs($binpath);
    print " to $binpath\n";
}

if (defined $install)
{
    $binpath = $ENV{"HOME"}."/bin";
    do_linkage($real_me, "$binpath/linkbin.pl");
    do_linkage($real_me, "$binpath/linkdot.pl");
    do_linkage($real_me, "$binpath/linklisp.pl");
} else {
    # We can specify files or just slurp up the dir
    @files = @ARGV;

    die "No files" if (scalar @files == 0);

    foreach my $file (@files)
    {
	do_linkage($file, $binpath);
    }
}

# Done
exit 0;

#
# usage
#

sub usage {
    print STDERR <<EOF;
Usage: $me [options] [files]
  -h, -?, --help 	: show usage info

  -b, --binpath <path>	: set destination path, defaults to: $binpath
  -f, --force		: overide existing links if they exist

  -i, --install         : install self in various guises
EOF
    exit 1;
}

sub do_linkage
{
    my ($file, $dest) = @_;

    if (!File::Spec->file_name_is_absolute($file))
    {
	$file = File::Spec->rel2abs($file);
    }

    if (-d $dest )
    {
	my $basename = basename($file);
	$dest = $dest."/".$basename;
    }

    # Remove old links if asked
    if (-l $dest && $force)
    {
	print "Removing existing $dest\n" unless $quiet;
	unlink $dest;
    }

    # Install links
    if (!-l $dest)
    {
	print "Linking $file to $dest\n" unless $quiet;
	die "Link failed for $file to $dest" if !symlink $file, $dest;
    } else {
	print "Skipping $file, $dest already there (-f to overide))\n" unless $quiet;
    }

}
