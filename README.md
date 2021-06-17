# Howl

Because somebody should yell at you when your `master` build breaks.

Howl is a GitHub Action. It writes a custom Slack message with an
optional `@here` or `@project-owners` to your preferred Slack channel.

<div style="text-align:center;width:100%">
	<img src="howler.jpeg" alt="Howler Monkey"/>
	<br/>
	<sub>Howler Monkey -
		<a href="https://commons.wikimedia.org/wiki/File:DSC09108_-_Guyanan_Red_Howler_Monkey_(36384553204).jpg">
			Wikimedia, CC BY-SA 2.0
		</a>
	</sub>
</div>

## Set up Slack token

Set up a repository or organisation secrets with your [Incoming Slack
Webhook] token. Use, for instance, `SLACK_TOKEN`. The content should
look similar to

	T01A*******/B0259*****/GcXTiEux*******************

Taken from the Slack provided Incoming Webhook URL:

	https://hooks.slack.com/services/T01A*******/B0259*****/GcXTiEux*******************

[Incoming Slack Webhook]: https://slack.com/intl/en-au/help/articles/115005265063-Incoming-webhooks-for-Slack

## Use with GitHub Action Workflow

```yaml
name: ci
on:
  push:
    branches: [ master ]
  pull_request:

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
      run: make
  howl-on-failure:
    runs-on: ubuntu-latest
    needs: [ci]
    if: always && github.event_name == 'push' && needs.ci.result == 'failure'
    steps:
    - uses: foxygoat/howl@v1
      env:
        SLACK_TOKEN: ${{ secrets.SLACK_TOKEN }}
        SLACK_TEXT: <!here|here>
        #CHANNEL: D01J5K3RLQJ       # optional; use if different from slack webhook setup, take from channel URL
```

## Use with external CI system

```yaml
name: slack-notify
on:
  # choose one of status, check_run, check_suite
  status:
  check_run:
    types: [completed]
  check_suite:
    types: [completed]
jobs:
  slack-notify:
    runs-on: ubuntu-latest
    steps:
    - if: ${{ contains(github.event.branches.*.name, 'master') && (github.event.state == 'failure' || github.event.state == 'error')}}
      uses: foxygoat/howl@v1
      env:
        SLACK_TOKEN: ${{ secrets.SLACK_TOKEN }}
        BUILD_URL: ${{ github.event.target_url }}
        #SLACK_TEXT: <!here|here>   # optional; text or @-mention project owners by slack member ID, e.g. <@U0LAN0Z89>
        #CHANNEL: D01J5K3RLQJ       # optional; use if different from slack webhook setup, take from channel URL
```
