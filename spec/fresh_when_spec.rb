require 'spec_helper'


describe Ettu::FreshWhen do
  before(:all) do
    Ettu.configure { |config| config.template_digestor = Digestor }
  end

  let(:ettu) { double }
  let(:record) { Record.new(DateTime.now) }
  let(:hash) { { random: true, options: true } }
  subject(:controller) { Controller.new }

  before(:each) do
    controller.stub(ettu_instance: ettu)
    ettu.stub(:etags)
    ettu.stub(:last_modified)
    ettu.stub(options: {})
  end

  it 'calls Ettu#etags' do
    ettu.should_receive(:etags)
    controller.fresh_when record, hash
  end

  it 'calls Ettu#last_modified' do
    ettu.should_receive(:last_modified)
    controller.fresh_when record, hash
  end

  it 'passes nil as the first argument to original fresh_when' do
    controller.should_receive(:old_fresh_when) do |r, h|
      r.nil?
    end
    controller.fresh_when record, hash
  end

  it 'passes extra options to original fresh_when' do
    controller.should_receive(:old_fresh_when) do |r, h|
      hash.each_pair.all? do |k, v|
        h[k] == v
      end
    end
    controller.fresh_when record, hash
  end
end
