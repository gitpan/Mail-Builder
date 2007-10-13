# -*- perl -*-

# t/005_list.t - check module for list handling

use Test::More tests => 17;

use Mail::Builder;

my $list = Mail::Builder::List->new('Mail::Builder::Address');

isa_ok ($list, 'Mail::Builder::List');
is($list->type, 'Mail::Builder::Address');
is($list->length, 0);
ok($list->add('test@test.com'), 'Add new item');
is($list->length, 1);
ok($list->add('test2@test2.com','test'), 'Add new item');
is($list->length, 2);
is(scalar($list->list),2);
isa_ok($list->item(0),'Mail::Builder::Address');
isa_ok($list->item(1),'Mail::Builder::Address');
is($list->item(2),undef);
is($list->join(', '),'<test@test.com>, "test" <test2@test2.com>');
ok($list->reset,'Reset list');
is($list->length, 0);
my $address = Mail::Builder::Address->new('test3@test3.com','test3');
ok($list->add($address));
is($list->length, 1);
my $fake_object = bless {},'Fake';
eval {
	$list->add($fake_object);
};
like($@,qr/Invalid item added to list/);