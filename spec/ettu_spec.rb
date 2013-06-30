require 'spec_helper'

Record = Struct.new(:updated_at)
Nested = Struct.new(:nil) do
  def [](name)
    nil
  end
  def method_missing(name, *args, &block)
    return self
  end
end
module Rails
  module Railtie; end

  def self.application
    Nested.new(nil)
  end
end

describe Ettu do
  let(:record) { Record.new(DateTime.now) }
  let(:hash) { { etag: record, last_modified: DateTime.now, public: false, random: true } }

  context 'when supplied with :js option' do
    xit "returns hash[:js]'s fingerprint as #js_etag"
  end

  context 'when supplied with :css option' do
    xit "returns hash[:css]'s fingerprint as #css_etag"
  end

  xit '#view_etag'


  context '.configure' do

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
