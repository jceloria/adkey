<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="noindex, nofollow">

    <title>{{ page_title }}</title>

    <link rel="stylesheet" href="{{ url('static', filename='bootstrap.min.css') }}">
    <script src="{{ url('static', filename='jquery.min.js') }}"></script>
    <script src="{{ url('static', filename='bootstrap.min.js') }}"></script>
  </head>

  <body>
    <div class="container">
      <div id="loginbox" style="margin-top:50px;" class="mainbox col-md-6 col-md-offset-3 col-sm-8 col-sm-offset-2">

      <div class="panel panel-info" >

        <div class="panel-heading">
          <div class="panel-title text-center">{{ page_title }}</div>
        </div>

        <div style="padding-top:30px" class="panel-body" >
          <form role="form" method="post" enctype="multipart/form-data">
            <div class="form-group">
              <label for="username">Username</label>
              <input class="form-control" id="username" name="username" value="{{ get('username', '') }}" type="text" required autofocus>
            </div>
            <div class="form-group">
              <label for="password">Password</label>
              <input class="form-control" id="password" name="password" type="password" required>
            </div>
            <div class="form-group">
              <label for="passphrase">Private key passphrase</label>
              <input class="form-control" id="passphrase" name="passphrase" type="password" required>
            </div>
            <div class="form-group">
              <label for="ssh-prikey">SSH private key</label>
              <textarea class="form-control" id="ssh-prikey" rows="7" name="ssh-prikey" required></textarea>
            </div>
            <div class="form-group">
              <button class="btn btn-primary" type="submit">Update SSH key</button>
            </div>
            <div class="form-group">
              %for type, text in get('alerts', []):
                <div class="alert {{ "alert-danger" if type == "error" else "alert-" + type }}" role="alert">{{ text }}</div>
              %end
            </div>
          </form>
        </div>

      </div>

    </div>
  </body>
</html>
