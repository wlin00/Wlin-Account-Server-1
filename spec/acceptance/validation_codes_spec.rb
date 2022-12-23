require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "ValidationCodes" do
  post "/api/v1/validation_codes" do
    parameter :email, type: :string
    let(:email) { 'wlin0z@163.com' }
    example "send validation code" do
      do_request
      expect(status).to eq 200
    end
  end
end