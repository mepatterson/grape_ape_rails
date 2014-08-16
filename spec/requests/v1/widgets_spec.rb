require 'spec_helper'

describe API::V1::Widgets do

  describe 'GET /health' do
    it "responds to health" do
      get "/health"
      expect(response.status).to eql 200
    end
  end

  describe "GET /widgets/:id/:name" do
    let(:widget) { FactoryGirl.create(:widget) }

    it "validates the name requirement" do
      req :get, "/widgets/#{widget.id}/named?foo=42"
      expect(response.status).to eql 422
    end
  end

  describe 'POST /widgets' do
    let(:attrs) { { name: 'New Widget', color: 'orange', radioactive: false, rads: 587 } }
    before do
      req :post, "/widgets", { params: MultiJson.dump(attrs) }
    end
    it 'succeeds (201)' do
      expect(response.status).to eql 201
    end
    it 'returns the widget' do
      expect(json_result[:widgets].first).to eql(attrs.merge({ id: 1}))
    end
    describe 'PUT /widgets/1' do
      let(:update_attrs) { { name: 'Updated', color: 'red' } }
      before do
        req :post, "/widgets", { params: MultiJson.dump(attrs) }
        expect(response.status).to eql 201
        req :put, "/widgets/1", { params: MultiJson.dump(update_attrs) }
      end
      it 'succeeds (200)' do
        expect(response.status).to eql 200
      end
      it 'returns the updated widget' do
        expect(json_result[:widgets].first).to eql(attrs.merge({ id: 1}).merge(update_attrs))
      end
    end
    describe 'PUT /widgets/1 INVALID' do
      let(:bad_attrs) { { color: 'xxxxxx' } }
      before do
        req :put, "/widgets/1", { params: MultiJson.dump(bad_attrs) }
      end
      it 'fails (422)' do
        expect(response.status).to eql 422
      end
      it 'responds with a validation error hash' do
        expect(json_error).to eql({ code: 'UPDATE_WIDGET_FAILED', message: '[UPDATE_WIDGET_FAILED] Resource failed validation. color is not included in the list' })
      end
    end
  end

  describe 'POST /widgets INVALID' do
    let(:bad_attrs) { { name: 'Bad Widget', color: 'xxxxxx', radioactive: false, rads: 587 } }
    before do
      req :post, "/widgets", { params: MultiJson.dump(bad_attrs) }
    end
    it 'fails (422)' do
      expect(response.status).to eql 422
    end
    it 'responds with a validation error hash' do
      expect(json_error).to eql({ code: 'CREATE_WIDGET_FAILED', message: '[CREATE_WIDGET_FAILED] Resource failed validation. color is not included in the list' })
    end
  end

  describe "GET /widgets/:id" do
    let(:widget) { FactoryGirl.create(:widget) }

    it "requires a versioned header request" do
      get "/widgets/#{widget.id}", {}, { 'Content-Type' => 'application/json' }
      json = MultiJson.load(response.body, symbolize_keys: true)
      expect(json_error[:code]).to eql "UNAUTHORIZED"
      expect(json_error[:message]).to eql "[UNAUTHORIZED] Cannot determine API version from header info."
      expect(response.status).to eql 401
    end

    it "returns a widget by id" do
      req :get, "/widgets/#{widget.id}"
      expect(response.status).to eql 200
      expect(json_result[:widgets].size).to eql 1
      expect(json_result[:widgets].first[:name]).to eql "Magical Widget Alpha"
    end

    it 'sets the default locale' do
      req :get, "/widgets/#{widget.id}"
      expect(I18n.locale).to eql :en
    end

    describe 'specifying a locale via header' do
      it "sets the proper locale" do
        req :get, "/widgets/#{widget.id}", { locale: 'jp' }
        expect(response.status).to eql 200
        expect(I18n.locale).to eql :jp
      end
    end
    describe 'specifying a locale via param' do
      it "sets the proper locale" do
        req :get, "/widgets/#{widget.id}?locale=es"
        expect(response.status).to eql 200
        expect(I18n.locale).to eql :es
      end
    end
  end

  describe 'GET /widgets' do
    before do
      3.times { FactoryGirl.create(:widget) }
    end
    it 'returns a list of widgets' do
      req :get, "/widgets"
      expect(response.status).to eql 200
      expect(json_result[:widgets].size).to eql 3
      expect(json_result[:widgets].map{|w| w[:id]}.uniq.size).to eql 3
    end
  end

end
