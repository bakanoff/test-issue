require 'pry'

class Account

	def initialize
		@transactions = []
	end

	def balance
    @transactions.inject(0) { |sum, transaction| sum + transaction }
  end

  def real_banknotes(banknotes, amount, denominations)
  	calculated_banknotes = atm(amount, denominations)
  	new_amount = amount
  	@real_hash = {}
  	while banknotes.length > 0 do
  		if banknotes.values.first < calculated_banknotes.values.first
  			add_hash_element(banknotes)
  			new_amount -= banknotes.keys.first * banknotes.values.first
  			denominations.shift
				calculated_banknotes = atm(new_amount, denominations)
				cut_hash(banknotes)
  		else
  			add_hash_element(calculated_banknotes)
  			cut_hash(banknotes)
  			cut_hash(calculated_banknotes)
  		end
  	end
  	
    check_sum(@real_hash, amount)
    @real_hash
  end

	private

  def atm(amount, denominations)
  	raw_data = denominations.inject({}) do |hash, denomination|
  		hash[denomination] = amount.divmod(denomination)
  		amount -= amount.divmod(denomination).first * denomination
  		hash
  	end

  	raw_data.map { |k, v|
  		raw_data[k] = v.first
  	}

  	raw_data
  end

  def check_sum(hash, amount)
  	calculated_sum = hash.map { |k, v| k*v if v > 0 }.compact.sum
    @transactions << -calculated_sum
  	available_banknotes = hash.keys
  	if calculated_sum != amount
  		calculated_sum != 0 ? (puts "WARNING: THE AMOUNT YOU REQUESTED CANNOT BE COMPOSED FROM BILLS AVAILABLE IN THIS ATM. AVAILABLE AMOUNT ₴#{calculated_sum} WAS WITHDRAWN") :
  													(puts "WARNING: THE AMOUNT YOU REQUESTED CANNOT BE COMPOSED FROM BILLS AVAILABLE IN THIS ATM. AVAILABLE BANKNOTES ARE: #{available_banknotes}")
  		puts hash
  	else
  		puts hash
  	end
  end

  def cut_hash(hash)
    hash = hash.tap { |h| h.delete(hash.keys.first) }
  end

  def add_hash_element(base_hash)
    @real_hash[base_hash.first[0]] = base_hash.first[1]
  end

end