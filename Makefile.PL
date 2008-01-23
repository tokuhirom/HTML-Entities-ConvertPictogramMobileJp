use inc::Module::Install;
name 'HTML-Entities-ConvertPictogramMobileJp';
all_from 'lib/HTML/Entities/ConvertPictogramMobileJp.pm';

requires 'Encode::JP::Mobile' => 0.24;
requires 'HTTP::MobileAgent';
requires 'Params::Validate';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
