#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Lite;
use Sys::Hostname;

use constant VERSION => 0.3;

get '/' => sub {
  my $conn = shift;
  my $host = hostname;
  if ($ENV{KUBE_NODE_NAME}){
      $conn->stash(kube_node_name => $ENV{KUBE_NODE_NAME});
  }
  $conn->stash(hostname => $host);
  $conn->stash(version => VERSION);
  
  $conn->render(template => 'index');
};


app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'DNAAS /dev/null as a Service';
<h1>Hostname: <%= $hostname %> </h1>
<h1>App version: <%= $version %> </h1>
<% if (my $node_name = stash 'kube_node_name') {%>                                  
    <h1>Kubernetes Node: <%= $node_name %>  </h1>
<%}%>
@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>

