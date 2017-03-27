require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerSlack do
    it 'should be a plugin' do
      expect(Danger::DangerSlack.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.slack
        @my_plugin.api_token = 'hoge'
      end

      it 'initialize' do
        expect(@my_plugin.api_token).to eq 'hoge'
      end

      it 'members' do
        stub_request(:get, 'https://slack.com/api/users.list')
          .with(query: { token: 'hoge' })
          .to_return(
            body: '{"members":[{"hoge":"fuga"}]}',
            status: 200
          )
        expect(@my_plugin.members).to eq [{ 'hoge' => 'fuga' }]
      end

      it 'channels' do
        stub_request(:get, 'https://slack.com/api/channels.list')
          .with(query: { token: 'hoge' })
          .to_return(
            body: '{"channels":[{"hoge":"fuga"}]}',
            status: 200
          )
        expect(@my_plugin.channels).to eq [{ 'hoge' => 'fuga' }]
      end

      it 'notify with text' do
        stub_request(:post, 'https://slack.com/api/chat.postMessage')
          .with(query: hash_including(token: 'hoge'))
          .to_return(
            body: '{"ok":true}',
            status: 200
          )
        @my_plugin.notify(channel: '#general', text: 'fuga')
        expect(WebMock).to have_requested(:post, 'https://slack.com/api/chat.postMessage')
          .with(query: hash_including(token: 'hoge',
                                      channel: '#general',
                                      text: 'fuga'))
      end

      it 'notify' do
        stub_request(:post, 'https://slack.com/api/chat.postMessage')
          .with(query: hash_including(token: 'hoge'))
          .to_return(
            body: '{"ok":true}',
            status: 200
          )
        @my_plugin.warn('foo')
        @my_plugin.markdown('bar')
        @my_plugin.markdown('hoge', file: 'foo', line: 1)
        @my_plugin.notify(channel: '#general')
        expect(WebMock).to have_requested(:post, 'https://slack.com/api/chat.postMessage')
          .with(query: hash_including(token: 'hoge',
                                      channel: '#general',
                                      attachments: [{
                                        text: 'foo',
                                        color: 'warning'
                                      }, {
                                        text: 'bar',
                                        fields: []
                                      }, {
                                        text: 'hoge',
                                        fields: [
                                          {
                                            title: 'file',
                                            value: 'foo',
                                            short: true
                                          }, {
                                            title: 'line',
                                            value: 1,
                                            short: true
                                          }
                                        ]
                                      }].to_json))
      end
    end
  end
end
