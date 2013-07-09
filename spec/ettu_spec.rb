require 'spec_helper'

describe Ettu do
  let(:controller) { Controller.new }
  let(:record) { Record.new(DateTime.now) }
  let(:hash) { { etag: record, last_modified: DateTime.now } }

  context 'when supplied with options' do
    before(:all) do
      Ettu.configure { |config| config.template_digestor = Digestor }
    end
    let(:hash) { { assets: 'first.ext', view: 'custom/action' } }
    subject(:ettu) { Ettu.new(hash, {}, controller) }

    it 'will use :asset option over default' do
      expect(ettu.asset_etags).to eq(['first.ext.digest'])
    end

    it 'will use :view option over default' do
      expect(ettu.view_etag).to eq('custom/action.digest')
    end
  end

  describe '.configure' do
    subject(:ettu) { Ettu.new(nil, {}, controller) }
    before(:all) do
      Ettu.configure { |config| config.template_digestor = Digestor }
    end
    after(:all) { Ettu.configure { |config| config.reset } }

    context 'when no options are specified' do
      before(:all) do
        Ettu.configure do |config|
          config.assets = ['first.ext', 'second.ext']
          config.view = 'custom/view'
        end
      end

      it 'will use the default asset files' do
        expect(ettu.asset_etags).to eq(['first.ext.digest', 'second.ext.digest'])
      end

      it 'will use the default view file' do
        expect(ettu.view_etag).to eq('custom/view.digest')
      end
    end

    context 'can append additional assets' do
      let(:configuration) { Ettu::Configuration.new }
      let(:random_string) { SecureRandom.hex }

      it 'with +=' do
        configuration.assets += [random_string]
        expect(configuration.assets).to include(random_string)
      end

      it 'with <<' do
        configuration.assets << random_string
        expect(configuration.assets).to include(random_string)
      end
    end

    context 'when setting default to false' do
      before(:all) do
        Ettu.configure do |config|
          config.assets = false
          config.view = false
        end
      end

      it 'will disable asset etags' do
        expect(ettu.asset_etags).to eq([nil])
      end

      it 'will disable view etags' do
        expect(ettu.view_etag).to eq(nil)
      end
    end
  end

  describe '#etags' do
    before(:all) do
      Ettu.configure { |config| config.template_digestor = Digestor }
    end
    let(:ettu) { Ettu.new(record, {}, controller) }

    it 'will collect all etags' do
      expected = [
        record, 'controller_name/action_name.digest',
       'application.js.manifest', 'application.css.manifest',
       'custom.js.manifest', 'custom.css.manifest',
       'first.ext.manifest', 'second.ext.manifest'
      ]
      result = ettu.etags
      expect(result).to include(*expected)
      expect(expected).to include(*result)
    end

    it 'will not allow nils' do
      ettu = Ettu.new(nil, {assets: [nil, nil, nil]}, controller )
      expect(ettu.etags).not_to include(nil)
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
