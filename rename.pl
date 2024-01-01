#!/usr/bin/perl

# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org/>

use warnings;
use strict;

use Image::ExifTool qw(:Public);
use DateTime;

sub do_link {
    my ( $path, $offset ) = @_;

    my $info     = ImageInfo( $path, 'DateTimeOriginal' );
    my $datetime = $info->{DateTimeOriginal};
    my $dt;
    if ( $datetime
        =~ /([0-9]{4}):([0-9]{2}):([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2})/
        )
    {
        $dt = DateTime->new(
            year      => $1,
            month     => $2,
            day       => $3,
            hour      => $4,
            minute    => $5,
            second    => $6,
            time_zone => 'floating'
        );
    }
    else {
        die "Could not parse $datetime as exif datetime";
    }

    $dt->add_duration($offset);
    my $newname = $dt->ymd('_') . '-' . $dt->hms('_');
    while ( -e "${newname}.jpg" ) {
        $newname .= '_';
    }
    link( $path, "${newname}.jpg" )
        or die "Could not create link called ${newname}.jpg to $path : $!";

    return;
}

my $offset = undef;
while (<STDIN>) {
    chomp;
    if ( defined($offset) ) {
        if ( $_ ne '' ) {
            do_link( $_, $offset );
        }
        else {
            $offset = undef;
        }
    }
    else {
        my @tokens      = split(/:/);
        my $do_subtract = 0;
        if ( $tokens[0] =~ /^-/ ) {
            $do_subtract = 1;
            $tokens[0] =~ s/^-//;
        }
        $offset = DateTime::Duration->new(
            hours   => $tokens[0],
            minutes => @tokens > 1 ? $tokens[1] : 0,
            seconds => @tokens > 2 ? $tokens[2] : 0
        );
        $offset = $offset->inverse if $do_subtract;
    }
}
