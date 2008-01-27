package HTML::Entities::ConvertPictogramMobileJp;
use strict;
use warnings;
our $VERSION = '0.05';
use Encode;
use Encode::JP::Mobile;
use Params::Validate;
use HTML::Entities::ConvertPictogramMobileJp::KDDITABLE;
use File::ShareDir qw/dist_file/;
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
            join '', map { sprintf '<img localsrc="%d" />', $_ }
              map { _ezuni2number($_) }
              map { unpack 'U*', $_ }
              split //, decode "x-utf8-kddi",
              encode( "x-utf8-kddi", chr( hex $2 ) );
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

sub _ezuni2number {
    my $unicode = shift;
    $HTML::Entities::ConvertPictogramMobileJp::KDDITABLE::TABLE->{$unicode};
}

sub _convert_unicode {
    my ($carrier, $unihex) = @_;
    join '', map { sprintf '&#x%X;', unpack 'U*', $_ } split //,
      decode "x-utf8-$carrier", encode( "x-utf8-$carrier", chr( hex $unihex ) );
}

sub _convert_sjis {
    my ($carrier, $unihex) = @_;

    sprintf '&#x%s;', uc unpack 'H*', encode("x-sjis-$carrier", chr(hex $unihex));
}

1;
__END__

=encoding utf8

=for stopwords utf8 pictogram DoCoMo KDDI SJIS SoftBank Unicode KDDI-Auto au

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

HTML 中にふくまれる絵文字の Unicode 16進数値文字参照の DoCoMo 絵文字を、SoftBank/KDDI の絵文字に変換します。

DoCoMo Mova/AirHPhone の場合には、 Unicode 実体参照ではなく SJIS の実体参照に変換して出力
することに注意してください。これは、該当機種が、 SJIS の実体参照でないと表示できないためです。

au の一部端末(W41CA, W32H など) では Unicode 実体参照が表示できないため、<img localsrc="" /> 形式を採用しています。

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom@gmail.comE<gt>

=head1 SEE ALSO

L<Encode::JP::Mobile>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
