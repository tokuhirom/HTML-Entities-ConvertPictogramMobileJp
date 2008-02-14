use inc::Module::Install;
name 'HTML-Entities-ConvertPictogramMobileJp';
all_from 'lib/HTML/Entities/ConvertPictogramMobileJp.pm';

requires 'Encode::JP::Mobile' => 0.24;
requires 'HTTP::MobileAgent' => 0.26;
requires 'Params::Validate' => 0.89;

build_requires 'Test::More';
build_requires 'YAML';
use_test_base;
auto_include;
WriteAll;
