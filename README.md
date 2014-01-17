# Crontasks for Opsworks

Then add a new layer `cronrunner` to your stack.  Add `crontasks` as a custom deploy command in your `cronrunner` layer.  You'll make a specific server run in two layers: it's orignal layer *and* cronrunner.

Next, add the following to your custom JSON:

    "crontasks": {
      "my-app": {
        "some-cron-task": {
          "layers": ["rails-app"],
          "hour": "*",
          "minute": "*",
          "wd": "{app_root}",
          "cmd": "RAILS_ENV={rails_env} bundle exec echo time >> {app_root}/time.out"
        }
      }
    },

    ...

  Now, when you deploy, that server will have the given crontask installed.