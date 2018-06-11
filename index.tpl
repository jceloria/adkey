<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="noindex, nofollow">

    <title>{{ page_title }}</title>

    <link rel="stylesheet" href="{{ url('static', filename='style.css') }}">
  </head>

  <body>
    <main>
      <h1>{{ page_title }}</h1>

      <form method="post">
        <label for="username">Username</label>
        <input id="username" name="username" value="{{ get('username', '') }}" type="text" required autofocus>

        <label for="password">Password</label>
        <input id="password" name="password" type="password" required>

        <label for="ssh-pubkey">SSH public key</label>
        <input id="ssh-pubkey" name="ssh-pubkey" type="text" required>

        <button type="submit">Update SSH public key</button>
      </form>

      <div class="alerts">
        %for type, text in get('alerts', []):
          <div class="alert {{ type }}">{{ text }}</div>
        %end
      </div>
    </main>
  </body>
</html>
