<a href="https://commons.wikimedia.org/wiki/File:DSC09108_-_Guyanan_Red_Howler_Monkey_(36384553204).jpg" title="Howler Monkey on Wikipedia">
<img align="right" width="100" height="150" src="howler.jpeg" alt="Howler monkey">
</a>

# Howl

Because somebody should yell at you when your `master` build breaks.

`howl` is a tool that sends messages to Slack or Discord when your default
branch build fails, typically on `main` or `master`. It is designed to be
triggered on your CI (continuous integration) system when a failure occurs on
your default branch. You can use it as a GitHub Action or as a standalone
program, which can be installed with [Hermit].

[Hermit]: https://cashapp.github.io/hermit

## Slack setup

Set up a [GitHub secret] called `SLACK_WEBHOOK_URL` with your
[Slack Webhook] URL, for example

    https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX

[Slack Webhook]: https://api.slack.com/messaging/webhooks
[GitHub secret]: https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions

### Optional inputs

To use a channel other than the default channel set up in the Slack App bound
to the webhook, set the `SLACK_CHANNEL` environment variable, for example

    export SLACK_CHANNEL=C0000000000

For a more customized message or @-mentions, set the `SLACK_TEXT` environment
variable, for example

    export SLACK_TEXT="<!here> 🚒"

## Discord setup

Set up a [GitHub secret] called `DISCORD_WEBHOOK_URL` with your
[Discord Webhook] URL for the target discord channel, for example

    https://discord.com/api/webhooks/1000000000000000000/XXXXXXXX-xxxxxxxxxxxxxxxxx

[Discord Webhook]: https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks
[GitHub secret]: https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions

### Optional inputs

For a more customized message or @-mentions, set the `DISCORD_TEXT` environment
variable, for example

    export DISCORD_TEXT="@here 🚒"

## Local Testing

You can test the integration locally with

    export SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
    export DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/1000000000000000000/XXXXXXXX-xxxxxxxxxxxxxxxxx'
    howl

## GitHub Action usage

Use the `foxygoat/howl@v2` in you GitHub Actions Workflow that runs on the
default branch, for example:

```yaml
name: ci
on:
  push:
    branches: [main]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        run: make ci
  howl-on-fail:
    runs-on: ubuntu-latest
    needs: [ci]
    if: always() && contains(join(needs.*.result, ','), 'failure')
    steps:
      - uses: foxygoat/howl@v2
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
          SLACK_CHANNEL: C0000000000 # optional; channel ID
          SLACK_TEXT: <!here> # optional; text or @-mention
          DISCORD_WEBHOOK_URL: ${{ secrets.DISCORD_WEBHOOK_URL }}
          DISCORD_TEXT: @here # optional; text or @-mention
```
