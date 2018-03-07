#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Lite;
use Sys::Hostname;
use Mojo::Redis2;

use constant VERSION => 0.4;

helper redis => sub { shift->stash->{redis} ||= Mojo::Redis2->new; };

get '/' => sub {
  my $conn = shift;
  my $host = hostname;
  if ($ENV{KUBE_NODE_NAME}){
      $conn->stash(kube_node_name => $ENV{KUBE_NODE_NAME});
  }
  $conn->stash(hostname => $host);
  $conn->stash(version => VERSION);
  $conn->delay(
      sub {
        my ($delay) = @_;
        $conn->redis->get('dnaas:uploaded_bytes', $delay->begin);
      },
      sub {
        my ($delay, $err, $message) = @_;
        if ($err){
            $conn->stash(uploaded_bytes => "Unknown");
        }
        else{
           $conn->stash(uploaded_bytes => $message);
        }
        $conn->render(template => 'index');

      },
  );
};

post '/upload' => sub {
    my $conn = shift;
    return $conn->redirect_to('/') unless my $file = $conn->param('file');
    my $size = $file->size;
    $conn->delay(
      sub {
        my ($delay) = @_;
        $conn->redis->incrby('dnaas:uploaded_bytes',$size, $delay->begin);
      },
      sub {
        my ($delay, $err, $message) = @_;
        $conn->redirect_to('/')
      },
    );
  };


app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'DNAAS /dev/null as a Service';
<h1>Hostname: <%= $hostname %> </h1>
<h1>App version: <%= $version %> </h1>
<h1>Bytes uploaded: <%= $uploaded_bytes %> </h1>
 <% if (my $node_name = stash 'kube_node_name') { %>                               
     <h1>Kubernetes Node: <%= $node_name %>  </h1>
 <%}%>

<h2> Upload  a file to /dev/null! </h2>
 %= form_for upload => (enctype => 'multipart/form-data') => begin
      %= file_field 'file'
      %= submit_button 'Upload'
% end
@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>

