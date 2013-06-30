require 'spec_helper'

describe Ettu do
  before(:each) { Ettu.configure { |config| config.reset } }
  let(:record) { Record.new(DateTime.now) }
  let(:hash) { { etag: record, last_modified: DateTime.now } }

  context 'when supplied with options' do
    let(:hash) { { js: 'custom.js', css: 'custom.css', assets: 'first.ext' } }
    subject(:ettu) { Ettu.new(hash) }

    it 'will use :js option over default' do
      expect(ettu.js_etag).to eq('custom.js.digest')
    end

    it 'will use :css option over default' do
      expect(ettu.css_etag).to eq('custom.css.digest')
    end

    it 'will use :asset option over default' do
      expect(ettu.asset_etags).to eq(['first.ext.digest'])
    end
  end

  xit '#view_etag'

  context '.configure' do
    subject(:ettu) { Ettu.new }
    context 'can configure default js file' do
      it 'will use that js file when none is specified' do
        Ettu.configure { |config| config.js = 'custom.js' }
        expect(ettu.js_etag).to eq('custom.js.digest')
      end
    end

    context 'can configure default css file' do
      it 'will use that css file when none is specified' do
        Ettu.configure { |config| config.css = 'custom.css' }
        expect(ettu.css_etag).to eq('custom.css.digest')
      end
    end

    context 'can configure default asset file' do
      it 'will use that file when none is specified' do
        Ettu.configure { |config| config.assets = 'first.ext' }
        expect(ettu.asset_etags).to eq(['first.ext.digest'])
      end

      it 'can configure multiple default asset files' do
        Ettu.configure { |config| config.assets = ['first.ext', 'second.ext'] }
        expect(ettu.asset_etags).to eq(['first.ext.digest', 'second.ext.digest'])
      end
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
