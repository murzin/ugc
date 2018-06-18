package UGC::Ajax;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

use DBI;

sub post_comment {
    my $c = shift;
    my $conf = $c->config;

    my $cmt_text = $c->param('cmt_text');
    my $cmt_level = $c->param('cmt_level');
    my $parent_cmt_id = $c->param('parent_cmt_id');


    my $data_source = sprintf "DBI:mysql:database=%s;host=%s;port=%s", @$conf{qw(mysql_db mysql_host mysql_port)};
    my $dbh = DBI->connect($data_source, $c->config->{mysql_user}, $c->config->{mysql_password});
    my $rows = $dbh->do("insert into comments (cmt_text, cmt_dt, parent_cmt_id, msg_id, cmt_level) 
                         values (?, now(), ?, 1, ?)", undef, $cmt_text, $parent_cmt_id || undef, $cmt_level);
    my ($row_id) = $dbh->selectrow_array("select last_insert_id()");

    return $c->render(text=>$row_id);
}

1;
