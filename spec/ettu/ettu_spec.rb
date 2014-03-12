require 'spec_helper'

describe Ettu do
  subject(:ettu) { Ettu.new(hash, {}, controller) }

  let(:controller) { Controller.new }
  let(:record) { Record.new(DateTime.now) }
  let(:hash) { { etag: record, last_modified: DateTime.now } }

  # NOTE: assets were created by running `rake assets:precompile`.
  # It compiled application.js and application.css (but NOT
  # test.js)
  let(:assets) { ::ActionView::Base.assets_manifest.assets }
  let(:files) { assets.keys }
  let(:digests) { assets.values }

  before(:each) do
    Ettu.configure do |config|
      config.reset
      config.template_digestor = Digestor
    end
  end

  after(:all) do
    Ettu.configure { |config| config.reset }
  end

  context 'when supplied with options' do
    let(:hash) { { assets: files.first, view: 'custom/action' } }

    it 'will use :asset option over default' do
      expect(ettu.asset_etags).to eq([digests.first])
    end

    it 'will use :view option over default' do
      expect(ettu.view_etag).to eq('custom/action.digest')
    end
  end

  context 'when given asset that is not precompiled' do
    it 'will digest the file if it exists' do
      # NOTE: test.js is located at dummy/app/assets/javascripts/test.js
      # It was added AFTER running `rake assets:precompile` (which compiled
      # application.js and application.css).
      def hash; { assets: 'test.js' }; end

      expect(ettu.asset_etags).not_to be_empty
    end

    it 'will throw error if file does not exist' do
      def hash; { assets: 'does_not_exist' }; end

      expect{ ettu.asset_etags }.to raise_error
    end
  end

  describe '.configure' do
    let(:hash) { nil }

    context 'when no options are specified' do
      it 'will use the default asset files' do
        expect(ettu.asset_etags).to eq(digests)
      end

      it 'will use the default view file' do
        Ettu.configure { |config| config.view = 'custom/view' }

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
      it 'will disable asset etags' do
        Ettu.configure { |config| config.assets = false }

        expect(ettu.asset_etags).to eq([nil])
      end

      it 'will disable view etags' do
        Ettu.configure { |config| config.view = false }

        expect(ettu.view_etag).to eq(nil)
      end
    end
  end

  describe '#etags' do
    subject(:ettu) { Ettu.new(record, {}, controller) }

    it 'will collect all etags' do
      expected = [record, 'controller_name/action_name.digest'] | digests
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
