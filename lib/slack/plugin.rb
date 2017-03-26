module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  shunsuke maeda/danger-slack
  # @tags monday, weekends, time, rattata
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
    #
    # @return [[Hash]]
    def members
      res = @conn.get 'users.list', token: @api_token
      Array(JSON.parse(res.body)['members'])
    end

    # get slack team members
    #
    # @return [[Hash]]
    def channels
      res = @conn.get 'channels.list', token: @api_token
      Array(JSON.parse(res.body)['channels'])
    end

    # notify to Slack
    # A method that you can call from your Dangerfile
    # @return [void]
    def notify(channel:, text: nil, **_opts)
      attachments = []
      text, attachments = report if text.nil?
      @conn.post do |req|
        req.url 'chat.postMessage'
        req.params = {
          token: @api_token,
          channel: channel,
          text: text,
          attachments: attachments,
          link_names: 1,
          **_opts
        }
      end
    end

    private

    # get status_report text
    # @return [String]
    def report
      attachment = status_report
                   .select { |_, v| !v.empty? }
                   .map do |k, v|
        text = v.join "\n"

        case k.to_s
        when 'errors' then
          {
            title: 'errors',
            text: text,
            color: 'danger'
          }
        when 'warnings' then
          {
            title: 'warnings',
            text: text,
            color: 'warning'
          }
        when 'messages' then
          {
            title: 'messages',
            text: text,
            color: 'good'
          }
        end
      end
      text = status_report
             .select { |k, _v| k == 'markdown' }
             .map { |_, v| v }.join "\n"
      [text, attachment]
    end
  end
end
