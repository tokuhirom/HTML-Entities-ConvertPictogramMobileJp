package HTML::Entities::ConvertPictogramMobileJp;
use strict;
use warnings;
our $VERSION = '0.01';
use Encode;
use Encode::JP::Mobile;
use Params::Validate;
use base 'Exporter';
our @EXPORT = qw/convert_pictogram_entities/;

sub convert_pictogram_entities {
    validate(@_ => +{
        mobile_agent => +{ isa => 'HTTP::MobileAgent' },
        html  => 1,
    });
    my %args = @_;

    my $content = $args{html};
    my $agent = $args{mobile_agent};
    $content =~ s{(&\#x([A-Z0-9]+);)}{
        if ($agent->is_softbank) {
            _convert_unicode('softbank', $2)
        } elsif ($agent->is_ezweb) {
            _convert_unicode('kddi', $2)
        } elsif ($agent->is_docomo && $agent->is_foma) {
            _convert_unicode('docomo', $2)
        } elsif (($agent->is_docomo && !$agent->is_foma) || $agent->is_airh_phone) {
            _convert_sjis('docomo', $2);
        } else {
            $1;
        }
    }ge;
    $content;
}

sub _convert_unicode {
    my ($carrier, $unihex) = @_;
    sprintf '&#x%X;', unpack 'U*', decode "x-utf8-$carrier", encode( "x-utf8-$carrier", chr( hex $unihex ));
}

sub _convert_sjis {
    my ($carrier, $unihex) = @_;

    sprintf '&#x%s;', uc unpack 'H*', encode("x-sjis-$carrier", chr(hex $unihex));
}

1;
__END__

=encoding utf8

=for stopwords utf8 pictogram DoCoMo KDDI SJIS SoftBank Unicode KDDI-Auto

=head1 NAME

HTML::Entities::ConvertPictogramMobileJp - convert pictogram entities

=head1 SYNOPSIS

    use HTTP::MobileAgent;
    use HTML::Entities::ConvertPictogramMobileJp;
    convert_pictogram_entities(
        mobile_agent => HTTP::MobileAgent->new,
        html  => "&#xE001",
    );

=head1 DESCRIPTION

HTML::Entities::ConvertPictogramMobileJp is Japanese mobile phone's pictogram converter.

HTML 中にふくまれる絵文字の Unicode 16進数値文字参照を、キャリヤ相互に変換します。

KDDI の絵文字領域は SoftBank の絵文字の Unicode とかぶっているため、 KDDI の絵文字が HTML
中に含まれていても変換しません。悪しからず。DoCoMo/SoftBank から KDDI の絵文字への変換
には対応しています。 KDDI からの絵文字変換を行いたい場合には KDDI-Auto を使用してください。
KDDI-Auto に関しては、L<Encode::JP::Mobile> のドキュメントを参照してください。

    o DoCoMo => KDDI
    o DoCoMo => SoftBank
    o SoftBank => KDDI
    o SoftBank => DoCoMo
    x KDDI => SoftBank
    x KDDI => DoCoMo

DoCoMo Mova/AirHPhone の場合には、 Unicode 実体参照ではなく SJIS の実体参照に変換して出力
することに注意してください。これは、該当機種が、 SJIS の実体参照でないと表示できないためです。

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom@gmail.comE<gt>

=head1 SEE ALSO

L<Encode::JP::Mobile>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
