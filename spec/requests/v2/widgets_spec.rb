require 'spec_helper'

describe API::V2::Widgets do
  describe 'GET /widgets' do
    before do
      3.times { FactoryGirl.create(:widget) }
      req :get, "/widgets", { version: 'v2' }
    end

    it 'returns a list of widgets' do
      expect(response.status).to eql 200
      expect(json_result[:widgets].size).to eql 3
      expect(json_result[:widgets].map{|w| w[:id]}.uniq.size).to eql 3
    end

    it 'still uses the V1 response structure' do
      widget = json_result[:widgets].first
      expect(widget[:radioactive]).to eql true
      expect(widget[:rads]).to eql 150
    end
  end

  describe "GET /widgets/:id" do
    let(:widget) { FactoryGirl.create(:widget) }
    before do
      req :get, "/widgets/#{widget.id}", { version: 'v2' }
    end
    it "returns a widget by id" do
      expect(response.status).to eql 200
      expect(json_result[:widgets].size).to eql 1
      expect(json_result[:widgets].first[:name]).to eql "Magical Widget Alpha"
    end

    it "includes the new V2 format for radioactive hash" do
      widget = json_result[:widgets].first
      expect(widget[:radioactive]).to eql({ rads: 150, per_day: 7 })
      expect(widget[:rads]).to eql 150
    end

  end
end
