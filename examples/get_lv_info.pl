
use Linux::LVM;

%hash = get_lv_info("/dev/vg00/code");

foreach(sort keys %hash) {
    print "$_ = $hash{$_} \n";
}
