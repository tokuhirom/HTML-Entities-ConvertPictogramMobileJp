use strict;
use warnings;
use Encode;
use Test::Base;
use HTTP::MobileAgent;
use HTML::Entities::ConvertPictogramMobileJp;

filters {
    input => [qw/yaml convert/],
};

sub convert {
    my $block = shift;
    convert_pictogram_entities(
        mobile_agent => HTTP::MobileAgent->new( $block->{user_agent} ),
        html         => $block->{html},
    );
}

__END__

=== i2v
--- input
user_agent: Vodafone/1.0/V904SH/SHJ001/SN123456789012 Browser/VF-NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1
html: "&#xE63E;&#xE65C;"
--- expected: &#xE04A;&#xE434;

=== i2e
--- input
user_agent: KDDI-SA31 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0
html: "&#xE63E;&#xE65C;"
--- expected: &#xEF60;&#xF0EC;

=== i2i(foma)
--- input
user_agent: DoCoMo/2.0 SH903i(c100;TB;W24H16)
html: "&#xE63E;&#xE65C;"
--- expected: &#xE63E;&#xE65C;

=== i2i(mova)
--- input
user_agent: DoCoMo/1.0/D501i
html: "&#xE63E;&#xE65C;"
--- expected: &#xF89F;&#xF8BD;

=== i2airh
--- input
user_agent: Mozilla/3.0(WILLCOM;SANYO/WX310SA/2;1/1/C128) NetFront/3.3
html: "&#xE63E;&#xE65C;"
--- expected: &#xF89F;&#xF8BD;

=== v2i(foma)
--- input
user_agent: DoCoMo/2.0 SH903i(c100;TB;W24H16)
html: "&#xE537;"
--- expected: &#xE732;

