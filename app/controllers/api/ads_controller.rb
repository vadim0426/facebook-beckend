require 'facebook_ads'

class Api::AdsController < ApplicationController
  before_action :init_session

  def index
    ads = get_ads(@ad_account, @session)
    render json: ads.to_json
  end

  def create
    payload = JSON.parse request.body.read
    begin
      ad = insert_ad(payload, @ad_account, @session)
      render json: ad
    rescue => e
      render json: {"message" => e.message, "name" => "Error",  }, :status => 500, :content_type=>'application/json'
    end
  end



  private

  def init_session
    @session = FacebookAds::Session.new(access_token: "EAAHEF24bvccBAEjaOzL6rZBrP5Yw5ViwzhZB9QQZCvXel2m7ZCZAo7CQiZCNbc5Vyo4UJmQSkh8ZAGBUnlQy5FUwvKphZBynBoBjR3kZAuLHSFH7DyAFX6A0CLYwXiWsm650QfMK3yBmjLfE2rmJJn67vJOmHzgGUd2ZB9bDzqsWivh21q4IWyEHyFrFLZAHZACZB40YZD",
                                       app_secret: "b50e66f86f3e55e4c460585ed53cf5d2")
    @ad_account = FacebookAds::AdAccount.get('act_115716852503656', 'name', @session)
  end

  # Get ads
  # Return all ads for Campaign and Ad Set
  # In perspective should take Campaign ID and AdSet ID to take limited scope

  def get_ads(ad_account, session)
    dataSet = { "ads" => [] }

    ad_account.ads(fields: 'name').each do |ad|
      dataSet['ads'] << {
          "id" => ad.id,
          "name" => ad.name,
          "thumbnail_url" => FacebookAds::AdCreative.get(ad.creative.id, 'thumbnail_url', session).thumbnail_url
      }
    end

    return dataSet
  end

  def insert_ad(payload, ad_account, session)
    begin
      ad = ad_account.ads.create({
                                      status: 'PAUSED',
                                      name: payload['ad']['name'],
                                      adset_id: 23842623365670124,
                                      creative: {
                                          object_story_spec: {
                                              page_id: 125260784796068,
                                              link_data: {
                                                  link: payload['ad']['link_url'],
                                                  # message: "Message 1",
                                                  # name: "Name 1",
                                                  attachment_style: "link",
                                                  call_to_action: {
                                                      type: "LEARN_MORE"
                                                  }
                                              }
                                          },
                                          # title: 'My Add',
                                          # body: 'Body of the first Ad1',
                                          object_ur: 'https://www.scientificamerican.com/podcast/episode/wetlands-could-save-cities-and-money-too/',
                                      },
                                  })
      return {"ad"=>{"id" => ad.id, "name" => ad.name, "thumbnail_url" => FacebookAds::AdCreative.get(ad.creative.id, 'thumbnail_url', @session).thumbnail_url}}
    rescue => e
      raise e.message
    end
  end
end
