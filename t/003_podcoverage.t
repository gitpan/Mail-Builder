# -*- perl -*-

# t/003_podcoverage.t - check pod coverage

use Test::More tests=>5;
eval "use Test::Pod::Coverage";
plan skip_all => "Test::Pod::Coverage required for testing POD coverage" if $@;

pod_coverage_ok( "Mail::Builder", "POD is covered" );
pod_coverage_ok( "Mail::Builder::Address", "POD is covered" );
pod_coverage_ok( "Mail::Builder::Attachment", "POD is covered" );
pod_coverage_ok( "Mail::Builder::Image", "POD is covered" );
pod_coverage_ok( "Mail::Builder::List", "POD is covered" );