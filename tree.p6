#!/usr/bin/perl6
use v6;
use Shell::Command; # install panda ( git clone https://github.com/tadzik/panda.git )

# Build custom tree of files & directories
# TODO add some examples & better &MAIN help

subset Depth    of Int where 3 <= * <= 60 ; # define custom types, or use where clause in signature
subset PosInt   of Int where * > 0;
subset FileSize of Int where 0 < * <= 1024; # Maximum 1GB file allowed

sub new_filename(PosInt $length=10) {
    state @range = ('a'..'z',0..9,'A'..'Z').flat;
    return @range.flat.pick($length).join() ~ '.txt';
}

signal(SIGINT).tap({ say "INT catched"; exit 0 }); # Catch Ctrl + C


sub MAIN($directory!, FileSize :$file-size=10, PosInt :$dir-count=50, Depth :$depth = 3, PosInt :$file-count=500){

    mkdir $directory if $directory.IO !~~ :d ;
    chdir $directory ;

    my IO::Path $root   = $*CWD;
    my Int $total       = $file-count;
    my Str $separator   = $*SPEC.dir-sep;

    my PosInt $file_per_dir = ($file-count / $dir-count).Int;
    my Int $left_files      = (( ($file-count / $dir-count) - $file_per_dir ) * $dir-count).Int ;

    my Int @iter        = 1..$dir-count;
    my IO::Path @dirs   = ();


    say "$file-count files will be created ( $file_per_dir per dir ) - Total " ~ ($file-count*$file-size) ~ " MB space";

    while @iter.shift -> $fol is copy {
        $fol ~= @iter.elems ?? $separator ~ @iter.shift !! '' for ^$depth;
        @dirs.push: IO::Path.new( $fol );
    }

    for @dirs -> $dir {
        mkpath( $dir.Str );

# That is NOT THREAD SAFE !
        for $dir.Str.split( $separator ) -> $subdir {
            temp $file_per_dir ; # copy will live only one iteration in current block
            chdir $subdir ;
            $file_per_dir++ if $left_files; # 0 Int is false, "0" Str is true

            # Windows server has another tool - 'CREATFIL.EXE'
            #TODO make it with pipe or use C posix_fallocate() <fcntl.h>
            if $*DISTRO.is-win { # TODO check for admin privileges ?
                run "fsutil", "file", "createnew", new_filename.Str, $file-size*1024*1024 for ^$file_per_dir;
            } else {
                run "fallocate", "-l", $file-size~"M", new_filename.Str for ^$file_per_dir;
            }

            $total      -= $file_per_dir;
            $left_files-- if $left_files;
            print "\r   $total to create";
        }
        chdir $root;
    }

    say "\nCreated $dir-count dirs, with $file-count files ( $file_per_dir per directory )";
}

