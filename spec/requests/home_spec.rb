require "rails_helper"

RSpec.describe "Home", type: :request do
  it "returns 200 for the root path" do
    get "/"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Task Manager")
  end
end