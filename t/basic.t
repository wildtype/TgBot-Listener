use Test::More;
use Test::Mojo;

$ENV{TGBOT_BASE_PATH} = '/mypath';
$ENV{TGBOT_VALID_ENDPOINTS} = 'nanochan,hakase';
$ENV{TGBOT_REDIS_DB} = 2;

use FindBin;
require "$FindBin::Bin/../listener.pl";
my $t = Test::Mojo->new;
my $r = Redis::Fast->new;
$r->select(2);

subtest "Telegram chat listener bot" => sub {
  subtest "it takes basepath and endpoints from environment variable" => sub {
    $t->post_ok('/mypath/nanochan', 'message to nanochan')->status_is(200);
    $t->post_ok('/mypath/hakase', 'message to hakase')->status_is(200);
  };
  subtest "it store request body into redis set" => sub {
    is $r->spop('tgbot__listener-nanochan'), 'message to nanochan';
    is $r->spop('tgbot__listener-hakase'), 'message to hakase';
  };
};

done_testing;
