module Danger
  # Notify danger reports to slack.
  #
  # The following steps is required for using danger-slack plugin.
  #    1. create bot in https://my.slack.com/services/new/bot
  #    2. invite created bot user to channel in slack app
  #
  # The bot's token is starting from `xoxb-`
  #
  # @example Configure credentials to access the Slack API
  #          slack.api_token = YOUR_API_TOKEN
  #
  # @example Get channels
  #          message slack.channels.map {|channel| channel['name']}.join "\n"
  #
  # @example Get members
  #          message slack.members.map {|member| member['name'] }.join "\n"
  #
  # @example Notify danger reports to slack
  #          slack.notify(channel: '#your_channel')
  #
  # @example Post message to slack
  #          slack.notify(channel: '#your_channel', text: 'hello danger')
  #
  # @see  duck8823/danger-slack
  # @tags slack
  #
  class DangerSlack < Plugin
    # API token to authenticate with SLACK API
    #
    # @return [String]
    attr_accessor :api_token

    def initialize(dangerfile)
      super(dangerfile)

      @api_token = ENV['SLACK_API_TOKEN']

      @conn = Faraday.new(url: 'https://slack.com/api')
    end

    # get slack team members
    # For more information, see also https://api.slack.com/methods/users.list
    #
    # @return [[Hash]]
    def members
      res = @conn.get 'users.list', token: @api_token
      Array(JSON.parse(res.body)['members'])
    end

    # get slack team channels
    # For more information, see also https://api.slack.com/methods/channels.list
    #
    # @return [[Hash]]
    def channels
      res = @conn.get 'channels.list', token: @api_token
      Array(JSON.parse(res.body)['channels'])
    end

    # get slack team groups (private channels)
    # For more information, see also http://api.slack.com/methods/groups.list
    #
    # @return [[Hash]]
    def groups
      res = @conn.get 'groups.list', token: @api_token
      Array(JSON.parse(res.body)['groups'])
    end

    # notify to Slack
    #
    # @param   [String] channel
    #          It is channel to be notified, defaults to '#general'
    # @param   [String] text
    #          text message posted to slack, defaults to nil.
    #          if nil, this method post danger reports to slack.
    # @param   [Hash] **opts
    # @return [void]
    def notify(channel: '#general', text: nil, **opts)
      attachments = text.nil? ? report : []
      text ||= '<http://danger.systems/|Danger> reports'
      @conn.post do |req|
        req.url 'chat.postMessage'
        req.params = {
          token: @api_token,
          channel: channel,
          text: text,
          attachments: attachments.to_json,
          link_names: 1,
          **opts
        }
      end
    end

    private

    # get status_report text
    # @return [[Hash]]
    def report
      attachment = status_report
                   .reject { |_, v| v.empty? }
                   .map do |k, v|
        case k.to_s
        when 'errors' then
          {
            text: v.join("\n"),
            color: 'danger'
          }
        when 'warnings' then
          {
            text: v.join("\n"),
            color: 'warning'
          }
        when 'messages' then
          {
            text: v.join("\n"),
            color: 'good'
          }
        when 'markdowns' then
          v.map do |val|
            {
              text: val.message,
              fields: fields(val)
            }
          end
        end
      end
      attachment.flatten
    end

    # get markdown fields
    # @return [[Hash]]
    def fields(markdown)
      fields = []
      if markdown.file
        fields.push(title: 'file',
                    value: markdown.file,
                    short: true)
      end
      if markdown.line
        fields.push(title: 'line',
                    value: markdown.line,
                    short: true)
      end
      fields
    end
  end
end
