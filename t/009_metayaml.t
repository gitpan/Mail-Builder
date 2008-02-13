# -*- perl -*-

use Test::More;

eval "use Test::YAML::Meta";

plan skip_all => "Test::YAML::Meta required for testing META.yml" if $@;
meta_yaml_ok();
meta_spec_ok('META.yml','1.3');