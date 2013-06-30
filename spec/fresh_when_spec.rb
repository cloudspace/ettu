describe Ettu::FreshWhen do
  context 'when given extra options' do
    subject(:ettu) { Ettu.new(record) }

    it "passes those options to Rails' fresh_when"
    it "calls #old_fresh_when"
  end
end
