require 'cora'
require 'siri_objects'
require 'trakt'

#######
######

class SiriProxy::Plugin::SiriTrakt < SiriProxy::Plugin
  def initialize(config)
    Trakt::api_key = config['trakt_api_key']
    Trakt::username = config['trakt_username']
    Trakt::password = config['trakt_password']
  end

  def generate_calendar_response(ref_id)
    object = SiriAddViews.new
    object.make_root(ref_id)
    if Trakt::User::Calendar.new.results.empty?
      object.views << SiriAssistantUtteranceView.new("Looks like nothing's on tonight. Might I suggest a good movie?")
      object
    else
      object.views << SiriAssistantUtteranceView.new("The following shows are airing tonight:")
      episode_count = 0
      episodes = Trakt::User::Calendar.new.results.first['episodes']
      episodes_airing = ""
      episodes.each do |calendar_result|
        episode_count = episode_count + 1
        if episodes.count == episode_count
          episodes_airing << " and #{calendar_result['show']['title']}"
        else
          episodes_airing << "#{calendar_result['show']['title']}"
        end
        unless episodes.count == 1 or (episode_count == (episodes.count - 1)) or episode_count = episodes.count
          episodes_airing << ", "
        end


      end
      object.views << SiriAssistantUtteranceView.new(episodes_airing)
      object
    end
  end

  listen_for /what's on tv tonight/i do
    send_object self.generate_calendar_response(last_ref_id)
    request_completed
  end

end
