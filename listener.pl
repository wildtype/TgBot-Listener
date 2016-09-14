#!/usr/bin/env perl
use Mojolicious::Lite;
use Redis::Fast;

my $redis           = Redis::Fast->new;
my @valid_endpoints = split ',', $ENV{TGBOT_VALID_ENDPOINTS};
my $base_path       = $ENV{TGBOT_BASE_PATH} || '';
$redis->select($ENV{TGBOT_REDIS_DB}) if $ENV{TGBOT_REDIS_DB};

post $base_path . '/:endpoint' => sub {
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
