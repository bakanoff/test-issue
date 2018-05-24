require './lib/start.rb'
require 'yaml'

describe StartAtm do
  subject { described_class.new(config) }
  let(:config) { YAML.load_file('./spec/spec_config.yml') }

    it "checking subject" do
      expect(subject).to be_instance_of(StartAtm)
    end
    
    it "return bulance" do
      allow(subject).to receive(:balance).and_return(config['accounts'][3321]['balance'])
      expect(subject.send :balance).to eq(422)
    end

    it "login" do
      allow($stdin).to receive(:gets).and_return(3321, 'mypass')
      acc_num = $stdin.gets
      pass = $stdin.gets
      expect(acc_num).to eq(3321)
      expect(pass).to eq('mypass')
    end

    it "atm_money" do
      real_hash = {}
      banknotes = []
      dbl = double(subject)
      expect(dbl).to receive(:atm_money).with(real_hash, banknotes)
      dbl.send :atm_money, real_hash, banknotes
    end

end