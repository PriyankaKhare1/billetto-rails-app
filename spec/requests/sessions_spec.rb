# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Clerk session callback", type: :request do
  let(:signing_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:jwk) { JWT::JWK.new(signing_key, kid: "test-key") }

  before do
    allow(Clerk::SDK.jwks_cache).to receive(:fetch).and_return([jwk.export])
  end

  it "rejects a client-supplied user ID without a signed token" do
    post "/clerk/callback", params: { clerk_user_id: "user_forged" }, as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(session[:clerk_user_id]).to be_nil
  end

  it "stores the subject from a valid Clerk-signed token" do
    post "/clerk/callback",
      params: {},
      headers: { "Authorization" => "Bearer #{signed_token(signing_key, "user_verified")}" },
      as: :json

    expect(response).to have_http_status(:ok)
    expect(session[:clerk_user_id]).to eq("user_verified")
  end

  it "rejects a token signed by a different key" do
    forged_key = OpenSSL::PKey::RSA.generate(2048)
    post "/clerk/callback",
      params: {},
      headers: { "Authorization" => "Bearer #{signed_token(forged_key, "user_forged")}" },
      as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(session[:clerk_user_id]).to be_nil
  end

  private

  def signed_token(key, user_id)
    JWT.encode(
      { sub: user_id, exp: 5.minutes.from_now.to_i },
      key,
      "RS256",
      { kid: "test-key" }
    )
  end
end
