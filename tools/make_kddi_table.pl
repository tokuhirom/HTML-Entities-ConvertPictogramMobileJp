use strict;
use warnings;
use YAML;
use Data::Dumper;

# make map from Encode-JP-Mobile/dat/kddi-table.yaml.

$Data::Dumper::Terse++;

my $ret = {};
my $dat = YAML::Load(join '', <>);
for my $row (@$dat) {
    $ret->{ hex $row->{unicode_auto} } = $row->{number};
}
$ret = Dumper($ret);

print <<"...";
package HTML::Entities::ConvertPictogramMobileJp::KDDITABLE;
use strict;
use warnings;

our \$TABLE = $ret;

1;
...
