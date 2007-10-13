# -*- perl -*-

# t/003_podcoverage.t - check pod coverage

use Test::Pod::Coverage tests=>5;

pod_coverage_ok( "Mail::Builder", "POD is covered" );
pod_coverage_ok( "Mail::Builder::Address", "POD is covered" );
pod_coverage_ok( "Mail::Builder::Attachment", "POD is covered" );
pod_coverage_ok( "Mail::Builder::Image", "POD is covered" );
pod_coverage_ok( "Mail::Builder::List", "POD is covered" );