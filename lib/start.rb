require_relative 'account'
require 'pry'
require 'bcrypt'
require 'yaml'

class InvalidLogin < StandardError; end

class StartAtm
	OPTIONS = [
				  '1. Display Balance',
				  '2. Withdraw',
				  '3. Log Out'
				]

	def initialize(config)
		@config = config
		@banknotes = @config['banknotes'].delete_if { |k, v| v == 0 }
		@denominations = @banknotes.keys
		@available_sum = @banknotes.map { |k, v| k*v }.sum
	end

	def start
		@retries ||= 0
		if login
			@transactions = 0
			name = @config['accounts'][@acc_num.to_i]['name']
			@start_balance = @config['accounts'][@acc_num.to_i]['balance']
			@account = Account.new
			puts "Hello, #{name}!"
			loop do
				puts "Please Choose From the Following Options:"
				puts OPTIONS.join("\n")
				@current_balance = balance
				case STDIN.gets.chomp
				when '1'
					puts "Your Current Balance is ₴#{@current_balance}"
				when '2'
					withdraw
				when '3'
					puts "#{name}, Thank You For Using Our ATM. Good-Bye!"
					update_config
					break
				else
					puts "Wrong option. Choose from list."
				end
			end
		else
			invalid_login
		end
	end

	private

	def login
		puts "Please Enter Your Account Number:"
		@acc_num = STDIN.gets.chomp
		puts "Enter Your Password:"
		@pass = STDIN.gets.chomp
		@config['accounts'].include?(@acc_num.to_i) && decoded_pass == @pass.to_s
	end

	def decoded_pass
		BCrypt::Password.new(@config['accounts'][@acc_num.to_i]['password'])
	end

	def balance
		if @transactions == 0
			@balance = @start_balance
		else
			@balance = @start_balance + @account.balance
		end
		@balance
	end

	def withdraw
		@transactions += 1
		puts "Enter Amount You Wish to Withdraw:"
		amount = STDIN.gets.chomp.to_i
		if amount <= @current_balance
			if amount <= @available_sum
				new_banknotes = @banknotes.clone
				@real_hash = @account.real_banknotes(@banknotes, amount, @denominations)
				@current_balance = balance
				atm_money(@real_hash, new_banknotes)
				puts "Your New Balance is ₴#{@current_balance}"
			else
				@available_sum != 0 ? (puts "ERROR: THE MAXIMUM AMOUNT AVAILABLE IN THIS ATM IS ₴#{@available_sum}. PLEASE ENTER A DIFFERENT AMOUNT:") :
															(puts "SORRY, THIS ATM IS EMPTY. WE WILL FILL IT SOON")
			end
		else
			STDERR.puts("ERROR: INSUFFICIENT FUNDS!! YOUR BALANCE IS ₴#{@current_balance}. PLEASE ENTER A DIFFERENT AMOUNT:")
		end
	end

	def atm_money(real_hash, banknotes)
  	@banknotes = banknotes.merge(real_hash){|key, oldval, newval| oldval - newval }.delete_if { |k, v| v == 0 }
  	@denominations = @banknotes.keys
  	@available_sum = @banknotes.map { |k, v| k*v }.sum
  end

  def update_config
  	@config['accounts'][@acc_num.to_i]['balance'] = balance
  	@banknotes = @config['banknotes'] = @banknotes
  	File.write('./config.yml', @config.to_yaml)
  end

  def invalid_login
		@retries += 1
  	if @retries < 3
  		puts "ERROR: ACCOUNT NUMBER AND PASSWORD DON'T MATCH. YOU HAVE #{3 - @retries} MORE TRYES"
  		start
  	else
  		raise InvalidLogin, "ACCOUNT NUMBER AND PASSWORD DON'T MATCH"
  	end
  end

end