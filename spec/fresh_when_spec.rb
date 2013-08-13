require 'spec_helper'


describe Ettu::FreshWhen do
  before(:all) do
    Ettu.configure { |config| config.template_digestor = Digestor }
  end

  let(:record) { Record.new(DateTime.now) }
  let(:hash) { { random: true, options: true } }
  subject(:controller) { Controller.new }

  it 'passes nil as the first argument to original fresh_when' do
    ret = controller.fresh_when record, hash

    expect(ret[0]).to equal(nil)
  end

  it 'passes extra options to original fresh_when' do
    ret = controller.fresh_when record, hash

    expect(ret[1]).to include_hash(hash)
  end
end
