# arch-tag: dh_haskell libary 
#
# Copyright (C) 2004 John Goerzen <jgoerzen@complete.org>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

package Dh_Haskell;

use strict;

use Exporter;
use vars qw(@ISA @EXPORT %dh);
@ISA=qw(Exporter);
@EXPORT = qw(&is_handled_package &is_handled_profiling
	     &is_profiling_enabled &dev_name &type_of_package
	     &version_of_debpkg &version_of_type &upstream_version
	     &profiling_name &getcabalname &getcabalversion
	     &getcabalbasepath &getcabalpkglibpath
	     &safesystem);

sub is_handled_package {
    my $pkgname = shift;
    if ($pkgname =~ m/^lib(ghc5|ghc6|nhc98|hugs)-.+-dev$/) {
	return 1;
    } elsif ($pkgname =~ m/libhugs-.+$/) {
	return 1;
    } else {
	return 0;
    }
}

sub is_handled_profiling {
    my $pkgname = shift;
    if ($pkgname =~ m/^lib(ghc5|ghc6|nhc98|hugs)-.+-prof$/) {
	return 1;
    } else {
	return 0;
    }
}

sub is_profiling_enabled {
    my $package = shift;
    my $packages = shift;
    my $profname = profiling_name($package);

    foreach my $p (@{$packages}) {
	if ($p =~ m/^$profname$/) {
	    return 1;
	}
    }
    return 0;
}

sub dev_name {
    my $package = shift;
    my @pn = ($package =~ m/^lib(ghc5|ghc6|nhc98|hugs)-(.+)-prof$/);
    return "lib$pn[0]-$pn[1]-dev";
}

sub type_of_package {
    my $pkgname = shift;
    if ($pkgname =~ m/^libhugs-.+$/) {
	return "hugs";
    } else {
	my @pn = ($pkgname =~ m/^lib(ghc5|ghc6|nhc98|hugs)-.+-(dev|prof)$/);
	return $pn[0];
    }
}

sub version_of_debpkg {
    my $pkgname = shift;
    my $retval = `dpkg-query --show --showformat='\${Version}' $pkgname`;
    chomp $retval;
    return $retval;
    }

sub version_of_type {
    my $pkgtype = shift;
    return version_of_debpkg($pkgtype);
}

sub upstream_version {
    my $inver = shift;
    if ($inver =~ m/-/) {
	my @v = ($inver =~ m/^(.+)-[^-]+$/);
	return $v[0];
    }
}

sub profiling_name {
    my $package = shift;
    my @pn = ($package =~ m/^lib(ghc5|ghc6|nhc98|hugs)-(.+)-dev$/);
    return "lib$pn[0]-$pn[1]-prof";
}

sub getcabalname {
    my $retval = `grep -i ^Name *.cabal | awk '{print \$2}'`;
    chomp $retval;
    return $retval;
}

sub getcabalversion {
    my $retval = `grep -i ^Version *.cabal | awk '{print \$2}'`;
    chomp $retval;
    return $retval;
}

sub getcabalnameversion {
    return getcabalname() . "-" . getcabalversion();
}

sub getcabalbasepath {
    my $pkgtype = shift;
    return "/usr/lib/haskell-packages/$pkgtype";
}

sub getcabalpkglibpath {
    my $pkgtype = shift;
    return getcabalbasepath($pkgtype) . "/lib/" . getcabalnameversion();
}

sub safesystem {
    my $program = shift;
    print "Running: $program\n";
    system($program) == 0
	or die "$program files: $?";
}

1
