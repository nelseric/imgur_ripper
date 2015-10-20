require 'rest-client'
require 'nokogiri'
require 'pry'
require 'uri'

module ImgurRipper
  class Album
    attr_accessor :url

    def self.applies?(url)
      new(url: url).valid?
    end

    def initialize(url:, **_extra)
      url = 'https://' + url if URI.parse(url).scheme.nil?
      @url = URI.parse url
    end

    def album_id
      url.path.match(%r{/a/(\w+)})[1]
    end

    def valid?
      (url.hostname.match(/imgur\.com$/) && album_id) ? true : false
    end

    def info
      @info ||= JSON.parse(ImgurRipper.client.album_info album_id)['data']
    end

    # This can be slow, especially the first time
    def archive
      @archive ||= RestClient.get info['link'] + '/zip'
    end

    def images
      info['images'].map { |image| Image.new image }
    end

    def to_json(*options)
      as_json.to_json(*options)
    end

    def as_json(*_options)
      {
        JSON.create_id => self.class.name,
        url: url
      }
    end

    def self.json_create(data)
      new(url: data['url'])
    end
  end
end