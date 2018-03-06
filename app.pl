#!/usr/bin/env perl
use Mojolicious::Lite;
use Sys::Hostname;


get '/' => sub {
  my $conn = shift;
  my $host = hostname;
  $conn->stash(hostname => $host);
  $conn->render(template => 'index');
};


app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'DNAAS /dev/null as a Service';
<h1>Hostname <%= $hostname %> </h1>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>

