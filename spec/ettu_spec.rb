require 'spec_helper'

describe Ettu do
  let(:controller) { Controller.new }
  let(:record) { Record.new(DateTime.now) }
  let(:hash) { { etag: record, last_modified: DateTime.now } }
  before(:all) do
    Ettu.configure { |config| config.template_digestor = Digestor }
  end

  context 'when supplied with options' do
    let(:hash) { { js: 'custom.js', css: 'custom.css', assets: 'first.ext', view: 'custom/action' } }
    subject(:ettu) { Ettu.new(hash, {}, controller) }

    it 'will use :js option over default' do
      expect(ettu.js_etag).to eq('custom.js.digest')
    end

    it 'will use :css option over default' do
      expect(ettu.css_etag).to eq('custom.css.digest')
    end

    it 'will use :asset option over default' do
      expect(ettu.asset_etags).to eq(['first.ext.digest'])
    end

    it 'will use :view option over default' do
      expect(ettu.view_etag).to eq('custom/action.digest')
    end
  end

  describe '.configure' do
    subject(:ettu) { Ettu.new(nil, {}, controller) }

    context 'when no options are specified' do
      before(:all) do
        Ettu.configure do |config|
          config.js = 'custom.js'
          config.css = 'custom.css'
          config.assets = ['first.ext', 'second.ext']
          config.view = 'custom/view'
        end
      end
      after(:all) { Ettu.configure { |config| config.reset } }

      it 'will use the default js file' do
        expect(ettu.js_etag).to eq('custom.js.digest')
      end

      it 'will use the default css file' do
        expect(ettu.css_etag).to eq('custom.css.digest')
      end

      it 'will use the default asset files' do
        expect(ettu.asset_etags).to eq(['first.ext.digest', 'second.ext.digest'])
      end

      it 'will use the default view file' do
        expect(ettu.view_etag).to eq('custom/view.digest')
      end
    end

    context 'when setting default to false' do
      before(:all) do
        Ettu.configure do |config|
          config.js = false
          config.css = false
          config.view = false
        end
      end
      after(:all) { Ettu.configure { |config| config.reset } }

      it 'will disable js etag' do
        expect(ettu.js_etag).to eq(nil)
      end

      it 'will disable css etag' do
        expect(ettu.css_etag).to eq(nil)
      end

      it 'will disable view etags' do
        expect(ettu.view_etag).to eq(nil)
      end
    end
  end

  describe '#etags' do
    let(:ettu) { Ettu.new(record, {}, controller) }
    it 'will collect all etags' do
      expected = [record, 'controller_name/action_name.digest', 'application.js.digest', 'application.css.digest']
      result = ettu.etags
      expect(ettu.etags).to include(*expected)
      expect(expected).to include(*result)
    end
  end

  context 'when given only a record' do
    subject(:ettu) { Ettu.new(record) }

    it 'makes #options an hash' do
      expect(ettu.options).to be_a(Hash)
    end

    it 'makes #options an empty hash' do
      expect(ettu.options).to be_empty
    end

    it 'uses record as #response_etag' do
      expect(ettu.response_etag).to eq(record)
    end

    it "uses record's #updated_at for #last_modified" do
      expect(ettu.last_modified).to eq(record.updated_at)
    end
  end

  context 'when given only a hash' do
    subject(:ettu) { Ettu.new(hash) }

    it 'sets #options to that hash' do
      expect(ettu.options).to eq(hash)
    end

    it 'uses hash[:etag] as #response_etag' do
      expect(ettu.response_etag).to eq(hash[:etag])
    end

    it 'uses hash[:last_modified] as #last_modified' do
      expect(ettu.last_modified).to eq(hash[:last_modified])
    end
  end

  context 'when given a record and hash' do
    let(:hash) { { public: true } }
    subject(:ettu) { Ettu.new(record, hash) }

    it 'sets #options to the hash' do
      expect(ettu.options).to eq(hash)
    end

    describe '#response_etag' do
      it 'uses record as #response_etag' do 
        expect(ettu.response_etag).to eq(record)
      end

      context 'when supplied with hash with :etag' do
        let(:hash) { { etag: 'hash' } }

        it 'overrides #response_etag with hash[:etag]' do
          expect(ettu.response_etag).to eq(hash[:etag])
        end
      end
    end

    describe '#last_modified' do
      it "uses record's #updated_at as #last_modified" do 
        expect(ettu.last_modified).to eq(record.updated_at)
      end

      context 'when supplied with hash with :last_modified' do
        let(:hash) { { last_modified: 'now' } }

        it 'overrides #last_modified with hash[:last_modified]' do
          expect(ettu.last_modified).to eq(hash[:last_modified])
        end
      end
    end
  end

end
