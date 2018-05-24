require './lib/account.rb'

describe Account do
  before { subject.instance_variable_set(:@real_hash, {}) }
  let (:banknotes) { {100 => 2, 50 => 1, 20 => 2, 10 => 4, 5 => 1, 1 => 2} }
  let (:amount) { 322 }
  let (:denominations) { [100, 50, 20, 10, 5, 1]}
  let (:result) { {100 => 2, 50 => 1, 20 => 2, 10 => 3, 5=>0, 1 => 2} }

  it "real banknotes" do
    expect(subject.real_banknotes(banknotes, amount, denominations)).to eq(result)
  end

  it "account balance" do
    allow(subject).to receive(:balance).and_return(-100)
    expect(subject.balance).to eq(-100)
  end

  it "check hash cutting" do
    expect(subject.send :cut_hash, banknotes).to eq({50 => 1, 20 => 2, 10 => 4, 5 => 1, 1 => 2})
  end

  it "check adding element to hash" do
    
    expect(subject.send :add_hash_element, banknotes).to eq(2)
  end

  context "#check_sum" do
    it "shold return hash if sum available" do
      expect{subject.send :check_sum, result, amount}.to output{result}.to_stdout
    end

    it "shold withdraw available amount if requested sum isn't available" do
      expect{subject.send :check_sum, result, 323}.to output(/AVAILABLE AMOUNT/).to_stdout
    end

    it "shold show available banknotes if sum less than minimal banknote" do
      expect{subject.send :check_sum, {10 => 0}, 5}.to output(/AVAILABLE BANKNOTES/).to_stdout
    end
  end

end