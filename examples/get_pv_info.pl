
use Linux::LVM;

%hash = get_pv_info("/dev/hdb");

foreach(sort keys %hash) {
    print "$_ = $hash{$_} \n";
}
