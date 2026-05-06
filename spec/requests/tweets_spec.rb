# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tweets', type: :request do
  before do
    user = create(:user)
    sign_in user
  end

  it 'GET /tweets 正常に表示される' do
    get tweets_path
    expect(response).to have_http_status(:ok)
  end
end
