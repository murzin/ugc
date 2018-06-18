package UGC;

use Mojo::Base 'Mojolicious';

sub startup {
    my $app = shift;

    $app->plugin('Config' => {file => $app->home.'/ugc.conf'});

    my $log = $app->log;

    $log->warn("Mojolicious Mode is " . $app->mode);
    $log->warn("Log Level        is " . $log->level);

    my $r = $app->routes;
    $r->any('/')->to('BaseFunc#index');
    $r->any('/message')->to('BaseFunc#message');

    $r->any('/post_comment')->to('Ajax#post_comment');
}

1;
