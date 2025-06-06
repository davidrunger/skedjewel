# Skedjewel

A scheduled Sidekiq job runner written in Crystal.

# Usage

Create a file at `config/skedjewel.yml` specifying the desired jobs schedule and other
configuration.

Example:

```yml
# config/skedjewel.yml

config:
  app_redis_db: 0
  sidekiq_redis_db: 1
  time_zone: America/Chicago

jobs_by_rails_env:
  all:
    DataMonitors::Launcher: '**:07' # hourly at 7 minutes after
    TruncateTables: '**:**' # every minute
  production:
    CheckLinks::LaunchPageFetches: '04:16' # daily at 4:16am in configured time zone
    CollectRedisMetrics: '**:%5' # every 5 minutes
    PgHero::CaptureQueryStats: '**:%10+2' # every 10 minutes, with an offset of 2 (2, 12, 22, ...)
    PgHero::CaptureQueryStats: '%2:07' # every 2 hours at 7 minutes after the hour
    PgHero::CaptureQueryStats: '%2+1:56' # every 2 hours (in odd hours) at 56 minutes after the hour
```

You can print the Skedjewel version:

```
$ skedjewel --version
```

# Installation

Start by adding something like this to your `Procfile`:

```yml
clock: bin/skedjewel
```

Now, you need to download the appropriate compiled binary and put it in the `bin/` directory of your Rails app. Binaries are released only for Linux. The latest release binary is available [here][latest-release].

[latest-release]: https://github.com/davidrunger/skedjewel/releases/latest

## In development

On your development machine (if you are using Linux), you can manually download the appropriate binary and put it in the `bin/` directory of your Rails project.

You'll also want to add `/bin/skedjewel` to your repository's `.gitignore` file.

## In production

To use Skedjewel in production, you'll need to download the appropriate binary as part of your
deploy process.

If you use Docker to build an image that can run Skedjewel, then you can add something like this to your `Dockerfile`:

```dockerfile
# Download skedjewel binary.
ARG SKEDJEWEL_VERSION=v1.1.0
RUN curl --fail -L "https://github.com/davidrunger/skedjewel/releases/download/$SKEDJEWEL_VERSION/skedjewel-$SKEDJEWEL_VERSION-linux" > skedjewel && \
  mkdir -p /app/bin && \
  mv skedjewel /app/bin/ && \
  chmod a+x /app/bin/skedjewel
```

Or, perhaps your deploy process invokes the `assets:precompile` rake task? If so, then you could `enhance` that rake task with the following:

```rb
# lib/tasks/assets.rake

Rake::Task['assets:precompile'].enhance do
  # install skedjewel
  bin_path = Rails.root.join('bin')
  skedjewel_url =
    'https://github.com/davidrunger/skedjewel/releases/download/v0.0.2/skedjewel-v0.0.2-linux'
  system(<<~SH.squish, exception: true)
    curl -L #{skedjewel_url} > skedjewel &&
      mv skedjewel #{bin_path}/ &&
      chmod a+x #{bin_path}/skedjewel
  SH
end
```

Note that a Skedjewel version is hardcoded at two places in that URL. You'll update Skedjewel by
updating those version numbers.

## An easier-to-install alternative: Schedjewel

[Schedjewel][schedjewel] is a Ruby gem with very similar functionality. It's also maintained by me,
@davidrunger.

Installing Schedjewel as a gem in your project is simpler than installing the Skedjewel binaries, so
if you're looking for convenience and simplicity, you might consider using Schedjewel instead. The
primary downside of using Schedjewel rather than Skedjewel is that Schedjewel (the Ruby gem) uses
more memory.

[schedjewel]: https://github.com/davidrunger/schedjewel

# Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davidrunger/skedjewel.

# License

This library is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
