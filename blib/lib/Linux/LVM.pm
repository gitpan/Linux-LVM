package Linux::LVM;

use 5.008;
use strict;
use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Linux::LVM ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw( get_volume_group_list
                                    get_volume_group_information
                                    get_logical_volume_information
                                    get_physical_volume_information
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( get_volume_group_list
                  get_volume_group_information
                  get_logical_volume_information
                  get_physical_volume_information
);

our $VERSION = '0.01';


# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

#-----------------------------------------------------------------------#
# Subroutine: get_volume_group_list                                     #
#-----------------------------------------------------------------------#
# Description: This function will return a sorted list of all of the    #
#              active volume groups on the system.                      #
#-----------------------------------------------------------------------#
# Parameters: None                                                      #
#-----------------------------------------------------------------------#
# Return Values: On success, a array with the volume group names.       #
#-----------------------------------------------------------------------#
sub get_volume_group_list() {
    my %vg = get_vg_information();
    return (sort keys(%vg));
} # End of the get_volume_group_list routine.


#-----------------------------------------------------------------------#
# Subroutine: get_volume_group_information                              #
#-----------------------------------------------------------------------#
# Description: This function will return a hash containing all of the   #
#              data about the specified volume group.                   #
#-----------------------------------------------------------------------#
# Parameters: A string containing a volume group name.                  #
#-----------------------------------------------------------------------#
# Return Values: On success, a hast with the volume group data.         #
#-----------------------------------------------------------------------#
sub get_volume_group_information($) {
    my $volume_group = $_[0];
    my %vg_info;
    my %vg = get_vg_information();

    foreach(sort keys %{$vg{$volume_group}}) {
        if   ( $_ eq "pvols" ) { next; }
        elsif( $_ eq "lvols" ) { next; }
        else                   { 
            $vg_info{$_} = $vg{$volume_group}->{$_}; 
        }
    }
    return %vg_info;
} # End of the get_volume_group_information routine.


#-----------------------------------------------------------------------#
# Subroutine: get_volume_group_information                              #
#-----------------------------------------------------------------------#
# Description: This function will return a hash containing all of the   #
#              data about the specified volume group.                   #
#-----------------------------------------------------------------------#
# Parameters: A string containing a volume group name.                  #
#-----------------------------------------------------------------------#
# Return Values: On success, a hast with the volume group data.         #
#-----------------------------------------------------------------------#
sub get_logical_volume_information($) {
    my $volume_group = $_[0];
    my %lv_info;
    my $lvname;
    my %vg = get_vg_information();

    foreach $lvname (sort keys %{$vg{$volume_group}->{lvols}}) {
        foreach(sort keys %{$vg{$volume_group}->{lvols}->{$lvname}}) {
            $lv_info{$lvname}->{$_} = $vg{$volume_group}->{lvols}->{$lvname}->{$_};
        }
    }
    return %lv_info;
} # End of the get_logical_volume_information routine.


#-----------------------------------------------------------------------#
# Subroutine: get_volume_group_information                              #
#-----------------------------------------------------------------------#
# Description: This function will return a hash containing all of the   #
#              data about the specified volume group.                   #
#-----------------------------------------------------------------------#
# Parameters: A string containing a volume group name.                  #
#-----------------------------------------------------------------------#
# Return Values: On success, a hast with the volume group data.         #
#-----------------------------------------------------------------------#
sub get_physical_volume_information($) {
    my $volume_group = $_[0];
    my %pv_info;
    my $pvname;
    my %vg = get_vg_information();

    foreach $pvname (sort keys %{$vg{$volume_group}->{pvols}}) {
        foreach(sort keys %{$vg{$volume_group}->{pvols}->{$pvname}}) {
            $pv_info{$pvname}->{$_} = $vg{$volume_group}->{pvols}->{$pvname}->{$_};
        }
    }
    return %pv_info;
} # End of the get_physical_volume_information routine.


#-----------------------------------------------------------------------#
# Subroutine: get_vg_information                                        #
#-----------------------------------------------------------------------#
# Description: This function will return a hash containing all of the   #
#              volume group information for the system.                 #
#-----------------------------------------------------------------------#
# Parameters: None                                                      #
#-----------------------------------------------------------------------#
# Return Values: On success, a hash with all of the vg information.     #
#-----------------------------------------------------------------------#
sub get_vg_information() {
    my %vghash;
    my $vgn;
    my $lvn;
    my $pvn;
    my @vginfo = `/sbin/vgdisplay -v`;
    VGINF: foreach(@vginfo) {

        # Parse the volume group name.
        if( m/^VG Name(\s+)(\S+)/ ) { 
            $vgn = $2; $vghash{$vgn}->{vgname} = $2; 
            next VGINF; }

        # Parse the volume group access.
        elsif( m/^VG Access(\s+)(\S+)/ ) { 
            $vghash{$vgn}->{access} = $2; 
            next VGINF; }

        # Parse the volume group status.
        elsif( m/^VG Status(\s+)(.+)/ ) { 
            $vghash{$vgn}->{status} = $2; 
            next VGINF; }

        # Parse the volume group number.
        elsif( m/^VG #(\s+)(\S+)/ ) { 
            $vghash{$vgn}->{vg_number} = $2; 
            next VGINF; }

        # Parse the maximum logical volume size and size unit for the volume group.
        elsif( m/^MAX LV Size(\s+)(\S+) (\S+)/ ) {
            $vghash{$vgn}->{max_lv_size} = $2;
            $vghash{$vgn}->{max_lv_size_unit} = $3; 
            next VGINF; }

        # Parse the maximum number of logical volumes for the volume group.
        elsif( m/^MAX LV(\s+)(\S+)/ ) { 
            $vghash{$vgn}->{max_lv} = $2; 
            next VGINF; }

        # Parse the current number of logical volumes for the volume group.
        elsif( m/^Cur LV(\s+)(\S+)/ ) { 
            $vghash{$vgn}->{cur_lv} = $2; 
            next VGINF; }

        # Parse the number of open logical volumes for the volume group.
        elsif( m/^Open LV(\s+)(\S+)/ )   { 
            $vghash{$vgn}->{open_lv} = $2; 
            next VGINF; }

        # Parse the number of physical volumes accessible to the volume group.
        elsif( m/^Max PV(\s+)(\S+)/ ) { 
            $vghash{$vgn}->{max_pv} = $2; 
            next VGINF; }

        # Parse the current number of physical volumes in the volume group.
        elsif( m/^Cur PV(\s+)(\S+)/ ) { 
            $vghash{$vgn}->{cur_pv} = $2; 
            next VGINF; }

        # Parse the number of active physical volumes in the volume group.
        elsif( m/^Act PV(\s+)(\S+)/ ) { 
            $vghash{$vgn}->{act_pv} = $2; 
            next VGINF; }

        # Parse the size of the volume group.
        elsif( m/^VG Size(\s+)(\S+) (\S+)/ ) {
            $vghash{$vgn}->{vg_size} = $2;
            $vghash{$vgn}->{vg_size_unit} = $3; 
            next VGINF; }

        # Parse the physical extent size and unit for one extent of volume group.
        elsif( m/^PE Size(\s+)(\S+) (\S+)/ ) {
            $vghash{$vgn}->{pe_size} = $2;
            $vghash{$vgn}->{pe_size_unit} = $3; 
            next VGINF; }

        # Parse the total number and number of free physical extents from the physical disk.
        elsif( m/^Total PE \/ Free PE(\s+)(\S+) \/ (\S+)/m ) {
            $vghash{$vgn}->{pvols}->{$pvn}->{total_pe} = $2;
            $vghash{$vgn}->{pvols}->{$pvn}->{free_pe} = $3;
            next VGINF; }

        # Parse the total number of physical extents from the volume group.
        elsif( m/^Total PE(\s+)(\S+)/ ) { 
            $vghash{$vgn}->{total_pe} = $2; 
            next VGINF; }

        # Parse the number of allocated physical extents from the volume group.
        elsif( m/^Alloc PE \/ Size(\s+)(\S+) \/ (\S+) (\S+)/ ) {
            $vghash{$vgn}->{alloc_pe} = $2;
            $vghash{$vgn}->{alloc_pe_size} = $3;
            $vghash{$vgn}->{alloc_pe_size_unit} = $4; 
            next VGINF; }

        # Parse the volume group name.
        elsif( m/^Free  PE \/ Size(\s+)(\S+) \/ (\S+) (\S+)/ ) {
            $vghash{$vgn}->{free_pe} = $2;
            $vghash{$vgn}->{free_pe_size} = $3;
            $vghash{$vgn}->{free_pe_size_unit} = $4; 
            next VGINF; }

        # Parse the volume group uuid.
        elsif( m/^VG UUID(\s+)(\S+)/ ) { 
            $vghash{$vgn}->{uuid} = $2; 
            next VGINF; }

        # Parse the logical volume name.
        elsif( m/^LV Name(\s+)(\S+)/ ) { 
            $lvn = $2; 
            $vghash{$vgn}->{lvols}->{$lvn}->{name} = $2; 
            next VGINF; }

        # Parse the logical volume size and unit.
        elsif( m/^LV Size(\s+)(\S+) (\S+)/ ) {
            $vghash{$vgn}->{lvols}->{$lvn}->{lv_size} = $2;
            $vghash{$vgn}->{lvols}->{$lvn}->{lv_size_unit} = $3; 
            next VGINF; }

        # Parse the logical volume write access.
        elsif( m/^LV Write Access(\s+)(\S+)/ ) { 
            $vghash{$vgn}->{lvols}->{$lvn}->{write_access} = $2; 
            next VGINF; }

        # Parse the logical volume status.
        elsif( m/^LV Status(\s+)(.+)/ ) { 
            $vghash{$vgn}->{lvols}->{$lvn}->{status} = $2; 
            next VGINF; }

        # Parse the number of logical extents in the logical volume.
        elsif( m/^Current LE(\s+)(\S+)/ ) { 
            $vghash{$vgn}->{lvols}->{$lvn}->{cur_le} = $2; 
            next VGINF; }

        # Parse the number of allocated logical extents in the logical volume.
        elsif( m/^Allocated LE(\s+)(\S+)/ ) { 
            $vghash{$vgn}->{lvols}->{$lvn}->{alloc_le} = $2; 
            next VGINF; }

        # Parse the allocation type for the logical volume.
        elsif( m/^Allocation(\s+)(.+)/ ) { 
            $vghash{$vgn}->{lvols}->{$lvn}->{allocation} = $2; 
            next VGINF; }

        # Parse the volume number.
        elsif( m/^LV #(\s+)(\S+)/ ) { 
            $vghash{$vgn}->{lvols}->{$lvn}->{lv_number} = $2; 
            next VGINF; }

        # Parse the number of times the logical volume is open.
        elsif( m/^# open(\s+)(\S+)/ ) { 
            $vghash{$vgn}->{lvols}->{$lvn}->{open_lv} = $2; 
            next VGINF; }

        # Parse the block device of the logical volume.
        elsif( m/^Block device(\s+)(\S+)/ ) { 
            $vghash{$vgn}->{lvols}->{$lvn}->{device} = $2; 
            next VGINF; }

        # Parse the value for the read ahead sectors of the logical volume.
        elsif( m/^Read ahead sectors(\s+)(\S+)/ ) { 
            $vghash{$vgn}->{lvols}->{$lvn}->{read_ahead} = $2; 
            next VGINF; }

        # Parse the physical disk name.
        elsif( m/^PV Name \(\#\)(\s+)(\S+) \((\S)\)/ ) {
            $pvn = $2;
            $vghash{$vgn}->{pvols}->{$pvn}->{device} = $2;
            $vghash{$vgn}->{pvols}->{$pvn}->{pv_number} = $3;
            next VGINF; }

        # Parse the status of the physical disk.
        elsif( m/^PV Status(\s+)(.+)/ ) { 
            $vghash{$vgn}->{pvols}->{$pvn}->{status} = $2; 
            next VGINF; }
    }
    return %vghash;
} # End of the get_vg_information routine.



1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Linux::LVM - Perl extension for accessing LVM data structures.

=head1 SYNOPSIS

  use Linux::LVM;
  

=head1 ABSTRACT

  The live data used in the examples is included in the DESCRIPTION area
  for your convenience and reference.
  
=head1 DESCRIPTION
  
  get_volume_group_list()	This routine will return an array that
				contains the names of the volume groups.

  @vgs = get_volume_group_list(); print "@vgs \n"; 
  Would yield the following: vg00
   
    
  get_volume_group_information($)	This routine will return all of
					the volume group information about
					the specified volume group.

  %vg = get_volume_group_information("vg00");
  foreach(sort keys %vg) {
     print "$_ = $vg{$_}\n";
  }
  Would yield the following:
     access = read/write
     act_pv = 2
     alloc_pe = 3840
     alloc_pe_size = 15
     alloc_pe_size_unit = GB
     cur_lv = 3
     cur_pv = 2
     free_pe = 864
     free_pe_size = 3.38
     free_pe_size_unit = GB
     max_lv = 256
     max_lv_size = 255.99
     max_lv_size_unit = GB
     max_pv = 256
     open_lv = 0
     pe_size = 4
     pe_size_unit = MB
     status = available/resizable
     total_pe = 4704
     uuid = BBq8si-NyRR-9ZNW-3J5e-DoRO-RBHK-ckrszi
     vg_number = 0
     vg_size = 18.38
     vg_size_unit = GB
     vgname = vg00
   
  
  get_logical_volume_information($)	This routine will return all of the
					logical volume information associated
					with the specified volume group.
 
  %lv = get_logical_volume_information("vg00");
  foreach $lvname (sort keys %lv) {
      foreach(sort keys %{$lv{$lvname}}) {
          print "$_ = $lv{$lvname}->{$_}\n"; 
      }
      print "\n"; 
  }
  Would yield the following results:
  alloc_le = 1024
  allocation = next free
  cur_le = 1024
  device = 58:0
  lv_number = 1
  lv_size = 4
  lv_size_unit = GB
  name = /dev/vg00/lvol1
  open_lv = 0
  read_ahead = 1024
  status = available
  write_access = read/write
  
  alloc_le = 1280
  allocation = next free
  cur_le = 1280
  device = 58:1
  lv_number = 2
  lv_size = 5
  lv_size_unit = GB
  name = /dev/vg00/lvol2
  open_lv = 0
  read_ahead = 1024
  status = available
  write_access = read/write
  
  alloc_le = 1536
  allocation = next free
  cur_le = 1536
  device = 58:2
  lv_number = 3
  lv_size = 6
  lv_size_unit = GB
  name = /dev/vg00/lvol3
  open_lv = 0
  read_ahead = 1024
  status = available
  write_access = read/write
   
   
  get_physical_volume_information("vg00")	This routine will return all
						of the information about the
						physical volumes assigned to
						the specified volume group.
   
  %pv = get_physical_volume_information("vg00");
  foreach $pvname (sort keys %pv) {
      foreach(sort keys %{$pv{$pvname}}) {
          print "$_ = $pv{$pvname}->{$_}\n";
      }
      print "\n";
  }
  Would yield the following results:
  device = /dev/hda3
  free_pe = 0
  pv_number = 1
  status = available / allocatable
  total_pe = 2160
  
  device = /dev/hda4
  free_pe = 864
  pv_number = 2
  status = available / allocatable
  total_pe = 2544
     
     
     
     
     
  Command Output Used In The Above Examples: /sbin/vgdisplay -v
  --- Volume group ---
  VG Name               vg00
  VG Access             read/write
  VG Status             available/resizable
  VG #                  0
  MAX LV                256
  Cur LV                3
  Open LV               0
  MAX LV Size           255.99 GB
  Max PV                256
  Cur PV                2
  Act PV                2
  VG Size               18.38 GB
  PE Size               4 MB
  Total PE              4704
  Alloc PE / Size       3840 / 15 GB
  Free  PE / Size       864 / 3.38 GB
  VG UUID               BBq8si-NyRR-9ZNW-3J5e-DoRO-RBHK-ckrszi
  
  --- Logical volume ---
  LV Name                /dev/vg00/lvol1
  VG Name                vg00
  LV Write Access        read/write
  LV Status              available
  LV #                   1
  # open                 0
  LV Size                4 GB
  Current LE             1024
  Allocated LE           1024
  Allocation             next free
  Read ahead sectors     1024
  Block device           58:0
  
  --- Logical volume ---
  LV Name                /dev/vg00/lvol2
  VG Name                vg00
  LV Write Access        read/write
  LV Status              available
  LV #                   2
  # open                 0
  LV Size                5 GB
  Current LE             1280
  Allocated LE           1280
  Allocation             next free
  Read ahead sectors     1024
  Block device           58:1
  
  --- Logical volume ---
  LV Name                /dev/vg00/lvol3
  VG Name                vg00
  LV Write Access        read/write
  LV Status              available
  LV #                   3
  # open                 0
  LV Size                6 GB
  Current LE             1536
  Allocated LE           1536
  Allocation             next free
  Read ahead sectors     1024
  Block device           58:2
  
  --- Physical volumes ---
  PV Name (#)           /dev/hda3 (1)
  PV Status             available / allocatable
  Total PE / Free PE    2160 / 0
  
  PV Name (#)           /dev/hda4 (2)
  PV Status             available / allocatable
  Total PE / Free PE    2544 / 864


=head1 SEE ALSO

L<vgdisplay>(1M)
L<lvdisplay>(1M)
L<pvdisplay>(1M)

=head1 AUTHOR

Chad Kerner, E<lt>chadkerner@yahoo.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Chad Kerner

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
