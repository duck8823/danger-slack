# danger-slack

Notify danger reports to slack.

## slack setup

The following steps is required for using danger-slack plugin.  

    1. create bot in https://my.slack.com/services/new/bot  
    2. invite created bot user to channel in slack app

`slack.api_token` or `SLACK_API_TOKEN` are the bot's token starting from `xoxb-`

## Installation

    $ gem install danger-slack

## Usage
### How to set your Slack API token
In Dangerfile,
```ruby
slack.api_token = 'SLACK_API_TOKEN'
```

or 

Set Environment variable `SLACK_API_TOKEN`
  
### methods
Get channels
```ruby
slack.channels
```

Get members
```ruby
slack.members
```

Get groups
```ruby
slack.groups
```

Notify danger reports to slack
```ruby
slack.notify(channel: '#your_channel')
```

Post message to slack
```ruby
slack.notify(channel: '#your_channel', text: 'hello danger')
```
