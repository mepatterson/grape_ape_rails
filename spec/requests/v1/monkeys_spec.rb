require 'spec_helper'

describe API::V1::Monkeys do
  describe "GET /monkeys/:id" do
    let(:monkey) { FactoryGirl.create(:monkey) }

    it "requires a version header" do
      get "/monkeys/#{monkey.id}", {}, { 'Content-Type' => 'application/json' }
      json = MultiJson.load(response.body, symbolize_keys: true)
      expect(json_error[:code]).to eql "UNAUTHORIZED"
      expect(json_error[:message]).to eql "[UNAUTHORIZED] Cannot determine API version from header info."
      expect(response.status).to eql 401
    end

    it "returns a single monkey by id, using the ActiveModelSerializers" do
      req :get, "/monkeys/#{monkey.id}"
      expect(response.status).to eql 200
      expect(json_result[:monkeys].size).to eql 1
      expect(json_result[:monkeys].first[:name]).to eql "Frank the Monkey"
    end
  end
  describe "GET /monkeys" do
    it "returns multiple monkeys, using the ActiveModelSerializers" do
      3.times { FactoryGirl.create :monkey }
      req :get, "/monkeys"
      expect(response.status).to eql 200
      expect(json_result[:monkeys].size).to eql 3
    end
  end

  describe "GET /nothings" do
    it "returns proper empty array [], using the ActiveModelSerializers" do
      3.times { FactoryGirl.create :monkey }
      req :get, "/nothing_monkeys"
      expect(response.status).to eql 200
      expect(json_result[:nothing_monkeys]).to eql([])
    end
  end

end
