#!/usr/bin/env perl
use Mojolicious::Lite;
use Redis::Fast;

my $redis = Redis::Fast->new;
$redis->select($ENV{TGBOT_REDIS_DB}) if $ENV{TGBOT_REDIS_DB};
my @valid_endpoints = split ',', $ENV{TGBOT_VALID_ENDPOINTS};

post '/:endpoint' => sub {
  my $c        = shift;
  my $endpoint = $c->param('endpoint');
  my $queue    = 'tgbot__listener-' . $endpoint;
  my $payload  = $c->req->body;

  if (grep $_ eq $endpoint, @valid_endpoints) {
    $redis->sadd($queue, $payload);
    $c->render(text => 'ok');
  } else {
    $c->res->code(404);
    $c->render(text => 'invalid route');
  }
};

app->start;
