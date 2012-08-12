require 'addressable/uri'
require 'json'
require 'rest_client'

class ShipShop 
	HOST = "localhost:3000"

	def run
		puts ""
		puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		puts "Who wants to keep track of all this $$$$ ??"
		puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		puts ""
		command = ""
		puts "Here are the customers:"
		puts ""
		#call the get_customers method to return all the customers
		puts get_customers
		puts ""
        while command != "q"
			printf "Would you like to VIEW a customer or CREATE a customer?"
			puts ""
			command = gets.chomp
			case command
			  when "view" 
			  	printf "Which customer number do you want to view?"
			  	puts ""
			  	input = gets.chomp
			  	puts ""
			  	name = get_customer_name(input)
			  	puts "The orders customer for #{name}:"
			  	#call the get_customer method to return the customer of orders associated with that customer
			  	get_orders(input)
			  	puts ""
			  when "create"
			  	#call the add_customer method 
			  	printf "What is the customer's first name?"
			  	puts ""
			  	first_name = gets.chomp
			  	puts ""
			  	printf "What is the customer's last name?"
			  	puts ""
			  	last_name = gets.chomp
			  	create_new_customer(first_name, last_name) 
			  	printf "Your customer: #{first_name} #{last_name} has been created"
			  	puts ""
			  	while command != "done"
			  		printf "Add a order now or type 'done' if no more orders to add"
			  		puts ""
			  		command = gets.chomp
			  		if command != "done"
				  		item = command
				  		printf "what's the price of that order?"
			  			puts ""
			  			price = gets.chomp
				  		puts "customer: #{first_name} #{last_name}"
				  		get_last_customer
				  		create_new_order(item, price)
				  		puts get_orders(@customer_id)
				  		puts ""
				  	end
			  	end
			  else
			  	puts "pick either 'view' or 'create' please you lazy bum..."
			end
        end
	end

	def parse_response(response)
	  JSON.parse(response, :symbolize_names => true)
	end


	def get_customers
		all_customers = RestClient.get(Addressable::URI.new({
		    :scheme => "http",
		    :host => HOST,
		    :path => "/customers.json"
		  }).to_s)
		parsed_customers = parse_response(all_customers)
		get_customers_names(parsed_customers)
	end

	def get_customers_names(customers)
		customers.each do |customer|
			puts "#{customer[:id]}. #{customer[:first_name]} #{customer[:last_name]}"
		end
		return ""
	end

	def get_customer_name(customer_id)
		customer = RestClient.get(Addressable::URI.new({
		    :scheme => "http",
		    :host => HOST,
		    :path => "/customers/#{customer_id}.json"
		  }).to_s)
		parsed_customer = parse_response(customer)
		parsed_customer[:first_name] + parsed_customer[:last_name]
	end

	def get_last_customer
		all_customers = RestClient.get(Addressable::URI.new({
		    :scheme => "http",
		    :host => HOST,
		    :path => "/customers.json"
		  }).to_s)
		parsed_customers = parse_response(all_customers)
		last_customer = parsed_customers.last
		@customer_id = last_customer[:id]
		@customer_first_name = last_customer[:first_name]
		@customer_last_name = last_customer[:last_name]
		return ""
	end

	def get_orders(customer_id)
		all_orders = RestClient.get(Addressable::URI.new({
		    :scheme => "http",
		    :host => HOST,
		    :path => "/orders.json",
		    :query_values => {
		    	:customer_id => customer_id
		    }
		  }).to_s)
		parsed_orders = parse_response(all_orders)
		get_orders_items(parsed_orders)
	end



	def get_orders_items(orders)
		orders.each do |order|
			puts "#{order[:item]}: #{order[:price]}"
		end
		return ""
	end

	def create_new_customer(first_name, last_name)
	  begin
	    RestClient.post(Addressable::URI.new({
	      :scheme => "http",
	      :host => HOST,
	      :path => "/customers.json"
	    }).to_s, {
	      :customer => {
	        :first_name => first_name,
	        :last_name => last_name
	      }
	    })
	  rescue RestClient::UnprocessableEntity => e
	    puts e.response
	  end
	end

	def create_new_order(item,price)
	  begin
	    RestClient.post(Addressable::URI.new({
	      :scheme => "http",
	      :host => HOST,
	      :path => "/orders.json"
	    }).to_s, {
	      :order => {
	      	:item => item,
	        :price => price,
	        :customer_id => @customer_id,
	      }
	    })
	  rescue RestClient::UnprocessableEntity => e
	    puts e.response
	  end
	end




end

ss = ShipShop.new
ss.run