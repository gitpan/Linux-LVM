
use Linux::LVM;

%hash = get_lv_info("/dev/vg00/software");

foreach(sort keys %hash) {
    print "$_ = $hash{$_} \n";
}
