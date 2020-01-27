use strict;
use warnings;

use Test::More;
use Test::Mojo;

{
    use Mojolicious::Lite;

    plugin 'ClientIP', ignore_default => [qw(127.0.0.0/8 172.16.0.0./12 192.168.0.0/16)];

    get '/' => sub {
        my $c = shift;
        $c->render(text => $c->client_ip);
    };

    app->start;
}

note "10.0.0.0/8 is authorized";

my $web = Test::Mojo->new;
my $xff = 'X-Forwarded-For';

$web->get_ok('/')
    ->content_is('127.0.0.1');

$web->get_ok('/', { $xff => '192.168.2.1' })
    ->content_is('127.0.0.1');

$web->get_ok('/', { $xff => '10.1.2.3' })
    ->content_is('10.1.2.3');

$web->get_ok('/', { $xff => '192.168.2.1, 10.0.0.1' })
    ->content_is('10.0.0.1');

$web->get_ok('/', { $xff => '192.168.2.1, 127.1.2.3' })
    ->content_is('127.0.0.1');

done_testing;
