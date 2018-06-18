package UGC::BaseFunc;

use DBI;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

use strict;
use warnings;

sub index {
    my $c = shift;

    return $c->render;
}

sub message {
    my $c = shift;
    my $conf = $c->config;

    my $data_source = sprintf "DBI:mysql:database=%s;host=%s;port=%s", @$conf{qw(mysql_db mysql_host mysql_port)};
    my $dbh = DBI->connect($data_source, $c->config->{mysql_user}, $c->config->{mysql_password});
    my $message = $dbh->selectall_hashref("select msg_id, msg_title, msg_text from messages where msg_id = 1", 'msg_id')->{1};

    my $comments_prep = $dbh->selectall_arrayref("select cmt_id, cmt_text, cmt_dt, parent_cmt_id, msg_id, cmt_level
                                                  from comments
                                                  order by cmt_level, cmt_dt desc");
    $_->[3] += 0 for @$comments_prep; # normilize NULLs
    my $comments;
    # preparing for output
    # CTE iplemente in MySQL 8, assuming having elder one
    for my $r (@$comments_prep) {
        last if $r->[5] > 1; # first level first
        push @$comments, $r;
        push @$comments, find_childs($r, $comments_prep);
    }

    return $c->render(
        msg_title   => $message->{msg_title}, 
        msg_text    => $message->{msg_text},
        comments    => $comments,
    );
}


# helpers

sub find_childs {
    my $pr  = shift;
    my $res = shift;
    my @ret;
    for my $r (@$res) {
        if ($pr->[0] == $r->[3]) {
            push @ret, $r;
            push @ret, find_childs($r, $res);
        }
    }
    return @ret;
}

1;
